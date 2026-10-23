---
name: mg-from-scratch
description: "Make a motion-graphics video with no footage: text-only / script video, product launch video, SaaS promo from screenshots, a first test render, or the 10-moves demo (kit PROMPTS 02, 03, 08, 09, 10). Use when: the user gives a script, a product description, app screenshots or a brief and wants an animated video made from nothing."
argument-hint: "Type (text | product | saas | demo), the script/product, optional style"
---

# Videos from scratch

Mechanics: load `hyperframes-core` + `hyperframes-animation`. Upstream routes that also fit: `faceless-explainer` (text),
`product-launch-video` (product/SaaS). This skill's briefs and rules win on conflict.

## Setup
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/new-project.ps1 -Name "<name>"                      # text / product
powershell -NoProfile -ExecutionPolicy Bypass -File tools/new-project.ps1 -Name "<name>" -Screenshots "<dir>"  # SaaS promo
```
Product photo → copy it to `projects/<name>/product.png`. Then work in `projects/<name>/`.
Style: ask if not given, then apply the block from `mg-styles`. Without a style: clean white frosted cards on a soft light gradient, Inter.

## Briefs (fill in the user's details; ask for real numbers, otherwise mark invented ones as examples)

**Text-only (PROMPT 08)** · default 1080x1920, 30 fps
Use the user's exact words, never rewrite or shorten. One sentence per screen, big enough for a phone; wrap long sentences over 2–3 lines on the same screen. Each screen stays up long enough to read (~0.35 s per word, min 1.2 s). All text inside the middle 80% of the width. → `renders/text.mp4`

**Product launch (PROMPT 09)** · default 1920x1080, 30 fps, ~12 s
If `product.png` exists use it as the hero, else build the product in HTML/CSS (app screen, logo, or phone).
0–2 s logo/name reveal → 2–9 s three feature moments, each *showing the product doing the thing*, not just a sentence → 9–12 s end card: name, one short line, CTA. → `renders/product.mp4`

**SaaS promo (PROMPT 10)** · default 1920x1080, 30 fps, ~60 s
1. Look at every screenshot first (view the images) and write what each shows.
2. Open with a short hook, then each screen with a zoom into the part that matters (number, chart, button) and one short line saying what it does for the customer.
3. Use the screenshots as they are — never redraw them.
4. Kinetic feel: fast zooms and pans, big bold words between screens, cuts on a steady beat.
5. End on logo, one short line, CTA. → `renders/promo.mp4`

**First render / smoke test (PROMPT 02)** · 1920x1080, 30 fps, 6 s
Frosted card on purple→blue gradient: grey label MY FIRST RENDER, number counts 0→100 over 2 s, green pill pops at 4 s. → `renders/first.mp4`

**Moves demo (PROMPT 03)** · 1080x1920, 30 fps, 14 s
The 10 moves from `mg-styles`, ~1.3 s each, white card on dark background, move name small above. → `renders/moves.mp4`

## Finish
`npx hyperframes lint` → `npx hyperframes check` → snapshots at key moments (view them) → render → copy approved file to `exports/`.
Sound: `mg-sound`. Variants / transparent: `mg-export`.
