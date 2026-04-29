-------------------------------------------------------------------------------
-- SpellData_Warlock.lua
-- Warlock spell definitions for TBC Anniversary (2.5.5)
-- Base values, coefficients, and per-rank data sourced from Wowhead TBC Classic
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
        -- Wowhead spell=686 (sub-cap penalty rank, SP mod 0.14)
        [1]  = { spellID = 686,   minDmg = 13,   maxDmg = 18,   level = 1, maxLevel = 5, coefficient = 0.14  },
        -- Wowhead spell=695 (sub-cap penalty rank, SP mod 0.299)
        [2]  = { spellID = 695,   minDmg = 26,   maxDmg = 32,   level = 6, maxLevel = 11, coefficient = 0.299 },
        -- Wowhead spell=705 (sub-cap penalty rank, SP mod 0.56)
        [3]  = { spellID = 705,   minDmg = 52,   maxDmg = 61,   level = 12, maxLevel = 19, coefficient = 0.56  },
        [4]  = { spellID = 1088,  minDmg = 92,   maxDmg = 104,  level = 20, maxLevel = 27 },
        [5]  = { spellID = 1106,  minDmg = 150,  maxDmg = 170,  level = 28, maxLevel = 35 },
        [6]  = { spellID = 7641,  minDmg = 213,  maxDmg = 240,  level = 36, maxLevel = 43 },
        [7]  = { spellID = 11659, minDmg = 292,  maxDmg = 327,  level = 44, maxLevel = 51 },
        [8]  = { spellID = 11660, minDmg = 373,  maxDmg = 415,  level = 52, maxLevel = 59 },
        [9]  = { spellID = 11661, minDmg = 455,  maxDmg = 507,  level = 60, maxLevel = 62 },
        [10] = { spellID = 25307, minDmg = 482,  maxDmg = 538,  level = 63, maxLevel = 68 },
        [11] = { spellID = 27209, minDmg = 544,  maxDmg = 607,  level = 69, maxLevel = 69 },
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
        -- Wowhead spell=5676 (sub-cap penalty rank, SP mod 0.396)
        [1] = { spellID = 5676,  minDmg = 42,  maxDmg = 52,  level = 18, maxLevel = 25, coefficient = 0.396 },
        [2] = { spellID = 17919, minDmg = 64,  maxDmg = 76,  level = 26, maxLevel = 33 },
        [3] = { spellID = 17920, minDmg = 91,  maxDmg = 107, level = 34, maxLevel = 41 },
        [4] = { spellID = 17921, minDmg = 128, maxDmg = 150, level = 42, maxLevel = 49 },
        [5] = { spellID = 17922, minDmg = 168, maxDmg = 196, level = 50, maxLevel = 57 },
        [6] = { spellID = 17923, minDmg = 204, maxDmg = 240, level = 58, maxLevel = 65 },
        [7] = { spellID = 27210, minDmg = 243, maxDmg = 285, level = 66, maxLevel = 69 },
        [8] = { spellID = 30459, minDmg = 270, maxDmg = 320, level = 70, maxLevel = 70 },
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
        [1] = { spellID = 6353,  minDmg = 623,  maxDmg = 783,  level = 48, maxLevel = 55 },
        [2] = { spellID = 17924, minDmg = 703,  maxDmg = 881,  level = 56, maxLevel = 63 },
        [3] = { spellID = 27211, minDmg = 839,  maxDmg = 1051, level = 64, maxLevel = 69 },
        [4] = { spellID = 30545, minDmg = 1003, maxDmg = 1257, level = 70, maxLevel = 70 },
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
        [1] = { spellID = 17877, minDmg = 91,  maxDmg = 104, level = 20, maxLevel = 23 },
        [2] = { spellID = 18867, minDmg = 134, maxDmg = 150, level = 24, maxLevel = 31 },
        [3] = { spellID = 18868, minDmg = 184, maxDmg = 206, level = 32, maxLevel = 39 },
        [4] = { spellID = 18869, minDmg = 261, maxDmg = 291, level = 40, maxLevel = 47 },
        [5] = { spellID = 18870, minDmg = 350, maxDmg = 390, level = 48, maxLevel = 55 },
        [6] = { spellID = 18871, minDmg = 440, maxDmg = 492, level = 56, maxLevel = 63 },
        [7] = { spellID = 27263, minDmg = 518, maxDmg = 578, level = 64, maxLevel = 69 },
        [8] = { spellID = 30546, minDmg = 597, maxDmg = 665, level = 70, maxLevel = 70 },
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
        [1] = { spellID = 29722, minDmg = 357, maxDmg = 413, level = 64, maxLevel = 69 },
        [2] = { spellID = 32231, minDmg = 444, maxDmg = 514, level = 70, maxLevel = 70 },
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
        [1] = { spellID = 17962, minDmg = 249, maxDmg = 316, level = 40, maxLevel = 47 },
        [2] = { spellID = 18930, minDmg = 319, maxDmg = 400, level = 48, maxLevel = 53 },
        [3] = { spellID = 18931, minDmg = 395, maxDmg = 491, level = 54, maxLevel = 59 },
        [4] = { spellID = 18932, minDmg = 447, maxDmg = 557, level = 60, maxLevel = 64 },
        [5] = { spellID = 27266, minDmg = 512, maxDmg = 638, level = 65, maxLevel = 69 },
        [6] = { spellID = 30912, minDmg = 579, maxDmg = 721, level = 70, maxLevel = 70 },
    },
}

-- Death Coil — instant, Shadow
-- Coefficient: 0.214 (instant, fixed damage, cannot crit)
SpellData[6789] = {
    name = "Death Coil",
    school = SCHOOL_SHADOW,
    coefficient = 0.214,
    castTime = 1.5, -- instant (GCD)
    canCrit = false,
    isDot = false,
    isChanneled = false,
    spellType = "direct",
    ranks = {
        [1] = { spellID = 6789,  minDmg = 244, maxDmg = 244, level = 42, maxLevel = 49 },
        [2] = { spellID = 17925, minDmg = 319, maxDmg = 319, level = 50, maxLevel = 57 },
        [3] = { spellID = 17926, minDmg = 400, maxDmg = 400, level = 58, maxLevel = 67 },
        [4] = { spellID = 27223, minDmg = 519, maxDmg = 519, level = 68, maxLevel = 68 },
    },
}

-------------------------------------------------------------------------------
-- DoT Spells
-------------------------------------------------------------------------------

-- Corruption — base 2.0s cast (instant with 5/5 Improved Corruption), Shadow
-- Spell coefficient: 0.936 total (0.156 per tick × 6 ticks)
-- Source: Wowhead TBC Classic tooltip data (spell 27216)
-- Corruption's 2.0s base cast time applies a penalty vs the standard
-- DoT formula (duration/15 = 1.2), reducing it to 0.936.
-- Note: The base cast time determines the coefficient even when
-- talents (Improved Corruption) reduce it to instant.
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
        [1] = { spellID = 172,   totalDmg = 40,  level = 4, maxLevel = 13 },
        [2] = { spellID = 6222,  totalDmg = 90,  level = 14, maxLevel = 23 },
        [3] = { spellID = 6223,  totalDmg = 222, level = 24, maxLevel = 33 },
        [4] = { spellID = 7648,  totalDmg = 324, level = 34, maxLevel = 43 },
        [5] = { spellID = 11671, totalDmg = 486, level = 44, maxLevel = 53 },
        [6] = { spellID = 11672, totalDmg = 666, level = 54, maxLevel = 59 },
        [7] = { spellID = 25311, totalDmg = 822, level = 60, maxLevel = 68 },
        [8] = { spellID = 27216, totalDmg = 900, level = 69, maxLevel = 69 },
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
        [1] = { spellID = 980,   totalDmg = 84,   level = 8, maxLevel = 17 },
        [2] = { spellID = 1014,  totalDmg = 180,  level = 18, maxLevel = 27 },
        [3] = { spellID = 6217,  totalDmg = 312,  level = 28, maxLevel = 37 },
        [4] = { spellID = 11711, totalDmg = 504,  level = 38, maxLevel = 47 },
        [5] = { spellID = 11712, totalDmg = 780,  level = 48, maxLevel = 57 },
        [6] = { spellID = 11713, totalDmg = 1044, level = 58, maxLevel = 66 },
        [7] = { spellID = 27218, totalDmg = 1356, level = 67, maxLevel = 67 },
    },
}

-- Unstable Affliction — 1.5s cast, Shadow
-- Spell coefficient: 1.2 total (0.200 per tick × 6 ticks)
-- Source: Wowhead TBC Classic tooltip data (spell 30405)
-- UA's 1.5s cast time equals the GCD minimum, so no cast-time
-- penalty is applied. Full DoT formula: duration/15 = 18/15 = 1.2
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
        [1] = { spellID = 30108, totalDmg = 660,  level = 50, maxLevel = 59 },
        [2] = { spellID = 30404, totalDmg = 858,  level = 60, maxLevel = 69 },
        [3] = { spellID = 30405, totalDmg = 1050, level = 70, maxLevel = 70 },
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
        [1] = { spellID = 18265, totalDmg = 150, level = 30, maxLevel = 37 },
        [2] = { spellID = 18879, totalDmg = 220, level = 38, maxLevel = 47 },
        [3] = { spellID = 18880, totalDmg = 330, level = 48, maxLevel = 57 },
        [4] = { spellID = 18881, totalDmg = 450, level = 58, maxLevel = 62 },
        [5] = { spellID = 27264, totalDmg = 540, level = 63, maxLevel = 69 },
        [6] = { spellID = 30911, totalDmg = 630, level = 70, maxLevel = 70 },
    },
}

-- Curse of Doom — instant, Shadow
-- Coefficient: 2.0 (60s single tick, cannot crit)
SpellData[603] = {
    name = "Curse of Doom",
    school = SCHOOL_SHADOW,
    coefficient = 2.0,
    castTime = 1.5, -- instant (GCD)
    canCrit = false,
    isDot = true,
    isChanneled = false,
    spellType = "dot",
    duration = 60,
    tickInterval = 60,
    numTicks = 1,
    ranks = {
        [1] = { spellID = 603,   totalDmg = 3200, level = 60, maxLevel = 69 },
        [2] = { spellID = 30910, totalDmg = 4200, level = 70, maxLevel = 70 },
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
        -- Wowhead spell=348 (sub-cap penalty rank, dir SP mod 0.058, dot per-tick 0.037 x 5 = 0.185)
        [1] = { spellID = 348,   minDmg = 8,   maxDmg = 8,   dotDmg = 20,  level = 1, maxLevel = 9,
                directCoefficient = 0.058, dotCoefficient = 0.185 },
        -- Wowhead spell=707 (sub-cap penalty rank, dir SP mod 0.125, dot per-tick 0.081 x 5 = 0.405)
        [2] = { spellID = 707,   minDmg = 19,  maxDmg = 19,  dotDmg = 40,  level = 10, maxLevel = 19,
                directCoefficient = 0.125, dotCoefficient = 0.405 },
        [3] = { spellID = 1094,  minDmg = 45,  maxDmg = 45,  dotDmg = 90,  level = 20, maxLevel = 29 },
        [4] = { spellID = 2941,  minDmg = 90,  maxDmg = 90,  dotDmg = 165, level = 30, maxLevel = 39 },
        [5] = { spellID = 11665, minDmg = 134, maxDmg = 134, dotDmg = 255, level = 40, maxLevel = 49 },
        [6] = { spellID = 11667, minDmg = 192, maxDmg = 192, dotDmg = 365, level = 50, maxLevel = 59 },
        [7] = { spellID = 11668, minDmg = 258, maxDmg = 258, dotDmg = 485, level = 60, maxLevel = 60 },
        [8] = { spellID = 25309, minDmg = 279, maxDmg = 279, dotDmg = 510, level = 60, maxLevel = 68 },
        [9] = { spellID = 27215, minDmg = 327, maxDmg = 327, dotDmg = 615, level = 69, maxLevel = 69 },
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
        -- Wowhead spell=689 (per-tick SP mod 0.111 x 5 ticks = 0.555; sub-cap penalty rank)
        [1] = { spellID = 689,   totalDmg = 10,  totalHeal = 10,  level = 14, maxLevel = 21, coefficient = 0.555 },
        [2] = { spellID = 699,   totalDmg = 85,  totalHeal = 85,  level = 22, maxLevel = 29 },
        [3] = { spellID = 709,   totalDmg = 145, totalHeal = 145, level = 30, maxLevel = 37 },
        [4] = { spellID = 7651,  totalDmg = 205, totalHeal = 205, level = 38, maxLevel = 45 },
        [5] = { spellID = 11699, totalDmg = 275, totalHeal = 275, level = 46, maxLevel = 53 },
        [6] = { spellID = 11700, totalDmg = 355, totalHeal = 355, level = 54, maxLevel = 61 },
        [7] = { spellID = 27219, totalDmg = 455, totalHeal = 455, level = 62, maxLevel = 68 },
        [8] = { spellID = 27220, totalDmg = 540, totalHeal = 540, level = 69, maxLevel = 69 },
    },
}

-- Drain Soul: 15s channel, 5 ticks @ 3s. Wowhead per-tick SP mod 0.429 -> 2.145 total.
-- Source: https://www.wowhead.com/tbc/spell=27217
SpellData[1120] = {
    name = "Drain Soul",
    school = SCHOOL_SHADOW,
    coefficient = 2.145,
    castTime = 15.0,
    canCrit = false,
    isDot = false,
    isChanneled = true,
    spellType = "channel",
    duration = 15,
    tickInterval = 3,
    numTicks = 5,
    ranks = {
        -- Wowhead spell=1120 (per-tick SP mod 0.0893 x 15 ticks = 1.34; sub-cap penalty rank)
        [1] = { spellID = 1120,  totalDmg = 55,  level = 10, maxLevel = 23, coefficient = 1.34 },
        [2] = { spellID = 8288,  totalDmg = 155, level = 24, maxLevel = 37 },
        [3] = { spellID = 8289,  totalDmg = 295, level = 38, maxLevel = 51 },
        [4] = { spellID = 11675, totalDmg = 455, level = 52, maxLevel = 66 },
        [5] = { spellID = 27217, totalDmg = 580, level = 67, maxLevel = 67 },
    },
}

-- Rain of Fire: 8-second channel, 4 ticks @ 2s. Wowhead per-tick SP mod 0.237 -> 0.948 total
-- (we round to 0.952 to align with the long-standing WoWWiki figure; difference is negligible).
-- Source: https://www.wowhead.com/tbc/spell=27212
SpellData[5740] = {
    name = "Rain of Fire",
    school = SCHOOL_FIRE,
    coefficient = 0.952,
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
        [1] = { spellID = 5740,  effectID = 42223, totalDmg = 372, level = 20, maxLevel = 33 },
        [2] = { spellID = 6219,  effectID = 42224, totalDmg = 564, level = 34, maxLevel = 45 },
        [3] = { spellID = 11677, effectID = 42225, totalDmg = 748, level = 46, maxLevel = 57 },
        [4] = { spellID = 11678, effectID = 42226, totalDmg = 932, level = 58, maxLevel = 68 },
        [5] = { spellID = 27212, effectID = 42218, totalDmg = 944, level = 69, maxLevel = 69 },
    },
}

-- Hellfire: 15-second self-channel; ticks every 1s for 15 ticks.
-- Wowhead spell=11684 / top rank 27213: per-tick SP mod 0.095 -> total 1.425.
-- Self-damage component is not modeled (out of scope; see issue #46).
-- Source: https://www.wowhead.com/tbc/spell=27213
SpellData[1949] = {
    name = "Hellfire",
    school = SCHOOL_FIRE,
    coefficient = 1.425,
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
        [1] = { spellID = 1949,  effectID = 5857,  totalDmg = 1245, level = 30, maxLevel = 41 },
        [2] = { spellID = 11683, effectID = 11681, totalDmg = 2085, level = 42, maxLevel = 53 },
        [3] = { spellID = 11684, effectID = 11682, totalDmg = 3120, level = 54, maxLevel = 67 },
        [4] = { spellID = 27213, effectID = 27214, totalDmg = 4590, level = 68, maxLevel = 68 },
    },
}

-------------------------------------------------------------------------------
-- Utility Spells
-------------------------------------------------------------------------------

-- Life Tap — instant, Shadow (converts health to mana)
-- Current addon model uses a 0.8 coefficient for the spell line, including Rank 6 at level 70.
-- Revisit only if stronger in-game evidence shows this model is wrong.
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
        [1] = { spellID = 1454,  healthCost = 30,  manaGain = 30,  level = 6, maxLevel = 15 },
        [2] = { spellID = 1455,  healthCost = 75,  manaGain = 75,  level = 16, maxLevel = 25 },
        [3] = { spellID = 1456,  healthCost = 140, manaGain = 140, level = 26, maxLevel = 35 },
        [4] = { spellID = 11687, healthCost = 220, manaGain = 220, level = 36, maxLevel = 45 },
        [5] = { spellID = 11688, healthCost = 310, manaGain = 310, level = 46, maxLevel = 55 },
        [6] = { spellID = 11689, healthCost = 420, manaGain = 420, level = 56, maxLevel = 67 },
        [7] = { spellID = 27222, healthCost = 582, manaGain = 582, level = 68, maxLevel = 68 },
    },
}

-------------------------------------------------------------------------------
-- AoE Spells
-------------------------------------------------------------------------------

-- Seed of Corruption: detonation direct damage on detonation trigger.
-- Wowhead detonation SP mod 0.214 (spell 27285 is the detonation effect).
-- The 18s background DoT is a separate effect; not modeled here.
-- Source (parent): https://www.wowhead.com/tbc/spell=27243
-- Source (detonation): https://www.wowhead.com/tbc/spell=27285
SpellData[27243] = {
    name = "Seed of Corruption",
    school = SCHOOL_SHADOW,
    coefficient = 0.214,
    castTime = 2.0,
    canCrit = false,
    isDot = false,
    isChanneled = false,
    isAoe = true,
    spellType = "direct",
    detonationThreshold = 1044,
    ranks = {
        [1] = { spellID = 27243, minDmg = 1110, maxDmg = 1290, level = 70, maxLevel = 70 },
    },
}

-- Shadowfury: instant AoE direct shadow damage. Wowhead SP mod 0.193.
-- Source: https://www.wowhead.com/tbc/spell=30414
SpellData[30283] = {
    name = "Shadowfury",
    school = SCHOOL_SHADOW,
    coefficient = 0.193,
    castTime = 0.5,
    canCrit = true,
    isDot = false,
    isChanneled = false,
    isAoe = true,
    spellType = "direct",
    ranks = {
        [1] = { spellID = 30283, minDmg = 343, maxDmg = 407, level = 50, maxLevel = 59 },
        [2] = { spellID = 30413, minDmg = 459, maxDmg = 547, level = 60, maxLevel = 69 },
        [3] = { spellID = 30414, minDmg = 612, maxDmg = 728, level = 70, maxLevel = 70 },
    },
}

-------------------------------------------------------------------------------
-- Dark Pact (Rank 1-4): Instant, Shadow, Utility (drains pet mana → player mana)
-------------------------------------------------------------------------------
SpellData[18220] = {
    name = "Dark Pact",
    school = SCHOOL_SHADOW,
    coefficient = 0.96,
    castTime = 0,
    canCrit = false,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "utility",
    ranks = {
        [1] = { spellID = 18220, manaGain = 150, level = 40, maxLevel = 47 },
        [2] = { spellID = 18905, manaGain = 200, level = 48, maxLevel = 55 },
        [3] = { spellID = 18906, manaGain = 250, level = 56, maxLevel = 63 },
        [4] = { spellID = 27265, manaGain = 300, level = 64, maxLevel = 64 },
    },
}

-------------------------------------------------------------------------------
-- Health Funnel (Rank 1-8): 10s Channel, Shadow, Heals pet
-------------------------------------------------------------------------------
SpellData[755] = {
    name = "Health Funnel",
    school = SCHOOL_SHADOW,
    coefficient = 0.548,
    castTime = 10,
    duration = 10,
    numTicks = 10,
    canCrit = false,
    isDot = false,
    isChanneled = true,
    isAoe = false,
    spellType = "channel",
    outputType = "healing",
    noMiss = true,
    ranks = {
        [1] = { spellID = 755,   totalDmg = 120,  level = 12, maxLevel = 19 },
        [2] = { spellID = 3698,  totalDmg = 240,  level = 20, maxLevel = 27 },
        [3] = { spellID = 3699,  totalDmg = 400,  level = 28, maxLevel = 35 },
        [4] = { spellID = 3700,  totalDmg = 600,  level = 36, maxLevel = 43 },
        [5] = { spellID = 11693, totalDmg = 800,  level = 44, maxLevel = 51 },
        [6] = { spellID = 11694, totalDmg = 1140, level = 52, maxLevel = 59 },
        [7] = { spellID = 11695, totalDmg = 1440, level = 60, maxLevel = 67 },
        [8] = { spellID = 27259, totalDmg = 1880, level = 68, maxLevel = 68 },
    },
}

-------------------------------------------------------------------------------
-- Shadow Ward (Rank 1-4): Instant, Shadow, Absorbs shadow damage
-------------------------------------------------------------------------------
SpellData[6229] = {
    name = "Shadow Ward",
    school = SCHOOL_SHADOW,
    coefficient = 0.30,
    castTime = 0,
    canCrit = false,
    isDot = false,
    isChanneled = false,
    isAoe = false,
    spellType = "direct",
    outputType = "absorption",
    noMiss = true,
    ranks = {
        [1] = { spellID = 6229,  minDmg = 290, maxDmg = 290, level = 32, maxLevel = 41 },
        [2] = { spellID = 11739, minDmg = 470, maxDmg = 470, level = 42, maxLevel = 51 },
        [3] = { spellID = 11740, minDmg = 675, maxDmg = 675, level = 52, maxLevel = 61 },
        [4] = { spellID = 28610, minDmg = 875, maxDmg = 875, level = 62, maxLevel = 62 },
    },
}

for spellID, data in pairs(SpellData) do
    ns.SpellData[spellID] = data
end
