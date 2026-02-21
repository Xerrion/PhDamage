-------------------------------------------------------------------------------
-- SpellData_Warlock.lua
-- Warlock spell definitions for TBC Anniversary (2.5.5)
-- Base values, coefficients, and per-rank data sourced from Wowhead TBC Classic
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-- Local references to constants
local SCHOOL_FIRE = ns.SCHOOL_FIRE
local SCHOOL_SHADOW = ns.SCHOOL_SHADOW

local SpellData = {}

-------------------------------------------------------------------------------
-- Direct Damage Spells
-------------------------------------------------------------------------------

-- Shadow Bolt — 3.0s cast, Shadow
-- Coefficient: 3.0 / 3.5 = 0.8571
SpellData[686] = {
    name = "Shadow Bolt",
    school = SCHOOL_SHADOW,
    coefficient = 0.8571,
    castTime = 3.0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    spellType = "direct",
    ranks = {
        [1]  = { spellID = 686,   minDmg = 13,   maxDmg = 18,   level = 1  },
        [2]  = { spellID = 695,   minDmg = 26,   maxDmg = 32,   level = 6  },
        [3]  = { spellID = 705,   minDmg = 52,   maxDmg = 61,   level = 12 },
        [4]  = { spellID = 1088,  minDmg = 92,   maxDmg = 104,  level = 20 },
        [5]  = { spellID = 1106,  minDmg = 150,  maxDmg = 170,  level = 28 },
        [6]  = { spellID = 7641,  minDmg = 213,  maxDmg = 240,  level = 36 },
        [7]  = { spellID = 11659, minDmg = 292,  maxDmg = 327,  level = 44 },
        [8]  = { spellID = 11660, minDmg = 373,  maxDmg = 415,  level = 52 },
        [9]  = { spellID = 11661, minDmg = 455,  maxDmg = 507,  level = 60 },
        [10] = { spellID = 25307, minDmg = 482,  maxDmg = 538,  level = 63 },
        [11] = { spellID = 27209, minDmg = 544,  maxDmg = 607,  level = 69 },
    },
}

-- Searing Pain — 1.5s cast, Fire
-- Coefficient: 1.5 / 3.5 = 0.4286
SpellData[5676] = {
    name = "Searing Pain",
    school = SCHOOL_FIRE,
    coefficient = 0.4286,
    castTime = 1.5,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    spellType = "direct",
    ranks = {
        [1] = { spellID = 5676,  minDmg = 42,  maxDmg = 52,  level = 18 },
        [2] = { spellID = 17919, minDmg = 64,  maxDmg = 76,  level = 26 },
        [3] = { spellID = 17920, minDmg = 91,  maxDmg = 107, level = 34 },
        [4] = { spellID = 17921, minDmg = 128, maxDmg = 150, level = 42 },
        [5] = { spellID = 17922, minDmg = 168, maxDmg = 196, level = 50 },
        [6] = { spellID = 17923, minDmg = 204, maxDmg = 240, level = 58 },
        [7] = { spellID = 27210, minDmg = 243, maxDmg = 285, level = 66 },
        [8] = { spellID = 30459, minDmg = 270, maxDmg = 320, level = 70 },
    },
}

-- Soul Fire — 6.0s cast, Fire
-- Coefficient: capped; base = 6.0 / 3.5 = 1.7143, but coefficient cap applies = 1.0
-- TBC actually uses 1.15 effective coefficient for Soul Fire
SpellData[6353] = {
    name = "Soul Fire",
    school = SCHOOL_FIRE,
    coefficient = 1.15,
    castTime = 6.0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    spellType = "direct",
    ranks = {
        [1] = { spellID = 6353,  minDmg = 623,  maxDmg = 783,  level = 48 },
        [2] = { spellID = 17924, minDmg = 703,  maxDmg = 881,  level = 56 },
        [3] = { spellID = 27211, minDmg = 839,  maxDmg = 1051, level = 64 },
        [4] = { spellID = 30545, minDmg = 1003, maxDmg = 1257, level = 70 },
    },
}

-- Shadowburn — instant, Shadow
-- Coefficient: 1.5 / 3.5 = 0.4286 (instant spell uses 1.5s base)
SpellData[17877] = {
    name = "Shadowburn",
    school = SCHOOL_SHADOW,
    coefficient = 0.4286,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    spellType = "direct",
    ranks = {
        [1] = { spellID = 17877, minDmg = 91,  maxDmg = 104, level = 20 },
        [2] = { spellID = 18867, minDmg = 134, maxDmg = 150, level = 24 },
        [3] = { spellID = 18868, minDmg = 184, maxDmg = 206, level = 32 },
        [4] = { spellID = 18869, minDmg = 261, maxDmg = 291, level = 40 },
        [5] = { spellID = 18870, minDmg = 350, maxDmg = 390, level = 48 },
        [6] = { spellID = 18871, minDmg = 440, maxDmg = 492, level = 56 },
        [7] = { spellID = 27263, minDmg = 518, maxDmg = 578, level = 64 },
        [8] = { spellID = 30546, minDmg = 597, maxDmg = 665, level = 70 },
    },
}

-- Incinerate — 2.5s cast, Fire
-- Coefficient: 2.5 / 3.5 = 0.7143
-- Bonus damage when target has Immolate (handled in AuraMap)
SpellData[29722] = {
    name = "Incinerate",
    school = SCHOOL_FIRE,
    coefficient = 0.7143,
    castTime = 2.5,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    spellType = "direct",
    ranks = {
        [1] = { spellID = 29722, minDmg = 357, maxDmg = 413, level = 64 },
        [2] = { spellID = 32231, minDmg = 444, maxDmg = 514, level = 70 },
    },
}

-- Conflagrate — instant, Fire
-- Coefficient: 1.5 / 3.5 = 0.4286 (instant spell uses 1.5s base)
-- Requires and consumes Immolate on target
SpellData[17962] = {
    name = "Conflagrate",
    school = SCHOOL_FIRE,
    coefficient = 0.4286,
    castTime = 0,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    spellType = "direct",
    ranks = {
        [1] = { spellID = 17962, minDmg = 249, maxDmg = 316, level = 40 },
        [2] = { spellID = 18930, minDmg = 319, maxDmg = 400, level = 48 },
        [3] = { spellID = 18931, minDmg = 395, maxDmg = 491, level = 54 },
        [4] = { spellID = 18932, minDmg = 447, maxDmg = 557, level = 60 },
        [5] = { spellID = 27266, minDmg = 512, maxDmg = 638, level = 65 },
        [6] = { spellID = 30912, minDmg = 579, maxDmg = 721, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- DoT Spells
-------------------------------------------------------------------------------

-- Corruption — base 2.0s cast (instant with 5/5 Improved Corruption), Shadow
-- Coefficient: duration / 15 = 18 / 15 = 1.2, but with cast time penalty:
--   (baseCastTime / 3.5) / ((baseCastTime / 3.5) + (duration / 15)) * (duration / 15)
--   = (2.0/3.5) / ((2.0/3.5) + (18/15)) * (18/15)
--   = 0.5714 / (0.5714 + 1.2) * 1.2 = 0.5714 / 1.7714 * 1.2 = 0.387
-- Wait — TBC actually uses a simpler model for Corruption:
-- Total coefficient = (duration / 15) = 1.2, penalized by cast time:
-- Effective = 1.2 * (1 - penalty). The commonly cited value is ~0.936.
-- This accounts for the 2.0s base cast time reducing the DoT coefficient.
SpellData[172] = {
    name = "Corruption",
    school = SCHOOL_SHADOW,
    coefficient = 0.936,
    castTime = 2.0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    spellType = "dot",
    duration = 18,
    tickInterval = 3,
    numTicks = 6,
    ranks = {
        [1] = { spellID = 172,   totalDmg = 40,  level = 4  },
        [2] = { spellID = 6222,  totalDmg = 90,  level = 14 },
        [3] = { spellID = 6223,  totalDmg = 222, level = 24 },
        [4] = { spellID = 7648,  totalDmg = 324, level = 34 },
        [5] = { spellID = 11671, totalDmg = 486, level = 44 },
        [6] = { spellID = 11672, totalDmg = 666, level = 54 },
        [7] = { spellID = 25311, totalDmg = 822, level = 60 },
        [8] = { spellID = 27216, totalDmg = 900, level = 69 },
    },
}

-- Curse of Agony — instant, Shadow
-- Coefficient: ~1.2 over full duration (weighted — later ticks hit harder)
-- First 4 ticks = 50% avg, middle 4 = 100% avg, last 4 = 150% avg per tick
-- 24s duration, 12 ticks, 2s tick interval
SpellData[980] = {
    name = "Curse of Agony",
    school = SCHOOL_SHADOW,
    coefficient = 1.2,
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    spellType = "dot",
    duration = 24,
    tickInterval = 2,
    numTicks = 12,
    isRamping = true,
    ranks = {
        [1] = { spellID = 980,   totalDmg = 84,   level = 8  },
        [2] = { spellID = 1014,  totalDmg = 180,  level = 18 },
        [3] = { spellID = 6217,  totalDmg = 312,  level = 28 },
        [4] = { spellID = 11711, totalDmg = 504,  level = 38 },
        [5] = { spellID = 11712, totalDmg = 780,  level = 48 },
        [6] = { spellID = 11713, totalDmg = 1044, level = 58 },
        [7] = { spellID = 27218, totalDmg = 1356, level = 67 },
    },
}

-- Unstable Affliction — 1.5s cast, Shadow
-- Coefficient: cast time penalty applies to DoT portion
-- Base: (1.5/3.5) + (18/15) = 0.4286 + 1.2 = 1.6286 total budget
-- DoT portion: 1.2 / 1.6286 * 1.6286 = 1.2 (DoT gets duration/15 share)
-- Commonly cited as ~1.2 total coefficient
SpellData[30108] = {
    name = "Unstable Affliction",
    school = SCHOOL_SHADOW,
    coefficient = 1.2,
    castTime = 1.5,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    spellType = "dot",
    duration = 18,
    tickInterval = 3,
    numTicks = 6,
    ranks = {
        [1] = { spellID = 30108, totalDmg = 660,  level = 50 },
        [2] = { spellID = 30404, totalDmg = 858,  level = 60 },
        [3] = { spellID = 30405, totalDmg = 1050, level = 70 },
    },
}

-- Siphon Life — instant, Shadow
-- Coefficient: duration / 15 = 30 / 15 = 2.0, but capped at 1.0 for instant DoTs
-- Commonly cited as ~1.0 total coefficient
-- Also heals caster for same amount
SpellData[18265] = {
    name = "Siphon Life",
    school = SCHOOL_SHADOW,
    coefficient = 1.0,
    castTime = 0,
    canCrit = false,
    isDot = true,
    isChanneled = false,
    spellType = "dot",
    duration = 30,
    tickInterval = 3,
    numTicks = 10,
    heals = true,
    ranks = {
        [1] = { spellID = 18265, totalDmg = 150, level = 30 },
        [2] = { spellID = 18879, totalDmg = 220, level = 38 },
        [3] = { spellID = 18880, totalDmg = 330, level = 48 },
        [4] = { spellID = 18881, totalDmg = 450, level = 58 },
        [5] = { spellID = 27264, totalDmg = 540, level = 63 },
        [6] = { spellID = 30911, totalDmg = 630, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- Hybrid Spells (Direct + DoT)
-------------------------------------------------------------------------------

-- Immolate — 2.0s cast, Fire
-- Direct coefficient: castTime / 3.5 adjusted for hybrid split = ~0.2
-- DoT coefficient: duration / 15 adjusted for hybrid split = ~0.65
-- 15s duration, 5 ticks every 3s
SpellData[348] = {
    name = "Immolate",
    school = SCHOOL_FIRE,
    directCoefficient = 0.2,
    dotCoefficient = 0.65,
    castTime = 2.0,
    canCrit = true,
    isDot = true,
    isChanneled = false,
    spellType = "hybrid",
    duration = 15,
    tickInterval = 3,
    numTicks = 5,
    ranks = {
        [1] = { spellID = 348,   minDmg = 8,   maxDmg = 8,   dotDmg = 20,  level = 1  },
        [2] = { spellID = 707,   minDmg = 19,  maxDmg = 19,  dotDmg = 40,  level = 10 },
        [3] = { spellID = 1094,  minDmg = 45,  maxDmg = 45,  dotDmg = 90,  level = 20 },
        [4] = { spellID = 2941,  minDmg = 90,  maxDmg = 90,  dotDmg = 165, level = 30 },
        [5] = { spellID = 11665, minDmg = 134, maxDmg = 134, dotDmg = 255, level = 40 },
        [6] = { spellID = 11667, minDmg = 192, maxDmg = 192, dotDmg = 365, level = 50 },
        [7] = { spellID = 11668, minDmg = 258, maxDmg = 258, dotDmg = 485, level = 60 },
        [8] = { spellID = 25309, minDmg = 279, maxDmg = 279, dotDmg = 510, level = 60 },
        [9] = { spellID = 27215, minDmg = 327, maxDmg = 327, dotDmg = 615, level = 69 },
    },
}

-------------------------------------------------------------------------------
-- Channeled Spells
-------------------------------------------------------------------------------

-- Drain Life — 5.0s channel, Shadow
-- Coefficient: channelDuration / 3.5 = 5.0 / 3.5 = 1.4286
-- But channeled spells get a penalty: effectively ~0.7143 for the whole channel
-- Also heals caster for same amount
-- 5 ticks, 1 tick per second
SpellData[689] = {
    name = "Drain Life",
    school = SCHOOL_SHADOW,
    coefficient = 0.7143,
    castTime = 5.0,
    canCrit = false,
    isDot = false,
    isChanneled = true,
    spellType = "channel",
    duration = 5,
    tickInterval = 1,
    numTicks = 5,
    heals = true,
    ranks = {
        [1] = { spellID = 689,   totalDmg = 10,  totalHeal = 10,  level = 14 },
        [2] = { spellID = 699,   totalDmg = 85,  totalHeal = 85,  level = 22 },
        [3] = { spellID = 709,   totalDmg = 145, totalHeal = 145, level = 30 },
        [4] = { spellID = 7651,  totalDmg = 205, totalHeal = 205, level = 38 },
        [5] = { spellID = 11699, totalDmg = 275, totalHeal = 275, level = 46 },
        [6] = { spellID = 11700, totalDmg = 355, totalHeal = 355, level = 54 },
        [7] = { spellID = 27219, totalDmg = 455, totalHeal = 455, level = 62 },
        [8] = { spellID = 27220, totalDmg = 540, totalHeal = 540, level = 69 },
    },
}

-- Drain Soul — 15.0s channel, Shadow
-- Coefficient: ~2.0 (long channel duration, but low base damage — utility spell)
-- 5 ticks every 3 seconds
SpellData[1120] = {
    name = "Drain Soul",
    school = SCHOOL_SHADOW,
    coefficient = 2.0,
    castTime = 15.0,
    canCrit = false,
    isDot = false,
    isChanneled = true,
    spellType = "channel",
    duration = 15,
    tickInterval = 3,
    numTicks = 5,
    ranks = {
        [1] = { spellID = 1120,  totalDmg = 55,  level = 10 },
        [2] = { spellID = 8288,  totalDmg = 155, level = 24 },
        [3] = { spellID = 8289,  totalDmg = 295, level = 38 },
        [4] = { spellID = 11675, totalDmg = 455, level = 52 },
        [5] = { spellID = 27217, totalDmg = 580, level = 67 },
    },
}

-- Rain of Fire — 8.0s channel, Fire (AoE)
-- Coefficient: ~0.57 per target over full channel (8.0 / 3.5 = 2.2857, but AoE penalty)
-- 4 ticks every 2 seconds
SpellData[5740] = {
    name = "Rain of Fire",
    school = SCHOOL_FIRE,
    coefficient = 0.57,
    castTime = 8.0,
    canCrit = false,
    isDot = false,
    isChanneled = true,
    isAoe = true,
    spellType = "channel",
    duration = 8,
    tickInterval = 2,
    numTicks = 4,
    ranks = {
        [1] = { spellID = 5740,  totalDmg = 372, level = 20 },
        [2] = { spellID = 6219,  totalDmg = 564, level = 34 },
        [3] = { spellID = 11677, totalDmg = 748, level = 46 },
        [4] = { spellID = 11678, totalDmg = 932, level = 58 },
        [5] = { spellID = 27212, totalDmg = 944, level = 69 },
    },
}

-- Hellfire — 15.0s channel, Fire (PBAoE)
-- Coefficient: ~0.4286 per tick period (each tick = 1s, 15 ticks)
-- Also damages the caster
SpellData[1949] = {
    name = "Hellfire",
    school = SCHOOL_FIRE,
    coefficient = 0.4286,
    castTime = 15.0,
    canCrit = false,
    isDot = false,
    isChanneled = true,
    isAoe = true,
    spellType = "channel",
    duration = 15,
    tickInterval = 1,
    numTicks = 15,
    damagesSelf = true,
    ranks = {
        [1] = { spellID = 1949,  totalDmg = 255, level = 12 },
        [2] = { spellID = 11683, totalDmg = 510, level = 28 },
        [3] = { spellID = 11684, totalDmg = 825, level = 44 },
        [4] = { spellID = 27214, totalDmg = 1395, level = 68 },
    },
}

-------------------------------------------------------------------------------
-- Utility Spells
-------------------------------------------------------------------------------

-- Life Tap — instant, Shadow (converts health to mana)
-- Coefficient: ~0.8 (gains spell power scaling)
SpellData[1454] = {
    name = "Life Tap",
    school = SCHOOL_SHADOW,
    coefficient = 0.8,
    castTime = 0,
    canCrit = false,
    isDot = false,
    isChanneled = false,
    spellType = "utility",
    convertsHealth = true,
    ranks = {
        [1] = { spellID = 1454,  healthCost = 30,  manaGain = 30,  level = 6  },
        [2] = { spellID = 1455,  healthCost = 75,  manaGain = 75,  level = 16 },
        [3] = { spellID = 1456,  healthCost = 140, manaGain = 140, level = 26 },
        [4] = { spellID = 11687, healthCost = 220, manaGain = 220, level = 36 },
        [5] = { spellID = 11688, healthCost = 310, manaGain = 310, level = 46 },
        [6] = { spellID = 11689, healthCost = 420, manaGain = 420, level = 56 },
        [7] = { spellID = 27222, healthCost = 582, manaGain = 582, level = 68 },
    },
}

-------------------------------------------------------------------------------
-- AoE Spells
-------------------------------------------------------------------------------

-- Seed of Corruption — 2.0s cast, Shadow (AoE detonation)
-- Coefficient: ~0.2286 for the detonation portion
-- Detonates when 1044 damage is absorbed by the embedded DoT
-- For Phase 1, modeled as detonation damage only
SpellData[27243] = {
    name = "Seed of Corruption",
    school = SCHOOL_SHADOW,
    coefficient = 0.2286,
    castTime = 2.0,
    canCrit = false,
    isDot = false,
    isChanneled = false,
    isAoe = true,
    spellType = "direct",
    detonationThreshold = 1044,
    ranks = {
        [1] = { spellID = 27243, minDmg = 1110, maxDmg = 1290, level = 70 },
    },
}

for spellID, data in pairs(SpellData) do
    ns.SpellData[spellID] = data
end
