-------------------------------------------------------------------------------
-- Tooltip.lua
-- Hooks GameTooltip to display expected damage/DPS for supported spells
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

local Tooltip = {}
ns.Tooltip = Tooltip

-- Cache WoW globals
local GameTooltip = GameTooltip
local CreateFrame = CreateFrame
local pairs = pairs
local format = string.format
local floor = math.floor
local concat = table.concat

-- SpellID reverse lookup: rankSpellID → { spellKey, rankIndex }
local spellIDMap = {}

-- Re-entry guard: tracks the spellID last appended to avoid duplicate lines
local lastTooltipSpellID = nil

-- Color constants
local COLOR_GOLD = "|cffffd100"
local COLOR_GREEN = "|cff00ff00"
local COLOR_WHITE = "|cffffffff"
local COLOR_RESET = "|r"

-- Separator line (gray dashes)
local SEPARATOR = string.rep("\226\128\148", 20) -- em-dash ─ repeated

-------------------------------------------------------------------------------
-- Formatting Helpers (exposed on ns.Tooltip for testability)
-------------------------------------------------------------------------------

--- Formats a number for compact tooltip display.
-- >= 10000 → "15k", >= 1000 → "1.5k", otherwise → integer "581"
function Tooltip.FormatNumber(n)
    if n == nil then return "?" end
    if n >= 10000 then
        return format("%.0fk", n / 1000)
    elseif n >= 1000 then
        return format("%.1fk", n / 1000)
    else
        return tostring(floor(n + 0.5))
    end
end

--- Formats a DPS/HPS value with one decimal place.
-- Uses the same "k" suffix logic for large values.
function Tooltip.FormatDPS(n)
    if n == nil then return "?" end
    if n >= 10000 then
        return format("%.0fk", n / 1000)
    elseif n >= 1000 then
        return format("%.1fk", n / 1000)
    else
        return format("%.1f", n)
    end
end

--- Returns the color escape code for a spell school bitmask.
-- Falls back to white for unknown schools.
function Tooltip.GetSchoolColor(school)
    return ns.SCHOOL_COLORS and ns.SCHOOL_COLORS[school] or COLOR_WHITE
end

--- Wraps a formatted string in school color codes.
function Tooltip.ColorValue(text, school)
    return Tooltip.GetSchoolColor(school) .. text .. COLOR_RESET
end

-- Local aliases for brevity inside this file
local FN = Tooltip.FormatNumber
local FD = Tooltip.FormatDPS

-------------------------------------------------------------------------------
-- BuildSpellIDMap
-- Creates a reverse lookup from rank-specific spellID → { spellKey, rankIndex }.
-- spellKey is the base spellID used as the key in ns.SpellData.
-------------------------------------------------------------------------------

local function BuildSpellIDMap()
    for spellKey, spellData in pairs(ns.SpellData) do
        if spellData.ranks then
            for rankIdx, rankData in pairs(spellData.ranks) do
                spellIDMap[rankData.spellID] = { spellKey = spellKey, rankIndex = rankIdx }
            end
        end
    end
end

-------------------------------------------------------------------------------
-- GetSpellIDMap — expose the reverse lookup for ActionBar.lua to reuse
-------------------------------------------------------------------------------

function Tooltip.GetSpellIDMap()
    return spellIDMap
end

-------------------------------------------------------------------------------
-- Output type helpers
-------------------------------------------------------------------------------

local function GetValueLabel(outputType)
    if outputType == "healing" then return "healing expected"
    elseif outputType == "absorption" then return "absorption"
    else return "expected" end
end

local function GetRateLabel(outputType)
    if outputType == "healing" then return "HPS"
    elseif outputType == "absorption" then return "APS"
    else return "DPS" end
end

local function GetPowerLabel(r)
    -- Melee results have dodgeChance set by CritCalc
    if r.dodgeChance ~= nil then return "AP" end
    return "SP"
end

-------------------------------------------------------------------------------
-- Separator
-------------------------------------------------------------------------------

local function AddSeparator()
    GameTooltip:AddLine(SEPARATOR, 0.4, 0.4, 0.4)
end

-------------------------------------------------------------------------------
-- Stats line builder
-------------------------------------------------------------------------------

local function AddStatsLine(r)
    local parts = {}
    local powerLabel = GetPowerLabel(r)

    parts[#parts + 1] = format("+%s %s", FN(r.spellPowerBonus or 0), powerLabel)

    if (r.critChance or 0) > 0 then
        parts[#parts + 1] = format("%.1f%% crit (\195\151%.2f)", r.critChance * 100, r.critMultiplier or 0)
    end

    if r.hitChance then
        parts[#parts + 1] = format("%d%% hit", floor(r.hitChance * 100 + 0.5))
    end

    GameTooltip:AddLine("  Stats:  " .. concat(parts, "  |  "), 0.67, 0.67, 0.67)
end

--- Adds melee-specific stats as two lines (AP/crit, then hit/dodge/armor)
local function AddMeleeStatsLines(r)
    -- Line 1: AP + crit
    local parts1 = {}
    parts1[#parts1 + 1] = format("+%s AP", FN(r.spellPowerBonus or 0))
    if (r.critChance or 0) > 0 then
        parts1[#parts1 + 1] = format("%.1f%% crit (\195\151%.2f)", r.critChance * 100, r.critMultiplier or 0)
    end
    GameTooltip:AddLine("  Stats:  " .. concat(parts1, "  |  "), 0.67, 0.67, 0.67)

    -- Line 2: hit + dodge + parry (if from front) + armor
    local parts2 = {}
    if r.hitChance then
        parts2[#parts2 + 1] = format("%d%% hit", floor(r.hitChance * 100 + 0.5))
    end
    if r.dodgeChance and r.dodgeChance > 0 then
        parts2[#parts2 + 1] = format("%.1f%% dodge", r.dodgeChance * 100)
    end
    if r.parryChance and r.parryChance > 0 then
        parts2[#parts2 + 1] = format("%.1f%% parry", r.parryChance * 100)
    end
    if r.armorReduction and r.armorReduction > 0 then
        parts2[#parts2 + 1] = format("%.0f%% armor", r.armorReduction * 100)
    end
    if #parts2 > 0 then
        GameTooltip:AddLine("  Avoidance:  " .. concat(parts2, "  |  "), 0.67, 0.67, 0.67)
    end
end

-------------------------------------------------------------------------------
-- Header line (shared across all damage/heal types)
-------------------------------------------------------------------------------

local function AddHeaderLine(r)
    local valueLabel = GetValueLabel(r.outputType)
    local rateLabel = GetRateLabel(r.outputType)
    local schoolColor = Tooltip.GetSchoolColor(r.school)
    local dmgStr = schoolColor .. FN(r.expectedDamageWithMiss) .. COLOR_RESET
    local dpsStr = COLOR_GREEN .. FD(r.dps) .. " " .. rateLabel .. COLOR_RESET

    GameTooltip:AddLine(
        format("%sPhDamage:%s  %s %s  (%s)", COLOR_GOLD, COLOR_RESET, dmgStr, valueLabel, dpsStr),
        1, 1, 1
    )
end

-------------------------------------------------------------------------------
-- Spell-type-specific line builders
-------------------------------------------------------------------------------

--- Direct damage/heal spell (3 lines, or 4 for melee)
local function AddDirectLines(r)
    AddHeaderLine(r)
    if r.dodgeChance ~= nil then
        AddMeleeStatsLines(r)
    else
        AddStatsLine(r)
    end
end

--- DoT spell (4 lines)
local function AddDotLines(r)
    AddHeaderLine(r)

    -- Tick info line
    local sc = Tooltip.GetSchoolColor(r.school)
    local tickStr = sc .. FN(r.tickDamage or r.tickDmg or 0) .. COLOR_RESET
    local totalStr = sc .. FN(r.expectedDamageWithMiss or 0) .. COLOR_RESET
    local durStr = format("%ds, %d ticks", r.duration or 0, r.numTicks or 0)
    GameTooltip:AddLine(
        format("  Breakdown:  %s/tick  |  %s total  (%s)", tickStr, totalStr, durStr),
        0.67, 0.67, 0.67
    )

    AddStatsLine(r)
end

--- Hybrid spell (5 lines)
local function AddHybridLines(r)
    AddHeaderLine(r)

    local sc = Tooltip.GetSchoolColor(r.school)

    -- Direct line
    local directStr = sc .. FN(r.directDamage or 0) .. COLOR_RESET
    local directParts = { format("Direct:  %s", directStr) }
    if (r.critChance or 0) > 0 then
        directParts[#directParts + 1] = format("%.1f%% crit (\195\151%.2f)", r.critChance * 100, r.critMultiplier or 0)
    end
    GameTooltip:AddLine("  " .. concat(directParts, "  |  "), 0.67, 0.67, 0.67)

    -- DoT line
    local tickStr = sc .. FN(r.tickDamage or 0) .. COLOR_RESET
    local dotTotalStr = sc .. FN(r.dotDamage or 0) .. COLOR_RESET
    local durStr = format("%ds, %d ticks", r.duration or 0, r.numTicks or 0)
    GameTooltip:AddLine(
        format("  DoT:  %s/tick  |  %s total  (%s)", tickStr, dotTotalStr, durStr),
        0.67, 0.67, 0.67
    )

    -- Stats line (no crit — already shown on direct line)
    local statParts = {}
    statParts[#statParts + 1] = format("+%s SP", FN(r.spellPowerBonus or 0))
    if r.hitChance then
        statParts[#statParts + 1] = format("%d%% hit", floor(r.hitChance * 100 + 0.5))
    end
    GameTooltip:AddLine("  Stats:  " .. concat(statParts, "  |  "), 0.67, 0.67, 0.67)
end

--- Channel spell (4 lines)
local function AddChannelLines(r)
    AddHeaderLine(r)

    -- Tick info line
    local sc = Tooltip.GetSchoolColor(r.school)
    local tickStr = sc .. FN(r.tickDamage or r.tickDmg or 0) .. COLOR_RESET
    local totalStr = sc .. FN(r.expectedDamageWithMiss or 0) .. COLOR_RESET
    local durStr = format("%ds, %d ticks", r.duration or 0, r.numTicks or 0)
    GameTooltip:AddLine(
        format("  Breakdown:  %s/tick  |  %s total  (%s)", tickStr, totalStr, durStr),
        0.67, 0.67, 0.67
    )

    AddStatsLine(r)
end

--- Utility spell (2 lines)
local function AddUtilityLines(r)
    if r.healthCost then
        -- Life Tap style: health cost → mana gain (+SP bonus)
        GameTooltip:AddLine(
            format("%sPhDamage:%s  %s HP \226\134\146 %s mana  (%s+%s SP%s)",
                COLOR_GOLD, COLOR_RESET,
                FN(r.healthCost),
                FN(r.manaGain),
                COLOR_GREEN, FN(r.spellPowerBonus or 0), COLOR_RESET),
            1, 1, 1
        )
    else
        -- Dark Pact style: mana gain only (+SP bonus)
        GameTooltip:AddLine(
            format("%sPhDamage:%s  %s mana  (%s+%s SP%s)",
                COLOR_GOLD, COLOR_RESET,
                FN(r.manaGain),
                COLOR_GREEN, FN(r.spellPowerBonus or 0), COLOR_RESET),
            1, 1, 1
        )
    end
end

-------------------------------------------------------------------------------
-- Main dispatcher
-------------------------------------------------------------------------------

local function AddTooltipLines(r)
    AddSeparator()

    if r.spellType == "utility" then
        AddUtilityLines(r)
    elseif r.spellType == "hybrid" then
        AddHybridLines(r)
    elseif r.spellType == "dot" then
        AddDotLines(r)
    elseif r.spellType == "channel" then
        AddChannelLines(r)
    else
        AddDirectLines(r)
    end

    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- Tooltip hook handler
-------------------------------------------------------------------------------

local function OnTooltipSetSpell(tooltip)
    local _, a, b = tooltip:GetSpell()
    local spellID = (type(b) == "number" and b) or (type(a) == "number" and a)
    if not spellID then return end

    -- Guard against re-entry (OnTooltipSetSpell can fire more than once)
    if spellID == lastTooltipSpellID then return end

    -- Look up the rank-specific spellID in the reverse map
    local lookup = spellIDMap[spellID]
    if not lookup then return end

    -- Get current player state (uses cached snapshot, refreshed on relevant events)
    local playerState = ns.StateCollector.GetCachedState()
    if not playerState then return end

    -- Run the full computation pipeline for the specific rank being hovered
    local result = ns.Engine.Pipeline.Calculate(lookup.spellKey, playerState, lookup.rankIndex)
    if not result then return end

    -- Mark this spellID as processed only after all guards pass
    lastTooltipSpellID = spellID

    -- Append formatted lines to the tooltip
    AddTooltipLines(result)
end

-------------------------------------------------------------------------------
-- HookTooltip — attaches the tooltip hooks (called once during init)
-------------------------------------------------------------------------------

local function HookTooltip()
    GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)

    -- Clear the re-entry guard when the tooltip is cleared
    GameTooltip:HookScript("OnTooltipCleared", function()
        lastTooltipSpellID = nil
    end)
end

-------------------------------------------------------------------------------
-- Initialization — deferred to PLAYER_LOGIN to ensure all data is ready
-------------------------------------------------------------------------------

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")
        BuildSpellIDMap()
        HookTooltip()
    end
end)
