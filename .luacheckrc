std = "lua51"
max_line_length = 120
codes = true

exclude_files = {
    "Libs/",
}

ignore = {
    "212/self",         -- unused self in methods
    "211/ADDON_NAME",   -- captured but only used in Init.lua
    "421",              -- shadowing variable in nested scope (intentional do-block pattern)
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

    -- WoW API - Ranged Combat
    "UnitRangedAttackPower",
    "GetRangedCritChance",
    "UnitRangedDamage",

    -- WoW API - Melee Combat
    "UnitAttackPower",
    "GetCritChance",
    "GetExpertise",
    "UnitDamage",
    "UnitAttackSpeed",
    "GetInventoryItemLink",
    "GetItemInfo",

    -- WoW API - Unit Info
    "UnitCreatureType",
    "UnitExists",
    "UnitHealth",
    "UnitHealthMax",
    "UnitCanAttack",

    -- WoW API - Talents
    "GetTalentInfo",
    "GetNumTalentTabs",
    "GetNumTalents",

    -- WoW API - Spells
    "GetSpellInfo",

    -- WoW API - Action Bar
    "HasAction",
    "GetActionInfo",
    "GetMacroSpell",
    "ActionBarButtonEventsFrame",
    "ActionButton_Update",
    "hooksecurefunc",

    -- WoW API - UI
    "GameTooltip",
    "C_Timer",

    -- WoW API - Auras (GetPlayerAuraBySpellID accessed via C_UnitAuras namespace)
    "C_UnitAuras",

    -- Ace3
    "LibStub",

    -- WoW globals
    "DEFAULT_CHAT_FRAME",
    "RAID_CLASS_COLORS",
    "Enum",
}

-- Test files use busted framework globals and may write to Enum
files["tests/**"] = {
    read_globals = {
        "describe",
        "it",
        "before_each",
        "after_each",
        "setup",
        "teardown",
        "pending",
        "spy",
        "stub",
        "mock",
        "assert",    -- busted's enhanced assert
        "loadfile",
        "arg",
    },
    globals = {
        "Enum",
    },
}
