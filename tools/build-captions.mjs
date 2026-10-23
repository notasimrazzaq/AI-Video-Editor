// Build captions.js from transcript.json + captions-src.json.
// captions-src.json: [[firstWordIndex, lastWordIndex, "Caption text", ["key", "words"]], ...]
// Usage (from workspace root): node tools/build-captions.mjs projects/<name>
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const dir = process.argv[2];
if (!dir) throw new Error("Usage: node tools/build-captions.mjs projects/<name>");

const strip = (s) => s.replace(/^\uFEFF/, "");
const words = JSON.parse(strip(readFileSync(join(dir, "transcript.json"), "utf8")));
const src = JSON.parse(strip(readFileSync(join(dir, "captions-src.json"), "utf8")));
const meta = JSON.parse(strip(readFileSync(join(dir, "metadata.json"), "utf8")));
const duration = Number(meta.format.duration);

const r2 = (n) => Math.round(n * 100) / 100;
const caps = src.map(([a, b, text, key = []], i) => {
  if (!words[a] || !words[b] || b < a) throw new Error(`Bad range in chunk ${i}: ${a}-${b}`);
  return { s: words[a].start, e: Math.max(words[b].end, words[a].start + 0.6), text, key };
});

let covered = new Set();
src.forEach(([a, b]) => { for (let k = a; k <= b; k++) covered.add(k); });
const missing = words.map((_, k) => k).filter((k) => !covered.has(k));
if (missing.length) console.warn(`Words not in any caption: ${missing.join(", ")}`);

caps.forEach((c, i) => {
  const next = caps[i + 1];
  // bridge short pauses so lines don't flicker; otherwise linger briefly
  c.e = next ? (next.s - c.e < 0.5 ? next.s : Math.min(c.e + 0.25, next.s)) : Math.min(c.e + 0.4, duration);
  c.s = r2(c.s);
  c.e = r2(c.e);
});

writeFileSync(join(dir, "captions.js"), `window.CAPTIONS = ${JSON.stringify(caps, null, 0).replace(/\},\{/g, "},\n{")};\n`);
console.log(`Wrote ${caps.length} captions to ${join(dir, "captions.js")}`);
