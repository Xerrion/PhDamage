-------------------------------------------------------------------------------
-- AuraMap_Shaman.lua
-- Shaman-relevant buff and debuff effects mapped to modifier descriptors
-- SpellIDs sourced from Wowhead TBC Classic
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local MOD = ns.MOD
local SCHOOL_NATURE = ns.SCHOOL_NATURE

local AuraMap = {}

-------------------------------------------------------------------------------
-- Player Buffs (target = "player")
-------------------------------------------------------------------------------

-- Elemental Mastery: next spell gets +100% crit chance and is instant cast
AuraMap[16166] = {
    name = "Elemental Mastery",
    target = "player",
    effects = {
        { type = MOD.CRIT_BONUS, value = 1.0 },
        { type = MOD.CAST_TIME_OVERRIDE, value = 0 },
    },
}

-- Nature's Swiftness: next Nature spell is instant cast
AuraMap[16188] = {
    name = "Nature's Swiftness",
    target = "player",
    effects = {
        { type = MOD.CAST_TIME_OVERRIDE, value = 0 },
    },
}

-- Wrath of Air Totem: +101 spell power
AuraMap[3738] = {
    name = "Wrath of Air Totem",
    target = "player",
    effects = {
        { type = MOD.SPELL_POWER_BONUS, value = 101 },
    },
}

-- Totem of Wrath: +3% spell hit and +3% spell crit
AuraMap[30708] = {
    name = "Totem of Wrath",
    target = "player",
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.03 },
        { type = MOD.CRIT_BONUS, value = 0.03 },
    },
}

-------------------------------------------------------------------------------
-- Target Debuffs/Buffs (target = "target")
-------------------------------------------------------------------------------

-- Stormstrike: target takes +20% Nature damage (2 charges, 12s duration)
AuraMap[17364] = {
    name = "Stormstrike",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.20,
          filter = { school = SCHOOL_NATURE } },
    },
}

-- Healing Way: +6% Healing Wave healing per stack (up to 3 stacks, modeled per stack)
AuraMap[29203] = {
    name = "Healing Way",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.06,
          filter = { spellNames = { "Healing Wave" } } },
    },
}

for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
