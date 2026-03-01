local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Hunter Talent Modifiers - TBC Anniversary (2.5.5)
-- Talent positions (tab:index) verified in-game on TBC Anniversary
-- (ordered by internal talentID)
-------------------------------------------------------------------------------

local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Beast Mastery (Tab 1)
-- 1:1  Improved Aspect of the Monkey (3)   1:2  Improved Aspect of the Hawk (5)
-- 1:3  Pathfinding (2)                     1:4  Improved Mend Pet (2)
-- 1:5  Bestial Wrath (1)                   1:6  Intimidation (1)
-- 1:7  Spirit Bond (2)                     1:8  Endurance Training (5)
-- 1:9  Bestial Discipline (2)              1:10 Bestial Swiftness (1)
-- 1:11 Ferocity (5)                        1:12 Thick Hide (3)
-- 1:13 Unleashed Fury (5)                  1:14 Frenzy (5)
-- 1:15 Focused Fire (2)                    1:16 Improved Revive Pet (2)
-- 1:17 Animal Handler (2)                  1:18 Ferocious Inspiration (3)
-- 1:19 Catlike Reflexes (3)                1:20 Serpent's Swiftness (5)
-- 1:21 The Beast Within (1)
-------------------------------------------------------------------------------

-- Focused Fire: +1/2% all damage when pet is active (Beast Mastery 1:15)
-- NOTE: Requires pet to be active - always applied when talent is taken
-- (Pet is almost always out for BM hunters)
TalentMap["1:15"] = {
    name = "Focused Fire",
    maxRank = 2,
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.01,
            perRank = true,
            stacking = "additive",
        },
    },
}

-------------------------------------------------------------------------------
-- Marksmanship (Tab 2)
-- 2:1  Improved Concussive Shot (5)        2:2  Efficiency (5)
-- 2:3  Improved Hunter's Mark (5)          2:4  Lethal Shots (5)
-- 2:5  Aimed Shot (1)                      2:6  Improved Arcane Shot (5)
-- 2:7  Barrage (3)                         2:8  Improved Stings (5)
-- 2:9  Mortal Shots (5)                    2:10 Concussive Barrage (3)
-- 2:11 Scatter Shot (1)                    2:12 Trueshot Aura (1)
-- 2:13 Ranged Weapon Specialization (5)    2:14 Combat Experience (2)
-- 2:15 Careful Aim (3)                     2:16 Master Marksman (5)
-- 2:17 Silencing Shot (1)                  2:18 Go for the Throat (2)
-- 2:19 Rapid Killing (2)                   2:20 Improved Barrage (3)
-------------------------------------------------------------------------------

-- Lethal Shots: +1/2/3/4/5% ranged crit chance (Marksmanship 2:4)
TalentMap["2:4"] = {
    name = "Lethal Shots",
    maxRank = 5,
    effects = {
        {
            type = MOD.CRIT_BONUS,
            value = 0.01,
            perRank = true,
        },
    },
}

-- Barrage: +4/8/12% Multi-Shot and Volley damage (Marksmanship 2:7)
TalentMap["2:7"] = {
    name = "Barrage",
    maxRank = 3,
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.04,
            perRank = true,
            stacking = "additive",
            filter = { spellNames = { "Multi-Shot", "Volley" } },
        },
    },
}

-- Improved Stings: +10/20/30% Serpent Sting damage (Marksmanship 2:8)
TalentMap["2:8"] = {
    name = "Improved Stings",
    maxRank = 5,
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.06,
            perRank = true,
            stacking = "additive",
            filter = { spellNames = { "Serpent Sting" } },
        },
    },
}

-- Mortal Shots: +6/12/18/24/30% crit damage bonus (Marksmanship 2:9)
TalentMap["2:9"] = {
    name = "Mortal Shots",
    maxRank = 5,
    effects = {
        {
            type = MOD.CRIT_MULT_BONUS,
            value = 0.06,
            perRank = true,
        },
    },
}

-- Ranged Weapon Specialization: +1/2/3/4/5% ranged damage (Marksmanship 2:13)
TalentMap["2:13"] = {
    name = "Ranged Weapon Specialization",
    maxRank = 5,
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.01,
            perRank = true,
            stacking = "additive",
        },
    },
}

-------------------------------------------------------------------------------
-- Survival (Tab 3)
-- 3:1  Humanoid Slaying (3)               3:2  Lightning Reflexes (5)
-- 3:3  Entrapment (3)                     3:4  Improved Wing Clip (3)
-- 3:5  Clever Traps (2)                   3:6  Deterrence (1)
-- 3:7  Improved Feign Death (2)           3:8  Surefooted (3)
-- 3:9  Deflection (5)                     3:10 Counterattack (1)
-- 3:11 Killer Instinct (3)               3:12 Trap Mastery (2)
-- 3:13 Wyvern Sting (1)                  3:14 Savage Strikes (2)
-- 3:15 Survivalist (5)                   3:16 Monster Slaying (3)
-- 3:17 Resourcefulness (3)              3:18 Survival Instincts (2)
-- 3:19 Thrill of the Hunt (3)           3:20 Expose Weakness (3)
-- 3:21 Master Tactician (5)             3:22 Readiness (1)
-- 3:23 Hawk Eye (3)
-------------------------------------------------------------------------------

-- Humanoid Slaying: +1/2/3% damage vs Humanoids (Survival 3:1)
TalentMap["3:1"] = {
    name = "Humanoid Slaying",
    maxRank = 3,
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.01,
            perRank = true,
            stacking = "additive",
            filter = { creatureTypes = { "Humanoid" } },
        },
    },
}

-- Surefooted: +1/2/3% hit chance (Survival 3:8)
TalentMap["3:8"] = {
    name = "Surefooted",
    maxRank = 3,
    effects = {
        {
            type = MOD.SPELL_HIT_BONUS,
            value = 0.01,
            perRank = true,
        },
    },
}

-- Monster Slaying: +1/2/3% damage vs Beasts, Giants, Dragonkin (Survival 3:16)
-- NOTE: Requires creatureTypeFilter support in ModifierCalc
TalentMap["3:16"] = {
    name = "Monster Slaying",
    maxRank = 3,
    effects = {
        {
            type = MOD.DAMAGE_MULTIPLIER,
            value = 0.01,
            perRank = true,
            stacking = "additive",
            filter = { creatureTypes = { "Beast", "Giant", "Dragonkin" } },
        },
    },
}

-- Survival Instincts: +2/4% crit chance for all (Survival 3:18)
TalentMap["3:18"] = {
    name = "Survival Instincts",
    maxRank = 2,
    effects = {
        {
            type = MOD.CRIT_BONUS,
            value = 0.02,
            perRank = true,
        },
    },
}

-------------------------------------------------------------------------------
-- Merge into global TalentMap
-------------------------------------------------------------------------------
for key, data in pairs(TalentMap) do
    ns.TalentMap["HUNTER:" .. key] = data
end
