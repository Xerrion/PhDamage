-------------------------------------------------------------------------------
-- test_hunter.lua
-- Unit tests for Hunter spells, talents, and pipeline integration
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeHunterState = bootstrap.makeHunterState

local Pipeline = ns.Engine.Pipeline

describe("Hunter", function()

    describe("Pipeline integration", function()

        it("should compute Arcane Shot through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(3044, state)
            assert.is_not_nil(result)
            assert.equals("Arcane Shot", result.spellName)
            assert.is_true(result.expectedDamageWithMiss > 0)
        end)

        it("should compute Steady Shot through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(34120, state)
            assert.is_not_nil(result)
            assert.equals("Steady Shot", result.spellName)
            -- base 150 + RAP*0.20 (200) + weapon avg 150 = 500
            -- crit: 500 * (1 + 0.15 * 0.5) = 500 * 1.075 = 537.5
            -- hit: 537.5 * (1 - 0.09 + 0.05) = 537.5 * 0.96 = 516
            -- No armor in default state
            assert.is_near(516, result.expectedDamageWithMiss, 1)
        end)

        it("should compute Aimed Shot through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(19434, state)
            assert.is_not_nil(result)
            assert.equals("Aimed Shot", result.spellName)
            assert.is_true(result.expectedDamageWithMiss > 0)
        end)

        it("should compute Serpent Sting through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(1978, state)
            assert.is_not_nil(result)
            assert.equals("Serpent Sting", result.spellName)
            assert.is_true(result.isDot)
        end)

        it("should compute Volley through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(1510, state)
            assert.is_not_nil(result)
            assert.equals("Volley", result.spellName)
            assert.is_true(result.isChanneled)
        end)

        it("should compute Explosive Trap through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(13813, state)
            assert.is_not_nil(result)
            assert.equals("Explosive Trap", result.spellName)
        end)

        it("should compute Multi-Shot through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(2643, state)
            assert.is_not_nil(result)
            assert.equals("Multi-Shot", result.spellName)
        end)

        it("should compute Silencing Shot through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(34490, state)
            assert.is_not_nil(result)
            assert.equals("Silencing Shot", result.spellName)
        end)

        it("should compute Immolation Trap through pipeline", function()
            local state = makeHunterState()
            local result = Pipeline.Calculate(13795, state)
            assert.is_not_nil(result)
            assert.equals("Immolation Trap", result.spellName)
        end)
    end)

    describe("Talent: Lethal Shots (2:2)", function()

        it("should increase crit by 5% at rank 5", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["2:2"] = 5
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.critChance + 0.05, buffed.critChance, 0.001)
        end)

        it("should increase crit by 1% at rank 1", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["2:2"] = 1
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.critChance + 0.01, buffed.critChance, 0.001)
        end)
    end)

    describe("Talent: Mortal Shots (2:10)", function()

        it("should increase crit multiplier by 30% at rank 5", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["2:10"] = 5
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.critMultiplier + 0.30, buffed.critMultiplier, 0.001)
        end)
    end)

    describe("Talent: Barrage (2:13)", function()

        it("should increase Multi-Shot damage by 12% at rank 3", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(2643, state)

            state.talents["2:13"] = 3
            local buffed = Pipeline.Calculate(2643, state)

            assert.is_near(base.expectedDamageWithMiss * 1.12, buffed.expectedDamageWithMiss, 0.5)
        end)

        it("should increase Volley damage by 12% at rank 3", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(1510, state)

            state.talents["2:13"] = 3
            local buffed = Pipeline.Calculate(1510, state)

            assert.is_near(base.expectedDamageWithMiss * 1.12, buffed.expectedDamageWithMiss, 0.5)
        end)

        it("should not affect Arcane Shot", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["2:13"] = 3
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss, buffed.expectedDamageWithMiss, 0.01)
        end)
    end)

    describe("Talent: Ranged Weapon Specialization (2:15)", function()

        it("should increase all ranged damage by 5% at rank 5", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["2:15"] = 5
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss * 1.05, buffed.expectedDamageWithMiss, 0.5)
        end)
    end)

    describe("Talent: Improved Stings (2:9)", function()

        it("should increase Serpent Sting damage by 18% at rank 3", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(1978, state)

            state.talents["2:9"] = 3
            local buffed = Pipeline.Calculate(1978, state)

            assert.is_near(base.expectedDamageWithMiss * 1.18, buffed.expectedDamageWithMiss, 0.5)
        end)

        it("should not affect Arcane Shot", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["2:9"] = 3
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss, buffed.expectedDamageWithMiss, 0.01)
        end)
    end)

    describe("Talent: Surefooted (3:12)", function()

        it("should increase hit by 3% at rank 3", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["3:12"] = 3
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.hitChance + 0.03, buffed.hitChance, 0.001)
        end)
    end)

    describe("Talent: Survival Instincts (3:14)", function()

        it("should increase crit by 4% at rank 2", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["3:14"] = 2
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.critChance + 0.04, buffed.critChance, 0.001)
        end)
    end)

    describe("Talent: Focused Fire (1:3)", function()

        it("should increase all damage by 2% at rank 2", function()
            local state = makeHunterState()
            local base = Pipeline.Calculate(3044, state)

            state.talents["1:3"] = 2
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss * 1.02, buffed.expectedDamageWithMiss, 0.5)
        end)
    end)

    describe("Talent: Monster Slaying (3:1)", function()

        it("should increase damage by 3% vs Beasts at rank 3", function()
            local state = makeHunterState()
            state.targetCreatureType = "Beast"
            local base = Pipeline.Calculate(3044, state)

            state.talents["3:1"] = 3
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss * 1.03, buffed.expectedDamageWithMiss, 0.5)
        end)

        it("should not affect damage vs Humanoids", function()
            local state = makeHunterState()
            state.targetCreatureType = "Humanoid"
            local base = Pipeline.Calculate(3044, state)

            state.talents["3:1"] = 3
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss, buffed.expectedDamageWithMiss, 0.01)
        end)

        it("should not apply without a target creature type", function()
            local state = makeHunterState()
            state.targetCreatureType = nil
            local base = Pipeline.Calculate(3044, state)

            state.talents["3:1"] = 3
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss, buffed.expectedDamageWithMiss, 0.01)
        end)
    end)

    describe("Talent: Humanoid Slaying (3:2)", function()

        it("should increase damage by 3% vs Humanoids at rank 3", function()
            local state = makeHunterState()
            state.targetCreatureType = "Humanoid"
            local base = Pipeline.Calculate(3044, state)

            state.talents["3:2"] = 3
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss * 1.03, buffed.expectedDamageWithMiss, 0.5)
        end)

        it("should not affect damage vs Beasts", function()
            local state = makeHunterState()
            state.targetCreatureType = "Beast"
            local base = Pipeline.Calculate(3044, state)

            state.talents["3:2"] = 3
            local buffed = Pipeline.Calculate(3044, state)

            assert.is_near(base.expectedDamageWithMiss, buffed.expectedDamageWithMiss, 0.01)
        end)
    end)

    describe("Serpent Sting no-crit behavior", function()

        it("should not crit regardless of crit chance", function()
            local state = makeHunterState()
            state.stats.rangedCrit = 0.50  -- 50% crit
            local result = Pipeline.Calculate(1978, state)
            assert.is_near(0, result.critChance, 0.001)
        end)
    end)

    describe("Talent stacking", function()

        it("should stack multiple additive damage talents", function()
            local state = makeHunterState()
            state.talents["2:15"] = 5  -- +5% ranged weapon spec
            state.talents["1:3"] = 2   -- +2% focused fire
            -- Both additive: total +7%
            local result = Pipeline.Calculate(3044, state)

            local baseState = makeHunterState()
            local baseResult = Pipeline.Calculate(3044, baseState)

            assert.is_near(baseResult.expectedDamageWithMiss * 1.07, result.expectedDamageWithMiss, 0.5)
        end)
    end)
end)
