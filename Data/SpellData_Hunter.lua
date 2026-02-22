local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Hunter Spell Data — TBC Anniversary (2.5.5)
-- Source of truth: Wowhead TBC Classic
-------------------------------------------------------------------------------

local SCHOOL_PHYSICAL = ns.SCHOOL_PHYSICAL
local SCHOOL_ARCANE   = ns.SCHOOL_ARCANE
local SCHOOL_NATURE   = ns.SCHOOL_NATURE
local SCHOOL_FIRE     = ns.SCHOOL_FIRE

local SpellData = {}

-------------------------------------------------------------------------------
-- DIRECT SHOTS
-------------------------------------------------------------------------------

-- Arcane Shot (instant, Arcane, 15% RAP coefficient, ignores armor via school)
SpellData[3044] = {
    name = "Arcane Shot",
    school = SCHOOL_ARCANE,
    coefficient = 0.15,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "ranged",
    ranks = {
        [1]  = { spellID = 3044,  minDmg = 13,  maxDmg = 13,  level = 6 },
        [2]  = { spellID = 14281, minDmg = 21,  maxDmg = 21,  level = 12 },
        [3]  = { spellID = 14282, minDmg = 33,  maxDmg = 33,  level = 20 },
        [4]  = { spellID = 14283, minDmg = 59,  maxDmg = 59,  level = 28 },
        [5]  = { spellID = 14284, minDmg = 83,  maxDmg = 83,  level = 36 },
        [6]  = { spellID = 14285, minDmg = 115, maxDmg = 115, level = 44 },
        [7]  = { spellID = 14286, minDmg = 145, maxDmg = 145, level = 52 },
        [8]  = { spellID = 14287, minDmg = 183, maxDmg = 183, level = 60 },
        [9]  = { spellID = 27019, minDmg = 273, maxDmg = 273, level = 70 },
    },
}

-- Steady Shot (1.5s cast, Physical, 20% RAP + weapon damage)
-- TBC formula: 150 + avgWeaponDmg + 0.2 * RAP
SpellData[34120] = {
    name = "Steady Shot",
    school = SCHOOL_PHYSICAL,
    coefficient = 0.20,
    castTime = 1.5,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "ranged",
    weaponDamage = true,
    ranks = {
        [1] = { spellID = 34120, minDmg = 150, maxDmg = 150, level = 62 },
    },
}

-- Multi-Shot (0.5s cast, Physical, 20% RAP, 3 targets)
SpellData[2643] = {
    name = "Multi-Shot",
    school = SCHOOL_PHYSICAL,
    coefficient = 0.20,
    castTime = 0.5,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = true,
    spellType = "direct",
    scalingType = "ranged",
    ranks = {
        [1] = { spellID = 2643,  minDmg = 0,   maxDmg = 0,   level = 18 },
        [2] = { spellID = 14288, minDmg = 40,  maxDmg = 40,  level = 30 },
        [3] = { spellID = 14289, minDmg = 80,  maxDmg = 80,  level = 42 },
        [4] = { spellID = 14290, minDmg = 120, maxDmg = 120, level = 54 },
        [5] = { spellID = 25294, minDmg = 150, maxDmg = 150, level = 62 },
        [6] = { spellID = 27021, minDmg = 205, maxDmg = 205, level = 70 },
    },
}

-- Aimed Shot (3.0s cast, Physical, 20% RAP + weapon damage)
SpellData[19434] = {
    name = "Aimed Shot",
    school = SCHOOL_PHYSICAL,
    coefficient = 0.20,
    castTime = 3.0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "ranged",
    weaponDamage = true,
    ranks = {
        [1] = { spellID = 19434, minDmg = 70,  maxDmg = 70,  level = 20 },
        [2] = { spellID = 20900, minDmg = 125, maxDmg = 125, level = 28 },
        [3] = { spellID = 20901, minDmg = 200, maxDmg = 200, level = 36 },
        [4] = { spellID = 20902, minDmg = 330, maxDmg = 330, level = 44 },
        [5] = { spellID = 20903, minDmg = 370, maxDmg = 370, level = 52 },
        [6] = { spellID = 20904, minDmg = 460, maxDmg = 460, level = 60 },
        [7] = { spellID = 27065, minDmg = 600, maxDmg = 600, level = 70 },
    },
}

-- Silencing Shot (instant, Physical, 50% weapon damage)
SpellData[34490] = {
    name = "Silencing Shot",
    school = SCHOOL_PHYSICAL,
    coefficient = 0.00,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "ranged",
    weaponDamage = true,
    weaponMultiplier = 0.50,
    ranks = {
        [1] = { spellID = 34490, minDmg = 0, maxDmg = 0, level = 50 },
    },
}

-------------------------------------------------------------------------------
-- DOTS
-------------------------------------------------------------------------------

-- Serpent Sting (instant, Nature, 10% RAP total, 15s/5 ticks, no crit)
SpellData[1978] = {
    name = "Serpent Sting",
    school = SCHOOL_NATURE,
    coefficient = 0.10,
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    isAoe = false,
    spellType = "dot",
    scalingType = "ranged",
    duration = 15,
    numTicks = 5,
    ranks = {
        [1]  = { spellID = 1978,  totalDmg = 20,  level = 4 },
        [2]  = { spellID = 13549, totalDmg = 40,  level = 10 },
        [3]  = { spellID = 13550, totalDmg = 80,  level = 18 },
        [4]  = { spellID = 13551, totalDmg = 140, level = 26 },
        [5]  = { spellID = 13552, totalDmg = 210, level = 34 },
        [6]  = { spellID = 13553, totalDmg = 290, level = 42 },
        [7]  = { spellID = 13554, totalDmg = 385, level = 50 },
        [8]  = { spellID = 13555, totalDmg = 490, level = 58 },
        [9]  = { spellID = 25295, totalDmg = 660, level = 63 },
        [10] = { spellID = 27016, totalDmg = 990, level = 70 },
    },
}

-- Immolation Trap (instant, Fire, 10% RAP, 15s/5 ticks, no crit)
SpellData[13795] = {
    name = "Immolation Trap",
    school = SCHOOL_FIRE,
    coefficient = 0.10,
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    isAoe = false,
    spellType = "dot",
    scalingType = "ranged",
    duration = 15,
    numTicks = 5,
    ranks = {
        [1] = { spellID = 13795, totalDmg = 105, level = 16 },
        [2] = { spellID = 14302, totalDmg = 215, level = 26 },
        [3] = { spellID = 14303, totalDmg = 340, level = 36 },
        [4] = { spellID = 14304, totalDmg = 510, level = 46 },
        [5] = { spellID = 14305, totalDmg = 690, level = 56 },
        [6] = { spellID = 27023, totalDmg = 1230, level = 68 },
    },
}

-------------------------------------------------------------------------------
-- CHANNELS
-------------------------------------------------------------------------------

-- Volley (6s channel, Arcane, ~0.50 RAP total across 6 ticks, AoE, no crit)
SpellData[1510] = {
    name = "Volley",
    school = SCHOOL_ARCANE,
    coefficient = 0.50,
    castTime = 0,
    canCrit = false,
    isDot = false,
    isChanneled = true,
    isAoe = true,
    spellType = "channel",
    scalingType = "ranged",
    duration = 6,
    numTicks = 6,
    ranks = {
        [1] = { spellID = 1510,  totalDmg = 120, level = 40 },
        [2] = { spellID = 14294, totalDmg = 192, level = 50 },
        [3] = { spellID = 14295, totalDmg = 264, level = 58 },
        [4] = { spellID = 27022, totalDmg = 450, level = 69 },
    },
}

-------------------------------------------------------------------------------
-- HYBRID (Direct + DoT)
-------------------------------------------------------------------------------

-- Explosive Trap (Fire, instant, blast + 20s DoT, 10% RAP on DoT)
SpellData[13813] = {
    name = "Explosive Trap",
    school = SCHOOL_FIRE,
    coefficient = 0.10,
    directCoefficient = 0.00,
    dotCoefficient = 0.10,
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    isAoe = true,
    spellType = "hybrid",
    scalingType = "ranged",
    duration = 20,
    numTicks = 10,
    ranks = {
        [1] = { spellID = 13813, minDmg = 52,  maxDmg = 70,  dotDmg = 80,  level = 20 },
        [2] = { spellID = 14316, minDmg = 84,  maxDmg = 112, dotDmg = 160, level = 30 },
        [3] = { spellID = 14317, minDmg = 135, maxDmg = 167, dotDmg = 240, level = 40 },
        [4] = { spellID = 27025, minDmg = 256, maxDmg = 338, dotDmg = 520, level = 68 },
    },
}

-------------------------------------------------------------------------------
-- Merge into global SpellData table
-------------------------------------------------------------------------------
for spellID, data in pairs(SpellData) do
    ns.SpellData[spellID] = data
end
