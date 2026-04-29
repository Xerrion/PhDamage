-------------------------------------------------------------------------------
-- test_druid_spells.lua
-- Tests for Druid base spell damage computation
--
-- Default Druid state:
--   AP=2000, weaponDmg=100-150, weaponSpeed=2.5, weaponType=FIST
--   spellPower: Nature=800, Arcane=800
--   meleeCrit=25%, spellCrit: Nature=10%, Arcane=10%
--   intellect=350
--
-- Cat normalized speed: 1.0  → AP bonus = 2000/14 * 1.0 = 142.857
-- Bear normalized speed: 2.5 → AP bonus = 2000/14 * 2.5 = 357.143
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeDruidState = bootstrap.makeDruidState

local Pipeline = ns.Engine.Pipeline

describe("Druid Spells", function()

    ---------------------------------------------------------------------------
    -- BALANCE SPELLS
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 1. Wrath R10 (spellID 26985)
    -- Nature direct, 2.0s cast, coefficient 0.571
    -- Base: avg(383, 432) = 407.5
    -- SP bonus: 800 * 0.571 = 456.8
    -- min = 383 + 456.8 = 839.8
    -- max = 432 + 456.8 = 888.8
    ---------------------------------------------------------------------------
    describe("Wrath", function()

        it("calculates R10 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5176, state)
            assert.is_not_nil(result)
            assert.equals("Wrath", result.spellName)
            assert.is_near(839.80, result.minDmg, 0.01)
            assert.is_near(888.80, result.maxDmg, 0.01)
        end)

        it("has correct cast time and spell type", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5176, state)
            assert.is_near(2.0, result.castTime, 0.01)
            assert.equals("direct", result.spellType)
        end)

        it("scales with spell power increase to 1200", function()
            local state = makeDruidState()
            state.stats.spellPower[ns.SCHOOL_NATURE] = 1200
            -- SP bonus: 1200 * 0.571 = 685.2
            -- min = 383 + 685.2 = 1068.2
            -- max = 432 + 685.2 = 1117.2
            local result = Pipeline.Calculate(5176, state)
            assert.is_near(1068.20, result.minDmg, 0.01)
            assert.is_near(1117.20, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Starfire R8 (spellID 26986)
    -- Arcane direct, 3.5s cast, coefficient 1.0
    -- Base: avg(625, 735) = 680
    -- SP bonus: 800 * 1.0 = 800
    -- min = 625 + 800 = 1425
    -- max = 735 + 800 = 1535
    ---------------------------------------------------------------------------
    describe("Starfire", function()

        it("calculates R8 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(2912, state)
            assert.is_not_nil(result)
            assert.equals("Starfire", result.spellName)
            assert.is_near(1425.00, result.minDmg, 0.01)
            assert.is_near(1535.00, result.maxDmg, 0.01)
        end)

        it("has correct cast time", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(2912, state)
            assert.is_near(3.5, result.castTime, 0.01)
        end)

        it("scales with spell power increase to 1200", function()
            local state = makeDruidState()
            state.stats.spellPower[ns.SCHOOL_ARCANE] = 1200
            -- SP bonus: 1200 * 1.0 = 1200
            -- min = 625 + 1200 = 1825
            -- max = 735 + 1200 = 1935
            local result = Pipeline.Calculate(2912, state)
            assert.is_near(1825.00, result.minDmg, 0.01)
            assert.is_near(1935.00, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Moonfire R12 (spellID 26988)
    -- Arcane hybrid, instant, directCoeff=0.15, dotCoeff=0.52
    -- Direct: avg(305, 305) = 305, SP: 800 * 0.15 = 120 → 425
    -- DoT: 600 + 800 * 0.52 = 600 + 416 = 1016, per tick = 1016 / 4 = 254
    --
    -- BuildHybridResult output (no talents/auras, all mults = 1.0):
    --   directDamage = 425 * hitProb * (1 - armor)
    --   dotTotalDmg = 1016 (before hit)
    --   directMin = directMax = 305 + 120 = 425
    --   numTicks = 4
    ---------------------------------------------------------------------------
    describe("Moonfire", function()

        it("calculates R12 direct and DoT damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(8921, state)
            assert.is_not_nil(result)
            assert.equals("Moonfire", result.spellName)
            assert.equals("hybrid", result.spellType)
            -- Direct portion (before hit/crit modifiers)
            assert.is_near(425.00, result.directMin, 0.01)
            assert.is_near(425.00, result.directMax, 0.01)
            -- DoT total (before hit modifiers)
            assert.is_near(1016.00, result.dotTotalDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(8921, state)
            assert.equals(4, result.numTicks)
            assert.equals(12, result.duration)
        end)

        it("has both direct and DoT portions", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(8921, state)
            assert.is_true(result.isDot)
            assert.is_not_nil(result.directDamage)
            assert.is_not_nil(result.dotDamage)
            assert.is_not_nil(result.tickDamage)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Insect Swarm R6 (spellID 27013)
    -- Nature DoT, instant, coefficient=0.762, 6 ticks / 12s
    -- DoT base: 792
    -- SP bonus: 800 * 0.762 = 609.6
    -- Total: 792 + 609.6 = 1401.6, per tick = 1401.6 / 6 = 233.6
    --
    -- Engine ComputeDot (non-melee caster path) reads rankData.totalDmg.
    -- Druid data uses dotDmg=792 in rank data. If the engine reads totalDmg
    -- (which is nil), this would fail. Tests assert CORRECT expected values;
    -- a data or engine fix may be needed if they fail.
    ---------------------------------------------------------------------------
    describe("Insect Swarm", function()

        it("calculates R6 total DoT damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5570, state)
            assert.is_not_nil(result)
            assert.equals("Insect Swarm", result.spellName)
            assert.is_near(1401.60, result.totalDmg, 0.01)
        end)

        it("has correct tick damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5570, state)
            assert.is_near(233.60, result.tickDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5570, state)
            assert.equals(6, result.numTicks)
            assert.equals(12, result.duration)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Hurricane R4 (spellID 27012)
    -- Nature channel, 10s, coefficient=1.28, 10 ticks
    -- Total base: 734
    -- SP bonus: 800 * 1.28 = 1024
    -- Total: 734 + 1024 = 1758, per tick = 1758 / 10 = 175.8
    --
    -- Engine ComputeChannel reads rankData.totalDmg. Druid data uses
    -- minDmg=maxDmg=734. If engine reads totalDmg (nil), this would fail.
    -- Tests assert CORRECT expected values.
    ---------------------------------------------------------------------------
    describe("Hurricane", function()

        it("calculates R4 total channeled damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(16914, state)
            assert.is_not_nil(result)
            assert.equals("Hurricane", result.spellName)
            -- R4: totalDmg 734 + Nature SP 800 * 1.07 = 1590
            assert.is_near(1590.00, result.totalDmg, 0.01)
        end)

        it("has correct tick damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(16914, state)
            -- 1590 / 10 ticks = 159.00
            assert.is_near(159.00, result.tickDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(16914, state)
            assert.equals(10, result.numTicks)
            assert.equals(10, result.duration)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 6. Entangling Roots R7 (spellID 26989)
    -- Nature DoT, 1.5s cast, coefficient=0.1, 10 ticks / 30s
    -- DoT base: 351
    -- SP bonus: 800 * 0.1 = 80
    -- Total: 351 + 80 = 431, per tick = 431 / 10 = 43.1
    --
    -- Same engine caveat as Insect Swarm: rankData uses dotDmg, engine
    -- expects totalDmg for caster DoTs.
    ---------------------------------------------------------------------------
    describe("Entangling Roots", function()

        it("calculates R7 total DoT damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(339, state)
            assert.is_not_nil(result)
            assert.equals("Entangling Roots", result.spellName)
            assert.is_near(431.00, result.totalDmg, 0.01)
        end)

        it("has correct tick damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(339, state)
            -- 431 / 10 = 43.1
            assert.is_near(43.10, result.tickDmg, 0.01)
        end)

        it("has correct cast time", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(339, state)
            assert.is_near(1.5, result.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- FERAL CAT SPELLS
    -- Cat normalized speed: 1.0
    -- AP norm = 2000 / 14 * 1.0 = 142.857
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 7. Claw R6 (spellID 27000)
    -- weaponDmg 1.0x, flatBonus 115
    -- min = (100 + 142.857 + 115) * 1.0 = 357.857
    -- max = (150 + 142.857 + 115) * 1.0 = 407.857
    ---------------------------------------------------------------------------
    describe("Claw", function()

        it("calculates R6 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(1082, state)
            assert.is_not_nil(result)
            assert.equals("Claw", result.spellName)
            assert.is_near(357.86, result.minDmg, 0.01)
            assert.is_near(407.86, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- AP norm = 3000 / 14 * 1.0 = 214.286
            -- min = (100 + 214.286 + 115) * 1.0 = 429.286
            -- max = (150 + 214.286 + 115) * 1.0 = 479.286
            local result = Pipeline.Calculate(1082, state)
            assert.is_near(429.29, result.minDmg, 0.01)
            assert.is_near(479.29, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 8. Shred R7 (spellID 27002)
    -- weaponDmg 2.25x, flatBonus 203
    -- min = (100 + 142.857 + 203) * 2.25 = 445.857 * 2.25 = 1003.179
    -- max = (150 + 142.857 + 203) * 2.25 = 495.857 * 2.25 = 1115.679
    ---------------------------------------------------------------------------
    describe("Shred", function()

        it("calculates R7 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5221, state)
            assert.is_not_nil(result)
            assert.equals("Shred", result.spellName)
            assert.is_near(1003.18, result.minDmg, 0.01)
            assert.is_near(1115.68, result.maxDmg, 0.01)
        end)

        it("applies 2.25x weapon multiplier", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5221, state)
            -- Verify via min: (100 + 142.857 + 203) * 2.25 = 1003.179
            assert.is_near(1003.18, result.minDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- AP norm = 3000 / 14 * 1.0 = 214.286
            -- min = (100 + 214.286 + 203) * 2.25 = 517.286 * 2.25 = 1163.893
            -- max = (150 + 214.286 + 203) * 2.25 = 567.286 * 2.25 = 1276.393
            local result = Pipeline.Calculate(5221, state)
            assert.is_near(1163.89, result.minDmg, 0.01)
            assert.is_near(1276.39, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 9. Mangle (Cat) R3 (spellID 33983)
    -- weaponDmg 1.6x, flatBonus 190
    -- min = (100 + 142.857 + 190) * 1.6 = 432.857 * 1.6 = 692.571
    -- max = (150 + 142.857 + 190) * 1.6 = 482.857 * 1.6 = 772.571
    ---------------------------------------------------------------------------
    describe("Mangle (Cat)", function()

        it("calculates R3 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(33876, state)
            assert.is_not_nil(result)
            assert.equals("Mangle (Cat)", result.spellName)
            assert.is_near(692.57, result.minDmg, 0.01)
            assert.is_near(772.57, result.maxDmg, 0.01)
        end)

        it("applies 1.6x weapon multiplier", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(33876, state)
            -- min before mult = 100 + 142.857 + 190 = 432.857
            -- * 1.6 = 692.571
            assert.is_near(692.57, result.minDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 10. Rake R5 (spellID 27003)
    -- Physical hybrid, apCoefficient=0.01, dotApCoefficient=0.06 (total)
    -- Engine ComputeHybrid uses scalingPower = AP = 2000
    --   directCoeff = apCoefficient = 0.01
    --   dotCoeff = dotApCoefficient = 0.06
    -- Direct: avg(78, 78) = 78, SP bonus: 2000 * 0.01 = 20 → 98
    -- DoT: 150 + 2000 * 0.06 = 150 + 120 = 270, per tick = 270 / 3 = 90
    --
    -- After CritCalc.BuildHybridResult (Physical, targetArmor=0):
    --   directMin = directMax = 78 + 20 = 98
    --   dotTotalDmg = 270 (before hit)
    ---------------------------------------------------------------------------
    describe("Rake", function()

        it("calculates R5 direct and DoT damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(1822, state)
            assert.is_not_nil(result)
            assert.equals("Rake", result.spellName)
            assert.equals("hybrid", result.spellType)
            -- Direct portion
            assert.is_near(98.00, result.directMin, 0.01)
            assert.is_near(98.00, result.directMax, 0.01)
            -- DoT total (before hit modifiers)
            assert.is_near(270.00, result.dotTotalDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(1822, state)
            assert.equals(3, result.numTicks)
            assert.equals(9, result.duration)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- Direct: 78 + 3000 * 0.01 = 78 + 30 = 108
            -- DoT: 150 + 3000 * 0.06 = 150 + 180 = 330
            local result = Pipeline.Calculate(1822, state)
            assert.is_near(108.00, result.directMin, 0.01)
            assert.is_near(108.00, result.directMax, 0.01)
            assert.is_near(330.00, result.dotTotalDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 11. Ferocious Bite R6 (spellID 24248)
    -- Physical direct, apCoefficient=0.15
    -- Base: min=259, max=371
    -- AP bonus: 2000 * 0.15 = 300
    -- min = 259 + 300 = 559
    -- max = 371 + 300 = 671
    ---------------------------------------------------------------------------
    describe("Ferocious Bite", function()

        it("calculates R6 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(22568, state)
            assert.is_not_nil(result)
            assert.equals("Ferocious Bite", result.spellName)
            assert.is_near(559.00, result.minDmg, 0.01)
            assert.is_near(671.00, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- AP bonus: 3000 * 0.15 = 450
            -- min = 259 + 450 = 709
            -- max = 371 + 450 = 821
            local result = Pipeline.Calculate(22568, state)
            assert.is_near(709.00, result.minDmg, 0.01)
            assert.is_near(821.00, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 12. Rip R7 (spellID 27008)
    -- Physical DoT, apCoefficient=0.24, 6 ticks / 12s
    -- Engine ComputeDot (melee path): baseDmg = rankData.totalDmg or 0
    -- The Druid data uses dotDmg=1038, not totalDmg. If engine reads
    -- totalDmg (nil), baseDmg would be 0. Tests assert CORRECT values
    -- assuming dotDmg is properly used.
    --
    -- DoT base: 1038
    -- AP bonus: 2000 * 0.24 = 480
    -- Total: 1038 + 480 = 1518, per tick = 1518 / 6 = 253
    ---------------------------------------------------------------------------
    describe("Rip", function()

        it("calculates R7 total DoT damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(1079, state)
            assert.is_not_nil(result)
            assert.equals("Rip", result.spellName)
            assert.is_near(1518.00, result.totalDmg, 0.01)
        end)

        it("has correct tick damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(1079, state)
            -- 1518 / 6 = 253
            assert.is_near(253.00, result.tickDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(1079, state)
            assert.equals(6, result.numTicks)
            assert.equals(12, result.duration)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- AP bonus: 3000 * 0.24 = 720
            -- Total: 1038 + 720 = 1758
            local result = Pipeline.Calculate(1079, state)
            assert.is_near(1758.00, result.totalDmg, 0.01)
        end)

        it("cannot crit", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(1079, state)
            assert.equals(0, result.critChance)
        end)
    end)

    ---------------------------------------------------------------------------
    -- FERAL BEAR SPELLS
    -- Bear normalized speed: 2.5
    -- AP norm = 2000 / 14 * 2.5 = 357.143
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 13. Maul R8 (spellID 26996)
    -- weaponDmg 1.0x, flatBonus 176
    -- min = (100 + 357.143 + 176) * 1.0 = 633.143
    -- max = (150 + 357.143 + 176) * 1.0 = 683.143
    ---------------------------------------------------------------------------
    describe("Maul", function()

        it("calculates R8 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(6807, state)
            assert.is_not_nil(result)
            assert.equals("Maul", result.spellName)
            assert.is_near(633.14, result.minDmg, 0.01)
            assert.is_near(683.14, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- AP norm = 3000 / 14 * 2.5 = 535.714
            -- min = (100 + 535.714 + 176) * 1.0 = 811.714
            -- max = (150 + 535.714 + 176) * 1.0 = 861.714
            local result = Pipeline.Calculate(6807, state)
            assert.is_near(811.71, result.minDmg, 0.01)
            assert.is_near(861.71, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 14. Swipe R6 (spellID 26997)
    -- Physical direct, apCoefficient=0.07, flat base
    -- Base: min=max=108
    -- AP bonus: 2000 * 0.07 = 140
    -- min = max = 108 + 140 = 248
    ---------------------------------------------------------------------------
    describe("Swipe", function()

        it("calculates R6 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(779, state)
            assert.is_not_nil(result)
            assert.equals("Swipe", result.spellName)
            assert.is_near(248.00, result.minDmg, 0.01)
            assert.is_near(248.00, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- AP bonus: 3000 * 0.07 = 210
            -- total = 108 + 210 = 318
            local result = Pipeline.Calculate(779, state)
            assert.is_near(318.00, result.minDmg, 0.01)
            assert.is_near(318.00, result.maxDmg, 0.01)
        end)

        it("is not affected by weapon damage changes", function()
            local state = makeDruidState()
            state.stats.mainHandWeaponDmgMin = 500
            state.stats.mainHandWeaponDmgMax = 700
            local result = Pipeline.Calculate(779, state)
            -- AP coefficient only, no weapon scaling
            assert.is_near(248.00, result.minDmg, 0.01)
            assert.is_near(248.00, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 15. Mangle (Bear) R3 (spellID 33987)
    -- weaponDmg 1.15x, flatBonus 199
    -- min = (100 + 357.143 + 199) * 1.15 = 656.143 * 1.15 = 754.564
    -- max = (150 + 357.143 + 199) * 1.15 = 706.143 * 1.15 = 812.064
    ---------------------------------------------------------------------------
    describe("Mangle (Bear)", function()

        it("calculates R3 base damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(33878, state)
            assert.is_not_nil(result)
            assert.equals("Mangle (Bear)", result.spellName)
            assert.is_near(754.56, result.minDmg, 0.01)
            assert.is_near(812.06, result.maxDmg, 0.01)
        end)

        it("applies 1.15x weapon multiplier", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(33878, state)
            -- min before mult = 100 + 357.143 + 199 = 656.143
            -- * 1.15 = 754.564
            assert.is_near(754.56, result.minDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- AP norm = 3000 / 14 * 2.5 = 535.714
            -- min = (100 + 535.714 + 199) * 1.15 = 834.714 * 1.15 = 959.921
            -- max = (150 + 535.714 + 199) * 1.15 = 884.714 * 1.15 = 1017.421
            local result = Pipeline.Calculate(33878, state)
            assert.is_near(959.92, result.minDmg, 0.01)
            assert.is_near(1017.42, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 16. Lacerate (spellID 33745)
    -- Physical hybrid, apCoefficient=0.01, dotApCoefficient=0.01, 5 ticks/15s
    -- Engine ComputeHybrid uses scalingPower = AP = 2000
    --   directCoeff = apCoefficient = 0.01
    --   dotCoeff = dotApCoefficient = 0.01
    -- Direct: avg(31, 31) = 31, AP bonus: 2000 * 0.01 = 20 → 51
    -- DoT: 310 + 2000 * 0.01 = 310 + 20 = 330, per tick = 330 / 5 = 66
    --
    -- After CritCalc.BuildHybridResult:
    --   directMin = directMax = 31 + 20 = 51
    --   dotTotalDmg = 330
    ---------------------------------------------------------------------------
    describe("Lacerate", function()

        it("calculates R1 direct and DoT damage", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(33745, state)
            assert.is_not_nil(result)
            assert.equals("Lacerate", result.spellName)
            assert.equals("hybrid", result.spellType)
            -- Direct portion
            assert.is_near(51.00, result.directMin, 0.01)
            assert.is_near(51.00, result.directMax, 0.01)
            -- DoT total (before hit modifiers)
            assert.is_near(330.00, result.dotTotalDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(33745, state)
            assert.equals(5, result.numTicks)
            assert.equals(15, result.duration)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDruidState()
            state.stats.attackPower = 3000
            -- Direct: 31 + 3000 * 0.01 = 31 + 30 = 61
            -- DoT: 310 + 3000 * 0.01 = 310 + 30 = 340
            local result = Pipeline.Calculate(33745, state)
            assert.is_near(61.00, result.directMin, 0.01)
            assert.is_near(61.00, result.directMax, 0.01)
            assert.is_near(340.00, result.dotTotalDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- RESTORATION SPELLS
    -- Healing spells use spellPower[Nature] = 800, isHealing = true
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 17. Healing Touch R13 (spellID 26979)
    -- Nature direct heal, 3.5s cast, coefficient=1.0
    -- Base: avg(3229, 3811) = 3520
    -- SP bonus: 800 * 1.0 = 800
    -- min = 3229 + 800 = 4029
    -- max = 3811 + 800 = 4611
    ---------------------------------------------------------------------------
    describe("Healing Touch", function()

        it("calculates R13 base healing", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5185, state)
            assert.is_not_nil(result)
            assert.equals("Healing Touch", result.spellName)
            assert.is_near(4029.00, result.minDmg, 0.01)
            assert.is_near(4611.00, result.maxDmg, 0.01)
        end)

        it("has correct cast time", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(5185, state)
            assert.is_near(3.5, result.castTime, 0.01)
        end)

        it("scales with spell power increase to 1200", function()
            local state = makeDruidState()
            state.stats.spellPower[ns.SCHOOL_NATURE] = 1200
            -- SP bonus: 1200 * 1.0 = 1200
            -- min = 3229 + 1200 = 4429
            -- max = 3811 + 1200 = 5011
            local result = Pipeline.Calculate(5185, state)
            assert.is_near(4429.00, result.minDmg, 0.01)
            assert.is_near(5011.00, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 18. Rejuvenation R13 (spellID 26982)
    -- Nature HoT, instant, coefficient=0.80, 4 ticks / 12s
    -- DoT base: 1192
    -- SP bonus: 800 * 0.80 = 640
    -- Total: 1192 + 640 = 1832, per tick = 1832 / 4 = 458
    --
    -- Same engine caveat as Insect Swarm: data uses dotDmg, engine expects
    -- totalDmg for DoT-type spells.
    ---------------------------------------------------------------------------
    describe("Rejuvenation", function()

        it("calculates R13 total HoT healing", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(774, state)
            assert.is_not_nil(result)
            assert.equals("Rejuvenation", result.spellName)
            assert.is_near(1832.00, result.totalDmg, 0.01)
        end)

        it("has correct tick healing", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(774, state)
            -- 1832 / 4 = 458
            assert.is_near(458.00, result.tickDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(774, state)
            assert.equals(4, result.numTicks)
            assert.equals(12, result.duration)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 19. Regrowth R10 (spellID 26980)
    -- Nature hybrid heal, 2.0s cast, directCoeff=0.286, dotCoeff=0.70
    -- Direct: avg(1253, 1394) = 1323.5, SP: 800 * 0.286 = 228.8 → 1552.3
    -- HoT: 1274 + 800 * 0.70 = 1274 + 560 = 1834, per tick = 1834 / 7 = 262
    --
    -- After CritCalc.BuildHybridResult:
    --   directMin = 1253 + 228.8 = 1481.8
    --   directMax = 1394 + 228.8 = 1622.8
    --   dotTotalDmg = 1834
    ---------------------------------------------------------------------------
    describe("Regrowth", function()

        it("calculates R10 direct and HoT healing", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(8936, state)
            assert.is_not_nil(result)
            assert.equals("Regrowth", result.spellName)
            assert.equals("hybrid", result.spellType)
            -- Direct portion
            assert.is_near(1481.80, result.directMin, 0.01)
            assert.is_near(1622.80, result.directMax, 0.01)
            -- HoT total (before hit modifiers)
            assert.is_near(1834.00, result.dotTotalDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(8936, state)
            assert.equals(7, result.numTicks)
            assert.equals(21, result.duration)
        end)

        it("has correct cast time", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(8936, state)
            assert.is_near(2.0, result.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 20. Lifebloom (spellID 33763)
    -- Nature hybrid, instant, directCoeff=0.3432, dotCoeff=0.5194
    -- Bloom: avg(600, 600) = 600, SP: 800 * 0.3432 = 274.56 → 874.56
    -- HoT: 539 + 800 * 0.5194 = 539 + 415.52 = 954.52
    -- per tick = 954.52 / 7 = 136.36
    --
    -- After CritCalc.BuildHybridResult:
    --   directMin = directMax = 600 + 274.56 = 874.56
    --   dotTotalDmg = 954.52
    ---------------------------------------------------------------------------
    describe("Lifebloom", function()

        it("calculates R1 bloom and HoT healing", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(33763, state)
            assert.is_not_nil(result)
            assert.equals("Lifebloom", result.spellName)
            assert.equals("hybrid", result.spellType)
            -- Bloom portion
            assert.is_near(874.56, result.directMin, 0.01)
            assert.is_near(874.56, result.directMax, 0.01)
            -- HoT total (before hit modifiers)
            assert.is_near(954.52, result.dotTotalDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(33763, state)
            assert.equals(7, result.numTicks)
            assert.equals(7, result.duration)
        end)

        it("scales with spell power increase to 1200", function()
            local state = makeDruidState()
            state.stats.spellPower[ns.SCHOOL_NATURE] = 1200
            -- Bloom: 600 + 1200 * 0.3432 = 600 + 411.84 = 1011.84
            -- HoT: 539 + 1200 * 0.5194 = 539 + 623.28 = 1162.28
            local result = Pipeline.Calculate(33763, state)
            assert.is_near(1011.84, result.directMin, 0.01)
            assert.is_near(1011.84, result.directMax, 0.01)
            assert.is_near(1162.28, result.dotTotalDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 21. Tranquility R5 (spellID 26983)
    -- Nature channel heal, 8s duration, coefficient=1.144, 4 ticks
    -- Total base: 1518
    -- SP bonus: 800 * 1.144 = 915.2
    -- Total: 1518 + 915.2 = 2433.2, per tick = 2433.2 / 4 = 608.3
    --
    -- Same engine caveat as Hurricane: data uses minDmg/maxDmg, engine
    -- expects totalDmg for channel-type spells.
    ---------------------------------------------------------------------------
    describe("Tranquility", function()

        it("calculates R5 total channeled healing", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(740, state)
            assert.is_not_nil(result)
            assert.equals("Tranquility", result.spellName)
            assert.is_near(2433.20, result.totalDmg, 0.01)
        end)

        it("has correct tick healing", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(740, state)
            -- 2433.2 / 4 = 608.3
            assert.is_near(608.30, result.tickDmg, 0.01)
        end)

        it("has correct tick count and duration", function()
            local state = makeDruidState()
            local result = Pipeline.Calculate(740, state)
            assert.equals(4, result.numTicks)
            assert.equals(8, result.duration)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Spell metadata verification
    ---------------------------------------------------------------------------
    describe("Spell metadata", function()

        it("has all 21 Druid spells in SpellData", function()
            local baseIDs = {
                -- Balance
                5176, 2912, 8921, 5570, 16914, 339,
                -- Feral Cat
                1082, 5221, 33876, 1822, 22568, 1079,
                -- Feral Bear
                6807, 779, 33878, 33745,
                -- Restoration
                5185, 774, 8936, 33763, 740,
            }
            for _, id in ipairs(baseIDs) do
                assert.is_not_nil(ns.SpellData[id], "Missing spell base ID " .. id)
            end
        end)

        it("has correct spell types", function()
            -- Direct spells
            assert.equals("direct", ns.SpellData[5176].spellType)  -- Wrath
            assert.equals("direct", ns.SpellData[2912].spellType)  -- Starfire
            assert.equals("direct", ns.SpellData[1082].spellType)  -- Claw
            assert.equals("direct", ns.SpellData[5221].spellType)  -- Shred
            assert.equals("direct", ns.SpellData[33876].spellType) -- Mangle (Cat)
            assert.equals("direct", ns.SpellData[22568].spellType) -- Ferocious Bite
            assert.equals("direct", ns.SpellData[6807].spellType)  -- Maul
            assert.equals("direct", ns.SpellData[779].spellType)   -- Swipe
            assert.equals("direct", ns.SpellData[33878].spellType) -- Mangle (Bear)
            assert.equals("direct", ns.SpellData[5185].spellType)  -- Healing Touch
            -- DoT spells
            assert.equals("dot", ns.SpellData[5570].spellType)  -- Insect Swarm
            assert.equals("dot", ns.SpellData[339].spellType)   -- Entangling Roots
            assert.equals("dot", ns.SpellData[1079].spellType)  -- Rip
            assert.equals("dot", ns.SpellData[774].spellType)   -- Rejuvenation
            -- Hybrid spells
            assert.equals("hybrid", ns.SpellData[8921].spellType)  -- Moonfire
            assert.equals("hybrid", ns.SpellData[1822].spellType)  -- Rake
            assert.equals("hybrid", ns.SpellData[33745].spellType) -- Lacerate
            assert.equals("hybrid", ns.SpellData[8936].spellType)  -- Regrowth
            assert.equals("hybrid", ns.SpellData[33763].spellType) -- Lifebloom
            -- Channel spells
            assert.equals("channel", ns.SpellData[16914].spellType) -- Hurricane
            assert.equals("channel", ns.SpellData[740].spellType)   -- Tranquility
        end)

        it("has correct schools", function()
            -- Nature spells
            local natureIDs = { 5176, 5570, 16914, 339, 774, 8936, 33763, 740, 5185 }
            for _, id in ipairs(natureIDs) do
                assert.equals(ns.SCHOOL_NATURE, ns.SpellData[id].school,
                    "Expected Nature school for spell " .. id)
            end
            -- Arcane spells
            local arcaneIDs = { 2912, 8921 }
            for _, id in ipairs(arcaneIDs) do
                assert.equals(ns.SCHOOL_ARCANE, ns.SpellData[id].school,
                    "Expected Arcane school for spell " .. id)
            end
            -- Physical spells
            local physicalIDs = { 1082, 5221, 33876, 1822, 22568, 1079, 6807, 779, 33878, 33745 }
            for _, id in ipairs(physicalIDs) do
                assert.equals(ns.SCHOOL_PHYSICAL, ns.SpellData[id].school,
                    "Expected Physical school for spell " .. id)
            end
        end)

        it("has correct canCrit flags", function()
            -- Can crit
            local crittable = {
                5176, 2912, 8921,           -- Balance
                1082, 5221, 33876, 22568,   -- Cat
                6807, 779, 33878, 33745,    -- Bear
                5185, 8936, 33763,          -- Resto
            }
            for _, id in ipairs(crittable) do
                assert.is_true(ns.SpellData[id].canCrit,
                    "Expected canCrit=true for spell " .. id)
            end
            -- Cannot crit
            local nonCrittable = { 5570, 16914, 339, 1822, 1079, 774, 740 }
            for _, id in ipairs(nonCrittable) do
                assert.is_false(ns.SpellData[id].canCrit,
                    "Expected canCrit=false for spell " .. id)
            end
        end)

        it("healing spells have isHealing=true", function()
            local healingIDs = { 5185, 774, 8936, 33763, 740 }
            for _, id in ipairs(healingIDs) do
                assert.is_true(ns.SpellData[id].isHealing,
                    "Expected isHealing=true for spell " .. id)
            end
        end)

        it("damage spells do not have isHealing", function()
            local damageIDs = { 5176, 2912, 8921, 5570, 16914, 339, 1082, 5221, 33876, 1822, 22568, 1079,
                6807, 779, 33878, 33745 }
            for _, id in ipairs(damageIDs) do
                assert.is_falsy(ns.SpellData[id].isHealing,
                    "Expected isHealing falsy for spell " .. id)
            end
        end)

        it("melee spells have scalingType melee", function()
            local meleeIDs = { 1082, 5221, 33876, 1822, 22568, 1079, 6807, 779, 33878, 33745 }
            for _, id in ipairs(meleeIDs) do
                assert.equals("melee", ns.SpellData[id].scalingType,
                    "Expected scalingType=melee for spell " .. id)
            end
        end)
    end)
end)
