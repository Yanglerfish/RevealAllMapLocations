# Reveal All Map Locations

A Ravenswatch mod designed to show points of interest on your map without having to walk up to each one. It reveals location icons; it does not guarantee removal of the dark fog covering unexplored terrain.

## What you need

Install [Ravenswatch Mod Manager (RSMM)](https://rsmm.me/) and use its loader setup to enable Lua mods. The loader is the component that lets Ravenswatch run this mod.

## Installation

1. Close Ravenswatch.
2. Download **RevealAllMapLocations_RSMM_v0.2.1.zip** from the [release page](https://github.com/Yanglerfish/RevealAllMapLocations/releases/tag/v0.2.1).
3. Open RSMM and import the ZIP.
4. Enable **Reveal All Map Locations** and click **Apply**.
5. Launch the game and start a new run.

If you are updating, replace the old version rather than keeping two copies enabled.

## How to use it

There is no hotkey. The mod attempts to reveal locations as the chapter loads. It then tries up to three more times while you play, with at least five seconds between attempts. Attack, use abilities, or interact with objects; standing idle does not trigger the retries.

## Multiplayer and limitations

The new retry behavior is experimental. It has passed automated checks, but complete map reveal has not yet been confirmed in-game for this version. In particular, it is not confirmed to work when you join another player's game. Try a solo or private run first.

Only objects that have a map icon can be revealed. This mod does not add icons to every object in the world.

## What's new in 0.2.1

- Tries again during gameplay if the first reveal happens too early.
- Limits retries so the mod does not keep running indefinitely.
- Removes an older compatibility workaround and uses RSMM's built-in reveal function.

## If nothing appears

- Check that the mod is enabled, the Lua loader is installed, and you clicked **Apply**.
- Restart the game after installing or updating.
- Start a new run and play for a short time to give the retries a chance to run.
- If it still fails, report your game and RSMM versions and whether you were playing solo, hosting, or joining someone else.

For troubleshooting, the loader writes messages beginning with `[RevealAllMapLocations]` to `mods/_log.txt` in the game folder. A message saying an attempt was dispatched means it was sent to the game; it does not confirm the icons appeared.
