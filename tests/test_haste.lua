-------------------------------------------------------------------------------
-- test_haste.lua
-- Integration tests for spell haste mechanics across the Pipeline
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

local Pipeline = ns.Engine.Pipeline

local GCD = 1.5

describe("Spell Haste Integration", function()
    local playerState

    before_each(function()
        playerState = makePlayerState()
    end)

    ---------------------------------------------------------------------------
    -- Cast time hasting
    ---------------------------------------------------------------------------
    describe("Cast time hasting", function()
        it("should not change cast time with 0% haste", function()
            playerState.stats.spellHaste = 0
            local result = Pipeline.Calculate(686, playerState)  -- Shadow Bolt
            assert.is_near(3.0, result.castTime, 0.01)
        end)

        it("should reduce cast time with 10% haste", function()
            playerState.stats.spellHaste = 0.10
            local result = Pipeline.Calculate(686, playerState)
            assert.is_near(3.0 / 1.10, result.castTime, 0.01)
        end)

        it("should reduce cast time with 20% haste", function()
            playerState.stats.spellHaste = 0.20
            local result = Pipeline.Calculate(686, playerState)
            assert.is_near(3.0 / 1.20, result.castTime, 0.01)
        end)

        it("should reduce cast time with 50% haste", function()
            playerState.stats.spellHaste = 0.50
            local result = Pipeline.Calculate(686, playerState)
            assert.is_near(3.0 / 1.50, result.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- GCD hasting
    ---------------------------------------------------------------------------
    describe("GCD hasting", function()
        it("should haste GCD for instant spells", function()
            playerState.stats.spellHaste = 0.10
            local result = Pipeline.Calculate(1454, playerState)  -- Life Tap
            assert.is_near(GCD / 1.10, result.castTime, 0.01)
        end)

        it("should not reduce GCD below 1.0s", function()
            playerState.stats.spellHaste = 1.0
            local result = Pipeline.Calculate(1454, playerState)
            assert.is_near(1.0, result.castTime, 0.01)
        end)

        it("should use hastedGCD when cast time is GCD-capped", function()
            playerState.stats.spellHaste = 0.20
            local result = Pipeline.Calculate(5676, playerState)  -- Searing Pain
            assert.is_near(1.5 / 1.20, result.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Channel hasting
    ---------------------------------------------------------------------------
    describe("Channel hasting", function()
        it("should haste channel duration", function()
            playerState.stats.spellHaste = 0.10
            local result = Pipeline.Calculate(689, playerState)  -- Drain Life
            assert.is_near(5.0 / 1.10, result.duration, 0.01)
        end)

        it("should keep same total damage with haste", function()
            playerState.stats.spellHaste = 0
            local noHaste = Pipeline.Calculate(689, playerState)

            playerState.stats.spellHaste = 0.10
            local withHaste = Pipeline.Calculate(689, playerState)

            assert.is_near(noHaste.expectedDamageWithMiss, withHaste.expectedDamageWithMiss, 0.01)
        end)

        it("should increase DPS with channel haste", function()
            playerState.stats.spellHaste = 0
            local noHaste = Pipeline.Calculate(689, playerState)

            playerState.stats.spellHaste = 0.10
            local withHaste = Pipeline.Calculate(689, playerState)

            assert.is_true(withHaste.dps > noHaste.dps)
        end)

        it("should keep same tick count with haste", function()
            playerState.stats.spellHaste = 0.10
            local result = Pipeline.Calculate(689, playerState)
            assert.are.equal(5, result.numTicks)
        end)

        it("should keep same tick damage with haste", function()
            playerState.stats.spellHaste = 0
            local noHaste = Pipeline.Calculate(689, playerState)

            playerState.stats.spellHaste = 0.10
            local withHaste = Pipeline.Calculate(689, playerState)

            assert.is_near(noHaste.tickDamage, withHaste.tickDamage, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- DoT duration unaffected
    ---------------------------------------------------------------------------
    describe("DoT duration unaffected", function()
        it("should not change DoT duration with haste", function()
            playerState.stats.spellHaste = 0.20
            local result = Pipeline.Calculate(172, playerState)  -- Corruption
            assert.is_near(18.0, result.duration, 0.01)
        end)

        it("should haste DoT cast time but not duration", function()
            playerState.stats.spellHaste = 0.10
            local result = Pipeline.Calculate(172, playerState)
            assert.is_near(2.0 / 1.10, result.castTime, 0.01)
            assert.is_near(18.0, result.duration, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Hybrid spell haste
    ---------------------------------------------------------------------------
    describe("Hybrid spell haste", function()
        it("should haste hybrid cast time but not dot duration", function()
            playerState.stats.spellHaste = 0.20
            local result = Pipeline.Calculate(348, playerState)  -- Immolate
            assert.is_near(2.0 / 1.20, result.castTime, 0.01)
            assert.is_near(15.0, result.duration, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- DPS calculations with haste
    ---------------------------------------------------------------------------
    describe("DPS calculations with haste", function()
        it("should increase direct spell DPS with haste", function()
            playerState.stats.spellHaste = 0
            local noHaste = Pipeline.Calculate(686, playerState)  -- Shadow Bolt

            playerState.stats.spellHaste = 0.10
            local withHaste = Pipeline.Calculate(686, playerState)

            assert.is_true(withHaste.dps > noHaste.dps)
        end)

        it("should increase channel DPS with haste", function()
            playerState.stats.spellHaste = 0
            local noHaste = Pipeline.Calculate(689, playerState)  -- Drain Life

            playerState.stats.spellHaste = 0.10
            local withHaste = Pipeline.Calculate(689, playerState)

            assert.is_true(withHaste.dps > noHaste.dps)
        end)

        it("should increase utility-exempt DPS", function()
            playerState.stats.spellHaste = 0.10
            local result = Pipeline.Calculate(1454, playerState)  -- Life Tap
            assert.is_near(GCD / 1.10, result.castTime, 0.01)
        end)
    end)
end)
