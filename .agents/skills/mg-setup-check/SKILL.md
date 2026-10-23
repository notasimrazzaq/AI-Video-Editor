---
name: mg-setup-check
description: "Check or repair the video-editing toolchain on this Windows PC (Node 22+, FFmpeg, Deepgram key, Chrome, HyperFrames skills). Use when: transcription or rendering fails, a new PC needs setup, .setup-ok is missing, or the user asks to update HyperFrames."
---

# Setup check (Windows)

Install or repair everything (unattended, safe to re-run, writes `.setup-ok` on success):
```
powershell -NoProfile -ExecutionPolicy Bypass -File tools/setup.ps1
```
It prints `SETUP FAILED: <reason>` with the fix when something can't be done automatically.

Known-good setup:
| Tool | Where |
|---|---|
| Node.js 22+ | winget `OpenJS.NodeJS.LTS` → `C:\Program Files\nodejs` |
| FFmpeg / FFprobe | winget `Gyan.FFmpeg` |
| Transcription / AI voice | Deepgram API via `tools/transcribe-deepgram.ps1`, key in user env var `DEEPGRAM_API_KEY` |
| Chrome | system install, or a private copy from `npx --yes hyperframes browser ensure` |
| HyperFrames skills | `%USERPROFILE%\.agents\skills` (+ `.claude\skills`) |

Do not install whisper.cpp or run local transcription models (slow and loud on typical PCs).

## Check
```powershell
npx -y hyperframes doctor
```
Docker, Kokoro (TTS), MusicGen and whisper-cpp are not needed here — ignore them.

## Common fixes
- **Deepgram key**: the user runs `powershell -NoProfile -ExecutionPolicy Bypass -File tools/set-deepgram-key.ps1` themselves (never paste it in chat). Scripts read the user-scope value even in old terminals.
- **`node` / `ffmpeg` not found right after setup**: refresh PATH in the terminal
  (`$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')`) or restart the editor.
- **"running scripts is disabled"**: always call scripts via `powershell -NoProfile -ExecutionPolicy Bypass -File ...`.
- **Deepgram 401**: key wrong/expired — ask the user to set it again. **402/429**: out of credit / rate-limited.
- **Update skills / CLI**: `npx -y hyperframes skills update`, `npx -y hyperframes upgrade`.
- Anything needing admin rights: give the user the exact command to run in an admin terminal.
