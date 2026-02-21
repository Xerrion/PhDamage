-------------------------------------------------------------------------------
-- test_pipeline.lua
-- Unit tests for PhDamage Engine.Pipeline
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

describe("Pipeline", function()
    local playerState
    local Pipeline = ns.Engine.Pipeline

    before_each(function()
        playerState = makePlayerState()
    end)

    ---------------------------------------------------------------------------
    -- Calculate
    ---------------------------------------------------------------------------
    describe("Calculate", function()
        it("should return a result for Shadow Bolt (686)", function()
            local result = Pipeline.Calculate(686, playerState)
            assert.is_not_nil(result)
            assert.are.equal("Shadow Bolt", result.spellName)
        end)

        it("should return positive DPS for Shadow Bolt", function()
            local result = Pipeline.Calculate(686, playerState)
            assert.is_true(result.dps > 0)
        end)

        it("should return a result for Corruption (172)", function()
            local result = Pipeline.Calculate(172, playerState)
            assert.is_not_nil(result)
            assert.are.equal("Corruption", result.spellName)
        end)

        it("should return positive DPS for Corruption", function()
            local result = Pipeline.Calculate(172, playerState)
            assert.is_true(result.dps > 0)
        end)

        it("should return a result for Immolate (348)", function()
            local result = Pipeline.Calculate(348, playerState)
            assert.is_not_nil(result)
            assert.are.equal("Immolate", result.spellName)
            assert.are.equal("hybrid", result.spellType)
        end)

        it("should return a result for Drain Life (689)", function()
            local result = Pipeline.Calculate(689, playerState)
            assert.is_not_nil(result)
            assert.are.equal("Drain Life", result.spellName)
            assert.is_true(result.isChanneled)
        end)

        it("should return a result for Life Tap (1454) with dps = 0", function()
            local result = Pipeline.Calculate(1454, playerState)
            assert.is_not_nil(result)
            assert.are.equal("Life Tap", result.spellName)
            assert.are.equal(0, result.dps)
        end)

        it("should return nil for an unknown spell ID", function()
            local result = Pipeline.Calculate(99999, playerState)
            assert.is_nil(result)
        end)

        it("should include rank number in result", function()
            local result = Pipeline.Calculate(686, playerState)
            assert.are.equal(11, result.rank)
        end)

        it("should include spell school in result", function()
            local result = Pipeline.Calculate(686, playerState)
            assert.are.equal(32, result.school)  -- SCHOOL_SHADOW
        end)

        it("should use a specific rank when rankIndex is provided", function()
            local result = Pipeline.Calculate(686, playerState, 5)
            assert.is_not_nil(result)
            assert.are.equal(5, result.rank)
            assert.are.equal(1106, result.spellID)
        end)

        it("should fall back to highest rank when rankIndex is invalid", function()
            local result = Pipeline.Calculate(686, playerState, 99)
            assert.is_not_nil(result)
            assert.are.equal(11, result.rank)
        end)

        it("should produce consistent results across multiple calls", function()
            local r1 = Pipeline.Calculate(686, playerState)
            local r2 = Pipeline.Calculate(686, playerState)
            assert.is_near(r1.dps, r2.dps, 0.001)
            assert.is_near(r1.expectedDamage, r2.expectedDamage, 0.001)
        end)

        it("should reflect different spell power in results", function()
            local r1 = Pipeline.Calculate(686, playerState)
            playerState.stats.spellPower[32] = 2000
            local r2 = Pipeline.Calculate(686, playerState)
            assert.is_true(r2.dps > r1.dps)
        end)

        it("should reflect talent bonuses in final DPS", function()
            local r1 = Pipeline.Calculate(686, playerState)
            playerState.talents["1:15"] = 5  -- Shadow Mastery +10%
            local r2 = Pipeline.Calculate(686, playerState)
            assert.is_true(r2.dps > r1.dps)
        end)
    end)

    ---------------------------------------------------------------------------
    -- CalculateAll
    ---------------------------------------------------------------------------
    describe("CalculateAll", function()
        it("should return an array of results", function()
            local results = Pipeline.CalculateAll(playerState)
            assert.is_not_nil(results)
            assert.is_true(#results > 0)
        end)

        it("should include a result for every spell in SpellData", function()
            local results = Pipeline.CalculateAll(playerState)
            local spellCount = 0
            for _ in pairs(ns.SpellData) do
                spellCount = spellCount + 1
            end
            assert.are.equal(spellCount, #results)
        end)

        it("should include spellName for each result", function()
            local results = Pipeline.CalculateAll(playerState)
            for _, result in ipairs(results) do
                assert.is_not_nil(result.spellName)
                assert.is_true(#result.spellName > 0)
            end
        end)

        it("should sort results by DPS descending", function()
            local results = Pipeline.CalculateAll(playerState)
            for i = 2, #results do
                local prevDps = results[i - 1].dps or 0
                local currDps = results[i].dps or 0
                if prevDps ~= currDps then
                    assert.is_true(prevDps > currDps,
                        string.format("Results not sorted: %s (%.1f) before %s (%.1f)",
                            results[i - 1].spellName, prevDps,
                            results[i].spellName, currDps))
                end
            end
        end)

        it("should place Life Tap (dps = 0) at the end", function()
            local results = Pipeline.CalculateAll(playerState)
            local lastResult = results[#results]
            -- Life Tap has dps = 0, so it should be last or among the last
            assert.are.equal(0, lastResult.dps)
        end)

        it("should return fresh results on repeated calls", function()
            local r1 = Pipeline.CalculateAll(playerState)
            -- Save values before second call (CalculateAll reuses its table)
            local firstDps = r1[1].dps
            local firstSpell = r1[1].spellName
            playerState.stats.spellPower[32] = 5000
            playerState.stats.spellPower[4] = 5000
            local r2 = Pipeline.CalculateAll(playerState)
            -- DPS values should differ with different SP
            assert.is_true(r2[1].dps ~= firstDps or r2[1].spellName ~= firstSpell)
        end)
    end)

    ---------------------------------------------------------------------------
    -- CalculateByName
    ---------------------------------------------------------------------------
    describe("CalculateByName", function()
        it("should find Shadow Bolt by exact name", function()
            local result = Pipeline.CalculateByName("Shadow Bolt", playerState)
            assert.is_not_nil(result)
            assert.are.equal("Shadow Bolt", result.spellName)
        end)

        it("should find Shadow Bolt case-insensitively", function()
            local result = Pipeline.CalculateByName("shadow bolt", playerState)
            assert.is_not_nil(result)
            assert.are.equal("Shadow Bolt", result.spellName)
        end)

        it("should find with mixed case", function()
            local result = Pipeline.CalculateByName("SHADOW BOLT", playerState)
            assert.is_not_nil(result)
            assert.are.equal("Shadow Bolt", result.spellName)
        end)

        it("should find Corruption by name", function()
            local result = Pipeline.CalculateByName("Corruption", playerState)
            assert.is_not_nil(result)
            assert.are.equal("Corruption", result.spellName)
        end)

        it("should find Life Tap by name", function()
            local result = Pipeline.CalculateByName("Life Tap", playerState)
            assert.is_not_nil(result)
            assert.are.equal("Life Tap", result.spellName)
        end)

        it("should return nil for a non-existent spell name", function()
            local result = Pipeline.CalculateByName("NonExistentSpell", playerState)
            assert.is_nil(result)
        end)

        it("should return nil for an empty string", function()
            local result = Pipeline.CalculateByName("", playerState)
            assert.is_nil(result)
        end)

        it("should return equivalent result to Calculate with the same spell", function()
            local byName = Pipeline.CalculateByName("Shadow Bolt", playerState)
            local byId = Pipeline.Calculate(686, playerState)

            assert.are.equal(byId.spellName, byName.spellName)
            assert.is_near(byId.dps, byName.dps, 0.001)
            assert.is_near(byId.expectedDamage, byName.expectedDamage, 0.001)
        end)
    end)
end)
