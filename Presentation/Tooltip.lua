-------------------------------------------------------------------------------
-- Tooltip.lua
-- Hooks GameTooltip to display expected damage/DPS for supported spells
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

local Tooltip = {}
ns.Tooltip = Tooltip

-------------------------------------------------------------------------------
-- Formatting Helpers (delegate to ns.Format, kept for backward compatibility)
-------------------------------------------------------------------------------

function Tooltip.FormatNumber(n)
    return ns.Format.FormatNumber(n)
end

function Tooltip.FormatDPS(n)
    return ns.Format.FormatDPS(n)
end

function Tooltip.GetSchoolColor(school)
    return ns.Format.GetSchoolColor(school)
end

function Tooltip.ColorValue(text, school)
    return ns.Format.ColorValue(text, school)
end

-- Cache WoW globals
local GameTooltip = GameTooltip
local CreateFrame = CreateFrame
local pairs = pairs
local format = string.format
local floor = math.floor
local concat = table.concat

-- Import shared formatting (populated by Format.lua, loaded before this file)
local Format  -- forward-declared; resolved in init
local FN, FD  -- FormatNumber / FormatDPS aliases
local COLOR_GOLD, COLOR_GREEN, COLOR_WHITE, COLOR_LABEL, COLOR_RESET
local MULTIPLY, ARROW

-- SpellID reverse lookup: rankSpellID -> { spellKey, rankIndex }
local spellIDMap = {}

-- Re-entry guard: tracks the spellID last appended to avoid duplicate lines
local lastTooltipSpellID = nil

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
-- BuildSpellIDMap
-- Creates a reverse lookup from rank-specific spellID -> { spellKey, rankIndex }.
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
-- GetSpellIDMap -- expose the reverse lookup for ActionBar.lua to reuse
-------------------------------------------------------------------------------

function Tooltip.GetSpellIDMap()
    return spellIDMap
end

-------------------------------------------------------------------------------
-- Identity line -- spell name (school-colored) + rank
-------------------------------------------------------------------------------

local function AddIdentityLine(r)
    local schoolColor = ns.Format.GetSchoolColor(r.school)
    local name = schoolColor .. (r.spellName or "Unknown") .. COLOR_RESET
    local rank = ""
    if r.rank then
        rank = " " .. COLOR_GOLD .. "(Rank " .. r.rank .. ")" .. COLOR_RESET
    end
    AddLine(name .. rank)
end

-------------------------------------------------------------------------------
-- Value line -- expected damage/DPS (the "money line")
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

local function AddValueLine(r)
    local valueLabel = GetValueLabel(r.outputType)
    local rateLabel = GetRateLabel(r.outputType)
    local schoolColor = ns.Format.GetSchoolColor(r.school)
    local dmgStr = schoolColor .. FN(r.expectedDamageWithMiss) .. COLOR_RESET
    local dpsStr = COLOR_GREEN .. FD(r.dps) .. " " .. rateLabel .. COLOR_RESET

    AddLine(format("%s %s  (%s)", dmgStr, valueLabel, dpsStr))
end

-------------------------------------------------------------------------------
-- Coefficient line -- labeled
-------------------------------------------------------------------------------

local function AddCoeffLine(r)
    if r.spellType == "utility" then return end
    local isMelee = r.dodgeChance ~= nil
    if isMelee then return end  -- melee has no coefficient

    local label = COLOR_LABEL .. "Coeff:" .. COLOR_RESET .. "  "
    if r.spellType == "hybrid" then
        local dc = r.directCoefficient or 0
        local dotc = r.dotCoefficient or 0
        AddLine("  " .. label .. format("%s%.2f + %.2f%s", COLOR_WHITE, dc, dotc, COLOR_RESET))
    elseif r.coefficient then
        AddLine("  " .. label .. format("%s%.3f%s", COLOR_WHITE, r.coefficient, COLOR_RESET))
    end
end

-------------------------------------------------------------------------------
-- Cast time line -- labeled
-------------------------------------------------------------------------------

local function FormatCastTime(r)
    if (r.baseCastTime or 0) <= 0 then
        return "instant"
    elseif r.spellType == "channel" then
        return format("%.1fs channel", r.castTime)
    else
        return format("%.1fs", r.castTime)
    end
end

local function AddCastLine(r)
    if r.spellType == "utility" then return end
    local label = COLOR_LABEL .. "Cast:" .. COLOR_RESET .. "  "
    AddLine("  " .. label .. COLOR_WHITE .. FormatCastTime(r) .. COLOR_RESET)
end

-------------------------------------------------------------------------------
-- Talent line -- labeled, only shown when talentDamageBonus > 0
-------------------------------------------------------------------------------

local function AddTalentLine(r)
    if (r.talentDamageBonus or 0) <= 0 then return end

    local label = COLOR_LABEL .. "Talents:" .. COLOR_RESET .. "  "
    AddLine("  " .. label .. format("%s+%.0f%%%s",
        COLOR_GREEN, r.talentDamageBonus * 100, COLOR_RESET))
end

-------------------------------------------------------------------------------
-- Stats line -- labeled, SP/AP + crit (hidden when 0%) + hit
-------------------------------------------------------------------------------

local function GetPowerLabel(r)
    if r.dodgeChance ~= nil then return "AP" end
    return "SP"
end

local function AddStatsLine(r)
    local label = COLOR_LABEL .. "Stats:" .. COLOR_RESET .. "  "
    local powerLabel = GetPowerLabel(r)
    local parts = {}

    parts[#parts + 1] = format("%s+%s%s %s",
        COLOR_WHITE, FN(r.spellPowerBonus or 0), COLOR_RESET, powerLabel)

    if (r.critChance or 0) > 0 then
        parts[#parts + 1] = format("%s%.1f%%%s crit (%s%s%.2f%s)",
            COLOR_WHITE, r.critChance * 100, COLOR_RESET,
            COLOR_WHITE, MULTIPLY, r.critMultiplier or 0, COLOR_RESET)
    end

    if r.hitChance then
        parts[#parts + 1] = format("%s%d%%%s hit",
            COLOR_WHITE, floor(r.hitChance * 100 + 0.5), COLOR_RESET)
    end

    AddLine("  " .. label .. concat(parts, "  |  "))
end

-------------------------------------------------------------------------------
-- Melee stats + avoidance lines -- labeled
-------------------------------------------------------------------------------

local function AddMeleeStatsLines(r)
    -- Line 1: Stats label with AP + crit
    local statsLabel = COLOR_LABEL .. "Stats:" .. COLOR_RESET .. "  "
    local parts1 = {}
    parts1[#parts1 + 1] = format("%s+%s%s AP",
        COLOR_WHITE, FN(r.spellPowerBonus or 0), COLOR_RESET)
    if (r.critChance or 0) > 0 then
        parts1[#parts1 + 1] = format("%s%.1f%%%s crit (%s%s%.2f%s)",
            COLOR_WHITE, r.critChance * 100, COLOR_RESET,
            COLOR_WHITE, MULTIPLY, r.critMultiplier or 0, COLOR_RESET)
    end
    AddLine("  " .. statsLabel .. concat(parts1, "  |  "))

    -- Line 2: Avoidance label with hit + dodge + parry + armor
    local avoidLabel = COLOR_LABEL .. "Avoidance:" .. COLOR_RESET .. "  "
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
        AddLine("  " .. avoidLabel .. concat(parts2, "  |  "))
    end
end

-------------------------------------------------------------------------------
-- Breakdown line -- labeled, for DoT and Channel spells
-- Shows tick damage, total damage, duration, and tick count
-------------------------------------------------------------------------------

local function AddBreakdownLine(r)
    local label = COLOR_LABEL .. "Breakdown:" .. COLOR_RESET .. "  "
    local sc = ns.Format.GetSchoolColor(r.school)
    local tickStr = sc .. FN(r.tickDamage or r.tickDmg or 0) .. COLOR_RESET
    local totalStr = sc .. FN(r.expectedDamageWithMiss or r.totalDmg or 0) .. COLOR_RESET
    local tickCount = r.numTicks or 0
    local duration = r.duration or 0

    AddLine(format("  %s%s/tick  |  %s total  (%ds, %d ticks)",
        label, tickStr, totalStr, duration, tickCount))
end

-------------------------------------------------------------------------------
-- Hybrid breakdown lines -- Direct + DoT sub-lines with labels
-------------------------------------------------------------------------------

local function AddHybridBreakdownLines(r)
    local sc = ns.Format.GetSchoolColor(r.school)

    -- Direct line
    local directLabel = COLOR_LABEL .. "Direct:" .. COLOR_RESET .. "  "
    local directStr = sc .. FN(r.directDamage or 0) .. COLOR_RESET
    local directParts = { directStr }
    if (r.critChance or 0) > 0 then
        directParts[#directParts + 1] = format("%s%.1f%%%s crit (%s%s%.2f%s)",
            COLOR_WHITE, r.critChance * 100, COLOR_RESET,
            COLOR_WHITE, MULTIPLY, r.critMultiplier or 0, COLOR_RESET)
    end
    AddLine("  " .. directLabel .. concat(directParts, "  |  "))

    -- DoT line
    local dotLabel = COLOR_LABEL .. "DoT:" .. COLOR_RESET .. "  "
    local tickStr = sc .. FN(r.tickDamage or 0) .. COLOR_RESET
    local dotTotalStr = sc .. FN(r.dotDamage or r.dotTotalDmg or 0) .. COLOR_RESET
    local tickCount = r.numTicks or 0
    local duration = r.duration or 0
    AddLine(format("  %s%s/tick  |  %s total  (%ds, %d ticks)",
        dotLabel, tickStr, dotTotalStr, duration, tickCount))
end

-------------------------------------------------------------------------------
-- Spell-type-specific line builders
-------------------------------------------------------------------------------

local function AddDirectLines(r)
    AddIdentityLine(r)
    AddValueLine(r)
    AddCoeffLine(r)
    AddCastLine(r)
    AddTalentLine(r)
    if r.dodgeChance ~= nil then
        AddMeleeStatsLines(r)
    else
        AddStatsLine(r)
    end
end

local function AddDotLines(r)
    AddIdentityLine(r)
    AddValueLine(r)
    AddCoeffLine(r)
    AddCastLine(r)
    AddTalentLine(r)
    AddBreakdownLine(r)
    AddStatsLine(r)
end

local function AddHybridLines(r)
    AddIdentityLine(r)
    AddValueLine(r)
    AddCoeffLine(r)
    AddCastLine(r)
    AddTalentLine(r)
    AddHybridBreakdownLines(r)
    AddStatsLine(r)
end

local function AddChannelLines(r)
    AddIdentityLine(r)
    AddValueLine(r)
    AddCoeffLine(r)
    AddCastLine(r)
    AddTalentLine(r)
    AddBreakdownLine(r)
    AddStatsLine(r)
end

local function AddUtilityLines(r)
    AddIdentityLine(r)
    local sc = ns.Format.GetSchoolColor(r.school)
    if r.healthCost then
        AddLine(format("  %s HP %s %s mana  (%s+%s SP%s)",
            sc .. FN(r.healthCost) .. COLOR_RESET,
            ARROW,
            sc .. FN(r.manaGain) .. COLOR_RESET,
            COLOR_GREEN, FN(r.spellPowerBonus or 0), COLOR_RESET))
    else
        AddLine(format("  %s mana  (%s+%s SP%s)",
            sc .. FN(r.manaGain) .. COLOR_RESET,
            COLOR_GREEN, FN(r.spellPowerBonus or 0), COLOR_RESET))
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
-- HookTooltip -- attaches the tooltip hooks (called once during init)
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
-- Initialization -- deferred to PLAYER_LOGIN to ensure all data is ready
-------------------------------------------------------------------------------

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")

        -- Resolve shared formatting references
        Format = ns.Format
        FN = Format.FormatNumber
        FD = Format.FormatDPS
        COLOR_GOLD  = Format.COLOR_GOLD
        COLOR_GREEN = Format.COLOR_GREEN
        COLOR_WHITE = Format.COLOR_WHITE
        COLOR_LABEL = Format.COLOR_LABEL
        COLOR_RESET = Format.COLOR_RESET
        MULTIPLY    = Format.MULTIPLY
        ARROW       = Format.ARROW

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
