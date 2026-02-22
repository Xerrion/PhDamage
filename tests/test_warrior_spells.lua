-------------------------------------------------------------------------------
-- test_warrior_spells.lua
-- Tests for Warrior base spell damage computation
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeWarriorState = bootstrap.makeWarriorState

local Pipeline = ns.Engine.Pipeline

-------------------------------------------------------------------------------
-- Mortal Strike (baseID 12294)
-- Weapon + flat 210 bonus, weaponMultiplier = 1.0
-- normalizedSpeed = 3.3 (TWO_HAND)
-- apBonus = 2000 / 14 * 3.3 = 471.4286
-- min = 200 + 471.4286 + 210 = 881.4286
-- max = 350 + 471.4286 + 210 = 1031.4286
-------------------------------------------------------------------------------
describe("Warrior Spells", function()

    describe("Mortal Strike", function()

        it("calculates R6 base damage", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(12294, state)
            assert.is_not_nil(result)
            assert.equals("Mortal Strike", result.spellName)
            assert.is_near(881.43, result.minDmg, 0.01)
            assert.is_near(1031.43, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeWarriorState()
            state.stats.attackPower = 3000
            -- apBonus = 3000 / 14 * 3.3 = 707.1429
            -- min = 200 + 707.1429 + 210 = 1117.1429
            -- max = 350 + 707.1429 + 210 = 1267.1429
            local result = Pipeline.Calculate(12294, state)
            assert.is_near(1117.14, result.minDmg, 0.01)
            assert.is_near(1267.14, result.maxDmg, 0.01)
        end)

        it("uses ONE_HAND normalized speed when weapon type changes", function()
            local state = makeWarriorState()
            state.stats.mainHandWeaponType = "ONE_HAND"
            -- normalizedSpeed = 2.4
            -- apBonus = 2000 / 14 * 2.4 = 342.8571
            -- min = 200 + 342.8571 + 210 = 752.8571
            -- max = 350 + 342.8571 + 210 = 902.8571
            local result = Pipeline.Calculate(12294, state)
            assert.is_near(752.86, result.minDmg, 0.01)
            assert.is_near(902.86, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Overpower (baseID 7384)
    -- Weapon + flat 35 bonus
    -- min = 200 + 471.4286 + 35 = 706.4286
    -- max = 350 + 471.4286 + 35 = 856.4286
    ---------------------------------------------------------------------------
    describe("Overpower", function()

        it("calculates R4 base damage", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(7384, state)
            assert.is_not_nil(result)
            assert.equals("Overpower", result.spellName)
            assert.is_near(706.43, result.minDmg, 0.01)
            assert.is_near(856.43, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeWarriorState()
            state.stats.attackPower = 3000
            -- apBonus = 3000 / 14 * 3.3 = 707.1429
            -- min = 200 + 707.1429 + 35 = 942.1429
            -- max = 350 + 707.1429 + 35 = 1092.1429
            local result = Pipeline.Calculate(7384, state)
            assert.is_near(942.14, result.minDmg, 0.01)
            assert.is_near(1092.14, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Slam (baseID 1464)
    -- Weapon + flat 140 bonus, castTime = 1.5
    -- min = 200 + 471.4286 + 140 = 811.4286
    -- max = 350 + 471.4286 + 140 = 961.4286
    ---------------------------------------------------------------------------
    describe("Slam", function()

        it("calculates R6 base damage", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(1464, state)
            assert.is_not_nil(result)
            assert.equals("Slam", result.spellName)
            assert.is_near(811.43, result.minDmg, 0.01)
            assert.is_near(961.43, result.maxDmg, 0.01)
        end)

        it("has cast time of 1.5 seconds", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(1464, state)
            assert.is_near(1.5, result.castTime, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeWarriorState()
            state.stats.attackPower = 3000
            -- apBonus = 3000 / 14 * 3.3 = 707.1429
            -- min = 200 + 707.1429 + 140 = 1047.1429
            -- max = 350 + 707.1429 + 140 = 1197.1429
            local result = Pipeline.Calculate(1464, state)
            assert.is_near(1047.14, result.minDmg, 0.01)
            assert.is_near(1197.14, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Thunder Clap (baseID 6343)
    -- Flat damage only, no weapon/AP scaling
    -- min = max = 123
    ---------------------------------------------------------------------------
    describe("Thunder Clap", function()

        it("calculates R7 base damage", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(6343, state)
            assert.is_not_nil(result)
            assert.equals("Thunder Clap", result.spellName)
            assert.is_near(123, result.minDmg, 0.01)
            assert.is_near(123, result.maxDmg, 0.01)
        end)

        it("is not affected by AP changes", function()
            local state = makeWarriorState()
            state.stats.attackPower = 3000
            local result = Pipeline.Calculate(6343, state)
            assert.is_near(123, result.minDmg, 0.01)
            assert.is_near(123, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Execute (baseID 5308)
    -- Flat base damage only (rage bonus not modeled)
    -- min = max = 925
    ---------------------------------------------------------------------------
    describe("Execute", function()

        it("calculates R7 base damage", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(5308, state)
            assert.is_not_nil(result)
            assert.equals("Execute", result.spellName)
            assert.is_near(925, result.minDmg, 0.01)
            assert.is_near(925, result.maxDmg, 0.01)
        end)

        it("is not affected by AP changes", function()
            local state = makeWarriorState()
            state.stats.attackPower = 3000
            local result = Pipeline.Calculate(5308, state)
            assert.is_near(925, result.minDmg, 0.01)
            assert.is_near(925, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Bloodthirst (baseID 23881)
    -- 45% of AP = 2000 * 0.45 = 900
    -- min = max = 900
    ---------------------------------------------------------------------------
    describe("Bloodthirst", function()

        it("calculates R6 base damage", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(23881, state)
            assert.is_not_nil(result)
            assert.equals("Bloodthirst", result.spellName)
            assert.is_near(900, result.minDmg, 0.01)
            assert.is_near(900, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeWarriorState()
            state.stats.attackPower = 3000
            -- 3000 * 0.45 = 1350
            local result = Pipeline.Calculate(23881, state)
            assert.is_near(1350, result.minDmg, 0.01)
            assert.is_near(1350, result.maxDmg, 0.01)
        end)

        it("is not affected by weapon damage changes", function()
            local state = makeWarriorState()
            state.stats.mainHandWeaponDmgMin = 500
            state.stats.mainHandWeaponDmgMax = 700
            local result = Pipeline.Calculate(23881, state)
            -- Still 2000 * 0.45 = 900
            assert.is_near(900, result.minDmg, 0.01)
            assert.is_near(900, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Whirlwind (baseID 1680)
    -- Weapon damage only, no flat bonus (minDmg = maxDmg = 0)
    -- min = 200 + 471.4286 + 0 = 671.4286
    -- max = 350 + 471.4286 + 0 = 821.4286
    ---------------------------------------------------------------------------
    describe("Whirlwind", function()

        it("calculates R1 base damage", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(1680, state)
            assert.is_not_nil(result)
            assert.equals("Whirlwind", result.spellName)
            assert.is_near(671.43, result.minDmg, 0.01)
            assert.is_near(821.43, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeWarriorState()
            state.stats.attackPower = 3000
            -- apBonus = 3000 / 14 * 3.3 = 707.1429
            -- min = 200 + 707.1429 + 0 = 907.1429
            -- max = 350 + 707.1429 + 0 = 1057.1429
            local result = Pipeline.Calculate(1680, state)
            assert.is_near(907.14, result.minDmg, 0.01)
            assert.is_near(1057.14, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Rend (baseID 772)
    -- DoT with weapon scaling via weaponDotCoefficient
    -- baseDmg = 182
    -- weaponAvg = (200 + 350) / 2 = 275
    -- normalizedDmg = 275 + 2000/14 * 3.6 = 275 + 514.2857 = 789.2857
    -- (uses actual weaponSpeed 3.6, NOT normalized 3.3)
    -- totalDmg = 182 + 0.00743 * 7 * 789.2857
    --          = 182 + 0.05201 * 789.2857
    --          = 182 + 41.0497
    --          = 223.05
    ---------------------------------------------------------------------------
    describe("Rend", function()

        it("calculates R8 total DoT damage", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(772, state)
            assert.is_not_nil(result)
            assert.equals("Rend", result.spellName)
            assert.is_near(223.05, result.totalDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeWarriorState()
            state.stats.attackPower = 3000
            -- normalizedDmg = 275 + 3000/14 * 3.6 = 275 + 771.4286 = 1046.4286
            -- totalDmg = 182 + 0.00743 * 7 * 1046.4286
            --          = 182 + 0.05201 * 1046.4286
            --          = 182 + 54.4248
            --          = 236.42
            local result = Pipeline.Calculate(772, state)
            assert.is_near(236.42, result.totalDmg, 0.01)
        end)

        it("has tick damage equal to totalDmg / numTicks", function()
            local state = makeWarriorState()
            local result = Pipeline.Calculate(772, state)
            if result.numTicks and result.numTicks > 0 then
                assert.is_near(result.totalDmg / result.numTicks, result.tickDmg, 0.01)
            end
        end)
    end)

    ---------------------------------------------------------------------------
    -- Spell metadata verification
    ---------------------------------------------------------------------------
    describe("Spell metadata", function()

        it("has all 8 Warrior spells in SpellData", function()
            local baseIDs = { 12294, 7384, 1464, 6343, 5308, 23881, 1680, 772 }
            for _, id in ipairs(baseIDs) do
                assert.is_not_nil(ns.SpellData[id], "Missing spell base ID " .. id)
            end
        end)

        it("has correct spell types", function()
            assert.equals("direct", ns.SpellData[12294].spellType) -- Mortal Strike
            assert.equals("direct", ns.SpellData[7384].spellType)  -- Overpower
            assert.equals("direct", ns.SpellData[1464].spellType)  -- Slam
            assert.equals("direct", ns.SpellData[6343].spellType)  -- Thunder Clap
            assert.equals("direct", ns.SpellData[5308].spellType)  -- Execute
            assert.equals("direct", ns.SpellData[23881].spellType) -- Bloodthirst
            assert.equals("direct", ns.SpellData[1680].spellType)  -- Whirlwind
            assert.equals("dot", ns.SpellData[772].spellType)      -- Rend
        end)

        it("has correct schools", function()
            local baseIDs = { 12294, 7384, 1464, 6343, 5308, 23881, 1680, 772 }
            for _, id in ipairs(baseIDs) do
                assert.equals(ns.SCHOOL_PHYSICAL, ns.SpellData[id].school,
                    "Expected Physical school for spell " .. id)
            end
        end)
    end)
end)
