-------------------------------------------------------------------------------
-- SpellData_Druid
-- Druid spell definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
-- Coefficient policy (TBC Classic 2.5.x):
-- Authoritative source: Wowhead TBC Classic (https://www.wowhead.com/tbc/),
-- per AGENTS.md. Values are stored as TOTAL spell-power coefficients consumed
-- verbatim by the engine. The engine does NOT recompute or apply additional
-- AoE/penalty multipliers at runtime.
--
-- Per-tick vs total: Wowhead's `SP mod` field on periodic effects is the
-- per-tick coefficient. The engine treats `coefficient` (and `dotCoefficient`
-- on hybrids) as TOTAL across the full duration, so periodic values stored
-- here are `SP_mod * numTicks`. For spells whose periodic damage is split
-- onto a trigger sub-spell (e.g. Arcane Missiles), the per-tick figure is
-- harvested from the trigger row, not the parent.
--
-- Per-rank overrides: a `coefficient` (or `directCoefficient` /
-- `dotCoefficient`) field on a per-rank table entry overrides the spell-level
-- value. This is required for sub-cap-level penalty ranks where Wowhead
-- reports a lower SP mod than the top-rank flat value.
--
-- Always cite the spell URL when adding or correcting entries:
-- https://www.wowhead.com/tbc/spell=<id>
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

local SCHOOL_NATURE = ns.SCHOOL_NATURE
local SCHOOL_ARCANE = ns.SCHOOL_ARCANE
local SCHOOL_PHYSICAL = ns.SCHOOL_PHYSICAL

local SpellData = {}

-------------------------------------------------------------------------------
-- Balance Spells
-------------------------------------------------------------------------------

-- Wrath — 2.0s cast, Nature, direct
-- Coefficient: 0.571
SpellData[5176] = {
    name = "Wrath",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 0.571,
    castTime = 2.0,
    canCrit = true,
    ranks = {
        -- Wowhead spell=5176 (sub-cap penalty rank, SP mod 0.123)
        [1]  = { spellID = 5176,  minDmg = 13,  maxDmg = 16,  level = 1, maxLevel = 5,  coefficient = 0.123 },
        -- Wowhead spell=5177 (sub-cap penalty rank, SP mod 0.231)
        [2]  = { spellID = 5177,  minDmg = 28,  maxDmg = 33,  level = 6, maxLevel = 13,  coefficient = 0.231 },
        -- Wowhead spell=5178 (sub-cap penalty rank, SP mod 0.443)
        [3]  = { spellID = 5178,  minDmg = 48,  maxDmg = 54,  level = 14, maxLevel = 21, coefficient = 0.443 },
        [4]  = { spellID = 5179,  minDmg = 69,  maxDmg = 79,  level = 22, maxLevel = 29 },
        [5]  = { spellID = 5180,  minDmg = 108, maxDmg = 123, level = 30, maxLevel = 37 },
        [6]  = { spellID = 6780,  minDmg = 148, maxDmg = 167, level = 38, maxLevel = 45 },
        [7]  = { spellID = 8905,  minDmg = 198, maxDmg = 221, level = 46, maxLevel = 53 },
        [8]  = { spellID = 9912,  minDmg = 248, maxDmg = 277, level = 54, maxLevel = 60 },
        [9]  = { spellID = 26984, minDmg = 292, maxDmg = 327, level = 61, maxLevel = 68 },
        [10] = { spellID = 26985, minDmg = 383, maxDmg = 432, level = 69, maxLevel = 69 },
    },
}

-- Starfire — 3.5s cast, Arcane, direct
-- Coefficient: 1.0
SpellData[2912] = {
    name = "Starfire",
    school = SCHOOL_ARCANE,
    spellType = "direct",
    coefficient = 1.0,
    castTime = 3.5,
    canCrit = true,
    ranks = {
        [1] = { spellID = 2912,  minDmg = 95,  maxDmg = 115, level = 20, maxLevel = 25 },
        [2] = { spellID = 8949,  minDmg = 146, maxDmg = 177, level = 26, maxLevel = 33 },
        [3] = { spellID = 8950,  minDmg = 212, maxDmg = 253, level = 34, maxLevel = 41 },
        [4] = { spellID = 8951,  minDmg = 293, maxDmg = 348, level = 42, maxLevel = 49 },
        [5] = { spellID = 9875,  minDmg = 378, maxDmg = 445, level = 50, maxLevel = 57 },
        [6] = { spellID = 9876,  minDmg = 463, maxDmg = 543, level = 58, maxLevel = 66 },
        [7] = { spellID = 25298, minDmg = 550, maxDmg = 647, level = 67, maxLevel = 69 },
        [8] = { spellID = 26986, minDmg = 625, maxDmg = 735, level = 70, maxLevel = 70 },
    },
}

-- Moonfire — instant cast, Arcane direct + Nature DoT, hybrid
-- Direct coefficient: 0.15, DoT coefficient: 0.52
-- DoT: 12s duration, 4 ticks
SpellData[8921] = {
    name = "Moonfire",
    school = SCHOOL_ARCANE,
    spellType = "hybrid",
    directCoefficient = 0.15,
    dotCoefficient = 0.52,
    duration = 12,
    numTicks = 4,
    castTime = 0,
    canCrit = true,
    ranks = {
        -- Wowhead spell=8921 (sub-cap penalty rank, dir SP mod 0.06, dot per-tick 0.052 x 4 = 0.208)
        [1]  = { spellID = 8921,  minDmg = 9,   maxDmg = 9,   dotDmg = 12,  level = 4, maxLevel = 9,
                 directCoefficient = 0.06,  dotCoefficient = 0.208 },
        -- Wowhead spell=8924 (sub-cap penalty rank, dir SP mod 0.094, dot per-tick 0.081 x 4 = 0.324)
        [2]  = { spellID = 8924,  minDmg = 17,  maxDmg = 17,  dotDmg = 32,  level = 10, maxLevel = 15,
                 directCoefficient = 0.094, dotCoefficient = 0.324 },
        -- Wowhead spell=8925 (sub-cap penalty rank, dir SP mod 0.128, dot per-tick 0.111 x 4 = 0.444)
        [3]  = { spellID = 8925,  minDmg = 30,  maxDmg = 30,  dotDmg = 52,  level = 16, maxLevel = 21,
                 directCoefficient = 0.128, dotCoefficient = 0.444 },
        [4]  = { spellID = 8926,  minDmg = 47,  maxDmg = 47,  dotDmg = 80,  level = 22, maxLevel = 27 },
        [5]  = { spellID = 8927,  minDmg = 70,  maxDmg = 70,  dotDmg = 124, level = 28, maxLevel = 33 },
        [6]  = { spellID = 8928,  minDmg = 91,  maxDmg = 91,  dotDmg = 164, level = 34, maxLevel = 39 },
        [7]  = { spellID = 8929,  minDmg = 117, maxDmg = 117, dotDmg = 212, level = 40, maxLevel = 45 },
        [8]  = { spellID = 9833,  minDmg = 143, maxDmg = 143, dotDmg = 264, level = 46, maxLevel = 51 },
        [9]  = { spellID = 9834,  minDmg = 172, maxDmg = 172, dotDmg = 320, level = 52, maxLevel = 57 },
        [10] = { spellID = 9835,  minDmg = 205, maxDmg = 205, dotDmg = 384, level = 58, maxLevel = 62 },
        [11] = { spellID = 26987, minDmg = 238, maxDmg = 238, dotDmg = 444, level = 63, maxLevel = 69 },
        [12] = { spellID = 26988, minDmg = 305, maxDmg = 305, dotDmg = 600, level = 70, maxLevel = 70 },
    },
}

-- Insect Swarm — instant cast, Nature DoT
-- Coefficient: 0.762 (total)
-- 12s duration, 6 ticks
SpellData[5570] = {
    name = "Insect Swarm",
    school = SCHOOL_NATURE,
    spellType = "dot",
    coefficient = 0.762,
    duration = 12,
    numTicks = 6,
    castTime = 0,
    canCrit = false,
    ranks = {
        [1] = { spellID = 5570,  totalDmg = 108, level = 20, maxLevel = 29 },
        [2] = { spellID = 24974, totalDmg = 192, level = 30, maxLevel = 39 },
        [3] = { spellID = 24975, totalDmg = 300, level = 40, maxLevel = 49 },
        [4] = { spellID = 24976, totalDmg = 432, level = 50, maxLevel = 59 },
        [5] = { spellID = 24977, totalDmg = 594, level = 60, maxLevel = 69 },
        [6] = { spellID = 27013, totalDmg = 792, level = 70, maxLevel = 70 },
    },
}

-- Hurricane: 10-second channel, 10 ticks @ 1s. Wowhead per-tick SP mod 0.107 -> 1.07 total.
-- Source: https://www.wowhead.com/tbc/spell=27012
SpellData[16914] = {
    name = "Hurricane",
    school = SCHOOL_NATURE,
    spellType = "channel",
    coefficient = 1.07,
    duration = 10,
    numTicks = 10,
    canCrit = false,
    isAoe = true,
    ranks = {
        [1] = { spellID = 16914, effectID = 42231, totalDmg = 206, level = 40, maxLevel = 49 },
        [2] = { spellID = 17401, effectID = 42232, totalDmg = 338, level = 50, maxLevel = 59 },
        [3] = { spellID = 17402, effectID = 42233, totalDmg = 482, level = 60, maxLevel = 69 },
        [4] = { spellID = 27012, effectID = 42230, totalDmg = 734, level = 70, maxLevel = 70 },
    },
}

-- Entangling Roots — 1.5s cast, Nature DoT (CC spell)
-- Coefficient: 0.1 (very low, primarily CC)
-- Duration and numTicks vary per rank
SpellData[339] = {
    name = "Entangling Roots",
    school = SCHOOL_NATURE,
    spellType = "dot",
    coefficient = 0.1,
    castTime = 1.5,
    canCrit = false,
    ranks = {
        [1] = { spellID = 339,   totalDmg = 20,  level = 8, maxLevel = 17,  duration = 12, numTicks = 4  },
        [2] = { spellID = 1062,  totalDmg = 50,  level = 18, maxLevel = 27, duration = 15, numTicks = 5  },
        [3] = { spellID = 5195,  totalDmg = 90,  level = 28, maxLevel = 37, duration = 18, numTicks = 6  },
        [4] = { spellID = 5196,  totalDmg = 140, level = 38, maxLevel = 47, duration = 21, numTicks = 7  },
        [5] = { spellID = 9852,  totalDmg = 200, level = 48, maxLevel = 57, duration = 24, numTicks = 8  },
        [6] = { spellID = 9853,  totalDmg = 270, level = 58, maxLevel = 68, duration = 27, numTicks = 9  },
        [7] = { spellID = 26989, totalDmg = 351, level = 69, maxLevel = 69, duration = 30, numTicks = 10 },
    },
}

-------------------------------------------------------------------------------
-- Feral Combat — Cat Form
-------------------------------------------------------------------------------

-- Claw — instant, Physical, weapon + flat bonus
-- Cat form normalized speed: 1.0
SpellData[1082] = {
    name = "Claw",
    school = SCHOOL_PHYSICAL,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    normalizedSpeed = 1.0,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 1082,  minDmg = 16,  maxDmg = 16,  level = 20, maxLevel = 27 },
        [2] = { spellID = 3029,  minDmg = 26,  maxDmg = 26,  level = 28, maxLevel = 35 },
        [3] = { spellID = 5201,  minDmg = 38,  maxDmg = 38,  level = 36, maxLevel = 43 },
        [4] = { spellID = 9849,  minDmg = 52,  maxDmg = 52,  level = 44, maxLevel = 51 },
        [5] = { spellID = 9850,  minDmg = 67,  maxDmg = 67,  level = 52, maxLevel = 63 },
        [6] = { spellID = 27000, minDmg = 115, maxDmg = 115, level = 64, maxLevel = 64 },
    },
}

-- Shred — instant, Physical, 225% weapon + flat bonus, requires behind target
-- Cat form normalized speed: 1.0
SpellData[5221] = {
    name = "Shred",
    school = SCHOOL_PHYSICAL,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 2.25,
    normalizedSpeed = 1.0,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 5221,  minDmg = 36,  maxDmg = 36,  level = 22, maxLevel = 29 },
        [2] = { spellID = 6800,  minDmg = 54,  maxDmg = 54,  level = 30, maxLevel = 37 },
        [3] = { spellID = 8992,  minDmg = 69,  maxDmg = 69,  level = 38, maxLevel = 45 },
        [4] = { spellID = 9829,  minDmg = 99,  maxDmg = 99,  level = 46, maxLevel = 53 },
        [5] = { spellID = 9830,  minDmg = 116, maxDmg = 116, level = 54, maxLevel = 63 },
        [6] = { spellID = 27001, minDmg = 180, maxDmg = 180, level = 64, maxLevel = 69 },
        [7] = { spellID = 27002, minDmg = 203, maxDmg = 203, level = 70, maxLevel = 70 },
    },
}

-- Mangle (Cat) — instant, Physical, 160% weapon + flat bonus (Feral talent)
-- Cat form normalized speed: 1.0
SpellData[33876] = {
    name = "Mangle (Cat)",
    school = SCHOOL_PHYSICAL,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 1.6,
    normalizedSpeed = 1.0,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 33876, minDmg = 121, maxDmg = 121, level = 50, maxLevel = 59 },
        [2] = { spellID = 33982, minDmg = 151, maxDmg = 151, level = 60, maxLevel = 69 },
        [3] = { spellID = 33983, minDmg = 190, maxDmg = 190, level = 70, maxLevel = 70 },
    },
}

-- Rake — instant, Physical hybrid (direct + bleed DoT)
-- Direct AP coefficient: 0.01, DoT AP coefficient: 0.06 per tick
-- DoT: 9s duration, 3 ticks
SpellData[1822] = {
    name = "Rake",
    school = SCHOOL_PHYSICAL,
    spellType = "hybrid",
    scalingType = "melee",
    apCoefficient = 0.01,
    dotApCoefficient = 0.06,
    duration = 9,
    numTicks = 3,
    castTime = 0,
    canCrit = false,
    ranks = {
        [1] = { spellID = 1822,  minDmg = 19, maxDmg = 19, dotDmg = 39,  level = 24, maxLevel = 33 },
        [2] = { spellID = 1823,  minDmg = 29, maxDmg = 29, dotDmg = 57,  level = 34, maxLevel = 43 },
        [3] = { spellID = 1824,  minDmg = 43, maxDmg = 43, dotDmg = 84,  level = 44, maxLevel = 53 },
        [4] = { spellID = 9904,  minDmg = 58, maxDmg = 58, dotDmg = 111, level = 54, maxLevel = 63 },
        [5] = { spellID = 27003, minDmg = 78, maxDmg = 78, dotDmg = 150, level = 64, maxLevel = 64 },
    },
}

-- Ferocious Bite — instant, Physical direct, finishing move
-- AP coefficient: 0.15 (at 5 combo points)
SpellData[22568] = {
    name = "Ferocious Bite",
    school = SCHOOL_PHYSICAL,
    spellType = "direct",
    scalingType = "melee",
    apCoefficient = 0.15,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 22568, minDmg = 52,  maxDmg = 82,  level = 32, maxLevel = 39 },
        [2] = { spellID = 22827, minDmg = 93,  maxDmg = 137, level = 40, maxLevel = 47 },
        [3] = { spellID = 22828, minDmg = 133, maxDmg = 193, level = 48, maxLevel = 55 },
        [4] = { spellID = 22829, minDmg = 169, maxDmg = 245, level = 56, maxLevel = 62 },
        [5] = { spellID = 31018, minDmg = 203, maxDmg = 297, level = 63, maxLevel = 69 },
        [6] = { spellID = 24248, minDmg = 259, maxDmg = 371, level = 70, maxLevel = 70 },
    },
}

-- Rip — instant, Physical DoT, finishing move
-- AP coefficient: 0.24 (total over full duration at 5 combo points)
-- 12s duration, 6 ticks
SpellData[1079] = {
    name = "Rip",
    school = SCHOOL_PHYSICAL,
    spellType = "dot",
    scalingType = "melee",
    apCoefficient = 0.24,
    duration = 12,
    numTicks = 6,
    castTime = 0,
    canCrit = false,
    ranks = {
        [1] = { spellID = 1079,  totalDmg = 186,  level = 20, maxLevel = 27 },
        [2] = { spellID = 9492,  totalDmg = 252,  level = 28, maxLevel = 35 },
        [3] = { spellID = 9493,  totalDmg = 342,  level = 36, maxLevel = 43 },
        [4] = { spellID = 9752,  totalDmg = 456,  level = 44, maxLevel = 51 },
        [5] = { spellID = 9894,  totalDmg = 594,  level = 52, maxLevel = 59 },
        [6] = { spellID = 9896,  totalDmg = 732,  level = 60, maxLevel = 66 },
        [7] = { spellID = 27008, totalDmg = 1038, level = 67, maxLevel = 67 },
    },
}

-------------------------------------------------------------------------------
-- Feral Combat — Bear Form
-------------------------------------------------------------------------------

-- Maul — instant (next melee), Physical, weapon + flat bonus
-- Bear form normalized speed: 2.5
SpellData[6807] = {
    name = "Maul",
    school = SCHOOL_PHYSICAL,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    normalizedSpeed = 2.5,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 6807,  minDmg = 18,  maxDmg = 18,  level = 10, maxLevel = 17 },
        [2] = { spellID = 6808,  minDmg = 27,  maxDmg = 27,  level = 18, maxLevel = 25 },
        [3] = { spellID = 6809,  minDmg = 37,  maxDmg = 37,  level = 26, maxLevel = 33 },
        [4] = { spellID = 8972,  minDmg = 49,  maxDmg = 49,  level = 34, maxLevel = 41 },
        [5] = { spellID = 9745,  minDmg = 71,  maxDmg = 71,  level = 42, maxLevel = 49 },
        [6] = { spellID = 9880,  minDmg = 101, maxDmg = 101, level = 50, maxLevel = 57 },
        [7] = { spellID = 9881,  minDmg = 128, maxDmg = 128, level = 58, maxLevel = 65 },
        [8] = { spellID = 26996, minDmg = 176, maxDmg = 176, level = 66, maxLevel = 66 },
    },
}

-- Swipe (Bear): instant cleave. AP coefficient 0.07 retained from prior PhDamage convention;
-- Wowhead does not expose AP coefficients for Druid Feral spells.
SpellData[779] = {
    name = "Swipe",
    school = SCHOOL_PHYSICAL,
    spellType = "direct",
    scalingType = "melee",
    apCoefficient = 0.07,
    castTime = 0,
    canCrit = true,
    isAoe = true,
    ranks = {
        [1] = { spellID = 779,   minDmg = 18,  maxDmg = 18,  level = 16, maxLevel = 23 },
        [2] = { spellID = 780,   minDmg = 25,  maxDmg = 25,  level = 24, maxLevel = 33 },
        [3] = { spellID = 769,   minDmg = 36,  maxDmg = 36,  level = 34, maxLevel = 43 },
        [4] = { spellID = 9754,  minDmg = 54,  maxDmg = 54,  level = 44, maxLevel = 53 },
        [5] = { spellID = 9908,  minDmg = 83,  maxDmg = 83,  level = 54, maxLevel = 63 },
        [6] = { spellID = 26997, minDmg = 108, maxDmg = 108, level = 64, maxLevel = 64 },
    },
}

-- Mangle (Bear) — instant, Physical, 115% weapon + flat bonus (Feral talent)
-- Bear form normalized speed: 2.5
SpellData[33878] = {
    name = "Mangle (Bear)",
    school = SCHOOL_PHYSICAL,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 1.15,
    normalizedSpeed = 2.5,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 33878, minDmg = 128, maxDmg = 128, level = 50, maxLevel = 59 },
        [2] = { spellID = 33986, minDmg = 160, maxDmg = 160, level = 60, maxLevel = 69 },
        [3] = { spellID = 33987, minDmg = 199, maxDmg = 199, level = 70, maxLevel = 70 },
    },
}

-- Lacerate — instant, Physical hybrid (direct + stacking bleed DoT)
-- Direct AP coefficient: 0.01, DoT AP coefficient: 0.01 per tick
-- DoT: 15s duration, 5 ticks
SpellData[33745] = {
    name = "Lacerate",
    school = SCHOOL_PHYSICAL,
    spellType = "hybrid",
    scalingType = "melee",
    apCoefficient = 0.01,
    dotApCoefficient = 0.01,
    duration = 15,
    numTicks = 5,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 33745, minDmg = 31, maxDmg = 31, dotDmg = 310, level = 66, maxLevel = 66 },
    },
}

-------------------------------------------------------------------------------
-- Restoration
-------------------------------------------------------------------------------

-- Healing Touch — 3.5s cast, Nature, direct heal
-- Coefficient: 1.0
SpellData[5185] = {
    name = "Healing Touch",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 1.0,
    castTime = 3.5,
    canCrit = true,
    isHealing = true,
    ranks = {
        [1]  = { spellID = 5185,  minDmg = 40,   maxDmg = 55,   level = 1, maxLevel = 7  },
        [2]  = { spellID = 5186,  minDmg = 94,   maxDmg = 119,  level = 8, maxLevel = 13  },
        [3]  = { spellID = 5187,  minDmg = 204,  maxDmg = 253,  level = 14, maxLevel = 19 },
        [4]  = { spellID = 5188,  minDmg = 376,  maxDmg = 459,  level = 20, maxLevel = 25 },
        [5]  = { spellID = 5189,  minDmg = 589,  maxDmg = 712,  level = 26, maxLevel = 31 },
        [6]  = { spellID = 6778,  minDmg = 762,  maxDmg = 914,  level = 32, maxLevel = 37 },
        [7]  = { spellID = 8903,  minDmg = 958,  maxDmg = 1143, level = 38, maxLevel = 43 },
        [8]  = { spellID = 9758,  minDmg = 1225, maxDmg = 1453, level = 44, maxLevel = 49 },
        [9]  = { spellID = 9888,  minDmg = 1545, maxDmg = 1826, level = 50, maxLevel = 55 },
        [10] = { spellID = 9889,  minDmg = 1916, maxDmg = 2261, level = 56, maxLevel = 59 },
        [11] = { spellID = 25297, minDmg = 2267, maxDmg = 2677, level = 60, maxLevel = 64 },
        [12] = { spellID = 26978, minDmg = 2707, maxDmg = 3197, level = 65, maxLevel = 69 },
        [13] = { spellID = 26979, minDmg = 3229, maxDmg = 3811, level = 70, maxLevel = 70 },
    },
}

-- Rejuvenation — instant, Nature HoT
-- Coefficient: 0.80 (total)
-- 12s duration, 4 ticks
SpellData[774] = {
    name = "Rejuvenation",
    school = SCHOOL_NATURE,
    spellType = "dot",
    coefficient = 0.80,
    duration = 12,
    numTicks = 4,
    castTime = 0,
    canCrit = false,
    isHealing = true,
    ranks = {
        [1]  = { spellID = 774,   totalDmg = 32,   level = 4, maxLevel = 9  },
        [2]  = { spellID = 1058,  totalDmg = 56,   level = 10, maxLevel = 15 },
        [3]  = { spellID = 1430,  totalDmg = 116,  level = 16, maxLevel = 21 },
        [4]  = { spellID = 2090,  totalDmg = 180,  level = 22, maxLevel = 27 },
        [5]  = { spellID = 2091,  totalDmg = 244,  level = 28, maxLevel = 33 },
        [6]  = { spellID = 3627,  totalDmg = 304,  level = 34, maxLevel = 39 },
        [7]  = { spellID = 8910,  totalDmg = 388,  level = 40, maxLevel = 45 },
        [8]  = { spellID = 9839,  totalDmg = 488,  level = 46, maxLevel = 51 },
        [9]  = { spellID = 9840,  totalDmg = 608,  level = 52, maxLevel = 57 },
        [10] = { spellID = 9841,  totalDmg = 756,  level = 58, maxLevel = 59 },
        [11] = { spellID = 25299, totalDmg = 888,  level = 60, maxLevel = 64 },
        [12] = { spellID = 26981, totalDmg = 1060, level = 65, maxLevel = 69 },
        [13] = { spellID = 26982, totalDmg = 1192, level = 70, maxLevel = 70 },
    },
}

-- Regrowth — 2.0s cast, Nature hybrid (direct heal + HoT)
-- Direct coefficient: 0.286, HoT coefficient: 0.70 (total)
-- HoT: 21s duration, 7 ticks
SpellData[8936] = {
    name = "Regrowth",
    school = SCHOOL_NATURE,
    spellType = "hybrid",
    directCoefficient = 0.286,
    dotCoefficient = 0.70,
    duration = 21,
    numTicks = 7,
    castTime = 2.0,
    canCrit = true,
    isHealing = true,
    ranks = {
        [1]  = { spellID = 8936,  minDmg = 93,   maxDmg = 107,  dotDmg = 98,   level = 12, maxLevel = 17 },
        [2]  = { spellID = 8938,  minDmg = 176,  maxDmg = 201,  dotDmg = 175,  level = 18, maxLevel = 23 },
        [3]  = { spellID = 8939,  minDmg = 255,  maxDmg = 290,  dotDmg = 259,  level = 24, maxLevel = 29 },
        [4]  = { spellID = 8940,  minDmg = 336,  maxDmg = 378,  dotDmg = 343,  level = 30, maxLevel = 35 },
        [5]  = { spellID = 8941,  minDmg = 425,  maxDmg = 478,  dotDmg = 427,  level = 36, maxLevel = 41 },
        [6]  = { spellID = 9750,  minDmg = 534,  maxDmg = 599,  dotDmg = 546,  level = 42, maxLevel = 47 },
        [7]  = { spellID = 9856,  minDmg = 672,  maxDmg = 751,  dotDmg = 686,  level = 48, maxLevel = 53 },
        [8]  = { spellID = 9857,  minDmg = 839,  maxDmg = 935,  dotDmg = 861,  level = 54, maxLevel = 59 },
        [9]  = { spellID = 9858,  minDmg = 1003, maxDmg = 1119, dotDmg = 1064, level = 60, maxLevel = 69 },
        [10] = { spellID = 26980, minDmg = 1253, maxDmg = 1394, dotDmg = 1274, level = 70, maxLevel = 70 },
    },
}

-- Lifebloom — instant, Nature hybrid (bloom direct + HoT)
-- Bloom coefficient: 0.3432, HoT coefficient: 0.5194 (total, 7 ticks * 0.0742)
-- 7s duration, 7 ticks
SpellData[33763] = {
    name = "Lifebloom",
    school = SCHOOL_NATURE,
    spellType = "hybrid",
    directCoefficient = 0.3432,
    dotCoefficient = 0.5194,
    duration = 7,
    numTicks = 7,
    castTime = 0,
    canCrit = true,
    isHealing = true,
    ranks = {
        [1] = { spellID = 33763, minDmg = 600, maxDmg = 600, dotDmg = 539, level = 64, maxLevel = 64 },
    },
}

-- Tranquility — channeled, Nature heal, 8s duration, 4 ticks
-- Coefficient: 1.144 (total, 0.286 per tick)
SpellData[740] = {
    name = "Tranquility",
    school = SCHOOL_NATURE,
    spellType = "channel",
    coefficient = 1.144,
    duration = 8,
    numTicks = 4,
    canCrit = false,
    isHealing = true,
    ranks = {
        [1] = { spellID = 740,   totalDmg = 364,  level = 30, maxLevel = 39 },
        [2] = { spellID = 8918,  totalDmg = 536,  level = 40, maxLevel = 49 },
        [3] = { spellID = 9862,  totalDmg = 790,  level = 50, maxLevel = 59 },
        [4] = { spellID = 9863,  totalDmg = 1120, level = 60, maxLevel = 69 },
        [5] = { spellID = 26983, totalDmg = 1518, level = 70, maxLevel = 70 },
    },
}

-------------------------------------------------------------------------------
-- Merge into addon namespace
-------------------------------------------------------------------------------
for spellID, data in pairs(SpellData) do
    ns.SpellData[spellID] = data
end
