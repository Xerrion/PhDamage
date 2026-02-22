-------------------------------------------------------------------------------
-- TalentMap_Rogue
-- Rogue talent modifier definitions for PhDamage
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.TalentMap = ns.TalentMap or {}

local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Assassination (Tab 1)
--
-- Grid layout (row x col → index):
--  1: Improved Eviscerate (1,1)  Remorseless Attacks (1,2)  Malice (1,3)
--  4: Ruthlessness (2,1)         Murder (2,2)               [empty]         Puncturing Wounds (2,4)
--  7: Relentless Strikes (3,1)   Improved Expose Armor (3,2) Lethality (3,3)
-- 10: Vile Poisons (4,2)         Improved Poisons (4,3)
-- 12: Fleet Footed (5,1)         Cold Blood (5,2)           Imp Kidney Shot (5,3) Quick Recovery (5,4)
-- 16: Seal Fate (6,2)            Master Poisoner (6,3)
-- 18: Vigor (7,2)                Deadened Nerves (7,3)
-- 20: Find Weakness (8,3)
-- 21: Mutilate (9,2)
-------------------------------------------------------------------------------

-- Improved Eviscerate (1:1): +5% Eviscerate damage per rank
TalentMap["1:1"] = {
    name = "Improved Eviscerate",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05, perRank = true, stacking = "additive",
          filter = { spellNames = { "Eviscerate" } } },
    },
}

-- Remorseless Attacks (1:2): +20% crit chance on next SS/Hemo/BS/Ambush/GS
-- after killing a target that yields XP/honor. Proc-based — deferred to AuraMap.
-- TalentMap["1:2"] — Remorseless Attacks: deferred to AuraMap

-- Malice (1:3): +1% crit chance per rank
TalentMap["1:3"] = {
    name = "Malice",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Ruthlessness (1:4): 20% chance per rank to add a combo point after
-- finishing move. Proc-based — not expressible as a damage modifier.
-- TalentMap["1:4"] — Ruthlessness: deferred (proc-based)

-- Murder (1:5): +1% all damage vs Humanoid/Giant/Beast/Dragonkin per rank
TalentMap["1:5"] = {
    name = "Murder",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { creatureTypes = {"Humanoid", "Giant", "Beast", "Dragonkin", "Critter"} } },
    },
}

-- Puncturing Wounds (1:6): +10% BS crit, +5% Mutilate crit per rank
TalentMap["1:6"] = {
    name = "Puncturing Wounds",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.10, perRank = true,
          filter = { spellNames = { "Backstab" } } },
        { type = MOD.CRIT_BONUS, value = 0.05, perRank = true,
          filter = { spellNames = { "Mutilate" } } },
    },
}

-- Relentless Strikes (1:7): Finishing moves have 20% chance per CP to
-- restore 25 Energy. Resource gain — not a damage modifier.
-- TalentMap["1:7"] — Relentless Strikes: deferred (resource-based)

-- Improved Expose Armor (1:8): Increases effectiveness of Expose Armor.
-- Armor reduction modifier — affects target debuff, not direct damage.
-- TalentMap["1:8"] — Improved Expose Armor: deferred (debuff modifier)

-- Lethality (1:9): +6% crit damage bonus per rank (6/12/18/24/30%)
-- Affects: SS, Gouge, BS, Ghostly Strike, Mutilate, Shiv, Hemorrhage
TalentMap["1:9"] = {
    name = "Lethality",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_MULT_BONUS, value = 0.06, perRank = true,
          filter = { spellNames = {
            "Sinister Strike", "Gouge", "Backstab",
            "Ghostly Strike", "Mutilate", "Shiv", "Hemorrhage",
          } } },
    },
}

-- Vile Poisons (1:10): +4% poison and Envenom damage per rank (4/8/12/16/20%)
-- Also +8% poison dispel resist per rank (not modeled)
TalentMap["1:10"] = {
    name = "Vile Poisons",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.04, perRank = true, stacking = "additive",
          filter = { spellNames = {
            "Instant Poison", "Deadly Poison", "Wound Poison", "Envenom",
          } } },
    },
}

-- Improved Poisons (1:11): +2% chance to apply poisons per rank (2/4/6/8/10%)
-- Application chance modifier — not a damage modifier.
-- TalentMap["1:11"] — Improved Poisons: deferred (proc chance)

-- Fleet Footed (1:12): +8% run speed, +3% chance to resist movement
-- impairing effects per rank. Utility — no damage effect.
-- TalentMap["1:12"] — Fleet Footed: deferred (utility)

-- Cold Blood (1:13): +100% crit chance on next offensive ability (active)
-- NOTE: Activated ability — handled via AuraMap when the Cold Blood buff
-- is active.
-- TalentMap["1:13"] — Cold Blood: deferred to AuraMap

-- Improved Kidney Shot (1:14): +3% damage taken from all sources per rank
-- while target is affected by Kidney Shot (3/6/9%)
-- NOTE: This is a debuff on the target during Kidney Shot. Should be
-- handled via AuraMap keyed to the Improved Kidney Shot debuff.
-- TalentMap["1:14"] — Improved Kidney Shot: deferred to AuraMap

-- Quick Recovery (1:15): +10% healing received, +40% finishing move energy
-- refund on miss per rank. Utility — no direct damage effect.
-- TalentMap["1:15"] — Quick Recovery: deferred (utility)

-- Seal Fate (1:16): Critical strikes from abilities that add combo points
-- have a 20% chance per rank to add an additional combo point. Proc-based.
-- TalentMap["1:16"] — Seal Fate: deferred (proc-based)

-- Master Poisoner (1:17): +2% chance to hit with poison, reduces poison
-- target's chance to resist spells by 2% per rank. Hit/debuff modifier.
-- TalentMap["1:17"] — Master Poisoner: deferred (debuff modifier)

-- Vigor (1:18): +10 maximum Energy (1 rank). Resource pool — no damage effect.
-- TalentMap["1:18"] — Vigor: deferred (resource pool)

-- Deadened Nerves (1:19): -1% all damage taken per rank. Defensive.
-- TalentMap["1:19"] — Deadened Nerves: deferred (defensive)

-- Find Weakness (1:20): Finishing moves increase damage of all offensive
-- abilities by 2% per rank for 10 sec (2/4/6/8/10%)
-- NOTE: This is a temporary buff triggered by finishing moves. Should be
-- handled via AuraMap when the Find Weakness buff is active.
-- TalentMap["1:20"] — Find Weakness: deferred to AuraMap

-- Mutilate (1:21): Active ability — damage handled via SpellData.
-- TalentMap["1:21"] — Mutilate: handled by SpellData

-------------------------------------------------------------------------------
-- Combat (Tab 2)
--
-- Grid layout (row x col → index):
--  1: Improved Gouge (1,1)       Improved SS (1,2)          Lightning Reflexes (1,3)
--  4: Improved SnD (2,1)         Deflection (2,2)           Precision (2,3)
--  7: Endurance (3,1)            Riposte (3,2)              [empty]          Improved Sprint (3,4)
-- 10: Improved Kick (4,1)        Dagger Spec (4,2)          DW Spec (4,3)
-- 13: Mace Spec (5,1)            Blade Flurry (5,2)         Sword Spec (5,3) Fist Spec (5,4)
-- 17: Blade Twisting (6,1)       Weapon Expertise (6,2)     Aggression (6,3)
-- 20: Vitality (7,1)             Adrenaline Rush (7,2)      Nerves of Steel (7,3)
-- 23: Combat Potency (8,3)
-- 24: Surprise Attacks (9,2)
-------------------------------------------------------------------------------

-- Improved Gouge (2:1): Increases Gouge duration. CC utility — no damage.
-- TalentMap["2:1"] — Improved Gouge: deferred (CC duration)

-- Improved Sinister Strike (2:2): -3/-5 Energy cost reduction.
-- Energy cost reduction is not a damage modifier — no MOD type for it.
-- TalentMap["2:2"] — Improved Sinister Strike: deferred (resource cost)

-- Lightning Reflexes (2:3): +1% Dodge per rank. Defensive.
-- TalentMap["2:3"] — Lightning Reflexes: deferred (defensive)

-- Improved Slice and Dice (2:4): +15% SnD duration per rank (15/30/45%)
-- NOTE: Duration increase — the attack speed bonus is already captured
-- as a buff via AuraMap when SnD is active.
-- TalentMap["2:4"] — Improved Slice and Dice: deferred (buff duration)

-- Deflection (2:5): +1% Parry per rank. Defensive.
-- TalentMap["2:5"] — Deflection: deferred (defensive)

-- Precision (2:6): +1% melee hit per rank (5 ranks = 5%)
TalentMap["2:6"] = {
    name = "Precision",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Endurance (2:7): Reduces cooldown of Sprint/Evasion. Utility.
-- TalentMap["2:7"] — Endurance: deferred (cooldown reduction)

-- Riposte (2:8): Active ability — damage handled via SpellData.
-- TalentMap["2:8"] — Riposte: handled by SpellData

-- Improved Sprint (2:9): Gives Sprint a chance to remove movement impairing
-- effects. Utility.
-- TalentMap["2:9"] — Improved Sprint: deferred (utility)

-- Improved Kick (2:10): Gives Kick a chance to silence. CC utility.
-- TalentMap["2:10"] — Improved Kick: deferred (CC utility)

-- Dagger Specialization (2:11): +1% crit with Daggers per rank
-- TODO: Needs weaponType filter support. Currently applies to all abilities.
TalentMap["2:11"] = {
    name = "Dagger Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Dual Wield Specialization (2:12): +10% OH damage per rank (10/20/30/40/50%)
-- TODO: Needs off-hand vs main-hand differentiation in the engine.
-- Currently the engine does not model OH vs MH separately.
-- TalentMap["2:12"] — Dual Wield Specialization: deferred (OH-specific)

-- Mace Specialization (2:13): Increases expertise with Maces per rank.
-- Also has a chance to reduce movement speed. The expertise portion is a
-- stat modifier.
-- TODO: Needs weaponType filter support.
-- TalentMap["2:13"] — Mace Specialization: deferred (weaponType filter)

-- Blade Flurry (2:14): +20% attack speed, hits additional nearby target.
-- Active ability — handled via AuraMap when Blade Flurry buff is active.
-- TalentMap["2:14"] — Blade Flurry: deferred to AuraMap

-- Sword Specialization (2:15): 1% chance per rank for extra attack on hit.
-- Proc-based extra attack — cannot be expressed as a simple damage modifier.
-- TalentMap["2:15"] — Sword Specialization: deferred (proc-based)

-- Fist Weapon Specialization (2:16): +1% crit with Fist Weapons per rank.
-- TODO: Needs weaponType filter support.
TalentMap["2:16"] = {
    name = "Fist Weapon Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Blade Twisting (2:17): Sinister Strike/Backstab have 10% chance per rank
-- to Daze target. CC utility — no direct damage.
-- TalentMap["2:17"] — Blade Twisting: deferred (CC utility)

-- Weapon Expertise (2:18): +5 expertise per rank (2 ranks = 10)
-- Reduces target's dodge and parry chance. Expertise is handled via
-- playerState.expertise in CritCalc, not as a TalentMap modifier.
-- TalentMap["2:18"] — Weapon Expertise: handled via stats

-- Aggression (2:19): +2% SS/BS/Evis damage per rank (2/4/6%)
TalentMap["2:19"] = {
    name = "Aggression",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { spellNames = { "Sinister Strike", "Backstab", "Eviscerate" } } },
    },
}

-- Vitality (2:20): +2% Stamina, +1% Agility per rank
-- NOTE: Stat multiplier — the Agility increase is already reflected in
-- playerState.stats when collected. Could be modeled but would require
-- a stat multiplier MOD type. The Agility increase does indirectly
-- increase AP and crit, but that's captured by StateCollector.
-- TalentMap["2:20"] — Vitality: handled via stats

-- Adrenaline Rush (2:21): +100% Energy regen for 15s. Active ability.
-- Resource gain — handled via AuraMap when the buff is active.
-- TalentMap["2:21"] — Adrenaline Rush: deferred to AuraMap

-- Nerves of Steel (2:22): Reduces duration of Stun/Fear. Defensive/PvP.
-- TalentMap["2:22"] — Nerves of Steel: deferred (defensive)

-- Combat Potency (2:23): 20% chance on OH hit to generate 3 Energy per rank
-- (3/6/9/12/15). Proc-based resource gain — not a damage modifier.
-- TalentMap["2:23"] — Combat Potency: deferred (proc-based resource)

-- Surprise Attacks (2:24): Finishing moves can't be dodged, +10% damage to
-- SS/BS/Shiv/Gouge (1 rank)
TalentMap["2:24"] = {
    name = "Surprise Attacks",
    maxRank = 1,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { spellNames = { "Sinister Strike", "Backstab", "Shiv", "Gouge" } } },
    },
}

-------------------------------------------------------------------------------
-- Subtlety (Tab 3)
--
-- Grid layout (row x col → index):
--  1: [empty]                    Master of Deception (1,2)  Opportunity (1,3)
--  3: Sleight of Hand (2,1)      Dirty Tricks (2,2)         Camouflage (2,3)
--  6: Initiative (3,1)           Ghostly Strike (3,2)       Improved Ambush (3,3)
--  9: Setup (4,1)                Elusiveness (4,2)          Serrated Blades (4,3)
-- 12: Heightened Senses (5,1)    Preparation (5,2)          Dirty Deeds (5,3)  Hemorrhage (5,4)
-- 16: Master of Subtlety (6,1)   [empty]                    Deadliness (6,3)
-- 18: Enveloping Shadows (7,1)   Premeditation (7,2)        Cheat Death (7,3)
-- 21: Sinister Calling (8,2)
-- 22: Shadowstep (9,2)
-------------------------------------------------------------------------------

-- Master of Deception (3:1): Reduces chance to be detected in stealth.
-- Stealth utility — no damage effect.
-- TalentMap["3:1"] — Master of Deception: deferred (stealth utility)

-- Opportunity (3:2): +4% damage from behind with BS/Mutilate/Garrote/Ambush
-- per rank (4/8/12/16/20%)
TalentMap["3:2"] = {
    name = "Opportunity",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.04, perRank = true, stacking = "additive",
          filter = { spellNames = { "Backstab", "Mutilate", "Garrote", "Ambush" } } },
    },
}

-- Sleight of Hand (3:3): -1% chance to be crit, +2% Pickpocket range per rank.
-- Defensive/utility.
-- TalentMap["3:3"] — Sleight of Hand: deferred (defensive)

-- Dirty Tricks (3:4): Reduces Energy cost of Sap/Blind, increases range.
-- CC utility.
-- TalentMap["3:4"] — Dirty Tricks: deferred (CC utility)

-- Camouflage (3:5): +5% move speed in stealth, -1 sec stealth cooldown per rank.
-- Stealth utility.
-- TalentMap["3:5"] — Camouflage: deferred (stealth utility)

-- Initiative (3:6): 25% chance per rank to add combo point on Garrote/Ambush.
-- Proc-based.
-- TalentMap["3:6"] — Initiative: deferred (proc-based)

-- Ghostly Strike (3:7): Active ability — damage handled via SpellData.
-- TalentMap["3:7"] — Ghostly Strike: handled by SpellData

-- Improved Ambush (3:8): +15% Ambush crit chance per rank (15/30/45%)
TalentMap["3:8"] = {
    name = "Improved Ambush",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.15, perRank = true,
          filter = { spellNames = { "Ambush" } } },
    },
}

-- Setup (3:9): Gives a chance per rank to add combo point when dodging.
-- Proc-based resource gain.
-- TalentMap["3:9"] — Setup: deferred (proc-based)

-- Elusiveness (3:10): Reduces cooldown of Vanish/Blind. Utility.
-- TalentMap["3:10"] — Elusiveness: deferred (cooldown reduction)

-- Serrated Blades (3:11): Ignore armor (scales with level) + 10% Rupture
-- damage per rank (10/20/30%)
TalentMap["3:11"] = {
    name = "Serrated Blades",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { spellNames = { "Rupture" } } },
        -- NOTE: Armor ignore portion scales with level and is not yet modeled.
        -- At level 70 it provides meaningful armor penetration per rank.
    },
}

-- Heightened Senses (3:12): +3% stealth detection, +2% chance to hit per rank.
-- The hit component is damage-relevant.
TalentMap["3:12"] = {
    name = "Heightened Senses",
    maxRank = 2,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true },
    },
}

-- Preparation (3:13): Resets cooldowns of certain abilities. Active ability.
-- TalentMap["3:13"] — Preparation: deferred (cooldown reset)

-- Dirty Deeds (3:14): -10 Energy on Cheap Shot/Garrote per rank, +10% damage
-- to targets below 35% HP per rank (10/20%)
TalentMap["3:14"] = {
    name = "Dirty Deeds",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { targetHealthBelow = 35 } },
    },
}

-- Hemorrhage (3:15): Active ability — damage handled via SpellData.
-- TalentMap["3:15"] — Hemorrhage: handled by SpellData

-- Master of Subtlety (3:16): +4/7/10% damage while stealthed and 6 sec after
-- NOTE: Stealth-conditional buff. Should be handled via AuraMap when the
-- Master of Subtlety buff is active (non-linear scaling: 4/7/10%).
-- TalentMap["3:16"] — Master of Subtlety: deferred to AuraMap

-- Deadliness (3:17): +2% attack power per rank (2/4/6/8/10%)
-- NOTE: Stat multiplier on AP — the increased AP is reflected in
-- playerState.stats.attackPower when collected by StateCollector.
-- TalentMap["3:17"] — Deadliness: handled via stats

-- Enveloping Shadows (3:18): +5% Cloak/Feint effect per rank. Defensive.
-- TalentMap["3:18"] — Enveloping Shadows: deferred (defensive)

-- Premeditation (3:19): Adds 2 combo points from stealth. Active ability.
-- TalentMap["3:19"] — Premeditation: deferred (utility)

-- Cheat Death (3:20): Reduces all damage taken by a killing blow. Defensive.
-- TalentMap["3:20"] — Cheat Death: deferred (defensive)

-- Sinister Calling (3:21): +3% Agility, +1% BS/Hemo damage bonus per rank
-- (3/6/9/12/15% Agi, 1/2/3/4/5% BS/Hemo)
-- NOTE: The Agility portion is a stat multiplier handled by StateCollector.
-- The BS/Hemo damage bonus is modeled here.
TalentMap["3:21"] = {
    name = "Sinister Calling",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { spellNames = { "Backstab", "Hemorrhage" } } },
    },
}

-- Shadowstep (3:22): Teleport behind target, +20% damage on next ability,
-- -50% threat. Active ability — handled via AuraMap when the Shadowstep
-- damage buff is active.
-- TalentMap["3:22"] — Shadowstep: deferred to AuraMap

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["ROGUE:" .. key] = data
end
