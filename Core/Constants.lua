-------------------------------------------------------------------------------
-- Constants.lua
-- Immutable reference data: spell schools, combat ratings, modifier types
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Spell Schools (bitmask values matching WoW API)
-------------------------------------------------------------------------------
ns.SCHOOL_PHYSICAL = 1
ns.SCHOOL_HOLY     = 2
ns.SCHOOL_FIRE     = 4
ns.SCHOOL_NATURE   = 8
ns.SCHOOL_FROST    = 16
ns.SCHOOL_SHADOW   = 32
ns.SCHOOL_ARCANE   = 64

-- Ordered list of magic schools (for iteration)
ns.MAGIC_SCHOOLS = {
    ns.SCHOOL_HOLY,
    ns.SCHOOL_FIRE,
    ns.SCHOOL_NATURE,
    ns.SCHOOL_FROST,
    ns.SCHOOL_SHADOW,
    ns.SCHOOL_ARCANE,
}

-- Human-readable names for schools
ns.SCHOOL_NAMES = {
    [ns.SCHOOL_PHYSICAL] = "Physical",
    [ns.SCHOOL_HOLY]     = "Holy",
    [ns.SCHOOL_FIRE]     = "Fire",
    [ns.SCHOOL_NATURE]   = "Nature",
    [ns.SCHOOL_FROST]    = "Frost",
    [ns.SCHOOL_SHADOW]   = "Shadow",
    [ns.SCHOOL_ARCANE]   = "Arcane",
}

-------------------------------------------------------------------------------
-- Base Crit Multiplier
-- Spells deal 150% damage on crit by default (1.5x multiplier)
-------------------------------------------------------------------------------
ns.BASE_CRIT_MULTIPLIER = 1.5

-------------------------------------------------------------------------------
-- Base Melee Crit Multiplier
-- Melee abilities deal 200% damage on crit by default (2.0x multiplier)
-------------------------------------------------------------------------------
ns.BASE_MELEE_CRIT_MULTIPLIER = 2.0

-------------------------------------------------------------------------------
-- Hit Caps
-- TBC boss (level 73 target vs level 70 caster) = 17% miss for spells
-- Heroic mob (level 72) = 6%, same level = 4%
-------------------------------------------------------------------------------
ns.BASE_SPELL_MISS_RATE = 0.17   -- vs boss
ns.MAX_SPELL_HIT = 0.99          -- cap (1% resist always remains)

-- Physical/ranged hit caps
-- TBC boss (level 73 target vs level 70 attacker) = 9% miss for physical/ranged
ns.BASE_RANGED_MISS_RATE = 0.09   -- vs boss
ns.MAX_RANGED_HIT = 1.00          -- physical can reach 100% hit

-- Melee combat constants (TBC values vs +3 level boss)
ns.BASE_MELEE_MISS_RATE = 0.08      -- 8% yellow miss rate
ns.MAX_MELEE_HIT = 1.00
ns.BOSS_DODGE_RATE = 0.065           -- 6.5% dodge
ns.BOSS_PARRY_RATE = 0.14            -- 14% parry (0 from behind)
ns.EXPERTISE_PER_PERCENT = 4.0       -- 4 expertise = 1% dodge/parry reduction

-- Normalized weapon speeds
ns.NORMALIZED_WEAPON_SPEED = {
    TWO_HAND = 3.3,
    ONE_HAND = 2.4,
    DAGGER = 1.7,
    FIST = 2.4,
}

-------------------------------------------------------------------------------
-- GCD and Cast Time
-------------------------------------------------------------------------------
ns.GLOBAL_COOLDOWN = 1.5

-------------------------------------------------------------------------------
-- Combat Rating IDs (for GetCombatRatingBonus)
-------------------------------------------------------------------------------
ns.CR_HIT_SPELL    = 8
ns.CR_HIT_RANGED   = 7
ns.CR_HIT_MELEE    = 6
ns.CR_HASTE_SPELL  = 20
ns.CR_HASTE_RANGED = 19
ns.CR_HASTE_MELEE  = 18

-------------------------------------------------------------------------------
-- Modifier Effect Types (used by TalentMap and AuraMap descriptors)
-------------------------------------------------------------------------------
ns.MOD = {
    DAMAGE_MULTIPLIER    = "damageMultiplier",
    COEFFICIENT_BONUS    = "coefficientBonus",
    CRIT_BONUS           = "critBonus",
    CRIT_MULT_BONUS      = "critMultBonus",
    CAST_TIME_REDUCTION  = "castTimeReduction",
    CAST_TIME_OVERRIDE   = "castTimeOverride",
    SPELL_HIT_BONUS      = "spellHitBonus",
    FLAT_DAMAGE_BONUS    = "flatDamageBonus",
    DOT_DAMAGE_MULTIPLIER = "dotDamageMultiplier",
    DIRECT_DAMAGE_MULTIPLIER = "directDamageMultiplier",
    SPELL_POWER_BONUS    = "spellPowerBonus",
}

-------------------------------------------------------------------------------
-- Scaling Types (how spells scale with player stats)
-------------------------------------------------------------------------------
ns.SCALING_TYPE = {
    SPELL  = "spell",   -- default: scales with spell power
    RANGED = "ranged",  -- scales with ranged attack power
    MELEE  = "melee",   -- scales with melee attack power
}

-------------------------------------------------------------------------------
-- Spell Types (for filtering in modifiers)
-- NOTE: Not yet referenced by SpellData; kept for future use when spell data
-- migrates from raw strings to typed constants.
-------------------------------------------------------------------------------
ns.SPELL_TYPE = {
    DIRECT    = "direct",
    DOT       = "dot",
    HYBRID    = "hybrid",
    CHANNEL   = "channel",
    UTILITY   = "utility",
}
