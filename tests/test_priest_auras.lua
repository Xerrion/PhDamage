-------------------------------------------------------------------------------
-- test_priest_auras
-- Tests for Priest aura (buff/debuff) modifiers
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePriestState = bootstrap.makePriestState
local Pipeline = ns.Engine.Pipeline

describe("Priest Auras", function()

    describe("Shadowform", function()
        it("should add 15% damage to shadow spells", function()
            local state = makePriestState()
            state.auras.player[15473] = true
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            assert.is_near(1136.6 * 1.15, r.minDmg, 1)
            assert.is_near(1176.6 * 1.15, r.maxDmg, 1)
        end)

        it("should not affect holy spells", function()
            local state = makePriestState()
            state.auras.player[15473] = true
            local r = Pipeline.Calculate(585, state)  -- Smite R10
            assert.is_near(1259.3, r.minDmg, 1)
            assert.is_near(1325.3, r.maxDmg, 1)
        end)

        it("should affect SWP", function()
            local state = makePriestState()
            state.auras.player[15473] = true
            local r = Pipeline.Calculate(589, state)  -- SWP R10
            assert.is_near(2334 * 1.15, r.totalDmg, 1)
        end)

        it("should affect Mind Flay", function()
            local state = makePriestState()
            state.auras.player[15473] = true
            local r = Pipeline.Calculate(15407, state)  -- Mind Flay R7
            assert.is_near(1098 * 1.15, r.totalDmg, 1)
        end)
    end)

    describe("Power Infusion", function()
        it("should add 20% damage to all spells", function()
            local state = makePriestState()
            state.auras.player[10060] = true
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            assert.is_near(1136.6 * 1.20, r.minDmg, 1)
            assert.is_near(1176.6 * 1.20, r.maxDmg, 1)
        end)

        it("should affect holy spells", function()
            local state = makePriestState()
            state.auras.player[10060] = true
            local r = Pipeline.Calculate(585, state)  -- Smite R10
            assert.is_near(1259.3 * 1.20, r.minDmg, 1)
            assert.is_near(1325.3 * 1.20, r.maxDmg, 1)
        end)
    end)

    describe("Shadow Weaving", function()
        it("should add 10% shadow damage on target", function()
            local state = makePriestState()
            state.auras.target[15258] = true
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            assert.is_near(1136.6 * 1.10, r.minDmg, 1)
            assert.is_near(1176.6 * 1.10, r.maxDmg, 1)
        end)

        it("should not affect holy spells", function()
            local state = makePriestState()
            state.auras.target[15258] = true
            local r = Pipeline.Calculate(585, state)  -- Smite R10
            assert.is_near(1259.3, r.minDmg, 1)
        end)
    end)

    describe("Stacking", function()
        it("should stack Shadowform + Shadow Weaving multiplicatively", function()
            local state = makePriestState()
            state.auras.player[15473] = true  -- Shadowform +15%
            state.auras.target[15258] = true  -- Shadow Weaving +10%
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            -- 1.15 * 1.10 = 1.265
            assert.is_near(1136.6 * 1.265, r.minDmg, 1)
            assert.is_near(1176.6 * 1.265, r.maxDmg, 1)
        end)

        it("should stack Shadowform with Darkness talent", function()
            local state = makePriestState()
            state.auras.player[15473] = true  -- Shadowform +15% (multiplicative)
            state.talents["3:2"] = 5          -- Darkness +10% (additive)
            local r = Pipeline.Calculate(8092, state)  -- Mind Blast R11
            -- Talent additive: 1.10, Shadowform multiplicative: *1.15
            -- Total: 1136.6 * 1.10 * 1.15
            assert.is_near(1136.6 * 1.10 * 1.15, r.minDmg, 1)
            assert.is_near(1176.6 * 1.10 * 1.15, r.maxDmg, 1)
        end)
    end)
end)
