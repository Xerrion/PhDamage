-------------------------------------------------------------------------------
-- TalentMap_Priest
-- Priest talent modifier definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.TalentMap = ns.TalentMap or {}

local SCHOOL_HOLY = 2
local SCHOOL_SHADOW = 32
local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Discipline
-------------------------------------------------------------------------------

-- Force of Will: +1% spell damage AND +1% spell crit per rank
TalentMap["1:15"] = {
    name = "Force of Will",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Focused Power: +2% all damage per rank
TalentMap["1:20"] = {
    name = "Focused Power",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive" },
    },
}

-------------------------------------------------------------------------------
-- Holy
-------------------------------------------------------------------------------

-- Holy Specialization: +1% holy spell crit per rank
TalentMap["2:3"] = {
    name = "Holy Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true, filter = { school = SCHOOL_HOLY } },
    },
}

-- Searing Light: +5% Smite and Holy Fire damage per rank
TalentMap["2:13"] = {
    name = "Searing Light",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05, perRank = true, stacking = "additive",
          filter = { spellNames = { "Smite", "Holy Fire" } } },
    },
}

-------------------------------------------------------------------------------
-- Shadow
-------------------------------------------------------------------------------

-- Shadow Focus: +2% shadow hit per rank
TalentMap["3:2"] = {
    name = "Shadow Focus",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true, filter = { school = SCHOOL_SHADOW } },
    },
}

-- Improved Shadow Word: Pain: +3% SW:P damage per rank
TalentMap["3:4"] = {
    name = "Improved Shadow Word: Pain",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.03, perRank = true, stacking = "additive",
          filter = { spellNames = { "Shadow Word: Pain" } } },
    },
}

-- Darkness: +2% shadow damage per rank
TalentMap["3:15"] = {
    name = "Darkness",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { school = SCHOOL_SHADOW } },
    },
}

-- Shadow Power: +20% shadow crit damage bonus per rank (0.10 of base 50% bonus)
TalentMap["3:22"] = {
    name = "Shadow Power",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.10, perRank = true, filter = { school = SCHOOL_SHADOW } },
    },
}

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["PRIEST:" .. key] = data
end
