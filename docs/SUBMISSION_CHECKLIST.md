# Pointerworks — itch.io + Gamedev.js Jam 2026 submission checklist

Source-of-truth field reference lives in [`docs/PLAN.md`](PLAN.md#itchio-submission-form--field-by-field-reference) (40 rows). This file is the live Day 7 worksheet.

## Bundle sanity (verified 2026-04-17)

| File                             | Raw    | gzip (wire) |
|----------------------------------|--------|-------------|
| `build/index.wasm`               | 36 MB  | **9.4 MB**  |
| `build/index.pck`                | 478 KB | 193 KB      |
| `build/index.js`                 | 308 KB | 79 KB       |
| `build/index.audio.worklet.js`   | 7.1 KB | 2.2 KB      |
| `build/index.audio.position...`  | 2.9 KB | 1.2 KB      |
| **Total over the wire**          |        | **≈ 9.7 MB** |

Budget was <15 MB — **passes** with ~5 MB headroom. itch.io gzips static assets automatically.

## Pre-submit gate (every item must be ticked before flipping to Public)

- [ ] `git status` clean; `git push origin main` matches remote; `git tag v1.0 && git push --tags`
- [ ] Godot headless `--quit-after 3` boots `scenes/main.tscn` with zero `SCRIPT ERROR`
- [ ] Web export re-built from a clean tree (`rm -rf .godot build && headless --export-release`)
- [ ] Claude Preview smoke: `preview_start pointerworks-web` → Main Menu → L01 loads → BUILD/RUN toggle works → Credits + Connect Wallet visible → 0 errors in `preview_console_logs level=error` on fresh reload
- [ ] Real Chrome smoke (cursor-enter works): hover L01 emitter → virtual cursor flies → target lights → WinDialog "Conveyor hums." + ⭐
- [ ] Firefox + Safari smoke on `python3 -m http.server 8000`
- [ ] Tutorial first-run shows + persists dismissal (clear `localStorage` in DevTools → reload → tutorial; reload again → no tutorial)
- [ ] Pause (Esc), Settings (from Pause), Fullscreen (F11) all work
- [ ] Connect Wallet button: without MetaMask → click → `no_wallet` error surfaces but game keeps playing

## itch.io page — exact field values

See [`docs/PLAN.md` § "itch.io submission form — field-by-field reference"](PLAN.md#itchio-submission-form--field-by-field-reference) for the 40-row table. Key values:

- **Title:** Pointerworks
- **Short description:** `Build factories where your own mouse cursor is the raw material.`
- **Kind:** Games → HTML → Embed in page, **1280 × 720** viewport, SharedArrayBuffer **OFF** (we ship non-threads), Mobile friendly **OFF** (desktop-only; DesktopOnlyBlocker in-game enforces this)
- **Tags (10, order matters):** `puzzle, machines, html5, godot, mouse-only, contraption, logic, factory, gamedevjs2026, open-source`
- **Genre:** Puzzle. **Custom noun:** `puzzle game`.
- **Metadata Inputs:** tick Mouse only (not keyboard — shortcuts are power-user only)
- **Accessibility:** tick "Configurable colors" (colorblind toggle in Settings)
- **AI-disclosure** (mandatory since 2024): tick + mention "Ethereum bridge code + level builders + shaders + UI + game logic are human-authored. No AI-generated images ship in v1.0."
- **Content rating:** safe for children (no violence / profanity / mature)
- **Community / Comments:** disabled for jam window; re-enable post-submit if traction

## Upload sequence (Day 7 exact order — do NOT flip Public until step 11)

1. Log in at https://itch.io/game/new as `MozeeB`
2. Fill fields #1-7 (Title → Pricing)
3. Upload zipped `build/` → tick "This file will be played in the browser"
4. Configure embed options (#10-16)
5. Upload cover image 630×500 PNG to `docs/cover.png` (see below)
6. Upload 3 screenshots from `docs/screenshots/`
7. (Optional) paste YouTube URL for trailer MP4
8. Paste long description with cover embed + GitHub + Etherscan links
9. Fill Genre / Tags / Noun / External links / Metadata (#17-36)
10. Save as **Draft**; open the preview in Incognito at full size + 315×250 thumbnail size
11. Flip **Visibility** to **Public** → Save
12. Copy the public URL (expected: `mozeeb.itch.io/pointerworks`)
13. Go to https://itch.io/jam/gamedevjs-2026/submit → paste URL → tick Open Source + Ethereum side challenges
14. Confirm via the email itch.io sends

## Media still needed (human-assist)

Claude Code cannot persist canvas screenshots to disk through the preview MCP (inline-only). These artefacts need a manual capture session:

- **`docs/cover.png`** — 630×500 PNG, ≤500 KB. Prompt for Figma/HF MCP or Preview + macOS screenshot: factory grid with amber emitters + magenta cursor trails + cyan targets on BG_DARK. Leading text "Pointerworks" optional.
- **`docs/screenshots/01-build.png`** — 1280×720 of BUILD phase on L01 or L04 (parts visible, Run button visible)
- **`docs/screenshots/02-run.png`** — mid-RUN with magenta trails in flight
- **`docs/screenshots/03-win.png`** — WinPanel with ⭐ par rating
- **`docs/trailer.gif`** — 30 s, 640 wide, 15 fps (`ffmpeg -i in.mov -vf "fps=15,scale=640:-1" docs/trailer.gif`)
- **`docs/trailer.mp4`** — 60 s H.264 for YouTube (`ffmpeg -i in.mov -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p -c:a aac -b:a 128k`)

## Post-submit

Leave 4 days buffer (Apr 22 submit → Apr 26 jam deadline) for hotfixes based on public-playtest feedback. Do **not** push breaking changes during this window.
