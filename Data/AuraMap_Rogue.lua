-------------------------------------------------------------------------------
-- AuraMap_Rogue.lua
-- Rogue-relevant buff and debuff effects mapped to modifier descriptors
-- SpellIDs sourced from Wowhead TBC Classic tooltip API
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local MOD = ns.MOD

local AuraMap = {}

-------------------------------------------------------------------------------
-- Player Buffs (target = "player")
-------------------------------------------------------------------------------

-- Cold Blood (talent active): +100% crit on next offensive ability
-- Buff spellID is the same as the talent/spell ID (14177)
AuraMap[14177] = {
    name = "Cold Blood",
    target = "player",
    effects = {
        { type = MOD.CRIT_BONUS, value = 1.00 },
    },
}

-- Remorseless Attacks (proc after killing target that yields XP/honor)
-- Rank 1 buff (14143): +20% crit on next SS/BS/Hemo/Ambush/GS/Mutilate
AuraMap[14143] = {
    name = "Remorseless",
    target = "player",
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.20,
          filter = { spellNames = {
            "Sinister Strike", "Backstab", "Hemorrhage",
            "Ambush", "Ghostly Strike", "Mutilate",
          } } },
    },
}

-- Remorseless Attacks Rank 2 buff (14149): +40% crit
AuraMap[14149] = {
    name = "Remorseless",
    target = "player",
    effects = {
        { type = MOD.CRIT_BONUS, value = 0.40,
          filter = { spellNames = {
            "Sinister Strike", "Backstab", "Hemorrhage",
            "Ambush", "Ghostly Strike", "Mutilate",
          } } },
    },
}

-- Shadowstep damage buff (36563): +20% damage on next ability, 10 sec
-- Applied after using Shadowstep (36554). Separate buff spellID.
-- Affects: SS, BS, Ambush, Hemo, Evis, Envenom, Ghostly Strike,
--          Garrote, Rupture, Riposte
AuraMap[36563] = {
    name = "Shadowstep",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.20 },
    },
}

-- Find Weakness (proc after finishing move): +X% damage for 10 sec
-- Each talent rank has its own buff spellID with a fixed value.
-- Rank 1 (31234): +2% damage
AuraMap[31234] = {
    name = "Find Weakness",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.02 },
    },
}

-- Find Weakness Rank 2 (31235): +4% damage
AuraMap[31235] = {
    name = "Find Weakness",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.04 },
    },
}

-- Find Weakness Rank 3 (31236): +6% damage
AuraMap[31236] = {
    name = "Find Weakness",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.06 },
    },
}

-- Find Weakness Rank 4 (31237): +8% damage
AuraMap[31237] = {
    name = "Find Weakness",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.08 },
    },
}

-- Find Weakness Rank 5 (31238): +10% damage
AuraMap[31238] = {
    name = "Find Weakness",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10 },
    },
}

-- Master of Subtlety (31665): damage bonus while stealthed + 6 sec after
-- The buff is always aura 31665 regardless of talent rank. Hardcoded at
-- 3/3 (10%) since that is the most common case and StateCollector can
-- read the actual buff value at runtime for precise overrides.
-- Actual talent scaling is non-linear: R1=4%, R2=7%, R3=10%.
AuraMap[31665] = {
    name = "Master of Subtlety",
    target = "player",
    effects = {
        { type = MOD.DAMAGE_MULTIPLIER, value = 0.10 },
    },
    -- Note: Hardcoded at 3/3 Master of Subtlety (10%). Actual scaling is 4/7/10%.
}

-- Blade Flurry (13877): +20% attack speed, cleave to nearby target
-- Attack speed is not a direct damage multiplier in the engine yet.
-- Included for forward-compatibility when melee haste support is added.
-- NOTE: The cleave component (hitting a second nearby target) is not
-- modeled as it's a separate hit, not a damage increase on the primary.
AuraMap[13877] = {
    name = "Blade Flurry",
    target = "player",
    -- Attack speed buff — no damage modifier effects yet
    effects = {},
}

-- Slice and Dice Rank 1 (5171): +20% attack speed
-- Attack speed is not a direct damage multiplier in the engine yet.
-- Included for forward-compatibility.
AuraMap[5171] = {
    name = "Slice and Dice",
    target = "player",
    effects = {},
}

-- Slice and Dice Rank 2 (6774): +30% attack speed
AuraMap[6774] = {
    name = "Slice and Dice",
    target = "player",
    effects = {},
}

-------------------------------------------------------------------------------
-- Target Debuffs (target = "target")
-------------------------------------------------------------------------------

-- Improved Kidney Shot: the +3/6/9% damage taken debuff is baked into the
-- Kidney Shot stun debuff itself (408 R1, 8643 R2). It is a passive talent
-- modifier on the Kidney Shot spell, not a separate debuff aura. The engine
-- would need to detect Kidney Shot on the target AND know the Rogue's talent
-- rank. For now, this is not modeled in AuraMap.

-- Hemorrhage debuff: causes the target to take additional physical damage
-- from each hit (flat bonus per hit, not a percentage). This is applied by
-- the Hemorrhage ability. The flat bonus per hit is small and difficult to
-- model accurately as a percentage-based modifier. Deferred.

for spellID, data in pairs(AuraMap) do
    ns.AuraMap[spellID] = data
end
