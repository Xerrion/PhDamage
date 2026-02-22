-------------------------------------------------------------------------------
-- SpellData_Mage
-- Mage spell definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.SpellData = ns.SpellData or {}

local SCHOOL_FIRE = 4
local SCHOOL_FROST = 16
local SCHOOL_ARCANE = 64

local SpellData = {}

-------------------------------------------------------------------------------
-- Fire Spells
-------------------------------------------------------------------------------

-- Fireball — 3.5s cast, Fire, hybrid (direct + DoT)
-- Direct coefficient: 1.0, DoT coefficient: 0.0 (DoT does NOT scale with SP in TBC)
-- DoT: 8s duration, 4 ticks
SpellData[133] = {
    name = "Fireball",
    school = SCHOOL_FIRE,
    spellType = "hybrid",
    directCoefficient = 1.0,
    dotCoefficient = 0.0,
    dotDuration = 8,
    dotTicks = 4,
    castTime = 3.5,
    canCrit = true,
    ranks = {
        [1]  = { spellID = 133,   minDmg = 16,  maxDmg = 25,  dotDmg = 2,   level = 1  },
        [2]  = { spellID = 143,   minDmg = 34,  maxDmg = 49,  dotDmg = 3,   level = 6  },
        [3]  = { spellID = 145,   minDmg = 57,  maxDmg = 77,  dotDmg = 6,   level = 12 },
        [4]  = { spellID = 3140,  minDmg = 89,  maxDmg = 122, dotDmg = 12,  level = 18 },
        [5]  = { spellID = 8400,  minDmg = 146, maxDmg = 195, dotDmg = 20,  level = 24 },
        [6]  = { spellID = 8401,  minDmg = 207, maxDmg = 274, dotDmg = 28,  level = 30 },
        [7]  = { spellID = 8402,  minDmg = 264, maxDmg = 345, dotDmg = 32,  level = 36 },
        [8]  = { spellID = 10148, minDmg = 328, maxDmg = 425, dotDmg = 40,  level = 42 },
        [9]  = { spellID = 10149, minDmg = 404, maxDmg = 518, dotDmg = 52,  level = 48 },
        [10] = { spellID = 10150, minDmg = 488, maxDmg = 623, dotDmg = 60,  level = 54 },
        [11] = { spellID = 10151, minDmg = 575, maxDmg = 730, dotDmg = 72,  level = 60 },
        [12] = { spellID = 25306, minDmg = 611, maxDmg = 776, dotDmg = 76,  level = 63 },
        [13] = { spellID = 27070, minDmg = 649, maxDmg = 821, dotDmg = 84,  level = 67 },
        [14] = { spellID = 38692, minDmg = 717, maxDmg = 913, dotDmg = 84,  level = 69 },
    },
}

-- Fire Blast — instant cast, Fire, direct
-- Coefficient: 0.429
SpellData[2136] = {
    name = "Fire Blast",
    school = SCHOOL_FIRE,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 2136,  minDmg = 27,  maxDmg = 35,  level = 6  },
        [2] = { spellID = 2137,  minDmg = 62,  maxDmg = 76,  level = 14 },
        [3] = { spellID = 2138,  minDmg = 110, maxDmg = 134, level = 22 },
        [4] = { spellID = 8412,  minDmg = 177, maxDmg = 211, level = 30 },
        [5] = { spellID = 8413,  minDmg = 253, maxDmg = 301, level = 38 },
        [6] = { spellID = 10197, minDmg = 345, maxDmg = 407, level = 46 },
        [7] = { spellID = 10199, minDmg = 446, maxDmg = 524, level = 54 },
        [8] = { spellID = 27078, minDmg = 555, maxDmg = 654, level = 63 },
        [9] = { spellID = 27079, minDmg = 664, maxDmg = 786, level = 70 },
    },
}

-- Scorch — 1.5s cast, Fire, direct
-- Coefficient: 0.429
SpellData[2948] = {
    name = "Scorch",
    school = SCHOOL_FIRE,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 1.5,
    canCrit = true,
    ranks = {
        [1] = { spellID = 2948,  minDmg = 56,  maxDmg = 69,  level = 22 },
        [2] = { spellID = 8444,  minDmg = 81,  maxDmg = 98,  level = 28 },
        [3] = { spellID = 8445,  minDmg = 105, maxDmg = 126, level = 34 },
        [4] = { spellID = 8446,  minDmg = 139, maxDmg = 165, level = 40 },
        [5] = { spellID = 10205, minDmg = 168, maxDmg = 199, level = 46 },
        [6] = { spellID = 10206, minDmg = 207, maxDmg = 247, level = 52 },
        [7] = { spellID = 10207, minDmg = 241, maxDmg = 284, level = 58 },
        [8] = { spellID = 27073, minDmg = 278, maxDmg = 327, level = 63 },
        [9] = { spellID = 27074, minDmg = 305, maxDmg = 361, level = 70 },
    },
}

-- Pyroblast — 6.0s cast, Fire, hybrid (direct + DoT)
-- Direct coefficient: 1.15, DoT coefficient: 0.05 per tick × 4 ticks = 0.20 total
-- DoT: 12s duration, 4 ticks
SpellData[11366] = {
    name = "Pyroblast",
    school = SCHOOL_FIRE,
    spellType = "hybrid",
    directCoefficient = 1.15,
    dotCoefficient = 0.20,
    dotDuration = 12,
    dotTicks = 4,
    castTime = 6.0,
    canCrit = true,
    ranks = {
        [1]  = { spellID = 11366, minDmg = 148, maxDmg = 195,  dotDmg = 56,  level = 20 },
        [2]  = { spellID = 12505, minDmg = 193, maxDmg = 250,  dotDmg = 72,  level = 24 },
        [3]  = { spellID = 12522, minDmg = 270, maxDmg = 343,  dotDmg = 96,  level = 30 },
        [4]  = { spellID = 12523, minDmg = 347, maxDmg = 437,  dotDmg = 124, level = 36 },
        [5]  = { spellID = 12524, minDmg = 427, maxDmg = 536,  dotDmg = 156, level = 42 },
        [6]  = { spellID = 12525, minDmg = 525, maxDmg = 654,  dotDmg = 188, level = 48 },
        [7]  = { spellID = 12526, minDmg = 625, maxDmg = 776,  dotDmg = 228, level = 54 },
        [8]  = { spellID = 18809, minDmg = 735, maxDmg = 926,  dotDmg = 268, level = 60 },
        [9]  = { spellID = 27132, minDmg = 866, maxDmg = 1094, dotDmg = 312, level = 64 },
        [10] = { spellID = 33938, minDmg = 939, maxDmg = 1191, dotDmg = 356, level = 70 },
    },
}

-- Flamestrike — 3.0s cast, Fire, hybrid (direct + DoT)
-- Direct coefficient: 0.236, DoT coefficient: 0.03 per tick × 4 ticks = 0.12 total
-- DoT: 8s duration, 4 ticks
SpellData[2120] = {
    name = "Flamestrike",
    school = SCHOOL_FIRE,
    spellType = "hybrid",
    directCoefficient = 0.236,
    dotCoefficient = 0.12,
    dotDuration = 8,
    dotTicks = 4,
    castTime = 3.0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 2120,  minDmg = 55,  maxDmg = 71,  dotDmg = 48,  level = 16 },
        [2] = { spellID = 2121,  minDmg = 100, maxDmg = 126, dotDmg = 88,  level = 24 },
        [3] = { spellID = 8422,  minDmg = 159, maxDmg = 197, dotDmg = 140, level = 32 },
        [4] = { spellID = 8423,  minDmg = 226, maxDmg = 279, dotDmg = 196, level = 40 },
        [5] = { spellID = 10215, minDmg = 298, maxDmg = 367, dotDmg = 264, level = 48 },
        [6] = { spellID = 10216, minDmg = 383, maxDmg = 468, dotDmg = 340, level = 56 },
        [7] = { spellID = 27086, minDmg = 480, maxDmg = 585, dotDmg = 424, level = 65 },
    },
}

-- Blast Wave — instant cast, Fire, direct (talent)
-- Coefficient: 0.193
SpellData[11113] = {
    name = "Blast Wave",
    school = SCHOOL_FIRE,
    spellType = "direct",
    coefficient = 0.193,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 11113, minDmg = 160, maxDmg = 192, level = 30 },
        [2] = { spellID = 13018, minDmg = 208, maxDmg = 249, level = 36 },
        [3] = { spellID = 13019, minDmg = 285, maxDmg = 338, level = 44 },
        [4] = { spellID = 13020, minDmg = 374, maxDmg = 443, level = 52 },
        [5] = { spellID = 13021, minDmg = 473, maxDmg = 556, level = 60 },
        [6] = { spellID = 27133, minDmg = 543, maxDmg = 638, level = 65 },
        [7] = { spellID = 33933, minDmg = 616, maxDmg = 724, level = 70 },
    },
}

-- Dragon's Breath — instant cast, Fire, direct (talent)
-- Coefficient: 0.193
SpellData[31661] = {
    name = "Dragon's Breath",
    school = SCHOOL_FIRE,
    spellType = "direct",
    coefficient = 0.193,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 31661, minDmg = 382, maxDmg = 442, level = 62 },
        [2] = { spellID = 33041, minDmg = 463, maxDmg = 536, level = 64 },
        [3] = { spellID = 33042, minDmg = 584, maxDmg = 677, level = 68 },
        [4] = { spellID = 33043, minDmg = 680, maxDmg = 790, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- Frost Spells
-------------------------------------------------------------------------------

-- Frostbolt — 3.0s cast, Frost, direct
-- Coefficient: 0.814
SpellData[116] = {
    name = "Frostbolt",
    school = SCHOOL_FROST,
    spellType = "direct",
    coefficient = 0.814,
    castTime = 3.0,
    canCrit = true,
    ranks = {
        [1]  = { spellID = 116,   minDmg = 20,  maxDmg = 22,  level = 4  },
        [2]  = { spellID = 205,   minDmg = 33,  maxDmg = 38,  level = 8  },
        [3]  = { spellID = 837,   minDmg = 54,  maxDmg = 61,  level = 14 },
        [4]  = { spellID = 7322,  minDmg = 78,  maxDmg = 87,  level = 20 },
        [5]  = { spellID = 8406,  minDmg = 132, maxDmg = 144, level = 26 },
        [6]  = { spellID = 8407,  minDmg = 180, maxDmg = 197, level = 32 },
        [7]  = { spellID = 8408,  minDmg = 235, maxDmg = 255, level = 38 },
        [8]  = { spellID = 10179, minDmg = 301, maxDmg = 326, level = 44 },
        [9]  = { spellID = 10180, minDmg = 363, maxDmg = 394, level = 50 },
        [10] = { spellID = 10181, minDmg = 440, maxDmg = 475, level = 56 },
        [11] = { spellID = 25304, minDmg = 527, maxDmg = 568, level = 60 },
        [12] = { spellID = 27071, minDmg = 548, maxDmg = 591, level = 62 },
        [13] = { spellID = 27072, minDmg = 600, maxDmg = 647, level = 66 },
        [14] = { spellID = 38697, minDmg = 630, maxDmg = 680, level = 69 },
    },
}

-- Ice Lance — instant cast, Frost, direct
-- Coefficient: 0.143
SpellData[30455] = {
    name = "Ice Lance",
    school = SCHOOL_FROST,
    spellType = "direct",
    coefficient = 0.143,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 30455, minDmg = 173, maxDmg = 200, level = 66 },
    },
}

-- Cone of Cold — instant cast, Frost, direct
-- Coefficient: 0.193
SpellData[120] = {
    name = "Cone of Cold",
    school = SCHOOL_FROST,
    spellType = "direct",
    coefficient = 0.193,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 120,   minDmg = 102, maxDmg = 112, level = 26 },
        [2] = { spellID = 8492,  minDmg = 151, maxDmg = 165, level = 34 },
        [3] = { spellID = 10159, minDmg = 209, maxDmg = 229, level = 42 },
        [4] = { spellID = 10160, minDmg = 270, maxDmg = 297, level = 50 },
        [5] = { spellID = 10161, minDmg = 342, maxDmg = 373, level = 58 },
        [6] = { spellID = 27087, minDmg = 418, maxDmg = 457, level = 65 },
    },
}

-- Blizzard — channeled, Frost, 8s duration, 8 ticks
-- Coefficient: 0.119 per tick = 0.952 total
SpellData[10] = {
    name = "Blizzard",
    school = SCHOOL_FROST,
    spellType = "channel",
    coefficient = 0.952,
    duration = 8,
    numTicks = 8,
    canCrit = false,
    ranks = {
        [1] = { spellID = 10,    totalDmg = 208,  level = 20 },
        [2] = { spellID = 6141,  totalDmg = 360,  level = 28 },
        [3] = { spellID = 8427,  totalDmg = 528,  level = 36 },
        [4] = { spellID = 10185, totalDmg = 736,  level = 44 },
        [5] = { spellID = 10186, totalDmg = 952,  level = 52 },
        [6] = { spellID = 10187, totalDmg = 1208, level = 60 },
        [7] = { spellID = 27085, totalDmg = 1480, level = 65 },
    },
}

-- Frost Nova — instant cast, Frost, direct
-- Coefficient: 0.043
SpellData[122] = {
    name = "Frost Nova",
    school = SCHOOL_FROST,
    spellType = "direct",
    coefficient = 0.043,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 122,   minDmg = 21,  maxDmg = 24,  level = 10 },
        [2] = { spellID = 865,   minDmg = 35,  maxDmg = 40,  level = 26 },
        [3] = { spellID = 6131,  minDmg = 54,  maxDmg = 61,  level = 40 },
        [4] = { spellID = 10230, minDmg = 73,  maxDmg = 82,  level = 54 },
        [5] = { spellID = 27088, minDmg = 100, maxDmg = 113, level = 65 },
    },
}

-------------------------------------------------------------------------------
-- Arcane Spells
-------------------------------------------------------------------------------

-- Arcane Missiles — channeled, Arcane
-- Coefficient: 0.143 per wave = 0.715 total
-- Note: R1 = 3 waves (3s), R2 = 4 waves (4s), R3+ = 5 waves (5s)
-- Base duration/numTicks set to R3+ values (5 waves)
SpellData[5143] = {
    name = "Arcane Missiles",
    school = SCHOOL_ARCANE,
    spellType = "channel",
    coefficient = 0.715,
    duration = 5,
    numTicks = 5,
    canCrit = true,
    ranks = {
        [1]  = { spellID = 5143,  totalDmg = 78,   level = 8  },  -- 3 waves x 26
        [2]  = { spellID = 5144,  totalDmg = 152,  level = 16 },  -- 4 waves x 38
        [3]  = { spellID = 5145,  totalDmg = 290,  level = 24 },  -- 5 waves x 58
        [4]  = { spellID = 8416,  totalDmg = 430,  level = 32 },  -- 5 waves x 86
        [5]  = { spellID = 8417,  totalDmg = 590,  level = 40 },  -- 5 waves x 118
        [6]  = { spellID = 10211, totalDmg = 775,  level = 48 },  -- 5 waves x 155
        [7]  = { spellID = 10212, totalDmg = 980,  level = 56 },  -- 5 waves x 196
        [8]  = { spellID = 25345, totalDmg = 1170, level = 60 },  -- 5 waves x 234
        [9]  = { spellID = 27075, totalDmg = 1225, level = 63 },  -- 5 waves x 245
        [10] = { spellID = 38699, totalDmg = 1325, level = 67 },  -- 5 waves x 265
        [11] = { spellID = 38704, totalDmg = 1430, level = 69 },  -- 5 waves x 286
    },
}

-- Arcane Blast — 2.5s cast, Arcane, direct
-- Coefficient: 0.714
SpellData[30451] = {
    name = "Arcane Blast",
    school = SCHOOL_ARCANE,
    spellType = "direct",
    coefficient = 0.714,
    castTime = 2.5,
    canCrit = true,
    ranks = {
        [1] = { spellID = 30451, minDmg = 668, maxDmg = 772, level = 64 },
    },
}

-- Arcane Explosion — instant cast, Arcane, direct
-- Coefficient: 0.213
SpellData[1449] = {
    name = "Arcane Explosion",
    school = SCHOOL_ARCANE,
    spellType = "direct",
    coefficient = 0.213,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 1449,  minDmg = 34,  maxDmg = 38,  level = 14 },
        [2] = { spellID = 8437,  minDmg = 60,  maxDmg = 66,  level = 22 },
        [3] = { spellID = 8438,  minDmg = 101, maxDmg = 110, level = 30 },
        [4] = { spellID = 8439,  minDmg = 143, maxDmg = 156, level = 38 },
        [5] = { spellID = 10201, minDmg = 191, maxDmg = 208, level = 46 },
        [6] = { spellID = 10202, minDmg = 249, maxDmg = 270, level = 54 },
        [7] = { spellID = 27080, minDmg = 313, maxDmg = 338, level = 63 },
        [8] = { spellID = 27082, minDmg = 377, maxDmg = 407, level = 69 },
    },
}

-- Merge into addon namespace
for baseID, data in pairs(SpellData) do
    ns.SpellData[baseID] = data
end
