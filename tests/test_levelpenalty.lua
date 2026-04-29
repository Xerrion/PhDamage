-------------------------------------------------------------------------------
-- test_levelpenalty.lua
-- Pins the cMaNGOS-TBC downranking spell-coefficient level-penalty formula.
--
-- Reference: cMaNGOS-TBC Unit.cpp::CalculateLevelPenalty
--   https://github.com/cmangos/mangos-tbc/blob/master/src/game/Entities/Unit.cpp
--
-- TBC vs WotLK divergence: TBC uses (MaxLevel + 6) / playerLevel; AzerothCore
-- and cMaNGOS-WotLK use (SpellLevel + 6). PhDamage targets TBC, so the
-- expectations below all use MaxLevel + 6.
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local CalculateLevelPenalty = ns.Engine.LevelPenalty.CalculateLevelPenalty
local Pipeline = ns.Engine.Pipeline

describe("LevelPenalty.CalculateLevelPenalty (issue #47)", function()

    describe("top-rank exemption", function()
        it("returns 1.0 when spellLevel == maxLevel (top-rank short-circuit)", function()
            assert.is_near(1.0, CalculateLevelPenalty(70, 70, 70), 0.0001)
        end)

        it("returns 1.0 when spellLevel > maxLevel (defensive)", function()
            assert.is_near(1.0, CalculateLevelPenalty(75, 70, 70), 0.0001)
        end)
    end)

    describe("defensive nil/zero fallbacks", function()
        it("returns 1.0 when maxLevel is nil (data not yet backfilled)", function()
            assert.is_near(1.0, CalculateLevelPenalty(12, nil, 70), 0.0001)
        end)

        it("returns 1.0 when spellLevel is nil", function()
            assert.is_near(1.0, CalculateLevelPenalty(nil, 19, 70), 0.0001)
        end)

        it("returns 1.0 when playerLevel is nil", function()
            assert.is_near(1.0, CalculateLevelPenalty(12, 19, nil), 0.0001)
        end)

        it("returns 1.0 when playerLevel == 0 (avoids div-by-zero)", function()
            assert.is_near(1.0, CalculateLevelPenalty(12, 19, 0), 0.0001)
        end)

        it("returns 1.0 when spellLevel == 0", function()
            assert.is_near(1.0, CalculateLevelPenalty(0, 19, 70), 0.0001)
        end)
    end)

    describe("downranking penalty (cMaNGOS-TBC formula)", function()
        -- Frostbolt R3: spellLevel=12, maxLevel=19 (next rank at 20), playerLevel=70
        -- LvlPenalty = (20 - 12) * 3.75 = 30
        -- LvlFactor  = (19 + 6) / 70 = 25/70 ~ 0.35714
        -- Result     = (100 - 30) * 0.35714 / 100 = 0.25
        it("Frostbolt R3 @ L70 (12, 19, 70) -> 0.25 (sub-20 stacking)", function()
            assert.is_near(0.25, CalculateLevelPenalty(12, 19, 70), 0.0001)
        end)

        -- Greater Heal R1: spellLevel=40, maxLevel=45, playerLevel=70
        -- LvlPenalty = 0 (spellLevel >= 20)
        -- LvlFactor  = (45 + 6) / 70 = 51/70 ~ 0.72857
        -- Result     = 100 * 0.72857 / 100 = 0.72857
        it("Greater Heal R1 @ L70 (40, 45, 70) -> 0.7286 (no sub-20 stacking)", function()
            assert.is_near(0.7286, CalculateLevelPenalty(40, 45, 70), 0.0001)
        end)

        -- Shadow Bolt R5: spellLevel=30, maxLevel=35, playerLevel=70
        -- LvlPenalty = 0
        -- LvlFactor  = (35 + 6) / 70 = 41/70 ~ 0.58571
        -- Result     = 0.58571
        it("Shadow Bolt R5 @ L70 (30, 35, 70) -> 0.5857", function()
            assert.is_near(0.5857, CalculateLevelPenalty(30, 35, 70), 0.0001)
        end)

        -- LvlFactor cap: (maxLevel + 6) / playerLevel = 106/50 = 2.12 -> caps to 1.0
        -- Sub-20 still applies: LvlPenalty = (20 - 1) * 3.75 = 71.25
        -- Result = (100 - 71.25) * 1.0 / 100 = 0.2875
        it("caps LvlFactor at 1.0 when (maxLevel+6) > playerLevel", function()
            assert.is_near(0.2875, CalculateLevelPenalty(1, 100, 50), 0.0001)
        end)

        -- Sub-20 boundary at spellLevel == 19:
        -- LvlPenalty = (20 - 19) * 3.75 = 3.75
        -- LvlFactor  = (25 + 6) / 70 = 31/70 ~ 0.44286
        -- Result     = (100 - 3.75) * 0.44286 / 100 ~ 0.42625
        it("applies sub-20 penalty at boundary spellLevel == 19", function()
            assert.is_near(0.4262, CalculateLevelPenalty(19, 25, 70), 0.0001)
        end)
    end)
end)

-------------------------------------------------------------------------------
-- Engine integration: ModifierCalc.BuildModifiedResult / BuildHybridResult
-- must scale the SP-bonus contribution by the level penalty when rankData
-- carries a maxLevel. When maxLevel is absent the engine must remain inert
-- (Phase 4 backfill compatibility).
--
-- Tests mutate rankData.maxLevel in-place and restore it after each case so
-- the global SpellData stays clean for subsequent tests.
-------------------------------------------------------------------------------
describe("LevelPenalty engine integration (Phase 2)", function()

    local function withMaxLevel(rankData, maxLevel, fn)
        local original = rankData.maxLevel
        rankData.maxLevel = maxLevel
        local ok, err = pcall(fn)
        rankData.maxLevel = original
        if not ok then error(err, 0) end
    end

    -- After Phase 4, real SpellData ranks all carry a populated maxLevel,
    -- so a vanilla Pipeline.Calculate already includes the penalty. To assert
    -- the penalty math against an unpenalized reference, this helper computes
    -- a baseline with rankData.maxLevel temporarily cleared, then restores it.
    local function unpenalizedBaseline(rankData, fn)
        local original = rankData.maxLevel
        rankData.maxLevel = nil
        local ok, err = pcall(fn)
        rankData.maxLevel = original
        if not ok then error(err, 0) end
    end

    describe("standard path (BuildModifiedResult)", function()
        -- Frostbolt R3: level=14. Forcing maxLevel=19 (next rank starts at 20)
        -- yields cMaNGOS-TBC penalty (14, 19, 70):
        --   LvlPenalty = (20 - 14) * 3.75 = 22.5
        --   LvlFactor  = (19 + 6) / 70 ~ 0.35714
        --   Result     = (100 - 22.5) * 0.35714 / 100 ~ 0.27679
        it("scales spellPowerBonus by the cMaNGOS penalty for sub-max-rank Frostbolt R3 @ L70", function()
            local rankData = ns.SpellData[116].ranks[3]
            local state = bootstrap.makeMageState()

            local baselineSpBonus
            unpenalizedBaseline(rankData, function()
                baselineSpBonus = Pipeline.Calculate(116, state, 3).spellPowerBonus
            end)
            assert.is_true(baselineSpBonus > 0, "baseline SP bonus must be positive")

            withMaxLevel(rankData, 19, function()
                local penalized = Pipeline.Calculate(116, state, 3)
                local expectedPenalty = CalculateLevelPenalty(rankData.level, 19, state.level)
                assert.is_near(0.2768, expectedPenalty, 0.0001)
                assert.is_near(baselineSpBonus * expectedPenalty, penalized.spellPowerBonus, 0.001)
            end)
        end)

        -- Phase 4 backfill safety: when a rank's maxLevel is cleared, the
        -- engine must apply no penalty (penalty=1.0).
        it("leaves spellPowerBonus untouched when maxLevel is nil (data backfill safety)", function()
            local rankData = ns.SpellData[116].ranks[3]
            local state = bootstrap.makeMageState()

            unpenalizedBaseline(rankData, function()
                local result = Pipeline.Calculate(116, state, 3)
                -- Without maxLevel, penalty=1.0; spellPowerBonus must equal effectiveSp * effectiveCoeff.
                local sp = state.stats.spellPower[ns.SpellData[116].school]
                local expectedCoeff = rankData.coefficient or ns.SpellData[116].coefficient
                assert.is_near(sp * expectedCoeff, result.spellPowerBonus, 0.001)
            end)
        end)

        -- Top-rank exemption: maxLevel == spellLevel triggers cMaNGOS short-circuit.
        it("applies no penalty when rank is top-rank (maxLevel == level)", function()
            local rankData = ns.SpellData[116].ranks[14]  -- level=69 (top)
            local state = bootstrap.makeMageState()

            local baselineSpBonus
            unpenalizedBaseline(rankData, function()
                baselineSpBonus = Pipeline.Calculate(116, state, 14).spellPowerBonus
            end)
            withMaxLevel(rankData, rankData.level, function()
                local result = Pipeline.Calculate(116, state, 14)
                assert.is_near(baselineSpBonus, result.spellPowerBonus, 0.001)
            end)
        end)
    end)

    describe("hybrid path (BuildHybridResult)", function()
        -- Immolate R1: level=1, has explicit per-rank directCoefficient/dotCoefficient.
        -- Forcing maxLevel=9 (next rank at 10) yields penalty (1, 9, 70):
        --   LvlPenalty = (20 - 1) * 3.75 = 71.25
        --   LvlFactor  = (9 + 6) / 70 = 15/70 ~ 0.21429
        --   Result     = (100 - 71.25) * 0.21429 / 100 ~ 0.0616
        it("scales both directSpBonus and dotSpBonus by the same penalty", function()
            local rankData = ns.SpellData[348].ranks[1]
            local state = bootstrap.makePlayerState()  -- Warlock, 1000 Fire SP

            local baselineDirect, baselineDot
            unpenalizedBaseline(rankData, function()
                local baseline = Pipeline.Calculate(348, state, 1)
                baselineDirect = baseline.directSpBonus
                baselineDot = baseline.dotSpBonus
            end)
            assert.is_true(baselineDirect > 0, "baseline directSpBonus must be positive")
            assert.is_true(baselineDot > 0, "baseline dotSpBonus must be positive")

            withMaxLevel(rankData, 9, function()
                local penalized = Pipeline.Calculate(348, state, 1)
                local expectedPenalty = CalculateLevelPenalty(rankData.level, 9, state.level)
                assert.is_near(baselineDirect * expectedPenalty, penalized.directSpBonus, 0.001)
                assert.is_near(baselineDot * expectedPenalty, penalized.dotSpBonus, 0.001)
            end)
        end)
    end)
end)
