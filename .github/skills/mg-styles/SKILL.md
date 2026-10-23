---
name: mg-styles
description: "Style library and animation vocabulary for motion-graphics videos: the 4 kit styles (Kinetic Type, Liquid Glass, Editorial Grain, Pop Bold), the 10 named moves (rise, pop, count-up, checklist tick, typewriter, slide-in, blur-in, punch-in, reframe, bar fill) and the 'change anything' knobs. Use when: picking or applying a look/style, the user names a style or move, or asks to change colour, font, surface, motion, timing or layout of a video."
---

# Styles, moves and knobs

Fonts are in each project's `fonts/` folder (copied from `kit/fonts/`). Load them with `@font-face` using those relative paths.
Apply exactly one style per video. If the user gives brand colours/fonts, keep the style's motion and structure and swap the palette/type.

## Which style when
| Style | Best for |
|---|---|
| Kinetic Type | hooks, short punchy scripts, text-only videos, SaaS promos |
| Liquid Glass (default) | talking-head reels, product, calm premium "Apple" look |
| Editorial Grain | stories, opinions, personal essays |
| Pop Bold | scroll-stoppers, playful / loud brands |
| Paper Cut | talking-head reels with a warm handmade feel, storytelling, advice, desi/Hinglish content |

## STYLE: Kinetic Type
- The text is the whole video. No cards, no boxes.
- Font: Archivo Black (`fonts/ArchivoBlack-400.woff2`), all caps, huge. The main word fills most of the width.
- Colours: black background, white text, one accent colour `#c6ff3d` for the most important word on each screen.
- Motion: words slam in one by one, fast and snappy (`power4.out`, 0.25–0.4 s). Mix the moves: slide in from the side, stretch from squashed to full height, split the letters apart and back together. Each screen exits fast before the next one hits.
- Cut the screens on the rhythm of the words, like a beat.
- Over footage: drop the black background; keep text in the safe zone with a subtle dark shadow for legibility.

## STYLE: Liquid Glass
- Frosted glass cards: white at ~80% opacity, 30px `backdrop-filter` blur, thin white border, 32px radius, soft shadow.
- Background (no footage): soft light gradient with 2–3 blurred colour blobs (pale blue, lilac, peach) drifting slowly.
- Font: Inter (`fonts/Inter-700.woff2` headings, `fonts/Inter-400.woff2` small text). Text `#1d1d1f`, small uppercase grey labels above headings.
- Accent: green `#34c759`, only for ticks and checks.
- Motion: calm and smooth. Cards rise 30px and fade in with `power3.out` over 0.6 s, scaling from 0.96. Text arrives piece by piece. Nothing bounces.

## STYLE: Editorial Grain
- Looks like a printed magazine page, not a screen.
- Background: warm paper `#efe8dc` with visible film grain over everything (animated SVG noise ~12% opacity, seeded/deterministic).
- Font: Instrument Serif (`fonts/InstrumentSerif-400.woff2`, `fonts/InstrumentSerif-400-italic.woff2`) for large headlines mixing upright and italic words. Small labels in Inter (`fonts/Inter-400.woff2`), uppercase, letter-spaced.
- Colours: ink `#1a1a1a`, one deep red accent `#c2412d`.
- Shapes: cut-out paper rectangles behind key words rotated 1–3°, thin rules, small page numbers in the corners.
- Motion: unhurried and a bit imperfect. Uneven staggers, gentle slides and wipes, no bounces.
- Grain makes big files → render with `--crf 23`.

## STYLE: Pop Bold
- Loud, playful, flat colour. No gradients, no glass.
- Font: Bricolage Grotesque ExtraBold (`fonts/BricolageGrotesque-800.woff2`), big and chunky.
- Colours: flat blocks of `#c6ff3d` lime, `#8a3cff` purple, `#ff4fd8` pink, `#111111`, with 4px black outlines and hard 8px offset shadows (no blur).
- Extras: rotating star and circle stickers, little arrows, simple CSS shapes.
- Motion: bouncy and springy. Pop in with `back.out(2.5)`, overshoot, small wobble, squash and stretch. Stickers spin slowly the whole time (finite repeat within root duration).

Other fonts available: Space Grotesk 500/700, JetBrains Mono 400 (code, numbers).

## STYLE: Paper Cut (stop-motion paper craft)
- Everything is cut paper laid on the video: cream chips `#f6edd8`, kraft `#c9a36b`, ink `#2b241b`, accent red `#e8442e`, mustard `#f2b53a`.
- Torn edges: seeded jagged `clip-path: polygon(...)` generated once in JS (deterministic PRNG, never `Math.random`). Paper grain from a static SVG `feTurbulence` data-URI at low opacity.
- Depth: every piece gets a hard paper shadow (`0 6px 0 rgba(0,0,0,.28)`) plus a soft one; washi-tape strips (semi-transparent, striped) pin cards at corners; small rotations (-4° to 4°).
- Fonts: Anton (`fonts/Anton-400.woff2`) for headline chips, Caveat (`fonts/Caveat-700.woff2`) for handwritten notes/arrows, Special Elite (`fonts/SpecialElite-400.woff2`) for typed labels, Permanent Marker for scribbles. Ransom-note words: each letter on its own chip with varied colour/rotation.
- Motion: stop-motion at ~12 fps. Use `ease: "steps(n)"` for entrances (paper drops from above / slides in, lands slightly crooked), slap-down (scale 1.15 → 1 in 3 steps), and a gentle "boil" on held pieces (rotation/offset nudges every 1/8 s from a seeded table). Exits: pieces get pulled off-frame in 2–3 steps.
- Captions: one torn cream strip in the lower area; words placed one by one; key word on a red chip.
- Big moments: reframe the footage into a taped paper photo on a kraft table, with the graphic beside it.
- Fonts above are in `kit/fonts/` (OFL).
- **Ready-made template**: `kit/templates/paper-cut-vertical.html` (1080x1920, tested on a 480x864 WhatsApp clip). Copy it to the project as `index.html`, set `data-duration` on the root and the `<video>`, then call the components in the graphics section:
  `headline(t0,t1,{label,title,color})` · `ransom(t0,t1,"TWO WORDS")` · `checklist(t1,{title,items:[{t,text}]})` · `counter(t0,t1,{label,to,prefix,suffix})` · `versus(t0,t1,{left:[label,text],right:[label,text,t]})` · `calendar(t0,t1,{title,crossAt|instant,glowAt,stamp:{t,text}})` · `reframe(t0,t1)` · `punch(t0,t1)`.
  Layout it assumes: face in y≈150–1080, graphics band y≈1100–1460, captions from y=1490.

## The 10 moves (name them and build them)
| Move | What it does | Use for |
|---|---|---|
| Rise | fade in while moving up ~40px | default entrance |
| Pop | scale 0.6 → 1 with a small overshoot | badges, pills, stickers |
| Count-up | number rolls to its value | any stat |
| Checklist tick | lines get a green tick one by one | any spoken list |
| Typewriter | text types itself letter by letter | quotes, prompts, search bars |
| Slide-in | comes in from the side | panels, comparisons |
| Blur-in | blurry → sharp | soft reveals, titles |
| Punch-in | whole frame zooms in ~15% fast, then holds | the line people should remember |
| Reframe | full-screen video shrinks into a rounded card, something new appears | topic changes, showing proof |
| Bar fill | progress bar fills 0 → 100% | progress, percentages, comparisons |

## Knobs (change anything, then: "keep everything else the same and render again")
- **Surface**: e.g. frosted glass → solid purple-to-pink gradient card with white text.
- **Colour**: brand colours, e.g. background `#111111`, card `#ff5a1f`, text white.
- **Type**: swap font family (use a local file in `fonts/`), resize by %.
- **Motion**: bouncier / calmer / faster / add overshoot.
- **Timing**: move an element's start to a new second or a spoken word.
- **Layout**: move / resize the card (keep safe zones).
Change only the knob asked for; preserve every other value.
