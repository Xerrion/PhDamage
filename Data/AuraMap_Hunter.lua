local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Hunter Aura Modifiers — TBC Anniversary (2.5.5)
-- Source of truth: Wowhead TBC Classic
--
-- Most Hunter damage buffs are from talents, not auras.
-- Trueshot Aura and Hunter's Mark RAP bonuses are already reflected
-- in UnitRangedAttackPower() — no explicit aura entries needed.
-------------------------------------------------------------------------------

local AuraMap = {}

-- (Reserved for future aura entries)

-------------------------------------------------------------------------------
-- Merge into global AuraMap
-------------------------------------------------------------------------------
for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
