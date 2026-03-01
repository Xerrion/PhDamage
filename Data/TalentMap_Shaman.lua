local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- TalentMap_Shaman.lua
-- Shaman talent effects mapped to modifier descriptors for TBC Anniversary
-- Talent positions (tab:index) verified in-game on TBC Anniversary
-- (ordered by internal talentID)
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

ns.TalentMap = ns.TalentMap or {}

local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Elemental (Tab 1)
-- 1:1  Call of Flame (3)                  1:2  Call of Thunder (5)
-- 1:3  Concussion (5)                     1:4  Convection (5)
-- 1:5  Elemental Fury (1)                 1:6  Improved Fire Totems (2)
-- 1:7  Earth's Grasp (2)                  1:8  Elemental Mastery (1)
-- 1:9  Elemental Focus (1)                1:10 Reverberation (5)
-- 1:11 Lightning Mastery (5)              1:12 Elemental Warding (3)
-- 1:13 Storm Reach (2)                    1:14 Eye of the Storm (3)
-- 1:15 Elemental Devastation (3)          1:16 Unrelenting Storm (5)
-- 1:17 Elemental Shields (3)              1:18 Elemental Precision (3)
-- 1:19 Lightning Overload (5)             1:20 Totem of Wrath (1)
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
-- 2:1  Anticipation (5)                   2:2  Flurry (5)
-- 2:3  Improved Ghost Wolf (2)            2:4  Improved Lightning Shield (3)
-- 2:5  Guardian Totems (2)                2:6  Enhancing Totems (2)
-- 2:7  Elemental Weapons (3)              2:8  Shield Specialization (5)
-- 2:9  Thundering Strikes (5)             2:10 Ancestral Knowledge (5)
-- 2:11 Toughness (5)                      2:12 Spirit Weapons (1)
-- 2:13 Shamanistic Focus (1)              2:14 Stormstrike (1)
-- 2:15 Weapon Mastery (5)                 2:16 Improved Weapon Totems (2)
-- 2:17 Unleashed Rage (5)                 2:18 Dual Wield (1)
-- 2:19 Mental Quickness (3)               2:20 Dual Wield Specialization (3)
-- 2:21 Shamanistic Rage (1)
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
-- 3:1  Ancestral Healing (3)              3:2  Totemic Mastery (1)
-- 3:3  Nature's Guidance (3)              3:4  Improved Healing Wave (5)
-- 3:5  Healing Focus (5)                  3:6  Restorative Totems (5)
-- 3:7  Improved Reincarnation (2)         3:8  Mana Tide Totem (1)
-- 3:9  Nature's Swiftness (1)             3:10 Purification (5)
-- 3:11 Tidal Focus (5)                    3:12 Tidal Mastery (5)
-- 3:13 Totemic Focus (5)                  3:14 Healing Grace (3)
-- 3:15 Healing Way (3)                    3:16 Focused Mind (3)
-- 3:17 Nature's Blessing (3)              3:18 Improved Chain Heal (2)
-- 3:19 Earth Shield (1)                   3:20 Nature's Guardian (5)
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
