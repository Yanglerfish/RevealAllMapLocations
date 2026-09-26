-- v0.2.3: clients may never receive MAP_GENERATION_DONE.
local R = require "rsmm"
-- Keep the compatibility check inside this mod. Do not replace R.map or SDK files.
local I = R._internal
local function world_live(d)
    if type(d) ~= "number" or d < 0x10000 or d % 8 ~= 0 then return false end
    if not I or not I.va_trusted or I.va_trusted() ~= true then return false end
    if not I.module_base or not I.read_u64 or not R.rtti or not R.rtti.name then return false end
    local owner = d - 0x340
    local base = I.module_base()
    local vt = I.read_u64(owner)
    if not base or base == 0 or not vt or vt < base or vt >= base + 0x1600000 then return false end
    return R.rtti.name(owner) == "oCEntitySceneContext"
end
local ok_factory, factory = pcall(require, "rsmm.map")
local map
if ok_factory and type(factory) == "function" then
    local ok, result = pcall(factory, {
        R = R, I = I, give_hero = function() return nil end,
        obj_has_vtable = world_live,
    })
    if ok and type(result) == "table" then map = result end
end
if not map then
    R.log("[RevealAllMapLocations] BLOCKED: compatible RSMM map module missing")
    return
end
local world, attempts, next_try, busy = nil, 0, 0, false
local actions = {
    ["gameplay:ABILITY_EXIT"] = true,
    ["gameplay:COMBO_LINK"] = true,
    ["gameplay:INTERACTION_VALIDATE"] = true,
    ["gameplay:GAIN_DREAM_SHARDS"] = true,
}
local function reset()
    world, attempts, next_try, busy = nil, 0, 0, false
    if map.rearm then map.rearm() end
end
local function reveal(reason)
    if not world or busy or attempts >= 4 then return end
    attempts = attempts + 1
    next_try = os.time() + 5
    busy = true
    local ok, result = pcall(map.reveal, world)
    busy = false
    R.log("[RevealAllMapLocations] attempt=" .. attempts .. " reason=" .. reason
        .. " dispatched=" .. tostring(ok and result == true)
        .. "; visual result requires in-game check")
end
R.on("run:start", reset)
R.on("run:end", reset)
R.on("menu:enter", reset)
R.on("gameplay:GAME_END_NEXT_CHAPTER", reset)
R.on("gameplay:GENERATE_REWARDS", function(ev)
    if not ev or ev.source ~= "gameplay" then return end
    local d = tonumber(ev.dispatcher)
    if not d or d == 0 then return end
    if world ~= d then reset(); world = d end
    if attempts == 0 then reveal("GENERATE_REWARDS") end
end)
R.on("*", function(ev, name)
    if not ev or ev.source ~= "gameplay" or not world or busy then return end
    if actions[name] and os.time() >= next_try then
        reveal("player activity after map generation")
    end
end)
R.on("ready", function()
    R.log("[RevealAllMapLocations] v0.2.3 loaded; self-contained world-owner check; no SDK repair needed")
end)
