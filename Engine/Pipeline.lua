-------------------------------------------------------------------------------
-- Pipeline.lua
-- Main computation pipeline: snapshot → result
-- Pure Lua — no WoW API calls
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local Pipeline = {}
ns.Engine.Pipeline = Pipeline

-------------------------------------------------------------------------------
-- Calculate(spellID, playerState)
-- Full pipeline for a single spell: base → modifiers → crit/hit → result.
-- Returns a SpellResult table, or nil if spellID is unknown.
-------------------------------------------------------------------------------
function Pipeline.Calculate(spellID, playerState)
    local spellData = ns.SpellData[spellID]
    if not spellData then
        return nil
    end

    local SpellCalc = ns.Engine.SpellCalc
    local ModifierCalc = ns.Engine.ModifierCalc
    local CritCalc = ns.Engine.CritCalc

    -- Step 1: Determine rank
    local rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
    if not rankNum then
        return nil
    end

    -- Step 2: Compute base damage
    local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
    if not baseResult then
        return nil
    end

    -- Step 3: Apply talent and aura modifiers
    local modifiedResult, modifiers = ModifierCalc.ApplyModifiers(
        baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
    )

    -- Step 4: Apply crit/hit expected values
    local finalResult = CritCalc.ApplyExpectedCrit(modifiedResult, spellData, playerState, modifiers)

    -- Step 5: Attach rank number
    finalResult.rank = rankNum

    return finalResult
end

-------------------------------------------------------------------------------
-- CalculateAll(playerState)
-- Runs the full pipeline for every spell in ns.SpellData.
-- Returns an array of SpellResult tables, sorted by spell name.
-------------------------------------------------------------------------------
function Pipeline.CalculateAll(playerState)
    local results = {}

    for spellID, _ in pairs(ns.SpellData) do
        local result = Pipeline.Calculate(spellID, playerState)
        if result then
            results[#results + 1] = result
        end
    end

    table.sort(results, function(a, b)
        return a.spellName < b.spellName
    end)

    return results
end

-------------------------------------------------------------------------------
-- CalculateByName(spellName, playerState)
-- Finds a spell by name (case-insensitive) and runs the pipeline.
-- Returns a SpellResult table, or nil if no matching spell is found.
-------------------------------------------------------------------------------
function Pipeline.CalculateByName(spellName, playerState)
    local lowerName = string.lower(spellName)

    for spellID, spellData in pairs(ns.SpellData) do
        if string.lower(spellData.name) == lowerName then
            return Pipeline.Calculate(spellID, playerState)
        end
    end

    return nil
end
