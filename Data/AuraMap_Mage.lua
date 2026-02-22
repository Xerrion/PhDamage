-------------------------------------------------------------------------------
-- AuraMap_Mage
-- Mage aura (buff/debuff) definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.AuraMap = ns.AuraMap or {}

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

-- TODO: Fire Vulnerability (22959) — target debuff, +3% fire damage taken per stack (5 max)
-- Requires debuff stack tracking (not yet implemented in engine)

-- TODO: Icy Veins (12472) — player buff, +20% spell haste
-- Haste is already reflected in spellHaste stat from GetCombatRating; no damage modifier needed

-- Merge into addon namespace
for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
