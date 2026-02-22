-------------------------------------------------------------------------------
-- test_priest_spells
-- Tests for Priest base spell damage computation
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePriestState = bootstrap.makePriestState
local Pipeline = ns.Engine.Pipeline

describe("Priest Spells", function()

    ---------------------------------------------------------------------------
    -- Shadow Spells
    ---------------------------------------------------------------------------
    describe("Shadow Word: Pain", function()
        it("should compute R10 total DoT damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(589, state)
            assert.is_not_nil(r)
            -- R10: 1236 base + 1000*1.098 = 2334
            assert.is_near(2334, r.totalDmg, 1)
            assert.is_near(389, r.tickDmg, 1)
            assert.equals(6, r.numTicks)
        end)

        it("should compute R1 total DoT damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(589, state, 1)
            assert.is_not_nil(r)
            -- R1: 30 base + 1000*1.098 = 1128
            assert.is_near(1128, r.totalDmg, 1)
        end)
    end)

    describe("Mind Blast", function()
        it("should compute R11 base damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(8092, state)
            assert.is_not_nil(r)
            -- R11: 708-748 + 1000*0.4286 = 1136.6-1176.6
            assert.is_near(1136.6, r.minDmg, 1)
            assert.is_near(1176.6, r.maxDmg, 1)
        end)

        it("should compute R1 base damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(8092, state, 1)
            assert.is_not_nil(r)
            -- R1: 39-43 + 1000*0.4286 = 467.6-471.6
            assert.is_near(467.6, r.minDmg, 1)
            assert.is_near(471.6, r.maxDmg, 1)
        end)
    end)

    describe("Mind Flay", function()
        it("should compute R7 total channel damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(15407, state)
            assert.is_not_nil(r)
            -- R7: 528 base + 1000*0.57 = 1098
            assert.is_near(1098, r.totalDmg, 1)
            assert.is_near(366, r.tickDmg, 1)
            assert.equals(3, r.numTicks)
        end)

        it("should compute R1 total channel damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(15407, state, 1)
            assert.is_not_nil(r)
            -- R1: 75 base + 1000*0.57 = 645
            assert.is_near(645, r.totalDmg, 1)
        end)
    end)

    describe("Shadow Word: Death", function()
        it("should compute R2 base damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(32379, state)
            assert.is_not_nil(r)
            -- R2: 572-664 + 1000*0.429 = 1001-1093
            assert.is_near(1001, r.minDmg, 1)
            assert.is_near(1093, r.maxDmg, 1)
        end)

        it("should compute R1 base damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(32379, state, 1)
            assert.is_not_nil(r)
            -- R1: 450-522 + 1000*0.429 = 879-951
            assert.is_near(879, r.minDmg, 1)
            assert.is_near(951, r.maxDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Holy Spells
    ---------------------------------------------------------------------------
    describe("Smite", function()
        it("should compute R10 base damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(585, state)
            assert.is_not_nil(r)
            -- R10: 545-611 + 1000*0.7143 = 1259.3-1325.3
            assert.is_near(1259.3, r.minDmg, 1)
            assert.is_near(1325.3, r.maxDmg, 1)
        end)

        it("should compute R1 base damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(585, state, 1)
            assert.is_not_nil(r)
            -- R1: 13-17 + 1000*0.7143 = 727.3-731.3
            assert.is_near(727.3, r.minDmg, 1)
            assert.is_near(731.3, r.maxDmg, 1)
        end)
    end)

    describe("Holy Fire", function()
        it("should compute R9 base direct + DoT damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(14914, state)
            assert.is_not_nil(r)
            -- R9: 412-522 direct + 1000*0.857 = 1269-1379
            assert.is_near(1269, r.directMin, 1)
            assert.is_near(1379, r.directMax, 1)
            -- DoT: 165 base + 1000*0.165 = 330
            assert.is_near(330, r.dotTotalDmg, 1)
        end)

        it("should compute R1 base direct + DoT damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(14914, state, 1)
            assert.is_not_nil(r)
            -- R1: 78-98 direct + 1000*0.857 = 935-955
            assert.is_near(935, r.directMin, 1)
            assert.is_near(955, r.directMax, 1)
            -- DoT: 30 base + 1000*0.165 = 195
            assert.is_near(195, r.dotTotalDmg, 1)
        end)
    end)

    describe("Holy Nova", function()
        it("should compute R7 base damage", function()
            local state = makePriestState()
            local r = Pipeline.Calculate(15237, state)
            assert.is_not_nil(r)
            -- R7: 242-280 + 1000*0.161 = 403-441
            assert.is_near(403, r.minDmg, 1)
            assert.is_near(441, r.maxDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Cross-spell verifications
    ---------------------------------------------------------------------------
    describe("Spell metadata", function()
        it("should have all 7 Priest spells in SpellData", function()
            local baseIDs = { 589, 8092, 15407, 32379, 585, 14914, 15237 }
            for _, id in ipairs(baseIDs) do
                assert.is_not_nil(ns.SpellData[id], "Missing spell base ID " .. id)
            end
        end)

        it("should have correct spell types", function()
            assert.equals("dot", ns.SpellData[589].spellType)       -- SWP
            assert.equals("direct", ns.SpellData[8092].spellType)   -- Mind Blast
            assert.equals("channel", ns.SpellData[15407].spellType)  -- Mind Flay
            assert.equals("direct", ns.SpellData[32379].spellType)  -- SW:Death
            assert.equals("direct", ns.SpellData[585].spellType)    -- Smite
            assert.equals("hybrid", ns.SpellData[14914].spellType)  -- Holy Fire
            assert.equals("direct", ns.SpellData[15237].spellType)  -- Holy Nova
        end)

        it("should have correct schools", function()
            assert.equals(32, ns.SpellData[589].school)    -- Shadow
            assert.equals(32, ns.SpellData[8092].school)   -- Shadow
            assert.equals(32, ns.SpellData[15407].school)  -- Shadow
            assert.equals(32, ns.SpellData[32379].school)  -- Shadow
            assert.equals(2, ns.SpellData[585].school)     -- Holy
            assert.equals(2, ns.SpellData[14914].school)   -- Holy
            assert.equals(2, ns.SpellData[15237].school)   -- Holy
        end)
    end)
end)
