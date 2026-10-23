# AI video editor

Motion-graphics editing with GitHub Copilot + HyperFrames, set up from Damiano's "Motion Graphics with Claude Code" kit.

## Install (Windows)
Needs: Windows 10/11, [VS Code](https://code.visualstudio.com) with GitHub Copilot (agent mode), Google Chrome.

```powershell
git clone https://github.com/notasimrazzaq/AI-Video-Editor.git
cd AI-Video-Editor
powershell -ExecutionPolicy Bypass -File tools\setup.ps1
```
`setup.ps1` installs Node.js 22+ and FFmpeg (via winget), installs the HyperFrames skills, and asks for your [Deepgram](https://console.deepgram.com) API key (used for transcription and AI voice; stored only in your user environment).

Then open the folder in VS Code and chat with Copilot in agent mode.

## How to use
1. Put your raw video in `raw/`.
2. In Copilot chat, say e.g. **"Edit raw/my-reel.mp4 in Liquid Glass style"** (or just "edit raw/my-reel.mp4").
3. Review the snapshots/draft, then ask for changes in plain words, one at a time:
   - "When I say *40 a week*, show the screenshots in my-folder popping up."
   - "Make the cards bouncier." / "Use my brand colours #111111 and #ff5a1f."
   - "Add sound effects." / "Export a 4K version." / "Make a transparent version for Premiere."
4. Finished videos land in `exports/`.

No footage? Give a script, a product description, or app screenshots and ask for a text video, product video or SaaS promo.

## Styles
Kinetic Type · Liquid Glass (default) · Editorial Grain · Pop Bold · Paper Cut (ready-made template) — details in `.github/skills/mg-styles/SKILL.md`.

## Folders
| Folder | What |
|---|---|
| `raw/` | your original footage (never changed) |
| `projects/` | one working folder per video (created by `tools/new-project.ps1`; not committed) |
| `exports/` | final videos |
| `kit/` | the original starter kit, PDF, `prompts.md`, plus `templates/` (Paper Cut) and the paper sound effects in `sfx/` |
| `tools/` | `setup.ps1` (first-time install), `new-project.ps1` (project + Deepgram transcript), `build-captions.mjs`, `sfx.mjs`, `make-paper-sfx.ps1` |
| `.github/skills/` | Copilot skills: `mg-edit-video`, `mg-styles`, `mg-from-scratch`, `mg-sound`, `mg-export`, `mg-setup-check` |
