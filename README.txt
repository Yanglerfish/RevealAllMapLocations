# Reveal All Map Locations

Reveals points of interest on the Ravenswatch map. It reveals location icons, not necessarily the dark fog over unexplored terrain.

## Install

1. Install Ravenswatch Mod Manager (https://rsmm.me/) and its Lua loader.
2. Close Ravenswatch.
3. Import RevealAllMapLocations_RSMM_v0.2.3.zip into RSMM.
4. Enable Reveal All Map Locations and click Apply. Replace the old version rather than enabling two copies.
5. Launch the game and start a run.

No repair script or SDK file edits are needed. If you previously installed the 0.2.2 SDK repair, this version also works with it; you do not need to undo it.

## Use

There is no hotkey. The mod attempts to reveal icons during chapter loading, then retries up to three times during gameplay, with at least five seconds between attempts. Attack, use abilities, or interact with objects to trigger retries.

## What changed

0.2.3 keeps the map-owner check inside the mod. It uses RSMM's existing event implementation with a separate world-owner validator, avoiding the hero-layout check that could block earlier versions after gameplay. It does not alter the shared SDK or other mods.

The owner layout was measured on Steam build 23766761. The check requires trusted loader build metadata, the expected world-owner class, and a valid owner vtable; unsupported layouts fail closed. Only objects with map icons can be revealed.

## Verification

The equivalent SDK-side owner correction was confirmed in solo. This self-contained packaging has offline regression coverage using the unmodified SDK map module; a fresh in-game test of this package is still required. Non-host multiplayer remains unconfirmed. RSMM Apply dry-run passed. RSMM lint flags the low-level compatibility bindings used by this version; this is not a clean lint pass.

## Troubleshooting

Check the mod is enabled and Apply completed, then restart the game. Messages begin with [RevealAllMapLocations] in mods/_log.txt in the game folder. A dispatched attempt does not prove icons appeared. Report game/RSMM versions and whether you were solo, hosting, or joining.

Source: https://github.com/Yanglerfish/RevealAllMapLocations

## Rollback

Version 0.2.2 remains available in GitHub Releases and Nexus previous files. Close the game, disable/remove 0.2.3, and import 0.2.2 instead. That older version requires its bundled SDK repair; follow its README. Do not enable both versions.
