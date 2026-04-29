-------------------------------------------------------------------------------
-- test_mage_spells
-- Tests for Mage base spell damage computation
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeMageState = bootstrap.makeMageState
local Pipeline = ns.Engine.Pipeline

describe("Mage Spells", function()

    -------------------------------------------------------------------------------
    -- Fire Spells
    -------------------------------------------------------------------------------
    describe("Fireball", function()
        it("should compute R14 base direct + DoT damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(133, state)
            assert.is_not_nil(r)
            -- R14: 717-913 direct + 1000*1.0 SP = 1717-1913, avg = 1815
            assert.is_near(1717, r.directMin, 1)
            assert.is_near(1913, r.directMax, 1)
            -- DoT: 84 base, dotCoeff=0.0, so just 84 total
            assert.is_near(84, r.dotTotalDmg, 1)
        end)

        it("should compute R1 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(133, state, 1)
            assert.is_not_nil(r)
            -- R1: level=1, maxLevel=5, per-rank coefficient 0.123.
            -- cMaNGOS-TBC penalty (1, 5, 70):
            --   LvlPenalty = (20-1)*3.75 = 71.25
            --   LvlFactor  = (5+6)/70    = 0.15714
            --   penalty    = (100-71.25)*0.15714/100 = 0.045179
            -- min = 16 + 1000*0.123*0.045179 = 21.557
            -- max = 25 + 1000*0.123*0.045179 = 30.557
            assert.is_near(21.557, r.directMin, 1)
            assert.is_near(30.557, r.directMax, 1)
        end)
    end)

    describe("Fire Blast", function()
        it("should compute R9 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(2136, state)
            assert.is_not_nil(r)
            -- R9: 664-786 + 1000*0.429 = 1093-1215
            assert.is_near(1093, r.minDmg, 1)
            assert.is_near(1215, r.maxDmg, 1)
        end)
    end)

    describe("Scorch", function()
        it("should compute R9 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(2948, state)
            assert.is_not_nil(r)
            -- R9: 305-361 + 1000*0.429 = 734-790
            assert.is_near(734, r.minDmg, 1)
            assert.is_near(790, r.maxDmg, 1)
        end)
    end)

    describe("Pyroblast", function()
        it("should compute R10 base direct + DoT damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(11366, state)
            assert.is_not_nil(r)
            -- R10: 939-1191 direct + 1000*1.15 = 2089-2341, avg = 2215
            assert.is_near(2089, r.directMin, 1)
            assert.is_near(2341, r.directMax, 1)
            -- DoT: 356 base + 1000*0.05*4ticks = 356+200 = 556
            assert.is_near(556, r.dotTotalDmg, 1)
        end)
    end)

    describe("Flamestrike", function()
        it("should compute R7 base direct + DoT damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(2120, state)
            assert.is_not_nil(r)
            -- R7: 480-585 direct + 1000*0.236 = 716-821
            assert.is_near(716, r.directMin, 1)
            assert.is_near(821, r.directMax, 1)
            -- DoT: 424 base + 1000*0.12 (total) = 544
            assert.is_near(544, r.dotTotalDmg, 1)
        end)
    end)

    describe("Blast Wave", function()
        it("should compute R7 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(11113, state)
            assert.is_not_nil(r)
            -- R7: 616-724 + 1000*0.1357 = 751.7-859.7
            assert.is_near(751.7, r.minDmg, 1)
            assert.is_near(859.7, r.maxDmg, 1)
        end)
    end)

    describe("Dragon's Breath", function()
        it("should compute R4 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(31661, state)
            assert.is_not_nil(r)
            -- R4: 680-790 + 1000*0.1357 = 815.7-925.7
            assert.is_near(815.7, r.minDmg, 1)
            assert.is_near(925.7, r.maxDmg, 1)
        end)
    end)

    -------------------------------------------------------------------------------
    -- Frost Spells
    -------------------------------------------------------------------------------
    describe("Frostbolt", function()
        it("should compute R14 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(116, state)
            assert.is_not_nil(r)
            -- R14: 630-680 + 1000*0.814 = 1444-1494
            assert.is_near(1444, r.minDmg, 1)
            assert.is_near(1494, r.maxDmg, 1)
        end)

        it("should compute R13 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(116, state, 13)
            assert.is_not_nil(r)
            -- R13: 600-647 + 1000*0.814 = 1414-1461
            assert.is_near(1414, r.minDmg, 1)
            assert.is_near(1461, r.maxDmg, 1)
        end)
    end)

    describe("Ice Lance", function()
        it("should compute R1 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(30455, state)
            assert.is_not_nil(r)
            -- R1: 173-200 + 1000*0.143 = 316-343
            assert.is_near(316, r.minDmg, 1)
            assert.is_near(343, r.maxDmg, 1)
        end)
    end)

    describe("Cone of Cold", function()
        it("should compute R6 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(120, state)
            assert.is_not_nil(r)
            -- R6: 418-457 + 1000*0.1357 = 553.7-592.7
            assert.is_near(553.7, r.minDmg, 1)
            assert.is_near(592.7, r.maxDmg, 1)
        end)
    end)

    describe("Blizzard", function()
        it("should compute R7 total channel damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(10, state)
            assert.is_not_nil(r)
            -- R7: 1480 base + 1000*0.952 = 2432, tickDmg = 2432/8 = 304
            assert.is_near(2432, r.totalDmg, 1)
            assert.is_near(304, r.tickDmg, 1)
            assert.equals(8, r.numTicks)
        end)
    end)

    describe("Frost Nova", function()
        it("should compute R5 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(122, state)
            assert.is_not_nil(r)
            -- R5: 100-113 + 1000*0.1357 = 235.7-248.7
            assert.is_near(235.7, r.minDmg, 1)
            assert.is_near(248.7, r.maxDmg, 1)
        end)
    end)

    -------------------------------------------------------------------------------
    -- Arcane Spells
    -------------------------------------------------------------------------------
    describe("Arcane Missiles", function()
        it("should compute R11 total channel damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(5143, state)
            assert.is_not_nil(r)
            -- R11: 1430 base + 1000*1.43 (5 missiles x 0.286 SP mod) = 2860
            assert.is_near(2860, r.totalDmg, 1)
            assert.is_near(572, r.tickDmg, 1)
            assert.equals(5, r.numTicks)
        end)
    end)

    describe("Arcane Blast", function()
        it("should compute R1 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(30451, state)
            assert.is_not_nil(r)
            -- R1: 668-772 + 1000*0.714 = 1382-1486
            assert.is_near(1382, r.minDmg, 1)
            assert.is_near(1486, r.maxDmg, 1)
        end)
    end)

    describe("Arcane Explosion", function()
        it("should compute R8 base damage", function()
            local state = makeMageState()
            local r = Pipeline.Calculate(1449, state)
            assert.is_not_nil(r)
            -- R8: 377-407 + 1000*0.213 = 590-620
            assert.is_near(590, r.minDmg, 1)
            assert.is_near(620, r.maxDmg, 1)
        end)
    end)

    -------------------------------------------------------------------------------
    -- Cross-spell verifications
    -------------------------------------------------------------------------------
    describe("Spell metadata", function()
        it("should have all 15 Mage spells in SpellData", function()
            local baseIDs = { 133, 2136, 2948, 11366, 2120, 11113, 31661,
                              116, 30455, 120, 10, 122,
                              5143, 30451, 1449 }
            for _, id in ipairs(baseIDs) do
                assert.is_not_nil(ns.SpellData[id], "Missing spell base ID " .. id)
            end
        end)

        it("should have correct spell types", function()
            assert.equals("hybrid", ns.SpellData[133].spellType)   -- Fireball
            assert.equals("hybrid", ns.SpellData[11366].spellType) -- Pyroblast
            assert.equals("hybrid", ns.SpellData[2120].spellType)  -- Flamestrike
            assert.equals("channel", ns.SpellData[10].spellType)   -- Blizzard
            assert.equals("channel", ns.SpellData[5143].spellType) -- Arcane Missiles
        end)
    end)
end)
