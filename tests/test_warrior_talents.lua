-------------------------------------------------------------------------------
-- test_warrior_talents
-- Tests for Warrior talent modifiers
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeWarriorState = bootstrap.makeWarriorState
local Pipeline = ns.Engine.Pipeline

-------------------------------------------------------------------------------
-- Default Warrior state reference (from bootstrap):
--   attackPower = 2000, weapon 200-350, TWO_HAND (norm 3.3), speed 3.6
--   meleeCrit = 0.25, meleeHit = 0, targetArmor = 0
--   attackingFromBehind = true, targetLevel = 73
--
-- Mortal Strike (12294) base: min=881.43, max=1031.43
-- Overpower (7384) base:     min=706.43, max=856.43
-- Slam (1464) base:          min=811.43, max=961.43, castTime=1.5
-- Rend (772) base:           totalDmg=223.05
--
-- Base melee hit probability: 1 - 0.08 - 0.065 = 0.855
-- Base crit mult (melee): 2.0
-------------------------------------------------------------------------------

describe("Warrior Talents", function()

    ---------------------------------------------------------------------------
    -- Arms (Tab 1)
    ---------------------------------------------------------------------------
    describe("Improved Rend", function()

        it("should increase Rend damage by 75% at 3/3", function()
            local state = makeWarriorState()
            state.talents["1:6"] = 3
            local r = Pipeline.Calculate(772, state)
            -- totalDmg = 223.05 * (1 + 3 * 0.25) = 223.05 * 1.75
            assert.is_near(223.05 * 1.75, r.totalDmg, 0.1)
        end)

        it("should not affect Mortal Strike", function()
            local state = makeWarriorState()
            state.talents["1:6"] = 3
            local r = Pipeline.Calculate(12294, state)
            assert.is_near(881.43, r.minDmg, 0.01)
            assert.is_near(1031.43, r.maxDmg, 0.01)
        end)
    end)

    describe("Improved Overpower", function()

        it("should add 50% crit chance to Overpower at 2/2", function()
            local state = makeWarriorState()
            state.talents["1:10"] = 2
            local r = Pipeline.Calculate(7384, state)
            -- critChance = 0.25 + 2 * 0.25 = 0.75
            assert.is_near(0.75, r.critChance, 0.001)
        end)

        it("should not affect Mortal Strike crit", function()
            local state = makeWarriorState()
            state.talents["1:10"] = 2
            local r = Pipeline.Calculate(12294, state)
            assert.is_near(0.25, r.critChance, 0.001)
        end)
    end)

    describe("Two-Handed Weapon Specialization", function()

        it("should increase Mortal Strike damage by 5% at 5/5", function()
            local state = makeWarriorState()
            state.talents["1:15"] = 5
            local r = Pipeline.Calculate(12294, state)
            -- damage * (1 + 5 * 0.01) = damage * 1.05
            assert.is_near(881.43 * 1.05, r.minDmg, 0.1)
            assert.is_near(1031.43 * 1.05, r.maxDmg, 0.1)
        end)

        it("should apply to all melee abilities (no weapon filter yet)", function()
            local state = makeWarriorState()
            state.talents["1:15"] = 5
            local r = Pipeline.Calculate(7384, state)  -- Overpower
            assert.is_near(706.43 * 1.05, r.minDmg, 0.1)
            assert.is_near(856.43 * 1.05, r.maxDmg, 0.1)
        end)
    end)

    describe("Impale", function()

        it("should increase crit multiplier by 0.20 at 2/2", function()
            local state = makeWarriorState()
            state.talents["1:18"] = 2
            local r = Pipeline.Calculate(12294, state)
            -- critMult = 2.0 + 2 * 0.10 = 2.20
            assert.is_near(2.20, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.10 at 1/2", function()
            local state = makeWarriorState()
            state.talents["1:18"] = 1
            local r = Pipeline.Calculate(12294, state)
            assert.is_near(2.10, r.critMult, 0.001)
        end)
    end)

    describe("Poleaxe Specialization", function()

        it("should add 5% crit chance at 5/5", function()
            local state = makeWarriorState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(12294, state)
            -- critChance = 0.25 + 5 * 0.01 = 0.30
            assert.is_near(0.30, r.critChance, 0.001)
        end)

        it("should apply to all melee abilities", function()
            local state = makeWarriorState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(7384, state)  -- Overpower
            assert.is_near(0.30, r.critChance, 0.001)
        end)
    end)

    describe("Improved Mortal Strike", function()

        it("should increase Mortal Strike damage by 5% at 5/5", function()
            local state = makeWarriorState()
            state.talents["1:23"] = 5
            local r = Pipeline.Calculate(12294, state)
            -- damage * (1 + 5 * 0.01) = damage * 1.05
            assert.is_near(881.43 * 1.05, r.minDmg, 0.1)
            assert.is_near(1031.43 * 1.05, r.maxDmg, 0.1)
        end)

        it("should not affect Overpower", function()
            local state = makeWarriorState()
            state.talents["1:23"] = 5
            local r = Pipeline.Calculate(7384, state)
            assert.is_near(706.43, r.minDmg, 0.01)
            assert.is_near(856.43, r.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Fury (Tab 2)
    ---------------------------------------------------------------------------
    describe("Cruelty", function()

        it("should add 5% melee crit at 5/5", function()
            local state = makeWarriorState()
            state.talents["2:4"] = 5
            local r = Pipeline.Calculate(12294, state)
            -- critChance = 0.25 + 5 * 0.01 = 0.30
            assert.is_near(0.30, r.critChance, 0.001)
        end)

        it("should apply to all melee abilities", function()
            local state = makeWarriorState()
            state.talents["2:4"] = 5
            local r = Pipeline.Calculate(7384, state)  -- Overpower
            assert.is_near(0.30, r.critChance, 0.001)
        end)
    end)

    describe("Precision", function()

        it("should increase hit probability at 3/3", function()
            local state = makeWarriorState()
            state.talents["2:19"] = 3
            local r = Pipeline.Calculate(12294, state)
            -- missChance = max(0, 0.08 - 0.03) = 0.05
            -- dodgeChance = 0.065 (no expertise)
            -- hitProbability = 1 - 0.05 - 0.065 = 0.885
            assert.is_near(0.885, r.hitProbability, 0.001)
        end)

        it("should have base hit probability of 0.855 without talent", function()
            local state = makeWarriorState()
            local r = Pipeline.Calculate(12294, state)
            -- 1 - 0.08 - 0.065 = 0.855
            assert.is_near(0.855, r.hitProbability, 0.001)
        end)
    end)

    describe("Improved Slam", function()

        -- NOTE: Slam's raw cast time is reduced (1.5 -> 0.5 at 2/2), but
        -- the final result.castTime is clamped to max(hastedCast, GCD).
        -- With 0% haste, GCD = 1.5s, so the effective time stays 1.5.
        -- To observe the reduction we need enough haste to push GCD below
        -- the reduced cast time.

        it("should reduce effective cast time with high haste at 2/2", function()
            local state = makeWarriorState()
            state.talents["2:12"] = 2
            state.stats.meleeHaste = 1.0  -- 100% haste -> GCD = 0.75 -> clamped to 1.0
            local r = Pipeline.Calculate(1464, state)
            -- Raw cast = 1.5 - 1.0 = 0.5, hasted = 0.5 / 2.0 = 0.25
            -- GCD = 1.5 / 2.0 = 0.75, clamped to 1.0
            -- effectiveCastTime = max(0.25, 1.0) = 1.0
            assert.is_near(1.0, r.castTime, 0.01)
        end)

        it("should not reduce effective cast time without haste (GCD floor)", function()
            local state = makeWarriorState()
            state.talents["2:12"] = 2
            local r = Pipeline.Calculate(1464, state)
            -- Raw cast = 0.5, no haste, GCD = 1.5
            -- effectiveCastTime = max(0.5, 1.5) = 1.5
            assert.is_near(1.5, r.castTime, 0.01)
        end)

        it("should not affect Mortal Strike cast time", function()
            local state = makeWarriorState()
            state.talents["2:12"] = 2
            local rMS = Pipeline.Calculate(12294, state)
            local rBase = Pipeline.Calculate(12294, makeWarriorState())
            assert.is_near(rBase.castTime, rMS.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Stacking tests
    ---------------------------------------------------------------------------
    describe("Stacking", function()

        it("Cruelty 5/5 + Impale 2/2 should both apply to Mortal Strike", function()
            local state = makeWarriorState()
            state.talents["2:4"] = 5   -- Cruelty +5% crit
            state.talents["1:18"] = 2  -- Impale +0.20 crit mult
            local r = Pipeline.Calculate(12294, state)
            assert.is_near(0.30, r.critChance, 0.001)
            assert.is_near(2.20, r.critMult, 0.001)
        end)

        it("Two-Handed Weapon Spec + Improved MS should stack additively on MS", function()
            local state = makeWarriorState()
            state.talents["1:15"] = 5  -- 2H Spec +5%
            state.talents["1:23"] = 5  -- Imp MS +5%
            local r = Pipeline.Calculate(12294, state)
            -- Both additive: damage * (1 + 0.05 + 0.05) = damage * 1.10
            assert.is_near(881.43 * 1.10, r.minDmg, 0.1)
            assert.is_near(1031.43 * 1.10, r.maxDmg, 0.1)
        end)

        it("Poleaxe Spec + Cruelty should stack crit on Overpower", function()
            local state = makeWarriorState()
            state.talents["1:11"] = 5  -- Poleaxe +5% crit
            state.talents["2:4"] = 5   -- Cruelty +5% crit
            local r = Pipeline.Calculate(7384, state)
            -- critChance = 0.25 + 0.05 + 0.05 = 0.35
            assert.is_near(0.35, r.critChance, 0.001)
        end)
    end)
end)
