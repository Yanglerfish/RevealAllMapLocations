# Reveal All Map Locations — RSMM mod

Attempts to reveal Ravenswatch's normal minimap POI markers through the game's
`CROWS_MAP_REVEAL` event using the guarded `R.map.reveal()` API.

## Download and install

Download [v0.2.1](https://github.com/Yanglerfish/RevealAllMapLocations/releases/tag/v0.2.1)
and import `RevealAllMapLocations_RSMM_v0.2.1.zip` into Ravenswatch Mod Manager.
Enable the mod, install the RSMM Lua loader if needed, and Apply.
Close Ravenswatch before updating, then start a fresh run.

Manual layout inside the RSMM mods directory:

```text
RevealAllMapLocations/
  manifest.toml
  init.lua
  README.txt
```

Requires RSMM SDK 3.x with `R.map.reveal()` and its Lua loader. This mod does not
require Hero Capture or additional loader flags. No damage mod or custom SDK
patches are included.

## Changes in v0.2.1

- Captures the world dispatcher on `GENERATE_REWARDS` and attempts a reveal.
- Adds up to three later attempts on ability exit, combo link, validated
  interaction, or dream-shard gain events, at least five seconds apart.
- Later attempts run even if the initial dispatch returned success. Dispatch
  success alone does not establish that visible markers changed.
- Clears the cached dispatcher and retry counter on run start/end, menu entry,
  and chapter transition. A changed world dispatcher also resets the counter.
- Does not depend on `MAP_GENERATION_DONE`, which was absent in an observed
  non-host run. This version replaces the earlier map-complete/game-start
  handlers with bounded gameplay-triggered retries.
- Uses only the guarded SDK map API; the v0.1.0 internal/raw-memory fallback
  has been removed. SDK refusal is logged without bypassing its checks.

## Scope and validation

Targets existing POI marker components. Full terrain-fog clearing is not promised.
RSMM lint and offline Lua 5.4 compilation/mocked retry and teardown checks passed.
The new retry behavior has not yet been confirmed to reveal all POIs in-game,
especially as a non-host. This release is a timing experiment, not a confirmed
multiplayer fix. Test in a solo/private run first.

## Troubleshooting

Inspect `mods/_log.txt` for `[RevealAllMapLocations]` messages. Expected startup:

```text
[RevealAllMapLocations] v0.2.1 loaded; bounded delayed reveal; capture not required
```

Attempts log their number, reason, and `dispatched=true/false`. A true result
means the SDK dispatched the event, not that every marker became visible.
Retries need gameplay activity; waiting idle does not trigger them.
If the SDK refuses a dispatcher, this mod does not force the operation.
