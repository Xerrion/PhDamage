-------------------------------------------------------------------------------
-- SpellData_Shaman
-- Shaman spell coefficients and rank data for TBC Anniversary
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.SpellData = ns.SpellData or {}

local SCHOOL_NATURE = ns.SCHOOL_NATURE
local SCHOOL_FIRE = ns.SCHOOL_FIRE
local SCHOOL_FROST = ns.SCHOOL_FROST

local SpellData = {}

-------------------------------------------------------------------------------
-- Nature Damage Spells
-------------------------------------------------------------------------------

-- Lightning Bolt — 2.5s cast, Nature, direct
-- Coefficient: 0.794
SpellData[403] = {
    name = "Lightning Bolt",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 0.794,
    castTime = 2.5,
    canCrit = true,
    ranks = {
        [1]  = { spellID = 403,   minDmg = 15,  maxDmg = 17,  level = 1  },
        [2]  = { spellID = 529,   minDmg = 28,  maxDmg = 33,  level = 8  },
        [3]  = { spellID = 548,   minDmg = 48,  maxDmg = 57,  level = 14 },
        [4]  = { spellID = 915,   minDmg = 88,  maxDmg = 100, level = 20 },
        [5]  = { spellID = 943,   minDmg = 131, maxDmg = 149, level = 26 },
        [6]  = { spellID = 6041,  minDmg = 179, maxDmg = 202, level = 32 },
        [7]  = { spellID = 10391, minDmg = 235, maxDmg = 264, level = 38 },
        [8]  = { spellID = 10392, minDmg = 291, maxDmg = 326, level = 44 },
        [9]  = { spellID = 15207, minDmg = 357, maxDmg = 400, level = 50 },
        [10] = { spellID = 15208, minDmg = 431, maxDmg = 479, level = 56 },
        [11] = { spellID = 25448, minDmg = 505, maxDmg = 576, level = 62 },
        [12] = { spellID = 25449, minDmg = 571, maxDmg = 652, level = 67 },
    },
}

-- Chain Lightning — 2.0s cast, Nature, direct
-- Coefficient: 0.651
SpellData[421] = {
    name = "Chain Lightning",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 0.651,
    castTime = 2.0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 421,   minDmg = 200, maxDmg = 227, level = 32 },
        [2] = { spellID = 930,   minDmg = 288, maxDmg = 323, level = 40 },
        [3] = { spellID = 2860,  minDmg = 391, maxDmg = 438, level = 48 },
        [4] = { spellID = 10605, minDmg = 508, maxDmg = 567, level = 56 },
        [5] = { spellID = 25439, minDmg = 620, maxDmg = 705, level = 63 },
        [6] = { spellID = 25442, minDmg = 734, maxDmg = 838, level = 70 },
    },
}

-- Earth Shock — instant cast, Nature, direct
-- Coefficient: 0.386
SpellData[8042] = {
    name = "Earth Shock",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 0.386,
    castTime = 1.5,
    canCrit = true,
    ranks = {
        [1] = { spellID = 8042,  minDmg = 19,  maxDmg = 22,  level = 4  },
        [2] = { spellID = 8044,  minDmg = 35,  maxDmg = 38,  level = 8  },
        [3] = { spellID = 8045,  minDmg = 65,  maxDmg = 69,  level = 14 },
        [4] = { spellID = 8046,  minDmg = 126, maxDmg = 134, level = 24 },
        [5] = { spellID = 10412, minDmg = 235, maxDmg = 249, level = 36 },
        [6] = { spellID = 10413, minDmg = 372, maxDmg = 394, level = 48 },
        [7] = { spellID = 10414, minDmg = 532, maxDmg = 561, level = 60 },
        [8] = { spellID = 25454, minDmg = 658, maxDmg = 692, level = 69 },
    },
}

-- Lightning Shield — utility, Nature
-- Coefficient: 0.33
SpellData[324] = {
    name = "Lightning Shield",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 0.33,
    castTime = 0,
    canCrit = false,
    ranks = {
        [1] = { spellID = 324,   minDmg = 13,  maxDmg = 13,  level = 8  },
        [2] = { spellID = 325,   minDmg = 29,  maxDmg = 29,  level = 16 },
        [3] = { spellID = 905,   minDmg = 51,  maxDmg = 51,  level = 24 },
        [4] = { spellID = 945,   minDmg = 80,  maxDmg = 80,  level = 32 },
        [5] = { spellID = 8134,  minDmg = 114, maxDmg = 114, level = 40 },
        [6] = { spellID = 10431, minDmg = 154, maxDmg = 154, level = 48 },
        [7] = { spellID = 10432, minDmg = 198, maxDmg = 198, level = 56 },
        [8] = { spellID = 25469, minDmg = 232, maxDmg = 232, level = 63 },
        [9] = { spellID = 25472, minDmg = 287, maxDmg = 287, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- Fire Spells
-------------------------------------------------------------------------------

-- Flame Shock — instant cast, Fire, hybrid (direct + DoT)
-- Direct coefficient: 0.214, DoT coefficient: 0.1
-- DoT: 12s duration, 4 ticks
SpellData[8050] = {
    name = "Flame Shock",
    school = SCHOOL_FIRE,
    spellType = "hybrid",
    directCoefficient = 0.214,
    dotCoefficient = 0.1,
    duration = 12,
    numTicks = 4,
    castTime = 1.5,
    canCrit = true,
    ranks = {
        [1] = { spellID = 8050,  minDmg = 25,  maxDmg = 25,  dotDmg = 28,  level = 10 },
        [2] = { spellID = 8052,  minDmg = 51,  maxDmg = 51,  dotDmg = 48,  level = 18 },
        [3] = { spellID = 8053,  minDmg = 95,  maxDmg = 95,  dotDmg = 96,  level = 28 },
        [4] = { spellID = 10447, minDmg = 164, maxDmg = 164, dotDmg = 168, level = 40 },
        [5] = { spellID = 10448, minDmg = 245, maxDmg = 245, dotDmg = 256, level = 52 },
        [6] = { spellID = 29228, minDmg = 334, maxDmg = 334, dotDmg = 344, level = 60 },
        [7] = { spellID = 25457, minDmg = 377, maxDmg = 377, dotDmg = 420, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- Frost Spells
-------------------------------------------------------------------------------

-- Frost Shock — instant cast, Frost, direct
-- Coefficient: 0.386
SpellData[8056] = {
    name = "Frost Shock",
    school = SCHOOL_FROST,
    spellType = "direct",
    coefficient = 0.386,
    castTime = 1.5,
    canCrit = true,
    ranks = {
        [1] = { spellID = 8056,  minDmg = 95,  maxDmg = 101, level = 20 },
        [2] = { spellID = 8058,  minDmg = 215, maxDmg = 230, level = 34 },
        [3] = { spellID = 10472, minDmg = 345, maxDmg = 366, level = 46 },
        [4] = { spellID = 10473, minDmg = 501, maxDmg = 529, level = 58 },
        [5] = { spellID = 25464, minDmg = 647, maxDmg = 683, level = 68 },
    },
}

-------------------------------------------------------------------------------
-- Healing Spells
-------------------------------------------------------------------------------

-- Healing Wave — 3.0s cast, Nature, direct heal
-- Coefficient: 0.857
SpellData[331] = {
    name = "Healing Wave",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 0.857,
    castTime = 3.0,
    canCrit = true,
    isHeal = true,
    ranks = {
        [1]  = { spellID = 331,   minDmg = 36,   maxDmg = 47,   level = 1  },
        [2]  = { spellID = 332,   minDmg = 69,   maxDmg = 83,   level = 6  },
        [3]  = { spellID = 547,   minDmg = 136,  maxDmg = 163,  level = 12 },
        [4]  = { spellID = 913,   minDmg = 279,  maxDmg = 328,  level = 18 },
        [5]  = { spellID = 939,   minDmg = 389,  maxDmg = 454,  level = 24 },
        [6]  = { spellID = 959,   minDmg = 552,  maxDmg = 639,  level = 32 },
        [7]  = { spellID = 8005,  minDmg = 759,  maxDmg = 874,  level = 40 },
        [8]  = { spellID = 10395, minDmg = 1040, maxDmg = 1191, level = 48 },
        [9]  = { spellID = 10396, minDmg = 1394, maxDmg = 1589, level = 56 },
        [10] = { spellID = 25357, minDmg = 1647, maxDmg = 1878, level = 60 },
        [11] = { spellID = 25391, minDmg = 1756, maxDmg = 2001, level = 63 },
        [12] = { spellID = 25396, minDmg = 2134, maxDmg = 2436, level = 70 },
    },
}

-- Lesser Healing Wave — 1.5s cast, Nature, direct heal
-- Coefficient: 0.429
SpellData[8004] = {
    name = "Lesser Healing Wave",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 1.5,
    canCrit = true,
    isHeal = true,
    ranks = {
        [1] = { spellID = 8004,  minDmg = 170,  maxDmg = 195,  level = 20 },
        [2] = { spellID = 8008,  minDmg = 257,  maxDmg = 292,  level = 28 },
        [3] = { spellID = 8010,  minDmg = 349,  maxDmg = 394,  level = 36 },
        [4] = { spellID = 10466, minDmg = 473,  maxDmg = 529,  level = 44 },
        [5] = { spellID = 10467, minDmg = 649,  maxDmg = 723,  level = 52 },
        [6] = { spellID = 10468, minDmg = 853,  maxDmg = 949,  level = 60 },
        [7] = { spellID = 25420, minDmg = 1051, maxDmg = 1198, level = 66 },
    },
}

-- Chain Heal — 2.5s cast, Nature, direct heal
-- Coefficient: 0.714
SpellData[1064] = {
    name = "Chain Heal",
    school = SCHOOL_NATURE,
    spellType = "direct",
    coefficient = 0.714,
    castTime = 2.5,
    canCrit = true,
    isHeal = true,
    ranks = {
        [1] = { spellID = 1064,  minDmg = 332, maxDmg = 381, level = 40 },
        [2] = { spellID = 10622, minDmg = 419, maxDmg = 479, level = 46 },
        [3] = { spellID = 10623, minDmg = 567, maxDmg = 646, level = 54 },
        [4] = { spellID = 25422, minDmg = 624, maxDmg = 710, level = 61 },
        [5] = { spellID = 25423, minDmg = 833, maxDmg = 950, level = 68 },
    },
}

-- Merge into addon namespace
for baseID, data in pairs(SpellData) do
    ns.SpellData[baseID] = data
end
