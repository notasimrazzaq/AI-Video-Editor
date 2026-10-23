# AI video editor workspace

Motion-graphics video editing with HyperFrames (HTML + GSAP → MP4), based on Damiano Caudullo's
"Motion Graphics with Claude Code" kit. Windows, PowerShell 5.1. First-time setup: `tools/setup.ps1`.

## Layout
- `raw/` — user's raw footage. Never modify files here.
- `projects/<name>/` — one folder per video: `index.html`, `clip.mp4`, `transcript.json`, `fonts/`, `sfx/`, `vendor/`, `renders/`.
- `exports/` — final approved videos only.
- `kit/` — the original starter kit (fonts, sfx, practice clip, practice screenshots, `prompts.md`, the PDF, `guide-text.txt`). Read-only reference.
- `tools/new-project.ps1` — creates a project (copies fonts/sfx, normalises video, extracts audio; `-Transcribe` uses Deepgram via `tools/transcribe-deepgram.ps1`).
- `tools/build-captions.mjs` (captions-src.json → captions.js) · `tools/sfx.mjs` (sfx.json → audio tags, `--mix` onto a render) · `tools/make-paper-sfx.ps1` (regenerates paper sounds).
- `kit/templates/` — proven style templates (start here instead of building components again).
- Transcription is Deepgram only (key in user env var `DEEPGRAM_API_KEY`). Don't install Whisper or run heavy local AI models.

## Which skill
- Raw video → graphics on top, or "when I say X show Y": `mg-edit-video`
- Styles, moves, colour/font/timing tweaks: `mg-styles`
- Script / product / SaaS promo with no footage: `mg-from-scratch`
- Sound effects: `mg-sound`
- Render options, transparent export, "something looks wrong": `mg-export`
- Tool errors / setup: `mg-setup-check`
- HyperFrames technical contract: installed skills `hyperframes-core`, `hyperframes-animation`, `hyperframes-cli`.

## Always
- Run `npx hyperframes ...` from inside the project folder.
- Fonts only from the project's `fonts/` folder; GSAP from `vendor/gsap.min.js` (`<script src="vendor/gsap.min.js">`); no network assets.
- Lint and check before rendering; view snapshots before a full render (renders are slow on this PC).
- Base first, then change one moment at a time; when tweaking, keep everything else the same.
