-------------------------------------------------------------------------------
-- test_phase4_spells.lua
-- Comprehensive tests for Phase 4 spells: Dark Pact, Health Funnel, Shadow Ward
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

local Pipeline = ns.Engine.Pipeline

-------------------------------------------------------------------------------
-- Dark Pact (base spellID 18220)
-------------------------------------------------------------------------------
describe("Phase 4 Spells", function()

    describe("Dark Pact", function()
        local playerState

        before_each(function()
            playerState = makePlayerState()
        end)

        it("should compute rank 1 mana gain with spell power", function()
            local result = Pipeline.Calculate(18220, playerState, 1)
            assert.is_not_nil(result)
            -- 150 + 1000 * 0.96 = 1110
            assert.is_near(1110, result.manaGain, 0.5)
        end)

        it("should compute rank 4 mana gain with spell power", function()
            local result = Pipeline.Calculate(18220, playerState, 4)
            assert.is_not_nil(result)
            -- 300 + 1000 * 0.96 = 1260
            assert.is_near(1260, result.manaGain, 0.5)
        end)

        it("should have no health cost", function()
            local result = Pipeline.Calculate(18220, playerState, 1)
            assert.is_nil(result.healthCost)
        end)

        it("should have correct coefficient", function()
            local result = Pipeline.Calculate(18220, playerState, 1)
            assert.is_near(0.96, result.coefficient, 0.01)
        end)

        it("should use GCD as cast time for instant utility", function()
            local result = Pipeline.Calculate(18220, playerState, 1)
            assert.is_near(1.5, result.castTime, 0.01)
        end)

        it("should scale with varying spell power", function()
            playerState.stats.spellPower[32] = 500
            local result = Pipeline.Calculate(18220, playerState, 1)
            -- 150 + 500 * 0.96 = 630
            assert.is_near(630, result.manaGain, 0.5)
        end)

        it("should report correct spell metadata", function()
            local result = Pipeline.Calculate(18220, playerState, 1)
            assert.are.equal("Dark Pact", result.spellName)
            assert.are.equal(ns.SCHOOL_SHADOW, result.school)
        end)

        it("should return all 4 ranks", function()
            for rank = 1, 4 do
                local result = Pipeline.Calculate(18220, playerState, rank)
                assert.is_not_nil(result,
                    string.format("Rank %d should return a result", rank))
            end
        end)
    end)

    ---------------------------------------------------------------------------
    -- Health Funnel (base spellID 755)
    ---------------------------------------------------------------------------
    describe("Health Funnel", function()
        local playerState

        before_each(function()
            playerState = makePlayerState()
        end)

        it("should compute rank 1 total healing", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            assert.is_not_nil(result)
            -- 120 + 1000 * 0.548 = 668; noMiss (hitChance=1.0), canCrit=false
            assert.is_near(668, result.expectedDamageWithMiss, 0.5)
        end)

        it("should compute rank 8 total healing", function()
            local result = Pipeline.Calculate(755, playerState, 8)
            assert.is_not_nil(result)
            -- 1880 + 1000 * 0.548 = 2428
            assert.is_near(2428, result.expectedDamageWithMiss, 0.5)
        end)

        it("should compute correct tick healing", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            -- 668 / 10 = 66.8 per tick
            assert.is_near(66.8, result.tickDamage, 0.5)
        end)

        it("should have 10 ticks", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            assert.are.equal(10, result.numTicks)
        end)

        it("should have 10s base duration", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            assert.are.equal(10, result.duration)
        end)

        it("should not miss (noMiss)", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            assert.is_near(1.0, result.hitProbability, 0.01)
        end)

        it("should not crit", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            assert.are.equal(0, result.critChance)
        end)

        it("should propagate healing outputType", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            assert.are.equal("healing", result.outputType)
        end)

        it("should be flagged as channeled", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            assert.is_true(result.isChanneled)
        end)

        it("should have DPS equal to total healing / duration", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            -- expectedDamageWithMiss / duration = 668 / 10 = 66.8
            assert.is_near(result.expectedDamageWithMiss / 10, result.dps, 0.5)
        end)

        it("should haste channel duration", function()
            playerState.stats.spellHaste = 0.20
            local result = Pipeline.Calculate(755, playerState, 1)
            -- duration = 10 / 1.20 = 8.333
            assert.is_near(10 / 1.20, result.duration, 0.01)
            -- Total healing unchanged (668), DPS increases
            assert.is_near(668, result.expectedDamageWithMiss, 0.5)
            assert.is_true(result.dps > 668 / 10)
        end)

        it("should return all 8 ranks", function()
            for rank = 1, 8 do
                local result = Pipeline.Calculate(755, playerState, rank)
                assert.is_not_nil(result,
                    string.format("Rank %d should return a result", rank))
            end
        end)
    end)

    ---------------------------------------------------------------------------
    -- Shadow Ward (base spellID 6229)
    ---------------------------------------------------------------------------
    describe("Shadow Ward", function()
        local playerState

        before_each(function()
            playerState = makePlayerState()
        end)

        it("should compute rank 1 absorption", function()
            local result = Pipeline.Calculate(6229, playerState, 1)
            assert.is_not_nil(result)
            -- 290 + 1000 * 0.30 = 590; noMiss + noCrit
            assert.is_near(590, result.expectedDamageWithMiss, 0.5)
        end)

        it("should compute rank 4 absorption", function()
            local result = Pipeline.Calculate(6229, playerState, 4)
            assert.is_not_nil(result)
            -- 875 + 1000 * 0.30 = 1175
            assert.is_near(1175, result.expectedDamageWithMiss, 0.5)
        end)

        it("should not miss (noMiss)", function()
            local result = Pipeline.Calculate(6229, playerState, 1)
            assert.is_near(1.0, result.hitProbability, 0.01)
        end)

        it("should not crit", function()
            local result = Pipeline.Calculate(6229, playerState, 1)
            assert.are.equal(0, result.critChance)
        end)

        it("should have fixed min=max base damage", function()
            local result = Pipeline.Calculate(6229, playerState, 1)
            assert.are.equal(result.baseDamage.min, result.baseDamage.max)
            assert.is_near(290, result.avgBaseDamage, 0.5)
        end)

        it("should propagate absorption outputType", function()
            local result = Pipeline.Calculate(6229, playerState, 1)
            assert.are.equal("absorption", result.outputType)
        end)

        it("should use GCD as cast time for instant", function()
            local result = Pipeline.Calculate(6229, playerState, 1)
            assert.is_near(1.5, result.castTime, 0.01)
        end)

        it("should compute correct APS", function()
            local result = Pipeline.Calculate(6229, playerState, 1)
            -- 590 / 1.5 = 393.33
            assert.is_near(590 / 1.5, result.dps, 0.5)
        end)

        it("should scale with spell power", function()
            playerState.stats.spellPower[32] = 500
            local result = Pipeline.Calculate(6229, playerState, 1)
            -- 290 + 500 * 0.30 = 440
            assert.is_near(440, result.expectedDamageWithMiss, 0.5)
        end)

        it("should return all 4 ranks", function()
            for rank = 1, 4 do
                local result = Pipeline.Calculate(6229, playerState, rank)
                assert.is_not_nil(result,
                    string.format("Rank %d should return a result", rank))
            end
        end)
    end)

end)
