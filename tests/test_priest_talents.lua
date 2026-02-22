-------------------------------------------------------------------------------
-- test_priest_talents
-- Tests for Priest talent modifiers
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePriestState = bootstrap.makePriestState
local Pipeline = ns.Engine.Pipeline

describe("Priest Talents", function()

    ---------------------------------------------------------------------------
    -- Discipline Talents
    ---------------------------------------------------------------------------
    describe("Force of Will", function()
        it("should add 5% damage and 5% crit at 5/5", function()
            local state = makePriestState()
            state.talents["1:15"] = 5
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            -- Damage: (708-748 + 428.6) * 1.05 = 1136.6*1.05, 1176.6*1.05
            assert.is_near(1136.6 * 1.05, r.minDmg, 1)
            assert.is_near(1176.6 * 1.05, r.maxDmg, 1)
            -- Crit: 0.10 + 0.05 = 0.15
            assert.is_near(0.15, r.critChance, 0.001)
        end)

        it("should add 2% damage and 2% crit at 2/5", function()
            local state = makePriestState()
            state.talents["1:15"] = 2
            local r = Pipeline.Calculate(8092, state)
            assert.is_near(1136.6 * 1.02, r.minDmg, 1)
            assert.is_near(0.12, r.critChance, 0.001)
        end)

        it("should affect holy spells too", function()
            local state = makePriestState()
            state.talents["1:15"] = 5
            local r = Pipeline.Calculate(585, state)  -- Smite R10
            assert.is_near(1259.3 * 1.05, r.minDmg, 1)
            assert.is_near(0.15, r.critChance, 0.001)
        end)
    end)

    describe("Focused Power", function()
        it("should add 4% damage at 2/2", function()
            local state = makePriestState()
            state.talents["1:20"] = 2
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            assert.is_near(1136.6 * 1.04, r.minDmg, 1)
            assert.is_near(1176.6 * 1.04, r.maxDmg, 1)
        end)

        it("should affect holy spells", function()
            local state = makePriestState()
            state.talents["1:20"] = 2
            local r = Pipeline.Calculate(585, state)  -- Smite R10
            assert.is_near(1259.3 * 1.04, r.minDmg, 1)
        end)

        it("should stack additively with Force of Will", function()
            local state = makePriestState()
            state.talents["1:15"] = 5  -- +5%
            state.talents["1:20"] = 2  -- +4%
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast
            -- Total additive: 1 + 0.05 + 0.04 = 1.09
            assert.is_near(1136.6 * 1.09, r.minDmg, 1)
            assert.is_near(1176.6 * 1.09, r.maxDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Holy Talents
    ---------------------------------------------------------------------------
    describe("Holy Specialization", function()
        it("should add 5% holy crit at 5/5", function()
            local state = makePriestState()
            state.talents["2:3"] = 5
            local r = Pipeline.Calculate(585, state)  -- Smite R10
            assert.is_near(0.15, r.critChance, 0.001)
        end)

        it("should not affect Shadow spells", function()
            local state = makePriestState()
            state.talents["2:3"] = 5
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast
            assert.is_near(0.10, r.critChance, 0.001)
        end)
    end)

    describe("Searing Light", function()
        it("should add 10% Smite damage at 2/2", function()
            local state = makePriestState()
            state.talents["2:13"] = 2
            local r = Pipeline.Calculate(585, state)  -- Smite R10
            assert.is_near(1259.3 * 1.10, r.minDmg, 1)
            assert.is_near(1325.3 * 1.10, r.maxDmg, 1)
        end)

        it("should add 10% Holy Fire damage at 2/2", function()
            local state = makePriestState()
            state.talents["2:13"] = 2
            local r = Pipeline.Calculate(14914, state)  -- Holy Fire R9
            assert.is_near(1269 * 1.10, r.directMin, 1)
            assert.is_near(1379 * 1.10, r.directMax, 1)
            assert.is_near(330 * 1.10, r.dotTotalDmg, 1)
        end)

        it("should not affect Mind Blast", function()
            local state = makePriestState()
            state.talents["2:13"] = 2
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast
            assert.is_near(1136.6, r.minDmg, 1)
        end)

        it("should not affect Holy Nova", function()
            local state = makePriestState()
            state.talents["2:13"] = 2
            local r = Pipeline.Calculate(15237, state)  -- Holy Nova R7
            assert.is_near(403, r.minDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Shadow Talents
    ---------------------------------------------------------------------------
    describe("Shadow Focus", function()
        it("should add 10% shadow hit at 5/5", function()
            local state = makePriestState()
            state.talents["3:2"] = 5
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast
            assert.is_near(0.13, r.hitChance, 0.001)
        end)

        it("should not affect holy spells", function()
            local state = makePriestState()
            state.talents["3:2"] = 5
            local r = Pipeline.Calculate(585, state)  -- Smite
            assert.is_near(0.03, r.hitChance, 0.001)
        end)
    end)

    describe("Improved Shadow Word: Pain", function()
        it("should add 6% SWP damage at 2/2", function()
            local state = makePriestState()
            state.talents["3:4"] = 2
            local r = Pipeline.Calculate(589, state)  -- SWP R10
            -- 2334 * 1.06 = 2474.04
            assert.is_near(2334 * 1.06, r.totalDmg, 1)
            assert.is_near(2334 * 1.06 / 6, r.tickDmg, 1)
        end)

        it("should not affect Mind Blast", function()
            local state = makePriestState()
            state.talents["3:4"] = 2
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast
            assert.is_near(1136.6, r.minDmg, 1)
        end)
    end)

    describe("Darkness", function()
        it("should add 10% shadow damage at 5/5", function()
            local state = makePriestState()
            state.talents["3:15"] = 5
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            assert.is_near(1136.6 * 1.10, r.minDmg, 1)
            assert.is_near(1176.6 * 1.10, r.maxDmg, 1)
        end)

        it("should add 4% at 2/5", function()
            local state = makePriestState()
            state.talents["3:15"] = 2
            local r = Pipeline.Calculate(8092, state)
            assert.is_near(1136.6 * 1.04, r.minDmg, 1)
        end)

        it("should not affect holy spells", function()
            local state = makePriestState()
            state.talents["3:15"] = 5
            local r = Pipeline.Calculate(585, state)  -- Smite
            assert.is_near(1259.3, r.minDmg, 1)
        end)

        it("should affect SWP", function()
            local state = makePriestState()
            state.talents["3:15"] = 5
            local r = Pipeline.Calculate(589, state)  -- SWP R10
            assert.is_near(2334 * 1.10, r.totalDmg, 1)
        end)
    end)

    describe("Shadow Power", function()
        it("should add 50% crit damage bonus at 5/5", function()
            local state = makePriestState()
            state.talents["3:22"] = 5
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast
            -- critMult = 1.5 + 0.50 = 2.0
            assert.is_near(2.0, r.critMult, 0.001)
        end)

        it("should add 20% at 2/5", function()
            local state = makePriestState()
            state.talents["3:22"] = 2
            local r = Pipeline.Calculate(8092, state)
            assert.is_near(1.7, r.critMult, 0.001)
        end)

        it("should not affect holy spells", function()
            local state = makePriestState()
            state.talents["3:22"] = 5
            local r = Pipeline.Calculate(585, state)  -- Smite
            assert.is_near(1.5, r.critMult, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Combined talent tests
    ---------------------------------------------------------------------------
    describe("Full Shadow build", function()
        it("should combine Force of Will + Focused Power + Shadow Focus + Darkness + Shadow Power", function()
            local state = makePriestState()
            state.talents["1:15"] = 5  -- Force of Will +5% dmg, +5% crit
            state.talents["1:20"] = 2  -- Focused Power +4% dmg
            state.talents["3:2"] = 5   -- Shadow Focus +10% hit
            state.talents["3:15"] = 5  -- Darkness +10% dmg
            state.talents["3:22"] = 5  -- Shadow Power +50% crit bonus
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            -- Additive damage: 1 + 0.05 + 0.04 + 0.10 = 1.19
            assert.is_near(1136.6 * 1.19, r.minDmg, 1)
            assert.is_near(1176.6 * 1.19, r.maxDmg, 1)
            -- Crit: 0.10 + 0.05 = 0.15
            assert.is_near(0.15, r.critChance, 0.001)
            -- CritMult: 1.5 + 0.50 = 2.0
            assert.is_near(2.0, r.critMult, 0.001)
            -- Hit: 0.03 + 0.10 = 0.13
            assert.is_near(0.13, r.hitChance, 0.001)
        end)
    end)

    describe("Full Holy build", function()
        it("should combine Force of Will + Focused Power + Holy Spec + Searing Light on Smite", function()
            local state = makePriestState()
            state.talents["1:15"] = 5  -- Force of Will +5% dmg, +5% crit
            state.talents["1:20"] = 2  -- Focused Power +4% dmg
            state.talents["2:3"] = 5   -- Holy Specialization +5% crit
            state.talents["2:13"] = 2  -- Searing Light +10% Smite/HF dmg
            local r = Pipeline.Calculate(585, state)  -- Smite R10
            -- Additive damage: 1 + 0.05 + 0.04 + 0.10 = 1.19
            assert.is_near(1259.3 * 1.19, r.minDmg, 1)
            assert.is_near(1325.3 * 1.19, r.maxDmg, 1)
            -- Crit: 0.10 + 0.05 + 0.05 = 0.20
            assert.is_near(0.20, r.critChance, 0.001)
        end)
    end)
end)
