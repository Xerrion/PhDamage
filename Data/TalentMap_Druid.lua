local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- TalentMap_Druid.lua
-- Druid talent effects mapped to modifier descriptors for TBC Anniversary
-- Talent positions (tab:index) verified in-game on TBC Anniversary
-- (ordered by internal talentID)
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

ns.TalentMap = ns.TalentMap or {}

local MOD = ns.MOD
local SCHOOL_PHYSICAL = ns.SCHOOL_PHYSICAL

local TalentMap = {}

-------------------------------------------------------------------------------
-- Balance (Tab 1)
-- 1:1  Nature's Grasp (1)                 1:2  Starlight Wrath (5)
-- 1:3  Improved Moonfire (2)              1:4  Nature's Reach (2)
-- 1:5  Brambles (3)                       1:6  Moonglow (3)
-- 1:7  Celestial Focus (3)                1:8  Control of Nature (3)
-- 1:9  Insect Swarm (1)                   1:10 Nature's Grace (1)
-- 1:11 Moonfury (5)                       1:12 Vengeance (5)
-- 1:13 Moonkin Form (1)                   1:14 Improved Nature's Grasp (4)
-- 1:15 Lunar Guidance (3)                 1:16 Balance of Power (2)
-- 1:17 Dreamstate (3)                     1:18 Improved Faerie Fire (3)
-- 1:19 Wrath of Cenarius (5)              1:20 Force of Nature (1)
-- 1:21 Focused Starlight (2)
-------------------------------------------------------------------------------

-- Starlight Wrath: -0.1s cast time on Wrath and Starfire per rank
TalentMap["1:2"] = {
    name = "Starlight Wrath",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = { "Wrath", "Starfire" } } },
    },
}

-- Improved Moonfire: +5% Moonfire damage and +5% Moonfire crit per rank
TalentMap["1:3"] = {
    name = "Improved Moonfire",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05, perRank = true,
          filter = { spellNames = { "Moonfire" } } },
        { type = MOD.CRIT_BONUS, value = 0.05, perRank = true,
          filter = { spellNames = { "Moonfire" } } },
    },
}

-- Brambles: +25% Entangling Roots damage per rank
TalentMap["1:5"] = {
    name = "Brambles",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.25, perRank = true, stacking = "additive",
          filter = { spellNames = { "Entangling Roots" } } },
    },
}

-- Moonfury: +2% Starfire/Moonfire/Wrath damage per rank
TalentMap["1:11"] = {
    name = "Moonfury",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { spellNames = { "Starfire", "Moonfire", "Wrath" } } },
    },
}

-- Vengeance: +10/20/30/40/50% crit damage bonus (non-linear scaling)
TalentMap["1:12"] = {
    name = "Vengeance",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = { 0.10, 0.20, 0.30, 0.40, 0.50 } },
    },
}

-- Lunar Guidance: 8/16/25% of Intellect added as spell power (non-linear)
TalentMap["1:15"] = {
    name = "Lunar Guidance",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_POWER_BONUS, value = { 0.08, 0.16, 0.25 }, statField = "intellect" },
    },
}

-- Balance of Power: +2% spell hit per rank
TalentMap["1:16"] = {
    name = "Balance of Power",
    maxRank = 2,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true },
    },
}

-- Wrath of Cenarius: +4% Starfire coeff and +2% Wrath coeff per rank
TalentMap["1:19"] = {
    name = "Wrath of Cenarius",
    maxRank = 5,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.04, perRank = true,
          filter = { spellNames = { "Starfire" } } },
        { type = MOD.COEFFICIENT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Wrath" } } },
    },
}

-- Focused Starlight: +2% crit chance on Wrath and Starfire per rank
TalentMap["1:21"] = {
    name = "Focused Starlight",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Wrath", "Starfire" } } },
    },
}

-------------------------------------------------------------------------------
-- Feral Combat (Tab 2)
-- 2:1  Thick Hide (3)                     2:2  Feral Aggression (5)
-- 2:3  Ferocity (5)                       2:4  Brutal Impact (2)
-- 2:5  Sharpened Claws (3)                2:6  Feral Instinct (3)
-- 2:7  Primal Fury (2)                    2:8  Shredding Attacks (2)
-- 2:9  Predatory Strikes (3)              2:10 Feral Charge (1)
-- 2:11 Savage Fury (2)                    2:12 Feral Swiftness (2)
-- 2:13 Heart of the Wild (5)              2:14 Leader of the Pack (1)
-- 2:15 Faerie Fire (Feral) (1)            2:16 Nurturing Instinct (2)
-- 2:17 Primal Tenacity (3)                2:18 Survival of the Fittest (3)
-- 2:19 Predatory Instincts (5)            2:20 Mangle (1)
-- 2:21 Improved Leader of the Pack (2)
-------------------------------------------------------------------------------

-- Sharpened Claws: +2% melee crit per rank (feral abilities)
TalentMap["2:5"] = {
    name = "Sharpened Claws",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Claw", "Shred", "Mangle (Cat)", "Rake", "Ferocious Bite", "Rip",
                                    "Maul", "Swipe", "Mangle (Bear)", "Lacerate" } } },
    },
}

-- Savage Fury: +10% Claw/Rake/Mangle (Cat) damage per rank
TalentMap["2:11"] = {
    name = "Savage Fury",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { spellNames = { "Claw", "Rake", "Mangle (Cat)" } } },
    },
}

-- Predatory Instincts: +3/6/10/13/16% melee crit damage (non-linear, cat abilities)
TalentMap["2:19"] = {
    name = "Predatory Instincts",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = { 0.03, 0.06, 0.10, 0.13, 0.16 },
          filter = { spellNames = { "Claw", "Shred", "Mangle (Cat)", "Rake", "Ferocious Bite", "Rip" } } },
    },
}

-------------------------------------------------------------------------------
-- Restoration (Tab 3)
-- 3:1  Improved Mark of the Wild (5)      3:2  Furor (5)
-- 3:3  Nature's Focus (5)                 3:4  Naturalist (5)
-- 3:5  Improved Regrowth (5)              3:6  Natural Shapeshifter (3)
-- 3:7  Omen of Clarity (1)                3:8  Gift of Nature (5)
-- 3:9  Intensity (3)                      3:10 Improved Rejuvenation (3)
-- 3:11 Nature's Swiftness (1)             3:12 Subtlety (5)
-- 3:13 Improved Tranquility (2)           3:14 Tranquil Spirit (5)
-- 3:15 Swiftmend (1)                      3:16 Empowered Touch (2)
-- 3:17 Empowered Rejuvenation (5)         3:18 Natural Perfection (3)
-- 3:19 Tree of Life (1)                   3:20 Living Spirit (3)
-------------------------------------------------------------------------------

-- Naturalist: -0.1s Healing Touch cast time and +2% physical damage per rank
TalentMap["3:4"] = {
    name = "Naturalist",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = { "Healing Touch" } } },
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { school = SCHOOL_PHYSICAL } },
    },
}

-- Improved Regrowth: +10% Regrowth crit chance per rank
TalentMap["3:5"] = {
    name = "Improved Regrowth",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.10, perRank = true,
          filter = { spellNames = { "Regrowth" } } },
    },
}

-- Gift of Nature: +2% healing spell effectiveness per rank
TalentMap["3:8"] = {
    name = "Gift of Nature",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { spellNames = { "Healing Touch", "Rejuvenation", "Regrowth", "Lifebloom",
                                    "Tranquility" } } },
    },
}

-- Improved Rejuvenation: +5% Rejuvenation healing per rank
TalentMap["3:10"] = {
    name = "Improved Rejuvenation",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05, perRank = true, stacking = "additive",
          filter = { spellNames = { "Rejuvenation" } } },
    },
}

-- Empowered Touch: +10% Healing Touch spell power coefficient per rank
TalentMap["3:16"] = {
    name = "Empowered Touch",
    maxRank = 2,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.10, perRank = true,
          filter = { spellNames = { "Healing Touch" } } },
    },
}

-- Empowered Rejuvenation: +4% HoT spell power coefficient per rank
TalentMap["3:17"] = {
    name = "Empowered Rejuvenation",
    maxRank = 5,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.04, perRank = true,
          filter = { spellNames = { "Rejuvenation", "Regrowth", "Lifebloom", "Tranquility" } } },
    },
}

-- Natural Perfection: +1% spell crit per rank (all spells)
TalentMap["3:18"] = {
    name = "Natural Perfection",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["DRUID:" .. key] = data
end
