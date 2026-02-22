-------------------------------------------------------------------------------
-- AuraMap_Priest
-- Priest aura (buff/debuff) definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.AuraMap = ns.AuraMap or {}

local SCHOOL_SHADOW = 32
local MOD = ns.MOD

local AuraMap = {}

-- Shadowform (15473): +15% shadow damage
AuraMap[15473] = {
    name = "Shadowform",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.15, filter = { school = SCHOOL_SHADOW } },
    },
}

-- Power Infusion (10060): +20% spell damage
AuraMap[10060] = {
    name = "Power Infusion",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.20 },
    },
}

-- Shadow Weaving (15258): +10% shadow damage taken on target (max stacks assumed)
AuraMap[15258] = {
    name = "Shadow Weaving",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, filter = { school = SCHOOL_SHADOW } },
    },
}

-- Merge into addon namespace
for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
