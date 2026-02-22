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
local COLOR_LABEL = "|cffc0a060"   -- Soft gold for labels

-------------------------------------------------------------------------------
-- Companion tooltip frame
-------------------------------------------------------------------------------

local PADDING = 10
local LINE_SPACING = 2
local MIN_WIDTH = 150

-- Created at init time
local companionFrame

-- FontString pool
local fontStrings = {}
local numActiveLines = 0

local function GetFontString(index)
    if fontStrings[index] then return fontStrings[index] end
    local fs = companionFrame:CreateFontString(nil, "ARTWORK")
    fs:SetFontObject(GameTooltipText)
    fs:SetJustifyH("LEFT")
    fontStrings[index] = fs
    return fs
end

local function AddLine(text, r, g, b)
    numActiveLines = numActiveLines + 1
    local fs = GetFontString(numActiveLines)
    if r and g and b then
        text = format("|cff%02x%02x%02x%s|r",
            floor(r * 255 + 0.5), floor(g * 255 + 0.5), floor(b * 255 + 0.5), text)
    end
    fs:SetText(text)
    fs:Show()
end

local function ResetLines()
    for i = 1, numActiveLines do
        fontStrings[i]:Hide()
    end
    numActiveLines = 0
end

local function FinalizeFrame()
    if numActiveLines == 0 then
        companionFrame:Hide()
        return
    end

    -- Measure widest line
    local maxWidth = MIN_WIDTH
    for i = 1, numActiveLines do
        local w = fontStrings[i]:GetStringWidth()
        if w > maxWidth then maxWidth = w end
    end

    -- Layout lines vertically
    local lineHeight = select(2, fontStrings[1]:GetFont())
    for i = 1, numActiveLines do
        fontStrings[i]:ClearAllPoints()
        fontStrings[i]:SetPoint("TOPLEFT", companionFrame, "TOPLEFT",
            PADDING, -PADDING - (i - 1) * (lineHeight + LINE_SPACING))
    end

    local totalHeight = PADDING * 2 + numActiveLines * lineHeight
        + (numActiveLines - 1) * LINE_SPACING

    companionFrame:SetSize(maxWidth + PADDING * 2, totalHeight)

    -- Re-anchor to GameTooltip (it may have moved)
    companionFrame:ClearAllPoints()
    companionFrame:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 0, -4)
    companionFrame:Show()
end

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
-- Scaling line builder
-------------------------------------------------------------------------------

local function AddScalingLine(r)
    -- Skip for utility spells
    if r.spellType == "utility" then return end

    local isMelee = r.dodgeChance ~= nil

    -- Coefficient line (skip for melee)
    if not isMelee then
        if r.spellType == "hybrid" and r.directSpBonus and r.dotSpBonus then
            local directCoeff = (r.spellPowerBonus or 0) > 0
                and (r.directSpBonus / r.spellPowerBonus) or 0
            local dotCoeff = (r.spellPowerBonus or 0) > 0
                and (r.dotSpBonus / r.spellPowerBonus) or 0
            AddLine(format("  %sCoeff:%s  %s%.2f+%.2f%s",
                COLOR_LABEL, COLOR_RESET, COLOR_WHITE, directCoeff, dotCoeff, COLOR_RESET))
        elseif r.coefficient then
            AddLine(format("  %sCoeff:%s  %s%.3f%s",
                COLOR_LABEL, COLOR_RESET, COLOR_WHITE, r.coefficient, COLOR_RESET))
        end
    end

    -- Cast time line
    if (r.baseCastTime or 0) <= 0 then
        AddLine(format("  %sCast:%s  %sinstant%s",
            COLOR_LABEL, COLOR_RESET, COLOR_WHITE, COLOR_RESET))
    elseif r.spellType == "channel" then
        AddLine(format("  %sCast:%s  %s%.1fs channel%s",
            COLOR_LABEL, COLOR_RESET, COLOR_WHITE, r.castTime, COLOR_RESET))
    else
        AddLine(format("  %sCast:%s  %s%.1fs%s",
            COLOR_LABEL, COLOR_RESET, COLOR_WHITE, r.castTime, COLOR_RESET))
    end

    -- Talent damage bonus line
    if (r.talentDamageBonus or 0) > 0 then
        AddLine(format("  %sTalents:%s  %s+%.0f%%%s",
            COLOR_LABEL, COLOR_RESET, COLOR_GREEN, r.talentDamageBonus * 100, COLOR_RESET))
    end
end

-------------------------------------------------------------------------------
-- Stats line builder
-------------------------------------------------------------------------------

local function AddStatsLine(r)
    local powerLabel = GetPowerLabel(r)
    local parts = {}

    parts[#parts + 1] = format("%s+%s%s %s", COLOR_WHITE, FN(r.spellPowerBonus or 0), COLOR_RESET, powerLabel)

    if (r.critChance or 0) > 0 then
        parts[#parts + 1] = format("%s%.1f%%%s crit (%s\195\151%.2f%s)",
            COLOR_WHITE, r.critChance * 100, COLOR_RESET,
            COLOR_WHITE, r.critMultiplier or 0, COLOR_RESET)
    end

    if r.hitChance then
        parts[#parts + 1] = format("%s%d%%%s hit",
            COLOR_WHITE, floor(r.hitChance * 100 + 0.5), COLOR_RESET)
    end

    AddLine(format("  %sStats:%s  ", COLOR_LABEL, COLOR_RESET) .. concat(parts, "  |  "))
end

--- Adds melee-specific stats as two lines (AP/crit, then hit/dodge/armor)
local function AddMeleeStatsLines(r)
    -- Line 1: AP + crit
    local parts1 = {}
    parts1[#parts1 + 1] = format("%s+%s%s AP", COLOR_WHITE, FN(r.spellPowerBonus or 0), COLOR_RESET)
    if (r.critChance or 0) > 0 then
        parts1[#parts1 + 1] = format("%s%.1f%%%s crit (%s\195\151%.2f%s)",
            COLOR_WHITE, r.critChance * 100, COLOR_RESET,
            COLOR_WHITE, r.critMultiplier or 0, COLOR_RESET)
    end
    AddLine(format("  %sStats:%s  ", COLOR_LABEL, COLOR_RESET) .. concat(parts1, "  |  "))

    -- Line 2: hit + dodge + parry + armor
    local parts2 = {}
    if r.hitChance then
        parts2[#parts2 + 1] = format("%s%d%%%s hit",
            COLOR_WHITE, floor(r.hitChance * 100 + 0.5), COLOR_RESET)
    end
    if r.dodgeChance and r.dodgeChance > 0 then
        parts2[#parts2 + 1] = format("%s%.1f%%%s dodge",
            COLOR_WHITE, r.dodgeChance * 100, COLOR_RESET)
    end
    if r.parryChance and r.parryChance > 0 then
        parts2[#parts2 + 1] = format("%s%.1f%%%s parry",
            COLOR_WHITE, r.parryChance * 100, COLOR_RESET)
    end
    if r.armorReduction and r.armorReduction > 0 then
        parts2[#parts2 + 1] = format("%s%.0f%%%s armor",
            COLOR_WHITE, r.armorReduction * 100, COLOR_RESET)
    end
    if #parts2 > 0 then
        AddLine(format("  %sAvoidance:%s  ", COLOR_LABEL, COLOR_RESET) .. concat(parts2, "  |  "))
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

    AddLine(
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
    AddScalingLine(r)
    if r.dodgeChance ~= nil then
        AddMeleeStatsLines(r)
    else
        AddStatsLine(r)
    end
end

--- DoT spell (4 lines)
local function AddDotLines(r)
    AddHeaderLine(r)
    AddScalingLine(r)

    -- Tick info line
    local sc = Tooltip.GetSchoolColor(r.school)
    local tickStr = sc .. FN(r.tickDamage or r.tickDmg or 0) .. COLOR_RESET
    local totalStr = sc .. FN(r.expectedDamageWithMiss or 0) .. COLOR_RESET
    local durStr = format("%ds, %d ticks", r.duration or 0, r.numTicks or 0)
    AddLine(
        format("  %sBreakdown:%s  %s/tick  |  %s total  (%s)", COLOR_LABEL, COLOR_RESET, tickStr, totalStr, durStr)
    )

    AddStatsLine(r)
end

--- Hybrid spell (5 lines)
local function AddHybridLines(r)
    AddHeaderLine(r)
    AddScalingLine(r)

    local sc = Tooltip.GetSchoolColor(r.school)

    -- Direct line
    local directStr = sc .. FN(r.directDamage or 0) .. COLOR_RESET
    local directParts = { format("%sDirect:%s  %s", COLOR_LABEL, COLOR_RESET, directStr) }
    if (r.critChance or 0) > 0 then
        directParts[#directParts + 1] = format("%s%.1f%%%s crit (%s\195\151%.2f%s)",
            COLOR_WHITE, r.critChance * 100, COLOR_RESET,
            COLOR_WHITE, r.critMultiplier or 0, COLOR_RESET)
    end
    AddLine("  " .. concat(directParts, "  |  "))

    -- DoT line
    local tickStr = sc .. FN(r.tickDamage or 0) .. COLOR_RESET
    local dotTotalStr = sc .. FN(r.dotDamage or 0) .. COLOR_RESET
    local durStr = format("%ds, %d ticks", r.duration or 0, r.numTicks or 0)
    AddLine(
        format("  %sDoT:%s  %s/tick  |  %s total  (%s)", COLOR_LABEL, COLOR_RESET, tickStr, dotTotalStr, durStr)
    )

    -- Stats line (no crit — already shown on direct line)
    local statParts = {}
    statParts[#statParts + 1] = format("%s+%s%s SP", COLOR_WHITE, FN(r.spellPowerBonus or 0), COLOR_RESET)
    if r.hitChance then
        statParts[#statParts + 1] = format("%s%d%%%s hit",
            COLOR_WHITE, floor(r.hitChance * 100 + 0.5), COLOR_RESET)
    end
    AddLine(format("  %sStats:%s  ", COLOR_LABEL, COLOR_RESET) .. concat(statParts, "  |  "))
end

--- Channel spell (4 lines)
local function AddChannelLines(r)
    AddHeaderLine(r)
    AddScalingLine(r)

    -- Tick info line
    local sc = Tooltip.GetSchoolColor(r.school)
    local tickStr = sc .. FN(r.tickDamage or r.tickDmg or 0) .. COLOR_RESET
    local totalStr = sc .. FN(r.expectedDamageWithMiss or 0) .. COLOR_RESET
    local durStr = format("%ds, %d ticks", r.duration or 0, r.numTicks or 0)
    AddLine(
        format("  %sBreakdown:%s  %s/tick  |  %s total  (%s)", COLOR_LABEL, COLOR_RESET, tickStr, totalStr, durStr)
    )

    AddStatsLine(r)
end

--- Utility spell (2 lines)
local function AddUtilityLines(r)
    if r.healthCost then
        -- Life Tap style: health cost → mana gain (+SP bonus)
        AddLine(
            format("%sPhDamage:%s  %s HP \226\134\146 %s mana  (%s+%s SP%s)",
                COLOR_GOLD, COLOR_RESET,
                FN(r.healthCost),
                FN(r.manaGain),
                COLOR_GREEN, FN(r.spellPowerBonus or 0), COLOR_RESET),
            1, 1, 1
        )
    else
        -- Dark Pact style: mana gain only (+SP bonus)
        AddLine(
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
    ResetLines()

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

    FinalizeFrame()
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
        if companionFrame then companionFrame:Hide() end
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

        -- Create companion tooltip frame
        companionFrame = CreateFrame("Frame", "PhDamageTooltip", UIParent, "BackdropTemplate")
        companionFrame:SetFrameStrata("TOOLTIP")
        companionFrame:SetClampedToScreen(true)
        companionFrame:Hide()

        companionFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        companionFrame:SetBackdropColor(0, 0, 0, 0.8)

        -- Apply ElvUI skin if available (SetTemplate is a mixin method)
        if ElvUI then
            local E = unpack(ElvUI)
            if E and E.Skins then
                pcall(function() companionFrame:SetTemplate("Transparent") end)
            end
        end

        HookTooltip()
    end
end)
