<#
.SYNOPSIS
  Generate crisp UI / glass sound effects with FFmpeg (deterministic, no samples, no licences) into kit\sfx.
.EXAMPLE
  .\tools\make-crisp-sfx.ps1 -Project projects\my-reel   # also copies them into that project's sfx\
#>
param([string]$Project)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root "kit\sfx"

$noise = { param($d, $seed, $hp) "anoisesrc=d=${d}:c=white:r=44100:a=0.9:s=$seed,highpass=f=$hp,afade=t=out:d=${d}:curve=exp" }
$tone = { param($expr, $d) "aevalsrc='$expr':s=44100:d=$d" }

$sounds = [ordered]@{
    # card / panel landing: bright two-partial click + air transient
    "crisp-click"  = "$(& $tone '0.8*sin(2*PI*2400*t)*exp(-140*t)+0.4*sin(2*PI*5200*t)*exp(-220*t)' 0.06)[a];$(& $noise 0.012 1 4000)[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # chip / pill: rising bubble pop
    "crisp-pop"    = "$(& $tone '0.9*sin(2*PI*(500*t+5000*t*t))*exp(-45*t)' 0.09)[a];$(& $noise 0.006 2 5000)[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # list row / small reveal
    "crisp-tick"   = "$(& $tone '0.9*sin(2*PI*3600*t)*exp(-260*t)' 0.03)[a];$(& $noise 0.006 3 6000)[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # liquid-glass tile: glassy inharmonic ping
    "glass-tap"    = "$(& $tone '0.5*sin(2*PI*1568*t)*exp(-9*t)+0.35*sin(2*PI*2349*t)*exp(-12*t)+0.25*sin(2*PI*3951*t)*exp(-18*t)+0.15*sin(2*PI*5274*t)*exp(-30*t)' 0.55)[a];$(& $noise 0.004 4 5000)[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # typing: 8 key clicks
    "type-burst"   = "$(& $tone '0.8*sin(2*PI*3000*t)*exp(-200*mod(t,0.075))*lt(t,0.6)+0.3*sin(2*PI*5100*t)*exp(-400*mod(t,0.075))*lt(t,0.6)' 0.62)"
    # number roll: fast ticks that ease off
    "count-roll"   = "$(& $tone '0.7*sin(2*PI*2800*t)*exp(-260*mod(t,0.05))*(1-0.6*t)' 1.0),afade=t=out:st=0.8:d=0.2"
    # reframe / scene change: short airy whoosh
    "whoosh"       = "anoisesrc=d=0.42:c=pink:r=44100:a=0.9:s=5,highpass=f=1200,lowpass=f=8000,afade=t=in:d=0.18:curve=qsin,afade=t=out:st=0.2:d=0.22:curve=qsin"
    # punch-in: tight sub hit with a snap on top
    "hit"          = "$(& $tone '0.95*sin(2*PI*(50+90*exp(-35*t))*t)*exp(-11*t)' 0.35)[a];$(& $noise 0.03 6 2500)[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # success / end card: two-note bell
    "ding"         = "$(& $tone '0.5*sin(2*PI*1319*t)*exp(-6*t)+0.2*sin(2*PI*2638*t)*exp(-9*t)' 0.9)[a];$(& $tone '0.5*sin(2*PI*1976*t)*exp(-6*t)+0.2*sin(2*PI*3952*t)*exp(-9*t)' 0.8),adelay=120[b];[a][b]amix=inputs=2:normalize=0:duration=longest"
    # limit reached: two falling blips
    "alert"        = "$(& $tone '0.7*sin(2*PI*880*t)*exp(-30*t)*lt(t,0.08)+0.7*sin(2*PI*620*t)*exp(-30*(t-0.1))*gte(t,0.1)' 0.3)"
    # toggle / model switch: two rising clicks
    "switch-on"    = "$(& $tone '0.8*sin(2*PI*1800*t)*exp(-180*t)+0.8*sin(2*PI*2700*t)*exp(-180*(t-0.07))*gte(t,0.07)' 0.15)"
    # send button: quick up-sweep
    "send"         = "$(& $tone 'sin(2*PI*(800*t+6000*t*t))*exp(-20*t)' 0.18)"
    # stars / highlight: three-note sparkle
    "sparkle"      = "$(& $tone '0.4*sin(2*PI*2637*t)*exp(-10*t)+0.3*sin(2*PI*3520*t)*exp(-12*(t-0.05))*gte(t,0.05)+0.25*sin(2*PI*4699*t)*exp(-14*(t-0.1))*gte(t,0.1)' 0.5)"
}

foreach ($name in $sounds.Keys) {
    $tmp = Join-Path $env:TEMP "$name.raw.wav"
    $dest = Join-Path $out "$name.wav"
    ffmpeg -nostdin -v error -y -filter_complex "$($sounds[$name]),volume=-12dB" -ac 1 -c:a pcm_f32le $tmp
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed for $name" }
    $max = (cmd /c "ffmpeg -nostdin -hide_banner -i `"$tmp`" -af volumedetect -f null NUL 2>&1" | Select-String "max_volume: (-?[\d.]+)").Matches[0].Groups[1].Value
    $gain = -1 - [double]$max
    ffmpeg -nostdin -v error -y -i $tmp -af "volume=${gain}dB" -c:a pcm_s16le $dest
    Remove-Item $tmp
    if ($Project) { Copy-Item $dest (Join-Path $root "$Project\sfx\$name.wav") }
    Write-Host ("{0,-12} peak {1,6} dB -> -1 dB" -f $name, $max)
}
