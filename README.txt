# Reveal All Map Locations — installation and troubleshooting

This guide covers the published **v0.2.3** release for Ravenswatch. It reveals points-of-interest icons using the game's map-reveal event. It does not guarantee removal of unexplored terrain fog or add icons to objects that have none.

**Normal installation: install RSMM and its Lua loader, import the mod ZIP, enable the mod, and Apply while Ravenswatch is closed. No separate SDK repair, repair script, or Hero Capture flag is required for this map mod.**

## 1. Requirements and what each component does

- **Ravenswatch Mod Manager (RSMM):** imports the package, manages its enabled state, and applies files to the selected game installation. Obtain it from https://rsmm.me/ and follow its loader setup instructions.
- **RSMM Lua loader:** runs Lua mods when Ravenswatch launches. Installing the manager alone is not sufficient if its game-side loader has not been installed.
- **RSMM Lua SDK 3.x:** the library supplied with the loader. The manifest declares `>=3.0,<4`. This mod uses `rsmm`, the `rsmm.map` module, RTTI helpers, and native build-validation/read bindings. The version range is not a guarantee that every old or future 3.x build provides all those capabilities.
- **Reveal All Map Locations v0.2.3:** the ZIP you import. Its map compatibility check is contained in the mod; it does not replace SDK files.

The world layout was measured on Steam build **23766761**. Other builds have not been established as compatible. The mod also checks trusted loader metadata and the world owner's identity before dispatching; those checks do not constitute verification of every game version.

## 2. Install through RSMM

1. Exit Ravenswatch completely. Returning to the main menu is not a full restart. If necessary, check Task Manager and confirm `Ravenswatch.exe` has exited.
2. Confirm RSMM is pointed at the installation you actually launch. For Steam, use the game's Manage/Browse local files option to locate the folder containing `Ravenswatch.exe`. A common path is `C:\Program Files (x86)\Steam\steamapps\common\Ravenswatch`, but other Steam libraries use different paths.
3. Complete RSMM's Lua loader setup for that game folder. Use RSMM's own instructions for its loader version; do not copy an unrelated loader DLL from another mod.
4. Download **RevealAllMapLocations_RSMM_v0.2.3.zip** from the release's attached assets or the Nexus Files tab. On GitHub, the automatically generated **Source code** archives are not the intended RSMM import package.
5. Import that ZIP using RSMM's mod import control. Manual extraction into the game folder is unnecessary for this workflow.
6. Enable **Reveal All Map Locations**. If upgrading, replace the existing entry with the same mod ID; do not enable two copies under different folders.
7. Click **Apply** and check that it completes. Importing or enabling a mod without Apply does not establish that the game-side files are current.
8. Launch Ravenswatch normally and start a fresh run. There is no hotkey or configuration menu for this mod.

Expected ZIP structure:

```text
RevealAllMapLocations/
    init.lua
    manifest.toml
    README.txt
```

After Apply, the active installation should contain `mods/RevealAllMapLocations/init.lua` and `mods/RevealAllMapLocations/manifest.toml` alongside the game's other mod folders. The manifest identifies `RevealAllMapLocations` with version `0.2.3`. Check the active game directory, not just RSMM's source library. An extra nested `RevealAllMapLocations/RevealAllMapLocations/` directory can indicate incorrect manual extraction.

## 3. What happens during a run

Version 0.2.3 allows **four total attempts** per tracked world/reset cycle: one initial attempt and up to three retries. Retries are at least five seconds apart; this is event-driven, not a background timer.

The initial attempt follows `gameplay:GENERATE_REWARDS`. Later attempts are triggered by `ABILITY_EXIT`, `COMBO_LINK`, `INTERACTION_VALIDATE`, or `GAIN_DREAM_SHARDS`. Attack, use abilities, or interact with objects to generate activity. Standing still for 15 seconds does not necessarily cause three retries. Attempts that are refused also consume the limit.

The mod clears its captured world and counter on run start/end, menu entry, and `GAME_END_NEXT_CHAPTER`. A changed dispatcher received through `GENERATE_REWARDS` also resets the cycle. It does not require `MAP_GENERATION_DONE` and cannot begin revealing until it has received a usable world-dispatcher candidate.

For a practical test, open the map after loading, play actively for 20–30 seconds, then check it again. If testing the earlier repeat-run failure, start a second run in the same game process and repeat the check. Compare visible POI icons, not just terrain fog.

## 4. Verify loading and read the log

The loader log is `<Ravenswatch game folder>/mods/_log.txt`. Open it after the test and find the latest `== SESSION` header. Old sessions may remain in the same file; check timestamps before interpreting a result.

Expected v0.2.3 startup message:

```text
[RevealAllMapLocations] v0.2.3 loaded; self-contained world-owner check; no SDK repair needed
```

Expected attempt messages include:

```text
attempt=1 reason=GENERATE_REWARDS dispatched=true; visual result requires in-game check
attempt=2 reason=player activity after map generation dispatched=true; visual result requires in-game check
```

The loader may prepend timestamps and repeat the mod name. `dispatched=true` means the call returned successfully after sending `CROWS_MAP_REVEAL`; it is not an acknowledgement that every marker appeared. `dispatched=false` means the attempt did not report a successful dispatch; a validation refusal or an exception inside the protected call can cause it. Nearby SDK messages may identify the reason.

## 5. Troubleshooting by symptom

### No log, or no new session when launching

First check the selected game folder and loader installation. Make sure you launched the same game installation that RSMM applied to. A missing/currently unchanged log does not establish that the mod itself ran.

### A current session exists, but no v0.2.3 startup line

Check the enabled state, Apply result, active mod directory, and manifest version. Look earlier in that session for Lua initialization or module-loading errors. Remove duplicate enabled copies through the manager, Apply with the game closed, and relaunch.

### The startup line reports an older version

The game is using an older applied copy or an already-running Lua state. Close the entire game, import the correct release asset, replace the old entry, Apply, and relaunch. Do not expect a file update to reload a running mod automatically.

### `BLOCKED: compatible RSMM map module missing`

The mod could not create its map helper from `rsmm.map`. Check RSMM's normal loader/SDK installation and compatibility with the game build. Restore or update it through RSMM's supported setup process. This message does not mean you should run the old v0.2.2 repair script.

### Loaded, but there are no attempt messages

Start a fresh run and allow chapter loading to complete. The mod needs the `GENERATE_REWARDS` event before it has a world candidate; player activity alone cannot invent one. If that event path never arrives, report the run type and current-session log. Repeatedly importing the same ZIP will not fix a missing runtime event.

### Attempts say `dispatched=false` or the dispatcher is rejected

The self-contained check requires trusted loader metadata, an aligned plausible dispatcher, a world-owner vtable in the game image, and RTTI class `oCEntitySceneContext`. A game/SDK mismatch, missing binding, or invalid candidate can prevent dispatch. The generic SDK rejection message may still mention a vtable or `R.give`; it does not establish that another mod is broken.

Do not force the check to return true or paste an address from another run. Addresses change between processes and objects can be retired. Save the relevant log lines and report the versions and run type.

### Attempts say `dispatched=true`, but icons are absent or incomplete

Let the remaining activity-triggered attempts run and inspect POI icons again. Four successful messages confirm sending four events, not complete visibility. Distinguish icons from terrain fog. Try a solo run to compare with joining another player's game; host/client behavior and marker availability can differ. A successful dispatch log alone does not prove multiplayer compatibility or identify a networking restriction.

### Lua error, crash, or failure after a game update

Close the game, preserve the relevant current-session log, disable this mod in RSMM, and Apply. Compare behavior with it disabled before attributing the fault. Check the loader's compatibility with the updated game. Report exact error text; do not enable experimental flags merely to suppress an unrelated error.

## 6. Technical implementation and lint status

The mod instantiates the SDK's `rsmm.map` factory with its own world-owner validator. It does not overwrite `R.map` or edit `rsmm.lua`. The factory retains the SDK's event construction and dispatch implementation. The validator checks the candidate owner at `dispatcher - 0x340`; it does not apply the learned hero-entity offset to a world dispatcher.

This addresses the earlier failure where a hero-oriented SDK liveness check could start rejecting world dispatchers after the hero layout had been learned. v0.1.0 used a direct-event fallback around that refusal. v0.2.0/0.2.1 removed that fallback. v0.2.2 distributed a separate SDK repair. **v0.2.3 contains the compatibility check within the mod and needs no repair step.**

RSMM lint reports low-level API usage for the internal bindings used by this check. This is an architectural lint failure, not a clean lint pass. The inspected RSMM Apply dry-run completed successfully; lint success and Apply success are different checks. If your manager version refuses the package, report that result rather than assuming all versions behave identically.

## 7. What has been verified

- Offline checks exercised the unchanged SDK map module with a rejecting shared map validator, two run cycles, bounded retries, resets, and rejection of invalid owner/type/build conditions.
- Local v0.2.3 runtime logs showed all four commands dispatched in two consecutive runs without restarting, including a non-host session, without the previous owner-check rejection.
- These logs do not establish complete visible reveal, host-side effects, every hero/chapter, or universal non-host support. Multiplayer remains experimental.

## 8. Updating, rollback, and uninstalling

Always close the game before changing versions. Import the chosen release, replace the old mod entry, enable only one copy, and Apply. Confirm its version in the next session's startup log.

The v0.2.2 release remains available for rollback on GitHub and Nexus. It follows a different installation procedure and needs its bundled SDK repair; consult that release's README only if deliberately reverting to it. Do not run that repair as part of a normal v0.2.3 installation. If it was previously installed, v0.2.3 does not require you to undo it.

To uninstall v0.2.3, close Ravenswatch, disable/remove this mod in RSMM, and Apply. v0.2.3 itself installs no SDK repair that needs reversing. Changes previously made by older versions are a separate matter.

## 9. Information to include in a bug report

Include the mod version from the startup line, RSMM/loader version, game build, solo/host/joined status, chapter, whether it was the first run after launch or a later run, whether any POI icons appeared, and the relevant startup/attempt/error lines from the latest session. State whether other mods were enabled and what happened with this mod disabled. Redact account IDs, session IDs, IP addresses, and unrelated personal data before posting logs publicly.

Downloads: https://github.com/Yanglerfish/RevealAllMapLocations/releases/tag/v0.2.3

Nexus listing: https://www.nexusmods.com/ravenswatch/mods/10
