-------------------------------------------------------------------------------
-- SpellData_Paladin
-- Paladin spell coefficients and rank data for TBC Anniversary
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.SpellData = ns.SpellData or {}

local SCHOOL_HOLY = ns.SCHOOL_HOLY

local SpellData = {}

-------------------------------------------------------------------------------
-- Healing Spells
-------------------------------------------------------------------------------

-- Holy Light — 2.5s cast, Holy, direct heal
-- Coefficient: 0.714
SpellData[635] = {
    name = "Holy Light",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.714,
    castTime = 2.5,
    canCrit = true,
    isHeal = true,
    ranks = {
        [1]  = { spellID = 635,   minDmg = 42,   maxDmg = 51,   level = 1  },
        [2]  = { spellID = 639,   minDmg = 81,   maxDmg = 96,   level = 6  },
        [3]  = { spellID = 647,   minDmg = 167,  maxDmg = 196,  level = 14 },
        [4]  = { spellID = 1026,  minDmg = 322,  maxDmg = 368,  level = 22 },
        [5]  = { spellID = 1042,  minDmg = 506,  maxDmg = 569,  level = 30 },
        [6]  = { spellID = 3472,  minDmg = 717,  maxDmg = 799,  level = 38 },
        [7]  = { spellID = 10328, minDmg = 968,  maxDmg = 1076, level = 46 },
        [8]  = { spellID = 10329, minDmg = 1272, maxDmg = 1414, level = 54 },
        [9]  = { spellID = 25292, minDmg = 1619, maxDmg = 1799, level = 60 },
        [10] = { spellID = 27135, minDmg = 1773, maxDmg = 1971, level = 62 },
        [11] = { spellID = 27136, minDmg = 2196, maxDmg = 2446, level = 70 },
    },
}

-- Flash of Light — 1.5s cast, Holy, direct heal
-- Coefficient: 0.429
SpellData[19750] = {
    name = "Flash of Light",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 1.5,
    canCrit = true,
    isHeal = true,
    ranks = {
        [1] = { spellID = 19750, minDmg = 67,  maxDmg = 77,  level = 20 },
        [2] = { spellID = 19939, minDmg = 102, maxDmg = 117, level = 26 },
        [3] = { spellID = 19940, minDmg = 153, maxDmg = 171, level = 34 },
        [4] = { spellID = 19941, minDmg = 206, maxDmg = 231, level = 42 },
        [5] = { spellID = 19942, minDmg = 278, maxDmg = 310, level = 50 },
        [6] = { spellID = 19943, minDmg = 356, maxDmg = 396, level = 58 },
        [7] = { spellID = 27137, minDmg = 458, maxDmg = 513, level = 66 },
    },
}

-- Holy Shock (Heal) uses a synthetic base ID (200473) to differentiate from the damage variant (20473).
-- The actual rank spell IDs are the same; only the heal values differ.
SpellData[200473] = {
    name = "Holy Shock",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 0,
    canCrit = true,
    isHeal = true,
    ranks = {
        [1] = { spellID = 20473, minDmg = 351, maxDmg = 379, level = 40 },
        [2] = { spellID = 20929, minDmg = 480, maxDmg = 518, level = 48 },
        [3] = { spellID = 20930, minDmg = 628, maxDmg = 680, level = 56 },
        [4] = { spellID = 27174, minDmg = 777, maxDmg = 841, level = 64 },
        [5] = { spellID = 33072, minDmg = 913, maxDmg = 987, level = 70 },
    },
}

-------------------------------------------------------------------------------
-- Holy Damage Spells
-------------------------------------------------------------------------------

-- Consecration — instant cast, Holy, AoE ground DoT
-- Coefficient: 0.119 per tick (0.952 total), 8s duration, 8 ticks
SpellData[26573] = {
    name = "Consecration",
    school = SCHOOL_HOLY,
    spellType = "dot",
    coefficient = 0.119,
    castTime = 0,
    canCrit = false,
    numTicks = 8,
    duration = 8,
    ranks = {
        [1] = { spellID = 26573, totalDmg = 64,  level = 20 },
        [2] = { spellID = 20116, totalDmg = 120, level = 30 },
        [3] = { spellID = 20922, totalDmg = 192, level = 40 },
        [4] = { spellID = 20923, totalDmg = 280, level = 50 },
        [5] = { spellID = 20924, totalDmg = 384, level = 60 },
        [6] = { spellID = 27173, totalDmg = 512, level = 70 },
    },
}

-- Exorcism — 1.5s cast, Holy, direct
-- Coefficient: 0.429
SpellData[879] = {
    name = "Exorcism",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 1.5,
    canCrit = true,
    ranks = {
        [1] = { spellID = 879,   minDmg = 90,  maxDmg = 102, level = 20 },
        [2] = { spellID = 5614,  minDmg = 160, maxDmg = 180, level = 28 },
        [3] = { spellID = 5615,  minDmg = 227, maxDmg = 255, level = 36 },
        [4] = { spellID = 10312, minDmg = 316, maxDmg = 354, level = 44 },
        [5] = { spellID = 10313, minDmg = 407, maxDmg = 453, level = 52 },
        [6] = { spellID = 10314, minDmg = 521, maxDmg = 579, level = 60 },
        [7] = { spellID = 27138, minDmg = 626, maxDmg = 698, level = 68 },
    },
}

-- Hammer of Wrath — instant cast, Holy, direct
-- Coefficient: 0.429
SpellData[24275] = {
    name = "Hammer of Wrath",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 24275, minDmg = 316, maxDmg = 348, level = 44 },
        [2] = { spellID = 24274, minDmg = 412, maxDmg = 455, level = 52 },
        [3] = { spellID = 24239, minDmg = 519, maxDmg = 572, level = 60 },
        [4] = { spellID = 27180, minDmg = 672, maxDmg = 742, level = 68 },
    },
}

-- Holy Wrath — 2.0s cast, Holy, direct
-- Coefficient: 0.286
SpellData[2812] = {
    name = "Holy Wrath",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.286,
    castTime = 2.0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 2812,  minDmg = 368, maxDmg = 435, level = 50 },
        [2] = { spellID = 10318, minDmg = 497, maxDmg = 584, level = 60 },
        [3] = { spellID = 27139, minDmg = 637, maxDmg = 748, level = 69 },
    },
}

-- Holy Shock (Damage) — instant cast, Holy, direct
-- Coefficient: 0.429
SpellData[20473] = {
    name = "Holy Shock",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.429,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 20473, minDmg = 277, maxDmg = 299, level = 40 },
        [2] = { spellID = 20929, minDmg = 379, maxDmg = 409, level = 48 },
        [3] = { spellID = 20930, minDmg = 496, maxDmg = 536, level = 56 },
        [4] = { spellID = 27174, minDmg = 614, maxDmg = 664, level = 64 },
        [5] = { spellID = 33072, minDmg = 721, maxDmg = 779, level = 70 },
    },
}

-- TODO: Avenger's Shield also scales with ~0.07 AP coefficient, but the engine
-- does not currently support apCoefficient on non-melee direct spells.
SpellData[31935] = {
    name = "Avenger's Shield",
    school = SCHOOL_HOLY,
    spellType = "direct",
    coefficient = 0.07,
    castTime = 0,
    canCrit = true,
    ranks = {
        [1] = { spellID = 31935, minDmg = 270, maxDmg = 330, level = 50 },
        [2] = { spellID = 32699, minDmg = 370, maxDmg = 452, level = 60 },
        [3] = { spellID = 32700, minDmg = 494, maxDmg = 602, level = 70 },
    },
}

-- Merge into addon namespace
for baseID, data in pairs(SpellData) do
    ns.SpellData[baseID] = data
end
