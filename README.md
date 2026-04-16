# Pointerworks

> Build factories where your own mouse cursor is the raw material.

A browser-native puzzle game about machines that run on your mouse. Built in 7 days for [Gamedev.js Jam 2026](https://itch.io/jam/gamedevjs-2026). Theme: **Machines**.

## Concept

Each level is an empty factory floor. Place **Emitters** on the grid, and when your real cursor passes over one, it spits out a **virtual cursor** — a tiny arrow flying in a fixed direction. Route those virtual cursors through a toolkit of parts — **Deflectors**, **Splitters**, **Speed Modifiers**, **Teleporters** — until they hit every **Target** in the right order.

It's *The Incredible Machine* for the browser era, where the thing your contraption is moving… is **you**.

## Play

- **itch.io:** _(link added on submission day)_
- **Source:** https://github.com/MozeeB/Pointerworks
- **Controls:** Mouse only. Hover an Emitter during RUN phase to feed it; parts are pre-laid in v1.0 (palette drag-drop is a post-jam stretch).
- **Shortcuts:** `Space` = Run/Stop · `Esc` = Pause · `F11` = Fullscreen · `R` = rotate selected part

## Theme — "Machines" (for judges in a hurry)

Four layers, each reinforced in the code:

1. **The factory is the machine** — every level is a literal grid of machine parts.
2. **The player is the fuel** — the real OS cursor is what Emitters consume.
3. **The browser is the machine** — mechanic only works on desktop browsers (enforced in-game via `DesktopOnlyBlocker`).
4. **Debugging is gameplay** — BUILD → RUN → FAIL → BUILD loop is industrial iteration.

Level names follow industrial machinery: Conveyor, Press, Forge, Refinery, Lathe, Kiln, Foundry, Assembly, Reactor, Cyclotron. Full rationale + judge-facing copy in [`THEME.md`](THEME.md).

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
- [`DEVLOG.md`](DEVLOG.md) — daily journal (Days 1-7 all shipped)
- [`ISSUES.md`](ISSUES.md) — known bugs
- [`docs/SUBMISSION_CHECKLIST.md`](docs/SUBMISSION_CHECKLIST.md) — Day 7 itch.io upload sequence + bundle sanity table

## Side challenges

- **Open Source** — MIT licensed, public repo.
- **Ethereum** — Optional Sepolia on-chain level completions via MetaMask. 100% skippable; the game plays fully without a wallet.

### Ethereum — deploy your own contract (optional)

The contract and JS bridge ship with the source. To wire up a live deploy:

```bash
# 1. Install Foundry
curl -L https://foundry.paradigm.xyz | bash && foundryup

# 2. Set up .env (NEVER commit this)
cp .env.example .env
# Fill in SEPOLIA_RPC (https://alchemy.com free tier), DEPLOYER_KEY
# (throwaway wallet, fund ~0.05 SepETH via https://sepoliafaucet.com),
# and ETHERSCAN_KEY (https://etherscan.io/apis).

# 3. Test + deploy
set -a && . .env && set +a
cd contracts
forge test
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC --broadcast

# 4. Paste the deployed address into .env as POINTERWORKS_CONTRACT,
#    then either:
#    (a) Edit scripts/autoload/web3_bridge.gd DEFAULT_CONTRACT_ADDRESS, OR
#    (b) Append to build/index.html before <script src=index.js>:
#        <script>window.POINTERWORKS_CONTRACT='0xYourAddress'</script>

# 5. Verify on Etherscan (optional)
forge verify-contract <addr> src/PointerworksAchievements.sol:PointerworksAchievements \
  --chain sepolia --etherscan-api-key $ETHERSCAN_KEY
```

Players without MetaMask see a "Connect Wallet (optional)" button that's a no-op — they finish every level with zero crypto friction. With MetaMask connected + a deployed contract, the win dialog gains a "Submit on-chain" button that records `LevelCompleted(address, levelId, hash, timestamp)`.

## License

MIT — see [LICENSE](LICENSE).
