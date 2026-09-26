# Reveal All Map Locations

A Ravenswatch mod that reveals location icons on the map. It does not guarantee removal of the dark fog over unexplored terrain.

## Installation

1. Install [Ravenswatch Mod Manager (RSMM)](https://rsmm.me/) and its Lua loader.
2. Close Ravenswatch completely.
3. Download **RevealAllMapLocations_RSMM_v0.2.2.zip** and extract it.
4. Open PowerShell in the extracted **RevealAllMapLocations** folder and run `& .\Repair-Map-SDK.ps1`. It normally finds the Steam install automatically; otherwise enter your game folder. Wait for the installed or already-installed message. If access is denied, open PowerShell as administrator, return to that folder, and run the command again.
5. Import the original ZIP into RSMM, enable **Reveal All Map Locations**, and click **Apply**. Replace the previous version rather than enabling two copies.
6. Launch Ravenswatch and start a new run. There is no hotkey.

The repair fixes an RSMM check that could incorrectly reject the map after earlier gameplay. It backs up the changed SDK file and leaves other SDK code intact. It supports only the verified game executable (SHA256 `40430b75c72be129f57917d865ecdc63a5ef4e4ba0a4244d950f5938cc00b2db`). It refuses other game builds or unfamiliar SDK layouts. If RSMM later replaces its SDK, rerunning the repair may be necessary.

## What changed in 0.2.2

Includes the SDK repair for a world-versus-hero validation bug. Previously the same mod could work initially and stop revealing locations in later runs despite retrying. Reveal timing remains one initial attempt plus up to three retries during gameplay, at least five seconds apart.

## Tested and limitations

The installed correction was confirmed working in solo by a player. Offline regression checks cover the map check before and after the hero layout is learned, plus rejection of invalid or mismatched owners. The packaged repair applies that same correction. Non-host multiplayer remains unconfirmed.

Attack, use abilities, or interact with objects to trigger delayed attempts. Standing idle does not trigger them. Only objects with map icons can be revealed.

## Troubleshooting

Check that the repair succeeded, the mod is enabled, and Apply completed. Restart after updating. Messages beginning with `[RevealAllMapLocations]` appear in `mods/_log.txt` in the game folder. A dispatched message means the command was sent; it does not prove icons appeared.

To undo the SDK repair, close the game and restore `rsmm/lib/rsmm.lua` from its `.map-backup-...` file. Disable the mod and Apply to remove the mod itself.

Source and releases: https://github.com/Yanglerfish/RevealAllMapLocations
