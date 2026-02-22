-------------------------------------------------------------------------------
-- TalentMap_Shaman
-- Shaman talent modifier definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.TalentMap = ns.TalentMap or {}

local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Elemental (Tab 1)
-------------------------------------------------------------------------------

-- Call of Thunder: +1% crit chance on Lightning Bolt and Chain Lightning per rank
TalentMap["1:2"] = {
    name = "Call of Thunder",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true,
          filter = { spellNames = { "Lightning Bolt", "Chain Lightning" } } },
    },
}

-- Concussion: +1% damage on Lightning Bolt, Chain Lightning, and all Shocks per rank
TalentMap["1:3"] = {
    name = "Concussion",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { spellNames = { "Lightning Bolt", "Chain Lightning",
                                    "Earth Shock", "Flame Shock", "Frost Shock" } } },
    },
}

-- Elemental Fury: +50% crit damage bonus (crits deal 200% instead of 150%)
TalentMap["1:5"] = {
    name = "Elemental Fury",
    maxRank = 1,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.50 },
    },
}

-- Lightning Mastery: -0.1s cast time on Lightning Bolt and Chain Lightning per rank
TalentMap["1:11"] = {
    name = "Lightning Mastery",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = { "Lightning Bolt", "Chain Lightning" } } },
    },
}

-- Elemental Precision: +2% spell hit per rank (all Shaman spells are Nature/Fire/Frost)
TalentMap["1:18"] = {
    name = "Elemental Precision",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true },
    },
}

-------------------------------------------------------------------------------
-- Enhancement (Tab 2)
-------------------------------------------------------------------------------

-- Weapon Mastery: +2% melee damage per rank
TalentMap["2:15"] = {
    name = "Weapon Mastery",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { scalingType = "melee" } },
    },
}

-- Mental Quickness: 10% of Attack Power as spell power per rank
TalentMap["2:19"] = {
    name = "Mental Quickness",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_POWER_BONUS, value = 0.10, perRank = true, statField = "attackPower" },
    },
}

-- Dual Wield Specialization: +2% melee hit per rank
TalentMap["2:20"] = {
    name = "Dual Wield Specialization",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true,
          filter = { scalingType = "melee" } },
    },
}

-------------------------------------------------------------------------------
-- Restoration (Tab 3)
-------------------------------------------------------------------------------

-- Improved Healing Wave: -0.1s cast time on Healing Wave per rank
TalentMap["3:4"] = {
    name = "Improved Healing Wave",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = { "Healing Wave" } } },
    },
}

-- Purification: +2% healing effectiveness per rank
TalentMap["3:10"] = {
    name = "Purification",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { isHeal = true } },
    },
}

-- Tidal Mastery: +1% crit on lightning spells and healing spells per rank
TalentMap["3:12"] = {
    name = "Tidal Mastery",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true,
          filter = { spellNames = { "Lightning Bolt", "Chain Lightning",
                                    "Healing Wave", "Lesser Healing Wave", "Chain Heal" } } },
    },
}

-- Nature's Blessing: 10% of Intellect as spell power per rank (heals only)
TalentMap["3:17"] = {
    name = "Nature's Blessing",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_POWER_BONUS, value = 0.10, perRank = true, statField = "intellect",
          filter = { isHeal = true } },
    },
}

-- Healing Way: modeled as an aura in AuraMap_Shaman.lua (stacking buff on target)

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["SHAMAN:" .. key] = data
end
