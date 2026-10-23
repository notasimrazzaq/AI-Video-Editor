<#
.SYNOPSIS
  Generate paper / stop-motion sound effects with FFmpeg (deterministic, no samples, no licences) into kit\sfx.
#>
$ErrorActionPreference = "Stop"
$out = Join-Path (Split-Path -Parent $PSScriptRoot) "kit\sfx"

$noise = { param($d, $color, $seed, $amp = 0.9) "anoisesrc=d=${d}:c=${color}:r=44100:a=${amp}:s=$seed" }

$sounds = [ordered]@{
    # swish of a turning page with a soft flap at the end
    "paper-flip" = "$(& $noise 0.5 pink 11),highpass=f=700,lowpass=f=7500,tremolo=f=17:d=0.6,afade=t=in:d=0.16:curve=qsin,afade=t=out:st=0.24:d=0.24:curve=exp[a];" +
                   "$(& $noise 0.07 white 12),highpass=f=1500,afade=t=out:d=0.07:curve=exp,adelay=330[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # card landing: crisp paper slap + small body
    "paper-drop" = "$(& $noise 0.16 white 21),highpass=f=1200,lowpass=f=9000,afade=t=out:d=0.14:curve=exp[a];" +
                   "aevalsrc='0.55*sin(2*PI*150*t)*exp(-38*t)':s=44100:d=0.16[b];[a][b]amix=inputs=2:normalize=0"
    # crinkly flutter for ransom-note letters
    "paper-rustle" = "$(& $noise 0.55 white 31),highpass=f=2200,lowpass=f=10000,tremolo=f=23:d=0.85,tremolo=f=37:d=0.6,afade=t=in:d=0.04,afade=t=out:st=0.2:d=0.35:curve=exp"
    # washi tape tear
    "tape-rip" = "$(& $noise 0.28 white 41),highpass=f=2600,tremolo=f=70:d=1,tremolo=f=11:d=0.5,afade=t=in:d=0.02,afade=t=out:st=0.12:d=0.16:curve=exp"
    # one marker tick (check mark: short down-stroke, longer up-stroke)
    "marker-tick" = "$(& $noise 0.07 white 51),bandpass=f=3200:width_type=h:w=2600,afade=t=out:d=0.07[a];" +
                    "$(& $noise 0.14 white 52),bandpass=f=3800:width_type=h:w=2800,afade=t=in:d=0.03,afade=t=out:st=0.05:d=0.09,adelay=80[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # ~9 quick marker strokes (calendar crosses)
    "marker-scribble" = "$(& $noise 0.85 white 61),bandpass=f=3300:width_type=h:w=2600,tremolo=f=11:d=1,afade=t=in:d=0.02,afade=t=out:st=0.7:d=0.15"
    # rubber stamp / slap-down thump
    "stamp" = "aevalsrc='0.9*sin(2*PI*85*t)*exp(-20*t)+0.35*sin(2*PI*170*t)*exp(-28*t)':s=44100:d=0.3[a];" +
              "$(& $noise 0.04 white 71),highpass=f=1500,afade=t=out:d=0.04:curve=exp[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # card sliding across paper
    "paper-slide" = "$(& $noise 0.36 pink 81),highpass=f=300,lowpass=f=2800,afade=t=in:d=0.14:curve=qsin,afade=t=out:st=0.16:d=0.2"
    # deep hit for punch-in
    "thump" = "aevalsrc='0.95*sin(2*PI*(55+70*exp(-30*t))*t)*exp(-9*t)':s=44100:d=0.45"
}

foreach ($name in $sounds.Keys) {
    $tmp = Join-Path $env:TEMP "$name.raw.wav"
    $dest = Join-Path $out "$name.wav"
    # headroom first: volumedetect clamps at 0 dB, so hot float peaks would be under-measured
    ffmpeg -v error -y -filter_complex "$($sounds[$name]),volume=-12dB" -ac 1 -c:a pcm_f32le $tmp
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed for $name" }
    $max = (cmd /c "ffmpeg -hide_banner -i `"$tmp`" -af volumedetect -f null NUL 2>&1" | Select-String "max_volume: (-?[\d.]+)").Matches[0].Groups[1].Value
    $gain = -1 - [double]$max
    ffmpeg -v error -y -i $tmp -af "volume=${gain}dB" -c:a pcm_s16le $dest
    Remove-Item $tmp
    Write-Host ("{0,-16} peak {1,6} dB -> -1 dB" -f $name, $max)
}
