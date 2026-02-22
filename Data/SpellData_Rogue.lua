-------------------------------------------------------------------------------
-- SpellData_Rogue.lua
-- Rogue spell definitions for TBC Anniversary (2.5.5)
-- Base values, coefficients, and per-rank data sourced from Wowhead TBC Classic
--
-- NOTE: The engine currently supports spell-power-based computation only.
-- Rogue melee abilities use forward-compatible fields (scalingType, weaponDamage,
-- weaponMultiplier, apCoefficient) that the engine will consume once melee
-- combat support is implemented. Until then these entries serve as a complete
-- data reference and will be picked up automatically when the engine is extended.
--
-- Combo-point finishers are pre-computed at 5 combo points.
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-- Local references to constants
local SCHOOL_PHYSICAL = ns.SCHOOL_PHYSICAL
local SCHOOL_NATURE = ns.SCHOOL_NATURE

local SpellData = {}

-------------------------------------------------------------------------------
-- Melee Weapon Abilities
-------------------------------------------------------------------------------

-- Sinister Strike -- instant, weapon + flat bonus, 45 Energy
-- Normalized weapon speed: 2.4 (one-hand) for AP contribution
SpellData[1752] = {
    name = "Sinister Strike",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    ranks = {
        [1]  = { spellID = 1752,  minDmg = 3,  maxDmg = 3,  level = 1  },
        [2]  = { spellID = 1757,  minDmg = 6,  maxDmg = 6,  level = 6  },
        [3]  = { spellID = 1758,  minDmg = 10, maxDmg = 10, level = 14 },
        [4]  = { spellID = 1759,  minDmg = 15, maxDmg = 15, level = 22 },
        [5]  = { spellID = 1760,  minDmg = 22, maxDmg = 22, level = 30 },
        [6]  = { spellID = 8621,  minDmg = 33, maxDmg = 33, level = 38 },
        [7]  = { spellID = 11293, minDmg = 52, maxDmg = 52, level = 46 },
        [8]  = { spellID = 11294, minDmg = 68, maxDmg = 68, level = 54 },
        [9]  = { spellID = 26861, minDmg = 80, maxDmg = 80, level = 62 },
        [10] = { spellID = 26862, minDmg = 98, maxDmg = 98, level = 70 },
    },
}

-- Backstab -- instant, 150% weapon + flat bonus, 60 Energy, requires dagger MH
SpellData[53] = {
    name = "Backstab",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = true,
    weaponMultiplier = 1.5,
    requiresWeapon = "dagger",
    ranks = {
        [1]  = { spellID = 53,    minDmg = 15,  maxDmg = 15,  level = 4  },
        [2]  = { spellID = 2589,  minDmg = 30,  maxDmg = 30,  level = 12 },
        [3]  = { spellID = 2590,  minDmg = 48,  maxDmg = 48,  level = 20 },
        [4]  = { spellID = 2591,  minDmg = 69,  maxDmg = 69,  level = 28 },
        [5]  = { spellID = 8721,  minDmg = 90,  maxDmg = 90,  level = 36 },
        [6]  = { spellID = 11279, minDmg = 135, maxDmg = 135, level = 44 },
        [7]  = { spellID = 11280, minDmg = 165, maxDmg = 165, level = 52 },
        [8]  = { spellID = 11281, minDmg = 210, maxDmg = 210, level = 60 },
        [9]  = { spellID = 25300, minDmg = 225, maxDmg = 225, level = 60 },
        [10] = { spellID = 26863, minDmg = 255, maxDmg = 255, level = 68 },
    },
}

-- Ambush -- instant, 275% weapon + flat bonus, 60 Energy, requires stealth + dagger MH
SpellData[8676] = {
    name = "Ambush",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = true,
    weaponMultiplier = 2.75,
    requiresWeapon = "dagger",
    requiresStealth = true,
    ranks = {
        [1] = { spellID = 8676,  minDmg = 70,  maxDmg = 70,  level = 18 },
        [2] = { spellID = 8724,  minDmg = 100, maxDmg = 100, level = 26 },
        [3] = { spellID = 8725,  minDmg = 125, maxDmg = 125, level = 34 },
        [4] = { spellID = 11267, minDmg = 185, maxDmg = 185, level = 42 },
        [5] = { spellID = 11268, minDmg = 230, maxDmg = 230, level = 50 },
        [6] = { spellID = 11269, minDmg = 290, maxDmg = 290, level = 58 },
        [7] = { spellID = 27441, minDmg = 335, maxDmg = 335, level = 66 },
    },
}

-- Hemorrhage -- instant, 110% weapon, 35 Energy (Subtlety talent)
-- Also applies a debuff increasing physical damage taken by target (separate mechanic)
SpellData[16511] = {
    name = "Hemorrhage",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = true,
    weaponMultiplier = 1.1,
    ranks = {
        [1] = { spellID = 16511, minDmg = 0, maxDmg = 0, level = 30 },
        [2] = { spellID = 17347, minDmg = 0, maxDmg = 0, level = 46 },
        [3] = { spellID = 17348, minDmg = 0, maxDmg = 0, level = 58 },
        [4] = { spellID = 26864, minDmg = 0, maxDmg = 0, level = 70 },
    },
}

-- Ghostly Strike -- instant, 125% weapon, 40 Energy, 20s CD (Subtlety talent)
SpellData[14278] = {
    name = "Ghostly Strike",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = true,
    weaponMultiplier = 1.25,
    ranks = {
        [1] = { spellID = 14278, minDmg = 0, maxDmg = 0, level = 20 },
    },
}

-- Mutilate -- instant, both weapons + flat bonus per hand, 60 Energy
-- Hits with MH and OH simultaneously, each dealing weapon + flat bonus damage
-- +50% damage vs poisoned targets (handled by engine/AuraMap when implemented)
-- Awards 2 combo points
SpellData[1329] = {
    name = "Mutilate",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    dualWieldStrike = true,
    requiresWeapon = "dagger",
    ranks = {
        [1] = { spellID = 1329,  minDmg = 44,  maxDmg = 44,  level = 40 },
        [2] = { spellID = 34411, minDmg = 63,  maxDmg = 63,  level = 50 },
        [3] = { spellID = 34412, minDmg = 88,  maxDmg = 88,  level = 60 },
        [4] = { spellID = 34413, minDmg = 101, maxDmg = 101, level = 70 },
    },
}

-- Shiv -- instant, OH weapon attack, 20+ Energy (scales with weapon speed)
-- Applies OH poison, awards 1 CP. Pure OH weapon damage, no flat bonus.
SpellData[5938] = {
    name = "Shiv",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    offHandOnly = true,
    ranks = {
        [1] = { spellID = 5938, minDmg = 0, maxDmg = 0, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- Non-Weapon Melee Abilities (flat damage only, no weapon component)
-------------------------------------------------------------------------------

-- Gouge -- instant, flat damage only, 45 Energy
-- Incapacitates target (breaks on damage), awards 1 CP
SpellData[1776] = {
    name = "Gouge",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = false,
    ranks = {
        [1] = { spellID = 1776,  minDmg = 10,  maxDmg = 10,  level = 6  },
        [2] = { spellID = 1777,  minDmg = 20,  maxDmg = 20,  level = 18 },
        [3] = { spellID = 8629,  minDmg = 32,  maxDmg = 32,  level = 32 },
        [4] = { spellID = 11285, minDmg = 55,  maxDmg = 55,  level = 46 },
        [5] = { spellID = 11286, minDmg = 75,  maxDmg = 75,  level = 60 },
        [6] = { spellID = 38764, minDmg = 105, maxDmg = 105, level = 67 },
    },
}

-------------------------------------------------------------------------------
-- Finishing Moves (pre-computed at 5 combo points)
-------------------------------------------------------------------------------

-- Eviscerate -- instant, finishing move, 35 Energy
-- Pre-computed at 5 combo points: minDmg = baseMin + 5 * perCPBonus
-- AP coefficient: 0.03 per combo point (5 CP = 0.15 total)
SpellData[2098] = {
    name = "Eviscerate",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = false,
    apCoefficient = 0.15,
    ranks = {
        [1]  = { spellID = 2098,  minDmg = 95,   maxDmg = 105,  level = 1  },
        [2]  = { spellID = 6760,  minDmg = 140,  maxDmg = 150,  level = 8  },
        [3]  = { spellID = 6761,  minDmg = 205,  maxDmg = 220,  level = 16 },
        [4]  = { spellID = 6762,  minDmg = 255,  maxDmg = 275,  level = 24 },
        [5]  = { spellID = 8623,  minDmg = 320,  maxDmg = 350,  level = 32 },
        [6]  = { spellID = 8624,  minDmg = 410,  maxDmg = 440,  level = 40 },
        [7]  = { spellID = 11299, minDmg = 510,  maxDmg = 550,  level = 48 },
        [8]  = { spellID = 11300, minDmg = 635,  maxDmg = 690,  level = 56 },
        [9]  = { spellID = 31016, minDmg = 795,  maxDmg = 885,  level = 60 },
        [10] = { spellID = 26865, minDmg = 985,  maxDmg = 1105, level = 64 },
    },
}

-- Rupture -- instant, finishing move DoT, 25 Energy
-- Pre-computed at 5 combo points: 16 sec duration, 8 ticks
-- AP coefficient at 5 CP: 0.24
SpellData[1943] = {
    name = "Rupture",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    isAoe = false,
    spellType = "dot",
    weaponDamage = false,
    apCoefficient = 0.24,
    duration = 16,
    numTicks = 8,
    ranks = {
        [1] = { spellID = 1943,  totalDmg = 144,  level = 20 },
        [2] = { spellID = 8639,  totalDmg = 216,  level = 28 },
        [3] = { spellID = 8640,  totalDmg = 304,  level = 36 },
        [4] = { spellID = 11273, totalDmg = 416,  level = 44 },
        [5] = { spellID = 11274, totalDmg = 576,  level = 52 },
        [6] = { spellID = 11275, totalDmg = 800,  level = 60 },
        [7] = { spellID = 26867, totalDmg = 1000, level = 68 },
    },
}

-- Envenom -- instant, finishing move, Nature school, 35 Energy
-- Pre-computed at 5 combo points (5 Deadly Poison doses consumed)
-- AP coefficient: 0.03 per dose (5 doses = 0.15 total)
SpellData[32645] = {
    name = "Envenom",
    school = SCHOOL_NATURE,
    scalingType = "melee",
    castTime = 0,
    canCrit = false,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = false,
    apCoefficient = 0.15,
    ranks = {
        [1] = { spellID = 32645, minDmg = 650, maxDmg = 650, level = 62 },
        [2] = { spellID = 32684, minDmg = 900, maxDmg = 900, level = 69 },
    },
}

-- Deadly Throw -- instant, finishing move, ranged, 35 Energy
-- Pre-computed at 5 combo points: uses thrown weapon + flat bonus
SpellData[26679] = {
    name = "Deadly Throw",
    school = SCHOOL_PHYSICAL,
    scalingType = "ranged",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    ranks = {
        [1] = { spellID = 26679, minDmg = 584, maxDmg = 600, level = 64 },
    },
}

-------------------------------------------------------------------------------
-- DoT Abilities (non-finishing-move)
-------------------------------------------------------------------------------

-- Garrote -- instant, stealth opener DoT, 50 Energy, 18s duration (6 ticks)
-- AP coefficient: 0.18 total (0.03 per tick x 6 ticks)
SpellData[703] = {
    name = "Garrote",
    school = SCHOOL_PHYSICAL,
    scalingType = "melee",
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    isAoe = false,
    spellType = "dot",
    weaponDamage = false,
    requiresStealth = true,
    apCoefficient = 0.18,
    duration = 18,
    numTicks = 6,
    ranks = {
        [1] = { spellID = 703,   totalDmg = 144, level = 14 },
        [2] = { spellID = 8631,  totalDmg = 204, level = 22 },
        [3] = { spellID = 8632,  totalDmg = 282, level = 30 },
        [4] = { spellID = 8633,  totalDmg = 354, level = 38 },
        [5] = { spellID = 11289, totalDmg = 444, level = 46 },
        [6] = { spellID = 11290, totalDmg = 552, level = 54 },
        [7] = { spellID = 26839, totalDmg = 666, level = 61 },
        [8] = { spellID = 26884, totalDmg = 810, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- Poison Procs (Nature school)
-- These are proc effects applied via weapon coatings.
-- SpellIDs here are the "coating" buff IDs (what the player applies).
-- Proc chance and application are handled by the WoW combat system.
-------------------------------------------------------------------------------

-- Instant Poison -- 20% proc, instant Nature damage per hit
SpellData[8679] = {
    name = "Instant Poison",
    school = SCHOOL_NATURE,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = false,
    isPoisonProc = true,
    procChance = 0.20,
    ranks = {
        [1] = { spellID = 8679,  minDmg = 19,  maxDmg = 25,  level = 20 },
        [2] = { spellID = 8686,  minDmg = 30,  maxDmg = 38,  level = 28 },
        [3] = { spellID = 8688,  minDmg = 44,  maxDmg = 56,  level = 36 },
        [4] = { spellID = 11338, minDmg = 67,  maxDmg = 85,  level = 44 },
        [5] = { spellID = 11339, minDmg = 92,  maxDmg = 118, level = 52 },
        [6] = { spellID = 11340, minDmg = 112, maxDmg = 148, level = 60 },
        [7] = { spellID = 26891, minDmg = 146, maxDmg = 194, level = 68 },
    },
}

-- Deadly Poison -- 30% proc, Nature DoT over 12 sec, stacks up to 5
SpellData[2823] = {
    name = "Deadly Poison",
    school = SCHOOL_NATURE,
    scalingType = "melee",
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    isAoe = false,
    spellType = "dot",
    weaponDamage = false,
    isPoisonProc = true,
    procChance = 0.30,
    maxStacks = 5,
    duration = 12,
    numTicks = 4,
    ranks = {
        [1] = { spellID = 2823,  totalDmg = 36,  level = 30 },
        [2] = { spellID = 2824,  totalDmg = 52,  level = 38 },
        [3] = { spellID = 11355, totalDmg = 80,  level = 46 },
        [4] = { spellID = 11356, totalDmg = 108, level = 54 },
        [5] = { spellID = 25351, totalDmg = 136, level = 60 },
        [6] = { spellID = 26967, totalDmg = 144, level = 62 },
        [7] = { spellID = 27186, totalDmg = 180, level = 70 },
    },
}

-- Wound Poison -- 30% proc, instant Nature damage + healing reduction debuff, stacks 5
SpellData[13219] = {
    name = "Wound Poison",
    school = SCHOOL_NATURE,
    scalingType = "melee",
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    weaponDamage = false,
    isPoisonProc = true,
    procChance = 0.30,
    maxStacks = 5,
    ranks = {
        [1] = { spellID = 13219, minDmg = 17, maxDmg = 17, level = 32 },
        [2] = { spellID = 13225, minDmg = 25, maxDmg = 25, level = 40 },
        [3] = { spellID = 13226, minDmg = 38, maxDmg = 38, level = 48 },
        [4] = { spellID = 13227, minDmg = 53, maxDmg = 53, level = 56 },
        [5] = { spellID = 27188, minDmg = 65, maxDmg = 65, level = 64 },
    },
}

-------------------------------------------------------------------------------
-- Merge into addon namespace
-------------------------------------------------------------------------------
for spellID, data in pairs(SpellData) do
    ns.SpellData[spellID] = data
end
