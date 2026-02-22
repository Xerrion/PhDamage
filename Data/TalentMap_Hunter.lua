local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Hunter Talent Modifiers — TBC Anniversary (2.5.5)
-- Source of truth: Wowhead TBC Classic
-------------------------------------------------------------------------------

local MOD = ns.MOD

local TalentMap = {}

-------------------------------------------------------------------------------
-- Beast Mastery (Tab 1)
-------------------------------------------------------------------------------

-- Focused Fire: +1/2% all damage when pet is active
-- NOTE: Requires pet to be active — always applied when talent is taken
-- (Pet is almost always out for BM hunters)
TalentMap["1:3"] = {
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
-------------------------------------------------------------------------------

-- Lethal Shots: +1/2/3/4/5% ranged crit chance
TalentMap["2:2"] = {
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

-- Mortal Shots: +6/12/18/24/30% crit damage bonus
TalentMap["2:10"] = {
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

-- Barrage: +4/8/12% Multi-Shot and Volley damage
TalentMap["2:13"] = {
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

-- Ranged Weapon Specialization: +1/2/3/4/5% ranged damage
TalentMap["2:15"] = {
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

-- Improved Stings: +10/20/30% Serpent Sting damage
TalentMap["2:9"] = {
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

-------------------------------------------------------------------------------
-- Survival (Tab 3)
-------------------------------------------------------------------------------

-- Monster Slaying: +1/2/3% damage vs Beasts, Giants, Dragonkin
-- NOTE: Requires creatureTypeFilter support in ModifierCalc
TalentMap["3:1"] = {
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

-- Humanoid Slaying: +1/2/3% damage vs Humanoids
TalentMap["3:2"] = {
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

-- Surefooted: +1/2/3% hit chance
TalentMap["3:12"] = {
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

-- Survival Instincts: +2/4% crit chance for all
TalentMap["3:14"] = {
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
