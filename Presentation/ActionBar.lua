-------------------------------------------------------------------------------
-- ActionBar.lua
-- Overlays expected damage numbers on action bar spell buttons
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

local ActionBar = {}
ns.ActionBar = ActionBar

-------------------------------------------------------------------------------
-- Cached WoW globals
-------------------------------------------------------------------------------
local HasAction = HasAction
local GetActionInfo = GetActionInfo
local GetMacroSpell = GetMacroSpell
local format = string.format
local floor = math.floor

-------------------------------------------------------------------------------
-- Button name patterns to scan
-------------------------------------------------------------------------------
local BUTTON_PATTERNS = {
    { prefix = "ActionButton", count = 12 },
    { prefix = "MultiBarBottomLeftButton", count = 12 },
    { prefix = "MultiBarBottomRightButton", count = 12 },
    { prefix = "MultiBarRightButton", count = 12 },
    { prefix = "MultiBarLeftButton", count = 12 },
    { prefix = "MultiBar5Button", count = 12 },
    { prefix = "MultiBar6Button", count = 12 },
    { prefix = "MultiBar7Button", count = 12 },
}

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------
local trackedButtons = {}   -- array of discovered button frames
local spellIDToBase = nil   -- reverse map: any rank spellID → base spellID
local resultCache = {}      -- spellID → result cache, cleared on state change
local initialized = false   -- guard to prevent duplicate initialization

-------------------------------------------------------------------------------
-- BuildSpellIDMap()
-- Creates a reverse lookup from every rank spellID to the base spellID key
-- used by ns.SpellData. Only rebuilt when spellIDToBase is nil.
-------------------------------------------------------------------------------
local function BuildSpellIDMap()
    spellIDToBase = {}
    for baseID, spellData in pairs(ns.SpellData) do
        spellIDToBase[baseID] = baseID
        if spellData.ranks then
            for _, rankData in pairs(spellData.ranks) do
                if rankData.spellID then
                    spellIDToBase[rankData.spellID] = baseID
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-- FormatNumber(n)
-- Compact display: 10000 → "10.0k", 1500 → "1.5k", 581 → "581"
-------------------------------------------------------------------------------
local function FormatNumber(n)
    if n >= 10000 then
        return format("%.1fk", n / 1000)
    elseif n >= 1000 then
        return format("%.1fk", n / 1000)
    else
        return tostring(floor(n + 0.5))
    end
end

-------------------------------------------------------------------------------
-- ResolveSpellID(button)
-- Given an action button, resolve the underlying spellID from its action slot.
-- Returns the base spellID (key in ns.SpellData) or nil.
-------------------------------------------------------------------------------
local function ResolveSpellID(button)
    local slot = button.action or (button.GetAttribute and button:GetAttribute("action"))
    if not slot or not HasAction(slot) then
        return nil
    end

    local actionType, id, subType = GetActionInfo(slot)
    local spellID = nil

    if actionType == "spell" then
        spellID = id
    elseif actionType == "macro" then
        local ok, result = pcall(function()
            if GetMacroSpell then
                return GetMacroSpell(id)
            end
            return nil
        end)
        if ok and result then
            spellID = result
        end
    end

    if not spellID then
        return nil
    end

    if not spellIDToBase then
        BuildSpellIDMap()
    end

    return spellIDToBase[spellID]
end

-------------------------------------------------------------------------------
-- GetOrCreateOverlay(button)
-- Lazily creates and returns the FontString overlay for a button.
-------------------------------------------------------------------------------
local function GetOrCreateOverlay(button)
    if button.phDamageText then
        return button.phDamageText
    end

    local fontString = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    fontString:SetPoint("BOTTOM", button, "BOTTOM", 0, 2)
    button.phDamageText = fontString
    return fontString
end

-------------------------------------------------------------------------------
-- CalculateForSpell(baseSpellID, playerState)
-- Returns the pipeline result for a spell, using the per-refresh cache.
-------------------------------------------------------------------------------
local function CalculateForSpell(baseSpellID, playerState)
    local cached = resultCache[baseSpellID]
    if cached ~= nil then
        return cached  -- may be false if spell had no result
    end

    local result = ns.Engine.Pipeline.Calculate(baseSpellID, playerState)
    resultCache[baseSpellID] = result or false
    return result or nil
end

-------------------------------------------------------------------------------
-- GetDisplayValue(result)
-- Picks the most relevant number to display from a SpellResult.
-- Returns the numeric value or nil.
-------------------------------------------------------------------------------
local function GetDisplayValue(result)
    if not result then
        return nil
    end

    if result.spellType == "utility" then
        return result.manaGain
    end

    return result.expectedDamageWithMiss or result.expectedDamage
end

-------------------------------------------------------------------------------
-- ActionBar.UpdateButton(button)
-- Computes and displays the expected damage for a single action button.
-------------------------------------------------------------------------------
function ActionBar.UpdateButton(button)
    local overlay = button.phDamageText
    local baseSpellID = ResolveSpellID(button)

    if not baseSpellID then
        if overlay then
            overlay:SetText("")
            overlay:Hide()
        end
        return
    end

    local playerState = ns.StateCollector.GetCachedState()
    if not playerState then
        if overlay then
            overlay:SetText("")
            overlay:Hide()
        end
        return
    end

    local result = CalculateForSpell(baseSpellID, playerState)
    local value = GetDisplayValue(result)

    if not value or value <= 0 then
        if overlay then
            overlay:SetText("")
            overlay:Hide()
        end
        return
    end

    overlay = GetOrCreateOverlay(button)
    overlay:SetText("|cffffffff" .. FormatNumber(value) .. "|r")
    overlay:Show()
end

-------------------------------------------------------------------------------
-- ActionBar.Refresh()
-- Updates all tracked buttons. Clears the per-refresh cache first.
-------------------------------------------------------------------------------
function ActionBar.Refresh()
    resultCache = {}
    for _, button in ipairs(trackedButtons) do
        ActionBar.UpdateButton(button)
    end
end

-------------------------------------------------------------------------------
-- DiscoverButtons()
-- Scans _G for all action bar buttons and populates trackedButtons.
-------------------------------------------------------------------------------
local function DiscoverButtons()
    trackedButtons = {}
    for _, pattern in ipairs(BUTTON_PATTERNS) do
        for i = 1, pattern.count do
            local button = _G[pattern.prefix .. i]
            if button then
                GetOrCreateOverlay(button)
                trackedButtons[#trackedButtons + 1] = button
            end
        end
    end
end

-------------------------------------------------------------------------------
-- OnActionBarSlotChanged(event, slot)
-- Updates only the button(s) matching the changed action slot.
-------------------------------------------------------------------------------
local function OnActionBarSlotChanged(event, slot)
    if not slot or slot == 0 then
        ActionBar.Refresh()
        return
    end

    for _, button in ipairs(trackedButtons) do
        local btnSlot = button.action or (button.GetAttribute and button:GetAttribute("action"))
        if btnSlot and btnSlot == slot then
            ActionBar.UpdateButton(button)
        end
    end
end

-------------------------------------------------------------------------------
-- OnFullRefresh()
-- Handles events that require a full refresh of all buttons.
-------------------------------------------------------------------------------
local function OnFullRefresh()
    ActionBar.Refresh()
end

-------------------------------------------------------------------------------
-- OnStateChanged()
-- Invalidates the spell ID map (in case spell data changed) and refreshes.
-------------------------------------------------------------------------------
local function OnStateChanged()
    spellIDToBase = nil
    resultCache = {}
    ActionBar.Refresh()
end

-------------------------------------------------------------------------------
-- ActionBar.Initialize()
-- Called after PLAYER_ENTERING_WORLD to discover buttons and register events.
-------------------------------------------------------------------------------
function ActionBar.Initialize()
    if initialized then
        return
    end

    local addon = ns.Addon
    if not addon then
        return
    end

    initialized = true

    BuildSpellIDMap()
    DiscoverButtons()
    ActionBar.Refresh()

    -- WoW events
    addon:RegisterEvent("ACTIONBAR_SLOT_CHANGED", OnActionBarSlotChanged)
    addon:RegisterEvent("ACTIONBAR_PAGE_CHANGED", OnFullRefresh)
    addon:RegisterEvent("UPDATE_MACROS", OnFullRefresh)

    -- Internal state-change message
    addon:RegisterMessage("PHDAMAGE_STATE_CHANGED", OnStateChanged)
end
