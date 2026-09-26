# Reveal All Map Locations — RSMM mod


Purpose
-------
Reveals Ravenswatch's normal revealable minimap POI markers each chapter by
firing the game's own CROWS_MAP_REVEAL event.

Target
------
Built against RSMM v5.8.0 / SDK 3.x on 2026-09-26.

Install
-------
1. Install/launch Ravenswatch through RSMM.
2. Put the entire "RevealAllMapLocations" folder in your Ravenswatch mods folder,
   OR import/extract this zip using RSMM if your build supports zip import.
3. Make sure the mod is enabled.
4. Apply/launch through RSMM.
5. Start a run. The reveal is attempted during chapter generation.

What it reveals
---------------
This targets the game's normal minimap POI marker reveal system. It is meant to
show locations that Ravenswatch itself can mark through CROWS_MAP_REVEAL.

It does NOT invent markers for objects that have no minimap-marker component,
and RSMM's own notes say terrain-fog clearing is engine-dependent. The goal is
"show the POI locations", not necessarily "paint every pixel of fog away".

Compatibility / caution
-----------------------
- Uses the public R.map.reveal() API first.
- RSMM v5.8.0 has a world-dispatcher liveness-check quirk, so this mod includes
  a compatibility fallback using R._internal and the same event construction
  used by RSMM's own map.lua.
- Because that fallback uses an internal API, a future RSMM update can break it.
- Test solo first. I have not run Ravenswatch itself in this environment, so
  this package is source-checked rather than in-game verified.
- If it fails, inspect the RSMM mod log for lines beginning:
    [RevealAllMapLocations]

Expected success log
--------------------
[RevealAllMapLocations] revealed POI markers via R.map (...)
or
[RevealAllMapLocations] revealed POI markers via v5.8 fallback (...)


## Quick install

Download dist/RevealAllMapLocations_RSMM_v0.1.0.zip, then import/extract it with Ravenswatch Mod Manager (RSMM), enable the mod, install the Lua loader, and apply mods.

This repository root also contains the raw RSMM mod files (manifest.toml and init.lua) for inspection or manual local install.
