std = "lua51"
max_line_length = 120
codes = true

exclude_files = {
    "Libs/",
}

ignore = {
    "212/self",         -- unused self in methods
    "211/ADDON_NAME",   -- captured but only used in Init.lua
}

globals = {
    "PhDamageDB",
    "SlashCmdList",
}

read_globals = {
    -- Lua globals
    "table", "string", "math", "pairs", "ipairs", "type", "tostring", "tonumber",
    "select", "unpack", "print", "format", "wipe", "sort", "tinsert", "tremove",
    "strsplit", "strtrim", "strlower",

    -- Lua builtins (used or anticipated)
    "pcall",
    "error",
    "assert",
    "setmetatable",

    -- WoW API - Core
    "CreateFrame",
    "UnitLevel",
    "UnitClass",
    "GetLocale",

    -- WoW API - Spell & Combat Stats
    "GetSpellBonusDamage",
    "GetSpellBonusHealing",
    "GetSpellCritChance",
    "GetCombatRatingBonus",
    "GetSpellHitModifier",
    "GetHitModifier",
    "GetManaRegen",

    -- WoW API - Talents
    "GetTalentInfo",
    "GetNumTalentTabs",
    "GetNumTalents",

    -- WoW API - Spells
    "GetSpellInfo",

    -- WoW API - Auras (GetPlayerAuraBySpellID accessed via C_UnitAuras namespace)
    "C_UnitAuras",

    -- Ace3
    "LibStub",

    -- WoW globals (used or anticipated for Phase 2)
    "DEFAULT_CHAT_FRAME",
    "RAID_CLASS_COLORS",
    "Enum",
}
