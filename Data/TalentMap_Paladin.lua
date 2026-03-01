local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Paladin Talent Modifiers - TBC Anniversary (2.5.5)
-- Talent positions (tab:index) verified in-game on TBC Anniversary
-- (ordered by internal talentID)
-------------------------------------------------------------------------------

local SCHOOL_HOLY = ns.SCHOOL_HOLY
local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Holy (Tab 1)
-- 1:1  Spiritual Focus (5)                1:2  Divine Favor (1)
-- 1:3  Aura Mastery (1)                   1:4  Improved Lay on Hands (2)
-- 1:5  Healing Light (3)                  1:6  Improved Blessing of Wisdom (2)
-- 1:7  Divine Intellect (5)               1:8  Divine Strength (5)
-- 1:9  Illumination (5)                   1:10 Improved Seal of Righteousness (5)
-- 1:11 Sanctified Light (3)               1:12 Holy Shock (1)
-- 1:13 Holy Power (5)                     1:14 Unyielding Faith (2)
-- 1:15 Pure of Heart (3)                  1:16 Purifying Power (2)
-- 1:17 Blessed Life (3)                   1:18 Light's Grace (3)
-- 1:19 Holy Guidance (5)                  1:20 Divine Illumination (1)
-------------------------------------------------------------------------------

-- Healing Light: +4% healing to Holy Light and Flash of Light per rank (Holy 1:5)
TalentMap["1:5"] = {
    name = "Healing Light",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.04, perRank = true, stacking = "additive",
          filter = { isHeal = true, spellNames = { "Holy Light", "Flash of Light" } } },
    },
}

-- Sanctified Light: +2% crit on Holy Light and Flash of Light per rank (Holy 1:11)
TalentMap["1:11"] = {
    name = "Sanctified Light",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Holy Light", "Flash of Light" } } },
    },
}

-- Holy Power: +1% Holy spell crit per rank (Holy 1:13)
TalentMap["1:13"] = {
    name = "Holy Power",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true, filter = { school = SCHOOL_HOLY } },
    },
}

-- Purifying Power: +10% crit on Exorcism and Holy Wrath per rank (Holy 1:16)
TalentMap["1:16"] = {
    name = "Purifying Power",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.10, perRank = true,
          filter = { spellNames = { "Exorcism", "Holy Wrath" } } },
    },
}

-- Holy Guidance: +5% of Intellect as spell power per rank (Holy 1:19)
TalentMap["1:19"] = {
    name = "Holy Guidance",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_POWER_BONUS, value = 0.05, perRank = true, statField = "intellect" },
    },
}

-------------------------------------------------------------------------------
-- Protection (Tab 2)
-- 2:1  Redoubt (5)                        2:2  Improved Devotion Aura (5)
-- 2:3  Toughness (5)                      2:4  Shield Specialization (3)
-- 2:5  Guardian's Favor (2)               2:6  Reckoning (5)
-- 2:7  One-Handed Weapon Spec (5)         2:8  Holy Shield (1)
-- 2:9  Blessing of Sanctuary (1)          2:10 Blessing of Kings (1)
-- 2:11 Improved Righteous Fury (3)        2:12 Improved Hammer of Justice (3)
-- 2:13 Improved Concentration Aura (3)    2:14 Anticipation (5)
-- 2:15 Precision (3)                      2:16 Stoicism (2)
-- 2:17 Spell Warding (2)                  2:18 Sacred Duty (2)
-- 2:19 Ardent Defender (5)                2:20 Combat Expertise (5)
-- 2:21 Avenger's Shield (1)               2:22 Improved Holy Shield (2)
-------------------------------------------------------------------------------

-- Precision: +1% spell hit per rank (Protection 2:15)
TalentMap["2:15"] = {
    name = "Precision",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Combat Expertise: +1% crit per rank (Protection 2:20)
TalentMap["2:20"] = {
    name = "Combat Expertise",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-------------------------------------------------------------------------------
-- Retribution (Tab 3)
-- 3:1  Improved Blessing of Might (5)     3:2  Vengeance (5)
-- 3:3  Deflection (5)                     3:4  Improved Retribution Aura (2)
-- 3:5  Benediction (5)                    3:6  Sanctity Aura (1)
-- 3:7  Two-Handed Weapon Spec (3)         3:8  Conviction (5)
-- 3:9  Repentance (1)                     3:10 Improved Seal of the Crusader (3)
-- 3:11 Seal of Command (1)                3:12 Improved Judgement (2)
-- 3:13 Eye for an Eye (2)                 3:14 Vindication (3)
-- 3:15 Pursuit of Justice (3)             3:16 Crusade (3)
-- 3:17 Improved Sanctity Aura (2)         3:18 Divine Purpose (3)
-- 3:19 Sanctified Judgement (3)           3:20 Fanaticism (5)
-- 3:21 Sanctified Seals (3)               3:22 Crusader Strike (1)
-------------------------------------------------------------------------------

-- NOTE: Crusade is actually +1%/rank damage to Humanoids, Demons, Undead, and Elementals.
-- Simplified to +1%/rank all damage since creature type filtering is not supported.
-- Crusade: +1% all damage per rank (Retribution 3:16)
TalentMap["3:16"] = {
    name = "Crusade",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
    },
}

-- Sanctified Seals: +1% crit per rank (Retribution 3:21)
TalentMap["3:21"] = {
    name = "Sanctified Seals",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-------------------------------------------------------------------------------
-- Merge into addon namespace with class prefix
-------------------------------------------------------------------------------
for key, data in pairs(TalentMap) do
    ns.TalentMap["PALADIN:" .. key] = data
end
