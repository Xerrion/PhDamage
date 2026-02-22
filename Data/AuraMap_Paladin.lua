-------------------------------------------------------------------------------
-- AuraMap_Paladin.lua
-- Paladin-relevant buff and debuff effects mapped to modifier descriptors
-- SpellIDs sourced from Wowhead TBC Classic
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.AuraMap = ns.AuraMap or {}

local MOD = ns.MOD
local SCHOOL_HOLY = ns.SCHOOL_HOLY
local SCHOOL_PHYSICAL = ns.SCHOOL_PHYSICAL

local AuraMap = {}

-------------------------------------------------------------------------------
-- Player Buffs (target = "player")
-------------------------------------------------------------------------------

-- Light's Grace: proc after casting Holy Light, reduces next Holy Light cast time by 0.5s (15s duration)
AuraMap[31834] = {
    name = "Light's Grace",
    target = "player",
    effects = {
        {
            type = MOD.CAST_TIME_REDUCTION,
            value = 0.5,
            filter = { spellNames = { "Holy Light" } },
        },
    },
}

-- Sanctity Aura: +10% Holy damage to all party members
AuraMap[20218] = {
    name = "Sanctity Aura",
    target = "player",
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.10,
            filter = { school = SCHOOL_HOLY },
        },
    },
}

-- Improved Sanctity Aura does not have a separate buff; it enhances Sanctity Aura.
-- Modeled as a separate aura entry for tracking. Uses talent spell ID 31869 as key.
AuraMap[31869] = {
    name = "Improved Sanctity Aura",
    target = "player",
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.02,
        },
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.02,
            filter = { isHeal = true },
        },
    },
}

-- Vengeance proc at max talent rank (5/5): +5% Physical and Holy damage for 15s.
-- Buff ID 20055 is the rank 5 proc; lower ranks are 20050-20054.
AuraMap[20055] = {
    name = "Vengeance",
    target = "player",
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.05,
            filter = { schools = { SCHOOL_PHYSICAL, SCHOOL_HOLY } },
        },
    },
}

for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
