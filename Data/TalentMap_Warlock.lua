-------------------------------------------------------------------------------
-- TalentMap_Warlock.lua
-- Warlock talent effects mapped to modifier descriptors for TBC Anniversary
-- Talent positions (tab:index) sourced from Wowhead TBC Classic talent calculator
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
-------------------------------------------------------------------------------

-- Suppression: +1% spell hit to Affliction (Shadow) spells per rank
TalentMap["1:1"] = {
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

-- Improved Corruption: -0.4s cast time on Corruption per rank (5 ranks = instant)
TalentMap["1:2"] = {
    name = "Improved Corruption",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.4, perRank = true,
          filter = { spellNames = {"Corruption"} } },
    },
}

-- Improved Life Tap: +10/20% mana from Life Tap (Affliction 1:3, 2 ranks)
TalentMap["1:3"] = {
    name = "Improved Life Tap",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { spellNames = {"Life Tap"} } },
    },
}

-- Soul Siphon: +2/4% damage per Affliction effect on target for Drain Life/Soul (capped)
TalentMap["1:5"] = {
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

-- Improved Curse of Agony: +5% Curse of Agony damage per rank
TalentMap["1:6"] = {
    name = "Improved Curse of Agony",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05, perRank = true, stacking = "additive",
          filter = { spellNames = {"Curse of Agony"} } },
    },
}

-- Empowered Corruption: +12% of SP added to Corruption coefficient per rank
TalentMap["1:11"] = {
    name = "Empowered Corruption",
    maxRank = 3,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.12, perRank = true,
          filter = { spellNames = {"Corruption"} } },
    },
}

-- Siphon Life (1:13): 1 rank, enables the spell. No damage modifier.

-- Shadow Mastery: +2% Shadow damage per rank
TalentMap["1:15"] = {
    name = "Shadow Mastery",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { school = SCHOOL_SHADOW } },
    },
}

-- Contagion: +1% damage to Corruption, Seed of Corruption, and Curse of Agony per rank
TalentMap["1:16"] = {
    name = "Contagion",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { spellNames = {"Corruption", "Seed of Corruption", "Curse of Agony"} } },
    },
}

-- Unstable Affliction (1:21): 1 rank, enables the spell. No damage modifier.

-- Malediction: +1/2/3% to Curse of the Elements and Curse of Shadow damage amplification
-- The actual amplification is handled via talentAmplify in AuraMap entries for those curses;
-- this entry provides the talent definition for rank lookup.
TalentMap["1:19"] = {
    name = "Malediction",
    maxRank = 3,
    effects = {},
}

-------------------------------------------------------------------------------
-- Tab 2: Demonology
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
TalentMap["2:16"] = {
    name = "Master Demonologist",
    maxRank = 5,
    effects = {},
}

-- Demonic Sacrifice (2:18): 1 rank — sacrifice pet for a damage buff that depends on pet
-- type (Imp = +15% Fire, Succubus = +15% Shadow, etc.). Skipped for Phase 1 because it
-- requires tracking which pet was sacrificed. TODO: implement pet-sacrifice state tracking.

-- Demonic Knowledge (2:18): 3 ranks — +4% of pet (Stamina + Intellect) as spell damage per
-- rank. Skipped for Phase 1 because it requires reading live pet stats.
-- TODO: integrate with pet stat snapshot from StateCollector.

-------------------------------------------------------------------------------
-- Demonic Tactics (Demonology, Tier 9) — +1/2/3/4/5% crit to all spells
-- Talent index 2:19 is a placeholder — needs in-game verification
-------------------------------------------------------------------------------
TalentMap["2:19"] = {
    name = "Demonic Tactics",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-------------------------------------------------------------------------------
-- Tab 3: Destruction
-------------------------------------------------------------------------------

-- Improved Shadow Bolt (3:1): 5 ranks — Shadow Bolt crits apply a debuff increasing Shadow
-- damage taken by 4% per stack (up to 5 stacks). The debuff itself is modeled in AuraMap;
-- this talent merely enables it. No modifier entry needed here.

-- Bane: -0.1s cast time to Shadow Bolt and Immolate per rank, -0.4s to Soul Fire per rank
TalentMap["3:3"] = {
    name = "Bane",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = {"Shadow Bolt", "Immolate"} } },
        { type = MOD.CAST_TIME_REDUCTION, value = 0.4, perRank = true,
          filter = { spellNames = {"Soul Fire"} } },
    },
}

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

-- Devastation: +1% crit chance to Destruction spells per rank
TalentMap["3:7"] = {
    name = "Devastation",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true,
          filter = { spellNames = {"Shadow Bolt", "Shadowburn", "Searing Pain", "Soul Fire",
                     "Incinerate", "Conflagrate", "Shadowfury", "Immolate"} } },
    },
}

-- Improved Searing Pain: +4/7/10% crit to Searing Pain per rank
TalentMap["3:11"] = {
    name = "Improved Searing Pain",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = {0.04, 0.07, 0.10},
          filter = { spellNames = {"Searing Pain"} } },
    },
}

-- Ruin: Destruction spell crits deal 200% damage instead of 150% (+0.5 crit multiplier)
TalentMap["3:13"] = {
    name = "Ruin",
    maxRank = 1,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.5, perRank = false,
          filter = { spellNames = {"Shadow Bolt", "Shadowburn", "Searing Pain", "Soul Fire",
                     "Incinerate", "Conflagrate", "Shadowfury", "Rain of Fire", "Hellfire", "Immolate"} } },
    },
}

-- Emberstorm: +2% Fire damage per rank
TalentMap["3:14"] = {
    name = "Emberstorm",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { school = SCHOOL_FIRE } },
    },
}

-- Backlash: +1% crit to all spells per rank (no school filter)
TalentMap["3:15"] = {
    name = "Backlash",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
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

for key, data in pairs(TalentMap) do
    ns.TalentMap["WARLOCK:" .. key] = data
end
