-------------------------------------------------------------------------------
-- test_warlock_completion.lua
-- Unit tests for new Warlock talents and auras
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

local Pipeline = ns.Engine.Pipeline

describe("Warlock Completion", function()

    describe("Improved Life Tap (1:3)", function()

        it("should increase Life Tap mana by 10% at rank 1", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(1454, state)

            state.talents["1:3"] = 1
            local buffed = Pipeline.Calculate(1454, state)

            assert.is_near(base.manaGain * 1.10, buffed.manaGain, 0.01)
        end)

        it("should increase Life Tap mana by 20% at rank 2", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(1454, state)

            state.talents["1:3"] = 2
            local buffed = Pipeline.Calculate(1454, state)

            assert.is_near(base.manaGain * 1.20, buffed.manaGain, 0.01)
        end)

        it("should not affect other spells", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(686, state)

            state.talents["1:3"] = 2
            local buffed = Pipeline.Calculate(686, state)

            assert.is_near(base.expectedDamageWithMiss, buffed.expectedDamageWithMiss, 0.01)
        end)
    end)

    describe("Improved Health Funnel (2:4)", function()

        it("should increase Health Funnel healing by 10% at rank 1", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(755, state)

            state.talents["2:4"] = 1
            local buffed = Pipeline.Calculate(755, state)

            assert.is_near(base.expectedDamageWithMiss * 1.10, buffed.expectedDamageWithMiss, 0.01)
        end)

        it("should increase Health Funnel healing by 20% at rank 2", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(755, state)

            state.talents["2:4"] = 2
            local buffed = Pipeline.Calculate(755, state)

            assert.is_near(base.expectedDamageWithMiss * 1.20, buffed.expectedDamageWithMiss, 0.01)
        end)
    end)

    describe("Soul Link aura (25228)", function()

        it("should increase all damage by 5%", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(686, state)

            state.auras.player[25228] = true
            local buffed = Pipeline.Calculate(686, state)

            assert.is_near(base.expectedDamageWithMiss * 1.05, buffed.expectedDamageWithMiss, 0.01)
        end)

        it("should stack with other multipliers", function()
            local state = makePlayerState()
            -- Get base without buffs
            local base = Pipeline.Calculate(686, state)
            -- Add Shadow Mastery + Soul Link
            state.auras.player[25228] = true
            state.talents["1:15"] = 5  -- Shadow Mastery +10%
            local result = Pipeline.Calculate(686, state)
            local expected = base.expectedDamageWithMiss * 1.10 * 1.05
            assert.is_near(expected, result.expectedDamageWithMiss, 0.5)
        end)
    end)

    describe("Demonic Sacrifice: Felguard (35701)", function()

        it("should increase fire damage by 10%", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(5676, state)  -- Searing Pain (fire)

            state.auras.player[35701] = true
            local buffed = Pipeline.Calculate(5676, state)

            assert.is_near(base.expectedDamageWithMiss * 1.10, buffed.expectedDamageWithMiss, 0.01)
        end)

        it("should increase shadow damage by 10%", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(686, state)  -- Shadow Bolt

            state.auras.player[35701] = true
            local buffed = Pipeline.Calculate(686, state)

            assert.is_near(base.expectedDamageWithMiss * 1.10, buffed.expectedDamageWithMiss, 0.01)
        end)
    end)

    describe("Amplify Curse (18288)", function()

        it("should increase Curse of Agony damage by 50%", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(980, state)

            state.auras.player[18288] = true
            local buffed = Pipeline.Calculate(980, state)

            assert.is_near(base.expectedDamageWithMiss * 1.50, buffed.expectedDamageWithMiss, 0.01)
        end)

        it("should increase Curse of Doom damage by 50%", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(603, state)

            state.auras.player[18288] = true
            local buffed = Pipeline.Calculate(603, state)

            assert.is_near(base.expectedDamageWithMiss * 1.50, buffed.expectedDamageWithMiss, 0.01)
        end)

        it("should not affect Shadow Bolt", function()
            local state = makePlayerState()
            local base = Pipeline.Calculate(686, state)

            state.auras.player[18288] = true
            local buffed = Pipeline.Calculate(686, state)

            assert.is_near(base.expectedDamageWithMiss, buffed.expectedDamageWithMiss, 0.01)
        end)
    end)
end)
