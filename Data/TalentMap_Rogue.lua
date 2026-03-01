local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Rogue Talent Modifiers - TBC Anniversary (2.5.5)
-- Talent positions (tab:index) verified in-game on TBC Anniversary
-- (ordered by internal talentID)
-------------------------------------------------------------------------------

local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Assassination (Tab 1)
-- 1:1  Improved Poisons (5)                1:2  Lethality (5)
-- 1:3  Malice (5)                          1:4  Remorseless Attacks (2)
-- 1:5  Ruthlessness (3)                    1:6  Murder (2)
-- 1:7  Improved Eviscerate (3)             1:8  Puncturing Wounds (3)
-- 1:9  Improved Expose Armor (2)           1:10 Improved Kidney Shot (3)
-- 1:11 Cold Blood (1)                      1:12 Relentless Strikes (1)
-- 1:13 Seal Fate (5)                       1:14 Vigor (1)
-- 1:15 Vile Poisons (5)                    1:16 Master Poisoner (2)
-- 1:17 Find Weakness (5)                   1:18 Mutilate (1)
-- 1:19 Fleet Footed (2)                    1:20 Deadened Nerves (5)
-- 1:21 Quick Recovery (2)
-------------------------------------------------------------------------------

-- Improved Poisons (1:1): +2% chance to apply poisons per rank (2/4/6/8/10%)
-- Application chance modifier - not a damage modifier.
-- TalentMap["1:1"] - Improved Poisons: deferred (proc chance)

-- Lethality (1:2): +6% crit damage bonus per rank (6/12/18/24/30%)
-- Affects: SS, Gouge, BS, Ghostly Strike, Mutilate, Shiv, Hemorrhage
TalentMap["1:2"] = {
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

-- Malice (1:3): +1% crit chance per rank
TalentMap["1:3"] = {
    name = "Malice",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Remorseless Attacks (1:4): +20% crit chance on next SS/Hemo/BS/Ambush/GS
-- after killing a target that yields XP/honor. Proc-based - deferred to AuraMap.
-- TalentMap["1:4"] - Remorseless Attacks: deferred to AuraMap

-- Ruthlessness (1:5): 20% chance per rank to add a combo point after
-- finishing move. Proc-based - not expressible as a damage modifier.
-- TalentMap["1:5"] - Ruthlessness: deferred (proc-based)

-- Murder (1:6): +1% all damage vs Humanoid/Giant/Beast/Dragonkin per rank
TalentMap["1:6"] = {
    name = "Murder",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { creatureTypes = {"Humanoid", "Giant", "Beast", "Dragonkin", "Critter"} } },
    },
}

-- Improved Eviscerate (1:7): +5% Eviscerate damage per rank
TalentMap["1:7"] = {
    name = "Improved Eviscerate",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.05, perRank = true, stacking = "additive",
          filter = { spellNames = { "Eviscerate" } } },
    },
}

-- Puncturing Wounds (1:8): +10% BS crit, +5% Mutilate crit per rank
TalentMap["1:8"] = {
    name = "Puncturing Wounds",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.10, perRank = true,
          filter = { spellNames = { "Backstab" } } },
        { type = MOD.CRIT_BONUS, value = 0.05, perRank = true,
          filter = { spellNames = { "Mutilate" } } },
    },
}

-- Improved Expose Armor (1:9): Increases effectiveness of Expose Armor.
-- Armor reduction modifier - affects target debuff, not direct damage.
-- TalentMap["1:9"] - Improved Expose Armor: deferred (debuff modifier)

-- Improved Kidney Shot (1:10): +3% damage taken from all sources per rank
-- while target is affected by Kidney Shot (3/6/9%)
-- NOTE: This is a debuff on the target during Kidney Shot. Should be
-- handled via AuraMap keyed to the Improved Kidney Shot debuff.
-- TalentMap["1:10"] - Improved Kidney Shot: deferred to AuraMap

-- Cold Blood (1:11): +100% crit chance on next offensive ability (active)
-- NOTE: Activated ability - handled via AuraMap when the Cold Blood buff
-- is active.
-- TalentMap["1:11"] - Cold Blood: deferred to AuraMap

-- Relentless Strikes (1:12): Finishing moves have 20% chance per CP to
-- restore 25 Energy. Resource gain - not a damage modifier.
-- TalentMap["1:12"] - Relentless Strikes: deferred (resource-based)

-- Seal Fate (1:13): Critical strikes from abilities that add combo points
-- have a 20% chance per rank to add an additional combo point. Proc-based.
-- TalentMap["1:13"] - Seal Fate: deferred (proc-based)

-- Vigor (1:14): +10 maximum Energy (1 rank). Resource pool - no damage effect.
-- TalentMap["1:14"] - Vigor: deferred (resource pool)

-- Vile Poisons (1:15): +4% poison and Envenom damage per rank (4/8/12/16/20%)
-- Also +8% poison dispel resist per rank (not modeled)
TalentMap["1:15"] = {
    name = "Vile Poisons",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.04, perRank = true, stacking = "additive",
          filter = { spellNames = {
            "Instant Poison", "Deadly Poison", "Wound Poison", "Envenom",
          } } },
    },
}

-- Master Poisoner (1:16): +2% chance to hit with poison, reduces poison
-- target's chance to resist spells by 2% per rank. Hit/debuff modifier.
-- TalentMap["1:16"] - Master Poisoner: deferred (debuff modifier)

-- Find Weakness (1:17): Finishing moves increase damage of all offensive
-- abilities by 2% per rank for 10 sec (2/4/6/8/10%)
-- NOTE: This is a temporary buff triggered by finishing moves. Should be
-- handled via AuraMap when the Find Weakness buff is active.
-- TalentMap["1:17"] - Find Weakness: deferred to AuraMap

-- Mutilate (1:18): Active ability - damage handled via SpellData.
-- TalentMap["1:18"] - Mutilate: handled by SpellData

-- Fleet Footed (1:19): +8% run speed, +3% chance to resist movement
-- impairing effects per rank. Utility - no damage effect.
-- TalentMap["1:19"] - Fleet Footed: deferred (utility)

-- Deadened Nerves (1:20): -1% all damage taken per rank. Defensive.
-- TalentMap["1:20"] - Deadened Nerves: deferred (defensive)

-- Quick Recovery (1:21): +10% healing received, +40% finishing move energy
-- refund on miss per rank. Utility - no direct damage effect.
-- TalentMap["1:21"] - Quick Recovery: deferred (utility)

-------------------------------------------------------------------------------
-- Combat (Tab 2)
-- 2:1  Precision (5)                       2:2  Dagger Specialization (5)
-- 2:3  Fist Weapon Specialization (5)      2:4  Mace Specialization (5)
-- 2:5  Lightning Reflexes (5)              2:6  Deflection (5)
-- 2:7  Improved Sinister Strike (2)        2:8  Improved Gouge (3)
-- 2:9  Endurance (2)                       2:10 Adrenaline Rush (1)
-- 2:11 Improved Kick (2)                   2:12 Dual Wield Specialization (5)
-- 2:13 Improved Sprint (2)                 2:14 Blade Flurry (1)
-- 2:15 Sword Specialization (5)            2:16 Riposte (1)
-- 2:17 Aggression (3)                      2:18 Weapon Expertise (2)
-- 2:19 Vitality (2)                        2:20 Blade Twisting (2)
-- 2:21 Nerves of Steel (2)                 2:22 Surprise Attacks (1)
-- 2:23 Combat Potency (5)                  2:24 Improved Slice and Dice (3)
-------------------------------------------------------------------------------

-- Precision (2:1): +1% melee hit per rank (5 ranks = 5%)
TalentMap["2:1"] = {
    name = "Precision",
    maxRank = 5,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Dagger Specialization (2:2): +1% crit with Daggers per rank
-- TODO: Needs weaponType filter support. Currently applies to all abilities.
TalentMap["2:2"] = {
    name = "Dagger Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Fist Weapon Specialization (2:3): +1% crit with Fist Weapons per rank.
-- TODO: Needs weaponType filter support.
TalentMap["2:3"] = {
    name = "Fist Weapon Specialization",
    maxRank = 5,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.01, perRank = true },
    },
}

-- Mace Specialization (2:4): Increases expertise with Maces per rank.
-- Also has a chance to reduce movement speed. The expertise portion is a
-- stat modifier.
-- TODO: Needs weaponType filter support.
-- TalentMap["2:4"] - Mace Specialization: deferred (weaponType filter)

-- Lightning Reflexes (2:5): +1% Dodge per rank. Defensive.
-- TalentMap["2:5"] - Lightning Reflexes: deferred (defensive)

-- Deflection (2:6): +1% Parry per rank. Defensive.
-- TalentMap["2:6"] - Deflection: deferred (defensive)

-- Improved Sinister Strike (2:7): -3/-5 Energy cost reduction.
-- Energy cost reduction is not a damage modifier - no MOD type for it.
-- TalentMap["2:7"] - Improved Sinister Strike: deferred (resource cost)

-- Improved Gouge (2:8): Increases Gouge duration. CC utility - no damage.
-- TalentMap["2:8"] - Improved Gouge: deferred (CC duration)

-- Endurance (2:9): Reduces cooldown of Sprint/Evasion. Utility.
-- TalentMap["2:9"] - Endurance: deferred (cooldown reduction)

-- Adrenaline Rush (2:10): +100% Energy regen for 15s. Active ability.
-- Resource gain - handled via AuraMap when the buff is active.
-- TalentMap["2:10"] - Adrenaline Rush: deferred to AuraMap

-- Improved Kick (2:11): Gives Kick a chance to silence. CC utility.
-- TalentMap["2:11"] - Improved Kick: deferred (CC utility)

-- Dual Wield Specialization (2:12): +10% OH damage per rank (10/20/30/40/50%)
-- TODO: Needs off-hand vs main-hand differentiation in the engine.
-- Currently the engine does not model OH vs MH separately.
-- TalentMap["2:12"] - Dual Wield Specialization: deferred (OH-specific)

-- Improved Sprint (2:13): Gives Sprint a chance to remove movement impairing
-- effects. Utility.
-- TalentMap["2:13"] - Improved Sprint: deferred (utility)

-- Blade Flurry (2:14): +20% attack speed, hits additional nearby target.
-- Active ability - handled via AuraMap when Blade Flurry buff is active.
-- TalentMap["2:14"] - Blade Flurry: deferred to AuraMap

-- Sword Specialization (2:15): 1% chance per rank for extra attack on hit.
-- Proc-based extra attack - cannot be expressed as a simple damage modifier.
-- TalentMap["2:15"] - Sword Specialization: deferred (proc-based)

-- Riposte (2:16): Active ability - damage handled via SpellData.
-- TalentMap["2:16"] - Riposte: handled by SpellData

-- Aggression (2:17): +2% SS/BS/Evis damage per rank (2/4/6%)
TalentMap["2:17"] = {
    name = "Aggression",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02, perRank = true, stacking = "additive",
          filter = { spellNames = { "Sinister Strike", "Backstab", "Eviscerate" } } },
    },
}

-- Weapon Expertise (2:18): +5 expertise per rank (2 ranks = 10)
-- Reduces target's dodge and parry chance. Expertise is handled via
-- playerState.expertise in CritCalc, not as a TalentMap modifier.
-- TalentMap["2:18"] - Weapon Expertise: handled via stats

-- Vitality (2:19): +2% Stamina, +1% Agility per rank
-- NOTE: Stat multiplier - the Agility increase is already reflected in
-- playerState.stats when collected. Could be modeled but would require
-- a stat multiplier MOD type. The Agility increase does indirectly
-- increase AP and crit, but that's captured by StateCollector.
-- TalentMap["2:19"] - Vitality: handled via stats

-- Blade Twisting (2:20): Sinister Strike/Backstab have 10% chance per rank
-- to Daze target. CC utility - no direct damage.
-- TalentMap["2:20"] - Blade Twisting: deferred (CC utility)

-- Nerves of Steel (2:21): Reduces duration of Stun/Fear. Defensive/PvP.
-- TalentMap["2:21"] - Nerves of Steel: deferred (defensive)

-- Surprise Attacks (2:22): Finishing moves can't be dodged, +10% damage to
-- SS/BS/Shiv/Gouge (1 rank)
TalentMap["2:22"] = {
    name = "Surprise Attacks",
    maxRank = 1,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { spellNames = { "Sinister Strike", "Backstab", "Shiv", "Gouge" } } },
    },
}

-- Combat Potency (2:23): 20% chance on OH hit to generate 3 Energy per rank
-- (3/6/9/12/15). Proc-based resource gain - not a damage modifier.
-- TalentMap["2:23"] - Combat Potency: deferred (proc-based resource)

-- Improved Slice and Dice (2:24): +15% SnD duration per rank (15/30/45%)
-- NOTE: Duration increase - the attack speed bonus is already captured
-- as a buff via AuraMap when SnD is active.
-- TalentMap["2:24"] - Improved Slice and Dice: deferred (buff duration)

-------------------------------------------------------------------------------
-- Subtlety (Tab 3)
-- 3:1  Master of Deception (5)             3:2  Camouflage (5)
-- 3:3  Initiative (3)                      3:4  Setup (3)
-- 3:5  Elusiveness (2)                     3:6  Opportunity (5)
-- 3:7  Dirty Tricks (2)                    3:8  Improved Ambush (3)
-- 3:9  Dirty Deeds (2)                     3:10 Preparation (1)
-- 3:11 Ghostly Strike (1)                  3:12 Premeditation (1)
-- 3:13 Hemorrhage (1)                      3:14 Serrated Blades (3)
-- 3:15 Sleight of Hand (2)                 3:16 Heightened Senses (2)
-- 3:17 Deadliness (5)                      3:18 Enveloping Shadows (3)
-- 3:19 Sinister Calling (5)                3:20 Master of Subtlety (3)
-- 3:21 Shadowstep (1)                      3:22 Cheat Death (3)
-------------------------------------------------------------------------------

-- Master of Deception (3:1): Reduces chance to be detected in stealth.
-- Stealth utility - no damage effect.
-- TalentMap["3:1"] - Master of Deception: deferred (stealth utility)

-- Camouflage (3:2): +5% move speed in stealth, -1 sec stealth cooldown per rank.
-- Stealth utility.
-- TalentMap["3:2"] - Camouflage: deferred (stealth utility)

-- Initiative (3:3): 25% chance per rank to add combo point on Garrote/Ambush.
-- Proc-based.
-- TalentMap["3:3"] - Initiative: deferred (proc-based)

-- Setup (3:4): Gives a chance per rank to add combo point when dodging.
-- Proc-based resource gain.
-- TalentMap["3:4"] - Setup: deferred (proc-based)

-- Elusiveness (3:5): Reduces cooldown of Vanish/Blind. Utility.
-- TalentMap["3:5"] - Elusiveness: deferred (cooldown reduction)

-- Opportunity (3:6): +4% damage from behind with BS/Mutilate/Garrote/Ambush
-- per rank (4/8/12/16/20%)
TalentMap["3:6"] = {
    name = "Opportunity",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.04, perRank = true, stacking = "additive",
          filter = { spellNames = { "Backstab", "Mutilate", "Garrote", "Ambush" } } },
    },
}

-- Dirty Tricks (3:7): Reduces Energy cost of Sap/Blind, increases range.
-- CC utility.
-- TalentMap["3:7"] - Dirty Tricks: deferred (CC utility)

-- Improved Ambush (3:8): +15% Ambush crit chance per rank (15/30/45%)
TalentMap["3:8"] = {
    name = "Improved Ambush",
    maxRank = 3,
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.15, perRank = true,
          filter = { spellNames = { "Ambush" } } },
    },
}

-- Dirty Deeds (3:9): -10 Energy on Cheap Shot/Garrote per rank, +10% damage
-- to targets below 35% HP per rank (10/20%)
TalentMap["3:9"] = {
    name = "Dirty Deeds",
    maxRank = 2,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { targetHealthBelow = 35 } },
    },
}

-- Preparation (3:10): Resets cooldowns of certain abilities. Active ability.
-- TalentMap["3:10"] - Preparation: deferred (cooldown reset)

-- Ghostly Strike (3:11): Active ability - damage handled via SpellData.
-- TalentMap["3:11"] - Ghostly Strike: handled by SpellData

-- Premeditation (3:12): Adds 2 combo points from stealth. Active ability.
-- TalentMap["3:12"] - Premeditation: deferred (utility)

-- Hemorrhage (3:13): Active ability - damage handled via SpellData.
-- TalentMap["3:13"] - Hemorrhage: handled by SpellData

-- Serrated Blades (3:14): Ignore armor (scales with level) + 10% Rupture
-- damage per rank (10/20/30%)
TalentMap["3:14"] = {
    name = "Serrated Blades",
    maxRank = 3,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10, perRank = true, stacking = "additive",
          filter = { spellNames = { "Rupture" } } },
        -- NOTE: Armor ignore portion scales with level and is not yet modeled.
        -- At level 70 it provides meaningful armor penetration per rank.
    },
}

-- Sleight of Hand (3:15): -1% chance to be crit, +2% Pickpocket range per rank.
-- Defensive/utility.
-- TalentMap["3:15"] - Sleight of Hand: deferred (defensive)

-- Heightened Senses (3:16): +3% stealth detection, +2% chance to hit per rank.
-- The hit component is damage-relevant.
TalentMap["3:16"] = {
    name = "Heightened Senses",
    maxRank = 2,
    effects = {
        { type = MOD.SPELL_HIT_BONUS, value = 0.02, perRank = true },
    },
}

-- Deadliness (3:17): +2% attack power per rank (2/4/6/8/10%)
-- NOTE: Stat multiplier on AP - the increased AP is reflected in
-- playerState.stats.attackPower when collected by StateCollector.
-- TalentMap["3:17"] - Deadliness: handled via stats

-- Enveloping Shadows (3:18): +5% Cloak/Feint effect per rank. Defensive.
-- TalentMap["3:18"] - Enveloping Shadows: deferred (defensive)

-- Sinister Calling (3:19): +3% Agility, +1% BS/Hemo damage bonus per rank
-- (3/6/9/12/15% Agi, 1/2/3/4/5% BS/Hemo)
-- NOTE: The Agility portion is a stat multiplier handled by StateCollector.
-- The BS/Hemo damage bonus is modeled here.
TalentMap["3:19"] = {
    name = "Sinister Calling",
    maxRank = 5,
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.01, perRank = true, stacking = "additive",
          filter = { spellNames = { "Backstab", "Hemorrhage" } } },
    },
}

-- Master of Subtlety (3:20): +4/7/10% damage while stealthed and 6 sec after
-- NOTE: Stealth-conditional buff. Should be handled via AuraMap when the
-- Master of Subtlety buff is active (non-linear scaling: 4/7/10%).
-- TalentMap["3:20"] - Master of Subtlety: deferred to AuraMap

-- Shadowstep (3:21): Teleport behind target, +20% damage on next ability,
-- -50% threat. Active ability - handled via AuraMap when the Shadowstep
-- damage buff is active.
-- TalentMap["3:21"] - Shadowstep: deferred to AuraMap

-- Cheat Death (3:22): Reduces all damage taken by a killing blow. Defensive.
-- TalentMap["3:22"] - Cheat Death: deferred (defensive)

-- Merge into addon namespace with class prefix
for key, data in pairs(TalentMap) do
    ns.TalentMap["ROGUE:" .. key] = data
end
