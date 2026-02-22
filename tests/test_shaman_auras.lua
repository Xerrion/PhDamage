-------------------------------------------------------------------------------
-- test_shaman_auras
-- Tests for Shaman aura (buff/debuff) calculations
--
-- Default Shaman state:
--   Nature SP=800, Fire SP=800, Frost SP=800
--   spellCrit=0.10 (all schools), spellHit=0.03
--   intellect=350, attackPower=2000
--
-- Base values (no auras/talents):
--   LB R12:  min=1206.20, max=1287.20 (sp=800, coeff=0.794, cast=2.5)
--   HW R12:  min=2819.60, max=3121.60 (sp=800, coeff=0.857, cast=3.0)
--   FS R5:   min=955.80,  max=991.80  (sp=800, coeff=0.386, cast=1.5, Frost)
--   FlS R7:  hybrid, directCoeff=0.214, dotCoeff=0.1, Fire, cast=1.5
--   LHW R7:  min=1394.20, max=1541.20 (sp=800, coeff=0.429, cast=1.5)
--   CH R5:   min=1404.20, max=1521.20 (sp=800, coeff=0.714, cast=2.5)
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeShamanState = bootstrap.makeShamanState
local Pipeline = ns.Engine.Pipeline

describe("Shaman Auras", function()

    ---------------------------------------------------------------------------
    -- 1. Elemental Mastery (16166) — +100% crit chance + instant cast
    ---------------------------------------------------------------------------
    describe("Elemental Mastery", function()

        it("grants guaranteed crit on Lightning Bolt", function()
            local state = makeShamanState()
            state.auras.player[16166] = true
            local result = Pipeline.Calculate(403, state)

            -- base crit 0.10 + 1.0 bonus = 1.10, capped to 1.0
            assert.is_near(1.0, result.critChance, 0.001)
        end)

        it("makes Lightning Bolt instant cast", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[16166] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(2.5, baseResult.baseCastTime, 0.01)
            -- Override to 0, but effective cast time is clamped to GCD (1.5)
            assert.is_near(0, result.baseCastTime, 0.01)
        end)

        it("makes Healing Wave instant cast", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(331, baseState)

            local state = makeShamanState()
            state.auras.player[16166] = true
            local result = Pipeline.Calculate(331, state)

            assert.is_near(3.0, baseResult.baseCastTime, 0.01)
            assert.is_near(0, result.baseCastTime, 0.01)
        end)

        it("does not change Lightning Bolt base damage", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[16166] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.minDmg, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg, result.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Nature's Swiftness (16188) — instant cast override
    ---------------------------------------------------------------------------
    describe("Nature's Swiftness", function()

        it("makes Healing Wave R12 instant cast", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(331, baseState)

            local state = makeShamanState()
            state.auras.player[16188] = true
            local result = Pipeline.Calculate(331, state)

            assert.is_near(3.0, baseResult.baseCastTime, 0.01)
            assert.is_near(0, result.baseCastTime, 0.01)
        end)

        it("makes Lightning Bolt instant cast", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[16188] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(2.5, baseResult.baseCastTime, 0.01)
            assert.is_near(0, result.baseCastTime, 0.01)
        end)

        it("does not affect crit chance", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[16188] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.critChance, result.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Stormstrike (17364) — target debuff, +20% Nature damage
    ---------------------------------------------------------------------------
    describe("Stormstrike", function()

        it("increases Lightning Bolt R12 damage by 20%", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.target[17364] = true
            local result = Pipeline.Calculate(403, state)

            -- min: 1206.2 * 1.20 = 1447.44
            assert.is_near(baseResult.minDmg * 1.20, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg * 1.20, result.maxDmg, 0.1)
        end)

        it("increases Earth Shock R8 damage by 20%", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(8042, baseState)

            local state = makeShamanState()
            state.auras.target[17364] = true
            local result = Pipeline.Calculate(8042, state)

            assert.is_near(baseResult.minDmg * 1.20, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg * 1.20, result.maxDmg, 0.1)
        end)

        it("does NOT affect Frost Shock (Frost school)", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(8056, baseState)

            local state = makeShamanState()
            state.auras.target[17364] = true
            local result = Pipeline.Calculate(8056, state)

            assert.is_near(baseResult.minDmg, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg, result.maxDmg, 0.1)
        end)

        it("does NOT affect Flame Shock direct damage (Fire school)", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(8050, baseState)

            local state = makeShamanState()
            state.auras.target[17364] = true
            local result = Pipeline.Calculate(8050, state)

            assert.is_near(baseResult.directMin, result.directMin, 0.1)
            assert.is_near(baseResult.directMax, result.directMax, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Wrath of Air Totem (3738) — +101 spell power
    ---------------------------------------------------------------------------
    describe("Wrath of Air Totem", function()

        it("increases Lightning Bolt R12 damage by 101 * 0.794", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[3738] = true
            local result = Pipeline.Calculate(403, state)

            -- SP bonus contribution: 101 * 0.794 = 80.194
            local expectedDelta = 101 * 0.794
            assert.is_near(baseResult.minDmg + expectedDelta, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg + expectedDelta, result.maxDmg, 0.1)
        end)

        it("increases Healing Wave R12 healing by 101 * 0.857", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(331, baseState)

            local state = makeShamanState()
            state.auras.player[3738] = true
            local result = Pipeline.Calculate(331, state)

            local expectedDelta = 101 * 0.857
            assert.is_near(baseResult.minDmg + expectedDelta, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg + expectedDelta, result.maxDmg, 0.1)
        end)

        it("does not affect cast time", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[3738] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.castTime, result.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Totem of Wrath (30708) — +3% spell hit + +3% spell crit
    ---------------------------------------------------------------------------
    describe("Totem of Wrath", function()

        it("increases Lightning Bolt crit chance by 0.03", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[30708] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(0.10, baseResult.critChance, 0.001)
            assert.is_near(0.13, result.critChance, 0.001)
        end)

        it("increases spell hit by 0.03", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[30708] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.hitChance + 0.03, result.hitChance, 0.001)
        end)

        it("affects Healing Wave crit chance too", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(331, baseState)

            local state = makeShamanState()
            state.auras.player[30708] = true
            local result = Pipeline.Calculate(331, state)

            assert.is_near(baseResult.critChance + 0.03, result.critChance, 0.001)
        end)

        it("does not change base damage", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.player[30708] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.minDmg, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg, result.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 6. Healing Way (29203) — +6% Healing Wave healing (target buff)
    ---------------------------------------------------------------------------
    describe("Healing Way", function()

        it("increases Healing Wave R12 healing by 6%", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(331, baseState)

            local state = makeShamanState()
            state.auras.target[29203] = true
            local result = Pipeline.Calculate(331, state)

            assert.is_near(baseResult.minDmg * 1.06, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg * 1.06, result.maxDmg, 0.1)
        end)

        it("does NOT affect Lesser Healing Wave", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(8004, baseState)

            local state = makeShamanState()
            state.auras.target[29203] = true
            local result = Pipeline.Calculate(8004, state)

            assert.is_near(baseResult.minDmg, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg, result.maxDmg, 0.1)
        end)

        it("does NOT affect Chain Heal", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(1064, baseState)

            local state = makeShamanState()
            state.auras.target[29203] = true
            local result = Pipeline.Calculate(1064, state)

            assert.is_near(baseResult.minDmg, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg, result.maxDmg, 0.1)
        end)

        it("does NOT affect Lightning Bolt", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.auras.target[29203] = true
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.minDmg, result.minDmg, 0.1)
            assert.is_near(baseResult.maxDmg, result.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Metadata: verify all 6 aura IDs exist in ns.AuraMap
    ---------------------------------------------------------------------------
    describe("AuraMap metadata", function()
        local expectedAuras = {
            [16166] = "Elemental Mastery",
            [16188] = "Nature's Swiftness",
            [17364] = "Stormstrike",
            [3738]  = "Wrath of Air Totem",
            [30708] = "Totem of Wrath",
            [29203] = "Healing Way",
        }

        for spellID, name in pairs(expectedAuras) do
            it("contains " .. name .. " (" .. spellID .. ")", function()
                assert.is_not_nil(ns.AuraMap[spellID])
                assert.are.equal(name, ns.AuraMap[spellID].name)
            end)
        end
    end)
end)
