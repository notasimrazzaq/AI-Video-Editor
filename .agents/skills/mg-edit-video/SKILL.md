---
name: mg-edit-video
description: "Add motion graphics on top of the user's own raw / talking-head video (Damiano 'Motion Graphics with Claude Code' workflow, PROMPT 11 + 12). Use when: the user gives a raw video, reel, clip or footage and wants it edited, animated, 'made into a masterpiece', cards/counters/checklists added, or a specific moment fixed ('when I say X, show Y')."
argument-hint: "Path to the raw video (e.g. raw/my-reel.mp4), optional style name, optional notes"
---

# Motion graphics on the user's own video

Workspace layer on top of the installed HyperFrames skills. For HTML/timeline mechanics, load
`hyperframes-core` (composition contract) and `hyperframes-animation` (GSAP rules); the closest
upstream route is `talking-head-recut`. This skill adds the creator's house rules, which win on conflict.

## Fast path (proven on reel-sep30, 3:20 Urdu/English reel, Paper Cut)
1. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/new-project.ps1 -Name <n> -Video raw/<file> -Transcribe` → Deepgram transcript in seconds.
2. Dump `transcript-words.txt` (index:text@start) → read it, summarise, pick moments.
3. Captions: `captions-src.json` (Roman Hinglish chunks by word index) → `node tools/build-captions.mjs projects/<n>`.
4. Style template: copy `kit/templates/paper-cut-vertical.html` → `index.html`; set both `data-duration`s; replace the EXAMPLE calls with this video's moments.
5. `lint` → `snapshot --at ...` (2 batches of ~12 frames) → view contact sheets → fix.
6. Sounds: write `sfx.json` from the offsets table in `mg-sound` → `node tools/sfx.mjs projects/<n>` (BEFORE rendering, so one render includes them).
7. Tell the user the render time up front (see `mg-export`: ~25–30 min per minute of 1080x1920 video on a 4-core laptop), then render once, copy to `exports/`.
8. Later tweaks: audio-only → `sfx.mjs --mix` (seconds, no re-render). Visual tweaks → snapshot first, then one re-render.

Don't: install local speech models, resume stalled downloads, render to "check" anything (use snapshots), or preview in VS Code's player (no AAC audio — use VLC).

## 1. Set up the project
1. If the video isn't in `raw/`, it can stay where it is. Pick a short kebab-case project name from the file name.
2. Run (from the workspace root):
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File tools/new-project.ps1 -Name "<name>" -Video "<path>" -Transcribe
   ```
   - Transcription uses **Deepgram** (`nova-3`, `language=multi` by default: handles Urdu/Hindi + English code-switching; Hindi/Urdu words may come back in Devanagari — romanise to Hinglish, keep timings). Needs the user env var `DEEPGRAM_API_KEY`; if missing, ask the user to run `powershell -NoProfile -ExecutionPolicy Bypass -File tools/set-deepgram-key.ps1` themselves (never in chat). English-only video: `-Language en`. Re-run alone: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/transcribe-deepgram.ps1 -Project projects/<name>`.
   - **Don't use `npx hyperframes transcribe` with whisper or install it (too loud/slow); use Deepgram.**
   - Gives `projects/<name>/` with `clip.mp4` (CFR H.264), `audio.mp3`, `metadata.json`, `transcript.json`, `fonts/`, `sfx/`, `renders/`.
   - Add `-Screenshots "<folder>"` if the user supplies screenshots for a moment.
3. Work inside `projects/<name>/` from here on (`cd` there before any `npx hyperframes` command).

## 2. Really analyse the video
- Read `metadata.json` (width, height, fps = `r_frame_rate`, duration) and `transcript.json` (flat `[{text,start,end}]`).
- Fix obvious ASR mistakes in place, keep timestamps. Speech-to-text can be ~1 s off: when a moment matters, verify with
  `ffmpeg -ss <t-0.5> -t 2 -i clip.mp4 ...` or snapshots rather than trusting the number.
- Long or mixed-language transcripts: dump an indexed word list (`index:text@start`, one sentence per line) to `transcript-words.txt` and read that.

### Captions (when the user wants them)
- Write `captions-src.json`: `[[firstWordIndex, lastWordIndex, "caption text", ["key","words"]], ...]`, 3–7 words per chunk, covering every word.
  Urdu/Hindi/Hinglish speech → write the text in **Roman Hinglish** (e.g. "ke 9 maah guzar gaye hain"), keep English words as spoken, fix mishearings by context ("नौ मां" → 9 maah, "New York" → New Year).
- Build: `node tools/build-captions.mjs projects/<name>` → `captions.js` (`window.CAPTIONS = [{s,e,text,key}]`), warns about uncovered words. Load with `<script src="captions.js">`.
- Find where the face is: `npx hyperframes snapshot` is not available before a composition exists, so extract frames:
  `ffmpeg -nostdin -v error -ss <t> -i clip.mp4 -frames:v 1 renders/_probe_<t>.png` at 3–4 points and view them.
- Write a one-paragraph summary: what the video is about, and the 3–8 moments that matter (numbers, lists, before/after, key claim, CTA).
- Ask the user which style if they didn't say (see `mg-styles`). Default: clean white frosted cards (Liquid Glass).

## 3. Plan (show the user before building if the video is > 30 s or the brief is vague)
For each moment: trigger word + its exact `start`, graphic type, content, zone, exit time. Graphic type follows what is said:
- number → **count-up** · list → **checklist tick** · before/after → **comparison** · key line → **punch-in** or big type
- screenshots / proof → pop-ups in sequence (PROMPT 12) · new topic → **reframe** (video shrinks into a card)
Moves vocabulary and styles live in the `mg-styles` skill.

## 4. House rules (non-negotiable)
1. **Keep the video exactly as it is**: same size, fps, audio, cut. Composition `data-width/height` = video size, fps = video fps,
   root `data-duration` = video duration (clamp to `metadata.json`). Video is `<video id="a-roll" class="clip" src="clip.mp4" data-has-audio="true" data-start="0" ...>` with no `muted`, no `crossorigin`.
2. Every graphic **starts on the exact word** (`start` of that word in the transcript).
3. **One style** across the whole video.
4. **Nothing in the first 3 seconds** — that's the hook.
5. Keep graphics **off the face**, **out of the bottom third** (captions), and **inside the middle 80% of the width** (10% margin left/right).
6. Fonts only from the project's `fonts/` folder via `@font-face` (never Google Fonts URLs); GSAP via `<script src="vendor/gsap.min.js">`.
7. Frosted glass needs something behind it; over footage it works, for transparent export use solid cards.

## 5. Build, check, review
1. Write `index.html` (standalone composition, one paused GSAP timeline registered at `window.__timelines["<id>"]`). Paper Cut style: start from `kit/templates/paper-cut-vertical.html`.
   Low-res phone footage (e.g. 480x864 WhatsApp): still author on a 1080x1920 canvas so graphics/captions stay sharp; the video scales up underneath.
2. `npx hyperframes lint` then `npx hyperframes check` — fix every error.
3. `npx hyperframes snapshot --at <t1>,<t2>,...` at each graphic's mid-point and **view the PNGs** — check face/caption overlap and text clipping.
4. Render a draft: `npx hyperframes render . -o renders/with-cards.mp4` (renders are slow on typical PCs; use snapshots to iterate, render only when the frames look right).
5. Copy the approved final to `exports/<name>.mp4`.

## 6. Follow-ups (same session)
- **One spot** (PROMPT 12): "When I say <phrase>, show <thing>". Find the phrase in the transcript, change only that moment, keep everything else identical, re-render to the same file.
- **Sound**: use the `mg-sound` skill. **Export variants / transparent**: `mg-export` skill.
- Tweaks in plain words (surface, colour, type, motion, timing, layout) → edit only that, keep everything else the same, render again.

Base first, then one spot at a time. Don't try to get everything in one pass.
