-------------------------------------------------------------------------------
-- Options.lua
-- AceConfig-3.0 options panel bound to db.profile.overlay
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached globals
-------------------------------------------------------------------------------
local LibStub = LibStub
local Settings = Settings
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
local pairs = pairs

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------
local Options = {}
ns.Options = Options

-------------------------------------------------------------------------------
-- Anchor choice list (also drives the dropdown values)
-------------------------------------------------------------------------------
local ANCHOR_VALUES = {
    TOPLEFT     = "TOPLEFT",
    TOP         = "TOP",
    TOPRIGHT    = "TOPRIGHT",
    LEFT        = "LEFT",
    CENTER      = "CENTER",
    RIGHT       = "RIGHT",
    BOTTOMLEFT  = "BOTTOMLEFT",
    BOTTOM      = "BOTTOM",
    BOTTOMRIGHT = "BOTTOMRIGHT",
}

-------------------------------------------------------------------------------
-- Internal helpers
-------------------------------------------------------------------------------
local function GetOverlay()
    return ns.Addon.db.profile.overlay
end

local function ApplyOverlay()
    if ns.ActionBar and ns.ActionBar.ApplySettings then
        ns.ActionBar.ApplySettings()
    end
end

-- get/set handlers for AceConfig - info[#info] is the leaf option key
local function GetSetting(info)
    return GetOverlay()[info[#info]]
end

local function SetSetting(info, value)
    GetOverlay()[info[#info]] = value
    ApplyOverlay()
end

local function ResetToDefaults()
    local defaults = ns.DB_DEFAULTS and ns.DB_DEFAULTS.profile and ns.DB_DEFAULTS.profile.overlay
    if not defaults then return end

    local overlay = GetOverlay()
    for key, value in pairs(defaults) do
        overlay[key] = value
    end
    ApplyOverlay()
end

-------------------------------------------------------------------------------
-- BuildOptionsTable() - returns the AceConfig schema
-------------------------------------------------------------------------------
function Options:BuildOptionsTable()
    return {
        type = "group",
        name = "PhDamage",
        get  = GetSetting,
        set  = SetSetting,
        args = {
            overlayHeader = {
                type  = "header",
                name  = "Action Bar Overlay",
                order = 1,
            },
            anchor = {
                type   = "select",
                name   = "Anchor",
                desc   = "Anchor point on the action button where the damage text is placed.",
                values = ANCHOR_VALUES,
                order  = 10,
            },
            offsetX = {
                type  = "range",
                name  = "Horizontal Offset",
                desc  = "Horizontal pixel offset from the anchor point.",
                min   = -50,
                max   = 50,
                step  = 1,
                order = 20,
            },
            offsetY = {
                type  = "range",
                name  = "Vertical Offset",
                desc  = "Vertical pixel offset from the anchor point.",
                min   = -50,
                max   = 50,
                step  = 1,
                order = 30,
            },
            fontSize = {
                type  = "range",
                name  = "Font Size",
                desc  = "Font size of the overlay damage text.",
                min   = 6,
                max   = 32,
                step  = 1,
                order = 40,
            },
            abbreviateNumbers = {
                type  = "toggle",
                name  = "Abbreviate Numbers",
                desc  = "Display large numbers with k/M suffixes (e.g. 1.2k instead of 1234).",
                order = 50,
            },
            spacer = {
                type  = "description",
                name  = " ",
                order = 60,
            },
            reset = {
                type  = "execute",
                name  = "Reset to Defaults",
                desc  = "Restore all overlay settings to their default values.",
                func  = ResetToDefaults,
                order = 70,
            },
        },
    }
end

-------------------------------------------------------------------------------
-- Register() - wires the options table into AceConfig and Blizzard panels
-------------------------------------------------------------------------------
function Options:Register()
    local AceConfig = LibStub("AceConfig-3.0", true)
    local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
    if not AceConfig or not AceConfigDialog then return end

    AceConfig:RegisterOptionsTable(ADDON_NAME, self:BuildOptionsTable())
    self.blizFrame = AceConfigDialog:AddToBlizOptions(ADDON_NAME, "PhDamage")
end

-------------------------------------------------------------------------------
-- Open() - opens the Blizzard interface options to the PhDamage panel
-------------------------------------------------------------------------------
function Options:Open()
    local frame = self.blizFrame
    if not frame then return end

    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(frame.name or frame)
        return
    end

    if InterfaceOptionsFrame_OpenToCategory then
        -- TBC 2.5.x quirk: first call only opens the panel; second call selects it.
        InterfaceOptionsFrame_OpenToCategory(frame)
        InterfaceOptionsFrame_OpenToCategory(frame)
    end
end
