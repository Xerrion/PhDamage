-------------------------------------------------------------------------------
-- AuraMap_Warlock.lua
-- Warlock-relevant buff and debuff effects mapped to modifier descriptors
-- SpellIDs sourced from Wowhead TBC Classic
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local SCHOOL_FIRE = ns.SCHOOL_FIRE
local SCHOOL_SHADOW = ns.SCHOOL_SHADOW
local SCHOOL_ARCANE = ns.SCHOOL_ARCANE
local SCHOOL_FROST = ns.SCHOOL_FROST
local MOD = ns.MOD

local AuraMap = {}

-------------------------------------------------------------------------------
-- Player Buffs (target = "player")
-------------------------------------------------------------------------------

-- Shadow Trance / Nightfall proc: Shadow Bolt becomes instant cast
AuraMap[17941] = {
    name = "Shadow Trance",
    target = "player",
    effects = {
        { type = MOD.CAST_TIME_OVERRIDE, value = 0,
          filter = { spellNames = {"Shadow Bolt"} } },
    },
}

-- Fel Armor Rank 1: +50 spell damage (already reflected in GetSpellBonusDamage())
AuraMap[28176] = {
    name = "Fel Armor",
    target = "player",
    alreadyInStats = true,
    -- effects listed for documentation; not applied at runtime due to alreadyInStats = true
    effects = {
        { type = MOD.SPELL_POWER_BONUS, value = 50 },
    },
}

-- Fel Armor Rank 2: +100 spell damage (already reflected in GetSpellBonusDamage())
AuraMap[28189] = {
    name = "Fel Armor",
    target = "player",
    alreadyInStats = true,
    -- effects listed for documentation; not applied at runtime due to alreadyInStats = true
    effects = {
        { type = MOD.SPELL_POWER_BONUS, value = 100 },
    },
}

-- Demonic Sacrifice: Burning Wish (sacrificed Imp) — +15% Fire damage
AuraMap[18789] = {
    name = "Burning Wish",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.15,
          filter = { school = SCHOOL_FIRE } },
    },
}

-- Demonic Sacrifice: Touch of Shadow (sacrificed Succubus) — +15% Shadow damage
AuraMap[18791] = {
    name = "Touch of Shadow",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.15,
          filter = { school = SCHOOL_SHADOW } },
    },
}

-- Demonic Sacrifice: Fel Stamina (18790) — +15% Health regen. Skipped (not damage).
-- Demonic Sacrifice: Fel Energy (18792) — +2% mana regen. Skipped (not damage).

-- Backlash proc: next Shadow Bolt or Incinerate is instant cast and +3% crit
AuraMap[34936] = {
    name = "Backlash",
    target = "player",
    effects = {
        { type = MOD.CAST_TIME_OVERRIDE, value = 0,
          filter = { spellNames = {"Shadow Bolt", "Incinerate"} } },
        { type = MOD.CRIT_BONUS, value = 0.03,
          filter = { spellNames = {"Shadow Bolt", "Incinerate"} } },
    },
}

-------------------------------------------------------------------------------
-- Target Debuffs (target = "target")
-------------------------------------------------------------------------------

-- Improved Shadow Bolt / Shadow Vulnerability: target takes +20% Shadow damage
-- Phase 1 simplification: assumes 5 stacks when debuff is present
AuraMap[17800] = {
    name = "Shadow Vulnerability",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.20,
          filter = { school = SCHOOL_SHADOW } },
    },
}

-- Shadow Vulnerability (alternate spellID seen in some builds)
AuraMap[17803] = {
    name = "Shadow Vulnerability",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.20,
          filter = { school = SCHOOL_SHADOW } },
    },
}

-- Curse of the Elements Rank 3: +8% Fire/Frost/Arcane/Shadow damage, -75 resistances
AuraMap[11722] = {
    name = "Curse of the Elements",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.08,
          filter = { schools = {SCHOOL_FIRE, SCHOOL_SHADOW, SCHOOL_ARCANE,
                                SCHOOL_FROST} } },
    },
    talentAmplify = {
        talentKey = "1:19",
        perRank = 0.01,
        effectType = MOD.DAMAGE_MULTIPLIER,
    },
}

-- Curse of the Elements Rank 4 (max in TBC): +10% Fire/Frost/Arcane/Shadow damage,
-- -88 resistances
AuraMap[27228] = {
    name = "Curse of the Elements",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10,
          filter = { schools = {SCHOOL_FIRE, SCHOOL_SHADOW, SCHOOL_ARCANE,
                                SCHOOL_FROST} } },
    },
    talentAmplify = {
        talentKey = "1:19",
        perRank = 0.01,
        effectType = MOD.DAMAGE_MULTIPLIER,
    },
}

-- Curse of Shadow Rank 1: +8% Shadow and Arcane damage, -75 resistances
AuraMap[17937] = {
    name = "Curse of Shadow",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.08,
          filter = { schools = {SCHOOL_SHADOW, SCHOOL_ARCANE} } },
    },
    talentAmplify = {
        talentKey = "1:19",
        perRank = 0.01,
        effectType = MOD.DAMAGE_MULTIPLIER,
    },
}

-- Curse of Shadow Rank 2: +10% Shadow and Arcane damage, -88 resistances
AuraMap[32862] = {
    name = "Curse of Shadow",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10,
          filter = { schools = {SCHOOL_SHADOW, SCHOOL_ARCANE} } },
    },
    talentAmplify = {
        talentKey = "1:19",
        perRank = 0.01,
        effectType = MOD.DAMAGE_MULTIPLIER,
    },
}

-- Immolate (max rank, TBC): Incinerate bonus damage when target has Immolate
-- Incinerate gains ~111-128 bonus damage (R2) when Immolate is on the target — averaged
AuraMap[27215] = {
    name = "Immolate",
    target = "target",
    effects = {
        { type = MOD.FLAT_DAMAGE_BONUS, value = 120,
          filter = { spellNames = {"Incinerate"} } },
    },
}

-------------------------------------------------------------------------------
-- Common Non-Warlock Debuffs (that affect Warlock damage)
-------------------------------------------------------------------------------

-- Misery (Shadow Priest talent, max rank): target takes +5% spell damage from all schools
-- TBC: 5 ranks — +1/2/3/4/5% spell damage taken
AuraMap[33198] = {
    name = "Misery",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05 },
    },
}

-- Shadow Weaving (Shadow Priest, 5 stacks): target takes +10% Shadow damage
-- Phase 1 simplification: assumes 5 stacks when debuff is present
AuraMap[15258] = {
    name = "Shadow Weaving",
    target = "target",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10,
          filter = { school = SCHOOL_SHADOW } },
    },
}

for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
