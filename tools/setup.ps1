<#
.SYNOPSIS
  One-time setup on a new Windows PC: Node.js 22+, FFmpeg, HyperFrames skills, Deepgram key.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\setup.ps1
#>
$ErrorActionPreference = "Stop"

function Update-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}

function Install-WithWinget($id) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget not found. Install '$id' manually, then run this script again."
    }
    winget install --id $id -e --accept-source-agreements --accept-package-agreements
    Update-Path
}

# Node.js 22+
$nodeOk = $false
if (Get-Command node -ErrorAction SilentlyContinue) {
    $major = [int]((node --version).TrimStart("v").Split(".")[0])
    $nodeOk = $major -ge 22
}
if (-not $nodeOk) {
    Write-Host "Installing Node.js LTS..."
    Install-WithWinget "OpenJS.NodeJS.LTS"
}
Write-Host "Node $(node --version)"

# FFmpeg
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "Installing FFmpeg..."
    Install-WithWinget "Gyan.FFmpeg"
}
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Warning "FFmpeg installed but not on PATH yet. Close and reopen VS Code, then run this script again."
} else {
    Write-Host "FFmpeg OK"
}

# HyperFrames skills (installed for all supported AI tools, incl. GitHub Copilot)
Write-Host "Installing HyperFrames skills..."
npx --yes hyperframes skills
npx --yes hyperframes telemetry disable

# Deepgram key (transcription + AI voice)
$key = [Environment]::GetEnvironmentVariable("DEEPGRAM_API_KEY", "User")
if (-not $key) {
    Write-Host ""
    Write-Host "Deepgram API key (free credit at https://console.deepgram.com). Press Enter to skip."
    $secure = Read-Host "DEEPGRAM_API_KEY" -AsSecureString
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
    if ($plain) {
        [Environment]::SetEnvironmentVariable("DEEPGRAM_API_KEY", $plain, "User")
        Write-Host "Saved DEEPGRAM_API_KEY to your user environment."
    }
} else {
    Write-Host "DEEPGRAM_API_KEY already set"
}

Write-Host ""
npx --yes hyperframes doctor
Write-Host ""
Write-Host "Setup done. Put a video in raw\ and ask Copilot: 'Edit raw\my-video.mp4'."
