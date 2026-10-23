<#
.SYNOPSIS
  One-time, unattended setup on a Windows PC: Node.js 22+, FFmpeg, HyperFrames skills, render browser.
  Safe to re-run. Writes .setup-ok in the repo root when everything works.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/setup.ps1
#>
# Not "Stop": npm/winget write progress to stderr, which PowerShell 5.1 would treat as fatal.
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$marker = Join-Path $root ".setup-ok"
Remove-Item $marker -ErrorAction SilentlyContinue

function Update-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}

function Test-Cmd($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }

function Fail($msg) {
    Write-Host ""
    Write-Host "SETUP FAILED: $msg" -ForegroundColor Red
    exit 1
}

function Install-WithWinget($id, $name, $url) {
    if (-not (Test-Cmd winget)) {
        Fail "winget is missing. Install 'App Installer' from the Microsoft Store, or install $name from $url, then run setup again."
    }
    Write-Host "Installing $name (winget $id)..."
    winget install --id $id -e --silent --accept-source-agreements --accept-package-agreements
    # Non-zero when already installed: try an upgrade instead.
    if ($LASTEXITCODE -ne 0) {
        winget upgrade --id $id -e --silent --accept-source-agreements --accept-package-agreements
    }
    Update-Path
}

function Get-NodeMajor {
    if (-not (Test-Cmd node)) { return 0 }
    return [int]((node --version).TrimStart("v").Split(".")[0])
}

Update-Path

# 1. Node.js 22+
if ((Get-NodeMajor) -lt 22) {
    Install-WithWinget "OpenJS.NodeJS.LTS" "Node.js LTS" "https://nodejs.org"
}
if ((Get-NodeMajor) -lt 22) {
    Fail "Node.js 22+ is not available. Install the LTS from https://nodejs.org, restart your editor, then run setup again."
}
Write-Host "Node.js $(node --version) OK"

# 2. FFmpeg + FFprobe
if (-not ((Test-Cmd ffmpeg) -and (Test-Cmd ffprobe))) {
    Install-WithWinget "Gyan.FFmpeg" "FFmpeg" "https://www.gyan.dev/ffmpeg/builds/"
}
if (-not ((Test-Cmd ffmpeg) -and (Test-Cmd ffprobe))) {
    Fail "FFmpeg was installed but is not on PATH yet. Fully close and reopen your editor, then run setup again."
}
Write-Host "FFmpeg OK"

# 3. HyperFrames skills for every supported AI tool (Copilot, Claude Code, Codex, ...)
Write-Host "Installing HyperFrames skills..."
$null | npx --yes hyperframes skills
if ($LASTEXITCODE -ne 0) { Fail "Installing HyperFrames skills failed (check your internet connection)." }
npx --yes hyperframes telemetry disable | Out-Null

# 4. Chrome for rendering (downloads a private copy if none is found)
Write-Host "Checking the render browser..."
npx --yes hyperframes browser ensure
if ($LASTEXITCODE -ne 0) { Fail "Could not find or download Chrome for rendering. Install Google Chrome, then run setup again." }

[IO.File]::WriteAllText($marker, (Get-Date -Format s))

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
if (-not [Environment]::GetEnvironmentVariable("DEEPGRAM_API_KEY", "User")) {
    Write-Host "Optional: for transcription and AI voiceover, add a free Deepgram key by running this yourself:"
    Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File tools/set-deepgram-key.ps1"
}
Write-Host "Put a video in raw\ and ask your AI assistant: 'Edit raw\my-video.mp4'."
