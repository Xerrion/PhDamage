-------------------------------------------------------------------------------
-- test_spellcalc.lua
-- Unit tests for PhDamage Engine.SpellCalc
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

describe("SpellCalc", function()
    local playerState
    local SpellCalc = ns.Engine.SpellCalc

    before_each(function()
        playerState = makePlayerState()
    end)

    ---------------------------------------------------------------------------
    -- GetCurrentRank
    ---------------------------------------------------------------------------
    describe("GetCurrentRank", function()
        it("should return rank 11 for Shadow Bolt at level 70", function()
            local spellData = ns.SpellData[686]
            local rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
            assert.are.equal(11, rankNum)
            assert.are.equal(27209, rankData.spellID)
        end)

        it("should return rank 8 for Corruption at level 70", function()
            local spellData = ns.SpellData[172]
            local rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
            assert.are.equal(8, rankNum)
            assert.are.equal(27216, rankData.spellID)
        end)

        it("should return rank 9 for Immolate at level 70", function()
            local spellData = ns.SpellData[348]
            local rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
            assert.are.equal(9, rankNum)
            assert.are.equal(27215, rankData.spellID)
        end)

        it("should return rank 8 for Drain Life at level 70", function()
            local spellData = ns.SpellData[689]
            local rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
            assert.are.equal(8, rankNum)
            assert.are.equal(27220, rankData.spellID)
        end)

        it("should return rank 7 for Life Tap at level 70", function()
            local spellData = ns.SpellData[1454]
            local rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
            assert.are.equal(7, rankNum)
            assert.are.equal(27222, rankData.spellID)
        end)

        it("should return a lower rank for a lower-level player", function()
            playerState.level = 20
            local spellData = ns.SpellData[686]
            local rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
            assert.are.equal(4, rankNum)
            assert.are.equal(1088, rankData.spellID)
        end)

        it("should return nil when player level is too low for any rank", function()
            playerState.level = 0
            local spellData = ns.SpellData[686]
            local rankNum, rankData = SpellCalc.GetCurrentRank(spellData, playerState)
            assert.is_nil(rankNum)
            assert.is_nil(rankData)
        end)
    end)

    ---------------------------------------------------------------------------
    -- ComputeBase
    ---------------------------------------------------------------------------
    describe("ComputeBase", function()

        describe("direct (Shadow Bolt R11)", function()
            it("should compute correct average base damage", function()
                local spellData = ns.SpellData[686]
                local rankData = spellData.ranks[11]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedAvg = (544 + 607) / 2  -- 575.5
                assert.is_near(expectedAvg, result.avgBaseDamage, 0.01)
            end)

            it("should carry through min and max base damage", function()
                local spellData = ns.SpellData[686]
                local rankData = spellData.ranks[11]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                assert.are.equal(544, result.minBaseDamage)
                assert.are.equal(607, result.maxBaseDamage)
            end)

            it("should compute correct spell power bonus with 1000 Shadow SP", function()
                local spellData = ns.SpellData[686]
                local rankData = spellData.ranks[11]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedSpBonus = 0.8571 * 1000  -- 857.1
                assert.is_near(expectedSpBonus, result.spellPowerBonus, 0.01)
                assert.is_near(0.8571, result.coefficient, 0.0001)
            end)

            it("should compute correct total damage", function()
                local spellData = ns.SpellData[686]
                local rankData = spellData.ranks[11]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedTotal = (544 + 607) / 2 + 0.8571 * 1000  -- 1432.6
                assert.is_near(expectedTotal, result.totalDamage, 0.1)
            end)

            it("should include cast time from spell data", function()
                local spellData = ns.SpellData[686]
                local rankData = spellData.ranks[11]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                assert.are.equal(3.0, result.castTime)
            end)

            it("should compute totalMin and totalMax", function()
                local spellData = ns.SpellData[686]
                local rankData = spellData.ranks[11]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local spBonus = 0.8571 * 1000
                assert.is_near(544 + spBonus, result.totalMin, 0.1)
                assert.is_near(607 + spBonus, result.totalMax, 0.1)
            end)

            it("should return zero spell power bonus when SP is zero", function()
                playerState.stats.spellPower[32] = 0
                local spellData = ns.SpellData[686]
                local rankData = spellData.ranks[11]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                assert.is_near(0, result.spellPowerBonus, 0.01)
                assert.is_near((544 + 607) / 2, result.totalDamage, 0.01)
            end)
        end)

        describe("dot (Corruption R8)", function()
            it("should compute correct total DoT damage with 1000 Shadow SP", function()
                local spellData = ns.SpellData[172]
                local rankData = spellData.ranks[8]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedSpBonus = 0.936 * 1000  -- 936
                local expectedTotal = 900 + expectedSpBonus  -- 1836

                assert.are.equal(900, result.avgBaseDamage)
                assert.is_near(expectedSpBonus, result.spellPowerBonus, 0.01)
                assert.is_near(expectedTotal, result.totalDamage, 0.01)
            end)

            it("should compute correct per-tick damage", function()
                local spellData = ns.SpellData[172]
                local rankData = spellData.ranks[8]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedTotal = 900 + 0.936 * 1000
                local expectedTick = expectedTotal / 6  -- 306
                assert.is_near(expectedTick, result.tickDamage, 0.01)
            end)

            it("should include tick count and duration", function()
                local spellData = ns.SpellData[172]
                local rankData = spellData.ranks[8]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                assert.are.equal(6, result.numTicks)
                assert.are.equal(18, result.duration)
            end)
        end)

        describe("hybrid (Immolate R9)", function()
            it("should compute correct direct portion with 1000 Fire SP", function()
                local spellData = ns.SpellData[348]
                local rankData = spellData.ranks[9]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedDirectAvg = (327 + 327) / 2  -- 327
                local expectedDirectSpBonus = 0.2 * 1000  -- 200
                local expectedDirectDamage = expectedDirectAvg + expectedDirectSpBonus  -- 527

                assert.is_near(expectedDirectAvg, result.avgBaseDamage, 0.01)
                assert.is_near(expectedDirectSpBonus, result.directSpBonus, 0.01)
                assert.is_near(expectedDirectDamage, result.directDamage, 0.01)
            end)

            it("should compute correct DoT portion", function()
                local spellData = ns.SpellData[348]
                local rankData = spellData.ranks[9]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedDotSpBonus = 0.65 * 1000  -- 650
                local expectedDotDamage = 615 + expectedDotSpBonus  -- 1265
                local expectedTickDamage = expectedDotDamage / 5  -- 253

                assert.is_near(expectedDotSpBonus, result.dotSpBonus, 0.01)
                assert.is_near(expectedDotDamage, result.dotDamage, 0.01)
                assert.is_near(expectedTickDamage, result.tickDamage, 0.01)
                assert.are.equal(5, result.numTicks)
                assert.are.equal(15, result.duration)
            end)

            it("should compute correct combined total damage", function()
                local spellData = ns.SpellData[348]
                local rankData = spellData.ranks[9]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedDirect = 327 + 0.2 * 1000  -- 527
                local expectedDot = 615 + 0.65 * 1000  -- 1265
                local expectedTotal = expectedDirect + expectedDot  -- 1792

                assert.is_near(expectedTotal, result.totalDamage, 0.1)
            end)

            it("should store both coefficients", function()
                local spellData = ns.SpellData[348]
                local rankData = spellData.ranks[9]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                assert.is_near(0.2, result.directCoefficient, 0.0001)
                assert.is_near(0.65, result.dotCoefficient, 0.0001)
                assert.is_near(0.85, result.coefficient, 0.0001)  -- combined
            end)
        end)

        describe("channel (Drain Life R8)", function()
            it("should compute correct total channel damage with 1000 Shadow SP", function()
                local spellData = ns.SpellData[689]
                local rankData = spellData.ranks[8]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedSpBonus = 0.7143 * 1000  -- 714.3
                local expectedTotal = 540 + expectedSpBonus  -- 1254.3

                assert.are.equal(540, result.avgBaseDamage)
                assert.is_near(expectedSpBonus, result.spellPowerBonus, 0.1)
                assert.is_near(expectedTotal, result.totalDamage, 0.1)
            end)

            it("should compute correct per-tick damage", function()
                local spellData = ns.SpellData[689]
                local rankData = spellData.ranks[8]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedTotal = 540 + 0.7143 * 1000
                local expectedTick = expectedTotal / 5  -- 250.86
                assert.is_near(expectedTick, result.tickDamage, 0.1)
            end)

            it("should include tick count and duration", function()
                local spellData = ns.SpellData[689]
                local rankData = spellData.ranks[8]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                assert.are.equal(5, result.numTicks)
                assert.are.equal(5, result.duration)
            end)
        end)

        describe("utility (Life Tap R7)", function()
            it("should compute correct mana gain with 1000 Shadow SP", function()
                local spellData = ns.SpellData[1454]
                local rankData = spellData.ranks[7]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedSpBonus = 0.8 * 1000  -- 800
                local expectedManaGain = 582 + expectedSpBonus  -- 1382

                assert.is_near(expectedSpBonus, result.spellPowerBonus, 0.01)
                assert.is_near(expectedManaGain, result.manaGain, 0.01)
            end)

            it("should include health cost from rank data", function()
                local spellData = ns.SpellData[1454]
                local rankData = spellData.ranks[7]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                assert.are.equal(582, result.healthCost)
            end)

            it("should include coefficient", function()
                local spellData = ns.SpellData[1454]
                local rankData = spellData.ranks[7]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                assert.is_near(0.8, result.coefficient, 0.0001)
            end)

            it("should preserve the current modeled 0.8 scaling for Rank 6", function()
                local spellData = ns.SpellData[1454]
                local rankData = spellData.ranks[6]
                local result = SpellCalc.ComputeBase(spellData, rankData, playerState)

                local expectedSpBonus = 0.8 * 1000  -- 800
                local expectedManaGain = 420 + expectedSpBonus  -- 1220

                assert.is_near(expectedSpBonus, result.spellPowerBonus, 0.01)
                assert.is_near(expectedManaGain, result.manaGain, 0.01)
                assert.is_near(0.8, result.coefficient, 0.0001)
            end)
        end)

        it("should return nil for an unknown spell type", function()
            local fakeSpellData = { spellType = "nonexistent" }
            local fakeRankData = {}
            local result = SpellCalc.ComputeBase(fakeSpellData, fakeRankData, playerState)
            assert.is_nil(result)
        end)
    end)
end)
