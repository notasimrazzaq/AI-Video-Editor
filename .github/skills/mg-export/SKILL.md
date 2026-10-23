---
name: mg-export
description: "Render and export HyperFrames videos: frame rate, 4K, ProRes MOV, PNG sequence, smaller files (--crf), transparent overlays for Premiere/After Effects (PROMPT 14), plus quick fixes when something looks wrong (fonts, cropping, captions overlap, timing, huge files). Use when: the user asks to render, export, change resolution/fps, make it transparent, reduce size, or says something looks off."
---

# Render, export, fix

Run from inside `projects/<name>/`. Final approved files also get copied to `exports/` at the workspace root.

## Cheat sheet
```powershell
npx hyperframes render . -o renders/video.mp4                         # default
npx hyperframes render . --fps 60 -o renders/video-60fps.mp4
npx hyperframes render . --resolution 4k -o renders/video-4k.mp4       # aspect must match; portrait → portrait-4k
npx hyperframes render . --resolution 4k --fps 120 -o renders/video-4k-120.mp4
npx hyperframes render . --fps 24 -o renders/video-24fps.mp4
npx hyperframes render . --format mov -o renders/video.mov             # ProRes
npx hyperframes render . --format png-sequence -o renders/frames
npx hyperframes render . --crf 23 -o renders/smaller.mp4               # smaller file
```
- When graphics sit on the user's footage, keep the footage fps unless the user asks otherwise.
- This PC is a 4-core i3 with ~12 GB RAM. Measured: 6 s of simple 1080p graphics ≈ 24 s; **3:20 of 1080x1920 footage + Paper Cut ≈ 1.5 h** (~1.1 fps: `filter: drop-shadow` forces screenshot capture, and fast capture only works on macOS anyway). Warn the user before long renders and render once at the end.
- Speed levers: `--workers 3` (each Chrome ~256 MB; default `auto` picked 1 here — test on a short clip first), `--quality draft` for review renders, or a shorter clip. If a render runs out of memory or times out, add `--low-memory-mode` and/or `--protocol-timeout 600000`.
- Audio-only changes never need a re-render: `node tools/sfx.mjs projects/<n> --mix in.mp4 out.mp4` (video stream copied).
- Iterate with `npx hyperframes snapshot` (fast) and render only when frames look right.

## Transparent export (PROMPT 14)
MOV/PNG are only transparent if the background is transparent.
1. Remove the background and any footage so only the card(s) remain; everything around them transparent.
2. Frosted cards lose their blur with nothing behind them → switch to **solid** cards for overlays.
3. Export `renders/card.mov` (ProRes 4444 with alpha, `--format mov`) and a PNG sequence in `renders/card-png` (`--format png-sequence`).
4. Snapshot over a checkerboard to verify only the card is visible. (`--format webm` is another transparent option.)

## When something looks wrong
| Symptom | Fix |
|---|---|
| Wrong font / plain fallback | Use the file in `fonts/` via `@font-face`; never a web font URL. `lint` flags `font_family_without_font_face`. |
| Text cut off on phones | Keep all text inside the middle 80% of the width. |
| A card covers the captions | Move every card above the bottom third. |
| A card is a bit early / late | Speech-to-text can be ~1 s off. Re-time to the exact spoken word (check audio around it). |
| File is huge | Render again with `--crf 23` (grain styles especially). |
| Silent render | Every `<audio>` needs an `id`; the `<video>` must not be `muted` and needs `data-has-audio="true"`. |
If the user describes the problem in plain words, translate it to one of these or to a knob in `mg-styles`.
