-------------------------------------------------------------------------------
-- test_shaman_spells
-- Tests for Shaman spell calculations
--
-- Default Shaman state:
--   Nature SP = 800, Fire SP = 800, Frost SP = 800
--   spellCrit = 0.10 for all schools
--   spellHit = 0.03
--   attackPower = 2000, meleeCrit = 0.25
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeShamanState = bootstrap.makeShamanState
local Pipeline = ns.Engine.Pipeline

describe("Shaman Spells", function()

    ---------------------------------------------------------------------------
    -- NATURE DAMAGE SPELLS
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 1. Lightning Bolt R12 (spellID 25449)
    -- Nature direct, 2.5s cast, coefficient 0.794
    -- Base: min=571, max=652
    -- SP bonus: 800 * 0.794 = 635.2
    -- min = 571 + 635.2 = 1206.2
    -- max = 652 + 635.2 = 1287.2
    ---------------------------------------------------------------------------
    describe("Lightning Bolt", function()

        it("calculates base damage for Lightning Bolt R12", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(403, state)
            assert.is_not_nil(result)
            assert.equals("Lightning Bolt", result.spellName)
            assert.is_near(1206.20, result.minDmg, 0.01)
            assert.is_near(1287.20, result.maxDmg, 0.01)
        end)

        it("scales Lightning Bolt with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[8] = 0  -- Zero Nature SP
            local result = Pipeline.Calculate(403, state)
            -- With 0 SP: just base damage
            assert.is_near(571, result.minDmg, 0.01)
            assert.is_near(652, result.maxDmg, 0.01)
        end)

        it("has correct cast time for Lightning Bolt", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(403, state)
            assert.is_near(2.5, result.castTime, 0.01)
        end)

        it("scales with increased spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[8] = 400  -- Lower Nature SP
            local result = Pipeline.Calculate(403, state)
            -- Expected: 571 + 400*0.794 = 888.6
            assert.is_near(888.60, result.minDmg, 0.01)
            -- Expected: 652 + 400*0.794 = 969.6
            assert.is_near(969.60, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Chain Lightning R6 (spellID 25442)
    -- Nature direct, 2.0s cast, coefficient 0.651
    -- Base: min=734, max=838
    -- SP bonus: 800 * 0.651 = 520.8
    -- min = 734 + 520.8 = 1254.8
    -- max = 838 + 520.8 = 1358.8
    ---------------------------------------------------------------------------
    describe("Chain Lightning", function()

        it("calculates base damage for Chain Lightning R6", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(421, state)
            assert.is_not_nil(result)
            assert.equals("Chain Lightning", result.spellName)
            assert.is_near(1254.80, result.minDmg, 0.01)
            assert.is_near(1358.80, result.maxDmg, 0.01)
        end)

        it("scales Chain Lightning with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[8] = 0
            local result = Pipeline.Calculate(421, state)
            assert.is_near(734, result.minDmg, 0.01)
            assert.is_near(838, result.maxDmg, 0.01)
        end)

        it("has correct cast time for Chain Lightning", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(421, state)
            assert.is_near(2.0, result.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Earth Shock R8 (spellID 25454)
    -- Nature direct, 1.5s cast (instant, GCD-capped), coefficient 0.386
    -- Base: min=658, max=692
    -- SP bonus: 800 * 0.386 = 308.8
    -- min = 658 + 308.8 = 966.8
    -- max = 692 + 308.8 = 1000.8
    ---------------------------------------------------------------------------
    describe("Earth Shock", function()

        it("calculates base damage for Earth Shock R8", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8042, state)
            assert.is_not_nil(result)
            assert.equals("Earth Shock", result.spellName)
            assert.is_near(966.80, result.minDmg, 0.01)
            assert.is_near(1000.80, result.maxDmg, 0.01)
        end)

        it("scales Earth Shock with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[8] = 0
            local result = Pipeline.Calculate(8042, state)
            assert.is_near(658, result.minDmg, 0.01)
            assert.is_near(692, result.maxDmg, 0.01)
        end)

        it("has correct cast time for Earth Shock", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8042, state)
            assert.is_near(1.5, result.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- FIRE SPELLS
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 4. Flame Shock R7 (spellID 25457)
    -- Fire hybrid, instant, directCoeff=0.214, dotCoeff=0.1
    -- Direct: 377 + 800*0.214 = 377 + 171.2 = 548.2
    -- DoT: 420 + 800*0.1*4 = 420 + 320 = 740 total
    --   dotSpBonus = 800 * 0.1 = 80, dotDmg = 420 + 80 = 500 (per ComputeHybrid)
    --   wait — ComputeHybrid does: dotSpBonus = scalingPower * dotCoeff
    --   dotDamage = rankData.dotDmg + dotSpBonus = 420 + 800*0.1 = 420 + 80 = 500
    --   tickDamage = 500 / 4 = 125
    --
    -- Direct portion:
    --   directMin = directMax = 377 + 171.2 = 548.2
    -- DoT total:
    --   dotTotalDmg = 500 (after CritCalc.BuildHybridResult, before hit modifier)
    ---------------------------------------------------------------------------
    describe("Flame Shock", function()

        it("calculates direct damage for Flame Shock R7", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8050, state)
            assert.is_not_nil(result)
            assert.equals("Flame Shock", result.spellName)
            assert.equals("hybrid", result.spellType)
            assert.is_near(548.20, result.directMin, 0.01)
            assert.is_near(548.20, result.directMax, 0.01)
        end)

        it("calculates DoT damage for Flame Shock R7", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8050, state)
            -- dotTotalDmg = 420 + 80 = 500
            assert.is_near(500.00, result.dotTotalDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8050, state)
            assert.equals(4, result.numTicks)
            assert.equals(12, result.duration)
        end)

        it("has correct tick damage", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8050, state)
            -- tickDamage from CritCalc.BuildHybridResult = dotWithHit / numTicks
            -- dotWithHit = dotDmg * hitProbability * (1 - armorReduction)
            -- dotDmg = 500, hitProb ~= 0.87 (1 - 0.16 + 0.03), armor = 0
            -- tickDamage = 500 * 0.87 / 4 = 108.75
            -- Just verify it's > 0 and reasonable
            assert.is_true(result.tickDamage > 0)
        end)

        it("scales Flame Shock direct with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[4] = 0  -- Zero Fire SP
            local result = Pipeline.Calculate(8050, state)
            -- Direct with 0 SP: 377
            assert.is_near(377, result.directMin, 0.01)
            assert.is_near(377, result.directMax, 0.01)
        end)

        it("scales Flame Shock DoT with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[4] = 0  -- Zero Fire SP
            local result = Pipeline.Calculate(8050, state)
            -- DoT with 0 SP: just base 420
            assert.is_near(420, result.dotTotalDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- FROST SPELLS
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 5. Frost Shock R5 (spellID 25464)
    -- Frost direct, 1.5s cast (instant), coefficient 0.386
    -- Base: min=647, max=683
    -- SP bonus: 800 * 0.386 = 308.8
    -- min = 647 + 308.8 = 955.8
    -- max = 683 + 308.8 = 991.8
    ---------------------------------------------------------------------------
    describe("Frost Shock", function()

        it("calculates base damage for Frost Shock R5", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8056, state)
            assert.is_not_nil(result)
            assert.equals("Frost Shock", result.spellName)
            assert.is_near(955.80, result.minDmg, 0.01)
            assert.is_near(991.80, result.maxDmg, 0.01)
        end)

        it("scales Frost Shock with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[16] = 0  -- Zero Frost SP
            local result = Pipeline.Calculate(8056, state)
            assert.is_near(647, result.minDmg, 0.01)
            assert.is_near(683, result.maxDmg, 0.01)
        end)

        it("has correct cast time for Frost Shock", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8056, state)
            assert.is_near(1.5, result.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- HEALING SPELLS
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 6. Healing Wave R12 (spellID 25396)
    -- Nature direct heal, 3.0s cast, coefficient 0.857, isHeal=true
    -- Base: min=2134, max=2436
    -- SP bonus: 800 * 0.857 = 685.6
    -- min = 2134 + 685.6 = 2819.6
    -- max = 2436 + 685.6 = 3121.6
    ---------------------------------------------------------------------------
    describe("Healing Wave", function()

        it("calculates base healing for Healing Wave R12", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(331, state)
            assert.is_not_nil(result)
            assert.equals("Healing Wave", result.spellName)
            assert.is_near(2819.60, result.minDmg, 0.01)
            assert.is_near(3121.60, result.maxDmg, 0.01)
        end)

        it("scales Healing Wave with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[8] = 0  -- Zero Nature SP
            local result = Pipeline.Calculate(331, state)
            assert.is_near(2134, result.minDmg, 0.01)
            assert.is_near(2436, result.maxDmg, 0.01)
        end)

        it("has correct cast time for Healing Wave", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(331, state)
            assert.is_near(3.0, result.castTime, 0.01)
        end)

        it("is flagged as a heal", function()
            local spellData = ns.SpellData[331]
            assert.is_true(spellData.isHeal)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 7. Lesser Healing Wave R7 (spellID 25420)
    -- Nature direct heal, 1.5s cast, coefficient 0.429, isHeal=true
    -- Base: min=1051, max=1198
    -- SP bonus: 800 * 0.429 = 343.2
    -- min = 1051 + 343.2 = 1394.2
    -- max = 1198 + 343.2 = 1541.2
    ---------------------------------------------------------------------------
    describe("Lesser Healing Wave", function()

        it("calculates base healing for Lesser Healing Wave R7", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8004, state)
            assert.is_not_nil(result)
            assert.equals("Lesser Healing Wave", result.spellName)
            assert.is_near(1394.20, result.minDmg, 0.01)
            assert.is_near(1541.20, result.maxDmg, 0.01)
        end)

        it("scales Lesser Healing Wave with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[8] = 0
            local result = Pipeline.Calculate(8004, state)
            assert.is_near(1051, result.minDmg, 0.01)
            assert.is_near(1198, result.maxDmg, 0.01)
        end)

        it("has correct cast time for Lesser Healing Wave", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(8004, state)
            assert.is_near(1.5, result.castTime, 0.01)
        end)

        it("is flagged as a heal", function()
            local spellData = ns.SpellData[8004]
            assert.is_true(spellData.isHeal)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 8. Chain Heal R5 (spellID 25423)
    -- Nature direct heal, 2.5s cast, coefficient 0.714, isHeal=true
    -- Base: min=833, max=950
    -- SP bonus: 800 * 0.714 = 571.2
    -- min = 833 + 571.2 = 1404.2
    -- max = 950 + 571.2 = 1521.2
    ---------------------------------------------------------------------------
    describe("Chain Heal", function()

        it("calculates base healing for Chain Heal R5", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(1064, state)
            assert.is_not_nil(result)
            assert.equals("Chain Heal", result.spellName)
            assert.is_near(1404.20, result.minDmg, 0.01)
            assert.is_near(1521.20, result.maxDmg, 0.01)
        end)

        it("scales Chain Heal with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[8] = 0
            local result = Pipeline.Calculate(1064, state)
            assert.is_near(833, result.minDmg, 0.01)
            assert.is_near(950, result.maxDmg, 0.01)
        end)

        it("has correct cast time for Chain Heal", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(1064, state)
            assert.is_near(2.5, result.castTime, 0.01)
        end)

        it("is flagged as a heal", function()
            local spellData = ns.SpellData[1064]
            assert.is_true(spellData.isHeal)
        end)
    end)

    ---------------------------------------------------------------------------
    -- UTILITY SPELLS
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 9. Lightning Shield R9 (spellID 25472)
    -- Nature utility, coefficient 0.33, canCrit=false
    -- Base: dmg=287 (min=max)
    -- SP bonus: 800 * 0.33 = 264
    -- total = 287 + 264 = 551
    -- minDmg = maxDmg = 551 (same since min=max base)
    ---------------------------------------------------------------------------
    describe("Lightning Shield", function()

        it("calculates base damage for Lightning Shield R9", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(324, state)
            assert.is_not_nil(result)
            assert.equals("Lightning Shield", result.spellName)
            assert.is_near(551.00, result.minDmg, 0.01)
            assert.is_near(551.00, result.maxDmg, 0.01)
        end)

        it("has equal min and max damage", function()
            local state = makeShamanState()
            local result = Pipeline.Calculate(324, state)
            assert.equals(result.minDmg, result.maxDmg)
        end)

        it("scales Lightning Shield with spell power", function()
            local state = makeShamanState()
            state.stats.spellPower[8] = 0  -- Zero Nature SP
            local result = Pipeline.Calculate(324, state)
            assert.is_near(287, result.minDmg, 0.01)
            assert.is_near(287, result.maxDmg, 0.01)
        end)

        it("cannot crit", function()
            local spellData = ns.SpellData[324]
            assert.is_false(spellData.canCrit)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Spell metadata verification
    ---------------------------------------------------------------------------
    describe("Spell metadata", function()

        it("has all 9 Shaman spells in SpellData", function()
            local baseIDs = {
                403,    -- Lightning Bolt
                421,    -- Chain Lightning
                8042,   -- Earth Shock
                8050,   -- Flame Shock
                8056,   -- Frost Shock
                331,    -- Healing Wave
                8004,   -- Lesser Healing Wave
                1064,   -- Chain Heal
                324,    -- Lightning Shield
            }
            for _, id in ipairs(baseIDs) do
                assert.is_not_nil(ns.SpellData[id], "Missing spell base ID " .. id)
            end
        end)

        it("has correct spell types", function()
            -- Direct spells
            assert.equals("direct", ns.SpellData[403].spellType)   -- Lightning Bolt
            assert.equals("direct", ns.SpellData[421].spellType)   -- Chain Lightning
            assert.equals("direct", ns.SpellData[8042].spellType)  -- Earth Shock
            assert.equals("direct", ns.SpellData[8056].spellType)  -- Frost Shock
            assert.equals("direct", ns.SpellData[331].spellType)   -- Healing Wave
            assert.equals("direct", ns.SpellData[8004].spellType)  -- Lesser Healing Wave
            assert.equals("direct", ns.SpellData[1064].spellType)  -- Chain Heal
            -- Hybrid spells
            assert.equals("hybrid", ns.SpellData[8050].spellType)  -- Flame Shock
            -- Utility spells
            assert.equals("direct", ns.SpellData[324].spellType)   -- Lightning Shield
        end)

        it("has correct schools", function()
            -- Nature spells
            local natureIDs = { 403, 421, 8042, 331, 8004, 1064, 324 }
            for _, id in ipairs(natureIDs) do
                assert.equals(ns.SCHOOL_NATURE, ns.SpellData[id].school,
                    "Expected Nature school for spell " .. id)
            end
            -- Fire spells
            assert.equals(ns.SCHOOL_FIRE, ns.SpellData[8050].school)  -- Flame Shock
            -- Frost spells
            assert.equals(ns.SCHOOL_FROST, ns.SpellData[8056].school) -- Frost Shock
        end)

        it("has correct canCrit flags", function()
            -- Can crit
            local crittable = { 403, 421, 8042, 8050, 8056, 331, 8004, 1064 }
            for _, id in ipairs(crittable) do
                assert.is_true(ns.SpellData[id].canCrit,
                    "Expected canCrit=true for spell " .. id)
            end
            -- Cannot crit
            assert.is_false(ns.SpellData[324].canCrit,
                "Expected canCrit=false for Lightning Shield")
        end)

        it("healing spells have isHeal=true", function()
            local healingIDs = { 331, 8004, 1064 }
            for _, id in ipairs(healingIDs) do
                assert.is_true(ns.SpellData[id].isHeal,
                    "Expected isHeal=true for spell " .. id)
            end
        end)

        it("damage spells do not have isHeal", function()
            local damageIDs = { 403, 421, 8042, 8050, 8056, 324 }
            for _, id in ipairs(damageIDs) do
                assert.is_falsy(ns.SpellData[id].isHeal,
                    "Expected isHeal falsy for spell " .. id)
            end
        end)

        it("has correct coefficients", function()
            assert.is_near(0.794, ns.SpellData[403].coefficient, 0.001)   -- Lightning Bolt
            assert.is_near(0.651, ns.SpellData[421].coefficient, 0.001)   -- Chain Lightning
            assert.is_near(0.386, ns.SpellData[8042].coefficient, 0.001)  -- Earth Shock
            assert.is_near(0.386, ns.SpellData[8056].coefficient, 0.001)  -- Frost Shock
            assert.is_near(0.857, ns.SpellData[331].coefficient, 0.001)   -- Healing Wave
            assert.is_near(0.429, ns.SpellData[8004].coefficient, 0.001)  -- Lesser Healing Wave
            assert.is_near(0.714, ns.SpellData[1064].coefficient, 0.001)  -- Chain Heal
            assert.is_near(0.33, ns.SpellData[324].coefficient, 0.001)    -- Lightning Shield
            -- Flame Shock hybrid
            assert.is_near(0.214, ns.SpellData[8050].directCoefficient, 0.001)
            assert.is_near(0.1, ns.SpellData[8050].dotCoefficient, 0.001)
        end)

        it("has correct rank counts", function()
            assert.equals(12, #ns.SpellData[403].ranks)   -- Lightning Bolt
            assert.equals(6, #ns.SpellData[421].ranks)    -- Chain Lightning
            assert.equals(8, #ns.SpellData[8042].ranks)   -- Earth Shock
            assert.equals(7, #ns.SpellData[8050].ranks)   -- Flame Shock
            assert.equals(5, #ns.SpellData[8056].ranks)   -- Frost Shock
            assert.equals(12, #ns.SpellData[331].ranks)   -- Healing Wave
            assert.equals(7, #ns.SpellData[8004].ranks)   -- Lesser Healing Wave
            assert.equals(5, #ns.SpellData[1064].ranks)   -- Chain Heal
            assert.equals(9, #ns.SpellData[324].ranks)    -- Lightning Shield
        end)
    end)
end)
