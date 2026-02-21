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
        local spellName = table.concat(args, " ", 2)
        ns.Diagnostics.PrintSpell(spellName)
    elseif cmd == "help" then
        self:Print("Usage:")
        self:Print("  /phd — Show all spell computations")
        self:Print("  /phd state — Show current player state snapshot")
        self:Print("  /phd spell <name> — Detailed breakdown for one spell")
        self:Print("  /phd help — Show this help")
    else
        ns.Diagnostics.PrintAll()
    end
end
