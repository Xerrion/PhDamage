local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- TalentMap_Mage.lua
-- Mage talent effects mapped to modifier descriptors for TBC Anniversary
-- Talent positions (tab:index) verified in-game on TBC Anniversary
-- (ordered by internal talentID)
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

ns.TalentMap = ns.TalentMap or {}

local SCHOOL_FIRE = ns.SCHOOL_FIRE
local SCHOOL_FROST = ns.SCHOOL_FROST
local SCHOOL_ARCANE = ns.SCHOOL_ARCANE
local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Arcane (Tab 1)
-- 1:1  Arcane Subtlety (2)               1:2  Arcane Concentration (5)
-- 1:3  Arcane Focus (5)                   1:4  Arcane Mind (5)
-- 1:5  Wand Specialization (2)            1:6  Improved Arcane Missiles (5)
-- 1:7  Arcane Impact (3)                  1:8  Magic Attunement (2)
-- 1:9  Improved Mana Shield (2)           1:10 Arcane Fortitude (1)
-- 1:11 Presence of Mind (1)               1:12 Arcane Power (1)
-- 1:13 Improved Counterspell (2)          1:14 Arcane Instability (3)
-- 1:15 Arcane Meditation (3)              1:16 Magic Absorption (5)
-- 1:17 Improved Blink (2)                 1:18 Arcane Potency (3)
-- 1:19 Prismatic Cloak (2)               1:20 Empowered Arcane Missiles (3)
-- 1:21 Mind Mastery (5)                   1:22 Slow (1)
-- 1:23 Spell Power (2)
-------------------------------------------------------------------------------

-- Arcane Focus: +2% Arcane hit per rank
TalentMap["1:3"] = {
    name = "Arcane Focus",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true, filter = { school = SCHOOL_ARCANE } },
    },
}

-- Arcane Impact: +2% crit per rank to Arcane Explosion and Arcane Blast
TalentMap["1:7"] = {
    name = "Arcane Impact",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Arcane Explosion", "Arcane Blast" } } },
    },
}

-- Arcane Instability: +1% damage AND +1% crit per rank to all spells
TalentMap["1:14"] = {
    name = "Arcane Instability",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Empowered Arcane Missiles: +0.75 total SP coefficient per rank (+0.15 per wave x 5 waves)
TalentMap["1:20"] = {
    name = "Empowered Arcane Missiles",
    maxRank = 3,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.75, perRank = true,
          filter = { spellNames = { "Arcane Missiles" } } },
    },
}

-- Spell Power: +25% crit damage bonus per rank (0.125 of the base 50% bonus)
TalentMap["1:23"] = {
    name = "Spell Power",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.125, perRank = true },
    },
}

-------------------------------------------------------------------------------
-- Fire (Tab 2)
-- 2:1  Burning Soul (2)                   2:2  Molten Shields (2)
-- 2:3  Improved Scorch (3)                2:4  Improved Fireball (5)
-- 2:5  Improved Fire Blast (3)            2:6  Flame Throwing (2)
-- 2:7  Pyroblast (1)                      2:8  Impact (5)
-- 2:9  Improved Flamestrike (3)           2:10 Blast Wave (1)
-- 2:11 Critical Mass (3)                  2:12 Ignite (5)
-- 2:13 Fire Power (5)                     2:14 Combustion (1)
-- 2:15 Incineration (2)                   2:16 Master of Elements (3)
-- 2:17 Playing with Fire (3)              2:18 Blazing Speed (2)
-- 2:19 Molten Fury (2)                    2:20 Pyromaniac (3)
-- 2:21 Empowered Fireball (5)             2:22 Dragon's Breath (1)
-------------------------------------------------------------------------------

-- Improved Fireball: -0.1s cast time per rank
TalentMap["2:4"] = {
    name = "Improved Fireball",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = { "Fireball" } } },
    },
}

-- Improved Flamestrike: +5% crit per rank to Flamestrike
TalentMap["2:9"] = {
    name = "Improved Flamestrike",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.05, perRank = true,
          filter = { spellNames = { "Flamestrike" } } },
    },
}

-- Critical Mass: +2% crit per rank to Fire spells
TalentMap["2:11"] = {
    name = "Critical Mass",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true, filter = { school = SCHOOL_FIRE } },
    },
}

-- Fire Power: +2% Fire damage per rank (additive with other talent bonuses)
TalentMap["2:13"] = {
    name = "Fire Power",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true,
          stacking = "additive", filter = { school = SCHOOL_FIRE } },
    },
}

-- Incineration: +2% crit per rank to Fire Blast and Scorch
TalentMap["2:15"] = {
    name = "Incineration",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Fire Blast", "Scorch" } } },
    },
}

-- Playing with Fire: +1% all damage per rank (additive)
TalentMap["2:17"] = {
    name = "Playing with Fire",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
    },
}

-- Molten Fury: +10% damage per rank to targets below 20% HP
TalentMap["2:19"] = {
    name = "Molten Fury",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true,
          filter = { targetHealthBelow = 20 } },
    },
}

-- Pyromaniac: +1% crit per rank to Fire spells
TalentMap["2:20"] = {
    name = "Pyromaniac",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true, filter = { school = SCHOOL_FIRE } },
    },
}

-- Empowered Fireball: +3% SP coefficient per rank to Fireball
TalentMap["2:21"] = {
    name = "Empowered Fireball",
    maxRank = 5,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.03, perRank = true,
          filter = { spellNames = { "Fireball" } } },
    },
}

-------------------------------------------------------------------------------
-- Frost (Tab 3)
-- 3:1  Improved Frostbolt (5)             3:2  Frostbite (3)
-- 3:3  Piercing Ice (3)                   3:4  Improved Frost Nova (2)
-- 3:5  Improved Blizzard (3)              3:6  Improved Cone of Cold (3)
-- 3:7  Permafrost (3)                     3:8  Frost Channeling (3)
-- 3:9  Shatter (5)                        3:10 Winter's Chill (5)
-- 3:11 Icy Veins (1)                      3:12 Frost Warding (2)
-- 3:13 Ice Barrier (1)                    3:14 Cold Snap (1)
-- 3:15 Ice Shards (5)                     3:16 Arctic Reach (2)
-- 3:17 Elemental Precision (3)            3:18 Frozen Core (3)
-- 3:19 Ice Floes (2)                      3:20 Arctic Winds (5)
-- 3:21 Empowered Frostbolt (5)            3:22 Summon Water Elemental (1)
-------------------------------------------------------------------------------

-- Improved Frostbolt: -0.1s cast time per rank
TalentMap["3:1"] = {
    name = "Improved Frostbolt",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = { "Frostbolt" } } },
    },
}

-- Piercing Ice: +2% Frost damage per rank (additive)
TalentMap["3:3"] = {
    name = "Piercing Ice",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true,
          stacking = "additive", filter = { school = SCHOOL_FROST } },
    },
}

-- Improved Cone of Cold: 15/25/35% damage bonus (non-linear - use table value)
TalentMap["3:6"] = {
    name = "Improved Cone of Cold",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = { 0.15, 0.25, 0.35 },
          filter = { spellNames = { "Cone of Cold" } } },
    },
}

-- Ice Shards: +20% crit damage bonus per rank to Frost (0.10 of base 50% bonus)
TalentMap["3:15"] = {
    name = "Ice Shards",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.10, perRank = true, filter = { school = SCHOOL_FROST } },
    },
}

-- Elemental Precision: +1% hit per rank to Fire and Frost
TalentMap["3:17"] = {
    name = "Elemental Precision",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true,
          filter = { schools = { SCHOOL_FIRE, SCHOOL_FROST } } },
    },
}

-- Arctic Winds: +1% Frost damage per rank (additive)
TalentMap["3:20"] = {
    name = "Arctic Winds",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true,
          stacking = "additive", filter = { school = SCHOOL_FROST } },
    },
}

-- Empowered Frostbolt: +2% SP coefficient AND +1% crit per rank to Frostbolt
TalentMap["3:21"] = {
    name = "Empowered Frostbolt",
    maxRank = 5,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Frostbolt" } } },
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true,
          filter = { spellNames = { "Frostbolt" } } },
    },
}

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["MAGE:" .. key] = data
end
