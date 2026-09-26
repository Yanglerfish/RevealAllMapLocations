-- Reveal All Map Locations
-- Target: RSMM v5.8.x / SDK 3.x
--
-- Ravenswatch's own POI reveal mechanic is CROWS_MAP_REVEAL.
-- RSMM exposes R.map.reveal(), but v5.8's dispatcher liveness check is
-- hero-oriented and may reject a world dispatcher. This mod tries the public
-- API first, then falls back to emitting the exact same engine event directly.
--
-- The GENERATE_REWARDS event is known (from RSMM's reverse-engineering notes)
-- to be dispatched on the world dispatcher during chapter load.
-- MAP_GENERATION_DONE gives us a later "the chapter is built" point at which
-- to reveal the markers. We also attempt once at GENERATE_REWARDS so the mod
-- remains useful if event order changes.

local R = require "rsmm"
local I = R._internal

R.health.checkpoint("per_mod:RevealAllMapLocations")

local EVENT = "CROWS_MAP_REVEAL"
local EVENT_CRC = 0xF3196C6D  -- standard CRC32("CROWS_MAP_REVEAL")

local world_dispatcher = nil
local revealed_for_cycle = false

local function ptr(v)
    if type(v) == "number" then
        return v
    end
    if type(v) == "string" then
        return tonumber(v)
    end
    return nil
end

local function raw_reveal(disp)
    if not disp or disp == 0 then
        return false, "no dispatcher"
    end

    if not I then
        return false, "R._internal unavailable"
    end

    local ctor = R.engine.resolve("NamedEvent_GiveMagicalObject_Ctor")
    local idfn = R.engine.resolve("NamedEvent_Id_FromCrc")
    local send = R.engine.resolve("NamedEvent_Dispatch")
    if not ctor or not idfn or not send then
        return false, "required event symbols unresolved"
    end

    -- Same event construction used by RSMM's own map.lua.
    local buf = I.scratch(0x80)
    if not buf or buf == 0 then
        return false, "scratch allocation failed"
    end

    local ev = R.engine.call("NamedEvent_GiveMagicalObject_Ctor", buf)
    if not ev or ev == 0 then
        return false, "event constructor failed"
    end

    -- This constructor is borrowed from GIVE_MAGICAL_OBJECT. The map-reveal
    -- listener reads no payload, so zero the unused magical-object GUID.
    I.poke(ev + 0x50, 0, 8)
    I.poke(ev + 0x58, 0, 8)

    -- Put the plaintext event name in the same scratch allocation.
    local tail = buf + 0x60
    for i = 1, #EVENT do
        I.write_u8(tail + i - 1, EVENT:byte(i))
    end
    I.write_u8(tail + #EVENT, 0)

    I.write_u64(ev + 0x20, tail)
    I.write_u32(ev + 0x28, 0x80000000 + #EVENT) -- unowned string
    I.write_u32(ev + 0x2C, 0)

    local event_id = R.engine.call("NamedEvent_Id_FromCrc", 0, EVENT_CRC)
    if not event_id or event_id == 0 then
        return false, "could not intern event id"
    end
    I.write_u32(ev + 0x30, event_id)

    R.engine.call("NamedEvent_Dispatch", disp, ev)
    return true
end

local function reveal(disp, reason)
    if not disp or disp == 0 then
        R.log("[RevealAllMapLocations] " .. reason .. ": no dispatcher")
        return false
    end

    -- Prefer RSMM's supported API. On v5.8 it can reject a world dispatcher,
    -- in which case we use the compatibility path below.
    if R.map and R.map.reveal then
        local ok, result = pcall(R.map.reveal, disp)
        if ok and result then
            R.log("[RevealAllMapLocations] revealed POI markers via R.map (" .. reason .. ")")
            revealed_for_cycle = true
            return true
        end
    end

    local ok, why = raw_reveal(disp)
    if ok then
        R.log("[RevealAllMapLocations] revealed POI markers via v5.8 fallback (" .. reason .. ")")
        revealed_for_cycle = true
        return true
    end

    R.log("[RevealAllMapLocations] reveal failed (" .. reason .. "): " .. tostring(why))
    return false
end

-- Confirmed by RSMM's RE notes to use the world dispatcher during level load.
R.on("gameplay:GENERATE_REWARDS", function(ev)
    local d = ptr(ev and ev.dispatcher)
    if d then
        world_dispatcher = d
    end

    -- This may be early, but it is harmless and gives us a fallback if the
    -- later map-generation event changes in a future build.
    reveal(world_dispatcher or d, "GENERATE_REWARDS")
end)

-- Fires once per chapter. By this point the generated chapter should be built,
-- making it the best point to reveal its normal map markers.
R.on("gameplay:MAP_GENERATION_DONE", function(ev)
    local d = world_dispatcher or ptr(ev and ev.dispatcher)
    reveal(d, "MAP_GENERATION_DONE")
end)

-- GAME_START re-fires per chapter. One more attempt is useful if the game's
-- loading order changed and the earlier reveal landed before all markers were
-- listening. Avoid spamming after a successful attempt.
R.on("gameplay:GAME_START", function(ev)
    if not revealed_for_cycle then
        local d = world_dispatcher or ptr(ev and ev.dispatcher)
        reveal(d, "GAME_START")
    end
end)

-- Reset chapter-local state before the next chapter is built.
R.on("gameplay:GAME_END_NEXT_CHAPTER", function()
    world_dispatcher = nil
    revealed_for_cycle = false
end)

R.on("ready", function()
    R.log("[RevealAllMapLocations] loaded; waiting for chapter-generation events")
end)
