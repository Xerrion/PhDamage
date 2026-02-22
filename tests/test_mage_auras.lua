-------------------------------------------------------------------------------
-- test_mage_auras
-- Tests for Mage aura (buff/debuff) modifiers
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeMageState = bootstrap.makeMageState
local Pipeline = ns.Engine.Pipeline

describe("Mage Auras", function()

    describe("Arcane Power", function()
        it("should add 30% damage to Fire spells", function()
            local state = makeMageState()
            state.auras.player[12042] = true
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            assert.is_near(1093 * 1.30, r.minDmg, 1)
            assert.is_near(1215 * 1.30, r.maxDmg, 1)
        end)

        it("should add 30% damage to Frost spells", function()
            local state = makeMageState()
            state.auras.player[12042] = true
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            assert.is_near(1444 * 1.30, r.minDmg, 1)
            assert.is_near(1494 * 1.30, r.maxDmg, 1)
        end)

        it("should add 30% damage to Arcane spells", function()
            local state = makeMageState()
            state.auras.player[12042] = true
            local r = Pipeline.Calculate(30451, state)  -- Arcane Blast
            assert.is_near(1382 * 1.30, r.minDmg, 1)
            assert.is_near(1486 * 1.30, r.maxDmg, 1)
        end)

        it("should stack with talent damage bonuses", function()
            local state = makeMageState()
            state.auras.player[12042] = true
            state.talents["2:13"] = 5  -- Fire Power +10% additive
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            -- Talent additive: 1.10, Arcane Power multiplicative: *1.30
            -- Total: 1093 * 1.10 * 1.30
            assert.is_near(1093 * 1.10 * 1.30, r.minDmg, 1)
        end)

        it("should add 30% damage to channel spells", function()
            local state = makeMageState()
            state.auras.player[12042] = true
            local r = Pipeline.Calculate(5143, state)  -- Arcane Missiles R11
            assert.is_near(2145 * 1.30, r.totalDmg, 1)
        end)

        it("should add 30% damage to hybrid spell direct portion", function()
            local state = makeMageState()
            state.auras.player[12042] = true
            local r = Pipeline.Calculate(133, state)  -- Fireball R14
            assert.is_near(1717 * 1.30, r.directMin, 1)
            assert.is_near(1913 * 1.30, r.directMax, 1)
        end)
    end)

    describe("Molten Armor", function()
        it("should add 3% crit to all spells", function()
            local state = makeMageState()
            state.auras.player[30482] = true
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            assert.is_near(0.10 + 0.03, r.critChance, 0.001)
        end)

        it("should add 3% crit to Fire spells", function()
            local state = makeMageState()
            state.auras.player[30482] = true
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast
            assert.is_near(0.10 + 0.03, r.critChance, 0.001)
        end)

        it("should stack with talent crit bonuses", function()
            local state = makeMageState()
            state.auras.player[30482] = true
            state.talents["2:11"] = 3  -- Critical Mass +6%
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast
            assert.is_near(0.10 + 0.03 + 0.06, r.critChance, 0.001)
        end)
    end)

    -- TODO: Fire Vulnerability (22959) — needs debuff stack tracking
    -- TODO: Icy Veins (12472) — haste handled by WoW API, no damage modifier
end)
