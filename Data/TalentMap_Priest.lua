local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Priest Talent Modifiers - TBC Anniversary (2.5.5)
-- Talent positions (tab:index) verified in-game on TBC Anniversary
-- (ordered by internal talentID)
-------------------------------------------------------------------------------

local SCHOOL_HOLY = ns.SCHOOL_HOLY
local SCHOOL_SHADOW = ns.SCHOOL_SHADOW
local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Discipline (Tab 1)
-- 1:1  Martyrdom (2)                      1:2  Power Infusion (1)
-- 1:3  Mental Agility (5)                 1:4  Unbreakable Will (5)
-- 1:5  Improved PW:Shield (3)             1:6  Improved PW:Fortitude (2)
-- 1:7  Wand Specialization (5)            1:8  Improved Inner Fire (3)
-- 1:9  Meditation (3)                     1:10 Inner Focus (1)
-- 1:11 Improved Mana Burn (2)             1:12 Divine Spirit (1)
-- 1:13 Silent Resolve (5)                 1:14 Mental Strength (5)
-- 1:15 Force of Will (5)                  1:16 Absolution (3)
-- 1:17 Improved Divine Spirit (2)         1:18 Focused Power (2)
-- 1:19 Enlightenment (5)                  1:20 Reflective Shield (5)
-- 1:21 Pain Suppression (1)               1:22 Focused Will (3)
-------------------------------------------------------------------------------

-- Force of Will: +1% spell damage AND +1% spell crit per rank (Discipline 1:15)
TalentMap["1:15"] = {
    name = "Force of Will",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Focused Power: +2% all damage per rank (Discipline 1:18)
TalentMap["1:18"] = {
    name = "Focused Power",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive" },
    },
}

-------------------------------------------------------------------------------
-- Holy (Tab 2)
-- 2:1  Inspiration (3)                    2:2  Holy Specialization (5)
-- 2:3  Spiritual Guidance (5)             2:4  Searing Light (2)
-- 2:5  Spiritual Healing (5)              2:6  Improved Renew (3)
-- 2:7  Improved Healing (3)               2:8  Healing Focus (2)
-- 2:9  Spell Warding (5)                  2:10 Healing Prayers (2)
-- 2:11 Holy Nova (1)                      2:12 Divine Fury (5)
-- 2:13 Spirit of Redemption (1)           2:14 Holy Reach (2)
-- 2:15 Blessed Recovery (3)               2:16 Lightwell (1)
-- 2:17 Blessed Resilience (3)             2:18 Surge of Light (2)
-- 2:19 Empowered Healing (5)              2:20 Holy Concentration (3)
-- 2:21 Circle of Healing (1)
-------------------------------------------------------------------------------

-- Holy Specialization: +1% holy spell crit per rank (Holy 2:2)
TalentMap["2:2"] = {
    name = "Holy Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true, filter = { school = SCHOOL_HOLY } },
    },
}

-- Searing Light: +5% Smite and Holy Fire damage per rank (Holy 2:4)
TalentMap["2:4"] = {
    name = "Searing Light",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05, perRank = true, stacking = "additive",
          filter = { spellNames = { "Smite", "Holy Fire" } } },
    },
}

-------------------------------------------------------------------------------
-- Shadow (Tab 3)
-- 3:1  Shadow Weaving (5)                 3:2  Darkness (5)
-- 3:3  Shadow Focus (5)                   3:4  Blackout (5)
-- 3:5  Spirit Tap (5)                     3:6  Shadow Affinity (3)
-- 3:7  Improved Mind Blast (5)            3:8  Improved SW:Pain (2)
-- 3:9  Improved Fade (2)                  3:10 Vampiric Embrace (1)
-- 3:11 Mind Flay (1)                      3:12 Shadowform (1)
-- 3:13 Silence (1)                        3:14 Improved Psychic Scream (2)
-- 3:15 Shadow Reach (2)                   3:16 Improved Vampiric Embrace (2)
-- 3:17 Focused Mind (3)                   3:18 Shadow Power (5)
-- 3:19 Vampiric Touch (1)                 3:20 Shadow Resilience (2)
-- 3:21 Misery (5)
-------------------------------------------------------------------------------

-- Darkness: +2% shadow damage per rank (Shadow 3:2)
TalentMap["3:2"] = {
    name = "Darkness",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { school = SCHOOL_SHADOW } },
    },
}

-- Shadow Focus: +2% shadow hit per rank (Shadow 3:3)
TalentMap["3:3"] = {
    name = "Shadow Focus",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true, filter = { school = SCHOOL_SHADOW } },
    },
}

-- Improved Shadow Word: Pain: +3% SW:P damage per rank (Shadow 3:8)
TalentMap["3:8"] = {
    name = "Improved Shadow Word: Pain",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.03, perRank = true, stacking = "additive",
          filter = { spellNames = { "Shadow Word: Pain" } } },
    },
}

-- Shadow Power: +20% shadow crit damage bonus per rank (0.10 of base 50% bonus) (Shadow 3:18)
TalentMap["3:18"] = {
    name = "Shadow Power",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.10, perRank = true, filter = { school = SCHOOL_SHADOW } },
    },
}

-------------------------------------------------------------------------------
-- Merge into addon namespace with class prefix
-------------------------------------------------------------------------------
for key, data in pairs(TalentMap) do
    ns.TalentMap["PRIEST:" .. key] = data
end
