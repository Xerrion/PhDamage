-------------------------------------------------------------------------------
-- TalentMap_Warrior
-- Warrior talent modifier definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.TalentMap = ns.TalentMap or {}

local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Arms (Tab 1)
-------------------------------------------------------------------------------

-- Improved Rend: +25% Rend bleed damage per rank
TalentMap["1:3"] = {
    name = "Improved Rend",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.25, perRank = true, stacking = "additive",
          filter = { spellNames = { "Rend" } } },
    },
}

-- Improved Overpower: +25% Overpower crit chance per rank
TalentMap["1:7"] = {
    name = "Improved Overpower",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.25, perRank = true,
          filter = { spellNames = { "Overpower" } } },
    },
}

-- Deep Wounds: 20% weapon average damage bleed over 12s per rank
-- NOTE: Proc-based (triggers on crit). Damage calculation is complex
-- (based on weapon average damage). Best handled via AuraMap when
-- Deep Wounds buff is active. Included here for completeness as a
-- placeholder — the engine does not yet calculate Deep Wounds ticks.
-- TalentMap["1:9"] — Deep Wounds: deferred to AuraMap

-- Two-Handed Weapon Specialization: +1% damage with 2H weapons per rank
-- TODO: Needs weaponType filter support in MatchesFilter. Currently applies
-- to all abilities regardless of weapon type. This is acceptable for 2H
-- warriors but over-applies for dual-wielders.
TalentMap["1:10"] = {
    name = "Two-Handed Weapon Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
    },
}

-- Impale: +10% crit damage bonus per rank
TalentMap["1:11"] = {
    name = "Impale",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.10, perRank = true },
    },
}

-- Poleaxe Specialization: +1% crit with Axes and Polearms per rank
-- TODO: Needs weaponType filter support in MatchesFilter. Currently applies
-- to all abilities regardless of weapon type.
TalentMap["1:12"] = {
    name = "Poleaxe Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Death Wish: +20% physical damage, active ability (30s duration)
-- NOTE: This is an activated ability, not a passive talent. The damage
-- bonus should be handled via AuraMap when the Death Wish buff is active.
-- TalentMap["1:13"] — Death Wish: deferred to AuraMap

-- Sword Specialization: 1% chance per rank for extra attack on hit
-- NOTE: Proc-based extra attack — cannot be expressed as a simple
-- damage modifier. Would require simulation or proc-rate modeling.
-- TalentMap["1:15"] — Sword Specialization: deferred (proc-based)

-- Mace Specialization: Chance to stun + generate rage per rank
-- NOTE: Proc-based — cannot be expressed as a damage modifier.
-- TalentMap["1:14"] — Mace Specialization: deferred (proc-based)

-- Blood Frenzy: +2% physical damage taken debuff on target per rank
-- NOTE: This is a debuff applied to the target via Rend/Deep Wounds.
-- Should be handled via AuraMap keyed to the Blood Frenzy debuff spellID.
-- TalentMap["1:19"] — Blood Frenzy: deferred to AuraMap

-- Improved Mortal Strike: +1% Mortal Strike damage per rank
TalentMap["1:22"] = {
    name = "Improved Mortal Strike",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { spellNames = { "Mortal Strike" } } },
    },
}

-------------------------------------------------------------------------------
-- Fury (Tab 2)
-------------------------------------------------------------------------------

-- Cruelty: +1% melee crit chance per rank
TalentMap["2:2"] = {
    name = "Cruelty",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Improved Cleave: +40% bonus Cleave damage per rank
TalentMap["2:5"] = {
    name = "Improved Cleave",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.40, perRank = true, stacking = "additive",
          filter = { spellNames = { "Cleave" } } },
    },
}

-- Commanding Presence: +5% Battle Shout AP / Commanding Shout HP per rank
-- NOTE: This modifies buff strength, not direct damage. The increased AP
-- from Battle Shout is already reflected in playerState.stats.attackPower.
-- No TalentMap entry needed — the buff effect is captured by StateCollector.
-- TalentMap["2:8"] — Commanding Presence: handled via stats

-- Dual Wield Specialization: +5% off-hand damage per rank
-- TODO: Needs off-hand vs main-hand differentiation in the engine.
-- Currently the engine does not model OH vs MH separately.
-- TalentMap["2:9"] — Dual Wield Specialization: deferred (OH-specific)

-- Enrage: +5% melee damage for 12s after being crit, per rank
-- NOTE: Proc-based buff triggered by receiving a critical hit.
-- Should be handled via AuraMap when the Enrage buff is active.
-- TalentMap["2:11"] — Enrage: deferred to AuraMap

-- Improved Slam: -0.5s Slam cast time per rank
TalentMap["2:12"] = {
    name = "Improved Slam",
    maxRank = 2,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.5, perRank = true,
          filter = { spellNames = { "Slam" } } },
    },
}

-- Weapon Mastery: -1% chance to be dodged per rank
-- NOTE: This reduces the target's effective dodge rate against the warrior.
-- Functionally similar to hit bonus but specifically reduces dodge.
-- Using SPELL_HIT_BONUS as the universal hit accumulator (same as
-- Hunter's Surefooted) since the engine treats all hit bonuses uniformly.
-- The dodge reduction is mechanically different from hit rating but has
-- the same net effect on damage expectation calculations.
TalentMap["2:14"] = {
    name = "Weapon Mastery",
    maxRank = 2,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Flurry: +5% attack speed for 3 swings after crit, per rank
-- NOTE: Proc-based buff with charge consumption. Cannot be expressed
-- as a simple modifier — requires proc modeling or AuraMap.
-- TalentMap["2:16"] — Flurry: deferred to AuraMap

-- Precision: +1% melee hit per rank
TalentMap["2:17"] = {
    name = "Precision",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Improved Whirlwind: -1s Whirlwind cooldown per rank
-- NOTE: Cooldown reduction does not affect per-hit damage, only DPS
-- throughput. The current engine computes per-hit damage, not DPS.
-- No MOD type for cooldown reduction exists. Included as a comment
-- for future DPS modeling.
-- TalentMap["2:19"] — Improved Whirlwind: deferred (cooldown reduction)

-- Improved Berserker Stance: +2% AP in Berserker Stance per rank
-- NOTE: The AP bonus is stance-dependent and should be reflected in
-- playerState.stats.attackPower when in Berserker Stance. Could be
-- handled via AuraMap keyed to Berserker Stance buff, or via
-- StateCollector detecting the stance. Deferred for now.
-- TalentMap["2:20"] — Improved Berserker Stance: deferred to AuraMap

-------------------------------------------------------------------------------
-- Protection (Tab 3)
-- Most Protection talents are defensive/threat-oriented. Only damage-
-- relevant talents are included here.
-------------------------------------------------------------------------------

-- NOTE: No Protection talents have been included because:
-- - Shield Specialization: block-related, defensive
-- - Anticipation: defense skill, defensive
-- - Toughness: armor, defensive
-- - Improved Shield Block: block, defensive
-- - Defiance: threat bonus only
-- - Improved Sunder Armor: rage cost reduction only
-- - Improved Disarm: duration increase, no damage
-- - Improved Shield Bash: silence chance, no damage
-- - Shield Slam: ability (damage from SpellData, not TalentMap)
-- - Devastate: ability (damage from SpellData, not TalentMap)
-- - One-Handed Weapon Specialization: +damage with 1H weapons
-- - Focused Rage: rage cost reduction
--
-- One-Handed Weapon Specialization (3:19) could be added but needs
-- weaponType filter support (same issue as Two-Handed Weapon Spec).

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["WARRIOR:" .. key] = data
end
