-------------------------------------------------------------------------------
-- TalentMap_Mage
-- Mage talent modifier definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.TalentMap = ns.TalentMap or {}

local SCHOOL_FIRE = 4
local SCHOOL_FROST = 16
local SCHOOL_ARCANE = 64
local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Arcane
-------------------------------------------------------------------------------

-- Arcane Focus: +2% Arcane hit per rank
TalentMap["1:3"] = {
    name = "Arcane Focus",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true, filter = { school = SCHOOL_ARCANE } },
    },
}

-- Arcane Impact: +2% crit per rank to Arcane Explosion and Arcane Blast
TalentMap["1:7"] = {
    name = "Arcane Impact",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Arcane Explosion", "Arcane Blast" } } },
    },
}

-- Arcane Instability: +1% damage AND +1% crit per rank to all spells
TalentMap["1:14"] = {
    name = "Arcane Instability",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Empowered Arcane Missiles: +0.75 total SP coefficient per rank (+0.15 per wave × 5 waves)
TalentMap["1:20"] = {
    name = "Empowered Arcane Missiles",
    maxRank = 3,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.75, perRank = true,
          filter = { spellNames = { "Arcane Missiles" } } },
    },
}

-- Spell Power: +25% crit damage bonus per rank (0.125 of the base 50% bonus)
TalentMap["1:23"] = {
    name = "Spell Power",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.125, perRank = true },
    },
}

-------------------------------------------------------------------------------
-- Fire
-------------------------------------------------------------------------------

-- Improved Fireball: -0.1s cast time per rank
TalentMap["2:4"] = {
    name = "Improved Fireball",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = { "Fireball" } } },
    },
}

-- Improved Flamestrike: +5% crit per rank to Flamestrike
TalentMap["2:9"] = {
    name = "Improved Flamestrike",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.05, perRank = true,
          filter = { spellNames = { "Flamestrike" } } },
    },
}

-- Critical Mass: +2% crit per rank to Fire spells
TalentMap["2:11"] = {
    name = "Critical Mass",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true, filter = { school = SCHOOL_FIRE } },
    },
}

-- Fire Power: +2% Fire damage per rank (additive with other talent bonuses)
TalentMap["2:13"] = {
    name = "Fire Power",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true,
          stacking = "additive", filter = { school = SCHOOL_FIRE } },
    },
}

-- Incineration: +2% crit per rank to Fire Blast and Scorch
TalentMap["2:15"] = {
    name = "Incineration",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Fire Blast", "Scorch" } } },
    },
}

-- Playing with Fire: +1% all damage per rank (additive)
TalentMap["2:17"] = {
    name = "Playing with Fire",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
    },
}

-- Molten Fury: +10% damage per rank to targets below 20% HP
TalentMap["2:19"] = {
    name = "Molten Fury",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true,
          filter = { targetHealthBelow = 20 } },
    },
}

-- Pyromaniac: +1% crit per rank to Fire spells
TalentMap["2:20"] = {
    name = "Pyromaniac",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true, filter = { school = SCHOOL_FIRE } },
    },
}

-- Empowered Fireball: +3% SP coefficient per rank to Fireball
TalentMap["2:21"] = {
    name = "Empowered Fireball",
    maxRank = 5,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.03, perRank = true,
          filter = { spellNames = { "Fireball" } } },
    },
}

-------------------------------------------------------------------------------
-- Frost
-------------------------------------------------------------------------------

-- Improved Frostbolt: -0.1s cast time per rank
TalentMap["3:1"] = {
    name = "Improved Frostbolt",
    maxRank = 5,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.1, perRank = true,
          filter = { spellNames = { "Frostbolt" } } },
    },
}

-- Piercing Ice: +2% Frost damage per rank (additive)
TalentMap["3:3"] = {
    name = "Piercing Ice",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true,
          stacking = "additive", filter = { school = SCHOOL_FROST } },
    },
}

-- Improved Cone of Cold: 15/25/35% damage bonus (non-linear — use table value)
TalentMap["3:6"] = {
    name = "Improved Cone of Cold",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = { 0.15, 0.25, 0.35 },
          filter = { spellNames = { "Cone of Cold" } } },
    },
}

-- Ice Shards: +20% crit damage bonus per rank to Frost (0.10 of base 50% bonus)
TalentMap["3:15"] = {
    name = "Ice Shards",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.10, perRank = true, filter = { school = SCHOOL_FROST } },
    },
}

-- Elemental Precision: +1% hit per rank to Fire and Frost
TalentMap["3:17"] = {
    name = "Elemental Precision",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true,
          filter = { schools = { SCHOOL_FIRE, SCHOOL_FROST } } },
    },
}

-- Arctic Winds: +1% Frost damage per rank (additive)
TalentMap["3:20"] = {
    name = "Arctic Winds",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true,
          stacking = "additive", filter = { school = SCHOOL_FROST } },
    },
}

-- Empowered Frostbolt: +2% SP coefficient AND +1% crit per rank to Frostbolt
TalentMap["3:21"] = {
    name = "Empowered Frostbolt",
    maxRank = 5,
    effects = {
        { type = MOD.COEFFICIENT_BONUS, value = 0.02, perRank = true,
          filter = { spellNames = { "Frostbolt" } } },
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true,
          filter = { spellNames = { "Frostbolt" } } },
    },
}

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["MAGE:" .. key] = data
end
