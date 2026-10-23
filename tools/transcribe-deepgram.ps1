<#
.SYNOPSIS
  Transcribe a project's audio with Deepgram and write transcript.json ([{text,start,end}]) for HyperFrames.
  Key is read from the DEEPGRAM_API_KEY environment variable (process or user scope). Never pass it on the command line.

.EXAMPLE
  .\tools\transcribe-deepgram.ps1 -Project projects\my-reel
  .\tools\transcribe-deepgram.ps1 -Project projects\my-reel -Language en
#>
param(
    [Parameter(Mandatory = $true)][string]$Project,
    [string]$Language = "multi",
    [string]$Model = "nova-3"
)

$ErrorActionPreference = "Stop"
$key = $env:DEEPGRAM_API_KEY
if (-not $key) { $key = [Environment]::GetEnvironmentVariable("DEEPGRAM_API_KEY", "User") }
if (-not $key) { throw "DEEPGRAM_API_KEY is not set. Run: [Environment]::SetEnvironmentVariable('DEEPGRAM_API_KEY','<key>','User')" }

$proj = (Resolve-Path $Project).Path
$audio = Join-Path $proj "audio.mp3"
if (-not (Test-Path $audio)) { throw "No audio.mp3 in $proj (create the project with tools\new-project.ps1 -Video first)." }

$raw = Join-Path $proj "deepgram.json"
$url = "https://api.deepgram.com/v1/listen?model=$Model&language=$Language&smart_format=true&punctuate=true"
Write-Host "Uploading to Deepgram ($Model, $Language)..."
# key goes via a curl config on stdin so it never appears in the process list
"header = `"Authorization: Token $key`"" | curl.exe -s -S --fail-with-body -K - -X POST -H "Content-Type: audio/mpeg" --data-binary "@$audio" -o "$raw" "$url"
if ($LASTEXITCODE -ne 0) { throw "Deepgram request failed: $(Get-Content $raw -Raw -ErrorAction SilentlyContinue)" }

$resp = Get-Content $raw -Raw -Encoding UTF8 | ConvertFrom-Json
$words = $resp.results.channels[0].alternatives[0].words
if (-not $words) { throw "Deepgram returned no words. See $raw" }

$out = foreach ($w in $words) {
    $text = if ($w.punctuated_word) { $w.punctuated_word } else { $w.word }
    $o = [ordered]@{ text = $text; start = [math]::Round([double]$w.start, 3); end = [math]::Round([double]$w.end, 3) }
    if ($w.language) { $o.lang = $w.language }
    [pscustomobject]$o
}

$dest = Join-Path $proj "transcript.json"
if (Test-Path $dest) { Copy-Item $dest (Join-Path $proj "transcript.prev.json") -Force }
$json = ConvertTo-Json @($out) -Depth 3
[IO.File]::WriteAllText($dest, $json, (New-Object Text.UTF8Encoding $false))
Write-Host "Wrote $($out.Count) words to $dest (raw response: deepgram.json)"
