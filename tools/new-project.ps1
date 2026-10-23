<#
.SYNOPSIS
  Create a new motion-graphics project folder under projects/ with the kit's fonts and sfx.

.EXAMPLE
  .\tools\new-project.ps1 -Name "my-reel" -Video "raw\my-reel.mov" -Transcribe   # Deepgram, needs DEEPGRAM_API_KEY
  .\tools\new-project.ps1 -Name "launch" -Screenshots saas
  .\tools\new-project.ps1 -Name "promo" -Screenshots "C:\shots\myapp"
#>
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$Video,
    [string]$Screenshots,
    [switch]$Transcribe,
    [string]$Language = "multi"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$kit = Join-Path $root "kit"

$slug = ($Name.ToLower() -replace "[^a-z0-9]+", "-").Trim("-")
if (-not $slug) { throw "Name must contain letters or numbers." }
$proj = Join-Path $root "projects\$slug"
if (Test-Path $proj) { throw "Project already exists: $proj" }

New-Item -ItemType Directory -Force $proj, (Join-Path $proj "renders") | Out-Null
Copy-Item (Join-Path $kit "fonts") (Join-Path $proj "fonts") -Recurse
Copy-Item (Join-Path $kit "sfx") (Join-Path $proj "sfx") -Recurse
Copy-Item (Join-Path $kit "vendor") (Join-Path $proj "vendor") -Recurse

if ($Screenshots) {
    $src = if ($Screenshots -in @("saas", "sales")) { Join-Path $kit "practice-screenshots\$Screenshots" } else { $Screenshots }
    if (-not (Test-Path $src)) { throw "Screenshots folder not found: $src" }
    New-Item -ItemType Directory -Force (Join-Path $proj "screenshots") | Out-Null
    Copy-Item (Join-Path $src "*") (Join-Path $proj "screenshots")
}

if ($Video) {
    $videoPath = if ($Video -eq "practice") { Join-Path $kit "clip.mp4" } else { (Resolve-Path $Video).Path }
    $clip = Join-Path $proj "clip.mp4"

    $probe = ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,r_frame_rate,avg_frame_rate -of csv=p=0 "$videoPath"
    $parts = "$probe".Split(",")
    $isH264Mp4 = ([IO.Path]::GetExtension($videoPath) -eq ".mp4") -and ($parts[0] -eq "h264")
    $isCfr = ($parts.Count -ge 3) -and ($parts[1] -eq $parts[2])

    if ($isH264Mp4 -and $isCfr) {
        Copy-Item $videoPath $clip
    } else {
        Write-Host "Converting to constant-frame-rate H.264 MP4 (phone footage is often variable frame rate)..."
        $fps = $parts[1]
        ffmpeg -v error -stats -y -i "$videoPath" -c:v libx264 -crf 16 -preset medium -pix_fmt yuv420p -r $fps -c:a aac -b:a 192k -movflags +faststart "$clip"
        if ($LASTEXITCODE -ne 0) { throw "ffmpeg conversion failed." }
    }

    $meta = ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -show_entries format=duration -of json "$clip"
    [IO.File]::WriteAllText((Join-Path $proj "metadata.json"), ($meta -join "`n"), (New-Object Text.UTF8Encoding $false))
    ffmpeg -v error -y -i "$clip" -vn -acodec libmp3lame -q:a 2 (Join-Path $proj "audio.mp3")

    if ($Transcribe) {
        & (Join-Path $PSScriptRoot "transcribe-deepgram.ps1") -Project $proj -Language $Language
    }
}

Write-Host ""
Write-Host "Project ready: $proj"
Get-ChildItem $proj | ForEach-Object { Write-Host ("  " + $_.Name) }
