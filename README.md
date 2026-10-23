# AI video editor

Motion-graphics video editing with an AI coding agent + [HyperFrames](https://github.com/heygen-com/hyperframes), set up from Damiano's "Motion Graphics with Claude Code" kit.
Works with **GitHub Copilot (VS Code), Claude Code, Google Antigravity, Cursor, Codex** and other agents that read `AGENTS.md`.

## Get started (Windows 10/11)
1. Download the repo: **Code → Download ZIP** (then extract), or
   ```
   git clone https://github.com/notasimrazzaq/AI-Video-Editor.git
   ```
2. Open the folder in your AI editor (VS Code + Copilot agent mode, Claude Code, Antigravity, ...).
3. Ask for what you want, e.g. **"Edit raw/my-reel.mp4 in Liquid Glass style"**.

On the first request the agent runs `tools/setup.ps1` by itself. It installs Node.js, FFmpeg, the HyperFrames skills
and a render browser (click **Yes** if Windows asks for permission). After that it is ready every time.

**Optional, for speech transcription and AI voiceover:** get a free key at [console.deepgram.com](https://console.deepgram.com) and run this in a terminal yourself (never paste keys into the AI chat):
```
powershell -NoProfile -ExecutionPolicy Bypass -File tools/set-deepgram-key.ps1
```

Manual setup (same thing the agent does): `powershell -NoProfile -ExecutionPolicy Bypass -File tools/setup.ps1`

## How to use
1. Put your raw video in `raw/`.
2. In your AI chat, say e.g. **"Edit raw/my-reel.mp4 in Liquid Glass style"** (or just "edit raw/my-reel.mp4").
3. Review the snapshots/draft, then ask for changes in plain words, one at a time:
   - "When I say *40 a week*, show the screenshots in my-folder popping up."
   - "Make the cards bouncier." / "Use my brand colours #111111 and #ff5a1f."
   - "Add sound effects." / "Export a 4K version." / "Make a transparent version for Premiere."
4. Finished videos land in `exports/`.

No footage? Give a script, a product description, or app screenshots and ask for a text video, product video or SaaS promo.

## Styles
Kinetic Type · Liquid Glass (default) · Editorial Grain · Pop Bold · Paper Cut (ready-made template) — details in `.agents/skills/mg-styles/SKILL.md`.

## Folders
| Folder | What |
|---|---|
| `raw/` | your original footage (never changed) |
| `projects/` | one working folder per video (created by `tools/new-project.ps1`; not committed) |
| `exports/` | final videos |
| `kit/` | the original starter kit, PDF, `prompts.md`, plus `templates/` (Paper Cut) and the paper sound effects in `sfx/` |
| `tools/` | `setup.ps1` (first-time install), `set-deepgram-key.ps1`, `new-project.ps1` (project + Deepgram transcript), `build-captions.mjs`, `sfx.mjs`, `make-paper-sfx.ps1` |
| `AGENTS.md` | rules every AI agent follows (`CLAUDE.md` imports it for Claude Code) |
| `.agents/skills/` | agent skills: `mg-edit-video`, `mg-styles`, `mg-from-scratch`, `mg-sound`, `mg-export`, `mg-setup-check` |
