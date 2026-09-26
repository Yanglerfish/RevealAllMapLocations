-- v0.2.2: clients may never receive MAP_GENERATION_DONE.
local R = require "rsmm"
local world, attempts, next_try, busy = nil, 0, 0, false
local actions = {
    ["gameplay:ABILITY_EXIT"] = true,
    ["gameplay:COMBO_LINK"] = true,
    ["gameplay:INTERACTION_VALIDATE"] = true,
    ["gameplay:GAIN_DREAM_SHARDS"] = true,
}
local function reset()
    world, attempts, next_try, busy = nil, 0, 0, false
    if R.map.rearm then R.map.rearm() end
end
local function reveal(reason)
    if not world or busy or attempts >= 4 then return end
    attempts = attempts + 1
    next_try = os.time() + 5
    busy = true
    local ok, result = pcall(R.map.reveal, world)
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
    R.log("[RevealAllMapLocations] v0.2.2 loaded; bounded delayed reveal; capture not required")
end)
