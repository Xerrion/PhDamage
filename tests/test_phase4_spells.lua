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
            -- R1: level=40, maxLevel=47. cMaNGOS-TBC penalty (40, 47, 70):
            --   LvlPenalty = 0 (spellLevel >= 20)
            --   LvlFactor  = (47+6)/70 = 0.75714
            --   penalty    = 0.75714
            -- manaGain = 150 + 1000*0.96*0.75714 = 876.86
            assert.is_near(876.86, result.manaGain, 0.5)
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
            -- R1: penalty = 0.75714 (see rank-1 test).
            -- manaGain = 150 + 500*0.96*0.75714 = 513.43
            assert.is_near(513.43, result.manaGain, 0.5)
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
            -- R1: level=12, maxLevel=19. cMaNGOS-TBC penalty (12, 19, 70):
            --   LvlPenalty = (20-12)*3.75 = 30
            --   LvlFactor  = (19+6)/70    = 0.35714
            --   penalty    = (100-30)*0.35714/100 = 0.25
            -- total = 120 + 1000*0.548*0.25 = 257; noMiss (hitChance=1.0), canCrit=false
            assert.is_near(257, result.expectedDamageWithMiss, 0.5)
        end)

        it("should compute rank 8 total healing", function()
            local result = Pipeline.Calculate(755, playerState, 8)
            assert.is_not_nil(result)
            -- 1880 + 1000 * 0.548 = 2428
            assert.is_near(2428, result.expectedDamageWithMiss, 0.5)
        end)

        it("should compute correct tick healing", function()
            local result = Pipeline.Calculate(755, playerState, 1)
            -- 257 / 10 = 25.7 per tick (penalty applied; see rank-1 test).
            assert.is_near(25.7, result.tickDamage, 0.5)
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
            -- expectedDamageWithMiss / duration = 257 / 10 = 25.7
            assert.is_near(result.expectedDamageWithMiss / 10, result.dps, 0.5)
        end)

        it("should haste channel duration", function()
            playerState.stats.spellHaste = 0.20
            local result = Pipeline.Calculate(755, playerState, 1)
            -- duration = 10 / 1.20 = 8.333
            assert.is_near(10 / 1.20, result.duration, 0.01)
            -- Total healing unchanged at penalty-adjusted 257; DPS increases.
            assert.is_near(257, result.expectedDamageWithMiss, 0.5)
            assert.is_true(result.dps > 257 / 10)
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
            -- R1: level=32, maxLevel=41. cMaNGOS-TBC penalty (32, 41, 70):
            --   LvlPenalty = 0 (spellLevel >= 20)
            --   LvlFactor  = (41+6)/70 = 0.67143
            --   penalty    = 0.67143
            -- absorption = 290 + 1000*0.30*0.67143 = 491.43; noMiss + noCrit
            assert.is_near(491.43, result.expectedDamageWithMiss, 0.5)
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
            -- 491.43 / 1.5 = 327.62 (penalty applied; see rank-1 test).
            assert.is_near(491.43 / 1.5, result.dps, 0.5)
        end)

        it("should scale with spell power", function()
            playerState.stats.spellPower[32] = 500
            local result = Pipeline.Calculate(6229, playerState, 1)
            -- penalty = 0.67143 (see rank-1 test).
            -- absorption = 290 + 500*0.30*0.67143 = 390.71
            assert.is_near(390.71, result.expectedDamageWithMiss, 0.5)
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
