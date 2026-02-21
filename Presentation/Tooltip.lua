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
local ipairs = ipairs
local format = string.format
local floor = math.floor

-- SpellID reverse lookup: rankSpellID → { spellKey, rankIndex }
local spellIDMap = {}

-- Re-entry guard: tracks the spellID last appended to avoid duplicate lines
local lastTooltipSpellID = nil

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

--- Formats a number for compact tooltip display.
-- >= 10000 → "10.0k", >= 1000 → "1.2k", otherwise → integer "581"
local function FormatNumber(n)
    if n == nil then return "?" end
    if n >= 10000 then
        return format("%.0fk", n / 1000)
    elseif n >= 1000 then
        return format("%.1fk", n / 1000)
    else
        return tostring(floor(n + 0.5))
    end
end

--- Formats a DPS value with one decimal place for readability.
-- Uses the same "k" suffix logic for large values.
local function FormatDPS(n)
    if n == nil then return "?" end
    if n >= 10000 then
        return format("%.0fk", n / 1000)
    elseif n >= 1000 then
        return format("%.1fk", n / 1000)
    else
        return format("%.1f", n)
    end
end

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
-- Tooltip line formatting
-------------------------------------------------------------------------------

--- Adds a gray detail line with SP bonus, optional crit info, and hit chance.
local function AddDetailLine(r)
    local parts = {}

    parts[#parts + 1] = format("+%s SP", FormatNumber(r.spellPowerBonus or 0))

    if (r.critChance or 0) > 0 then
        parts[#parts + 1] = format("%.1f%% crit (\195\151%.2f)", r.critChance * 100, r.critMultiplier or 0)
    end

    if r.hitChance then
        parts[#parts + 1] = format("%d%% hit", floor(r.hitChance * 100 + 0.5))
    end

    GameTooltip:AddLine(table.concat(parts, " | "), 0.67, 0.67, 0.67)
end

--- Adds formatted PhDamage lines to the tooltip based on spell type.
local function AddTooltipLines(r)
    if r.spellType == "utility" then
        if r.healthCost then
            -- Life Tap style: health cost → mana gain (+SP bonus)
            GameTooltip:AddLine(
                format("|cffffd100PhDamage:|r %s HP \226\134\146 %s mana (|cff00ff00+%s SP|r)",
                    FormatNumber(r.healthCost),
                    FormatNumber(r.manaGain),
                    FormatNumber(r.spellPowerBonus or 0)),
                1, 1, 1
            )
        else
            -- Dark Pact style: mana gain only (+SP bonus)
            GameTooltip:AddLine(
                format("|cffffd100PhDamage:|r %s mana (|cff00ff00+%s SP|r)",
                    FormatNumber(r.manaGain),
                    FormatNumber(r.spellPowerBonus or 0)),
                1, 1, 1
            )
        end
    elseif r.spellType == "hybrid" then
        -- Immolate style: direct + DoT
        GameTooltip:AddLine(
            format("|cffffd100PhDamage:|r %s direct + %s DoT (|cff00ff00%s DPS|r)",
                FormatNumber(r.directDamage),
                FormatNumber(r.dotDamage),
                FormatDPS(r.dps)),
            1, 1, 1
        )
        AddDetailLine(r)
    else
        -- Direct, DoT, or Channel
        local valueLabel, rateLabel, rateStr
        if r.outputType == "healing" then
            valueLabel = "healing expected"
            rateLabel = "HPS"
        elseif r.outputType == "absorption" then
            valueLabel = "absorption"
            rateLabel = "APS"
        else
            valueLabel = "expected"
            rateLabel = "DPS"
        end
        rateStr = format("|cff00ff00%s %s|r", FormatDPS(r.dps), rateLabel)
        GameTooltip:AddLine(
            format("|cffffd100PhDamage:|r %s %s (%s)",
                FormatNumber(r.expectedDamageWithMiss),
                valueLabel,
                rateStr),
            1, 1, 1
        )
        AddDetailLine(r)
    end

    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- Tooltip hook handler
-------------------------------------------------------------------------------

local function OnTooltipSetSpell(tooltip)
    local spellName, a, b = tooltip:GetSpell()
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
