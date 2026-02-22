-------------------------------------------------------------------------------
-- test_paladin_spells
-- Tests for Paladin spell calculations
--
-- Default Paladin state:
--   Holy SP = 800, healingPower = 900
--   spellCrit = 0.15 for Holy
--   spellHit = 0.05
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePaladinState = bootstrap.makePaladinState
local Pipeline = ns.Engine.Pipeline

describe("Paladin Spells", function()

    ---------------------------------------------------------------------------
    -- HEALING SPELLS
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 1. Holy Light (base ID 635)
    -- Holy direct heal, 2.5s cast, coefficient 0.714
    ---------------------------------------------------------------------------
    describe("Holy Light", function()

        it("calculates base healing for Holy Light R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(635, state, 1)
            assert.is_not_nil(result)
            assert.equals("Holy Light", result.spellName)
            -- avg = (42 + 51) / 2 = 46.5
            assert.is_near(46.5, result.damageAfterMods, 0.01)
        end)

        it("calculates base healing for Holy Light R11 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(635, state)
            assert.is_not_nil(result)
            -- avg = (2196 + 2446) / 2 = 2321
            assert.is_near(2321, result.damageAfterMods, 0.01)
        end)

        it("scales Holy Light R11 with healing power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 900
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(635, state)
            -- SP bonus = 900 * 0.714 = 642.6
            -- Total = 2321 + 642.6 = 2963.6
            assert.is_near(2963.6, result.damageAfterMods, 0.01)
        end)

        it("is flagged as a heal", function()
            local spellData = ns.SpellData[635]
            assert.is_true(spellData.isHeal)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Flash of Light (base ID 19750)
    -- Holy direct heal, 1.5s cast, coefficient 0.429
    ---------------------------------------------------------------------------
    describe("Flash of Light", function()

        it("calculates base healing for Flash of Light R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(19750, state, 1)
            assert.is_not_nil(result)
            assert.equals("Flash of Light", result.spellName)
            -- avg = (67 + 77) / 2 = 72
            assert.is_near(72, result.damageAfterMods, 0.01)
        end)

        it("calculates base healing for Flash of Light R7 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(19750, state)
            assert.is_not_nil(result)
            -- avg = (458 + 513) / 2 = 485.5
            assert.is_near(485.5, result.damageAfterMods, 0.01)
        end)

        it("scales Flash of Light R7 with healing power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 900
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(19750, state)
            -- SP bonus = 900 * 0.429 = 386.1
            -- Total = 485.5 + 386.1 = 871.6
            assert.is_near(871.6, result.damageAfterMods, 0.01)
        end)

        it("is flagged as a heal", function()
            local spellData = ns.SpellData[19750]
            assert.is_true(spellData.isHeal)
        end)
    end)

    ---------------------------------------------------------------------------
    -- HOLY DAMAGE SPELLS
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 3. Consecration (base ID 26573, DoT)
    -- Holy AoE ground DoT, instant cast, coefficient 0.119 (total),
    -- 8s duration, 8 ticks
    ---------------------------------------------------------------------------
    describe("Consecration", function()

        it("calculates base damage for Consecration R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(26573, state, 1)
            assert.is_not_nil(result)
            assert.equals("Consecration", result.spellName)
            -- totalDmg = 64, perTick = 64 / 8 = 8
            assert.is_near(64, result.totalDmg, 0.01)
            assert.is_near(8, result.tickDmg, 0.01)
        end)

        it("calculates base damage for Consecration R6 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(26573, state)
            assert.is_not_nil(result)
            -- totalDmg = 512, perTick = 512 / 8 = 64
            assert.is_near(512, result.totalDmg, 0.01)
            assert.is_near(64, result.tickDmg, 0.01)
        end)

        it("scales Consecration R6 with spell power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 800
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(26573, state)
            -- SP bonus = 800 * 0.119 = 95.2
            -- totalDmg = 512 + 95.2 = 607.2
            -- tickDmg = 607.2 / 8 = 75.9
            assert.is_near(607.2, result.totalDmg, 0.01)
            assert.is_near(75.9, result.tickDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makePaladinState()
            local result = Pipeline.Calculate(26573, state)
            assert.equals(8, result.numTicks)
            assert.equals(8, result.duration)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Exorcism (base ID 879)
    -- Holy direct, 1.5s cast, coefficient 0.429
    ---------------------------------------------------------------------------
    describe("Exorcism", function()

        it("calculates base damage for Exorcism R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(879, state, 1)
            assert.is_not_nil(result)
            assert.equals("Exorcism", result.spellName)
            -- avg = (90 + 102) / 2 = 96
            assert.is_near(96, result.damageAfterMods, 0.01)
        end)

        it("calculates base damage for Exorcism R7 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(879, state)
            assert.is_not_nil(result)
            -- avg = (626 + 698) / 2 = 662
            assert.is_near(662, result.damageAfterMods, 0.01)
        end)

        it("scales Exorcism R7 with spell power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 800
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(879, state)
            -- SP bonus = 800 * 0.429 = 343.2
            -- Total = 662 + 343.2 = 1005.2
            assert.is_near(1005.2, result.damageAfterMods, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Hammer of Wrath (base ID 24275)
    -- Holy direct, instant cast, coefficient 0.429
    ---------------------------------------------------------------------------
    describe("Hammer of Wrath", function()

        it("calculates base damage for Hammer of Wrath R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(24275, state, 1)
            assert.is_not_nil(result)
            assert.equals("Hammer of Wrath", result.spellName)
            -- avg = (316 + 348) / 2 = 332
            assert.is_near(332, result.damageAfterMods, 0.01)
        end)

        it("calculates base damage for Hammer of Wrath R4 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(24275, state)
            assert.is_not_nil(result)
            -- avg = (672 + 742) / 2 = 707
            assert.is_near(707, result.damageAfterMods, 0.01)
        end)

        it("scales Hammer of Wrath R4 with spell power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 800
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(24275, state)
            -- SP bonus = 800 * 0.429 = 343.2
            -- Total = 707 + 343.2 = 1050.2
            assert.is_near(1050.2, result.damageAfterMods, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 6. Holy Wrath (base ID 2812)
    -- Holy direct, 2.0s cast, coefficient 0.286
    ---------------------------------------------------------------------------
    describe("Holy Wrath", function()

        it("calculates base damage for Holy Wrath R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(2812, state, 1)
            assert.is_not_nil(result)
            assert.equals("Holy Wrath", result.spellName)
            -- avg = (368 + 435) / 2 = 401.5
            assert.is_near(401.5, result.damageAfterMods, 0.01)
        end)

        it("calculates base damage for Holy Wrath R3 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(2812, state)
            assert.is_not_nil(result)
            -- avg = (637 + 748) / 2 = 692.5
            assert.is_near(692.5, result.damageAfterMods, 0.01)
        end)

        it("scales Holy Wrath R3 with spell power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 800
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(2812, state)
            -- SP bonus = 800 * 0.286 = 228.8
            -- Total = 692.5 + 228.8 = 921.3
            assert.is_near(921.3, result.damageAfterMods, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 7. Holy Shock — Damage (base ID 20473)
    -- Holy direct, instant cast, coefficient 0.429
    ---------------------------------------------------------------------------
    describe("Holy Shock (Damage)", function()

        it("calculates base damage for Holy Shock R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(20473, state, 1)
            assert.is_not_nil(result)
            assert.equals("Holy Shock", result.spellName)
            -- avg = (277 + 299) / 2 = 288
            assert.is_near(288, result.damageAfterMods, 0.01)
        end)

        it("calculates base damage for Holy Shock R5 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(20473, state)
            assert.is_not_nil(result)
            -- avg = (721 + 779) / 2 = 750
            assert.is_near(750, result.damageAfterMods, 0.01)
        end)

        it("scales Holy Shock R5 damage with spell power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 800
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(20473, state)
            -- SP bonus = 800 * 0.429 = 343.2
            -- Total = 750 + 343.2 = 1093.2
            assert.is_near(1093.2, result.damageAfterMods, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 8. Holy Shock — Heal (base ID 200473)
    -- Holy direct heal, instant cast, coefficient 0.429
    ---------------------------------------------------------------------------
    describe("Holy Shock (Heal)", function()

        it("calculates base healing for Holy Shock R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(200473, state, 1)
            assert.is_not_nil(result)
            assert.equals("Holy Shock", result.spellName)
            -- avg = (351 + 379) / 2 = 365
            assert.is_near(365, result.damageAfterMods, 0.01)
        end)

        it("calculates base healing for Holy Shock R5 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(200473, state)
            assert.is_not_nil(result)
            -- avg = (913 + 987) / 2 = 950
            assert.is_near(950, result.damageAfterMods, 0.01)
        end)

        it("scales Holy Shock R5 heal with healing power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 900
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(200473, state)
            -- SP bonus = 900 * 0.429 = 386.1
            -- Total = 950 + 386.1 = 1336.1
            assert.is_near(1336.1, result.damageAfterMods, 0.01)
        end)

        it("is flagged as a heal", function()
            local spellData = ns.SpellData[200473]
            assert.is_true(spellData.isHeal)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 9. Avenger's Shield (base ID 31935)
    -- Holy direct, instant cast, coefficient 0.07
    ---------------------------------------------------------------------------
    describe("Avenger's Shield", function()

        it("calculates base damage for Avenger's Shield R1 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(31935, state, 1)
            assert.is_not_nil(result)
            assert.equals("Avenger's Shield", result.spellName)
            -- avg = (270 + 330) / 2 = 300
            assert.is_near(300, result.damageAfterMods, 0.01)
        end)

        it("calculates base damage for Avenger's Shield R3 (no SP)", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 0
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(31935, state)
            assert.is_not_nil(result)
            -- avg = (494 + 602) / 2 = 548
            assert.is_near(548, result.damageAfterMods, 0.01)
        end)

        it("scales Avenger's Shield R3 with spell power", function()
            local state = makePaladinState()
            state.stats.spellPower[2] = 800
            state.stats.healingPower = 0
            local result = Pipeline.Calculate(31935, state)
            -- SP bonus = 800 * 0.07 = 56
            -- Total = 548 + 56 = 604
            assert.is_near(604, result.damageAfterMods, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Spell metadata verification
    ---------------------------------------------------------------------------
    describe("Spell metadata", function()

        it("has all 9 Paladin spells in SpellData", function()
            local baseIDs = {
                635,    -- Holy Light
                19750,  -- Flash of Light
                200473, -- Holy Shock (Heal)
                26573,  -- Consecration
                879,    -- Exorcism
                24275,  -- Hammer of Wrath
                2812,   -- Holy Wrath
                20473,  -- Holy Shock (Damage)
                31935,  -- Avenger's Shield
            }
            for _, id in ipairs(baseIDs) do
                assert.is_not_nil(ns.SpellData[id], "Missing spell base ID " .. id)
            end
        end)

        it("has correct spell types", function()
            assert.equals("direct", ns.SpellData[635].spellType)    -- Holy Light
            assert.equals("direct", ns.SpellData[19750].spellType)  -- Flash of Light
            assert.equals("direct", ns.SpellData[200473].spellType) -- Holy Shock (Heal)
            assert.equals("dot", ns.SpellData[26573].spellType)     -- Consecration
            assert.equals("direct", ns.SpellData[879].spellType)    -- Exorcism
            assert.equals("direct", ns.SpellData[24275].spellType)  -- Hammer of Wrath
            assert.equals("direct", ns.SpellData[2812].spellType)   -- Holy Wrath
            assert.equals("direct", ns.SpellData[20473].spellType)  -- Holy Shock (Damage)
            assert.equals("direct", ns.SpellData[31935].spellType)  -- Avenger's Shield
        end)

        it("has correct schools", function()
            local allIDs = { 635, 19750, 200473, 26573, 879, 24275, 2812, 20473, 31935 }
            for _, id in ipairs(allIDs) do
                assert.equals(ns.SCHOOL_HOLY, ns.SpellData[id].school,
                    "Expected Holy school for spell " .. id)
            end
        end)

        it("healing spells have isHeal=true", function()
            local healIDs = { 635, 19750, 200473 }
            for _, id in ipairs(healIDs) do
                assert.is_true(ns.SpellData[id].isHeal,
                    "Expected isHeal=true for spell " .. id)
            end
        end)

        it("damage spells do not have isHeal", function()
            local damageIDs = { 26573, 879, 24275, 2812, 20473, 31935 }
            for _, id in ipairs(damageIDs) do
                assert.is_falsy(ns.SpellData[id].isHeal,
                    "Expected isHeal falsy for spell " .. id)
            end
        end)

        it("has correct coefficients", function()
            assert.is_near(0.714, ns.SpellData[635].coefficient, 0.001)    -- Holy Light
            assert.is_near(0.429, ns.SpellData[19750].coefficient, 0.001)  -- Flash of Light
            assert.is_near(0.429, ns.SpellData[200473].coefficient, 0.001) -- Holy Shock (Heal)
            assert.is_near(0.119, ns.SpellData[26573].coefficient, 0.001)  -- Consecration
            assert.is_near(0.429, ns.SpellData[879].coefficient, 0.001)    -- Exorcism
            assert.is_near(0.429, ns.SpellData[24275].coefficient, 0.001)  -- Hammer of Wrath
            assert.is_near(0.286, ns.SpellData[2812].coefficient, 0.001)   -- Holy Wrath
            assert.is_near(0.429, ns.SpellData[20473].coefficient, 0.001)  -- Holy Shock (Dmg)
            assert.is_near(0.07, ns.SpellData[31935].coefficient, 0.001)   -- Avenger's Shield
        end)

        it("has correct rank counts", function()
            assert.equals(11, #ns.SpellData[635].ranks)    -- Holy Light
            assert.equals(7, #ns.SpellData[19750].ranks)   -- Flash of Light
            assert.equals(5, #ns.SpellData[200473].ranks)  -- Holy Shock (Heal)
            assert.equals(6, #ns.SpellData[26573].ranks)   -- Consecration
            assert.equals(7, #ns.SpellData[879].ranks)     -- Exorcism
            assert.equals(4, #ns.SpellData[24275].ranks)   -- Hammer of Wrath
            assert.equals(3, #ns.SpellData[2812].ranks)    -- Holy Wrath
            assert.equals(5, #ns.SpellData[20473].ranks)   -- Holy Shock (Dmg)
            assert.equals(3, #ns.SpellData[31935].ranks)   -- Avenger's Shield
        end)
    end)
end)
