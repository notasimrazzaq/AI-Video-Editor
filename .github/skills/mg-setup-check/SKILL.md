---
name: mg-setup-check
description: "Check or repair the video-editing toolchain on this Windows PC (Node 22+, FFmpeg, Deepgram key, Chrome, HyperFrames skills). Use when: transcription or rendering fails, a new PC needs setup, or the user asks to update HyperFrames."
---

# Setup check (Windows)

First-time install: `powershell -ExecutionPolicy Bypass -File tools\setup.ps1`.

Known-good setup:
| Tool | Where |
|---|---|
| Node.js 24 | `C:\Program Files\nodejs` |
| FFmpeg / FFprobe | winget (`Gyan.FFmpeg`) |
| Transcription | Deepgram API via `tools/transcribe-deepgram.ps1`, key in user env var `DEEPGRAM_API_KEY` |
| Chrome | system install, used for rendering |
| HyperFrames skills | `%USERPROFILE%\.agents\skills` (+ `.claude\skills`) |

Do not install whisper.cpp or run local transcription models (slow and loud on typical PCs).

## Check
```powershell
npx -y hyperframes doctor
```
Docker, Kokoro (TTS), MusicGen and whisper-cpp are not needed here — ignore them.

## Common fixes
- **Deepgram key**: the user sets it themselves (never paste it in chat):
  `[Environment]::SetEnvironmentVariable('DEEPGRAM_API_KEY','<key>','User')`. Scripts read the user-scope value even in old terminals.
- **Deepgram 401**: key wrong/expired — ask the user to set it again. **402/429**: out of credit / rate-limited.
- **Update skills / CLI**: `npx -y hyperframes skills update`, `npx -y hyperframes upgrade`.
- Anything needing admin rights: the VS Code terminal is elevated here; if not, give the user the exact command to run.
