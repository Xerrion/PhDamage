-------------------------------------------------------------------------------
-- AuraMap_Priest
-- Priest aura (buff/debuff) definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.AuraMap = ns.AuraMap or {}

local SCHOOL_SHADOW = ns.SCHOOL_SHADOW
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

-- Shadow Weaving (15258): up to +10% shadow damage taken on target
-- Stack-aware: +2% per stack, max 5 stacks. Engine scales by applications/maxStacks.
AuraMap[15258] = {
    name = "Shadow Weaving",
    target = "target",
    maxStacks = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, filter = { school = SCHOOL_SHADOW } },
    },
}

-- Merge into addon namespace
for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
