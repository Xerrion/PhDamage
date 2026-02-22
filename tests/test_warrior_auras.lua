-------------------------------------------------------------------------------
-- test_warrior_auras
-- Tests for Warrior aura (buff/debuff) modifiers
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeWarriorState = bootstrap.makeWarriorState
local Pipeline = ns.Engine.Pipeline

-- Mortal Strike (baseID 12294) base damage at default state:
-- apBonus = 2000 / 14 * 3.3 = 471.4286
-- min = 200 + 471.4286 + 210 = 881.4286
-- max = 350 + 471.4286 + 210 = 1031.4286

describe("Warrior Auras", function()

    describe("Death Wish", function()
        it("should add 20% physical damage to Mortal Strike", function()
            local state = makeWarriorState()
            state.auras.player[12292] = true
            local r = Pipeline.Calculate(12294, state)  -- Mortal Strike R6
            assert.is_near(881.43 * 1.20, r.minDmg, 1)
            assert.is_near(1031.43 * 1.20, r.maxDmg, 1)
        end)
    end)

    describe("Blood Frenzy R1", function()
        it("should add 2% physical damage on target", function()
            local state = makeWarriorState()
            state.auras.target[29836] = true
            local r = Pipeline.Calculate(12294, state)  -- Mortal Strike R6
            assert.is_near(881.43 * 1.02, r.minDmg, 1)
            assert.is_near(1031.43 * 1.02, r.maxDmg, 1)
        end)
    end)

    describe("Blood Frenzy R2", function()
        it("should add 4% physical damage on target", function()
            local state = makeWarriorState()
            state.auras.target[29859] = true
            local r = Pipeline.Calculate(12294, state)  -- Mortal Strike R6
            assert.is_near(881.43 * 1.04, r.minDmg, 1)
            assert.is_near(1031.43 * 1.04, r.maxDmg, 1)
        end)
    end)

    describe("Stacking", function()
        it("should stack Death Wish + Blood Frenzy R2 multiplicatively", function()
            local state = makeWarriorState()
            state.auras.player[12292] = true  -- Death Wish +20%
            state.auras.target[29859] = true  -- Blood Frenzy R2 +4%
            local r = Pipeline.Calculate(12294, state)  -- Mortal Strike R6
            -- 1.20 * 1.04 = 1.248
            assert.is_near(881.43 * 1.20 * 1.04, r.minDmg, 1)
            assert.is_near(1031.43 * 1.20 * 1.04, r.maxDmg, 1)
        end)
    end)
end)
