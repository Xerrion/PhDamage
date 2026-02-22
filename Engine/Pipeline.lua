-------------------------------------------------------------------------------
-- Pipeline.lua
-- Main computation pipeline: snapshot → result
-- Pure Lua — no WoW API calls
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

local Pipeline = {}
ns.Engine.Pipeline = Pipeline

-------------------------------------------------------------------------------
-- Calculate(spellID, playerState, rankIndex)
-- Full pipeline for a single spell: base → modifiers → crit/hit → result.
-- If rankIndex is provided, uses that specific rank instead of the highest.
-- Returns a SpellResult table, or nil if spellID is unknown.
-------------------------------------------------------------------------------
function Pipeline.Calculate(spellID, playerState, rankIndex)
    local spellData = ns.SpellData[spellID]
    if not spellData then
        return nil
    end

    local SpellCalc = ns.Engine.SpellCalc
    local ModifierCalc = ns.Engine.ModifierCalc
    local CritCalc = ns.Engine.CritCalc

    -- Step 1: Determine rank
    local rankNum, rankData
    if rankIndex and spellData.ranks and spellData.ranks[rankIndex] then
        rankNum = rankIndex
        rankData = spellData.ranks[rankIndex]
    else
        rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
    end
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
    if not modifiedResult then
        return nil
    end

    -- Step 4: Apply crit/hit expected values
    local finalResult = CritCalc.ApplyExpectedCrit(modifiedResult, spellData, playerState, modifiers)

    -- Step 5: Attach rank number
    finalResult.rank = rankNum
    finalResult.outputType = spellData.outputType

    return finalResult
end

-------------------------------------------------------------------------------
-- CalculateAll(playerState)
-- Runs the full pipeline for every spell in ns.SpellData.
-- Returns an array of SpellResult tables, sorted by spell name.
-------------------------------------------------------------------------------
function Pipeline.CalculateAll(playerState)
    local allResults = {}
    local n = 0

    for spellID, _ in pairs(ns.SpellData) do
        local result = Pipeline.Calculate(spellID, playerState)
        if result then
            n = n + 1
            allResults[n] = result
        end
    end

    table.sort(allResults, function(a, b)
        local aDps = a.dps or 0
        local bDps = b.dps or 0
        if aDps ~= bDps then
            return aDps > bDps
        end
        return a.spellName < b.spellName
    end)

    return allResults
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
