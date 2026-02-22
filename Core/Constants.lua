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

-------------------------------------------------------------------------------
-- GCD and Cast Time
-------------------------------------------------------------------------------
ns.GLOBAL_COOLDOWN = 1.5

-------------------------------------------------------------------------------
-- Combat Rating IDs (for GetCombatRatingBonus)
-------------------------------------------------------------------------------
ns.CR_HIT_SPELL    = 8
ns.CR_HIT_RANGED   = 7
ns.CR_HASTE_SPELL  = 20
ns.CR_HASTE_RANGED = 19

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
