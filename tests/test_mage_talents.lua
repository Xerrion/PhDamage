-------------------------------------------------------------------------------
-- test_mage_talents
-- Tests for Mage talent modifiers
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeMageState = bootstrap.makeMageState
local Pipeline = ns.Engine.Pipeline

describe("Mage Talents", function()

    -------------------------------------------------------------------------------
    -- Arcane Talents
    -------------------------------------------------------------------------------
    describe("Arcane Focus", function()
        it("should add 10% Arcane hit at 5/5", function()
            local state = makeMageState()
            state.talents["1:3"] = 5
            local r = Pipeline.Calculate(30451, state)  -- Arcane Blast
            assert.is_near(0.03 + 0.10, r.hitChance, 0.001)
        end)

        it("should not affect Fire spells", function()
            local state = makeMageState()
            state.talents["1:3"] = 5
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast
            assert.is_near(0.03, r.hitChance, 0.001)
        end)
    end)

    describe("Arcane Impact", function()
        it("should add 6% crit to Arcane Explosion at 3/3", function()
            local state = makeMageState()
            state.talents["1:7"] = 3
            local r = Pipeline.Calculate(1449, state)  -- Arcane Explosion R8
            assert.is_near(0.10 + 0.06, r.critChance, 0.001)
        end)

        it("should add 6% crit to Arcane Blast at 3/3", function()
            local state = makeMageState()
            state.talents["1:7"] = 3
            local r = Pipeline.Calculate(30451, state)  -- Arcane Blast
            assert.is_near(0.10 + 0.06, r.critChance, 0.001)
        end)

        it("should not affect Frostbolt", function()
            local state = makeMageState()
            state.talents["1:7"] = 3
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            assert.is_near(0.10, r.critChance, 0.001)
        end)
    end)

    describe("Arcane Instability", function()
        it("should add 3% damage and 3% crit at 3/3 to all spells", function()
            local state = makeMageState()
            state.talents["1:14"] = 3
            -- Test on Frostbolt
            local r = Pipeline.Calculate(116, state)
            assert.is_near(0.10 + 0.03, r.critChance, 0.001)
            -- Damage: (630-680 + 1000*0.814) * 1.03 = 1487.3-1538.8
            assert.is_near(1487.3, r.minDmg, 1)
            assert.is_near(1538.8, r.maxDmg, 1)
        end)
    end)

    describe("Empowered Arcane Missiles", function()
        it("should add 45% SP coefficient at 3/3", function()
            local state = makeMageState()
            state.talents["1:20"] = 3
            local r = Pipeline.Calculate(5143, state)  -- Arcane Missiles R11
            -- Base: 1430 + 1000*(0.143+0.45)*5 = 1430+2965 = 4395
            assert.is_near(4395, r.totalDmg, 1)
        end)

        it("should not affect Frostbolt", function()
            local state = makeMageState()
            state.talents["1:20"] = 3
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            -- Should still be base: 630-680 + 1000*0.814 = 1444-1494
            assert.is_near(1444, r.minDmg, 1)
        end)
    end)

    describe("Spell Power", function()
        it("should add 25% crit damage bonus at 2/2", function()
            local state = makeMageState()
            state.talents["1:23"] = 2
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            -- critMult = 1.5 + 0.25 = 1.75
            assert.is_near(1.75, r.critMult, 0.001)
        end)

        it("should add 12.5% at 1/2", function()
            local state = makeMageState()
            state.talents["1:23"] = 1
            local r = Pipeline.Calculate(116, state)
            assert.is_near(1.625, r.critMult, 0.001)
        end)
    end)

    -------------------------------------------------------------------------------
    -- Fire Talents
    -------------------------------------------------------------------------------
    describe("Improved Fireball", function()
        it("should reduce cast time by 0.5s at 5/5", function()
            local state = makeMageState()
            state.talents["2:4"] = 5
            local r = Pipeline.Calculate(133, state)  -- Fireball R14
            assert.is_near(3.0, r.castTime, 0.01)  -- 3.5 - 0.5
        end)

        it("should not affect Scorch", function()
            local state = makeMageState()
            state.talents["2:4"] = 5
            local r = Pipeline.Calculate(2948, state)  -- Scorch R9
            assert.is_near(1.5, r.castTime, 0.01)
        end)
    end)

    describe("Improved Flamestrike", function()
        it("should add 15% crit to Flamestrike at 3/3", function()
            local state = makeMageState()
            state.talents["2:9"] = 3
            local r = Pipeline.Calculate(2120, state)  -- Flamestrike R7
            assert.is_near(0.10 + 0.15, r.critChance, 0.001)
        end)
    end)

    describe("Critical Mass", function()
        it("should add 6% crit to Fire spells at 3/3", function()
            local state = makeMageState()
            state.talents["2:11"] = 3
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            assert.is_near(0.10 + 0.06, r.critChance, 0.001)
        end)

        it("should not affect Frost spells", function()
            local state = makeMageState()
            state.talents["2:11"] = 3
            local r = Pipeline.Calculate(116, state)  -- Frostbolt
            assert.is_near(0.10, r.critChance, 0.001)
        end)
    end)

    describe("Fire Power", function()
        it("should add 10% Fire damage at 5/5", function()
            local state = makeMageState()
            state.talents["2:13"] = 5
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            -- (664-786 + 429) * 1.10 = 1093*1.10=1202.3, 1215*1.10=1336.5
            assert.is_near(1202.3, r.minDmg, 1)
            assert.is_near(1336.5, r.maxDmg, 1)
        end)

        it("should stack additively with Playing with Fire", function()
            local state = makeMageState()
            state.talents["2:13"] = 5  -- +10%
            state.talents["2:17"] = 3  -- +3%
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            -- Total additive: 1 + 0.10 + 0.03 = 1.13
            assert.is_near(1093 * 1.13, r.minDmg, 1)
            assert.is_near(1215 * 1.13, r.maxDmg, 1)
        end)

        it("should not affect Frost spells", function()
            local state = makeMageState()
            state.talents["2:13"] = 5
            local r = Pipeline.Calculate(116, state)  -- Frostbolt
            assert.is_near(1444, r.minDmg, 1)
        end)
    end)

    describe("Incineration", function()
        it("should add 4% crit to Fire Blast at 2/2", function()
            local state = makeMageState()
            state.talents["2:15"] = 2
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast
            assert.is_near(0.10 + 0.04, r.critChance, 0.001)
        end)

        it("should add 4% crit to Scorch at 2/2", function()
            local state = makeMageState()
            state.talents["2:15"] = 2
            local r = Pipeline.Calculate(2948, state)  -- Scorch
            assert.is_near(0.10 + 0.04, r.critChance, 0.001)
        end)

        it("should not affect Fireball", function()
            local state = makeMageState()
            state.talents["2:15"] = 2
            local r = Pipeline.Calculate(133, state)  -- Fireball
            assert.is_near(0.10, r.critChance, 0.001)
        end)
    end)

    describe("Playing with Fire", function()
        it("should add 3% damage to all spells at 3/3", function()
            local state = makeMageState()
            state.talents["2:17"] = 3
            -- Test on Frost spell
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            assert.is_near(1444 * 1.03, r.minDmg, 1)
            assert.is_near(1494 * 1.03, r.maxDmg, 1)
        end)
    end)

    describe("Molten Fury", function()
        it("should add 20% damage when target below 20% HP at 2/2", function()
            local state = makeMageState()
            state.talents["2:19"] = 2
            state.targetHealthPercent = 15  -- Below 20%
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            assert.is_near(1093 * 1.20, r.minDmg, 1)
            assert.is_near(1215 * 1.20, r.maxDmg, 1)
        end)

        it("should not apply when target above 20% HP", function()
            local state = makeMageState()
            state.talents["2:19"] = 2
            state.targetHealthPercent = 50
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            assert.is_near(1093, r.minDmg, 1)
        end)

        it("should not apply at exactly 20% HP", function()
            local state = makeMageState()
            state.talents["2:19"] = 2
            state.targetHealthPercent = 20
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            assert.is_near(1093, r.minDmg, 1)
        end)
    end)

    describe("Pyromaniac", function()
        it("should add 3% crit to Fire spells at 3/3", function()
            local state = makeMageState()
            state.talents["2:20"] = 3
            local r = Pipeline.Calculate(2948, state)  -- Scorch
            assert.is_near(0.10 + 0.03, r.critChance, 0.001)
        end)
    end)

    describe("Empowered Fireball", function()
        it("should add 15% SP coefficient at 5/5", function()
            local state = makeMageState()
            state.talents["2:21"] = 5
            local r = Pipeline.Calculate(133, state)  -- Fireball R14
            -- Direct: 717-913 + 1000*(1.0+0.15) = 1867-2063
            assert.is_near(1867, r.directMin, 1)
            assert.is_near(2063, r.directMax, 1)
        end)

        it("should not affect Pyroblast", function()
            local state = makeMageState()
            state.talents["2:21"] = 5
            local r = Pipeline.Calculate(11366, state)  -- Pyroblast R10
            -- Pyroblast unchanged: 939-1191 + 1000*1.15 = 2089-2341
            assert.is_near(2089, r.directMin, 1)
        end)
    end)

    -------------------------------------------------------------------------------
    -- Frost Talents
    -------------------------------------------------------------------------------
    describe("Improved Frostbolt", function()
        it("should reduce cast time by 0.5s at 5/5", function()
            local state = makeMageState()
            state.talents["3:1"] = 5
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            assert.is_near(2.5, r.castTime, 0.01)  -- 3.0 - 0.5
        end)
    end)

    describe("Piercing Ice", function()
        it("should add 6% Frost damage at 3/3", function()
            local state = makeMageState()
            state.talents["3:3"] = 3
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            assert.is_near(1444 * 1.06, r.minDmg, 1)
            assert.is_near(1494 * 1.06, r.maxDmg, 1)
        end)

        it("should not affect Fire spells", function()
            local state = makeMageState()
            state.talents["3:3"] = 3
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast
            assert.is_near(1093, r.minDmg, 1)
        end)
    end)

    describe("Improved Cone of Cold", function()
        it("should add 15% damage at rank 1", function()
            local state = makeMageState()
            state.talents["3:6"] = 1
            local r = Pipeline.Calculate(120, state)  -- Cone of Cold R6
            -- Base: 418-457 + 193 = 611-650
            assert.is_near(611 * 1.15, r.minDmg, 1)
            assert.is_near(650 * 1.15, r.maxDmg, 1)
        end)

        it("should add 25% damage at rank 2", function()
            local state = makeMageState()
            state.talents["3:6"] = 2
            local r = Pipeline.Calculate(120, state)
            assert.is_near(611 * 1.25, r.minDmg, 1)
            assert.is_near(650 * 1.25, r.maxDmg, 1)
        end)

        it("should add 35% damage at rank 3", function()
            local state = makeMageState()
            state.talents["3:6"] = 3
            local r = Pipeline.Calculate(120, state)
            assert.is_near(611 * 1.35, r.minDmg, 1)
            assert.is_near(650 * 1.35, r.maxDmg, 1)
        end)

        it("should not affect Frostbolt", function()
            local state = makeMageState()
            state.talents["3:6"] = 3
            local r = Pipeline.Calculate(116, state)  -- Frostbolt
            assert.is_near(1444, r.minDmg, 1)
        end)
    end)

    describe("Ice Shards", function()
        it("should add 50% crit damage bonus at 5/5 to Frost", function()
            local state = makeMageState()
            state.talents["3:15"] = 5
            local r = Pipeline.Calculate(116, state)  -- Frostbolt
            -- critMult = 1.5 + 0.50 = 2.0
            assert.is_near(2.0, r.critMult, 0.001)
        end)

        it("should not affect Fire spells", function()
            local state = makeMageState()
            state.talents["3:15"] = 5
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast
            assert.is_near(1.5, r.critMult, 0.001)
        end)
    end)

    describe("Elemental Precision", function()
        it("should add 3% hit to Fire spells at 3/3", function()
            local state = makeMageState()
            state.talents["3:17"] = 3
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast
            assert.is_near(0.03 + 0.03, r.hitChance, 0.001)
        end)

        it("should add 3% hit to Frost spells at 3/3", function()
            local state = makeMageState()
            state.talents["3:17"] = 3
            local r = Pipeline.Calculate(116, state)  -- Frostbolt
            assert.is_near(0.03 + 0.03, r.hitChance, 0.001)
        end)

        it("should not affect Arcane spells", function()
            local state = makeMageState()
            state.talents["3:17"] = 3
            local r = Pipeline.Calculate(30451, state)  -- Arcane Blast
            assert.is_near(0.03, r.hitChance, 0.001)
        end)
    end)

    describe("Arctic Winds", function()
        it("should add 5% Frost damage at 5/5", function()
            local state = makeMageState()
            state.talents["3:20"] = 5
            local r = Pipeline.Calculate(116, state)  -- Frostbolt
            assert.is_near(1444 * 1.05, r.minDmg, 1)
            assert.is_near(1494 * 1.05, r.maxDmg, 1)
        end)

        it("should stack additively with Piercing Ice", function()
            local state = makeMageState()
            state.talents["3:3"] = 3   -- +6%
            state.talents["3:20"] = 5  -- +5%
            local r = Pipeline.Calculate(116, state)  -- Frostbolt
            -- Total additive: 1 + 0.06 + 0.05 = 1.11
            assert.is_near(1444 * 1.11, r.minDmg, 1)
            assert.is_near(1494 * 1.11, r.maxDmg, 1)
        end)
    end)

    describe("Empowered Frostbolt", function()
        it("should add 10% SP coefficient and 5% crit at 5/5", function()
            local state = makeMageState()
            state.talents["3:21"] = 5
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            -- Coeff: 0.814 + 0.10 = 0.914
            -- Damage: 630-680 + 1000*0.914 = 1544-1594
            assert.is_near(1544, r.minDmg, 1)
            assert.is_near(1594, r.maxDmg, 1)
            -- Crit: 0.10 + 0.05 = 0.15
            assert.is_near(0.15, r.critChance, 0.001)
        end)

        it("should not affect Ice Lance", function()
            local state = makeMageState()
            state.talents["3:21"] = 5
            local r = Pipeline.Calculate(30455, state)  -- Ice Lance
            assert.is_near(316, r.minDmg, 1)
            assert.is_near(0.10, r.critChance, 0.001)
        end)
    end)

    -------------------------------------------------------------------------------
    -- Combined talent tests
    -------------------------------------------------------------------------------
    describe("Full Fire build", function()
        it("should combine Fire Power + Playing with Fire + Critical Mass + Pyromaniac", function()
            local state = makeMageState()
            state.talents["2:13"] = 5  -- Fire Power +10%
            state.talents["2:17"] = 3  -- Playing with Fire +3%
            state.talents["2:11"] = 3  -- Critical Mass +6% crit
            state.talents["2:20"] = 3  -- Pyromaniac +3% crit
            local r = Pipeline.Calculate(2136, state)  -- Fire Blast R9
            -- Damage: (664-786 + 429) * (1 + 0.10 + 0.03) = 1093*1.13, 1215*1.13
            assert.is_near(1093 * 1.13, r.minDmg, 1)
            assert.is_near(1215 * 1.13, r.maxDmg, 1)
            -- Crit: 0.10 + 0.06 + 0.03 = 0.19
            assert.is_near(0.19, r.critChance, 0.001)
        end)
    end)

    describe("Full Frost build", function()
        it("should combine Piercing Ice + Arctic Winds + Ice Shards + Empowered Frostbolt", function()
            local state = makeMageState()
            state.talents["3:3"] = 3   -- Piercing Ice +6%
            state.talents["3:20"] = 5  -- Arctic Winds +5%
            state.talents["3:15"] = 5  -- Ice Shards +50% crit bonus
            state.talents["3:21"] = 5  -- Empowered Frostbolt +0.10 coeff, +5% crit
            local r = Pipeline.Calculate(116, state)  -- Frostbolt R14
            -- Coeff: 0.814 + 0.10 = 0.914
            -- Base: 630-680 + 1000*0.914 = 1544-1594
            -- Damage mult: 1 + 0.06 + 0.05 = 1.11
            -- Final: 1544*1.11, 1594*1.11
            assert.is_near(1544 * 1.11, r.minDmg, 1)
            assert.is_near(1594 * 1.11, r.maxDmg, 1)
            -- Crit: 0.10 + 0.05 = 0.15
            assert.is_near(0.15, r.critChance, 0.001)
            -- CritMult: 1.5 + 0.50 = 2.0
            assert.is_near(2.0, r.critMult, 0.001)
        end)
    end)
end)
