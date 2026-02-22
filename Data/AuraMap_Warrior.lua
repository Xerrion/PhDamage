-------------------------------------------------------------------------------
-- AuraMap_Warrior.lua
-- Warrior-relevant buff and debuff effects mapped to modifier descriptors
-- SpellIDs sourced from Wowhead TBC Classic
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local SCHOOL_PHYSICAL = ns.SCHOOL_PHYSICAL
local MOD = ns.MOD

local AuraMap = {}

-------------------------------------------------------------------------------
-- Player Buffs (target = "player")
-------------------------------------------------------------------------------

-- Death Wish: +20% physical damage for 30 seconds
AuraMap[12292] = {
    name = "Death Wish",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.20,
          filter = { school = SCHOOL_PHYSICAL } },
    },
}

-------------------------------------------------------------------------------
-- Target Debuffs (target = "target")
-------------------------------------------------------------------------------

-- Blood Frenzy Rank 1: target takes +2% physical damage
AuraMap[29836] = {
    name = "Blood Frenzy",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02,
          filter = { school = SCHOOL_PHYSICAL } },
    },
}

-- Blood Frenzy Rank 2: target takes +4% physical damage
AuraMap[29859] = {
    name = "Blood Frenzy",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.04,
          filter = { school = SCHOOL_PHYSICAL } },
    },
}

for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
