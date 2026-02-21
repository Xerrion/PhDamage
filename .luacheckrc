std = "lua51"
max_line_length = 120
codes = true

exclude_files = {
    "Libs/",
}

ignore = {
    "212/self",  -- unused self in methods
}

globals = {
    "PhDamageDB",
    "SLASH_PHDAMAGE1",
    "SLASH_PHDAMAGE2",
    "SlashCmdList",
}

read_globals = {
    -- Lua globals
    "table", "string", "math", "pairs", "ipairs", "type", "tostring", "tonumber",
    "select", "unpack", "print", "format", "wipe", "sort", "tinsert", "tremove",
    "strsplit", "strtrim", "strlower",

    -- WoW API - Core
    "CreateFrame",
    "UnitLevel",
    "UnitClass",
    "GetLocale",

    -- WoW API - Spell & Combat Stats
    "GetSpellBonusDamage",
    "GetSpellBonusHealing",
    "GetSpellCritChance",
    "GetCombatRating",
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
    "GetSpellBookItemInfo",
    "GetNumSpellTabs",
    "GetSpellTabInfo",
    "IsSpellKnown",

    -- WoW API - Auras
    "GetPlayerAuraBySpellID",

    -- WoW API - C_ namespaces
    "C_UnitAuras",
    "C_Spell",
    "C_SpellBook",

    -- WoW API - Combat Ratings
    "CR_HIT_SPELL",
    "CR_HASTE_SPELL",
    "CR_CRIT_SPELL",

    -- WoW API - Misc
    "pcall",
    "xpcall",
    "error",
    "assert",
    "rawget",
    "rawset",
    "setmetatable",
    "getmetatable",

    -- Ace3
    "LibStub",

    -- WoW globals
    "DEFAULT_CHAT_FRAME",
    "RAID_CLASS_COLORS",
    "Enum",
}
