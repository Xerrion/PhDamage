-------------------------------------------------------------------------------
-- SpellData_Priest
-- Priest spell definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.SpellData = ns.SpellData or {}

local SCHOOL_HOLY = ns.SCHOOL_HOLY
local SCHOOL_SHADOW = ns.SCHOOL_SHADOW

local SpellData = {}

-------------------------------------------------------------------------------
-- Shadow Spells
-------------------------------------------------------------------------------

-- Shadow Word: Pain — instant cast, Shadow, DoT
-- 18s duration, 6 ticks every 3 sec
-- Coefficient: 1.098 total (0.183 per tick × 6 ticks, confirmed on Wowhead)
SpellData[589] = {
    name = "Shadow Word: Pain",
    school = SCHOOL_SHADOW,
    spellType = "dot",
    coefficient = 1.098,
    castTime = 0,
    canCrit = false,
    duration = 18,
    numTicks = 6,
    ranks = {
        [1]  = { spellID = 589,   totalDmg = 30,   level = 4  },
        [2]  = { spellID = 594,   totalDmg = 66,   level = 10 },
        [3]  = { spellID = 970,   totalDmg = 132,  level = 18 },
        [4]  = { spellID = 992,   totalDmg = 234,  level = 26 },
        [5]  = { spellID = 2767,  totalDmg = 366,  level = 34 },
        [6]  = { spellID = 10892, totalDmg = 510,  level = 42 },
        [7]  = { spellID = 10893, totalDmg = 672,  level = 50 },
        [8]  = { spellID = 10894, totalDmg = 852,  level = 58 },
        [9]  = { spellID = 25367, totalDmg = 1002, level = 65 },
        [10] = { spellID = 25368, totalDmg = 1236, level = 70 },
    },
}

-- Mind Blast — 1.5s cast, Shadow, direct
-- Coefficient: 0.4286 (1.5 / 3.5)
-- 8s cooldown
SpellData[8092] = {
    name = "Mind Blast",
    school = SCHOOL_SHADOW,
    spellType = "direct",
    coefficient = 0.4286,
    castTime = 1.5,
    canCrit = true,
    ranks = {
        [1]  = { spellID = 8092,  minDmg = 39,  maxDmg = 43,  level = 10 },
        [2]  = { spellID = 8102,  minDmg = 72,  maxDmg = 78,  level = 16 },
        [3]  = { spellID = 8103,  minDmg = 112, maxDmg = 120, level = 22 },
        [4]  = { spellID = 8104,  minDmg = 167, maxDmg = 177, level = 28 },
        [5]  = { spellID = 8105,  minDmg = 217, maxDmg = 231, level = 34 },
        [6]  = { spellID = 8106,  minDmg = 279, maxDmg = 297, level = 40 },
        [7]  = { spellID = 10945, minDmg = 346, maxDmg = 366, level = 46 },
        [8]  = { spellID = 10946, minDmg = 425, maxDmg = 449, level = 52 },
        [9]  = { spellID = 10947, minDmg = 503, maxDmg = 531, level = 58 },
        [10] = { spellID = 25372, minDmg = 557, maxDmg = 587, level = 63 },
        [11] = { spellID = 25375, minDmg = 708, maxDmg = 748, level = 69 },
    },
}

-- Mind Flay — 3s channel, Shadow, 3 ticks every 1 sec (talent)
-- Coefficient: 0.57 total (0.19 per tick × 3 ticks)
SpellData[15407] = {
    name = "Mind Flay",
    school = SCHOOL_SHADOW,
    spellType = "channel",
    coefficient = 0.57,
    canCrit = false,
    duration = 3,
    numTicks = 3,
    ranks = {
        [1] = { spellID = 15407, totalDmg = 75,  level = 20 },
        [2] = { spellID = 17311, totalDmg = 126, level = 28 },
        [3] = { spellID = 17312, totalDmg = 186, level = 36 },
        [4] = { spellID = 17313, totalDmg = 261, level = 44 },
        [5] = { spellID = 17314, totalDmg = 330, level = 52 },
        [6] = { spellID = 18807, totalDmg = 426, level = 60 },
        [7] = { spellID = 25387, totalDmg = 528, level = 68 },
    },
}

-- Shadow Word: Death — instant cast, Shadow, direct
-- Coefficient: 0.429 (1.5 / 3.5)
-- 12s cooldown, deals equal damage to caster
SpellData[32379] = {
    name = "Shadow Word: Death",
    school = SCHOOL_SHADOW,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 32379, minDmg = 450, maxDmg = 522, level = 62 },
        [2] = { spellID = 32996, minDmg = 572, maxDmg = 664, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- Holy Spells
-------------------------------------------------------------------------------

-- Smite — cast time varies by rank, Holy, direct
-- R1: 1.5s cast, R2: 2.0s cast, R3+: 2.5s cast
-- Coefficient: 0.7143 (2.5 / 3.5, based on max-rank cast time)
SpellData[585] = {
    name = "Smite",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.7143,
    castTime = 2.5,
    canCrit = true,
    ranks = {
        [1]  = { spellID = 585,   minDmg = 13,  maxDmg = 17,  level = 1  },
        [2]  = { spellID = 591,   minDmg = 25,  maxDmg = 31,  level = 6  },
        [3]  = { spellID = 598,   minDmg = 54,  maxDmg = 62,  level = 14 },
        [4]  = { spellID = 984,   minDmg = 91,  maxDmg = 105, level = 22 },
        [5]  = { spellID = 1004,  minDmg = 150, maxDmg = 170, level = 30 },
        [6]  = { spellID = 6060,  minDmg = 212, maxDmg = 240, level = 38 },
        [7]  = { spellID = 10933, minDmg = 287, maxDmg = 323, level = 46 },
        [8]  = { spellID = 10934, minDmg = 371, maxDmg = 415, level = 54 },
        [9]  = { spellID = 25363, minDmg = 405, maxDmg = 453, level = 61 },
        [10] = { spellID = 25364, minDmg = 545, maxDmg = 611, level = 69 },
    },
}

-- Holy Fire — 3.5s cast, Holy, hybrid (direct + DoT)
-- Direct coefficient: 0.857 (3.5 / 3.5 adjusted for hybrid split)
-- DoT coefficient: 0.165 total (0.033 per tick × 5 ticks)
-- DoT: 10s duration, 5 ticks every 2 sec
SpellData[14914] = {
    name = "Holy Fire",
    school = SCHOOL_HOLY,
    spellType = "hybrid",
    directCoefficient = 0.857,
    dotCoefficient = 0.165,
    duration = 10,
    numTicks = 5,
    castTime = 3.5,
    canCrit = true,
    ranks = {
        [1] = { spellID = 14914, minDmg = 78,  maxDmg = 98,  dotDmg = 30,  level = 20 },
        [2] = { spellID = 15262, minDmg = 96,  maxDmg = 120, dotDmg = 40,  level = 24 },
        [3] = { spellID = 15263, minDmg = 132, maxDmg = 166, dotDmg = 55,  level = 30 },
        [4] = { spellID = 15264, minDmg = 165, maxDmg = 209, dotDmg = 65,  level = 36 },
        [5] = { spellID = 15265, minDmg = 204, maxDmg = 258, dotDmg = 85,  level = 42 },
        [6] = { spellID = 15266, minDmg = 254, maxDmg = 322, dotDmg = 100, level = 48 },
        [7] = { spellID = 15267, minDmg = 304, maxDmg = 386, dotDmg = 125, level = 54 },
        [8] = { spellID = 15261, minDmg = 355, maxDmg = 449, dotDmg = 145, level = 60 },
        [9] = { spellID = 25384, minDmg = 412, maxDmg = 522, dotDmg = 165, level = 66 },
    },
}

-- Holy Nova — instant cast, Holy, AoE direct damage + healing (talent)
-- Coefficient: 0.161 (AoE instant penalty)
SpellData[15237] = {
    name = "Holy Nova",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.161,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 15237, minDmg = 28,  maxDmg = 32,  level = 20 },
        [2] = { spellID = 15430, minDmg = 50,  maxDmg = 58,  level = 28 },
        [3] = { spellID = 15431, minDmg = 76,  maxDmg = 88,  level = 36 },
        [4] = { spellID = 27799, minDmg = 106, maxDmg = 122, level = 44 },
        [5] = { spellID = 27800, minDmg = 140, maxDmg = 162, level = 52 },
        [6] = { spellID = 27801, minDmg = 181, maxDmg = 209, level = 60 },
        [7] = { spellID = 25331, minDmg = 242, maxDmg = 280, level = 68 },
    },
}

-- Merge into addon namespace
for baseID, data in pairs(SpellData) do
    ns.SpellData[baseID] = data
end
