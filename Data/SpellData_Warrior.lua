local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Warrior Spell Data — TBC Anniversary (2.5.5)
-- Source of truth: Wowhead TBC Classic
-------------------------------------------------------------------------------

local SCHOOL_PHYSICAL = ns.SCHOOL_PHYSICAL

local SpellData = {}

-------------------------------------------------------------------------------
-- DIRECT — WEAPON DAMAGE ABILITIES
-------------------------------------------------------------------------------

-- Mortal Strike (instant, Physical, weapon + flat bonus)
SpellData[12294] = {
    name = "Mortal Strike",
    school = SCHOOL_PHYSICAL,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    ranks = {
        [1] = { spellID = 12294, minDmg = 85,  maxDmg = 85,  level = 40 },
        [2] = { spellID = 21551, minDmg = 110, maxDmg = 110, level = 48 },
        [3] = { spellID = 21552, minDmg = 135, maxDmg = 135, level = 54 },
        [4] = { spellID = 21553, minDmg = 160, maxDmg = 160, level = 60 },
        [5] = { spellID = 25248, minDmg = 185, maxDmg = 185, level = 66 },
        [6] = { spellID = 30330, minDmg = 210, maxDmg = 210, level = 70 },
    },
}

-- Overpower (instant, Physical, weapon + flat bonus)
SpellData[7384] = {
    name = "Overpower",
    school = SCHOOL_PHYSICAL,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    ranks = {
        [1] = { spellID = 7384,  minDmg = 5,  maxDmg = 5,  level = 12 },
        [2] = { spellID = 7887,  minDmg = 15, maxDmg = 15, level = 28 },
        [3] = { spellID = 11584, minDmg = 25, maxDmg = 25, level = 44 },
        [4] = { spellID = 11585, minDmg = 35, maxDmg = 35, level = 60 },
    },
}

-- Slam (1.5s cast, Physical, weapon + flat bonus)
SpellData[1464] = {
    name = "Slam",
    school = SCHOOL_PHYSICAL,
    castTime = 1.5,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    ranks = {
        [1] = { spellID = 1464,  minDmg = 32,  maxDmg = 32,  level = 30 },
        [2] = { spellID = 8820,  minDmg = 43,  maxDmg = 43,  level = 38 },
        [3] = { spellID = 11604, minDmg = 68,  maxDmg = 68,  level = 46 },
        [4] = { spellID = 11605, minDmg = 87,  maxDmg = 87,  level = 54 },
        [5] = { spellID = 25241, minDmg = 105, maxDmg = 105, level = 61 },
        [6] = { spellID = 25242, minDmg = 140, maxDmg = 140, level = 69 },
    },
}

-- Whirlwind (instant, Physical, weapon damage, single rank)
SpellData[1680] = {
    name = "Whirlwind",
    school = SCHOOL_PHYSICAL,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = true,
    spellType = "direct",
    scalingType = "melee",
    weaponDamage = true,
    weaponMultiplier = 1.0,
    ranks = {
        [1] = { spellID = 1680, minDmg = 0, maxDmg = 0, level = 36 },
    },
}

-------------------------------------------------------------------------------
-- DIRECT — NON-WEAPON ABILITIES
-------------------------------------------------------------------------------

-- Thunder Clap (instant, Physical, flat damage only)
SpellData[6343] = {
    name = "Thunder Clap",
    school = SCHOOL_PHYSICAL,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = true,
    spellType = "direct",
    scalingType = "melee",
    ranks = {
        [1] = { spellID = 6343,  minDmg = 10,  maxDmg = 10,  level = 6 },
        [2] = { spellID = 8198,  minDmg = 23,  maxDmg = 23,  level = 18 },
        [3] = { spellID = 8204,  minDmg = 37,  maxDmg = 37,  level = 28 },
        [4] = { spellID = 8205,  minDmg = 55,  maxDmg = 55,  level = 38 },
        [5] = { spellID = 11580, minDmg = 82,  maxDmg = 82,  level = 48 },
        [6] = { spellID = 11581, minDmg = 103, maxDmg = 103, level = 58 },
        [7] = { spellID = 25264, minDmg = 123, maxDmg = 123, level = 67 },
    },
}

-- Execute (instant, Physical, flat base damage + rage scaling)
SpellData[5308] = {
    name = "Execute",
    school = SCHOOL_PHYSICAL,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "melee",
    rageBonus = true,
    rageCost = 15,
    ranks = {
        [1] = { spellID = 5308,  minDmg = 125, maxDmg = 125, rageConversion = 3,  level = 24 },
        [2] = { spellID = 20658, minDmg = 200, maxDmg = 200, rageConversion = 6,  level = 32 },
        [3] = { spellID = 20660, minDmg = 325, maxDmg = 325, rageConversion = 9,  level = 40 },
        [4] = { spellID = 20661, minDmg = 450, maxDmg = 450, rageConversion = 12, level = 48 },
        [5] = { spellID = 20662, minDmg = 600, maxDmg = 600, rageConversion = 15, level = 56 },
        [6] = { spellID = 25234, minDmg = 750, maxDmg = 750, rageConversion = 18, level = 65 },
        [7] = { spellID = 25236, minDmg = 925, maxDmg = 925, rageConversion = 21, level = 70 },
    },
}

-- Bloodthirst (instant, Physical, 45% AP, no weapon damage)
SpellData[23881] = {
    name = "Bloodthirst",
    school = SCHOOL_PHYSICAL,
    apCoefficient = 0.45,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    scalingType = "melee",
    ranks = {
        [1] = { spellID = 23881, minDmg = 0, maxDmg = 0, level = 40 },
        [2] = { spellID = 23892, minDmg = 0, maxDmg = 0, level = 48 },
        [3] = { spellID = 23893, minDmg = 0, maxDmg = 0, level = 54 },
        [4] = { spellID = 23894, minDmg = 0, maxDmg = 0, level = 60 },
        [5] = { spellID = 25251, minDmg = 0, maxDmg = 0, level = 66 },
        [6] = { spellID = 30335, minDmg = 0, maxDmg = 0, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- DOTS
-------------------------------------------------------------------------------

-- Rend (instant, Physical, bleed DoT, weapon-scaled via weaponDotCoefficient)
SpellData[772] = {
    name = "Rend",
    school = SCHOOL_PHYSICAL,
    weaponDotCoefficient = 0.00743,
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    isAoe = false,
    spellType = "dot",
    scalingType = "melee",
    ranks = {
        [1] = { spellID = 772,   totalDmg = 15,  duration = 9,  numTicks = 3, level = 4 },
        [2] = { spellID = 6546,  totalDmg = 28,  duration = 12, numTicks = 4, level = 10 },
        [3] = { spellID = 6547,  totalDmg = 45,  duration = 15, numTicks = 5, level = 20 },
        [4] = { spellID = 6548,  totalDmg = 66,  duration = 18, numTicks = 6, level = 30 },
        [5] = { spellID = 11572, totalDmg = 98,  duration = 21, numTicks = 7, level = 40 },
        [6] = { spellID = 11573, totalDmg = 126, duration = 21, numTicks = 7, level = 50 },
        [7] = { spellID = 11574, totalDmg = 147, duration = 21, numTicks = 7, level = 60 },
        [8] = { spellID = 25208, totalDmg = 182, duration = 21, numTicks = 7, level = 68 },
    },
}

-------------------------------------------------------------------------------
-- Merge into global SpellData table
-------------------------------------------------------------------------------
for spellID, data in pairs(SpellData) do
    ns.SpellData[spellID] = data
end
