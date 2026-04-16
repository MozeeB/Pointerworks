# Pointerworks — Gamedev.js Jam 2026 (7-day sprint)

> ## 🚀 FAST-RESUME (read this first, every session)
>
> **Claude Code Desktop sessions should take <30 s to orient.** This block is the entire onboarding.
>
> **Step 1 — Read the live state table below** (updated every EOD):
>
> ```
> ┌─────────────────────────────────────────────────────┐
> │ CURRENT STATE (update at EOD + mid-task checkpoints)│
> ├─────────────────────────────────────────────────────┤
> │ Today's date:          2026-04-17                   │
> │ Current day:           Day 5 of 7 — COMPLETE        │
> │ Last completed:        Day 5 EOD — Ethereum plumbing│
> │                        shipped (contract + tests +  │
> │                        glue + Web3Bridge + UI,      │
> │                        deploy self-serve)           │
> │ Next action:           Day 6 — robustness (save +   │
> │                        error dialog) + playtest +   │
> │                        l09 Reactor + l10 Cyclotron  │
> │ In-progress (if any):  (none — end of Day 5)        │
> │   └─ last file touched: DEVLOG.md                   │
> │   └─ last test run:     Preview: window.pointerworks│
> │                        object exposed; 0 errors     │
> │ Blockers:              Contract not deployed (user  │
> │                        self-serve via README). Music│
> │                        deferred. Bundle gzip at D7. │
> │ Last commit:            (pending Day 5 EOD)         │
> │ Plan version:          v8 (7-day + Ethereum +       │
> │                        gap audit + theme detail +   │
> │                        source-of-truth +            │
> │                        context-limit safety +       │
> │                        genre desc)                  │
> └─────────────────────────────────────────────────────┘
> ```
>
> **Step 2 — Skip re-exploration.** All scope, FSMs, tool choices, edge cases, and gotchas are in this plan. Don't search the codebase for context — it's here.
>
> **Step 3 — Jump to the current-day section.** Use the Table of Contents (next section).
>
> **Step 4 — Execute the day's morning/midday/afternoon checklists in order.** Mark each `- [ ]` complete as you go (edit THIS file — working copy — and copy to `docs/PLAN.md` at EOD).
>
> **Step 5 — If anything diverges from the plan, edit the plan FIRST, then implement.** Never let code and plan drift.
>
> **If resuming from a prior session that ran out of context:** Read the CURRENT STATE block above + the `DEVLOG.md` last `Session handoff` entry + `ISSUES.md` → you have enough to continue. Do NOT re-read everything. Details: see [Context-limit safety](#context-limit-safety-mid-task-session-interruption).
>
> **Mid-task checkpoints are mandatory, not optional.** If you are editing and notice context getting heavy, or >30 tool calls in, or a system warning about context — STOP and run the full checkpoint procedure. Losing a partial edit is much worse than a 3-minute checkpoint pause.

## Table of Contents (fast navigation)

- [🚀 FAST-RESUME](#-fast-resume-read-this-first-every-session) (above)
- [🎯 Source of Truth](#-source-of-truth)
- [🗣️ Response Style — Caveman Ultra](#-response-style--caveman-ultra-default) — default chat compression
- [🔬 Verification Cadence](#-verification-cadence--godot-mcp--claude-preview-are-non-negotiable) — Godot MCP per task + Claude Preview per day (HTML5 is the ship target)
- [Context](#context) — jam details, game title, descriptions, target outcome
- [Genre](#genre) — puzzle genre positioning, audience, tone
- [Tags](#tags-canonical-list--copy-verbatim-to-itchio-github-topics-jam-form) — canonical tag list for itch, GitHub, jam form
- [**itch.io submission form — field reference**](#itchio-submission-form--field-by-field-reference) — every field on https://itch.io/game/new with pre-filled values
- [Core mechanic](#core-mechanic--pointerworks)
- [**Theme — "Machines"**](#theme--machines-how-pointerworks-answers-the-brief) — 4-layer interpretation, level names, justification
- [Architecture summary](#architecture-summary)
- [Open Source challenge integration](#open-source-challenge-integration-free)
- [Art / animation / sprites / tileset / background](#art--animation--sprites--tileset--background-strategy)
- [Design & art tooling — MCP stack](#design--art-tooling--mcp-stack)
- [Audio tooling — MCP stack](#audio-tooling--mcp-stack-free-only)
- [Markdown docs inventory](#markdown-docs-inventory-prevent-context-loss-across-sessions)
- [**Gap audit**](#gap-audit--what-a-complete-jam-game-needs)
- [**7-day sprint schedule**](#7-day-sprint-schedule)
- [**Tool cost audit**](#tool-cost-audit-every-tool-must-be-free)
- [**Detailed game flow**](#detailed-game-flow-prevent-gaps--bugs)
- [Risks & mitigations](#risks--mitigations-7-day-scope)
- [Verification / test plan](#verification--test-plan)
- [Session resumption protocol](#session-resumption-protocol-for-future-claude-sessions)
- [**Context-limit safety**](#context-limit-safety-mid-task-session-interruption) — checkpoint procedure for mid-task interruptions
- [Critical files to touch](#critical-files-to-touch-in-the-first-session-day-1-morning-30-min)

> ## 🎯 Source of Truth (authoritative — all other docs defer to this one)
>
> **This document is THE single source of truth for the Pointerworks project.** It supersedes any other document, memory, or session context.
>
> - **Precedence order** (highest → lowest): `docs/PLAN.md` (this file, repo copy) > `CLAUDE.md` > `THEME.md`, `docs/GAME_FLOW.md`, `docs/ART.md` > `DEVLOG.md` > in-code comments > session memory. If two sources disagree, this plan wins and the other source is stale — update it.
> - **Working copy vs repo copy:** the *working copy* at `/Users/mujibnoctua/.claude/plans/parallel-jingling-river.md` is where Claude edits during planning; the *repo copy* at `docs/PLAN.md` is the shipped, committed, reviewed version. Sync them at every EOD and at every mid-task checkpoint (see "Context-limit safety" below).
> - **Every scope decision, timeline, FSM, tool choice, theme interpretation, risk, edge case, and genre classification is defined here.** If a piece of context is NOT in this plan, either (a) it's derivable from the code, (b) it's in memory as a user-preference, or (c) it's missing — in which case add it here before acting on it.
> - **When the plan needs to change, edit THIS file first, then propagate:**
>   - `CLAUDE.md` gets the "current sprint day" + "known dragons" line updates.
>   - `DEVLOG.md` gets the 2-5 line day entry.
>   - `THEME.md` / `docs/GAME_FLOW.md` / `docs/ART.md` get copies of their respective sections.
> - **Day 1 task:** copy this file into the repo at `docs/PLAN.md` so it ships with the project. Future Claude sessions should `Read docs/PLAN.md` first before any work.
> - **When in doubt, consult this file before asking the user questions — the answer is probably already here.**
> - **Judge-friendly side-effect:** because this plan lives in the repo, Gamedev.js judges can read the whole strategy + theme interpretation + scope reasoning directly on GitHub. It doubles as a design doc + post-mortem.
>
> **Canonical locations:**
> - Working copy (edited during planning): `/Users/mujibnoctua/.claude/plans/parallel-jingling-river.md`
> - Repo copy (shipped + committed): `docs/PLAN.md` (created Day 1, synced every EOD + every mid-task checkpoint)
>
> The two must stay in sync. Treat `docs/PLAN.md` as read-only during a day's work; update it at EOD + at mid-task checkpoints alongside `DEVLOG.md`.

> ## 🗣️ Response Style — Caveman Ultra (default)
>
> **Claude replies in Caveman Ultra** on this project. Token-thrift: drop articles, filler, hedging. Fragments fine. Arrows for causality (`write → run → verify`). Abbreviations welcome (DB, auth, req, res, MCP, TTL).
>
> **Unchanged:** code, commit messages, PR bodies, `.md` files, `DEVLOG.md` entries, plan edits. Caveman = chat reply only.
>
> **Safety suspends caveman:** irreversible ops, security warnings, destructive git, multi-step confirmations — switch to normal mode until clarity, then resume.
>
> **Switch levels** via `/caveman [lite|full|ultra|wenyan-lite|wenyan-full]`. "normal mode" exits entirely.
>
> Skill: `/Users/mujibnoctua/.claude/skills/caveman`.

> ## 🔬 Verification Cadence — Godot MCP + Claude Preview are non-negotiable
>
> **We ship HTML5**, so the authoritative test is the *web build* — and the cheapest way to drive that in-session is **Claude Preview MCP**. Godot MCP is the fast-path parse check between writes; Claude Preview is the daily *real* smoke on the thing judges will actually load.
>
> **Two-track cadence:**
>
> | Track | Tool | Purpose | Frequency |
> |---|---|---|---|
> | **Fast-path (per task)** | **Godot MCP** `run_project` + `get_debug_output` | Catch parse errors and runtime exceptions within seconds of a file write. Editor-only — tests the code, not the shipping target. | After every `.gd` / `.tscn` write |
> | **Ship-path (per day, per commit)** | **Claude Preview MCP** on exported `build/index.html` | The real target: WASM boots, assets load, gameplay flows under browser runtime + localStorage + autoplay policy. | Daily EOD, and before every non-doc commit once a web build exists (≥ Day 2 EOD) |
>
> **Claude Preview is the default smoke test.** Screenshots, console logs, network tab, and scripted clicks all live in-session — no tab-switching, no manual browser launch for baseline checks.
>
> **`.claude/launch.json` (create at Day 2 EOD, when the first web build lands):**
>
> ```json
> {
>   "version": "0.0.1",
>   "configurations": [
>     {
>       "name": "pointerworks-web",
>       "runtimeExecutable": "python3",
>       "runtimeArgs": ["-m", "http.server", "8000", "--directory", "build"],
>       "port": 8000
>     }
>   ]
> }
> ```
>
> After that, `preview_start` with `name: "pointerworks-web"` boots the build on `http://127.0.0.1:8000/` and every preview tool (`preview_screenshot`, `preview_console_logs`, `preview_click`, `preview_eval`, `preview_network`, `preview_resize`) becomes available.
>
> **Mandatory calls by phase:**
>
> | When | Tool chain | What to capture |
> |---|---|---|
> | **After every file write** to `scripts/**/*.gd` or `scenes/**/*.tscn` | Godot MCP `run_project` → `get_debug_output` | Boot clean; zero `SCRIPT ERROR` / `Parse error` / `ERROR:` |
> | **After any new part lands** | Godot MCP open `scenes/dev/part_test.tscn` → `get_debug_output` | Pre-existing smoke still works; no new warnings |
> | **Every day's EOD (Day 2+)** | (a) Godot MCP `run_project` **AND** (b) export web build via headless CLI → `preview_start` → `preview_screenshot` → `preview_console_logs` | Web boot clean; screenshot saved to `docs/preview-day-N.png`; 2-line summary in `DEVLOG.md` |
> | **Every day's EOD (Day 1 only — no web build yet)** | Godot MCP `run_project` + manual play of `scenes/dev/part_test.tscn` | Editor smoke clean |
> | **Before any `git commit`** that isn't pure-doc | Same as the current phase (Day 1: Godot only; Day 2+: Godot + Preview) | Clean output |
> | **Mid-task checkpoint** (Context-limit safety) | Godot MCP `run_project` | Result line into `In-progress > last test run` |
> | **Day 4+ UX-gap features** | `preview_click` + `preview_eval` to script Tutorial → Level → Pause → Settings → Win flow | Confirm no console errors across the full flow |
> | **Day 5 Ethereum** | `preview_network` (verify ethers.js CDN loads), `preview_eval` (`window.pointerworks.isConnected()`) | Wallet round-trip works without wallet installed (skip path) |
> | **Day 7 pre-submit** | Full `preview_resize` trio: 1280×720, 1024×768 (judge laptop), 1920×1080 | Layout survives all three |
>
> **Checklist-item completion rule** (every `- [ ]` that modifies runtime code):
>
> > A checkbox only flips to `- [x]` when **all three** conditions are true:
> > 1. Code is written + saved.
> > 2. Godot MCP `run_project` booted with no parse / load errors.
> > 3. `get_debug_output` (or `preview_console_logs` for web-only fixes) shows no new `ERROR` / `SCRIPT ERROR` / `Invalid` entries.
> >
> > Day 2+ additionally requires: Claude Preview `preview_start` + `preview_console_logs` clean once per commit boundary (not per file, to keep cycles fast).
> >
> > If any condition fails, the checkbox stays `- [~]` (in-progress) and the next action is fix — not move on.
>
> **Doc-only edits are exempt.** Updating `.md`, `CREDITS.md`, `DEVLOG.md`, `docs/PLAN.md` does not require any run.
>
> **Fallbacks** (use only when the MCP is genuinely unavailable — record in `In-progress > last test run`):
>
> - **Godot MCP down** → headless CLI:
>   ```
>   /Applications/Godot.app/Contents/MacOS/Godot --headless --check-only --path . 2>&1 | tail -40
>   /Applications/Godot.app/Contents/MacOS/Godot --headless --quit-after 2 --path . 2>&1 | tail -40
>   ```
> - **Claude Preview down** → real-browser smoke in Chrome (`cd build && python3 -m http.server 8000` + manual open). Note: no scripted assertions, so this is strictly worse — re-enable Preview ASAP.
>
> **Daily EOD verification gate** (folded into the universal EOD checklist below — non-optional):
>
> - [ ] Godot MCP `run_project` on `scenes/main.tscn` — clean boot.
> - [ ] Godot MCP `get_debug_output` — zero errors.
> - [ ] **Day 2+:** Web export built; `preview_start` boots `pointerworks-web`; `preview_screenshot` saved to `docs/preview-day-N.png`; `preview_console_logs` zero errors.
> - [ ] Manual smoke of the day's exit-gate behavior.
> - [ ] `Verify:` bullet added to `DEVLOG.md` Day N entry (e.g., `Verify: Godot clean; Preview web build loads; 3/3 targets lit in part_test`).
>
> **Why this rule exists:** the jam target is `index.html` + `*.wasm` + `*.pck` running in a browser on a judge's laptop. Testing only in the Godot editor means a working editor build + broken web build = failed submission. Every day after Day 1 must end with proof the *web build* is green. Claude Preview makes that proof automatic and in-session.
>
> **Anti-patterns:**
> - Writing 5 files in a row, then running Godot once at the end and getting a cryptic stack trace from file #3. *Correct:* write → run → verify → next file.
> - Shipping a commit without running the web build post–Day 2. *Correct:* every commit that touches runtime code → Preview smoke.
> - "It works in the editor" — not sufficient. The browser has different autoplay policies, `localStorage` quotas, WASM init timings. Web build is the only truth post–Day 2.

## Context

**Why this project, now:** The user wants to compete in [Gamedev.js Jam 2026](https://itch.io/jam/gamedevjs-2026), a 13-day HTML5 browser-game jam with a **$30k prize pool**, running **Apr 13 – Apr 26 2026**. Today is **Apr 16 2026**. The user has chosen a **self-imposed 7-day sprint** (Apr 16 → Apr 22), submitting 4 days before the jam deadline. This provides real breathing room to close UX gaps, add the Ethereum challenge, do a proper external playtest, and still leave a buffer for last-minute fixes.

**Game title: "Pointerworks"** — portmanteau of *pointer* (mouse cursor) and *ironworks* (industrial factory). Uniqueness verified: 0 results on itch.io / Steam / GitHub / npm / USPTO.

**GitHub repo (user-created):** `git@github.com:MozeeB/Pointerworks.git` → https://github.com/MozeeB/Pointerworks

**Short description** (itch.io tagline, <150 chars):
> *Build factories where your own mouse cursor is the raw material.*

**Long description** (itch.io submission page):
> *Pointerworks* is a browser-native puzzle game about machines that run on your mouse.
>
> Each level is an empty factory floor. Place **Emitters** on the grid, and when your real cursor passes over one, it spits out a **virtual cursor** — a tiny arrow flying in a fixed direction. Route those virtual cursors through a toolkit of parts — **Deflectors**, **Splitters**, **Speed Modifiers**, **Teleporters** — until they hit every **Target** in the right order.
>
> It's *The Incredible Machine* for the browser era, where the thing your contraption is moving… is you.
>
> **Theme — "Machines":** every level is a machine you build; every puzzle is a machine you debug. The grid is the factory. You are the fuel.
>
> **Open Source:** full source on GitHub under MIT. Fork it, port it, learn from it.
>
> **Controls:** Mouse only. Drag parts from the palette onto the grid during build phase; click Run and move your cursor over Emitters to feed the machine.
>
> Made in 7 days with [Godot 4.6](https://godotengine.org/) for [Gamedev.js Jam 2026](https://itch.io/jam/gamedevjs-2026). Theme: *Machines*. Qualifying for Open Source + Ethereum side challenges.
>
> **Credits:** Music + SFX generated via Hugging Face MCP (MusicGen / AudioLDM2) · retro SFX with [sfxr](https://sfxr.me/) · UI designed with Figma · Built with Godot 4.6.

**Target outcome:** Ship a browser-playable Godot 4.6 HTML5 puzzle game — **Pointerworks** — that competes strongly on *Innovation* and *Theme*, and qualifies for **two** side challenges: **Open Source** (GitHub + MIT) and **Ethereum** (Sepolia on-chain level completions).

### Genre

**Primary genre:** **Puzzle** — specifically **grid-based logic / contraption puzzle** (sub-genre of "engineering sandbox puzzle"). Closest genre siblings: *The Incredible Machine* (1993), *SpaceChem* (2011), *Opus Magnum* (2017), *Manifold Garden*'s puzzle segments, *while True: learn()*. Pointerworks sits in the same lineage but swaps "place parts on a board and press play" for "place parts on a board **and then be the energy source yourself**" — moving the player's agency from planner-only to planner-plus-fuel.

**Secondary tags** (for itch, Steam-like storefront filters, and judge scanning):
- **Logic puzzle** — solution-oriented, no twitch reflex.
- **Programming-adjacent** — building a deterministic machine resembles visual programming; "beat par-cursors" rewards clean design, same dopamine as refactoring.
- **Physics-lite** — cursors move on fixed-velocity rails; no simulation noise. Easier to reason about than a full physics sandbox.
- **Single-player** — no multiplayer for scope reasons, but leaderboards via Ethereum bitmap are a possible post-jam stretch.
- **Short session** — each level 30 s – 3 min; total playtime 20–40 min for all 10 levels. Ideal for judges' short time budget.
- **Mouse-only / accessibility note:** Pointer-only input (no keyboard required for gameplay; keyboard is shortcut-only). Not playable without a mouse or trackpad — desktop-only blocker makes this explicit.

**Target audience:** puzzle enthusiasts (TIM / SpaceChem / Zachtronics fans), web-game browsers scanning itch.io front pages, Gamedev.js Jam 2026 judges. Secondary: casual players who'll play 2–3 levels for the "my cursor is the fuel" novelty and bounce.

**Tone:** industrial-cute — factory aesthetic softened by saturated flat-vector colors (amber + magenta + cyan on dark navy), upbeat chiptune loop, playful fail copy ("Machine stalled"). Not grim dystopia; not cutesy platformer. Think "lo-fi factory tour."

**One-sentence genre pitch** (use verbatim on itch.io + jam form):
> *Pointerworks is a grid-based contraption puzzle where you build factories out of deflectors, splitters, and teleporters, then feed them with your own mouse cursor.*

### Tags (canonical list — copy verbatim to itch.io, GitHub topics, jam form)

One source of truth for every tag-input field. Itch.io allows up to 10 tags; GitHub repos allow up to 20 topics. Jam submission form accepts a freeform tag string.

**itch.io tags** (exactly 10, order matters — first tag is what itch uses for default search boost):

1. `puzzle`
2. `machines` *(jam theme — must be present)*
3. `html5`
4. `godot`
5. `mouse-only`
6. `contraption`
7. `logic`
8. `factory`
9. `gamedevjs2026` *(jam-specific discoverability)*
10. `open-source`

**GitHub topics** (for `MozeeB/Pointerworks` repo — up to 20, includes tech stack + side-challenge tags):

`godot`, `godot4`, `godot-engine`, `gdscript`, `html5-game`, `browser-game`, `puzzle-game`, `contraption-puzzle`, `grid-puzzle`, `machines`, `gamedevjs`, `gamedevjs2026`, `game-jam`, `open-source-game`, `mit-license`, `ethereum`, `sepolia`, `web3`, `ethers-js`, `solidity`

**Jam submission form tag string** (paste into the "tags" input):
```
puzzle, machines, html5, godot, mouse-only, contraption, logic, factory, gamedevjs2026, open-source, ethereum
```

**Descriptive marketing hashtags** (for Twitter/BlueSky announcement posts — not for storefront fields):
`#gamedevjs2026` · `#gamedev` · `#indiedev` · `#godotengine` · `#puzzlegame` · `#html5games` · `#madeingodot` · `#machinesjam`

**Tag hygiene rules:**
- **Never add tags that don't match the game.** Judges filtering by tag will be annoyed by false matches (`platformer`, `shooter`, etc. would fail this test).
- **Do not tag `web3` on itch.io** — Ethereum is 100% optional; leading with a crypto tag will push away the 95% of puzzle fans who don't want a crypto game. Keep `ethereum` on the GitHub repo and in the jam side-challenge field only.
- **Do not tag `mobile` anywhere** — the game is desktop-only. Adding `mobile` would bring frustrated mobile players who can't run it.
- **Do not tag `multiplayer`** — single-player only.
- **Lock this list on Day 1.** Changing tags post-submission resets itch's discoverability signal.

### itch.io submission form — field-by-field reference

**URL of the form:** https://itch.io/game/new (authenticated; user must be logged in as `MozeeB`).

This table is the *single source of truth* for every field Claude/user will fill on Day 7. Values already decided elsewhere in this plan are repeated here verbatim so no copy-pasting from memory is needed. Constraints are taken from itch.io's current public HTML5 creator docs (https://itch.io/docs/creators/html5 + https://itch.io/docs/creators/design) plus observed form behavior.

| # | Field | Req? | Value / constraint | Source-of-truth in this plan |
|---|---|---|---|---|
| 1 | **Title** | ✅ | `Pointerworks` | Context § Game title |
| 2 | **Project URL** (slug) | ✅ (auto from title) | `mozeeb.itch.io/pointerworks` — accept default | n/a |
| 3 | **Short description / tagline** | ✅ (≤150 chars) | `Build factories where your own mouse cursor is the raw material.` | Context § Short description |
| 4 | **Classification** (Kind of project) | ✅ | **Games** | n/a |
| 5 | **Kind of project** | ✅ | **HTML** | Architecture § Web export |
| 6 | **Release status** | ✅ | **Released** (flip on Day 7 when public) | Day 7 checklist |
| 7 | **Pricing** | ✅ | **No payments** (free, aligns with jam + Open Source challenge) | Context + Open Source integration |
| 8 | **Uploads** | ✅ | Zip of `build/` (contains `index.html`, `*.wasm`, `*.pck`, `*.js`, audio). Total **< 15 MB**. | Day 7 export + bundle check |
| 9 | **This file will be played in the browser** | ✅ | Tick this on the uploaded zip | n/a |
| 10 | **Embed options → Display mode** | ✅ | **Embed in page** (not click-to-launch-fullscreen) | Architecture |
| 11 | **Embed options → Viewport dimensions** | ✅ | **1280 × 720** (matches `project.godot` `[display]` settings) | Day 1 morning checklist |
| 12 | **Embed options → Fullscreen button** | — | **ON** (auto-added by itch; players expect it) | — |
| 13 | **Embed options → Mobile friendly** | — | **OFF** (game is desktop-only; DesktopOnlyBlocker in-game also enforces this) | Gap audit #5 |
| 14 | **Embed options → SharedArrayBuffer support** | — | **OFF** (we ship non-threads web variant — no COOP/COEP needed) | Architecture + Risks |
| 15 | **Embed options → Scrollbars** | — | **OFF** (game fits viewport) | — |
| 16 | **Embed options → Click to play** | — | **ON** (default — required for audio autoplay policy) | Detailed game flow §E Save/load notes |
| 17 | **Genre** (itch's single-select dropdown) | — | **Puzzle** | Genre section |
| 18 | **Tags** (up to 10, comma-sep) | — | `puzzle, machines, html5, godot, mouse-only, contraption, logic, factory, gamedevjs2026, open-source` | Tags section |
| 19 | **Custom noun** (how itch refers to "the game" — e.g., "game", "experience") | — | `puzzle game` | Genre |
| 20 | **App store availability** | — | Leave all OFF (no Steam, no Epic, etc.) | — |
| 21 | **Community** | — | **Disabled** for jam submission (avoid moderation burden; re-enable post-jam if traction) | — |
| 22 | **Visibility** | ✅ | **Public** (flipped on Day 7 after final media upload; keep `Draft` or `Restricted` until ready) | Day 7 checklist |
| 23 | **Cover image** | ✅ | `docs/cover.png` — **630×500** PNG, ≤500 KB. Min 315×250. Full spec in "Cover image & itch media". | Art § Cover |
| 24 | **Screenshots** | — (but strongly recommended) | 3 × 1280×720 PNGs from `docs/screenshots/`: BUILD / RUN / WIN | Art § Other itch media |
| 25 | **Trailer / Video URL** | — | *(optional)* YouTube URL if user uploads the 60 s MP4; skip if not | Day 7 afternoon |
| 26 | **Description body** (rich-text) | ✅ | Long description from Context § *Long description*; embed `docs/cover.png` inline at top; link to GitHub + Etherscan | Context § Long description |
| 27 | **External links → Source code** | — | `https://github.com/MozeeB/Pointerworks` | Open Source integration |
| 28 | **External links → Homepage / other** | — | Leave blank | — |
| 29 | **Page theme / color / font** | — | Skip custom theming — default dark theme matches our aesthetic well enough; spending 30 min here is low-ROI for a jam | — |
| 30 | **Metadata → Release date** | ✅ (auto) | 2026-04-22 (Day 7) — itch fills this from the submission time | Day 7 |
| 31 | **Metadata → Platforms** | ✅ | **Web** only (no Windows/Mac/Linux native uploads) | Architecture |
| 32 | **Metadata → Average session length** | — | **A few minutes** (each level 30 s – 3 min) | Genre § secondary tags |
| 33 | **Metadata → Inputs supported** | — | Tick **Mouse** only. Do NOT tick keyboard (shortcuts are power-user only, not required). Do NOT tick touchscreen. | Genre + Gap audit #5 |
| 34 | **Metadata → Accessibility features** | — | Tick **Configurable colors** (colorblind palette toggle from Gap audit #3) | Gap audit #3 |
| 35 | **Metadata → Languages supported** | — | **English** | — |
| 36 | **Metadata → Multiplayer** | — | Leave all off (single-player only) | Genre |
| 37 | **This page is not appropriate for children** | ✅ | **OFF** (no violence, no profanity, no mature content — Pointerworks is all-ages) | — |
| 38 | **Content warnings** | — | None. Do NOT tick flashing lights / audio warnings (game has no strobe; music is non-jarring). | — |
| 39 | **AI-generated content disclosure** | ✅ (itch mandates for 2024+) | **Tick "This project contains AI-generated content"** AND disclose in description: *"Background music (Hugging Face MusicGen) and 2 sound effects (Hugging Face AudioLDM2 / Stable Audio Open) are AI-generated. All code, art, level design, and game logic are human-authored."* | Audio tooling § License check |
| 40 | **Comments** | — | **Disabled for jam window** (avoid moderation during Apr 22–26 buffer); re-enable post-submission if traction warrants | — |

**Upload technical constraints (from itch HTML5 docs):**
- Max 1,000 files per ZIP → we'll have ~10 files, fine.
- Max filename length: 240 chars → fine.
- Total extracted: 500 MB → we're <15 MB.
- Individual file size: 200 MB → fine.
- UTF-8 filename encoding → Godot export does this by default.

**Submission order (Day 7 exact sequence — do NOT flip Public until step 11):**

1. Go to https://itch.io/game/new while logged in as `MozeeB`.
2. Fill fields #1-#7 (Title through Pricing).
3. Scroll to **Uploads** — drag `build.zip` → tick "This file will be played in the browser".
4. Configure **Embed options** (#10-#16).
5. Upload **Cover image** (#23) — 630×500 PNG.
6. Upload **3 Screenshots** (#24).
7. Paste **Trailer video URL** (#25) if YouTube upload done; otherwise skip.
8. Paste **Description** (#26) including cover image + GitHub + Etherscan links.
9. Fill **Genre / Tags / Custom noun / External links / Metadata** (#17-#36).
10. **Save** as Draft; click "View page" to preview at desktop size + 315×250 thumbnail size.
11. Only after preview looks correct: flip **Visibility** to **Public** (#22) and **Save** again.
12. Copy the resulting public URL (e.g., `mozeeb.itch.io/pointerworks`).
13. Go to https://itch.io/jam/gamedevjs-2026/submit — paste the public URL + tick both side challenges (Open Source + Ethereum).
14. Confirm submission email.

**Risk: "form saved but game not live"** — itch requires the game to be set to **Public** AND the build to be marked "playable in browser" for the jam submission to work. Always verify the game loads at its public URL in an Incognito tab before submitting to the jam.

**Risk: "SharedArrayBuffer toggle wrong"** — if the non-threads web variant is accidentally uploaded *with* SharedArrayBuffer toggle ON, itch will enforce COOP/COEP and the game may fail to load on some browsers. Keep #14 OFF; verify in Incognito.

**Included (thanks to 7-day window):**
- **Ethereum challenge** — promoted from post-jam stretch into Day 5. Solidity contract on Sepolia + `JavaScriptBridge` → `ethers.js` v6 + on-chain "level completed" events.

**Still deferred:**
- **YouTube Playables / Wavedash** — mobile-first; fundamentally conflicts with mouse-cursor mechanic.

## Core mechanic — "Pointerworks"

The player builds grid-based machines where the **player's OS mouse cursor is the working fluid**. Tiles called **Emitters** detect the real cursor entering them and spawn **Virtual Cursors** that fly across the grid at a fixed velocity. Other tiles modify them: Deflectors rotate 90°, Splitters fork, Speed Modifiers scale velocity, Teleporters relocate. Hit all Target tiles → win.

**Why innovative:** No existing browser game treats the OS mouse cursor as an engineering substrate. The closest analog (Mouse Required) only "rescues" cursors. This mechanic is unshippable on any non-browser platform — perfect fit for an HTML5 jam.

## Theme — "Machines" (how Pointerworks answers the brief)

Jam theme is **"Machines"**. Judges score theme fit explicitly, so the game needs a defensible, layered answer — not just "there's a machine in it." Pointerworks is engineered around four simultaneous interpretations of the theme; each reinforces the others and shows up in the gameplay, the art, and the copy.

### Four layers of "Machines"

1. **The factory is the machine (diegetic).** Every level is a literal machine the player assembles from parts on a grid: Emitter, Deflector, Splitter, Speed Modifier, Teleporter, Target. The machine has inputs (real cursor), processing stages (parts mutate velocity/direction/count), and outputs (Target tiles light up). Levels are named after industrial machinery: *Conveyor, Press, Forge, Refinery, Lathe, Kiln, Foundry, Assembly, Reactor, Cyclotron*. Each level intro card calls out the machinery metaphor.
2. **The player is the machine (meta).** In Pointerworks the mouse cursor is not a tool — it's *fuel*. The player's real cursor enters an Emitter and the machine consumes them, converting motion into virtual cursors that do work. This inverts the usual "you are the operator" trope; *you* are the raw material, the conveyor belt is everywhere else. Players feel this the first time they realize hovering an Emitter produces output.
3. **The browser is the machine (platform).** The OS mouse cursor only exists on desktop browsers — this mechanic can't be ported. We lean into it: the title screen has a subtitle "Runs on your browser's cursor.", the tutorial explicitly says "Your real cursor is the fuel", and the desktop-only blocker says "Pointerworks runs on desktop mouse hardware." The platform IS the machine.
4. **Debugging is gameplay (meta-meta).** Puzzle-solving here feels like repairing a broken machine: you watch virtual cursors flow, spot where they die (wall, off-grid, TTL), tweak a Deflector by 90°, run again. The BUILD → RUN → FAIL → BUILD loop is literally the industrial iterate-and-fix cycle. Par-cursors rating rewards *efficient* machines — the player becomes a mechanical engineer optimizing a factory line.

### How the theme shows up in each system

| System | How it expresses "Machines" |
|---|---|
| **Visual design** | Factory-floor aesthetic: amber emitters resemble furnace mouths, cyan targets resemble pressure gauges, walls are grey industrial bulkheads, cursor trails resemble sparks. Grid shader = glowing floor plates. |
| **Audio (music)** | HF MusicGen prompt: *"chiptune factory ambient loop, 110 BPM, minor key, industrial clanks, looping, no drums on the downbeat"*. The rhythm itself evokes machinery. |
| **Audio (SFX)** | `spawn` = hydraulic hiss, `deflect` = metallic clank, `hit_target` = pressure-release valve, `win` = assembly line success chime, `place_part` = bolt-tightening click. |
| **Level names** | `l01.tres` = "Conveyor", `l02.tres` = "Press", ... `l10.tres` = "Cyclotron". Each level `name` string in `LevelResource` is an industrial machine. |
| **Level design progression** | L1-3 teach a single machine component (like learning a lathe). L4-7 combine components (a full assembly line). L8-10 are "factory floor" problems with 4+ parts + par-cursor optimization. |
| **Tutorial copy** | "Your real cursor is the fuel. Emitters refine it into virtual cursors. Deflectors redirect them. Targets are the machines you're powering. Build the factory. Run the factory. Fix the factory." |
| **Win-dialog copy** | Varies per level: "Machine calibrated." / "Factory line operational." / "Reactor critical — in a good way." |
| **Fail-banner copy** | "Machine stalled — X targets unfed." (not "you failed" — blame is on the machine, encouraging iteration). |
| **Ethereum integration** | "Submit on-chain" = the factory stamps a permanent certification into the blockchain ledger. Etherscan link is framed as "Factory certification of record." |
| **itch page description** | The short description ("Build factories where your own mouse cursor is the raw material.") leads with the theme. |
| **Trailer / cover art** | Factory grid with amber/magenta glow; cover title uses a riveted-plate typeface feel (via Figma). |

### Level-naming plan (10 levels = 10 machines, each teaches something new)

| Lvl | Name | Concept taught | Parts introduced |
|---|---|---|---|
| l01 | Conveyor | Emitter → Target in straight line | Emitter, Target, Wall |
| l02 | Press | 90° routing | Deflector |
| l03 | Forge | Two targets in sequence | Multiple targets |
| l04 | Refinery | Split one stream into two | Splitter |
| l05 | Lathe | Acceleration for long runs | Speed Modifier (×2) |
| l06 | Kiln | Slow a cursor down for tight routing | Speed Modifier (×0.5) |
| l07 | Foundry | Jump across obstacles | Teleporter pair |
| l08 | Assembly | Full combo: split + teleport + deflect | All 7 parts used |
| l09 | Reactor | Optimize — "beat par" with 4 targets, tight budget | All parts; emphasize `par_cursors` |
| l10 | Cyclotron | Multi-emitter, multi-teleporter maze | 2 emitters, 3 teleporters, 4 targets |

### Theme-fit verification checklist (Day 7 pre-submit)

Before submitting, every item below must pass:
- [ ] Every level's `name` field is a machine from the list above.
- [ ] Short description on itch page opens with a machine word.
- [ ] Cover art shows recognizable factory/industrial imagery.
- [ ] Tutorial uses the word "machine", "factory", or "fuel" at least 3 times.
- [ ] Credits page thanks "the machines that built this game" (HF MCP, Godot, etc.) — meta joke.
- [ ] `THEME.md` in repo root states all 4 theme interpretations for judges browsing source.
- [ ] Itch page tags include `machines` and `factory` alongside technical tags.

### Stand-in theme justification (paste verbatim into jam submission form)

> **Pointerworks is "Machines" four times over:**
>
> 1. **The factory is the machine** — every level is a literal machine you assemble from Emitters, Deflectors, Splitters, and Targets on a grid.
> 2. **The player is the machine's fuel** — your real mouse cursor is the raw material the factory consumes; no cursor movement = no output.
> 3. **The browser is the machine** — the mouse-cursor-as-fuel mechanic only works on a desktop browser, so the game uses the platform itself as a machine part.
> 4. **Debugging is gameplay** — the BUILD → RUN → FAIL → BUILD loop turns the player into a mechanical engineer iterating on a factory line.
>
> Built in 7 days with Godot 4.6; qualifies for Open Source (MIT, public GitHub) + Ethereum (Sepolia on-chain level completions).

## Architecture summary

- **Engine:** Godot 4.6, **GL Compatibility** renderer (already set), **3D removed** (Jolt 3D physics line stripped from `project.godot`), 60 Hz deterministic `_physics_process` sim.
- **Input:** `get_global_mouse_position()` per frame — cursor is *not* captured or hidden.
- **Node hierarchy (core scene):**
  ```
  Level (Node2D)
   ├── Grid (GridSystem)   ← dictionary<Vector2i, Part>
   ├── PartsContainer      ← Part instances
   ├── CursorSystem        ← spawns/despawns VirtualCursor (Area2D)
   ├── PhaseController     ← FSM: BUILD → RUN → WIN
   └── HUD (CanvasLayer)   ← PartPalette, RunStopButton, WinDialog
  ```
- **Autoloads:** `SceneSwitcher`, `Progress` (ConfigFile at `user://save.cfg`), `AudioBus`, `Web3Bridge` (stub only; populate post-jam).
- **Level data:** custom `Resource` class `LevelResource` (`.tres`), type-checked in inspector.
- **Parts (7 for jam, down from 10):** Emitter, Target, Wall, Deflector, Splitter, Speed Modifier, Teleporter. Deferred post-jam: Multiplier, Delay Gate, Merge Gate.
- **Levels:** **10 levels** (8 by Day 3 + 2 more on Day 6).
- **Art:** flat vector — `Polygon2D` + `Line2D`, one `grid_glow.gdshader`, 6-color palette. No sprite-pack dependency.
- **Audio:** 5 SFX + 1 music loop. Generated via Hugging Face MCP (primary) with sfxr/BeepBox as fallbacks. Three buses (Master/Music/SFX).

## Open Source challenge integration (free)

- Repo is **public** at https://github.com/MozeeB/Pointerworks from Day 1.
- Day 1 wiring:
  ```
  cd /Users/mujibnoctua/Documents/CikupProjects/machines-game
  git init
  git remote add origin git@github.com:MozeeB/Pointerworks.git
  git branch -M main
  # (after first commit) git push -u origin main
  ```
- Add **`LICENSE`** (MIT) + comprehensive `README.md` for judge Stacey Haffner to review.
- Repo must be readable: small files, feature-folder organization, no dead code at submission.

## Art / animation / sprites / tileset / background strategy

Every pixel is accounted for; zero dependency on third-party asset packs.

### Background
- Viewport-filling `ColorRect` with dark-navy fill (`#0E1320` suggestion).
- **One shader** `shaders/grid_glow.gdshader` (canvas_item, GL-compat, ~15 lines of GLSL) renders a subtle glowing grid — procedural, no texture needed.
- No parallax, no skybox, no background tilemap.
- **Effort:** ~45 min total for the shader + tuning.

### Tileset
- **No traditional TileSet resource.** Grid is drawn by the shader. Wall parts are individual `Polygon2D` instances with a subtle border.
- If a future update needs richer tiles, a `TileSetAtlasSource` with 2 tiles (floor, wall) can be added in <1 hr — not in jam scope.

### Sprites (parts & cursor)
- **7 part sprites** — all `Polygon2D` + optional `Line2D` outline. Hand-drawn in Godot's polygon editor at 64×64 cell size. Each part ~10-vertex polygon. Uniform 4 px inset from cell edge.
- **Virtual cursor sprite** — 12 px arrow `Polygon2D` with a `Line2D` trail child (gradient alpha, 8-point trail, length ~60 px).
- **Real OS cursor** — not overridden. Browser's default pointer is our player.
- **Palette discipline** — all Polygons reference named colors from `scripts/util/color_palette.gd`:
  - `BG_DARK` = `#0E1320`
  - `FG_LIGHT` = `#F2F0E9`
  - `EMITTER_AMBER` = `#E8A53A`
  - `CURSOR_MAGENTA` = `#D946B3`
  - `TARGET_CYAN` = `#3AD4D6`
  - `WALL_GREY` = `#4A5060`
- **Effort:** ~8 min per part × 7 parts + 5 min cursor = **~1 hr total**.
- **Optional MCP assist:** call Game Asset Generator MCP with prompt *"flat vector factory part, top-down icon, amber color, 6-color minimal palette"* → use the output as reference only; recreate in Godot as `Polygon2D` to keep bundle tiny.

### Animations
All via **`Tween`** (Godot 4.6 native) or **shader** — **no `AnimationPlayer` nodes**, **no sprite-frame animation**.

| Element | Type | Notes |
|---|---|---|
| Part place pop-in | `Tween` scale 0.0 → 1.1 → 1.0, 0.18 s, `EASE_OUT_BACK` | Triggered in `Part._ready()` or by GridSystem. |
| Part remove shrink | `Tween` scale → 0.0 + alpha fade, 0.12 s | Triggered before `queue_free()`. |
| Virtual cursor trail | `Line2D` with gradient alpha | No animation node — passive visual. |
| Target pulse | `shaders/target_pulse.gdshader` — `sin(TIME)` modulates glow alpha | Pure shader, no CPU cost. |
| Target hit flash | `Tween` brightness → white → back, 0.15 s | One-shot. |
| Run button press | CSS-like — `Tween` button scale 1.0 → 0.95 → 1.0, 0.1 s | Juice. |
| Win dialog fade-in | `Tween` alpha 0 → 1 + `EASE_OUT`, 0.3 s | CanvasLayer container. |
| Level complete screen-shake | `Tween` Camera2D offset with `EASE_OUT`, 8 px, 0.15 s | One-shot on win. |
| Main menu title idle | `Tween` looping, sin-wave Y offset ±3 px, 2 s cycle | Subtle juice. |

**Effort:** ~2 hrs across Day 2 (build phase + win dialog) and Day 3 (polish pass).

### Cover image & itch media

#### itch.io cover image — spec & requirements

The **cover image is used whenever itch.io links to the project from elsewhere on the site** (browse pages, bundle cards, recommendations, "more like this", creator page, search results). It is the single most important piece of marketing art we ship — often the *only* art a potential player sees before clicking in.

**Spec (authoritative — from itch.io project edit page):**

| Field | Value |
|---|---|
| **Required** | Yes (upload on Day 7 before going public) |
| **Minimum dimensions** | 315 × 250 px |
| **Recommended dimensions** | **630 × 500 px** (2× retina of the minimum) |
| **Aspect ratio** | 63:50 (≈ 1.26:1) — essentially a slightly wider-than-5:4 landscape rectangle |
| **Format** | PNG (preferred) or JPG |
| **File size cap** | 3 MB (itch.io hard limit); target ≤500 KB for fast load |
| **Color space** | sRGB |
| **Canonical output path** | `docs/cover.png` (committed to repo so judges can find it) |

**Design rules (must-follow):**

- **Use the 6-color palette** — `BG_DARK #0E1320` (background), `EMITTER_AMBER #E8A53A` (focal glow), `CURSOR_MAGENTA #D946B3` (trails/arrows), `TARGET_CYAN #3AD4D6` (highlight), `WALL_GREY #4A5060` (structure), `FG_LIGHT #F2F0E9` (title type only if on-image text is used).
- **Show gameplay, not a logo** — itch thumbnails at small sizes lose detail. A recognizable gameplay tableau (emitter → deflector → splitter → targets, with magenta cursor trails) reads better than abstract title art.
- **Title text is optional** — if added, keep it to the word "Pointerworks" in the top-left or bottom-center; minimum text height 48 px (so it's still readable at 315 × 250).
- **Readable at 315×250** — design at 630×500, then view the downscaled version. If key elements become mud, simplify.
- **No text-heavy compositions** — tagline/short-description is shown *next to* the cover on itch; repeating it on the cover wastes space.
- **Safe area** — keep vital content within the inner 90% (31 px margin all sides at 630×500). itch may crop edges for certain placements.
- **No gradients requiring >6 bands** — stick to flat vector style; JPEG compression artifacts are ugly on smooth gradients.

**Composition (the canonical cover we're producing):**

A 630×500 canvas with:
- Dark-navy `BG_DARK` background with a subtle grid-glow shader motif (not the full game shader — a simplified version baked into the image).
- Center-left: 1 amber emitter tile with a magenta cursor arrow exiting it, trailing into a 90° deflector.
- Center-right: a splitter forking the magenta trail into 2 cyan targets lighting up.
- Top-left or bottom-center: "Pointerworks" word-mark (riveted-plate feel, `FG_LIGHT` on dark).
- No UI, no palette, no buttons — the cover is a *screenshot of the concept*, not a screenshot of the HUD.

**Authoring workflow (Day 7 midday):**

1. **Attempt via Hugging Face MCP first** (~10 min) using the prompt already in Day 7 checklist; evaluate the output at 630×500 AND at 315×250 downscale.
2. **If HF output is off-brand** (wrong palette, wrong composition, too AI-busy), fall back to **Figma** — compose in Figma Desktop with the 6 palette swatches pre-loaded, export as 630×500 PNG. Budget: 45 min.
3. **Last-resort fallback:** take an in-engine screenshot during RUN phase, crop to 630×500 in Preview.app, overlay "Pointerworks" word-mark in Figma. Budget: 15 min; guaranteed on-brand.
4. **Verify at small size**: open `docs/cover.png` at 50% zoom — does it still read? If not, simplify and re-export.
5. **Commit `docs/cover.png`** + update `README.md` to embed it: `<img src="docs/cover.png" alt="Pointerworks cover" width="630">`.

**Alternate sizes & placements (itch auto-generates most, but the *source* cover matters):**

| Placement | itch behavior |
|---|---|
| Browse-page thumbnail | Downscales cover to ~315×250; need legibility at that size |
| Bundle card / "more like this" | Crops cover to wider aspect in some layouts; keep focal content centered |
| Creator page grid | Displays 315×250 crop |
| Open Graph / Twitter card | itch uses cover as og:image — what Twitter shows when the URL is shared |
| Jam submission card | Displayed at ~315×250 on jam pages — judges scanning 200+ entries see this at a glance |

A strong cover is therefore worth >30 min of polish; it's the first filter between the game and its audience.

#### Other itch media

- **3 in-game screenshots** (1280×720, PNG, each ≤500 KB) — captured from the running game: (1) BUILD phase with palette visible, (2) RUN phase with magenta cursor trails mid-flight, (3) WIN dialog with ⭐ par-cursors rating. itch shows screenshots as a carousel under the embedded game.
- **30 s gameplay GIF** (640 wide, 15 fps, ≤5 MB) — QuickTime screen record → `ffmpeg -i x.mov -vf "fps=15,scale=640:-1" docs/trailer.gif`. itch embeds GIFs inline; autoplay is effectively a video preview.
- **60 s MP4 trailer** (1280×720, H.264, ≤8 MB) — for Twitter/BlueSky announcement + potential YouTube upload. Higher fidelity than GIF, but itch.io itself does not embed MP4 (only YouTube/Vimeo embeds). Command: `ffmpeg -i in.mov -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p -c:a aac -b:a 128k docs/trailer.mp4`.
- **All media committed to `docs/`** so the GitHub repo is self-contained — judges can see the cover, screenshots, and GIF without visiting itch.

## Design & art tooling — MCP stack

### Already connected (confirmed by user 2026-04-16)

1. **Godot MCP** (`@coding-solo/godot-mcp`) — programmatic scene + node creation, `run_project`, `get_debug_output`. Iteration engine for all 7 days. *(Verified in `~/.claude/settings.json`.)*
2. **Figma MCP** — for UI mockups. *User-confirmed connected.* Use Day 3 evening — main menu layout + win dialog layout. Free tier gives 6 tool calls/month — plenty for 2 UI screens.
3. **Hugging Face / Game Asset Generator MCP** — for cover image + concept references. *User-confirmed connected.* Use Day 1 for concept refs on the 7 parts; Day 4 for the 630×500 itch cover.

### Tier 2 — skip for this sprint

- ~~PixelLab MCP~~ — only useful for pixel art; we are flat vector.
- ~~fal-ai MCP~~ — paid, not needed for jam quality.

### Day 1 pre-flight (MCP smoke tests, ~10 min total)
Before real work starts, verify each MCP responds:
- **Godot MCP** → `run_project` on the empty project, expect success + empty debug output.
- **Figma MCP** → list files in the default team, confirm 1+ of the 6 monthly tool calls is still available.
- **Hugging Face MCP** → generate a tiny test asset (any prompt), confirm no auth errors.
If any MCP fails, fall back to hand-authored assets in Godot for that channel — do NOT spend Day 1 hours troubleshooting MCP auth.

### Decision rule
If a connected MCP saves >30 min on an asset → use it. Otherwise, hand-draw Polygon2D in Godot.

## Audio tooling — MCP stack (free only)

**Goal:** 5 SFX (~0.5 s each) + 1 music loop (20-30 s), total audio budget **<600 KB** compressed OGG.

### Primary — Hugging Face MCP (already connected)
Runs open-source audio models as HF Inference endpoints or Spaces. **Free** under the user's existing HF token.

| Need | Model | Rough call |
|---|---|---|
| Music loop (factory ambient, chippy, 20-30 s) | **`facebook/musicgen-small`** (or `musicgen-melody` if we want a motif) | prompt: *"loopable 24-second chiptune factory ambient loop, 110 BPM, minor key, industrial clanks, no drums on the downbeat so it loops cleanly"* |
| SFX bursts (spawn / deflect / hit_target / win / place_part) | **`cvssp/audioldm2`** or **`stabilityai/stable-audio-open-1.0`** (SA-Open is royalty-free, permissive license) | prompt examples: *"short digital pop, rising pitch, 0.3 s"*, *"metallic clank, short reverb, 0.25 s"*, *"ascending arpeggio success chime, 0.8 s"* |

**Post-processing:** All MCP-generated audio → trim silence → normalize to -3 dBFS → export OGG Vorbis q2. One-liner: `ffmpeg -i in.wav -af "silenceremove=start_periods=1:start_silence=0.05,loudnorm=I=-16:LRA=11:TP=-1.5" -c:a libvorbis -q:a 2 out.ogg`.

**License note:** MusicGen / AudioLDM2 outputs are usable under their model licenses (CC-BY-NC for MusicGen — **non-commercial**, which is fine for the jam since we're not selling). Stable Audio Open 1.0 is permissive (check per-use). Log the exact model + prompt in `CREDITS.md`.

### Backup — Freesound MCP (community) or direct API
If HF outputs disappoint or license concerns arise: **[Freesound.org](https://freesound.org/)** has 500k+ CC-licensed sounds (many CC0). Community MCPs exist (e.g. `freesound-mcp`); otherwise call via `WebFetch` using the free API key. Use CC0 / CC-BY sounds only; record attribution in `CREDITS.md`.

### Fallbacks (no MCP, fastest path)
- **[sfxr.me](https://sfxr.me/)** — 2-minute browser tool for retro bleep/bloop SFX. If HF generates weird artifacts, sfxr is the known-good bail-out.
- **[BeepBox](https://beepbox.co/)** — browser chiptune composer, 10-15 min to author a clean loop. Known-good bail-out for music.

### Not using (paid or out-of-scope)
- ~~ElevenLabs MCP~~ — high quality but 10k credit/month free cap is tight if we iterate; skip unless HF fails on SFX.
- ~~Suno / Udio~~ — no stable MCP, music licensing unclear for jam submission.
- ~~fal-ai audio~~ — paid.

### Decision rule (audio)
1. **Music:** HF MusicGen first. If bad after 3 prompt iterations or takes >30 min → switch to BeepBox.
2. **SFX:** Try HF AudioLDM2 / Stable Audio Open for 2 of the 5 SFX (the ones most important — `hit_target` and `win`). Use sfxr for the other 3 (`spawn`, `deflect`, `place_part` — retro chippy pops suit sfxr).
3. **Do not block on audio.** If any tool stalls Day 3 afternoon by >45 min, drop it and bail to the fallback. Polish > perfect audio for a jam build.

## Markdown docs inventory (prevent context loss across sessions)

Create these on **Day 1** (before first real code) so future sessions have full context without re-onboarding. All live at repo root unless noted.

| File | Purpose | When updated |
|---|---|---|
| **`README.md`** | Public-facing. Concept pitch, controls, build/run, credits, itch link, GitHub link, license. | Day 1 (stub) → Day 4 (polished). |
| **`CLAUDE.md`** | **AI agent context.** Project goals, tech stack, conventions, directory map, "do this / don't do this" rules, current sprint day, known dragons. Lets any future Claude session resume without re-exploration. | Day 1 (full) → update at end of each day with day-summary line. |
| **`DEVLOG.md`** | Daily journal. 2-5 lines per day: what shipped, what was cut, next blocker. | Every end-of-day. |
| **`PARTS.md`** | Reference sheet for the 7 parts: name, mechanic, inputs/outputs, visual spec, sound. | Day 1 (stub) → Day 2 (after each part lands). |
| **`LEVELS.md`** | Level design notes — intended solution path + cheese paths + par cursors per level. Helps balance + debug. | Day 2 (after first levels) → Day 3. |
| **`CREDITS.md`** | Attribution: HF models (MusicGen / AudioLDM2), Figma, sfxr, BeepBox (if fallback used), Godot, ethers.js, Foundry. | Day 1 stub → Day 7 polish. |
| **`ISSUES.md`** | Known bugs + workarounds. P0/P1/P2 priority tagging. | Day 4 onward. |
| **`LICENSE`** | MIT. Not `.md` but required for Open Source challenge. | Day 1, never changes. |
| **`docs/ART.md`** | Palette hex codes, part visual spec, shader list, animation catalog. Prevents drift if polishing in parallel to coding. | Day 2 after first parts. |
| **`docs/GAME_FLOW.md`** | Copy of the "Detailed game flow" section from this plan. Single source of truth for FSMs and edge cases — update alongside code changes. | Day 1 initial copy → updated Day 4 (gaps closed) + Day 5 (Ethereum flow). |
| **`docs/PLAN.md`** | **Repo copy of the source-of-truth plan** (this document). Shipped in the repo so judges + future Claude sessions can read it. | Day 1 initial copy from `~/.claude/plans/parallel-jingling-river.md` → re-synced at every EOD + every mid-task checkpoint. |
| **`THEME.md`** | Four-layer explanation of how Pointerworks answers the "Machines" theme. Written for jam judges browsing the repo. Copy of this plan's Theme section. | Day 1 (copy from plan) → Day 7 (polish with final level names + screenshots). |

**CLAUDE.md template (Day 1 content):**
```markdown
# Pointerworks — Claude Agent Context

## ⚠️ Source of Truth
**Read `docs/PLAN.md` FIRST before any work.** That file is the single source of truth:
scope, schedule, FSMs, tool choices, theme, risks, edge cases. This file (`CLAUDE.md`)
only summarizes + points to it. If they conflict, `docs/PLAN.md` wins.

## What this is
Gamedev.js Jam 2026 entry. Theme: Machines. HTML5 puzzle game built in Godot 4.6.
Core mechanic: the OS mouse cursor is the "working fluid" of grid-based machines.
Full theme rationale in `THEME.md`. Full game flow in `docs/GAME_FLOW.md`.

## Tech stack
- Godot 4.6, GL Compatibility renderer, 2D only (3D stripped).
- GDScript. No C# or GDExtension.
- Web export target (non-threads variant).
- Levels stored as `.tres` custom Resources, not JSON.

## Sprint
7-day sprint, Apr 16 → Apr 22 2026. See `DEVLOG.md` for current day status.

## Conventions
- Many small files: 200-400 lines typical, 800 hard cap.
- Feature-folder organization (scripts/parts/*, scripts/level/*, etc.).
- Immutable data patterns — return new copies, don't mutate.
- Signals for cross-node communication; autoloads only for truly global state.
- No AnimationPlayer nodes — Tween only.
- Colors come from `scripts/util/color_palette.gd` — no hex literals in game code.

## DO NOT
- Add GPUParticles2D (GL Compatibility issues on web).
- Use threads-variant web export (COOP/COEP hosting pain).
- Pull in sprite asset packs (keeps bundle <15 MB).
- Add AnimationPlayer — use Tween.
- Ship Ethereum as *required* — it must be 100% skippable (offline players must still finish the game).

## Directory map
scripts/autoload/  — SceneSwitcher, Progress, AudioBus, Web3Bridge, Settings
scripts/level/     — GridSystem, VirtualCursor, PhaseController, WinChecker, LevelLoader, FailChecker
scripts/parts/     — Part base + 7 part subclasses
scripts/ui/        — MainMenu, LevelSelect, HUD, PartPalette, WinDialog, PauseMenu, SettingsDialog, TutorialOverlay, DesktopOnlyBlocker
scripts/data/      — LevelResource, PartPlacement, PartData
scripts/web3/      — web3_bridge, ethers_glue.js (included as HTML5 custom JS)
data/levels/       — l01.tres … l10.tres
contracts/         — PointerworksAchievements.sol, foundry.toml (Day 5)
shaders/           — grid_glow, target_pulse
audio/             — sfx/*.ogg, music/factory_loop.ogg

## Known dragons
- `get_global_mouse_position()` returns canvas coords, not window — safe.
- Browsers pause audio until first click; music starts on PlayButton press.
- `user://save.cfg` on web is backed by localStorage — 5 MB hard cap (fine for us).
```

## Gap audit — what a "complete" jam game needs

A shorter plan would ship these as "post-jam stretch" — with 7 days we fold them in. Each item below is tied to the day that closes it.

| # | Gap | Why it matters | Closed by |
|---|---|---|---|
| 1 | **FAIL state** — if player hits RUN and cursors miss targets, nothing happens except they time out. | Without explicit fail feedback, players think the game is broken. | Day 4 — `FailChecker`: when all virtual cursors die with any target unhit → show "Machine failed — missed X targets" banner + Retry button + auto-return to BUILD. |
| 2 | **Pause menu (Esc)** — no way to pause mid-level. | Standard expectation; judges playing in a browser need Esc to escape without leaving the tab. | Day 4 — `scripts/ui/pause_menu.tscn`: Resume / Restart / Settings / Back to Menu. |
| 3 | **Settings dialog** — no volume control, no fullscreen toggle. | Browser auto-play policy + judge's muted Slack call means first-run audio is jarring; slider required. | Day 4 — `scripts/ui/settings_dialog.tscn`: Master/Music/SFX sliders, fullscreen toggle, colorblind-palette toggle. Persisted via `Settings` autoload (`user://settings.cfg`). |
| 4 | **Tutorial / first-run onboarding** — l01 tooltip exists but no holistic "here's how this game works" moment. | Jam judges give <2 min; if they don't understand the mechanic they rate "innovation" low. | Day 4 — non-skippable 15 s animated tutorial overlay on first launch: shows cursor spawning from emitter, routing through deflector, hitting target. Skippable on replay via `Progress.seen_tutorial`. |
| 5 | **Desktop-only blocker** — mobile users load the game and get a broken experience. | itch.io "mobile OFF" hides from mobile storefront but the direct URL still serves; need an in-game blocker. | Day 4 — `DesktopOnlyBlocker` screen on `_ready` if `OS.has_feature("mobile")` or `touch`: "Pointerworks requires a mouse. Visit on desktop." |
| 6 | **Reset level button (in-game during BUILD/RUN)** — currently only reachable via win dialog. | Players will experiment and want to wipe the grid. | Day 2 — add "Clear" button to HUD palette panel, confirms with tween highlight. |
| 7 | **Keyboard shortcuts** — only `R` for rotate exists. | Power-users + speedrunners; cheap to add. | Day 4 — `Space` = run/stop toggle, `Esc` = pause, `1-7` = select part, `Ctrl+Z` = undo last placement, `F11` = fullscreen. |
| 8 | **Undo last placement** — irreversible palette drags are punishing. | Small but felt quality-of-life win; one-step undo ring buffer. | Day 4 — `PhaseController` keeps 10-step undo stack of `PartPlacement` operations. |
| 9 | **Level rating (par cursors)** — `par_cursors` is defined on LevelResource but nothing displays it. | Re-playability hook; shows "beat par" in win dialog. | Day 3 — win dialog shows `actual_cursors_used / par_cursors` with a ⭐ if ≤ par. |
| 10 | **Cursor lifecycle polish** — virtual cursors currently appear/disappear abruptly. | Juice + clarity: players should see *why* a cursor died (off-grid, hit wall, TTL). | Day 3 — fade-out tween on despawn; red flash on wall/off-grid death; gentle dissolve on TTL expiry. |
| 11 | **Wall & grid-edge rules documented** — plan is ambiguous on collision behavior. | Prevents "is this a bug or design?" confusion. | Day 1 — in `scripts/level/virtual_cursor.gd`: cursor on Wall = die with red flash; cursor leaving grid = die with fade. Documented in `PARTS.md`. |
| 12 | **Multiple emitters per level** — allowed? constrained? | Level designer needs a rule. | Day 2 — **allowed**. Each emitter spawns independently, TTL prevents runaway. Documented in `LEVELS.md`. |
| 13 | **External playtest time** — Day 3 plan had a 15-min session; not enough. | Fresh eyes catch obvious bugs that authorial blindness hides. | Day 6 — full 45-min session with ≥2 testers (1 puzzle-genre fan, 1 non-gamer). Log findings in `ISSUES.md` with P0/P1/P2. |
| 14 | **More levels for variety** — 8 levels clears in ~15 min, short for judges. | Adds `par_cursors` rating replay value too. | Day 6 — add levels 9-10 (2 advanced levels combining 4+ parts). |
| 15 | **Save-file robustness** — no handling for corrupted / missing / version-mismatched save. | Web `localStorage` can get cleared, other tab can conflict. | Day 6 — `Progress.load()` wraps in `try/except`, resets to defaults with a "save reset" toast on corruption. Add a `version` key for future migrations. |
| 16 | **Ethereum challenge** — was deferred; now re-added. | Qualifies for a second prize pool. | Day 5 (full day). |
| 17 | **Itch page polish** — plan has checklist but no time for iteration. | First impression = cover + GIF + short description; worth 30+ min of styling. | Day 7. |
| 18 | **Deterministic-sim verification** — plan mentions "hash logged at RUN start" but no implementation. | Guards against physics regressions; also makes speedruns/Ethereum solution-hashing legitimate. | Day 1 — RUN start logs `hash(grid_state + seed)`; tracked in `DEVLOG.md` for each level. |
| 19 | **Error handling at resource boundaries** — missing `.tres`, bad JSON, save corruption. | Jam judges on older browsers or with extensions will hit edge cases. | Day 6 — wrap `load()` calls; show "Level failed to load" dialog instead of crashing. |
| 20 | **Trailer / proper screen-record** — plan has 30 s GIF but that's it. | A 60 s MP4 with music significantly boosts itch page CTR. | Day 7 — QuickTime record + `ffmpeg` 60 s MP4 in addition to the GIF. |

## 7-day sprint schedule

~5-7 hrs/day. All days assume completion + commit + push by EOD.

| Day | Date | Big goal | Exit gate |
|---|---|---|---|
| **1** | Apr 16 (today) | **Bootstrap + core mechanic**: project cleanup, folders, git+GitHub wiring, all 9 `.md` docs, GridSystem, VirtualCursor, 5 parts (Emitter/Wall/Target/Deflector/Splitter), test scene, wall/off-grid death rules. | Test scene: mouse over emitter → cursor routes through deflector + splitter → hits 2 targets. Cursor hitting wall dies with red flash. All 9 `.md` docs committed. |
| **2** | Apr 17 | **Remaining parts + build phase + 4 levels + clear button**: Speed Mod + Teleporter, phase FSM, palette drag-drop, clear button, win detection, LevelResource, 4 levels, 5 SFX pass, progress save. Multiple emitters supported. | 4 levels playable end-to-end in editor. Save/load works. Audio hooked. Clear button wipes grid during BUILD. |
| **3** | Apr 18 | **4 more levels + art polish + music + menus + cursor-death polish + par-cursors UI**: levels 5-8, grid shader, target pulse shader, main menu, win dialog with par-cursors ⭐, credits, HF MusicGen loop, Tween animations, cursor fade-out polish. | 8 levels playable, par-cursor ⭐ shown, game looks "finished" in screenshots. |
| **4** | Apr 19 | **UX gaps closed**: FAIL state + fail banner, Pause menu (Esc), Settings dialog (volume/fullscreen/colorblind), Tutorial overlay (first-run), Desktop-only blocker, full keyboard shortcut set, 10-step undo. | Complete user journey: first-run → tutorial → main menu → settings → level → pause → fail → retry → win → next. All 7 gap items (#1-8) verified. |
| **5** | Apr 20 | **Ethereum challenge**: Solidity contract (`PointerworksAchievements`), Foundry deploy to Sepolia, `JavaScriptBridge` + ethers.js v6 glue, "Connect Wallet" button in main menu, on-chain `LevelCompleted` event from win dialog, **100% skippable** path for non-crypto players. | Wallet connect + level completion TX visible on Sepolia block explorer. Game still fully playable with wallet disconnected. |
| **6** | Apr 21 | **Robustness + playtest + +2 levels**: save-file hardening (try/except + version key), resource-load error dialogs, external 45-min playtest with 2 testers, fix P0/P1 issues from `ISSUES.md`, author levels 9-10. | Playtest report logged. P0/P1 bugs fixed. 10 levels total, all beatable. |
| **7** | Apr 22 | **Web export + media + itch + submission**: export, bundle-size check, Claude Preview + 3-browser test, capture screenshots + GIF + 60 s MP4, cover image (HF MCP), polish itch page, finalize README, **SUBMIT TO JAM**. | Submission confirmation email from itch.io. Both side-challenge tickboxes filled. |

**Checkpoint gates (hard):**
- **End of Day 1:** if the cursor mechanic doesn't work in a test scene, stop and debug — do not proceed to Day 2. The mechanic is the whole game.
- **End of Day 2:** if 4 levels aren't playable end-to-end with build + run phases, trim parts list further (drop Speed Mod or Teleporter) to recover Day 3 for polish.
- **End of Day 3:** if game doesn't look/feel "shippable" in screenshots, cut level count from 8 to 6 and use Day 4 extra time for polish.
- **End of Day 4:** if UX gaps aren't closed, delete Ethereum from Day 5 and move Day 5 to Day 4 overflow. Polish > side challenge.
- **End of Day 5:** if Ethereum hasn't deployed + round-tripped a test TX by EOD, **bail cleanly** — revert `web3_bridge` to a stub, remove "Connect Wallet" button, skip Ethereum challenge tickbox. Do not let Ethereum block submission.
- **End of Day 6:** if playtest surfaces P0 bugs, Day 7 morning is dedicated to fixing them before any submission work.

## Detailed daily workflow (7 days, step-by-step)

### Pre-flight (one-time, ~15 min before Day 1 starts)
- [ ] Confirm Godot 4.6 launches from `/Applications/Godot.app`.
- [ ] Confirm Web export template installed: Godot → Editor → Manage Export Templates → ensure "Web" is listed for 4.6.
- [ ] Install butler: `brew install butler && butler login`.
- [x] ~~Figma MCP connected~~ — **DONE** (user-confirmed 2026-04-16).
- [x] ~~Hugging Face / Game Asset Generator MCP connected~~ — **DONE** (user-confirmed 2026-04-16).
- [ ] MCP smoke-test trio (Godot + Figma + HF): see "Day 1 pre-flight (MCP smoke tests)" in Design & art tooling section. ~10 min.

### Day 1 — Apr 16 — Bootstrap + core mechanic
**Target hours:** 6-7. **End state:** cursor mechanic works end-to-end in a test scene.

**Morning — Infrastructure (~2 hr):**
- [ ] **Clean `project.godot`**:
  - Remove `[physics] 3d/physics_engine="Jolt Physics"`.
  - Add `[application] run/main_scene="res://scenes/main.tscn"`.
  - Add `[display] window/size/viewport_width=1280`, `viewport_height=720`, `window/stretch/mode="canvas_items"`, `window/stretch/aspect="keep"`.
  - Add `[autoload]` with `SceneSwitcher`, `Progress`, `AudioBus`, `Web3Bridge` (stub).
  - Add `[rendering] textures/canvas_textures/default_texture_filter=0`.
- [ ] **Create folders**: `scripts/{autoload,data,level,parts,ui,util}`, `scenes/{ui,level,parts,dev}`, `data/levels`, `shaders`, `audio/{sfx,music}`, `docs`.
- [ ] **Repo wiring**:
  ```
  cd /Users/mujibnoctua/Documents/CikupProjects/machines-game
  git init && git remote add origin git@github.com:MozeeB/Pointerworks.git && git branch -M main
  ```
- [ ] **Copy this plan file to `docs/PLAN.md`** — `cp ~/.claude/plans/parallel-jingling-river.md docs/PLAN.md`. This is THE source of truth; ships with repo; first file any future Claude session should read.
- [ ] **Create all 11 Markdown docs** (stubs are fine; `CLAUDE.md`, `THEME.md`, `docs/GAME_FLOW.md`, `docs/PLAN.md` must be full):
  - `README.md`, `CLAUDE.md` (full template above — must reference `docs/PLAN.md` as source of truth), `DEVLOG.md` (one Day 1 entry), `PARTS.md` (table header + 7 blank rows), `LEVELS.md` (header + 10 level-name rows from Theme section), `CREDITS.md` (Godot, HF models, Figma), `ISSUES.md` (empty list), `THEME.md` (copy of Theme section), `docs/ART.md` (palette hex + animation catalog from this plan), `docs/GAME_FLOW.md` (copy of "Detailed game flow" section), `docs/PLAN.md` (cp from `~/.claude/plans/parallel-jingling-river.md`).
- [ ] **Create `LICENSE`** (MIT, current year, user's name).
- [ ] **Create `.gitignore`**: `.godot/`, `build/`, `*.tmp`, `.DS_Store`, `export_presets.cfg`, `.env`, `contracts/out/`, `contracts/cache/`, `contracts/broadcast/`.
- [ ] **Autoload stubs**: 4 files `scripts/autoload/{scene_switcher,progress,audio_bus,web3_bridge}.gd`, each `extends Node` + a one-line comment describing purpose.
- [ ] **Scene stubs**: `scenes/main.tscn` (PlayButton), `scenes/ui/level_select.tscn` (Label + 1 button), `scenes/level/level.tscn` (Node2D).
- [ ] **First commit + push**: `git add -A && git commit -m "feat: bootstrap Pointerworks + docs skeleton" && git push -u origin main`.

**Midday — Grid + cursor + 3 parts (~2.5 hr):**
- [ ] **`scripts/util/color_palette.gd`** — 6 named colors.
- [ ] **`scripts/data/part_data.gd`** (Resource) — `type`, `color`, `rotation_steps`.
- [ ] **`scripts/level/grid_system.gd`** — `TILE_SIZE=64`, `world_to_cell`, `cell_to_world`, `snap`, `get_part_at`, `place_part`, `remove_part`, signals.
- [ ] **`scripts/parts/part.gd`** — base class (`@export data`, `cell`, `apply_to_cursor`, `on_real_mouse_enter/exit`, `rotate_cw`).
- [ ] **`scripts/level/virtual_cursor.gd`** — Area2D + velocity + TTL + Line2D trail.
- [ ] **`scripts/parts/{emitter,wall,target}.gd`** + `scenes/parts/{emitter,wall,target}.tscn`.
- [ ] **`scenes/dev/part_test.tscn`** — hand-place 1 emitter + 1 target, cursor routes left→right.
- [ ] **MCP verify:** `run_project` → hover emitter → see cursor spawn → hit target → "HIT" in debug output.
- [ ] Update `PARTS.md` with first 3 filled rows.
- [ ] Commit `feat: grid + virtual cursor + emitter/wall/target`.

**Afternoon — Deflector + Splitter (~2 hr):**
- [ ] **`scripts/parts/deflector.gd`** — 90° rotation based on `rotation_steps`.
- [ ] **`scripts/parts/splitter.gd`** — consume input, spawn 2 perpendicular cursors.
- [ ] Extend `part_test.tscn` to a 2-target chain with splitter + 2 deflectors.
- [ ] **MCP verify:** chain solves reliably across 10 consecutive runs.
- [ ] Update `PARTS.md` with 2 more rows.
- [ ] Update `DEVLOG.md` + `CLAUDE.md` "current sprint day".
- [ ] Commit `feat: deflector + splitter` + push.

**Exit gate Day 1:**
- Test scene with 5 parts works end-to-end.
- [github.com/MozeeB/Pointerworks](https://github.com/MozeeB/Pointerworks) green on `main`.
- All 10 `.md` docs exist with meaningful content (incl. `THEME.md`).

### Day 2 — Apr 17 — Remaining parts + build phase + 4 levels
**Target hours:** 6-7. **End state:** 4 levels playable with drag-drop palette.

**Morning — Speed Mod + Teleporter (~1.5 hr):**
- [ ] **`scripts/parts/speed_mod.gd`** — ×0.5 / ×2.0 variants on pass-through.
- [ ] **`scripts/parts/teleporter.gd`** — paired tiles, preserve velocity on exit.
- [ ] Extend `part_test.tscn` with test rows for both.
- [ ] Update `PARTS.md`.

**Midday — Phase controller + palette + win check (~3 hr):**
- [ ] **`scripts/data/level_resource.gd`** + **`part_placement.gd`** custom Resources.
- [ ] **`scripts/level/phase_controller.gd`** — FSM `{BUILD, RUN, WIN}`.
- [ ] **`scripts/ui/hud.gd`** + `scenes/ui/hud.tscn` — palette panel, run/stop button, win dialog placeholder.
- [ ] **`scripts/ui/part_palette.gd`** — drag-drop from palette to grid cell; right-click removes; `R` rotates.
- [ ] **`scripts/level/win_checker.gd`** — monitors `"targets"` group.

**Afternoon — 4 levels + save system + audio pass (~2.5 hr):**
- [ ] **Design 4 levels on paper** (5 min each — minimal grid sketches).
- [ ] **Author** `data/levels/l01.tres` through `l04.tres` — progression: emitter-only → deflector → splitter → splitter+teleporter.
- [ ] **`scripts/ui/level_select.gd`** — lists `l01..l08` buttons; locked if `Progress.is_unlocked()==false`.
- [ ] **`scripts/autoload/progress.gd`** — `ConfigFile` at `user://save.cfg`.
- [ ] **Generate 5 SFX** per Audio tooling decision rule: 2 via Hugging Face MCP (AudioLDM2 / Stable Audio Open) for `hit_target` + `win`; 3 via [sfxr.me](https://sfxr.me/) for `spawn` + `deflect` + `place_part`. Post-process all 5 via `ffmpeg` silence-trim + loudnorm + OGG Vorbis q2 (one-liner in Audio tooling section).
- [ ] **`scripts/autoload/audio_bus.gd`** with 8-player SFX pool + `default_bus_layout.tres` (Master/Music/SFX buses).
- [ ] Connect SFX in each part's signal.
- [ ] Update `LEVELS.md` + `DEVLOG.md` + `CLAUDE.md`.
- [ ] **First web export + Claude Preview harness (Day 2 EOD milestone):**
  - Configure Godot → Project → Export → Add Web (non-threads variant). Export With Debug OFF.
  - Headless build: `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release "Web" build/index.html`
  - Create `.claude/launch.json` with the `pointerworks-web` config (see Verification Cadence section for JSON).
  - `preview_start` → `preview_screenshot` → `preview_console_logs`. Save screenshot to `docs/preview-day-2.png`. Commit both `build/` (verify it's gitignored) and `.claude/launch.json` + screenshot.
- [ ] Commit `feat: build phase + 4 levels + audio + web export harness` + push.

**Exit gate Day 2:** 4 levels complete end-to-end in the editor run, palette works, audio plays, progress persists across scene reload. **Verify via Claude Preview:** first web export built + `preview_start pointerworks-web` boots main menu; `preview_console_logs` zero errors; `docs/preview-day-2.png` committed.

### Day 3 — Apr 18 — 4 more levels + art polish + menus + music
**Target hours:** 6-7. **End state:** feature-complete game, screenshot-ready.

**Morning — Levels 5-8 (~2 hr):**
- [ ] **Design levels 5-8 on paper** — these are the "combinations" tier. Should exercise 2-3 parts together.
- [ ] **Author** `data/levels/l05.tres` through `l08.tres`.
- [ ] Self-playtest each — confirm intended solution + check for cheese paths. Add `par_cursors` + `hint` strings.
- [ ] Update `LEVELS.md`.

**Midday — Art polish (~2.5 hr):**
- [ ] **`shaders/grid_glow.gdshader`** (canvas_item, ~15 lines, GL-compat).
- [ ] **`shaders/target_pulse.gdshader`** (canvas_item, sin-modulated alpha).
- [ ] Pass every Polygon2D through the 6-color palette (no stray hex literals).
- [ ] Add **Tween animations** per the table in §Art — place pop-in, remove shrink, win fade, title idle, button press, screen-shake.
- [ ] Create 5 in-level tooltip Labels for levels 1-3 explaining parts (fade in + dismiss on click).

**Afternoon — Menus + music (~2 hr):**
- [ ] **Figma MCP session (~30 min)**: prompt — "make a main menu for a dark-navy puzzle game called Pointerworks with a title, Play button, and credits link; use amber + magenta accents". Iterate once. Export SVG/description.
- [ ] **`scenes/ui/main_menu.tscn`** — implement layout in Godot Control nodes mirroring Figma output.
- [ ] **`scenes/ui/win_dialog.tscn`** — centered panel, level complete text, next-level button, retry button, back-to-menu button. Appears with Tween fade.
- [ ] **`scenes/ui/credits.tscn`** — scrolling text crediting sfxr, BeepBox, Godot, the Jam.
- [ ] **Generate music** via Hugging Face MCP (MusicGen-small, prompt in Audio tooling section) — 20-30 s seamless loop, chippy/industrial. If 3 iterations fail the vibe check, fall back to [BeepBox](https://beepbox.co/) (~15 min author time). Export WAV → OGG at <300 KB.
- [ ] **Hook music start** to first PlayButton click (autoplay compliance).
- [ ] Update `CREDITS.md` with all tools + music composer (user) + CC0 note if any.
- [ ] Update `DEVLOG.md` + `CLAUDE.md`.
- [ ] Commit `feat: 8 levels + art polish + music + menus` + push.

**Exit gate Day 3:** Loadable from main menu → pick a level → play it → win dialog → back. 8 levels all beatable. Screenshots look like a finished jam game. **Verify via Claude Preview:** scripted click path Main → L1 → Win via `preview_click`; `preview_screenshot` of RUN phase saved to `docs/preview-day-3.png`; `preview_console_logs` clean.

### Day 4 — Apr 19 — UX gap closure (tutorial, pause, settings, fail, blocker)
**Target hours:** 6-7. **End state:** every UX gap item #1-8 from the audit is closed, game feels complete to a fresh player.

**Morning — FAIL state + Pause + Reset (~2 hr):**
- [ ] **`scripts/level/fail_checker.gd`** — monitors cursor count + unhit-target count; when all cursors dead and any target unhit → emit `fail` signal with missed-target count.
- [ ] **HUD fail banner** — centered `PanelContainer` that fades in on `fail` signal: "Machine failed — missed X targets. [Retry] [Back]". Tween alpha 0→1 over 0.3 s.
- [ ] **Auto-return to BUILD** after 2 s if user does nothing; keep current grid layout.
- [ ] **`scripts/ui/pause_menu.tscn`** — CanvasLayer, `Esc` toggles; buttons: Resume / Restart Level / Settings / Back to Menu. `get_tree().paused = true` on open.
- [ ] **Process-mode audit** — confirm UI nodes have `process_mode = PROCESS_MODE_ALWAYS` so pause menu works.

**Midday — Settings + Tutorial + Desktop blocker (~2.5 hr):**
- [ ] **`scripts/autoload/settings.gd`** — `ConfigFile` at `user://settings.cfg`. Fields: `master_vol`, `music_vol`, `sfx_vol`, `fullscreen`, `colorblind_palette`. Signal `settings_changed` on mutation.
- [ ] **`scripts/ui/settings_dialog.tscn`** — 3 HSliders (0-1 float), 2 CheckButtons. Bind to `AudioServer.set_bus_volume_db(linear_to_db(...))`.
- [ ] **Colorblind palette variant** in `scripts/util/color_palette.gd` — when `Settings.colorblind_palette` is true, swap `EMITTER_AMBER`/`TARGET_CYAN` for a deuteranopia-safe pair (amber → blue `#2E7AE8`, cyan stays). All Polygon2Ds listen to `Settings.settings_changed` and re-fetch color.
- [ ] **`scripts/ui/tutorial_overlay.tscn`** — first-run only (check `Progress.seen_tutorial`). 15 s animated sequence using existing Tweens: panel slides in → demonstrates emitter + deflector + target → "Got it" button dismisses. Set `Progress.seen_tutorial = true`.
- [ ] **`scripts/ui/desktop_only_blocker.tscn`** — checked on `MainMenu._ready()`. If `OS.has_feature("mobile")` or `DisplayServer.is_touchscreen_available()` → show fullscreen panel: "Pointerworks requires a mouse. Please visit on desktop." Block further input.

**Afternoon — Keyboard shortcuts + Undo (~2 hr):**
- [ ] **Global input map** in `project.godot` (via InputMap API or direct edit): `pause` (Esc), `run_toggle` (Space), `rotate` (R), `undo` (Ctrl+Z), `fullscreen` (F11), `part_1` through `part_7` (1-7).
- [ ] **`scripts/ui/part_palette.gd`** — handle `part_1..7` to select palette slot; `run_toggle` calls `PhaseController.toggle()`; `fullscreen` calls `DisplayServer.window_set_mode(FULLSCREEN or WINDOWED)`.
- [ ] **Undo stack** in `PhaseController` — 10-entry ring buffer of `{op: "place"|"remove", cell: Vector2i, part_type: PartType}`. `undo()` reverses the last op. Cleared on phase transition.
- [ ] **Claude Preview smoke**: export a throwaway web build (bundle-check Day 7) → `preview_start` → scripted click path through tutorial → level → pause → settings → resume → win. Capture `preview_console_logs`.
- [ ] Update `DEVLOG.md` + `CLAUDE.md` + `ISSUES.md`.
- [ ] Commit `feat: fail state + pause + settings + tutorial + shortcuts + undo` + push.

**Exit gate Day 4:** A fresh user launching the game for the first time sees tutorial → dismisses → plays level → fails → sees fail banner → retries → wins. Esc pauses, settings sliders work, F11 fullscreens, mobile users see blocker. All 8 gap items #1-8 verified in a recorded Claude-Preview session.

### Day 5 — Apr 20 — Ethereum challenge integration
**Target hours:** 6-7. **End state:** connected wallet can submit level completions as on-chain TXs on Sepolia; skip path preserved for non-crypto players.

**Morning — Contract + deploy (~2.5 hr):**
- [ ] **Install [Foundry](https://book.getfoundry.sh/)**: `curl -L https://foundry.paradigm.xyz | bash && foundryup`.
- [ ] **Create `.env` (gitignored) + `.env.example` (committed)** with keys: `SEPOLIA_RPC` (Alchemy URL — sign up free at alchemy.com → create app → "Ethereum Sepolia"), `DEPLOYER_KEY` (throwaway private key, NEVER the user's real wallet), `ETHERSCAN_KEY` (sign up free at etherscan.io/apis). Verify `.env` is in `.gitignore` BEFORE pasting any key. Source with `set -a && . .env && set +a` before every `forge` command.
- [ ] **Init Foundry project** inside `contracts/`: `forge init --no-git contracts && cd contracts`.
- [ ] **Write `contracts/src/PointerworksAchievements.sol`**:
  - `mapping(address => uint256) public completedLevelBitmap` (bitmap of levels completed).
  - `mapping(address => mapping(uint8 => bytes32)) public solutionHash` (per-level deterministic solution hash).
  - `event LevelCompleted(address indexed player, uint8 indexed levelId, bytes32 hash, uint64 timestamp)`.
  - `function completeLevel(uint8 levelId, bytes32 hash) external` — `require(levelId < 10)`, set bit in bitmap, store hash, emit event.
- [ ] **Test with `forge test`** — 3 unit tests: first completion, idempotency on replay, invalid level reverts.
- [ ] **Fund deploy wallet** — get ~0.1 Sepolia ETH from a faucet ([sepoliafaucet.com](https://sepoliafaucet.com/) / [Alchemy faucet](https://www.alchemy.com/faucets/ethereum-sepolia)).
- [ ] **Deploy** to Sepolia via `forge create --rpc-url $SEPOLIA_RPC --private-key $DEPLOYER_KEY src/PointerworksAchievements.sol:PointerworksAchievements`. Record contract address.
- [ ] **Verify on Etherscan**: `forge verify-contract <addr> PointerworksAchievements --chain sepolia --etherscan-api-key $ETHERSCAN_KEY`.
- [ ] Commit contract source.

**Midday — JS bridge + ethers glue (~2 hr):**
- [ ] **`scripts/web3/ethers_glue.js`** — small vanilla JS file exposing `window.pointerworks.connect()`, `window.pointerworks.completeLevel(levelId, hash)`, `window.pointerworks.getAddress()`, `window.pointerworks.isConnected()`. Uses ethers v6 loaded from CDN `https://cdn.jsdelivr.net/npm/ethers@6/dist/ethers.min.js`.
- [ ] **HTML shell injection** — in Godot web export's `export/web/custom_html_shell.html`, include the CDN script + the glue file.
- [ ] **`scripts/autoload/web3_bridge.gd`** — replace stub with `JavaScriptBridge` calls:
  - `connect() -> Promise` — invokes `window.pointerworks.connect()`.
  - `complete_level(level_id: int, solution_hash: String) -> Promise` — writes the TX, returns TX hash.
  - `is_connected() -> bool`.
  - Emit signals `wallet_connected(address)`, `tx_pending(tx_hash)`, `tx_confirmed(tx_hash)`, `wallet_error(msg)`.

**Afternoon — UI integration + skippability (~2.5 hr):**
- [ ] **Main menu "Connect Wallet" button** — optional, shows "Connect (optional)" pre-connect; post-connect shows shortened address. If MetaMask absent, button shows "No wallet detected — install MetaMask" with link; clicking does NOT block access to levels.
- [ ] **Win dialog "Submit on-chain" button** — visible only if wallet connected. Pressing it calls `Web3Bridge.complete_level(level_id, hash)`; shows spinner during pending; shows Etherscan link on confirm.
- [ ] **Determinism check** — `Level.compute_solution_hash()` = `sha256(level_id || part_placements_sorted || run_seed)` — same grid always hashes same. Included in submission TX for anti-cheese.
- [ ] **Error handling** — network errors, user-rejected TX, insufficient gas → show toast, log to `ISSUES.md`. Game proceeds regardless.
- [ ] **Explicit skip path test** — launch in Incognito with no wallet → finish level 1 → win dialog shows "Connect wallet to record on-chain (optional)" → click "Next Level" works fine.
- [ ] **Update `README.md`** — "Ethereum: optional Sepolia on-chain completions via MetaMask. Contract address: 0x... Etherscan: ..."
- [ ] **Update `CREDITS.md`** — Foundry, ethers.js v6, Sepolia, MetaMask.
- [ ] Commit `feat: ethereum sepolia on-chain level completions (optional)` + push.

**Exit gate Day 5:** Wallet-connected player finishes a level → sees on-chain TX → TX confirms on Sepolia → Etherscan shows the `LevelCompleted` event. Disconnected player completes the same level with zero friction. **Bail gate:** if any step fails by EOD, revert `web3_bridge.gd` to stub and strip "Connect Wallet" button — do NOT let Ethereum jeopardize the submission.

### Day 6 — Apr 21 — Robustness + playtest + levels 9-10
**Target hours:** 6-7. **End state:** 10 levels shipped, external playtest feedback incorporated, save files robust.

**Morning — Save hardening + resource error handling (~1.5 hr):**
- [ ] **`Progress.load()`** — wrap `ConfigFile.load()` in try/catch; on any error or if `config.version != CURRENT_VERSION`, reset to defaults and show a 2 s toast "Save reset (was corrupted or old version)". Add `version=1` key.
- [ ] **`Settings.load()`** — same pattern.
- [ ] **`LevelLoader.load(path)`** — wrap `load()`. On nil result show `LevelLoadErrorDialog` scene: "Level failed to load. Please report this." with a "Back to menu" button. Log full error.
- [ ] **Claude Preview smoke**: simulate corrupted save by setting `localStorage["userdata/_Pointerworks/save.cfg"]` to `"garbage"` via `preview_eval` → reload → confirm toast + reset.

**Midday — Levels 9-10 (~1.5 hr):**
- [ ] **Design on paper**: l09 = 4-part chain (emitter → splitter → 2× deflector → 3 targets); l10 = teleporter maze with speed modifier (1 emitter, 3 teleporters, 2 speed mods, 4 targets).
- [ ] **Author `data/levels/l09.tres`, `l10.tres`**. Self-playtest both. Record `par_cursors`.
- [ ] Update `LEVELS.md`.
- [ ] Update `scripts/ui/level_select.gd` unlock logic to include l09, l10.

**Afternoon — External playtest (~2.5 hr):**
- [ ] **Export a test web build** (same headless command as Day 7): `godot --headless --path . --export-release "Web" build-test/index.html`. Serve on `python3 -m http.server 8000`.
- [ ] **Deploy to public URL** — fastest option: `butler push build-test/ MozeeB/pointerworks:playtest` (unlisted) OR `ngrok http 8000` share link.
- [ ] **Recruit 2 testers** — 1 puzzle fan, 1 non-gamer. DM the link. Ask for a 20-30 min session each, via screen-share so you can watch.
- [ ] **Observation protocol**: don't explain anything; note every point of confusion, every rage-quit candidate, every "what do I do?". Score tutorial clarity 1-5.
- [ ] **Log findings** in `ISSUES.md` as P0 (blocks completion), P1 (annoying), P2 (polish).
- [ ] **Fix P0 + P1** immediately. If fixes take >2 hr, spill remaining P1s to Day 7 morning.
- [ ] Commit `fix: post-playtest P0+P1 + levels 9-10` + push.

**Exit gate Day 6:** 10 levels beatable. Playtest report in `ISSUES.md`. Zero unresolved P0. **Verify via Claude Preview:** save-corruption scenario scripted via `preview_eval` to poison `localStorage` → `preview_stop` + `preview_start` → toast confirms reset.

### Day 7 — Apr 22 — Web export + itch + SUBMIT
**Target hours:** 5-6. **End state:** submitted with both side-challenge tickboxes checked.

**Morning — Export + Claude Preview + browsers (~2 hr):**
- [ ] **Configure Web export**: Godot → Project → Export → Add Web. Variant: **Regular (non-threads)**. Export With Debug: **OFF**. Uncheck ETC2/ASTC. Ensure custom HTML shell (with ethers glue) is wired.
- [ ] **Build headless**:
  ```
  /Applications/Godot.app/Contents/MacOS/Godot \
    --headless --path . --export-release "Web" build/index.html
  ```
- [ ] **Bundle size check**: `du -sh build/*.wasm build/*.pck build/*.js` — total **<15 MB**. Mitigations if over: drop unused audio, Export With Debug OFF, confirm no PNG textures.
- [ ] **Local serve**:
  ```
  cd build && python3 -m http.server 8000
  ```
- [ ] **Claude Preview smoke test**: `preview_start` at `http://127.0.0.1:8000/` → `preview_screenshot`, `preview_console_logs`, scripted Start → Level 1 → Win via `preview_click` → `preview_resize` to 1024×768 for judge-laptop check. Save screenshots to `docs/preview-*.png`.
- [ ] **Cross-browser test (real)**: Chrome, Firefox, Safari. Log residual issues to `ISSUES.md`; only fix P0.

**Midday — Media capture + itch page (~2 hr):**
- [ ] **Generate cover image 630×500** via Hugging Face MCP: *"Pointerworks — glowing factory grid with amber emitters and magenta cursor arrows flowing through deflectors, dark navy background, flat vector style, 6-color palette"*. Save to `docs/cover.png`.
- [ ] **Capture 3 screenshots**: build phase, run phase with trails, win dialog with ⭐. Use QuickTime window capture.
- [ ] **Record 30 s GIF**: QuickTime screen record → `ffmpeg -i x.mov -vf "fps=15,scale=640:-1" docs/trailer.gif`.
- [ ] **Record 60 s MP4** (better CTR than GIF): QuickTime → `ffmpeg -i in.mov -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p -c:a aac -b:a 128k docs/trailer.mp4`.
- [ ] **Create itch.io project** at https://itch.io/game/new. Follow the 14-step **"Submission order"** sequence in the [itch.io submission form — field-by-field reference](#itchio-submission-form--field-by-field-reference) section verbatim — every field value is pre-decided there. Set visibility to **Draft** first, NOT Public.
- [ ] **Fill itch page** using the 40-row field table: title, tagline, long description (from Context), tags (exact 10 from Tags section), cover 630×500, 3 screenshots, genre=Puzzle, AI-disclosure ticked, content-rating safe-for-children, etc.
- [ ] **Preview the draft itch page** in an Incognito tab — game loads, cover renders at both full size and 315×250 thumbnail size, no broken links.
- [ ] **Optional butler deploy** (for faster iteration on future updates): `butler push build/ MozeeB/pointerworks:web-jam`.

**Afternoon — README + submit (~1.5 hr):**
- [ ] **Final `README.md`** — concept paragraph, embed trailer, controls, play-now itch link, how-to-build, Ethereum contract address + Etherscan link, credits, MIT badge. Must be judge-worthy.
- [ ] **Final commit + tag**:
  ```
  git add -A && git commit -m "feat: jam submission v1.0"
  git tag -a v1.0 -m "Pointerworks jam submission"
  git push origin main --tags
  ```
- [ ] **Flip itch page to public**.
- [ ] **Submit to [Gamedev.js Jam 2026](https://itch.io/jam/gamedevjs-2026/submit)**:
  - Link itch.io page.
  - Tick **Open Source challenge** → paste https://github.com/MozeeB/Pointerworks.
  - Tick **Ethereum challenge** → paste contract address + Etherscan verified link.
  - Main theme justification: short description + 2 lines about Machines theme.
- [ ] **Verify** submission confirmation email.
- [ ] Update final `DEVLOG.md` entry.

**Exit gate Day 7:** Submission email received **before Apr 22 EOD**, leaving **4 days of buffer** until Apr 26 jam deadline for post-submission hotfixes from public playtest feedback.

### End-of-each-day universal checklist
- [ ] **Godot MCP `run_project`** on `scenes/main.tscn` — boots without errors. (If MCP unavailable: headless CLI fallback per Verification Cadence section.)
- [ ] **Godot MCP `get_debug_output`** — zero `SCRIPT ERROR` / `ERROR:` / `Parse error` lines since project boot.
- [ ] **Day 2+ only:** Export web build (headless CLI) → `preview_start` (`pointerworks-web` config from `.claude/launch.json`) → `preview_screenshot` saved to `docs/preview-day-N.png` → `preview_console_logs` zero errors. This is the authoritative HTML5 check.
- [ ] **Manual smoke** of the day's exit gate (per each day's "Exit gate" line).
- [ ] Add a `Verify:` bullet to the day's `DEVLOG.md` entry with Godot + Preview results (e.g., `Verify: Godot run_project clean; Preview web build loads, 3/3 targets lit in part_test.tscn; zero console errors`).
- [ ] `git status` clean after commit.
- [ ] `git push origin main` — remote matches local.
- [ ] Add a 2-5 line `DEVLOG.md` entry: day, what shipped, what was cut, next blocker.
- [ ] Update `CLAUDE.md` "current sprint day" line.
- [ ] **Sync the plan (source of truth):** if anything changed materially (scope cut, risk realized, new gap found, tool swap), edit `~/.claude/plans/parallel-jingling-river.md` first, then `cp ~/.claude/plans/parallel-jingling-river.md docs/PLAN.md`. Commit both. Future sessions MUST read `docs/PLAN.md` first.
- [ ] If anything slipped: move it to next day's top task, never silently drop.

### Per-task verification (applies to every `[ ]` item that writes code)

Before flipping a checkbox to `[x]`:

1. **Godot MCP `run_project`** after the file write — confirm editor boot is clean (fast path, seconds).
2. **`get_debug_output`** — no new `ERROR` / `SCRIPT ERROR` / `Invalid` entries vs. the pre-edit baseline.
3. **Smoke test** the specific behavior just added (e.g., spawn a cursor after writing `Emitter.gd`; verify trail draws after writing `VirtualCursor.gd`).
4. **Day 2+ only (commit-boundary, not per file):** after a group of related edits, rebuild the web export and run **Claude Preview** (`preview_start` → `preview_screenshot` → `preview_console_logs`). This is the HTML5 authoritative check — pass this before commit.

If any step fails, the checkbox stays `[~]` and the next action is fix — not move on. See the "🔬 Verification Cadence" callout near the top of this plan for the full rule.

## Post-submission buffer (Apr 23-26, 4 days before jam deadline)

Use the 4-day buffer for:
1. **Public playtest hotfixes** — itch comments + first-48-hour review feedback.
2. **Extra levels** (l11..l12) if the 10 feel short from real player feedback.
3. **Missing parts** (Multiplier / Delay Gate / Merge Gate) only if level variety feels thin.
4. **Trailer improvements** — longer YouTube video if itch CTR is low.

Protect the submission above all — never ship an update on Day Apr 26 that could break what's already accepted.

## Tool cost audit (every tool must be free)

All tooling confirmed **zero-cost** under the user's existing access. No credit cards required.

| Tool | Cost | Notes |
|---|---|---|
| **Godot 4.6** | Free (MIT) | Already installed. |
| **Godot MCP** | Free (open source) | Connected in `~/.claude/settings.json`. |
| **Figma MCP** (remote) | **Free tier** — 6 tool calls / month | Already connected. Budget: 2 calls (main menu + win dialog) + 4 reserve. |
| **Hugging Face MCP** | **Free** with user's HF token | Already connected. Free tier has rate limits on hosted Inference API — if throttled, use Spaces (`musicgen-small` Space works without inference API credits). |
| **Claude Preview MCP** | Free (Claude Code built-in) | No sign-up. |
| **[sfxr.me](https://sfxr.me/)** | Free (browser) | Fallback SFX. |
| **[BeepBox](https://beepbox.co/)** | Free (browser) | Music fallback. |
| **Git + GitHub** | Free for public repos | Repo already created. |
| **itch.io** | Free — HTML5 hosting unlimited bandwidth | Sign-up required; user should have this. |
| **butler** (itch CLI) | Free | `brew install butler`. |
| **QuickTime** | Free (preinstalled macOS) | Screen record. |
| **ffmpeg** | Free (LGPL) | `brew install ffmpeg`. |
| **Python http.server** | Free (stdlib) | Local preview. |
| **Chrome / Firefox / Safari** | Free | Cross-browser testing. |
| **Foundry** | Free (open source) | `curl -L https://foundry.paradigm.xyz \| bash`. |
| **ethers.js v6** | Free (MIT, via CDN) | `cdn.jsdelivr.net` — no account. |
| **Sepolia testnet ETH** | Free via faucet | [sepoliafaucet.com](https://sepoliafaucet.com/) or [Alchemy faucet](https://www.alchemy.com/faucets/ethereum-sepolia). ~0.1 SepETH covers 100+ test TXs. |
| **Alchemy Sepolia RPC** | **Free tier** — 300M compute units / month | Needs free signup; we'll use <0.1% of quota. |
| **Etherscan API** (verification) | **Free tier** — 5 req/sec | Needs free signup. |
| **MetaMask** | Free (browser extension) | Players install themselves. |
| **[sepoliafaucet.com](https://sepoliafaucet.com/)** | Free | Requires mainnet ETH balance > 0.001 for anti-abuse; alt: [Alchemy faucet](https://www.alchemy.com/faucets/ethereum-sepolia), [POW faucet](https://sepolia-faucet.pk910.de/). |

### License check for AI-generated audio (jam legal safety)

| Source | License | Jam OK? |
|---|---|---|
| **MusicGen (`facebook/musicgen-small`)** | CC-BY-NC (non-commercial) | ✅ Yes — jam is non-commercial. Attribution required. |
| **AudioLDM2 (`cvssp/audioldm2`)** | CC-BY-NC | ✅ Yes — same reasoning. |
| **Stable Audio Open 1.0** | Permissive (free for non-commercial + restricted commercial) | ✅ Yes. |
| **sfxr outputs** | CC0 (public domain) | ✅ Yes — no attribution needed but still credited. |
| **BeepBox outputs** | CC0 (user owns their composition) | ✅ Yes. |

**All attributions go into `CREDITS.md` + itch page.** If any AI-generated track turns out to be not-quite-right licensing-wise, the BeepBox/sfxr fallbacks are 100% CC0.

### Tool-failure bail-outs (everything has a free plan B)
- **HF MCP throttled** → run model via HF Space UI manually → download WAV → commit.
- **Figma MCP out of calls** → use Figma Desktop directly (free account).
- **Alchemy RPC down** → use public RPC `https://rpc.sepolia.org` (free, rate-limited but fine for demo).
- **Etherscan verification fails** → submit contract unverified; manually publish source in repo `contracts/` folder — still qualifies for Ethereum challenge since code is open source.

## Detailed game flow (prevent gaps & bugs)

Full state machines + sequence diagrams for every interactive path. Each FSM names the signals / methods to implement and the edge cases to test.

### A. App lifecycle FSM (top-level)

```
┌─────────────┐
│   LAUNCH    │  _ready on Main scene
└──────┬──────┘
       ▼
┌─────────────────────┐  if OS.has_feature("mobile") or touchscreen_available
│ DESKTOP_CHECK       │───────────────┐
└──────┬──────────────┘               ▼
       │ (desktop)        ┌────────────────────┐
       ▼                  │ DESKTOP_ONLY       │ (terminal state; no other transitions)
┌─────────────────────┐   │ BLOCKER            │
│ LOAD_SAVE           │   └────────────────────┘
│ (Progress.load,     │
│  Settings.load)     │
│  reset on corrupt   │
└──────┬──────────────┘
       ▼
┌─────────────────────┐
│ TUTORIAL_CHECK      │
└──────┬──────────────┘
       │ if not Progress.seen_tutorial
       ├──────► TUTORIAL_OVERLAY ──► (user dismisses) ──► MAIN_MENU
       │
       ▼ (seen already)
┌─────────────────────┐
│ MAIN_MENU           │──► Play ──► LEVEL_SELECT ──► pick ──► IN_LEVEL
│                     │──► Settings ──► SETTINGS_DIALOG ──► back
│                     │──► Credits ──► CREDITS ──► back
│                     │──► Connect Wallet (optional)
└─────────────────────┘
```

**Key invariants:**
- `Progress.seen_tutorial` is sticky; tutorial only ever shown once per browser.
- `DESKTOP_ONLY_BLOCKER` is terminal; a mobile player cannot navigate around it.
- `LOAD_SAVE` failure resets to defaults + 2 s toast; never crashes the app.

### B. In-level FSM (the core loop)

```
┌────────────────────┐
│ LEVEL_LOAD         │ LevelLoader.load(l0X.tres)
│ (failure→error dlg)│
└──────┬─────────────┘
       ▼
┌────────────────────┐            ┌──────────────┐
│ BUILD              │──Esc──►    │ PAUSE_MENU   │
│ - drag from palette│◄─Resume────│              │
│ - click to remove  │  Restart──►└──────┬───────┘
│ - R rotates        │                   │
│ - Ctrl+Z undo      │                   ├──► Back to menu → MAIN_MENU
│ - Clear button     │                   └──► Restart → BUILD (grid cleared)
│ - Space=RUN        │
│ - 1..7 pick part   │
└──────┬─────────────┘
       │ Space or Run button
       ▼
┌────────────────────┐         ┌─────────────────────┐
│ RUN                │  any    │ PAUSE_MENU (RUN)    │
│ - real cursor on   │──Esc──► │ cursors frozen via  │
│   Emitter spawns   │◄─Resume │ get_tree().paused   │
│   VirtualCursor    │         └─────────────────────┘
│ - CursorSystem     │
│   _physics_process │
│ - targets tracked  │
│ - Space=back to    │
│   BUILD (cancel)   │
└──┬─────────────────┘
   │ WinChecker: all targets hit        ┌─────────────┐
   ├──────────────────────────────────► │  WIN        │
   │                                    │ - fade in   │
   │ FailChecker: all cursors dead,     │ - ⭐ if ≤par │
   │ any target unhit                   │ - Next/Back │
   ├──────────────────────────────────► │ - Submit TX │
   │                                    │   (optional)│
   │                                    └──┬──────────┘
   │                                       │ Next
   │                                       ▼
   │                                    LEVEL_LOAD (next)
   │
   │ FAIL
   ▼
┌────────────────────┐
│ FAIL_BANNER        │ 2 s auto-hide OR user clicks Retry
│ "missed X targets" │
└──────┬─────────────┘
       ▼
    BUILD (grid preserved)
```

**Key invariants:**
- BUILD ↔ RUN is reversible (Space both ways) — RUN→BUILD wipes all live virtual cursors.
- WIN is terminal for the level; only advance via user click (Next / Back / Submit).
- FAIL is transient — auto-returns to BUILD; grid NOT cleared.
- Pause works in BUILD and RUN; settings changes propagate via `Settings.settings_changed` signal without closing the dialog.

### C. Virtual cursor lifecycle

```
spawned by Emitter on real-mouse-enter
         │
         ▼
┌──────────────────┐
│ TRAVEL           │  Area2D with velocity, _physics_process ticks position
│ TTL = 5 s        │  Line2D trail appended each frame (max 60 points)
└──┬───────────────┘
   │
   ├─ overlaps Part (Deflector/Splitter/SpeedMod/Teleporter/Target)
   │   → Part.apply_to_cursor(self) mutates velocity / spawns children / teleports / kills
   │
   ├─ overlaps Wall
   │   → DEATH (red flash, emit "died" signal, queue_free after 0.2 s)
   │
   ├─ position.x/y outside grid rect
   │   → DEATH (fade, 0.15 s)
   │
   ├─ TTL expires (5 s)
   │   → DEATH (dissolve, 0.3 s)
   │
   └─ hits Target with matching requirements
       → Target.mark_hit(), Emit "target_hit" signal
       → cursor DEATH (gentle fade)
```

**Invariants & edge cases to test:**
- Two cursors reach a Target in the same frame → only the first hit counts; both still die.
- Splitter consumes input cursor, spawns 2 children with perpendicular velocity — each child has *fresh* TTL reset to 5 s.
- Teleporter: entering cursor despawns, new cursor spawns at paired tile with *same velocity* (not reflected).
- Max live cursor cap = 64. Over that, oldest cursor dies first (prevent splitter fork bombs).
- Player pausing during RUN freezes `_physics_process` via `get_tree().paused = true` and `process_mode`.

### D. Input-handling precedence (avoid bugs where Esc opens TWO dialogs)

```
Input event arrives
         │
         ▼
┌────────────────────────────────────────────┐
│ 1. TUTORIAL_OVERLAY (if visible) consumes  │
│    ALL input; nothing else handles         │
└──────┬─────────────────────────────────────┘
       ▼
┌────────────────────────────────────────────┐
│ 2. DESKTOP_ONLY_BLOCKER (if visible)       │
│    consumes all input                      │
└──────┬─────────────────────────────────────┘
       ▼
┌────────────────────────────────────────────┐
│ 3. SETTINGS_DIALOG (if open) Esc closes it │
│    — does NOT propagate to PauseMenu       │
└──────┬─────────────────────────────────────┘
       ▼
┌────────────────────────────────────────────┐
│ 4. PAUSE_MENU (if open) Esc closes (resume)│
│    — does NOT propagate to level           │
└──────┬─────────────────────────────────────┘
       ▼
┌────────────────────────────────────────────┐
│ 5. IN_LEVEL                                │
│   Esc=pause, Space=run_toggle, R=rotate,   │
│   Ctrl+Z=undo, 1..7=part, F11=fullscreen   │
└────────────────────────────────────────────┘
```

**Implementation:** use Godot's `_unhandled_input` in the level and `_input` in modal dialogs (modals call `accept_event()` to stop propagation).

### E. Save/load flow

```
STARTUP
   │
   ▼
Settings.load()                Progress.load()
   │                              │
   ├─ok→ apply volumes, fullscreen├─ok→ unlock bitmap
   └─fail→ defaults + toast      └─fail→ defaults + toast

SETTINGS change (slider drag end)
   → Settings.save() (debounced 500 ms)

LEVEL WIN
   → Progress.mark_completed(level_id, cursors_used)
   → Progress.save() (immediate, synchronous)
   → optionally Web3Bridge.complete_level(level_id, hash)

TUTORIAL dismissed
   → Progress.seen_tutorial = true; Progress.save()
```

**Web `localStorage` notes:**
- Godot serializes ConfigFile as plain text in `localStorage` key `userdata/_Pointerworks/save.cfg`.
- 5 MB hard limit — our payload is <1 KB, fine.
- Browser "Clear site data" wipes `localStorage` — save loss expected; surface as toast not as crash.

### F. Ethereum TX flow (skippable)

```
MainMenu "Connect Wallet"
   │
   ▼
Web3Bridge.connect()  ──► window.pointerworks.connect()
   │                           │
   │                           ├─ no MetaMask → show "Install MetaMask" link, no-op
   │                           ├─ user rejects → toast "Wallet connection cancelled"
   │                           └─ success → emit wallet_connected(address)
   │                               ▼
   │                          MainMenu UI updates to show 0x123...abc
   ▼
(later) WIN dialog for level_id
   │
   ▼
IF Web3Bridge.is_connected():
   show "Submit on-chain" button
ELSE:
   show "Connect wallet to record on-chain (optional)"

User clicks Submit
   │
   ▼
Web3Bridge.complete_level(level_id, solution_hash)
   │
   ├─ emit tx_pending(tx_hash) → show spinner
   ├─ wait for 1 confirmation (~12 s on Sepolia)
   ├─ on success: emit tx_confirmed(tx_hash) → show Etherscan link
   └─ on error: emit wallet_error(msg) → toast "TX failed: <reason>" — level STILL marked locally-completed
```

**Invariants:**
- Failing TX NEVER rolls back local `Progress.mark_completed()` — player still advances.
- No TX is required to unlock any level.
- Wallet disconnect fires signal; UI drops to disconnected state mid-session.

### G. Edge cases & bug-prevention checklist (to test before Day 7 submit)

| Scenario | Expected behavior |
|---|---|
| Refresh browser mid-level | Returns to MainMenu; `Progress` reflects last-saved state. |
| Lose wallet mid-level (disconnect in MM) | Win dialog seamlessly drops "Submit on-chain"; game continues. |
| Open pause menu during tutorial | Tutorial overlay consumes Esc first; pause cannot open. |
| Spam-click palette drag | Only last drag's drop fires; no duplicate placements. |
| Rotate part that has no rotation variants (Wall) | Silently ignored. |
| Place part on occupied cell | Rejected with red flash on existing part; toast "Cell occupied". |
| Splitter inside splitter chain (fork bomb) | Max-live-cursor cap (64) kicks in; oldest dies first. |
| Teleporter with no pair | LevelLoader rejects the `.tres` at load; `LevelLoadErrorDialog` shown. |
| Music autoplay blocked by browser | Starts on first user gesture (PlayButton click); `AudioBus` primes on click. |
| Cursor clips through corner of two Parts in same frame | `CursorSystem` processes collisions in z-index order; first-collision wins. |
| F11 while in pause menu | Pause menu stays open; fullscreen toggles; no state lost. |
| Settings slider drag while RUN active | Volume updates live; no sim pause. |
| localStorage disabled by browser | `Progress.load()` returns default; tutorial shown every launch; toast "save disabled". |
| Tab loses focus during RUN | Godot auto-pauses physics on web; cursors freeze; resume on focus. |
| Player completes level 10 | Main menu "Play" button stays enabled; Credits scene accessible; show "You've cleared all 10!" on next launch. |
| Ethereum: replay same completion (same hash) | Contract idempotent — bit already set; TX succeeds as no-op; cheap gas. |
| Ethereum: fund wallet with 0 SepETH | TX fails pre-sign; toast "Need Sepolia ETH — see faucet". |

## Risks & mitigations (7-day scope)

1. **Mechanic isn't fun** — Day 1 end-of-day test scene must demonstrate the "aha" of routing a cursor through a splitter. If not fun by Day 1 EOD, Day 2 morning pivots to single-cursor fallback (mouse IS the working fluid; no virtual cursors).
2. **Cursor-capture weirdness on web** — play area inset 64 px from canvas edge; use `get_global_mouse_position()` (canvas coords) not deltas; pause on blur. Test in real browser by Day 2 EOD (not Day 7).
3. **GL Compatibility gotchas** — no `GPUParticles2D`, cap at 2 canvas-item shaders. Export a throwaway web build on Day 2 to catch issues early.
4. **Bundle size >15 MB** — mitigations: `.ogg` not `.wav`, 3D stripped Day 1, Export With Debug OFF, zero sprite PNGs. If still over, drop music loop to `.ogg q1` or cut the loop to 15 s.
5. **Scope creep** — the 7-day budget is the firewall. If tempted to add a part or level: "does it fit the 10-level budget AND can I author + playtest it within the day?"
6. **Ethereum Day 5 slips** — hard bail: revert `web3_bridge.gd` to stub, remove Connect Wallet button. Submission MUST ship without Ethereum if that's the cost.
7. **Audio MCP throttled or bad output** — 3-iteration cap, then bail to sfxr/BeepBox. Never spend >45 min fighting audio gen.
8. **Playtest reveals fundamental issue on Day 6** — only fix P0s on Day 7 morning; document P1+P2 in `ISSUES.md` and post-submit if time allows.
9. **Browser autoplay policy** — music starts on first user gesture (PlayButton click), not `_ready`. `AudioBus` primes SFX pool on first click too.
10. **Figma MCP quota (6/month)** — budget 2 calls (main menu + win dialog), hold 4 in reserve. If quota exhausted, use Figma Desktop directly with a free account.
11. **HF MCP rate limits** — if Inference API 429s, use the model's Space UI directly (free). Download WAV, commit to repo.
12. **Sepolia faucet drip unavailable** — alternate faucets listed in Tool cost audit; always have at least 2 faucet sources bookmarked.
13. **MetaMask not detected in judge's browser** — contract/etherscan link in README lets judges verify the Ethereum challenge *without* playing; UI shows install link but never blocks gameplay.

## Verification / test plan

**Iteration loop (every session):**
- MCP Godot `run_project` keeps game running as hot process.
- `get_debug_output` after each edit catches runtime errors early.
- `res://scenes/dev/part_test.tscn` grows a row per part — auto-runs as smoke test.
- Deterministic-sim hash logged at RUN start catches regressions.

**Claude Preview (in-session web smoke tests):**
Once a web build exists (end of Day 2 onward), use the Claude Preview MCP to catch web-specific breakage without leaving the session:
- `mcp__Claude_Preview__preview_start` → point at `http://127.0.0.1:8000/` after `python3 -m http.server 8000` is running.
- `mcp__Claude_Preview__preview_screenshot` — visual sanity (grid renders, palette visible, trails drawn).
- `mcp__Claude_Preview__preview_console_logs` + `preview_network` — catch WASM load failures, missing .pck, CORS.
- `mcp__Claude_Preview__preview_click` / `preview_eval` — drive a scripted Start → Level 1 → Win smoke path.
- `mcp__Claude_Preview__preview_resize` — 1280×720 (design), 1024×768 (judge laptop), 1920×1080 (big screen).
Run Claude Preview *before* opening real browsers — it's faster to iterate and already in-session. Save screenshots to `docs/preview-*.png` for evidence.

**Browser playtest** (end of Days 2, 3, 4): Chrome + Firefox + Safari. Claude Preview covers a Chromium-like engine, so Firefox + Safari are the two that still need manual testing.

**Export & local serve:**
```
/Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path /Users/mujibnoctua/Documents/CikupProjects/machines-game \
  --export-release "Web" build/index.html

cd build && python3 -m http.server 8000
# open http://127.0.0.1:8000
```

**Bundle size check:** `du -sh build/*.wasm build/*.pck build/*.js` — total **<15 MB**.

**itch.io upload:**
```
butler push build/ MozeeB/pointerworks:web-jam
butler status MozeeB/pointerworks:web-jam
```

**Jam submission checklist (Day 4):**
- [ ] `butler push` final build, or manual zip upload.
- [ ] itch page: title, short description, long description (both from plan).
- [ ] 3 screenshots + 30 s GIF + 630×500 cover.
- [ ] Tags: `html5`, `puzzle`, `godot`, `mouse`, `gamedevjs2026`, `machines`.
- [ ] Tick **Open Source challenge** + link to [github.com/MozeeB/Pointerworks](https://github.com/MozeeB/Pointerworks).
- [ ] Credits: Hugging Face MCP (MusicGen + AudioLDM2 / Stable Audio Open), sfxr, BeepBox (if used as fallback), Godot 4.6, Figma.
- [ ] GitHub README polished + repo public.
- [ ] Submission email from itch.io received.

## Session resumption protocol (for future Claude sessions)

Claude Code Desktop sessions may span minutes, hours, or days, and context may reset mid-sprint. This protocol guarantees a fresh session can be productive in **under 30 seconds** without re-exploring the repo.

### The 30-second onboarding sequence

Paste this as the first user message to any new session working on Pointerworks:

```
Resume Pointerworks jam work. Read docs/PLAN.md — the CURRENT STATE block + the current day's section. Then continue from "Next action". Don't re-explore the codebase.
```

Claude's expected behavior:
1. **Read `docs/PLAN.md`** (5 s) — grabs FAST-RESUME block → CURRENT STATE → current day section.
2. **Read `DEVLOG.md` last entry** (2 s) — validates the state block matches actual work.
3. **Read `ISSUES.md` P0 section** (2 s) — checks for unresolved blockers.
4. **Begin executing the next checklist item** from the current day.

### State hygiene rules

- **CURRENT STATE block** at the top of the plan is the canonical "where are we" indicator. Updated at EOD **and** at every mid-task checkpoint (see "Context-limit safety" below).
- **Checkbox convention** — use three states inside each day's section:
  - `- [ ]` = not started
  - `- [~]` = **in progress** (with an inline note: `- [~] Implement GridSystem — currently at scripts/level/grid_system.gd:45, working on snap()`)
  - `- [x]` = done
  - Only ONE `- [~]` item exists at a time across the whole plan; it is the pointer to "what would be interrupted if context ran out right now."
- **When the plan changes materially** (scope cut, new gap, risk realized), bump the `Plan version` counter in CURRENT STATE (v8 → v9 etc.) and note the change in `DEVLOG.md`.
- **When in doubt about precedence:** code < `CLAUDE.md` < `DEVLOG.md` < `docs/PLAN.md` (this file, the source of truth).

### Context-limit safety (mid-task session interruption)

Claude Code Desktop sessions have a finite context window. If context runs out mid-task, a naïve session loses the "what was I doing" state and either re-explores (wasteful) or restarts the subtask from scratch (risks breaking WIP code). These rules guarantee a mid-task interruption is recoverable with zero rework.

**The three checkpoint triggers:**

1. **Time-based:** every ~45 min of wall-clock work within a day → run a mini-checkpoint.
2. **Scope-based:** every time a checklist item flips from `- [~]` to `- [x]` → update CURRENT STATE's `Last completed` + advance `- [~]` to the next item.
3. **Context-pressure-based:** as soon as Claude notices context is ~70-75% full (approaching limit) → run a **full checkpoint immediately**, even mid-subtask. Do NOT wait to finish the subtask — commit WIP first.

**Mini-checkpoint procedure (~1 min, every 45 min or on checkbox flip):**

1. Update CURRENT STATE block at top of plan:
   - `Last completed:` = most recent `- [x]` item
   - `In-progress (if any):` = the current `- [~]` item with a short what-I'm-doing note
   - `└─ last file touched:` = the most recently edited file path (with line number if useful)
   - `└─ last test run:` = last MCP `run_project` / `preview_start` / `forge test` and its result ("passed" / "1 error: X")
2. `cp ~/.claude/plans/parallel-jingling-river.md docs/PLAN.md`
3. No commit required for mini-checkpoints (avoid commit spam). Leave the working tree dirty; the plan file + any edited game files are all that matters.

**Full checkpoint procedure (~3 min, on context-pressure or before any risky operation):**

1. **Stop the current subtask safely.** Do NOT leave the codebase in a broken state:
   - If a file was partially edited and would break compilation, **finish the minimal edit that keeps it compiling** (add a stub / early return / `pass`).
   - If a test was mid-run, let it finish; log the outcome in CURRENT STATE.
2. **Run the mini-checkpoint steps above** (update CURRENT STATE + sync to `docs/PLAN.md`).
3. **Append a handoff note to `DEVLOG.md`** under a `## Session handoff — <date> <time>` header:
   ```markdown
   ## Session handoff — 2026-04-17 14:32
   - Day: 2 of 7
   - Active task: [~] Implement part_palette drag-drop (scripts/ui/part_palette.gd)
   - Last file edited: scripts/ui/part_palette.gd:78 — mid-way through _on_drag_ended handler
   - Last test: run_project passed; drag + drop visual feedback works, drop-to-place not yet wired
   - Next micro-step: wire `GridSystem.place_part(cell, part_type)` call inside _on_drag_ended
   - Gotchas to remember: right-click-to-remove not implemented yet; stub it as `pass`
   - Commit status: WIP — commit as `wip: day 2 part_palette drag-drop (mid-task)` before session ends
   ```
4. **Commit with `wip:` prefix** (signals "not feature-complete, don't merge to main or tag"):
   ```
   git add -A && git commit -m "wip: <day N> <subtask> (mid-task checkpoint)"
   git push origin main
   ```
   WIP commits on `main` are fine for a solo jam — they preserve state across sessions. Post-jam, these can be squashed.
5. **Tell the user (in the current session's last message):** "Context checkpoint saved — safe to end session. Resume with the 30-second onboarding prompt; last `[~]` item in docs/PLAN.md + latest DEVLOG handoff note describe where we left off."

**Resumption procedure (starting a new session after a mid-task interruption):**

1. Read `docs/PLAN.md` FAST-RESUME block — specifically the `In-progress (if any)` line.
2. Read the last `## Session handoff` entry in `DEVLOG.md`.
3. Read the last-touched file at the specific line number named in the handoff.
4. Re-run the "last test" from the handoff to verify the codebase state matches the note (guard against local edits made outside Claude).
5. Continue from `Next micro-step` in the handoff.
6. When the `- [~]` item is completed, flip it to `- [x]`, clear the `In-progress` line in CURRENT STATE, and continue normally.

**Idempotency guarantees (critical — every checklist item must be replay-safe):**

- **File creation** — if the file already exists and has the expected shape, skip; do NOT overwrite. Use `Read` first, then `Write` only if missing.
- **Git ops** — `git init` is idempotent; `git remote add` fails loudly if the remote exists (check with `git remote -v` first); `git commit` is skipped if nothing changed.
- **Scene/resource creation** — check for the node/resource before creating. Godot MCP's scene creation tools are idempotent by default; confirm before relying on it.
- **SFX/music generation** — if `audio/sfx/spawn.ogg` already exists and is non-zero size, skip regeneration. Each asset named deterministically.
- **Ethereum deploy** — once a contract is deployed, the address goes into `docs/PLAN.md` + `README.md`. Re-running deploy produces a *new* address; the resumption procedure must check for existing address BEFORE redeploying.
- **External playtest** — if testers already responded, do NOT re-recruit; check `ISSUES.md` for recorded feedback first.

**Anti-patterns to avoid (these break resumption):**

- ❌ Leaving a partial edit that breaks compilation (always add a stub).
- ❌ Running mid-task tool calls that can't be re-run safely (e.g., "send email to playtesters" — one-shot actions must be logged immediately).
- ❌ Keeping state only in conversation memory (e.g., "I decided we should use approach X" without writing it to plan or code).
- ❌ Batching a large edit across many files without an intermediate commit (loses state if interrupted mid-batch; prefer many small commits).
- ❌ Using checkbox `- [x]` before the work is committed (lying about state — only flip to `[x]` AFTER the commit).

**Context-limit early warning signs (trigger a full checkpoint when Claude sees these):**

- Tool-result scrolling that pushes old messages far up.
- A `<system-reminder>` warning about approaching context limit.
- Extended thinking budget getting tight.
- User says "this is taking a while" or "let me know if you're running low."
- More than ~30 tool calls in the current session without a checkpoint.

When ANY of those fires, stop the current subtask at the earliest safe point and run the full checkpoint procedure. It is always cheaper to checkpoint + resume than to blow context mid-edit and lose state.

### Leverage Claude Code's memory system

Claude Code Desktop maintains a per-project memory at `/Users/mujibnoctua/.claude/projects/-Users-mujibnoctua-Documents-CikupProjects-machines-game/memory/`. Complementary to `docs/PLAN.md`:

| Use memory for | Use `docs/PLAN.md` for |
|---|---|
| User preferences & working style | Scope, schedule, FSMs |
| Feedback/corrections from this specific user | Game design, architecture |
| External references (Linear boards, Slack channels) | Tool choices, risks |
| "Don't do X because we got burned before" | Day-by-day execution plan |

**Do NOT duplicate plan content into memory.** Memory is for *context about the human + workflow*, plan is for *context about the game + sprint*.

### Fast mode (Opus 4.6)

User's global setting: Opus 4.6 with `/fast` toggle available. Recommended for this sprint:
- **Fast mode ON** for: checklist execution, repetitive file edits, running scripts, committing.
- **Fast mode OFF** for: initial reading of this plan, diagnosing novel bugs, theme/design decisions, playtest-feedback triage.

### Parallelization opportunities during the sprint

Claude Code can launch subagents in parallel. Use these where applicable:

| Day | Parallel-capable tasks |
|---|---|
| Day 1 | (writing 10 md docs in parallel via Explore subagent; or serial + commit faster) |
| Day 2 | Generate 5 SFX via HF MCP + design 4 levels on paper in parallel human work |
| Day 3 | Figma call + shader authoring + music generation all interleave well |
| Day 5 | Foundry tests + ethers_glue.js both compile/test independently |
| Day 6 | Playtest runs + robustness edits can interleave (background playtest) |
| Day 7 | Media capture + itch page fill + README polish all independent |

**Rule:** if two tasks touch different files/systems and neither depends on the other's output, run them in parallel (Claude Code supports multiple tool calls in one message).

### Session end → session start handoff

**Three kinds of session end** — each has a slightly different handoff:

**(a) Clean EOD (a day's work is complete):**
1. Update `CURRENT STATE` block: `Last completed:` = last `- [x]`, `Next action:` = tomorrow's first item, clear `In-progress`.
2. Update `DEVLOG.md` with 2-5 line EOD entry.
3. `cp ~/.claude/plans/parallel-jingling-river.md docs/PLAN.md`.
4. `git add -A && git commit -m "chore: day N EOD sync"`.
5. `git push origin main`.

**(b) Mid-task session end (intentional, e.g., user stopping for the night mid-day):**
Run the **full checkpoint procedure** (in "Context-limit safety" section above) — identical steps, but commit prefix is `wip:` not `chore:`.

**(c) Emergency context-limit bail:**
Run the **full checkpoint procedure** immediately; do not attempt to finish the subtask first. Speed > completeness.

**At start of next session (any of the three above):**
1. Paste the 30-second onboarding prompt.
2. Verify `git status` clean (if WIP commit: you'll see the WIP commit as the HEAD; do NOT reset — resume from it).
3. Read CURRENT STATE `In-progress (if any)` + latest DEVLOG `Session handoff` entry (if WIP).
4. Proceed from `Next action` (clean EOD) or `Next micro-step` (mid-task/emergency).

This handoff is idempotent — interrupt a session any way, paste the prompt, continue. Zero rework guaranteed by the checkpoint protocol above.

## Critical files to touch in the FIRST session (Day 1 morning, ~30 min)

Existing files: `project.godot`, `icon.svg`, `icon.svg.import`, `.godot/`.

**Modify:** `project.godot` (see Day 1 Morning checklist).

**Create Day 1 morning:**
- `.gitignore`, `LICENSE`, `README.md`, `CLAUDE.md`, `DEVLOG.md`, `PARTS.md`, `LEVELS.md`, `CREDITS.md`, `ISSUES.md`, `THEME.md`, `docs/ART.md`, `docs/GAME_FLOW.md`, `docs/PLAN.md`
- `scripts/autoload/{scene_switcher,progress,audio_bus,web3_bridge}.gd`
- `scenes/main.tscn`, `scenes/ui/level_select.tscn`, `scenes/level/level.tscn`

**Full target layout:**
```
/
├── project.godot, icon.svg, .gitignore, LICENSE
├── README.md, CLAUDE.md, DEVLOG.md, PARTS.md, LEVELS.md, CREDITS.md, ISSUES.md, THEME.md
├── docs/            (PLAN.md, ART.md, GAME_FLOW.md, cover.png, trailer.gif, trailer.mp4, screenshots/)
├── default_bus_layout.tres
├── scripts/
│   ├── autoload/    (scene_switcher, progress, audio_bus, settings, web3_bridge)
│   ├── data/        (level_resource, part_placement, part_data)
│   ├── level/       (level, grid_system, phase_controller, virtual_cursor, cursor_system, win_checker, fail_checker, level_loader)
│   ├── parts/       (part [base], emitter, deflector, splitter, speed_mod, teleporter, target, wall)
│   ├── ui/          (main_menu, level_select, level_button, hud, part_palette, win_dialog, pause_menu, settings_dialog, tutorial_overlay, desktop_only_blocker, level_load_error_dialog)
│   ├── web3/        (ethers_glue.js)
│   └── util/        (assert_dev, color_palette)
├── scenes/          (main, ui/*, level/*, parts/*, dev/part_test.tscn)
├── data/levels/     (l01.tres … l10.tres)
├── contracts/       (src/PointerworksAchievements.sol, foundry.toml, script/Deploy.s.sol)
├── shaders/         (grid_glow.gdshader, target_pulse.gdshader)
├── audio/           (sfx/*.ogg, music/factory_loop.ogg)
└── build/           (gitignored — web export output)
```

User's global rules enforced: **many small files** (200-400 lines typical, 800 cap), **immutability**, **feature-folder organization**, **explicit error handling**, **no hardcoded values** (colors from palette, paths in constants).
