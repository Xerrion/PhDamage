-------------------------------------------------------------------------------
-- Init.lua
-- Ace3 addon object creation and namespace wiring
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Ace3 Addon Creation
-------------------------------------------------------------------------------
local PhDamage = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
ns.Addon = PhDamage

-- Sub-tables on the namespace for each layer to populate
ns.SpellData = {}      -- populated by Data/SpellData_Warlock.lua
ns.TalentMap = {}      -- populated by Data/TalentMap_Warlock.lua
ns.AuraMap = {}        -- populated by Data/AuraMap_Warlock.lua
ns.Engine = {}         -- populated by Engine/*.lua

-------------------------------------------------------------------------------
-- Saved Variables Defaults
-------------------------------------------------------------------------------
local DB_DEFAULTS = {
    profile = {
        enabled = true,
        verbose = false,
        overlay = {
            anchor             = "BOTTOM",
            offsetX            = 0,
            offsetY            = 2,
            fontSize           = 10,
            abbreviateNumbers  = true,
        },
    },
}

-------------------------------------------------------------------------------
-- Lifecycle: OnInitialize (runs once, before PLAYER_LOGIN)
-------------------------------------------------------------------------------
function PhDamage:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PhDamageDB", DB_DEFAULTS, true)

    -- Register slash commands
    self:RegisterChatCommand("phd", "OnSlashCommand")
    self:RegisterChatCommand("phdamage", "OnSlashCommand")

    self:Print("PhDamage loaded. Type /phd for diagnostics.")
end

-------------------------------------------------------------------------------
-- Lifecycle: OnEnable (runs when addon is enabled)
-------------------------------------------------------------------------------
function PhDamage:OnEnable()
    -- Events module handles all event registration
    if ns.Events and ns.Events.RegisterAll then
        ns.Events.RegisterAll()
    end
end

-------------------------------------------------------------------------------
-- Lifecycle: OnDisable
-------------------------------------------------------------------------------
function PhDamage:OnDisable()
    -- Events module handles cleanup
    if ns.Events and ns.Events.UnregisterAll then
        ns.Events.UnregisterAll()
    end
    -- Invalidate cached state so stale data isn't served on re-enable
    if ns.StateCollector and ns.StateCollector.Invalidate then
        ns.StateCollector.Invalidate()
    end
end

-------------------------------------------------------------------------------
-- Slash Command Router
-------------------------------------------------------------------------------

-- Valid anchor point identifiers accepted by the config command
local VALID_ANCHORS = {
    BOTTOM = true, TOP = true, CENTER = true,
    LEFT = true, RIGHT = true,
    BOTTOMLEFT = true, BOTTOMRIGHT = true,
    TOPLEFT = true, TOPRIGHT = true,
}

local function HandleConfigCommand(addon, args)
    local cfg = addon.db.profile.overlay
    local setting = args[2] and strlower(args[2]) or ""
    local value   = args[3]

    if setting == "" then
        addon:Print("Overlay settings:")
        addon:Print(string.format("  anchor: %s", cfg.anchor))
        addon:Print(string.format("  offsetX: %d", cfg.offsetX))
        addon:Print(string.format("  offsetY: %d", cfg.offsetY))
        addon:Print(string.format("  fontSize: %d", cfg.fontSize))
        addon:Print(string.format("  abbreviate: %s", cfg.abbreviateNumbers and "on" or "off"))
        return
    end

    if setting == "anchor" then
        local v = value and strupper(value) or ""
        if VALID_ANCHORS[v] then
            cfg.anchor = v
            addon:Print("Overlay anchor set to: " .. v)
        else
            addon:Print("Invalid anchor. Valid values: BOTTOM, TOP, CENTER, LEFT, RIGHT, "
                .. "BOTTOMLEFT, BOTTOMRIGHT, TOPLEFT, TOPRIGHT")
            return
        end

    elseif setting == "offsetx" then
        local n = tonumber(value)
        if n then
            cfg.offsetX = n
            addon:Print("Overlay offsetX set to: " .. n)
        else
            addon:Print("Invalid value for offsetX. Expected a number.")
            return
        end

    elseif setting == "offsety" then
        local n = tonumber(value)
        if n then
            cfg.offsetY = n
            addon:Print("Overlay offsetY set to: " .. n)
        else
            addon:Print("Invalid value for offsetY. Expected a number.")
            return
        end

    elseif setting == "fontsize" then
        local n = tonumber(value)
        if n and n >= 6 and n <= 24 then
            cfg.fontSize = n
            addon:Print("Overlay font size set to: " .. n)
        else
            addon:Print("Invalid font size. Expected a number between 6 and 24.")
            return
        end

    elseif setting == "abbreviate" then
        local v = value and strlower(value) or ""
        if v == "on" or v == "true" or v == "1" then
            cfg.abbreviateNumbers = true
            addon:Print("Number abbreviation enabled.")
        elseif v == "off" or v == "false" or v == "0" then
            cfg.abbreviateNumbers = false
            addon:Print("Number abbreviation disabled.")
        else
            addon:Print("Invalid value for abbreviate. Use 'on' or 'off'.")
            return
        end

    else
        addon:Print("Unknown config setting '" .. setting
            .. "'. Valid settings: anchor, offsetX, offsetY, fontSize, abbreviate")
        return
    end

    -- Apply the updated settings to all existing overlays
    if ns.ActionBar and ns.ActionBar.ApplySettings then
        ns.ActionBar.ApplySettings()
    end
end

function PhDamage:OnSlashCommand(input)
    if not ns.Diagnostics then
        self:Print("Diagnostics module not loaded.")
        return
    end

    local args = { strsplit(" ", input) }
    local cmd = args[1] and strlower(args[1]) or ""

    if cmd == "state" then
        ns.Diagnostics.PrintState()
    elseif cmd == "spell" then
        local spellInput = table.concat(args, " ", 2)
        local linkName = spellInput:match("|Hspell:%d+.-|h%[(.-)%]|h")
        ns.Diagnostics.PrintSpell(linkName or spellInput)
    elseif cmd == "config" then
        HandleConfigCommand(self, args)
    elseif cmd == "help" then
        self:Print("Usage:")
        self:Print("  /phd — Show all spell computations")
        self:Print("  /phd state — Show current player state snapshot")
        self:Print("  /phd spell <name> — Detailed breakdown for one spell")
        self:Print("  /phd config — Show overlay display settings")
        self:Print("  /phd config anchor <point> — Set text anchor (BOTTOM, TOP, CENTER, ...)")
        self:Print("  /phd config offsetX <n> — Set horizontal offset (default 0)")
        self:Print("  /phd config offsetY <n> — Set vertical offset (default 2)")
        self:Print("  /phd config fontSize <n> — Set font size 6-24 (default 10)")
        self:Print("  /phd config abbreviate on|off — Toggle k/M number shortening (default on)")
        self:Print("  /phd help — Show this help")
    else
        ns.Diagnostics.PrintAll()
    end
end
