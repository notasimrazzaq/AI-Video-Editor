<#
.SYNOPSIS
  Save your Deepgram API key to your Windows user environment (run this yourself; never paste the key into an AI chat).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/set-deepgram-key.ps1
#>
Write-Host "Get a free key at https://console.deepgram.com (API Keys -> Create a New API Key)."
$secure = Read-Host "Paste your Deepgram API key" -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
    $key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr).Trim()
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}
if (-not $key) { Write-Host "No key entered; nothing changed."; exit 1 }
[Environment]::SetEnvironmentVariable("DEEPGRAM_API_KEY", $key, "User")
Write-Host "Saved. The video tools will pick it up straight away."
