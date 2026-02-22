-------------------------------------------------------------------------------
-- TalentMap_Paladin
-- Paladin talent modifier definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.TalentMap = ns.TalentMap or {}

local SCHOOL_HOLY = ns.SCHOOL_HOLY
local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Holy (Tab 1)
-------------------------------------------------------------------------------

-- Healing Light: +4% healing to Holy Light and Flash of Light per rank
TalentMap["1:7"] = {
    name = "Healing Light",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.04, perRank = true, stacking = "additive",
          filter = { isHeal = true, spellNames = { "Holy Light", "Flash of Light" } } },
    },
}

-- Sanctified Light: +2% crit on Holy Light and Flash of Light per rank
TalentMap["1:14"] = {
    name = "Sanctified Light",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Holy Light", "Flash of Light" } } },
    },
}

-- Purifying Power: +10% crit on Exorcism and Holy Wrath per rank
TalentMap["1:16"] = {
    name = "Purifying Power",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.10, perRank = true,
          filter = { spellNames = { "Exorcism", "Holy Wrath" } } },
    },
}

-- Holy Power: +1% Holy spell crit per rank
TalentMap["1:19"] = {
    name = "Holy Power",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true, filter = { school = SCHOOL_HOLY } },
    },
}

-- Holy Guidance: +5% of Intellect as spell power per rank
TalentMap["1:25"] = {
    name = "Holy Guidance",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_POWER_BONUS, value = 0.05, perRank = true, statField = "intellect" },
    },
}

-------------------------------------------------------------------------------
-- Protection (Tab 2)
-------------------------------------------------------------------------------

-- Precision: +1% spell hit per rank
TalentMap["2:4"] = {
    name = "Precision",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Combat Expertise: +1% crit per rank
TalentMap["2:23"] = {
    name = "Combat Expertise",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-------------------------------------------------------------------------------
-- Retribution (Tab 3)
-------------------------------------------------------------------------------

-- NOTE: Crusade is actually +1%/rank damage to Humanoids, Demons, Undead, and Elementals.
-- Simplified to +1%/rank all damage since creature type filtering is not supported.
TalentMap["3:10"] = {
    name = "Crusade",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
    },
}

-- Sanctified Seals: +1% crit per rank
TalentMap["3:20"] = {
    name = "Sanctified Seals",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["PALADIN:" .. key] = data
end
