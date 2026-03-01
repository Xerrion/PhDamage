local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Warrior Talent Modifiers - TBC Anniversary (2.5.5)
-- Talent positions (tab:index) verified in-game on TBC Anniversary
-- (ordered by internal talentID)
-------------------------------------------------------------------------------

ns.TalentMap = ns.TalentMap or {}

local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Arms (Tab 1, 23 talents)
-- 1:1  Deep Wounds (3)                    1:2  Sword Specialization (5)
-- 1:3  Improved Heroic Strike (3)         1:4  Mace Specialization (5)
-- 1:5  Improved Charge (2)                1:6  Improved Rend (3)
-- 1:7  Improved Thunder Clap (3)          1:8  Improved Hamstring (3)
-- 1:9  Deflection (5)                     1:10 Improved Overpower (2)
-- 1:11 Poleaxe Specialization (5)         1:12 Death Wish (1)
-- 1:13 Improved Intercept (2)             1:14 Mortal Strike (1)
-- 1:15 Two-Handed Weapon Specialization (5)
-- 1:16 Anger Management (1)              1:17 Iron Will (5)
-- 1:18 Impale (2)                         1:19 Endless Rage (1)
-- 1:20 Improved Disciplines (3)           1:21 Second Wind (2)
-- 1:22 Blood Frenzy (2)                   1:23 Improved Mortal Strike (5)
-------------------------------------------------------------------------------

-- Deep Wounds: 20% weapon average damage bleed over 12s per rank
-- NOTE: Proc-based (triggers on crit). Damage calculation is complex
-- (based on weapon average damage). Best handled via AuraMap when
-- Deep Wounds buff is active. Included here for completeness as a
-- placeholder - the engine does not yet calculate Deep Wounds ticks.
-- TalentMap["1:1"] - Deep Wounds: deferred to AuraMap

-- Sword Specialization: 1% chance per rank for extra attack on hit
-- NOTE: Proc-based extra attack - cannot be expressed as a simple
-- damage modifier. Would require simulation or proc-rate modeling.
-- TalentMap["1:2"] - Sword Specialization: deferred (proc-based)

-- Mace Specialization: Chance to stun + generate rage per rank
-- NOTE: Proc-based - cannot be expressed as a damage modifier.
-- TalentMap["1:4"] - Mace Specialization: deferred (proc-based)

-- Improved Rend: +25% Rend bleed damage per rank (Arms 1:6)
TalentMap["1:6"] = {
    name = "Improved Rend",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.25, perRank = true, stacking = "additive",
          filter = { spellNames = { "Rend" } } },
    },
}

-- Improved Overpower: +25% Overpower crit chance per rank (Arms 1:10)
TalentMap["1:10"] = {
    name = "Improved Overpower",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.25, perRank = true,
          filter = { spellNames = { "Overpower" } } },
    },
}

-- Poleaxe Specialization: +1% crit with Axes and Polearms per rank (Arms 1:11)
-- TODO: Needs weaponType filter support in MatchesFilter. Currently applies
-- to all abilities regardless of weapon type.
TalentMap["1:11"] = {
    name = "Poleaxe Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Death Wish: +20% physical damage, active ability (30s duration)
-- NOTE: This is an activated ability, not a passive talent. The damage
-- bonus should be handled via AuraMap when the Death Wish buff is active.
-- TalentMap["1:12"] - Death Wish: deferred to AuraMap

-- Two-Handed Weapon Specialization: +1% damage with 2H weapons per rank (Arms 1:15)
-- TODO: Needs weaponType filter support in MatchesFilter. Currently applies
-- to all abilities regardless of weapon type. This is acceptable for 2H
-- warriors but over-applies for dual-wielders.
TalentMap["1:15"] = {
    name = "Two-Handed Weapon Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive" },
    },
}

-- Impale: +10% crit damage bonus per rank (Arms 1:18)
TalentMap["1:18"] = {
    name = "Impale",
    maxRank = 2,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.10, perRank = true },
    },
}

-- Blood Frenzy: +2% physical damage taken debuff on target per rank
-- NOTE: This is a debuff applied to the target via Rend/Deep Wounds.
-- Should be handled via AuraMap keyed to the Blood Frenzy debuff spellID.
-- TalentMap["1:22"] - Blood Frenzy: deferred to AuraMap

-- Improved Mortal Strike: +1% Mortal Strike damage per rank (Arms 1:23)
TalentMap["1:23"] = {
    name = "Improved Mortal Strike",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { spellNames = { "Mortal Strike" } } },
    },
}

-------------------------------------------------------------------------------
-- Fury (Tab 2, 21 talents)
-- 2:1  Commanding Presence (5)            2:2  Enrage (5)
-- 2:3  Flurry (5)                         2:4  Cruelty (5)
-- 2:5  Booming Voice (5)                  2:6  Unbridled Wrath (5)
-- 2:7  Piercing Howl (1)                  2:8  Improved Demoralizing Shout (5)
-- 2:9  Sweeping Strikes (1)               2:10 Improved Cleave (3)
-- 2:11 Bloodthirst (1)                    2:12 Improved Slam (2)
-- 2:13 Blood Craze (3)                    2:14 Improved Berserker Rage (2)
-- 2:15 Improved Execute (2)               2:16 Weapon Mastery (2)
-- 2:17 Dual Wield Specialization (5)      2:18 Improved Whirlwind (2)
-- 2:19 Precision (3)                      2:20 Improved Berserker Stance (5)
-- 2:21 Rampage (1)
-------------------------------------------------------------------------------

-- Commanding Presence: +5% Battle Shout AP / Commanding Shout HP per rank
-- NOTE: This modifies buff strength, not direct damage. The increased AP
-- from Battle Shout is already reflected in playerState.stats.attackPower.
-- No TalentMap entry needed - the buff effect is captured by StateCollector.
-- TalentMap["2:1"] - Commanding Presence: handled via stats

-- Enrage: +5% melee damage for 12s after being crit, per rank
-- NOTE: Proc-based buff triggered by receiving a critical hit.
-- Should be handled via AuraMap when the Enrage buff is active.
-- TalentMap["2:2"] - Enrage: deferred to AuraMap

-- Flurry: +5% attack speed for 3 swings after crit, per rank
-- NOTE: Proc-based buff with charge consumption. Cannot be expressed
-- as a simple modifier - requires proc modeling or AuraMap.
-- TalentMap["2:3"] - Flurry: deferred to AuraMap

-- Cruelty: +1% melee crit chance per rank (Fury 2:4)
TalentMap["2:4"] = {
    name = "Cruelty",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Improved Cleave: +40% bonus Cleave damage per rank (Fury 2:10)
TalentMap["2:10"] = {
    name = "Improved Cleave",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.40, perRank = true, stacking = "additive",
          filter = { spellNames = { "Cleave" } } },
    },
}

-- Improved Slam: -0.5s Slam cast time per rank (Fury 2:12)
TalentMap["2:12"] = {
    name = "Improved Slam",
    maxRank = 2,
    effects = {
        { type = MOD.CAST_TIME_REDUCTION, value = 0.5, perRank = true,
          filter = { spellNames = { "Slam" } } },
    },
}

-- Weapon Mastery: -1% chance to be dodged per rank (Fury 2:16)
-- NOTE: This reduces the target's effective dodge rate against the warrior.
-- Functionally similar to hit bonus but specifically reduces dodge.
-- Using SPELL_HIT_BONUS as the universal hit accumulator (same as
-- Hunter's Surefooted) since the engine treats all hit bonuses uniformly.
-- The dodge reduction is mechanically different from hit rating but has
-- the same net effect on damage expectation calculations.
TalentMap["2:16"] = {
    name = "Weapon Mastery",
    maxRank = 2,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Dual Wield Specialization: +5% off-hand damage per rank
-- TODO: Needs off-hand vs main-hand differentiation in the engine.
-- Currently the engine does not model OH vs MH separately.
-- TalentMap["2:17"] - Dual Wield Specialization: deferred (OH-specific)

-- Improved Whirlwind: -1s Whirlwind cooldown per rank
-- NOTE: Cooldown reduction does not affect per-hit damage, only DPS
-- throughput. The current engine computes per-hit damage, not DPS.
-- No MOD type for cooldown reduction exists. Included as a comment
-- for future DPS modeling.
-- TalentMap["2:18"] - Improved Whirlwind: deferred (cooldown reduction)

-- Precision: +1% melee hit per rank (Fury 2:19)
TalentMap["2:19"] = {
    name = "Precision",
    maxRank = 3,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Improved Berserker Stance: +2% AP in Berserker Stance per rank
-- NOTE: The AP bonus is stance-dependent and should be reflected in
-- playerState.stats.attackPower when in Berserker Stance. Could be
-- handled via AuraMap keyed to Berserker Stance buff, or via
-- StateCollector detecting the stance. Deferred for now.
-- TalentMap["2:20"] - Improved Berserker Stance: deferred to AuraMap

-------------------------------------------------------------------------------
-- Protection (Tab 3, 22 talents)
-- 3:1  Anticipation (5)                   3:2  Toughness (5)
-- 3:3  Tactical Mastery (3)               3:4  Improved Bloodrage (2)
-- 3:5  Improved Taunt (2)                 3:6  Defiance (3)
-- 3:7  Improved Shield Block (1)          3:8  Improved Sunder Armor (3)
-- 3:9  Improved Revenge (3)               3:10 Shield Slam (1)
-- 3:11 Improved Shield Bash (2)           3:12 Improved Shield Wall (2)
-- 3:13 Improved Disarm (3)                3:14 Concussion Blow (1)
-- 3:15 Last Stand (1)                     3:16 One-Handed Weapon Specialization (5)
-- 3:17 Shield Specialization (5)          3:18 Improved Defensive Stance (3)
-- 3:19 Vitality (5)                       3:20 Shield Mastery (3)
-- 3:21 Focused Rage (3)                   3:22 Devastate (1)
--
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
-- One-Handed Weapon Specialization (3:16) could be added but needs
-- weaponType filter support (same issue as Two-Handed Weapon Spec).

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["WARRIOR:" .. key] = data
end
