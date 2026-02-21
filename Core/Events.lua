-------------------------------------------------------------------------------
-- Events.lua
-- WoW event registration and state invalidation triggers
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local Events = {}
ns.Events = Events

-- Events that should trigger a full state rebuild
local STATE_EVENTS = {
    "PLAYER_ENTERING_WORLD",
    "UNIT_AURA",
    "CHARACTER_POINTS_CHANGED",
    "PLAYER_DAMAGE_DONE_MODS",
    "SPELL_POWER_CHANGED",          -- Exists in TBC 2.5.5; pcall as defensive measure
    "UNIT_STATS",
    "PLAYER_TALENT_UPDATE",
    "ACTIVE_TALENT_GROUP_CHANGED",
    "PLAYER_EQUIPMENT_CHANGED",
}

-- Resolve the Addon object lazily to handle load order gracefully
local function GetAddon()
    return ns.Addon
end

function Events.RegisterAll()
    local addon = GetAddon()
    if not addon then return end

    for _, event in ipairs(STATE_EVENTS) do
        pcall(function()
            addon:RegisterEvent(event, Events.OnStateEvent)
        end)
    end
end

function Events.UnregisterAll()
    local addon = GetAddon()
    if not addon then return end

    for _, event in ipairs(STATE_EVENTS) do
        pcall(function()
            addon:UnregisterEvent(event)
        end)
    end
end

function Events.OnStateEvent(event, arg1, ...)
    -- UNIT_AURA and UNIT_STATS fire for all units; care about player and target
    if (event == "UNIT_AURA" or event == "UNIT_STATS") and arg1 ~= "player" and arg1 ~= "target" then
        return
    end

    -- Invalidate cached state
    if ns.StateCollector then
        ns.StateCollector.Invalidate()
    end

    -- Initialize ActionBar on first PLAYER_ENTERING_WORLD (buttons must exist)
    if event == "PLAYER_ENTERING_WORLD" and ns.ActionBar and ns.ActionBar.Initialize then
        ns.ActionBar.Initialize()
    end

    -- Fire internal message for any listeners
    local addon = GetAddon()
    if addon then
        addon:SendMessage("PHDAMAGE_STATE_CHANGED", event)
    end
end
