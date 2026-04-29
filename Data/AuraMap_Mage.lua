-------------------------------------------------------------------------------
-- AuraMap_Mage
-- Mage aura (buff/debuff) definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.AuraMap = ns.AuraMap or {}

local SCHOOL_FIRE = ns.SCHOOL_FIRE
local MOD = ns.MOD

local AuraMap = {}

-- Arcane Power: +30% all spell damage
AuraMap[12042] = {
    name = "Arcane Power",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.30 },
    },
}

-- Molten Armor: +3% spell crit
AuraMap[30482] = {
    name = "Molten Armor",
    target = "player",
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.03 },
    },
}

-- Fire Vulnerability / Improved Scorch (22959): target takes up to +15% Fire damage.
-- Stack-aware: +3% per stack, max 5 stacks. Engine scales by applications/maxStacks.
AuraMap[22959] = {
    name = "Fire Vulnerability",
    target = "target",
    maxStacks = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.15,
          filter = { school = SCHOOL_FIRE } },
    },
}

-- TODO: Icy Veins (12472) — player buff, +20% spell haste
-- Haste is already reflected in spellHaste stat from GetCombatRating; no damage modifier needed

-- Merge into addon namespace
for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
