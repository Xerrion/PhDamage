-------------------------------------------------------------------------------
-- test_rogue_talents
-- Tests for Rogue talent modifiers
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeRogueState = bootstrap.makeRogueState
local Pipeline = ns.Engine.Pipeline

-------------------------------------------------------------------------------
-- Default Rogue state reference (from bootstrap):
--   attackPower = 2000, weapon 130-243, ONE_HAND (norm 2.4), speed 2.6
--   meleeCrit = 0.25, meleeHit = 0, targetArmor = 0
--   attackingFromBehind = true, targetLevel = 73
--
-- AP bonus (ONE_HAND): 2000 / 14 * 2.4 = 342.857
-- AP bonus (DAGGER):   2000 / 14 * 1.7 = 242.857
--
-- Dagger state: 100-187 dmg, 1.8 speed, DAGGER type
--
-- Base values (no talents):
--   Sinister Strike R10:  min = 570.857,  max = 683.857
--   Backstab R10 (dagger): min = 896.786,  max = 1027.286
--   Eviscerate R10:       min = 1285,      max = 1405,     avg = 1345
--   Mutilate R4 (dagger): min = 443.857,   max = 530.857
--   Garrote R8:           totalDmg = 1170
--   Ambush R7 (dagger):   min = 1864.107,  max = 2103.357
--   Gouge R6:             min = 105,        max = 105
--   Shiv R1 (ONE_HAND):   min = 472.857,   max = 585.857
--   Hemorrhage R4:        min = 520.143,    max = 644.443
--   Rupture R7:           totalDmg = 1480
--   Instant Poison R7:    min = 146,        max = 194
--   Envenom R2:           min = 1200,       max = 1200
--   Ghostly Strike R1:    min = 591.071,    max = 732.321
--
-- Base melee hit probability: 1 - 0.08 - 0.065 = 0.855
-- Base crit mult (melee): 2.0
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Helper: create a dagger-equipped rogue state for Backstab/Ambush/Mutilate
-------------------------------------------------------------------------------
local function makeDaggerRogueState()
    local state = makeRogueState()
    state.stats.mainHandWeaponType = "DAGGER"
    state.stats.mainHandWeaponDmgMin = 100
    state.stats.mainHandWeaponDmgMax = 187
    state.stats.mainHandWeaponSpeed = 1.8
    return state
end

describe("Rogue Talents", function()

    ---------------------------------------------------------------------------
    -- 1. Improved Eviscerate (1:1) — +5%/rank DAMAGE_MULT on Eviscerate
    --    3 ranks, additive
    ---------------------------------------------------------------------------
    describe("Improved Eviscerate", function()

        it("should increase Eviscerate damage by 15% at 3/3", function()
            local state = makeRogueState()
            state.talents["1:1"] = 3
            local r = Pipeline.Calculate(2098, state)
            -- avg = 1345 * 1.15 = 1546.75
            local expectedMin = 1285 * 1.15
            local expectedMax = 1405 * 1.15
            assert.is_near(expectedMin, r.minDmg, 0.1)
            assert.is_near(expectedMax, r.maxDmg, 0.1)
        end)

        it("should increase Eviscerate damage by 5% at 1/3", function()
            local state = makeRogueState()
            state.talents["1:1"] = 1
            local r = Pipeline.Calculate(2098, state)
            assert.is_near(1285 * 1.05, r.minDmg, 0.1)
            assert.is_near(1405 * 1.05, r.maxDmg, 0.1)
        end)

        it("should not affect Sinister Strike", function()
            local state = makeRogueState()
            state.talents["1:1"] = 3
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
            assert.is_near(683.86, r.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Malice (1:3) — +1%/rank CRIT_BONUS global, 5 ranks
    ---------------------------------------------------------------------------
    describe("Malice", function()

        it("should add 5% crit at 5/5", function()
            local state = makeRogueState()
            state.talents["1:3"] = 5
            local r = Pipeline.Calculate(1752, state)  -- Sinister Strike
            -- critChance = 0.25 + 0.05 = 0.30
            assert.is_near(0.30, r.critChance, 0.001)
        end)

        it("should add 3% crit at 3/5", function()
            local state = makeRogueState()
            state.talents["1:3"] = 3
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(0.28, r.critChance, 0.001)
        end)

        it("should apply to all melee abilities", function()
            local state = makeDaggerRogueState()
            state.talents["1:3"] = 5
            local r = Pipeline.Calculate(53, state)  -- Backstab
            assert.is_near(0.30, r.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Murder (1:5) — +1%/rank DAMAGE_MULT, 2 ranks, additive
    --    filter = { creatureTypes = Humanoid/Giant/Beast/Dragonkin/Critter }
    ---------------------------------------------------------------------------
    describe("Murder", function()

        it("should increase damage by 2% vs Humanoid at 2/2", function()
            local state = makeRogueState()
            state.talents["1:5"] = 2
            state.targetCreatureType = "Humanoid"
            local r = Pipeline.Calculate(1752, state)  -- Sinister Strike
            -- SS min * 1.02
            assert.is_near(570.857 * 1.02, r.minDmg, 0.1)
            assert.is_near(683.857 * 1.02, r.maxDmg, 0.1)
        end)

        it("should increase damage by 2% vs Beast at 2/2", function()
            local state = makeRogueState()
            state.talents["1:5"] = 2
            state.targetCreatureType = "Beast"
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.857 * 1.02, r.minDmg, 0.1)
        end)

        it("should not apply vs Undead", function()
            local state = makeRogueState()
            state.talents["1:5"] = 2
            state.targetCreatureType = "Undead"
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
            assert.is_near(683.86, r.maxDmg, 0.01)
        end)

        it("should not apply when no target creature type set", function()
            local state = makeRogueState()
            state.talents["1:5"] = 2
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Puncturing Wounds (1:6)
    --    +10%/rank CRIT on Backstab, +5%/rank CRIT on Mutilate, 3 ranks
    ---------------------------------------------------------------------------
    describe("Puncturing Wounds", function()

        it("should add 30% crit to Backstab at 3/3", function()
            local state = makeDaggerRogueState()
            state.talents["1:6"] = 3
            local r = Pipeline.Calculate(53, state)
            -- critChance = 0.25 + 0.30 = 0.55
            assert.is_near(0.55, r.critChance, 0.001)
        end)

        it("should add 15% crit to Mutilate at 3/3", function()
            local state = makeDaggerRogueState()
            state.talents["1:6"] = 3
            local r = Pipeline.Calculate(1329, state)
            -- critChance = 0.25 + 0.15 = 0.40
            assert.is_near(0.40, r.critChance, 0.001)
        end)

        it("should not affect Sinister Strike", function()
            local state = makeRogueState()
            state.talents["1:6"] = 3
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(0.25, r.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Lethality (1:9) — +6%/rank CRIT_MULT_BONUS, 5 ranks
    --    filter on SS, Gouge, BS, Ghostly Strike, Mutilate, Shiv, Hemorrhage
    ---------------------------------------------------------------------------
    describe("Lethality", function()

        it("should increase crit multiplier by 0.30 on Sinister Strike at 5/5", function()
            local state = makeRogueState()
            state.talents["1:9"] = 5
            local r = Pipeline.Calculate(1752, state)
            -- critMult = 2.0 + 0.30 = 2.30
            assert.is_near(2.30, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.30 on Backstab at 5/5", function()
            local state = makeDaggerRogueState()
            state.talents["1:9"] = 5
            local r = Pipeline.Calculate(53, state)
            assert.is_near(2.30, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.30 on Gouge at 5/5", function()
            local state = makeRogueState()
            state.talents["1:9"] = 5
            local r = Pipeline.Calculate(1776, state)
            assert.is_near(2.30, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.30 on Ghostly Strike at 5/5", function()
            local state = makeRogueState()
            state.talents["1:9"] = 5
            local r = Pipeline.Calculate(14278, state)
            assert.is_near(2.30, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.30 on Mutilate at 5/5", function()
            local state = makeDaggerRogueState()
            state.talents["1:9"] = 5
            local r = Pipeline.Calculate(1329, state)
            assert.is_near(2.30, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.30 on Shiv at 5/5", function()
            local state = makeRogueState()
            state.talents["1:9"] = 5
            local r = Pipeline.Calculate(5938, state)
            assert.is_near(2.30, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.30 on Hemorrhage at 5/5", function()
            local state = makeRogueState()
            state.talents["1:9"] = 5
            local r = Pipeline.Calculate(16511, state)
            assert.is_near(2.30, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.12 at 2/5", function()
            local state = makeRogueState()
            state.talents["1:9"] = 2
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(2.12, r.critMult, 0.001)
        end)

        it("should not affect Eviscerate", function()
            local state = makeRogueState()
            state.talents["1:9"] = 5
            local r = Pipeline.Calculate(2098, state)
            assert.is_near(2.0, r.critMult, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 6. Vile Poisons (1:10) — +4%/rank DAMAGE_MULT on poisons + Envenom
    --    5 ranks, additive
    ---------------------------------------------------------------------------
    describe("Vile Poisons", function()

        it("should increase Instant Poison damage by 20% at 5/5", function()
            local state = makeRogueState()
            state.talents["1:10"] = 5
            local r = Pipeline.Calculate(8679, state)  -- Instant Poison R7
            -- min = 146 * 1.20 = 175.2, max = 194 * 1.20 = 232.8
            assert.is_near(175.2, r.minDmg, 0.1)
            assert.is_near(232.8, r.maxDmg, 0.1)
        end)

        it("should increase Deadly Poison damage by 20% at 5/5", function()
            local state = makeRogueState()
            state.talents["1:10"] = 5
            local r = Pipeline.Calculate(2823, state)  -- Deadly Poison R7
            -- totalDmg = 180 * 1.20 = 216
            assert.is_near(216, r.totalDmg, 0.1)
        end)

        it("should increase Wound Poison damage by 20% at 5/5", function()
            local state = makeRogueState()
            state.talents["1:10"] = 5
            local r = Pipeline.Calculate(13219, state)  -- Wound Poison R5
            -- min = max = 65 * 1.20 = 78
            assert.is_near(78, r.minDmg, 0.1)
            assert.is_near(78, r.maxDmg, 0.1)
        end)

        it("should increase Envenom damage by 20% at 5/5", function()
            local state = makeRogueState()
            state.talents["1:10"] = 5
            local r = Pipeline.Calculate(32645, state)  -- Envenom R2
            -- min = max = 1200 * 1.20 = 1440
            assert.is_near(1440, r.minDmg, 1)
            assert.is_near(1440, r.maxDmg, 1)
        end)

        it("should increase Instant Poison damage by 8% at 2/5", function()
            local state = makeRogueState()
            state.talents["1:10"] = 2
            local r = Pipeline.Calculate(8679, state)
            assert.is_near(146 * 1.08, r.minDmg, 0.1)
            assert.is_near(194 * 1.08, r.maxDmg, 0.1)
        end)

        it("should not affect Sinister Strike", function()
            local state = makeRogueState()
            state.talents["1:10"] = 5
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
            assert.is_near(683.86, r.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 7. Precision (2:6) — +1%/rank SPELL_HIT_BONUS, 5 ranks
    ---------------------------------------------------------------------------
    describe("Precision", function()

        it("should increase hit probability by 5% at 5/5", function()
            local state = makeRogueState()
            state.talents["2:6"] = 5
            local r = Pipeline.Calculate(1752, state)  -- Sinister Strike
            -- missChance = max(0, 0.08 - 0.05) = 0.03
            -- dodgeChance = 0.065
            -- hitProbability = 1 - 0.03 - 0.065 = 0.905
            assert.is_near(0.905, r.hitProbability, 0.001)
        end)

        it("should have base hit probability of 0.855 without talent", function()
            local state = makeRogueState()
            local r = Pipeline.Calculate(1752, state)
            -- 1 - 0.08 - 0.065 = 0.855
            assert.is_near(0.855, r.hitProbability, 0.001)
        end)

        it("should increase hit probability by 3% at 3/5", function()
            local state = makeRogueState()
            state.talents["2:6"] = 3
            local r = Pipeline.Calculate(1752, state)
            -- missChance = max(0, 0.08 - 0.03) = 0.05
            -- hitProbability = 1 - 0.05 - 0.065 = 0.885
            assert.is_near(0.885, r.hitProbability, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 8. Dagger Specialization (2:11) — +1%/rank CRIT_BONUS global, 5 ranks
    ---------------------------------------------------------------------------
    describe("Dagger Specialization", function()

        it("should add 5% crit at 5/5", function()
            local state = makeRogueState()
            state.talents["2:11"] = 5
            local r = Pipeline.Calculate(1752, state)  -- Sinister Strike
            -- critChance = 0.25 + 0.05 = 0.30
            assert.is_near(0.30, r.critChance, 0.001)
        end)

        it("should add 3% crit at 3/5", function()
            local state = makeRogueState()
            state.talents["2:11"] = 3
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(0.28, r.critChance, 0.001)
        end)

        it("should apply to all melee abilities", function()
            local state = makeDaggerRogueState()
            state.talents["2:11"] = 5
            local r = Pipeline.Calculate(53, state)  -- Backstab
            assert.is_near(0.30, r.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 9. Fist Weapon Specialization (2:16) — +1%/rank CRIT_BONUS global, 5 ranks
    ---------------------------------------------------------------------------
    describe("Fist Weapon Specialization", function()

        it("should add 5% crit at 5/5", function()
            local state = makeRogueState()
            state.talents["2:16"] = 5
            local r = Pipeline.Calculate(1752, state)  -- Sinister Strike
            -- critChance = 0.25 + 0.05 = 0.30
            assert.is_near(0.30, r.critChance, 0.001)
        end)

        it("should add 2% crit at 2/5", function()
            local state = makeRogueState()
            state.talents["2:16"] = 2
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(0.27, r.critChance, 0.001)
        end)

        it("should apply to all melee abilities", function()
            local state = makeDaggerRogueState()
            state.talents["2:16"] = 5
            local r = Pipeline.Calculate(53, state)  -- Backstab
            assert.is_near(0.30, r.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 10. Aggression (2:19) — +2%/rank DAMAGE_MULT on SS/BS/Evis
    --     3 ranks, additive
    ---------------------------------------------------------------------------
    describe("Aggression", function()

        it("should increase Sinister Strike damage by 6% at 3/3", function()
            local state = makeRogueState()
            state.talents["2:19"] = 3
            local r = Pipeline.Calculate(1752, state)
            -- SS min = 570.857 * 1.06 = 605.108
            assert.is_near(570.857 * 1.06, r.minDmg, 0.1)
            assert.is_near(683.857 * 1.06, r.maxDmg, 0.1)
        end)

        it("should increase Backstab damage by 6% at 3/3", function()
            local state = makeDaggerRogueState()
            state.talents["2:19"] = 3
            local r = Pipeline.Calculate(53, state)
            assert.is_near(896.786 * 1.06, r.minDmg, 0.1)
            assert.is_near(1027.286 * 1.06, r.maxDmg, 0.1)
        end)

        it("should increase Eviscerate damage by 6% at 3/3", function()
            local state = makeRogueState()
            state.talents["2:19"] = 3
            local r = Pipeline.Calculate(2098, state)
            -- Evis avg = 1345 * 1.06 = 1425.7
            assert.is_near(1285 * 1.06, r.minDmg, 0.1)
            assert.is_near(1405 * 1.06, r.maxDmg, 0.1)
        end)

        it("should not affect Hemorrhage", function()
            local state = makeRogueState()
            state.talents["2:19"] = 3
            local r = Pipeline.Calculate(16511, state)
            assert.is_near(520.14, r.minDmg, 0.01)
            assert.is_near(644.44, r.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 11. Surprise Attacks (2:24) — +10% DAMAGE_MULT on SS/BS/Shiv/Gouge
    --     1 rank, additive
    ---------------------------------------------------------------------------
    describe("Surprise Attacks", function()

        it("should increase Sinister Strike damage by 10% at 1/1", function()
            local state = makeRogueState()
            state.talents["2:24"] = 1
            local r = Pipeline.Calculate(1752, state)
            -- SS min = 570.857 * 1.10 = 627.943
            assert.is_near(570.857 * 1.10, r.minDmg, 0.1)
            assert.is_near(683.857 * 1.10, r.maxDmg, 0.1)
        end)

        it("should increase Backstab damage by 10% at 1/1", function()
            local state = makeDaggerRogueState()
            state.talents["2:24"] = 1
            local r = Pipeline.Calculate(53, state)
            assert.is_near(896.786 * 1.10, r.minDmg, 0.1)
            assert.is_near(1027.286 * 1.10, r.maxDmg, 0.1)
        end)

        it("should increase Shiv damage by 10% at 1/1", function()
            local state = makeRogueState()
            state.talents["2:24"] = 1
            local r = Pipeline.Calculate(5938, state)
            assert.is_near(472.857 * 1.10, r.minDmg, 0.1)
            assert.is_near(585.857 * 1.10, r.maxDmg, 0.1)
        end)

        it("should increase Gouge damage by 10% at 1/1", function()
            local state = makeRogueState()
            state.talents["2:24"] = 1
            local r = Pipeline.Calculate(1776, state)
            assert.is_near(105 * 1.10, r.minDmg, 0.1)
            assert.is_near(105 * 1.10, r.maxDmg, 0.1)
        end)

        it("should not affect Eviscerate", function()
            local state = makeRogueState()
            state.talents["2:24"] = 1
            local r = Pipeline.Calculate(2098, state)
            assert.is_near(1285, r.minDmg, 1)
            assert.is_near(1405, r.maxDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 12. Opportunity (3:2) — +4%/rank DAMAGE_MULT on BS/Mutilate/Garrote/Ambush
    --     5 ranks, additive
    ---------------------------------------------------------------------------
    describe("Opportunity", function()

        it("should increase Backstab damage by 20% at 5/5", function()
            local state = makeDaggerRogueState()
            state.talents["3:2"] = 5
            local r = Pipeline.Calculate(53, state)
            -- BS R10 min = 896.786 * 1.20 = 1076.143
            assert.is_near(896.786 * 1.20, r.minDmg, 0.1)
            assert.is_near(1027.286 * 1.20, r.maxDmg, 0.1)
        end)

        it("should increase Mutilate damage by 20% at 5/5", function()
            local state = makeDaggerRogueState()
            state.talents["3:2"] = 5
            local r = Pipeline.Calculate(1329, state)
            assert.is_near(443.857 * 1.20, r.minDmg, 0.1)
            assert.is_near(530.857 * 1.20, r.maxDmg, 0.1)
        end)

        it("should increase Garrote damage by 20% at 5/5", function()
            local state = makeRogueState()
            state.talents["3:2"] = 5
            local r = Pipeline.Calculate(703, state)
            -- Garrote R8 totalDmg = 1170 * 1.20 = 1404
            assert.is_near(1170 * 1.20, r.totalDmg, 1)
        end)

        it("should increase Ambush damage by 20% at 5/5", function()
            local state = makeDaggerRogueState()
            state.talents["3:2"] = 5
            local r = Pipeline.Calculate(8676, state)
            assert.is_near(1864.107 * 1.20, r.minDmg, 0.1)
            assert.is_near(2103.357 * 1.20, r.maxDmg, 0.1)
        end)

        it("should not affect Sinister Strike", function()
            local state = makeRogueState()
            state.talents["3:2"] = 5
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
            assert.is_near(683.86, r.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 13. Improved Ambush (3:8) — +15%/rank CRIT_BONUS on Ambush, 3 ranks
    ---------------------------------------------------------------------------
    describe("Improved Ambush", function()

        it("should add 30% crit to Ambush at 2/3", function()
            local state = makeDaggerRogueState()
            state.talents["3:8"] = 2
            local r = Pipeline.Calculate(8676, state)
            -- critChance = 0.25 + 0.30 = 0.55
            assert.is_near(0.55, r.critChance, 0.001)
        end)

        it("should add 45% crit to Ambush at 3/3", function()
            local state = makeDaggerRogueState()
            state.talents["3:8"] = 3
            local r = Pipeline.Calculate(8676, state)
            -- critChance = 0.25 + 0.45 = 0.70
            assert.is_near(0.70, r.critChance, 0.001)
        end)

        it("should not affect Backstab", function()
            local state = makeDaggerRogueState()
            state.talents["3:8"] = 3
            local r = Pipeline.Calculate(53, state)
            assert.is_near(0.25, r.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 14. Serrated Blades (3:11) — +10%/rank DAMAGE_MULT on Rupture
    --     3 ranks, additive
    ---------------------------------------------------------------------------
    describe("Serrated Blades", function()

        it("should increase Rupture damage by 30% at 3/3", function()
            local state = makeRogueState()
            state.talents["3:11"] = 3
            local r = Pipeline.Calculate(1943, state)
            -- Rupture R7 totalDmg = 1480 * 1.30 = 1924
            assert.is_near(1480 * 1.30, r.totalDmg, 1)
        end)

        it("should increase Rupture damage by 10% at 1/3", function()
            local state = makeRogueState()
            state.talents["3:11"] = 1
            local r = Pipeline.Calculate(1943, state)
            assert.is_near(1480 * 1.10, r.totalDmg, 1)
        end)

        it("should not affect Sinister Strike", function()
            local state = makeRogueState()
            state.talents["3:11"] = 3
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
            assert.is_near(683.86, r.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 15. Heightened Senses (3:12) — +2%/rank HIT, 2 ranks
    ---------------------------------------------------------------------------
    describe("Heightened Senses", function()

        it("should increase hit probability by 4% at 2/2", function()
            local state = makeRogueState()
            state.talents["3:12"] = 2
            local r = Pipeline.Calculate(1752, state)  -- Sinister Strike
            -- missChance = max(0, 0.08 - 0.04) = 0.04
            -- dodgeChance = 0.065
            -- hitProbability = 1 - 0.04 - 0.065 = 0.895
            assert.is_near(0.895, r.hitProbability, 0.001)
        end)

        it("should increase hit probability by 2% at 1/2", function()
            local state = makeRogueState()
            state.talents["3:12"] = 1
            local r = Pipeline.Calculate(1752, state)
            -- missChance = max(0, 0.08 - 0.02) = 0.06
            -- hitProbability = 1 - 0.06 - 0.065 = 0.875
            assert.is_near(0.875, r.hitProbability, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 16. Dirty Deeds (3:14) — +10%/rank DAMAGE_MULT global, 2 ranks,
    --     additive, targetHealthBelow = 0.35
    ---------------------------------------------------------------------------
    describe("Dirty Deeds", function()

        it("should increase damage by 20% when target below 35% HP at 2/2", function()
            local state = makeRogueState()
            state.talents["3:14"] = 2
            state.targetHealthPercent = 30  -- Below 35%
            local r = Pipeline.Calculate(1752, state)  -- Sinister Strike
            -- SS min = 570.857 * 1.20 = 685.029
            assert.is_near(570.857 * 1.20, r.minDmg, 0.1)
            assert.is_near(683.857 * 1.20, r.maxDmg, 0.1)
        end)

        it("should increase damage by 10% at 1/2 when target below 35%", function()
            local state = makeRogueState()
            state.talents["3:14"] = 1
            state.targetHealthPercent = 20
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.857 * 1.10, r.minDmg, 0.1)
            assert.is_near(683.857 * 1.10, r.maxDmg, 0.1)
        end)

        it("should not apply when target at 50% HP", function()
            local state = makeRogueState()
            state.talents["3:14"] = 2
            state.targetHealthPercent = 50
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
            assert.is_near(683.86, r.maxDmg, 0.01)
        end)

        it("should not apply when target at exactly 35% HP", function()
            local state = makeRogueState()
            state.talents["3:14"] = 2
            state.targetHealthPercent = 35
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
        end)

        it("should apply globally to all spells when target below 35%", function()
            local state = makeDaggerRogueState()
            state.talents["3:14"] = 2
            state.targetHealthPercent = 20
            local r = Pipeline.Calculate(53, state)  -- Backstab
            assert.is_near(896.786 * 1.20, r.minDmg, 0.1)
            assert.is_near(1027.286 * 1.20, r.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 17. Sinister Calling (3:21) — +1%/rank DAMAGE_MULT on BS/Hemo
    --     5 ranks, additive
    ---------------------------------------------------------------------------
    describe("Sinister Calling", function()

        it("should increase Backstab damage by 5% at 5/5", function()
            local state = makeDaggerRogueState()
            state.talents["3:21"] = 5
            local r = Pipeline.Calculate(53, state)
            -- BS R10 min = 896.786 * 1.05 = 941.625
            assert.is_near(896.786 * 1.05, r.minDmg, 0.1)
            assert.is_near(1027.286 * 1.05, r.maxDmg, 0.1)
        end)

        it("should increase Hemorrhage damage by 5% at 5/5", function()
            local state = makeRogueState()
            state.talents["3:21"] = 5
            local r = Pipeline.Calculate(16511, state)
            -- Hemo R4 min = 520.143 * 1.05 = 546.150
            assert.is_near(520.143 * 1.05, r.minDmg, 0.1)
            assert.is_near(644.443 * 1.05, r.maxDmg, 0.1)
        end)

        it("should increase Backstab damage by 2% at 2/5", function()
            local state = makeDaggerRogueState()
            state.talents["3:21"] = 2
            local r = Pipeline.Calculate(53, state)
            assert.is_near(896.786 * 1.02, r.minDmg, 0.1)
            assert.is_near(1027.286 * 1.02, r.maxDmg, 0.1)
        end)

        it("should not affect Sinister Strike", function()
            local state = makeRogueState()
            state.talents["3:21"] = 5
            local r = Pipeline.Calculate(1752, state)
            assert.is_near(570.86, r.minDmg, 0.01)
            assert.is_near(683.86, r.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Talent Stacking Tests
    ---------------------------------------------------------------------------
    describe("Stacking", function()

        it("Aggression + Surprise Attacks should stack additively on SS", function()
            local state = makeRogueState()
            state.talents["2:19"] = 3  -- Aggression +6%
            state.talents["2:24"] = 1  -- Surprise Attacks +10%
            local r = Pipeline.Calculate(1752, state)
            -- Total additive: 1 + 0.06 + 0.10 = 1.16
            assert.is_near(570.857 * 1.16, r.minDmg, 0.1)
            assert.is_near(683.857 * 1.16, r.maxDmg, 0.1)
        end)

        it("Opportunity + Sinister Calling should stack additively on BS", function()
            local state = makeDaggerRogueState()
            state.talents["3:2"] = 5   -- Opportunity +20%
            state.talents["3:21"] = 5  -- Sinister Calling +5%
            local r = Pipeline.Calculate(53, state)
            -- Total additive: 1 + 0.20 + 0.05 = 1.25
            assert.is_near(896.786 * 1.25, r.minDmg, 0.1)
            assert.is_near(1027.286 * 1.25, r.maxDmg, 0.1)
        end)

        it("Malice + Puncturing Wounds should stack crit on BS", function()
            local state = makeDaggerRogueState()
            state.talents["1:3"] = 5  -- Malice +5% crit
            state.talents["1:6"] = 3  -- Puncturing Wounds +30% BS crit
            local r = Pipeline.Calculate(53, state)
            -- critChance = 0.25 + 0.05 + 0.30 = 0.60
            assert.is_near(0.60, r.critChance, 0.001)
        end)

        it("Improved Eviscerate + Aggression should stack additively on Evis", function()
            local state = makeRogueState()
            state.talents["1:1"] = 3   -- Imp Evis +15%
            state.talents["2:19"] = 3  -- Aggression +6%
            local r = Pipeline.Calculate(2098, state)
            -- Total additive: 1 + 0.15 + 0.06 = 1.21
            assert.is_near(1285 * 1.21, r.minDmg, 0.1)
            assert.is_near(1405 * 1.21, r.maxDmg, 0.1)
        end)

        it("Opportunity + Aggression + Surprise Attacks should stack on BS", function()
            local state = makeDaggerRogueState()
            state.talents["3:2"] = 5   -- Opportunity +20%
            state.talents["2:19"] = 3  -- Aggression +6%
            state.talents["2:24"] = 1  -- Surprise Attacks +10%
            local r = Pipeline.Calculate(53, state)
            -- Total additive: 1 + 0.20 + 0.06 + 0.10 = 1.36
            assert.is_near(896.786 * 1.36, r.minDmg, 0.1)
            assert.is_near(1027.286 * 1.36, r.maxDmg, 0.1)
        end)

        it("Precision + Heightened Senses should stack hit on SS", function()
            local state = makeRogueState()
            state.talents["2:6"] = 5   -- Precision +5% hit
            state.talents["3:12"] = 2  -- Heightened Senses +4% hit
            local r = Pipeline.Calculate(1752, state)
            -- missChance = max(0, 0.08 - 0.09) = 0
            -- hitProbability = 1 - 0 - 0.065 = 0.935
            assert.is_near(0.935, r.hitProbability, 0.001)
        end)

        it("Malice + Dagger Spec should stack crit globally", function()
            local state = makeRogueState()
            state.talents["1:3"] = 5   -- Malice +5% crit
            state.talents["2:11"] = 5  -- Dagger Spec +5% crit
            local r = Pipeline.Calculate(1752, state)
            -- critChance = 0.25 + 0.05 + 0.05 = 0.35
            assert.is_near(0.35, r.critChance, 0.001)
        end)
    end)
end)
