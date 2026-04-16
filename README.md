# Pointerworks

> Build factories where your own mouse cursor is the raw material.

A browser-native puzzle game about machines that run on your mouse. Built in 7 days for [Gamedev.js Jam 2026](https://itch.io/jam/gamedevjs-2026). Theme: **Machines**.

## Concept

Each level is an empty factory floor. Place **Emitters** on the grid, and when your real cursor passes over one, it spits out a **virtual cursor** — a tiny arrow flying in a fixed direction. Route those virtual cursors through a toolkit of parts — **Deflectors**, **Splitters**, **Speed Modifiers**, **Teleporters** — until they hit every **Target** in the right order.

It's *The Incredible Machine* for the browser era, where the thing your contraption is moving… is **you**.

## Play

- **itch.io:** _(link added on submission day)_
- **Source:** https://github.com/MozeeB/Pointerworks
- **Controls:** Mouse only. Drag parts from the palette onto the grid during BUILD phase; click RUN and move your cursor over Emitters to feed the machine.

## Build locally

```bash
# Requires Godot 4.6
/Applications/Godot.app/Contents/MacOS/Godot --path . --headless --export-release "Web" build/index.html
cd build && python3 -m http.server 8000
# open http://127.0.0.1:8000
```

## Docs

All project context lives in `docs/PLAN.md` — the single source of truth for scope, schedule, FSMs, and design decisions. Additional docs:

- [`docs/PLAN.md`](docs/PLAN.md) — full 7-day sprint plan, theme interpretation, tool choices
- [`docs/GAME_FLOW.md`](docs/GAME_FLOW.md) — FSMs + edge cases
- [`docs/ART.md`](docs/ART.md) — palette, shaders, animation catalog
- [`THEME.md`](THEME.md) — how Pointerworks answers the "Machines" theme
- [`PARTS.md`](PARTS.md) — 7-part reference sheet
- [`LEVELS.md`](LEVELS.md) — 10-level design notes
- [`CREDITS.md`](CREDITS.md) — attribution
- [`DEVLOG.md`](DEVLOG.md) — daily journal
- [`ISSUES.md`](ISSUES.md) — known bugs

## Side challenges

- **Open Source** — MIT licensed, public repo.
- **Ethereum** — Optional Sepolia on-chain level completions via MetaMask. Contract address: _(added on Day 5)_.

## License

MIT — see [LICENSE](LICENSE).
