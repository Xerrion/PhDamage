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
local wipe = wipe

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------
local allButtons = {}           -- array of discovered button frames
local registeredButtons = {}    -- set keyed by button frame, prevents duplicates
local resultCache = {}          -- spellID → result cache, cleared on state change
local initialized = false       -- guard to prevent duplicate initialization

-------------------------------------------------------------------------------
-- FormatNumber - delegated to shared formatting module, honours abbreviation setting
-------------------------------------------------------------------------------
local FormatNumber = function(n)
    local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.overlay
    if cfg and cfg.abbreviateNumbers == false then
        return ns.Format.FormatNumberFull(n)
    end
    return ns.Format.FormatNumber(n)
end

-------------------------------------------------------------------------------
-- ResolveSpellID(button)
-- Given an action button, resolve the underlying spellID from its action slot.
-- Returns the base spellID (key in ns.SpellData) or nil.
-------------------------------------------------------------------------------
local function ResolveSpellID(button)
    local slot = button.action
    if not slot and button.GetAttribute then
        slot = button:GetAttribute("action")
    end
    if type(slot) ~= "number" or slot == 0 then
        return nil
    end
    if not HasAction(slot) then
        return nil
    end

    local actionType, id = GetActionInfo(slot)
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

    return ns.SpellResolver.Resolve(spellID)
end

-------------------------------------------------------------------------------
-- ApplyOverlayAppearance(fontString, button)
-- Applies font size and anchor point from the current DB profile to an overlay.
-- Falls back to sensible defaults when the DB is not yet available.
-------------------------------------------------------------------------------
local function ApplyOverlayAppearance(fontString, button)
    local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.overlay or {}
    local anchor  = cfg.anchor  or "BOTTOM"
    local offsetX = cfg.offsetX or 0
    local offsetY = cfg.offsetY or 2
    local fontSize = cfg.fontSize or 10

    fontString:ClearAllPoints()
    fontString:SetPoint(anchor, button, anchor, offsetX, offsetY)
    fontString:SetFont("Fonts\\ARIALN.TTF", fontSize, "OUTLINE")
end

-------------------------------------------------------------------------------
-- GetOrCreateOverlay(button)
-- Lazily creates and returns the FontString overlay for a button.
-------------------------------------------------------------------------------
local function GetOrCreateOverlay(button)
    if button.phDamageText then
        return button.phDamageText
    end

    local fontString = button:CreateFontString(nil, "OVERLAY")
    ApplyOverlayAppearance(fontString, button)
    button.phDamageText = fontString
    return fontString
end

-------------------------------------------------------------------------------
-- ActionBar.ApplySettings()
-- Re-applies font/position settings to all existing overlays and forces a
-- full refresh so the displayed values are re-rendered immediately.
-------------------------------------------------------------------------------
function ActionBar.ApplySettings()
    for _, button in ipairs(allButtons) do
        if button.phDamageText then
            ApplyOverlayAppearance(button.phDamageText, button)
        end
    end
    wipe(resultCache)
    for _, button in ipairs(allButtons) do
        ActionBar.UpdateButton(button)
    end
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
            if overlay.phdLastText then
                overlay:SetText("")
                overlay.phdLastText = nil
            end
            overlay:Hide()
        end
        return
    end

    local playerState = ns.StateCollector.GetCachedState()
    if not playerState then
        if overlay then
            if overlay.phdLastText then
                overlay:SetText("")
                overlay.phdLastText = nil
            end
            overlay:Hide()
        end
        return
    end

    local result = CalculateForSpell(baseSpellID, playerState)
    local value = GetDisplayValue(result)

    if not value or value <= 0 then
        if overlay then
            if overlay.phdLastText then
                overlay:SetText("")
                overlay.phdLastText = nil
            end
            overlay:Hide()
        end
        return
    end

    overlay = GetOrCreateOverlay(button)
    local newText = "|cffffffff" .. FormatNumber(value) .. "|r"
    if newText ~= overlay.phdLastText then
        overlay:SetText(newText)
        overlay.phdLastText = newText
    end
    overlay:Show()
end

-------------------------------------------------------------------------------
-- ActionBar.Refresh()
-- Updates all tracked buttons. Clears the per-refresh cache first.
-------------------------------------------------------------------------------
function ActionBar.Refresh()
    wipe(resultCache)
    for _, button in ipairs(allButtons) do
        ActionBar.UpdateButton(button)
    end
end

-------------------------------------------------------------------------------
-- RegisterButton(button)
-- Registers a single action button for tracking. Skips duplicates.
-- Creates the FontString overlay and adds the button to allButtons.
-------------------------------------------------------------------------------
local function RegisterButton(button)
    if not button or registeredButtons[button] then
        return
    end
    registeredButtons[button] = true
    GetOrCreateOverlay(button)
    allButtons[#allButtons + 1] = button
end

-------------------------------------------------------------------------------
-- DiscoverButtons()
-- Discovers action bar buttons via ActionBarButtonEventsFrame and known
-- name prefixes (Blizzard default + ElvUI). Populates allButtons.
-------------------------------------------------------------------------------
local function DiscoverButtons()
    -- Try modern generic discovery first
    if ActionBarButtonEventsFrame then
        if ActionBarButtonEventsFrame.ForEachFrame then
            ActionBarButtonEventsFrame:ForEachFrame(function(button)
                RegisterButton(button)
            end)
        elseif ActionBarButtonEventsFrame.frames then
            for _, button in pairs(ActionBarButtonEventsFrame.frames) do
                RegisterButton(button)
            end
        end
    end

    -- Fallback: scan known prefixes (covers Blizzard + ElvUI)
    local BUTTON_PATTERNS = {
        { prefix = "ActionButton", count = 12 },
        { prefix = "MultiBarBottomLeftButton", count = 12 },
        { prefix = "MultiBarBottomRightButton", count = 12 },
        { prefix = "MultiBarRightButton", count = 12 },
        { prefix = "MultiBarLeftButton", count = 12 },
        { prefix = "MultiBar5Button", count = 12 },
        { prefix = "MultiBar6Button", count = 12 },
        { prefix = "MultiBar7Button", count = 12 },
        { prefix = "ElvUI_Bar1Button", count = 12 },
        { prefix = "ElvUI_Bar2Button", count = 12 },
        { prefix = "ElvUI_Bar3Button", count = 12 },
        { prefix = "ElvUI_Bar4Button", count = 12 },
        { prefix = "ElvUI_Bar5Button", count = 12 },
        { prefix = "ElvUI_Bar6Button", count = 12 },
        { prefix = "ElvUI_Bar7Button", count = 12 },
        { prefix = "ElvUI_Bar8Button", count = 12 },
        { prefix = "ElvUI_Bar9Button", count = 12 },
        { prefix = "ElvUI_Bar10Button", count = 12 },
    }
    for _, pattern in ipairs(BUTTON_PATTERNS) do
        for i = 1, pattern.count do
            local button = _G[pattern.prefix .. i]
            if button then
                RegisterButton(button)
            end
        end
    end
end

-------------------------------------------------------------------------------
-- OnActionBarSlotChanged(event, slot)
-- Updates only the button(s) matching the changed action slot.
-------------------------------------------------------------------------------
local function OnActionBarSlotChanged(_event, slot)
    if not slot or slot == 0 then
        ActionBar.Refresh()
        return
    end

    for _, button in ipairs(allButtons) do
        local btnSlot = button.action
        if not btnSlot and button.GetAttribute then
            btnSlot = button:GetAttribute("action")
        end
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
    wipe(resultCache)
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

    DiscoverButtons()
    ActionBar.Refresh()

    -- Hook ActionButton_Update to refresh overlays when individual buttons change
    if ActionButton_Update then
        hooksecurefunc("ActionButton_Update", function(button)
            if button.phDamageText then
                ActionBar.UpdateButton(button)
            end
        end)
    end

    -- Hook RegisterFrame to catch late-registered buttons (e.g. addon bars loaded after init)
    if ActionBarButtonEventsFrame and ActionBarButtonEventsFrame.RegisterFrame then
        hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(self, button)
            RegisterButton(button)
            ActionBar.UpdateButton(button)
        end)
    end

    -- WoW events
    addon:RegisterEvent("ACTIONBAR_SLOT_CHANGED", OnActionBarSlotChanged)
    addon:RegisterEvent("ACTIONBAR_PAGE_CHANGED", OnFullRefresh)
    addon:RegisterEvent("UPDATE_MACROS", OnFullRefresh)

    -- Internal state-change message
    addon:RegisterMessage("PHDAMAGE_STATE_CHANGED", OnStateChanged)
end
