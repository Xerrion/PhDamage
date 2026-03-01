-------------------------------------------------------------------------------
-- TalentMap_Warlock.lua
-- Warlock talent effects mapped to modifier descriptors for TBC Anniversary
-- Talent positions (tab:index) verified in-game on TBC Anniversary (ordered by internal talentID)
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local SCHOOL_FIRE = ns.SCHOOL_FIRE
local SCHOOL_SHADOW = ns.SCHOOL_SHADOW
local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Tab 1: Affliction
--
-- In-game ordering (by internal talentID):
--  1:1  = Fel Concentration (5)       1:2  = Nightfall (2)
--  1:3  = Improved Corruption (5)     1:4  = Soul Siphon (2)
--  1:5  = Suppression (5)             1:6  = Improved Curse of Weakness (2)
--  1:7  = Improved Life Tap (2)       1:8  = Grim Reach (2)
--  1:9  = Dark Pact (1)               1:10 = Siphon Life (1)
--  1:11 = Shadow Mastery (5)          1:12 = Amplify Curse (1)
--  1:13 = Curse of Exhaustion (1)     1:14 = Improved Drain Soul (2)
--  1:15 = Improved Curse of Agony (2) 1:16 = Malediction (3)
--  1:17 = Improved Howl of Terror (2) 1:18 = Contagion (5)
--  1:19 = Unstable Affliction (1)     1:20 = Shadow Embrace (5)
--  1:21 = Empowered Corruption (3)
-------------------------------------------------------------------------------

-- Improved Corruption: -0.4s cast time on Corruption per rank (5 ranks = instant)
TalentMap["1:3"] = {
    name = "Improved Corruption",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.4, perRank = true,
          filter = { spellNames = {"Corruption"} } },
    },
}

-- Soul Siphon: +2/4% damage per Affliction effect on target for Drain Life/Soul (capped)
TalentMap["1:4"] = {
    name = "Soul Siphon",
    maxRank = 2,
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = { 0.02, 0.04 },
            filter = { spellNames = { "Drain Life", "Drain Soul" } },
            countField = "afflictionCountOnTarget",
            maxBonus = { 0.24, 0.60 },
        },
    },
}

-- Suppression: +1% spell hit to Affliction (Shadow) spells per rank
TalentMap["1:5"] = {
    name = "Suppression",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true,
          filter = { spellNames = {
              "Corruption", "Curse of Agony", "Curse of Doom",
              "Unstable Affliction", "Siphon Life", "Drain Life",
              "Drain Soul", "Death Coil", "Seed of Corruption",
              "Fear", "Howl of Terror", "Curse of Tongues",
              "Curse of Weakness", "Curse of Recklessness",
              "Curse of the Elements", "Curse of Shadow",
              "Drain Mana"
          } } },
    },
}

-- Improved Life Tap: +10/20% mana from Life Tap (Affliction 1:7, 2 ranks)
TalentMap["1:7"] = {
    name = "Improved Life Tap",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { spellNames = {"Life Tap"} } },
    },
}

-- Siphon Life (1:10): 1 rank, enables the spell. No damage modifier.

-- Shadow Mastery: +2% Shadow damage per rank
TalentMap["1:11"] = {
    name = "Shadow Mastery",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { school = SCHOOL_SHADOW } },
    },
}

-- Improved Curse of Agony: +5% Curse of Agony damage per rank
TalentMap["1:15"] = {
    name = "Improved Curse of Agony",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05, perRank = true, stacking = "additive",
          filter = { spellNames = {"Curse of Agony"} } },
    },
}

-- Malediction: +1/2/3% to Curse of the Elements and Curse of Shadow damage amplification
-- The actual amplification is handled via talentAmplify in AuraMap entries for those curses;
-- this entry provides the talent definition for rank lookup.
TalentMap["1:16"] = {
    name = "Malediction",
    maxRank = 3,
    effects = {},
}

-- Contagion: +1% damage to Corruption, Seed of Corruption, and Curse of Agony per rank
TalentMap["1:18"] = {
    name = "Contagion",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { spellNames = {"Corruption", "Seed of Corruption", "Curse of Agony"} } },
    },
}

-- Unstable Affliction (1:19): 1 rank, enables the spell. No damage modifier.

-- Empowered Corruption: +12% of SP added to Corruption coefficient per rank
TalentMap["1:21"] = {
    name = "Empowered Corruption",
    maxRank = 3,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.12, perRank = true,
          filter = { spellNames = {"Corruption"} } },
    },
}

-------------------------------------------------------------------------------
-- Tab 2: Demonology
--
-- In-game ordering (by internal talentID):
--  2:1  = Improved Healthstone (2)    2:2  = Improved Imp (3)
--  2:3  = Demonic Embrace (5)         2:4  = Improved Health Funnel (2)
--  2:5  = Improved Voidwalker (3)     2:6  = Fel Domination (1)
--  2:7  = Master Summoner (2)         2:8  = Fel Stamina (3)
--  2:9  = Fel Intellect (3)           2:10 = Improved Sayaad (3)
--  2:11 = Master Demonologist (5)     2:12 = Master Conjuror (2)
--  2:13 = Unholy Power (5)            2:14 = Demonic Knowledge (3)
--  2:15 = Demonic Sacrifice (1)       2:16 = Soul Link (1)
--  2:17 = Improved Subjugate Demon (2) 2:18 = Demonic Aegis (3)
--  2:19 = Summon Felguard (1)         2:20 = Demonic Tactics (5)
--  2:21 = Demonic Resilience (3)      2:22 = Mana Feed (3)
-------------------------------------------------------------------------------

-- Improved Health Funnel: +10/20% healing (Demonology 2:4, 2 ranks)
TalentMap["2:4"] = {
    name = "Improved Health Funnel",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { spellNames = {"Health Funnel"} } },
    },
}

-- Master Demonologist: pet-dependent damage buff. Actual values come from AuraMap entries
-- (spellIDs 23761/35702) which use talentAmplify to scale by this talent's rank.
TalentMap["2:11"] = {
    name = "Master Demonologist",
    maxRank = 5,
    effects = {},
}

-- Demonic Sacrifice (2:15): 1 rank - sacrifice pet for a damage buff that depends on pet
-- type (Imp = +15% Fire, Succubus = +15% Shadow, etc.). Skipped for Phase 1 because it
-- requires tracking which pet was sacrificed. TODO: implement pet-sacrifice state tracking.

-- Demonic Knowledge (2:14): 3 ranks - +4% of pet (Stamina + Intellect) as spell damage per
-- rank. Skipped for Phase 1 because it requires reading live pet stats.
-- TODO: integrate with pet stat snapshot from StateCollector.

-------------------------------------------------------------------------------
-- Demonic Tactics (Demonology, Tier 9) - +1/2/3/4/5% crit to all spells
-------------------------------------------------------------------------------
TalentMap["2:20"] = {
    name = "Demonic Tactics",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-------------------------------------------------------------------------------
-- Tab 3: Destruction
--
-- In-game ordering (by internal talentID):
--  3:1  = Cataclysm (5)              3:2  = Bane (5)
--  3:3  = Improved Shadow Bolt (5)   3:4  = Improved Immolate (5)
--  3:5  = Shadowburn (1)             3:6  = Destructive Reach (2)
--  3:7  = Improved Searing Pain (3)  3:8  = Emberstorm (5)
--  3:9  = Ruin (1)                   3:10 = Conflagrate (1)
--  3:11 = Devastation (5)            3:12 = Aftermath (5)
--  3:13 = Improved Firebolt (2)      3:14 = Improved Lash of Pain (2)
--  3:15 = Intensity (2)              3:16 = Pyroclasm (2)
--  3:17 = Shadowfury (1)             3:18 = Shadow and Flame (5)
--  3:19 = Soul Leech (3)             3:20 = Nether Protection (3)
--  3:21 = Backlash (3)
-------------------------------------------------------------------------------

-- Bane: -0.1s cast time to Shadow Bolt and Immolate per rank, -0.4s to Soul Fire per rank
TalentMap["3:2"] = {
    name = "Bane",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = {"Shadow Bolt", "Immolate"} } },
        { type = MOD.CAST_TIME_REDUCTION, value = 0.4, perRank = true,
          filter = { spellNames = {"Soul Fire"} } },
    },
}

-- Improved Shadow Bolt (3:3): 5 ranks - Shadow Bolt crits apply a debuff increasing Shadow
-- damage taken by 4% per stack (up to 5 stacks). The debuff itself is modeled in AuraMap;
-- this talent merely enables it. No modifier entry needed here.

-- Improved Immolate: +5% Immolate direct damage per rank
TalentMap["3:4"] = {
    name = "Improved Immolate",
    maxRank = 5,
    effects = {
        {
            type = MOD.DIRECT_DAMAGE_MULTIPLIER,
            value = 0.05, perRank = true,
            filter = { spellNames = { "Immolate" } },
        },
    },
}

-- Improved Searing Pain: +4/7/10% crit to Searing Pain per rank
TalentMap["3:7"] = {
    name = "Improved Searing Pain",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = {0.04, 0.07, 0.10},
          filter = { spellNames = {"Searing Pain"} } },
    },
}

-- Emberstorm: +2% Fire damage per rank
TalentMap["3:8"] = {
    name = "Emberstorm",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { school = SCHOOL_FIRE } },
    },
}

-- Ruin: Destruction spell crits deal 200% damage instead of 150% (+0.5 crit multiplier)
TalentMap["3:9"] = {
    name = "Ruin",
    maxRank = 1,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.5, perRank = false,
          filter = { spellNames = {"Shadow Bolt", "Shadowburn", "Searing Pain", "Soul Fire",
                     "Incinerate", "Conflagrate", "Shadowfury", "Rain of Fire", "Hellfire", "Immolate"} } },
    },
}

-- Devastation: +1% crit chance to Destruction spells per rank
TalentMap["3:11"] = {
    name = "Devastation",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true,
          filter = { spellNames = {"Shadow Bolt", "Shadowburn", "Searing Pain", "Soul Fire",
                     "Incinerate", "Conflagrate", "Shadowfury", "Immolate"} } },
    },
}

-- Shadow and Flame: +4% of SP as coefficient bonus to Shadow Bolt and Incinerate per rank
TalentMap["3:18"] = {
    name = "Shadow and Flame",
    maxRank = 5,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.04, perRank = true,
          filter = { spellNames = {"Shadow Bolt", "Incinerate"} } },
    },
}

-- Backlash: +1% crit to all spells per rank (no school filter)
TalentMap["3:21"] = {
    name = "Backlash",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

for key, data in pairs(TalentMap) do
    ns.TalentMap["WARLOCK:" .. key] = data
end
