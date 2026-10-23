# AI video editor workspace

Motion-graphics video editing with HyperFrames (HTML + GSAP → MP4), based on Damiano Caudullo's
"Motion Graphics with Claude Code" kit. Windows only (PowerShell 5.1+). These rules apply to every AI tool
(GitHub Copilot, Claude Code, Antigravity, Cursor, Codex, ...).

## First run (before any other step)
If the file `.setup-ok` does not exist in the repo root, set the machine up first, then continue with the user's request:
```
powershell -NoProfile -ExecutionPolicy Bypass -File tools/setup.ps1
```
- It installs Node.js 22+, FFmpeg, the HyperFrames skills and a render browser. It can take several minutes;
  Windows may show an admin (UAC) prompt for Node.js — tell the user to click **Yes**.
- If it ends with "restart your editor", tell the user to fully close and reopen the editor, then ask again.
- After setup, if `node`/`ffmpeg` are still "not found" in your terminal, refresh PATH (PowerShell):
  `$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')`
- On macOS/Linux: tell the user this system currently supports Windows only.
- The Deepgram key (transcription + AI voice) is only needed for footage with speech or for voiceovers. If
  `DEEPGRAM_API_KEY` is missing, ask the user to run `powershell -NoProfile -ExecutionPolicy Bypass -File tools/set-deepgram-key.ps1`
  in a terminal **themselves** (free key at console.deepgram.com). Never ask for, read or print the key in chat.

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
Project skills live in `.agents/skills/<name>/SKILL.md`. If your tool doesn't load them automatically, read the file yourself before starting the task.
- Raw video → graphics on top, or "when I say X show Y": `mg-edit-video`
- Styles, moves, colour/font/timing tweaks: `mg-styles`
- Script / product / SaaS promo with no footage: `mg-from-scratch`
- Sound effects: `mg-sound`
- Render options, transparent export, "something looks wrong": `mg-export`
- Tool errors / setup: `mg-setup-check`
- HyperFrames technical contract: skills `hyperframes-core`, `hyperframes-animation`, `hyperframes-cli`
  (installed globally by setup into `~/.agents/skills` and `~/.claude/skills`).

## Always
- Run `.ps1` scripts as `powershell -NoProfile -ExecutionPolicy Bypass -File tools/<script>.ps1 ...` with forward slashes,
  so they work from PowerShell, cmd and Git Bash alike.
- Use `npx --yes hyperframes ...` (without `--yes` it can stop on an "Ok to proceed?" prompt), run from inside the project folder.
- Always pass `-nostdin` to `ffmpeg` (otherwise it can swallow terminal input and abort).
- Fonts only from the project's `fonts/` folder; GSAP from `vendor/gsap.min.js` (`<script src="vendor/gsap.min.js">`); no network assets.
- Lint and check before rendering; view snapshots before a full render (renders are slow on typical PCs).
- Base first, then change one moment at a time; when tweaking, keep everything else the same.
