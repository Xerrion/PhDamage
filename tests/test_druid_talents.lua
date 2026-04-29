-------------------------------------------------------------------------------
-- test_druid_talents
-- Tests for Druid talent modifiers
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeDruidState = bootstrap.makeDruidState
local Pipeline = ns.Engine.Pipeline

-------------------------------------------------------------------------------
-- Default Druid state reference (from bootstrap):
--   attackPower = 2000, weapon 100-150, FIST (norm 2.5), speed 2.5
--   meleeCrit = 0.25, meleeHit = 0, targetArmor = 0
--   spellPower: Nature(8)=800, Arcane(64)=800
--   spellCrit: Nature=0.10, Arcane=0.10
--   spellHit = 0.03, intellect = 350
--   attackingFromBehind = true, targetLevel = 73
--
-- Wrath R10 (5176):     castTime=2.0, coeff=0.571, min=383, max=432
--   SP bonus: 800 * 0.571 = 456.80
--   min = 383 + 456.80 = 839.80, max = 432 + 456.80 = 888.80
--
-- Starfire R8 (2912):   castTime=3.5, coeff=1.0, min=625, max=735
--   SP bonus: 800 * 1.0 = 800
--   min = 625 + 800 = 1425, max = 735 + 800 = 1535
--
-- Moonfire R12 (8921):  hybrid, directCoeff=0.15, dotCoeff=0.52
--   Direct: 305 + 800*0.15 = 305 + 120 = 425
--   DoT:    600 + 800*0.52 = 600 + 416 = 1016
--
-- Entangling Roots R7 (339): dot, coeff=0.1, dotDmg=351
--   totalDmg = 351 + 800*0.1 = 351 + 80 = 431
--
-- Claw R6 (1082): melee direct, weaponMult=1.0, normSpeed=1.0, flat=115
--   AP bonus: 2000/14*1.0 = 142.857
--   min = (100 + 142.857 + 115) * 1.0 = 357.857
--   max = (150 + 142.857 + 115) * 1.0 = 407.857
--
-- Shred R7 (5221): melee direct, weaponMult=2.25, normSpeed=1.0, flat=203
--   AP bonus: 2000/14*1.0 = 142.857
--   min = (100 + 142.857 + 203) * 2.25 = 445.857 * 2.25 = 1003.18
--   max = (150 + 142.857 + 203) * 2.25 = 495.857 * 2.25 = 1115.68
--
-- Healing Touch R13 (5185): direct heal, coeff=1.0, min=3229, max=3811
--   SP bonus: 800 * 1.0 = 800
--   min = 3229 + 800 = 4029, max = 3811 + 800 = 4611, avg = 4320
--
-- Rejuvenation R13 (774): HoT, coeff=0.80, dotDmg=1192
--   totalDmg = 1192 + 800*0.80 = 1192 + 640 = 1832
--
-- Regrowth R10 (8936): hybrid heal, directCoeff=0.286, dotCoeff=0.70
--   Direct: avg(1253,1394)=1323.5 + 800*0.286 = 1323.5 + 228.8 = 1552.3
--   DoT:    1274 + 800*0.70 = 1274 + 560 = 1834
--
-- Base spell hit probability: 1 - 0.16 + 0.03 = 0.87 (TBC 3% hit)
-- Base melee hit probability: 1 - 0.08 - 0.065 = 0.855
-- Base crit mult (spell): 1.5, (melee): 2.0
-------------------------------------------------------------------------------

describe("Druid Talents", function()

    ---------------------------------------------------------------------------
    -- Balance (Tab 1)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 1. Starlight Wrath (1:2) — -0.1s/rank cast time on Wrath/Starfire
    ---------------------------------------------------------------------------
    describe("Starlight Wrath", function()

        it("should reduce Wrath cast time by 0.5s at 5/5", function()
            local state = makeDruidState()
            state.talents["1:2"] = 5
            local r = Pipeline.Calculate(5176, state)
            -- castTime = 2.0 - 5*0.1 = 1.5
            assert.is_near(1.5, r.castTime, 0.01)
        end)

        it("should reduce Starfire cast time by 0.5s at 5/5", function()
            local state = makeDruidState()
            state.talents["1:2"] = 5
            local r = Pipeline.Calculate(2912, state)
            -- castTime = 3.5 - 5*0.1 = 3.0
            assert.is_near(3.0, r.castTime, 0.01)
        end)

        it("should not affect Moonfire cast time", function()
            local state = makeDruidState()
            state.talents["1:2"] = 5
            local r = Pipeline.Calculate(8921, state)
            -- Moonfire is instant (GCD-bound), should remain unchanged
            local rBase = Pipeline.Calculate(8921, makeDruidState())
            assert.is_near(rBase.castTime, r.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Improved Moonfire (1:3) — +5%/rank dmg AND +5%/rank crit to Moonfire
    ---------------------------------------------------------------------------
    describe("Improved Moonfire", function()

        it("should increase Moonfire direct and dot damage by 10% at 2/2", function()
            local state = makeDruidState()
            state.talents["1:3"] = 2
            local r = Pipeline.Calculate(8921, state)
            -- Base direct (avg): 305 + 120 = 425.0
            -- Base dot: 600 + 416 = 1016.0
            -- With 2/2: +10% additive → directMin/Max * 1.10, dotTotalDmg * 1.10
            -- Direct portion: 425 * 1.10 = 467.50 (directMin = directMax since min=max=305)
            -- DoT portion: 1016 * 1.10 = 1117.60
            assert.is_near(467.50, r.directMin, 0.1)
            assert.is_near(467.50, r.directMax, 0.1)
            assert.is_near(1117.60, r.dotTotalDmg, 0.1)
        end)

        it("should increase Moonfire crit chance by 10% at 2/2", function()
            local state = makeDruidState()
            state.talents["1:3"] = 2
            local r = Pipeline.Calculate(8921, state)
            -- baseCrit = 0.10 (Arcane), + 2*0.05 = 0.10
            -- critChance = 0.10 + 0.10 = 0.20
            assert.is_near(0.20, r.critChance, 0.001)
        end)

        it("should not affect Wrath", function()
            local state = makeDruidState()
            state.talents["1:3"] = 2
            local r = Pipeline.Calculate(5176, state)
            assert.is_near(839.80, r.minDmg, 0.1)
            assert.is_near(888.80, r.maxDmg, 0.1)
            assert.is_near(0.10, r.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Brambles (1:5) — +25%/rank Entangling Roots dmg (additive)
    ---------------------------------------------------------------------------
    describe("Brambles", function()

        it("should increase Entangling Roots damage by 75% at 3/3", function()
            local state = makeDruidState()
            state.talents["1:5"] = 3
            local r = Pipeline.Calculate(339, state)
            -- Base totalDmg = 431.0
            -- With 3/3: 431.0 * (1 + 0.75) = 431.0 * 1.75 = 754.25
            assert.is_near(754.25, r.totalDmg, 0.1)
        end)

        it("should increase Entangling Roots damage by 25% at 1/3", function()
            local state = makeDruidState()
            state.talents["1:5"] = 1
            local r = Pipeline.Calculate(339, state)
            -- With 1/3: 431.0 * 1.25 = 538.75
            assert.is_near(538.75, r.totalDmg, 0.1)
        end)

        it("should not affect Wrath", function()
            local state = makeDruidState()
            state.talents["1:5"] = 3
            local r = Pipeline.Calculate(5176, state)
            assert.is_near(839.80, r.minDmg, 0.1)
            assert.is_near(888.80, r.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Moonfury (1:11) — +2%/rank Starfire/Moonfire/Wrath dmg (additive)
    ---------------------------------------------------------------------------
    describe("Moonfury", function()

        it("should increase Wrath damage by 10% at 5/5", function()
            local state = makeDruidState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(5176, state)
            -- Wrath base avg = 864.30
            -- With 5/5: * (1 + 0.10) = 950.73
            assert.is_near(839.80 * 1.10, r.minDmg, 0.1)
            assert.is_near(888.80 * 1.10, r.maxDmg, 0.1)
        end)

        it("should increase Starfire damage by 10% at 5/5", function()
            local state = makeDruidState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(2912, state)
            -- Starfire base min=1425, max=1535
            -- With 5/5: * 1.10
            assert.is_near(1425 * 1.10, r.minDmg, 0.1)
            assert.is_near(1535 * 1.10, r.maxDmg, 0.1)
        end)

        it("should increase Moonfire damage by 10% at 5/5", function()
            local state = makeDruidState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(8921, state)
            -- Direct: 425 * 1.10 = 467.50
            -- DoT: 1016 * 1.10 = 1117.60
            assert.is_near(467.50, r.directMin, 0.1)
            assert.is_near(467.50, r.directMax, 0.1)
            assert.is_near(1117.60, r.dotTotalDmg, 0.1)
        end)

        it("should not affect Entangling Roots", function()
            local state = makeDruidState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(339, state)
            assert.is_near(431.0, r.totalDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Vengeance (1:12) — non-linear crit mult bonus table
    --    {0.10, 0.20, 0.30, 0.40, 0.50}
    ---------------------------------------------------------------------------
    describe("Vengeance", function()

        it("should increase crit multiplier by 0.50 at 5/5 on Starfire", function()
            local state = makeDruidState()
            state.talents["1:12"] = 5
            local r = Pipeline.Calculate(2912, state)
            -- Base spell crit mult = 1.5, + 0.50 = 2.0
            assert.is_near(2.0, r.critMultiplier, 0.001)
        end)

        it("should increase crit multiplier by 0.30 at 3/5 on Wrath", function()
            local state = makeDruidState()
            state.talents["1:12"] = 3
            local r = Pipeline.Calculate(5176, state)
            -- Base spell crit mult = 1.5, + 0.30 = 1.8
            assert.is_near(1.8, r.critMultiplier, 0.001)
        end)

        it("should increase crit multiplier by 0.10 at 1/5 on Starfire", function()
            local state = makeDruidState()
            state.talents["1:12"] = 1
            local r = Pipeline.Calculate(2912, state)
            -- Base = 1.5, + 0.10 = 1.6
            assert.is_near(1.6, r.critMultiplier, 0.001)
        end)

        it("should apply to Moonfire", function()
            local state = makeDruidState()
            state.talents["1:12"] = 5
            local r = Pipeline.Calculate(8921, state)
            assert.is_near(2.0, r.critMultiplier, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 6. Lunar Guidance (1:15) — {8%, 16%, 25%} of INT as spell power
    --    statField = "intellect"
    ---------------------------------------------------------------------------
    describe("Lunar Guidance", function()

        it("should add 25% of intellect as spell power at 3/3 on Wrath", function()
            local state = makeDruidState()
            state.talents["1:15"] = 3
            local r = Pipeline.Calculate(5176, state)
            -- INT = 350, bonus = 350 * 0.25 = 87.5
            -- Effective SP = 800 + 87.5 = 887.5
            -- SP bonus = 887.5 * 0.571 = 506.7625
            -- Wrath avg = 407.5 + 506.7625 = 914.2625
            -- Without talent: min = 839.80, avg = 864.30
            -- With talent: min = 383 + 506.7625 = 889.7625
            local rBase = Pipeline.Calculate(5176, makeDruidState())
            -- The SP bonus increase: 87.5 * 0.571 = 49.9625
            assert.is_true(r.minDmg > rBase.minDmg)
            assert.is_near(rBase.minDmg + 49.96, r.minDmg, 0.1)
            assert.is_near(rBase.maxDmg + 49.96, r.maxDmg, 0.1)
        end)

        it("should add 16% of intellect as spell power at 2/3 on Starfire", function()
            local state = makeDruidState()
            state.talents["1:15"] = 2
            local r = Pipeline.Calculate(2912, state)
            -- INT = 350, bonus = 350 * 0.16 = 56
            -- SP bonus increase = 56 * 1.0 = 56
            local rBase = Pipeline.Calculate(2912, makeDruidState())
            assert.is_near(rBase.minDmg + 56, r.minDmg, 0.1)
            assert.is_near(rBase.maxDmg + 56, r.maxDmg, 0.1)
        end)

        it("should add 8% of intellect as spell power at 1/3 on Wrath", function()
            local state = makeDruidState()
            state.talents["1:15"] = 1
            local r = Pipeline.Calculate(5176, state)
            -- INT = 350, bonus = 350 * 0.08 = 28
            -- SP bonus increase = 28 * 0.571 = 15.988
            local rBase = Pipeline.Calculate(5176, makeDruidState())
            assert.is_near(rBase.minDmg + 15.99, r.minDmg, 0.1)
            assert.is_near(rBase.maxDmg + 15.99, r.maxDmg, 0.1)
        end)

        it("should scale with higher intellect values", function()
            local state = makeDruidState()
            state.talents["1:15"] = 3
            state.stats.intellect = 500
            local r = Pipeline.Calculate(5176, state)
            -- INT = 500, bonus = 500 * 0.25 = 125
            -- SP bonus increase = 125 * 0.571 = 71.375
            local rBase = Pipeline.Calculate(5176, makeDruidState())
            assert.is_near(rBase.minDmg + 71.38, r.minDmg, 0.1)
            assert.is_near(rBase.maxDmg + 71.38, r.maxDmg, 0.1)
        end)

        it("should apply to Moonfire hybrid spell", function()
            local state = makeDruidState()
            state.talents["1:15"] = 3
            local r = Pipeline.Calculate(8921, state)
            -- INT = 350, bonus SP = 87.5
            -- Direct coeff = 0.15, dot coeff = 0.52
            -- Direct SP increase = 87.5 * 0.15 = 13.125
            -- DoT SP increase = 87.5 * 0.52 = 45.5
            local rBase = Pipeline.Calculate(8921, makeDruidState())
            assert.is_near(rBase.directMin + 13.13, r.directMin, 0.2)
            assert.is_near(rBase.dotTotalDmg + 45.5, r.dotTotalDmg, 0.2)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 7. Balance of Power (1:16) — +2% spell hit per rank
    ---------------------------------------------------------------------------
    describe("Balance of Power", function()

        it("should increase spell hit by 4% at 2/2", function()
            local state = makeDruidState()
            state.talents["1:16"] = 2
            local r = Pipeline.Calculate(5176, state)
            -- Base spellHit = 0.03, + 2*0.02 = 0.04
            -- hitChance = 0.03 + 0.04 = 0.07
            local rBase = Pipeline.Calculate(5176, makeDruidState())
            assert.is_near(rBase.hitChance + 0.04, r.hitChance, 0.001)
        end)

        it("should increase spell hit by 2% at 1/2", function()
            local state = makeDruidState()
            state.talents["1:16"] = 1
            local r = Pipeline.Calculate(5176, state)
            local rBase = Pipeline.Calculate(5176, makeDruidState())
            assert.is_near(rBase.hitChance + 0.02, r.hitChance, 0.001)
        end)

        it("should also affect melee hit (engine adds spellHitBonus to all hit types)", function()
            local state = makeDruidState()
            state.talents["1:16"] = 2
            local rClaw = Pipeline.Calculate(1082, state)
            local rBase = Pipeline.Calculate(1082, makeDruidState())
            -- Engine adds spellHitBonus to melee hit as well (CritCalc line 119)
            assert.is_near(rBase.hitProbability + 0.04, rClaw.hitProbability, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 8. Wrath of Cenarius (1:19) — +4%/rank coeff Starfire, +2%/rank coeff Wrath
    ---------------------------------------------------------------------------
    describe("Wrath of Cenarius", function()

        it("should increase Starfire coefficient by 0.20 at 5/5", function()
            local state = makeDruidState()
            state.talents["1:19"] = 5
            local r = Pipeline.Calculate(2912, state)
            -- Base coeff = 1.0, + 5*0.04 = 1.20
            -- SP bonus = 800 * 1.20 = 960
            -- min = 625 + 960 = 1585, max = 735 + 960 = 1695
            assert.is_near(1585, r.minDmg, 0.1)
            assert.is_near(1695, r.maxDmg, 0.1)
        end)

        it("should increase Wrath coefficient by 0.10 at 5/5", function()
            local state = makeDruidState()
            state.talents["1:19"] = 5
            local r = Pipeline.Calculate(5176, state)
            -- Base coeff = 0.571, + 5*0.02 = 0.671
            -- SP bonus = 800 * 0.671 = 536.8
            -- min = 383 + 536.8 = 919.8, max = 432 + 536.8 = 968.8
            assert.is_near(919.8, r.minDmg, 0.1)
            assert.is_near(968.8, r.maxDmg, 0.1)
        end)

        it("should not affect Moonfire coefficient", function()
            local state = makeDruidState()
            state.talents["1:19"] = 5
            local r = Pipeline.Calculate(8921, state)
            local rBase = Pipeline.Calculate(8921, makeDruidState())
            -- Moonfire direct/dot should remain the same
            assert.is_near(rBase.directMin, r.directMin, 0.1)
            assert.is_near(rBase.dotTotalDmg, r.dotTotalDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 9. Focused Starlight (1:21) — +2%/rank crit to Wrath/Starfire
    ---------------------------------------------------------------------------
    describe("Focused Starlight", function()

        it("should add 4% crit to Wrath at 2/2", function()
            local state = makeDruidState()
            state.talents["1:21"] = 2
            local r = Pipeline.Calculate(5176, state)
            -- baseCrit = 0.10 (Nature), + 2*0.02 = 0.04
            -- critChance = 0.10 + 0.04 = 0.14
            assert.is_near(0.14, r.critChance, 0.001)
        end)

        it("should add 4% crit to Starfire at 2/2", function()
            local state = makeDruidState()
            state.talents["1:21"] = 2
            local r = Pipeline.Calculate(2912, state)
            -- baseCrit = 0.10 (Arcane), + 0.04 = 0.14
            assert.is_near(0.14, r.critChance, 0.001)
        end)

        it("should not affect Moonfire crit", function()
            local state = makeDruidState()
            state.talents["1:21"] = 2
            local r = Pipeline.Calculate(8921, state)
            assert.is_near(0.10, r.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Feral (Tab 2)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 10. Sharpened Claws (2:5) — +2%/rank crit to feral abilities
    ---------------------------------------------------------------------------
    -- Sharpened Claws (2:5) removed from TalentMap; see plan 44, Bug A.

    ---------------------------------------------------------------------------
    -- 11. Savage Fury (2:11) — +10%/rank Claw/Rake/Mangle (Cat) dmg (additive)
    ---------------------------------------------------------------------------
    describe("Savage Fury", function()

        it("should increase Claw damage by 20% at 2/2", function()
            local state = makeDruidState()
            state.talents["2:11"] = 2
            local r = Pipeline.Calculate(1082, state)
            -- Claw base: min=357.857, max=407.857
            -- With 2/2: * (1 + 0.20) = 1.20
            assert.is_near(357.857 * 1.20, r.minDmg, 0.1)
            assert.is_near(407.857 * 1.20, r.maxDmg, 0.1)
        end)

        it("should increase Claw damage by 10% at 1/2", function()
            local state = makeDruidState()
            state.talents["2:11"] = 1
            local r = Pipeline.Calculate(1082, state)
            assert.is_near(357.857 * 1.10, r.minDmg, 0.1)
            assert.is_near(407.857 * 1.10, r.maxDmg, 0.1)
        end)

        it("should not affect Shred", function()
            local state = makeDruidState()
            state.talents["2:11"] = 2
            local r = Pipeline.Calculate(5221, state)
            -- Shred base values unchanged
            local rBase = Pipeline.Calculate(5221, makeDruidState())
            assert.is_near(rBase.minDmg, r.minDmg, 0.01)
            assert.is_near(rBase.maxDmg, r.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 12. Predatory Instincts (2:19) — non-linear crit mult bonus
    --     {0.03, 0.06, 0.10, 0.13, 0.16}
    ---------------------------------------------------------------------------
    describe("Predatory Instincts", function()

        it("should increase crit multiplier by 0.16 at 5/5 on Shred", function()
            local state = makeDruidState()
            state.talents["2:19"] = 5
            local r = Pipeline.Calculate(5221, state)
            -- Base melee crit mult = 2.0, + 0.16 = 2.16
            assert.is_near(2.16, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.10 at 3/5 on Claw", function()
            local state = makeDruidState()
            state.talents["2:19"] = 3
            local r = Pipeline.Calculate(1082, state)
            -- Base = 2.0, + 0.10 = 2.10
            assert.is_near(2.10, r.critMult, 0.001)
        end)

        it("should increase crit multiplier by 0.03 at 1/5 on Shred", function()
            local state = makeDruidState()
            state.talents["2:19"] = 1
            local r = Pipeline.Calculate(5221, state)
            -- Base = 2.0, + 0.03 = 2.03
            assert.is_near(2.03, r.critMult, 0.001)
        end)

        it("should not affect Maul (bear ability)", function()
            local state = makeDruidState()
            state.talents["2:19"] = 5
            local r = Pipeline.Calculate(6807, state)
            -- Maul is not in the Predatory Instincts filter list
            assert.is_near(2.0, r.critMult, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Restoration (Tab 3)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 13. Naturalist (3:4) — -0.1s/rank HT cast + +2%/rank physical dmg
    ---------------------------------------------------------------------------
    describe("Naturalist", function()

        it("should reduce Healing Touch cast time by 0.5s at 5/5", function()
            local state = makeDruidState()
            state.talents["3:4"] = 5
            local r = Pipeline.Calculate(5185, state)
            -- castTime = 3.5 - 5*0.1 = 3.0
            assert.is_near(3.0, r.castTime, 0.01)
        end)

        it("should increase physical damage by 10% at 5/5 on Claw", function()
            local state = makeDruidState()
            state.talents["3:4"] = 5
            local r = Pipeline.Calculate(1082, state)
            -- Claw base: min=357.857, max=407.857
            -- With 5/5: * (1 + 0.10) = 1.10
            assert.is_near(357.857 * 1.10, r.minDmg, 0.1)
            assert.is_near(407.857 * 1.10, r.maxDmg, 0.1)
        end)

        it("should not affect Wrath damage (Nature spell)", function()
            local state = makeDruidState()
            state.talents["3:4"] = 5
            local r = Pipeline.Calculate(5176, state)
            assert.is_near(839.80, r.minDmg, 0.1)
            assert.is_near(888.80, r.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 14. Improved Regrowth (3:5) — +10%/rank crit to Regrowth
    ---------------------------------------------------------------------------
    describe("Improved Regrowth", function()

        it("should add 50% crit to Regrowth at 5/5", function()
            local state = makeDruidState()
            state.talents["3:5"] = 5
            local r = Pipeline.Calculate(8936, state)
            -- baseCrit = 0.10 (Nature), + 5*0.10 = 0.50
            -- critChance = 0.10 + 0.50 = 0.60
            assert.is_near(0.60, r.critChance, 0.001)
        end)

        it("should add 30% crit to Regrowth at 3/5", function()
            local state = makeDruidState()
            state.talents["3:5"] = 3
            local r = Pipeline.Calculate(8936, state)
            -- critChance = 0.10 + 0.30 = 0.40
            assert.is_near(0.40, r.critChance, 0.001)
        end)

        it("should not affect Healing Touch crit", function()
            local state = makeDruidState()
            state.talents["3:5"] = 5
            local r = Pipeline.Calculate(5185, state)
            assert.is_near(0.10, r.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 15. Gift of Nature (3:8) — +2%/rank healing (additive) on specific heals
    ---------------------------------------------------------------------------
    describe("Gift of Nature", function()

        it("should increase Healing Touch by 10% at 5/5", function()
            local state = makeDruidState()
            state.talents["3:8"] = 5
            local r = Pipeline.Calculate(5185, state)
            -- HT base: min=4029, max=4611, avg=4320
            -- With 5/5: * (1 + 0.10) = 1.10
            assert.is_near(4029 * 1.10, r.minDmg, 1)
            assert.is_near(4611 * 1.10, r.maxDmg, 1)
        end)

        it("should increase Rejuvenation by 10% at 5/5", function()
            local state = makeDruidState()
            state.talents["3:8"] = 5
            local r = Pipeline.Calculate(774, state)
            -- Rejuv base totalDmg = 1832
            -- With 5/5: 1832 * 1.10 = 2015.2
            assert.is_near(1832 * 1.10, r.totalDmg, 1)
        end)

        it("should not affect Wrath", function()
            local state = makeDruidState()
            state.talents["3:8"] = 5
            local r = Pipeline.Calculate(5176, state)
            assert.is_near(839.80, r.minDmg, 0.1)
            assert.is_near(888.80, r.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 16. Improved Rejuvenation (3:10) — +5%/rank Rejuv healing (additive)
    ---------------------------------------------------------------------------
    describe("Improved Rejuvenation", function()

        it("should increase Rejuvenation by 15% at 3/3", function()
            local state = makeDruidState()
            state.talents["3:10"] = 3
            local r = Pipeline.Calculate(774, state)
            -- Rejuv base totalDmg = 1832
            -- With 3/3: 1832 * (1 + 0.15) = 2106.80
            assert.is_near(2106.80, r.totalDmg, 1)
        end)

        it("should increase Rejuvenation by 5% at 1/3", function()
            local state = makeDruidState()
            state.talents["3:10"] = 1
            local r = Pipeline.Calculate(774, state)
            -- With 1/3: 1832 * 1.05 = 1923.60
            assert.is_near(1923.60, r.totalDmg, 1)
        end)

        it("should not affect Healing Touch", function()
            local state = makeDruidState()
            state.talents["3:10"] = 3
            local r = Pipeline.Calculate(5185, state)
            assert.is_near(4029, r.minDmg, 1)
            assert.is_near(4611, r.maxDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 17. Empowered Touch (3:16) — +10%/rank HT coefficient
    ---------------------------------------------------------------------------
    describe("Empowered Touch", function()

        it("should increase HT coefficient by 0.20 at 2/2", function()
            local state = makeDruidState()
            state.talents["3:16"] = 2
            local r = Pipeline.Calculate(5185, state)
            -- Base coeff = 1.0, + 2*0.10 = 1.20
            -- SP bonus = 800 * 1.20 = 960
            -- min = 3229 + 960 = 4189, max = 3811 + 960 = 4771
            assert.is_near(4189, r.minDmg, 1)
            assert.is_near(4771, r.maxDmg, 1)
        end)

        it("should increase HT coefficient by 0.10 at 1/2", function()
            local state = makeDruidState()
            state.talents["3:16"] = 1
            local r = Pipeline.Calculate(5185, state)
            -- Coeff = 1.10, SP bonus = 800 * 1.10 = 880
            -- min = 3229 + 880 = 4109, max = 3811 + 880 = 4691
            assert.is_near(4109, r.minDmg, 1)
            assert.is_near(4691, r.maxDmg, 1)
        end)

        it("should not affect Rejuvenation coefficient", function()
            local state = makeDruidState()
            state.talents["3:16"] = 2
            local r = Pipeline.Calculate(774, state)
            -- Rejuv base totalDmg = 1832 (unchanged)
            assert.is_near(1832, r.totalDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 18. Empowered Rejuvenation (3:17) — +4%/rank HoT coefficient
    ---------------------------------------------------------------------------
    describe("Empowered Rejuvenation", function()

        it("should increase Rejuvenation coefficient by 0.20 at 5/5", function()
            local state = makeDruidState()
            state.talents["3:17"] = 5
            local r = Pipeline.Calculate(774, state)
            -- Base coeff = 0.80, + 5*0.04 = 1.00
            -- SP bonus = 800 * 1.00 = 800
            -- totalDmg = 1192 + 800 = 1992
            assert.is_near(1992, r.totalDmg, 1)
        end)

        it("should increase Rejuvenation coefficient by 0.08 at 2/5", function()
            local state = makeDruidState()
            state.talents["3:17"] = 2
            local r = Pipeline.Calculate(774, state)
            -- Coeff = 0.80 + 0.08 = 0.88
            -- SP bonus = 800 * 0.88 = 704
            -- totalDmg = 1192 + 704 = 1896
            assert.is_near(1896, r.totalDmg, 1)
        end)

        it("should not affect Healing Touch coefficient", function()
            local state = makeDruidState()
            state.talents["3:17"] = 5
            local r = Pipeline.Calculate(5185, state)
            -- HT base unchanged: min=4029, max=4611
            assert.is_near(4029, r.minDmg, 1)
            assert.is_near(4611, r.maxDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 19. Natural Perfection (3:18) — +1%/rank crit to all spells
    ---------------------------------------------------------------------------
    -- Natural Perfection (3:18) removed from TalentMap; see plan 44, Bug A.

    ---------------------------------------------------------------------------
    -- Talent Stacking Tests
    ---------------------------------------------------------------------------
    describe("Stacking", function()

        it("Moonfury + Improved Moonfire should stack on Moonfire", function()
            local state = makeDruidState()
            state.talents["1:11"] = 5  -- Moonfury +10% (additive → talentDamageBonus)
            state.talents["1:3"] = 2   -- Imp Moonfire +10% (multiplicative → damageMultiplier)
            local r = Pipeline.Calculate(8921, state)
            -- Moonfury is additive: talentDamageBonus = 0.10
            -- Imp Moonfire is multiplicative: damageMultiplier = 1.10
            -- Final: base * (1 + 0.10) * 1.10 = base * 1.21
            -- Direct: 425 * 1.21 = 514.25
            -- DoT: 1016 * 1.21 = 1229.36
            assert.is_near(514.25, r.directMin, 0.1)
            assert.is_near(1229.36, r.dotTotalDmg, 0.1)
        end)

        it("Focused Starlight should add crit on Wrath", function()
            -- Natural Perfection (3:18) removed from TalentMap (plan 44, Bug A); the
            -- +3% crit it provided is now counted in stats.spellCrit only.
            local state = makeDruidState()
            state.talents["1:21"] = 2  -- Focused Starlight +4%
            local r = Pipeline.Calculate(5176, state)
            -- critChance = 0.10 + 0.04 = 0.14
            assert.is_near(0.14, r.critChance, 0.001)
        end)

        it("Savage Fury + Naturalist should stack additively on Claw", function()
            local state = makeDruidState()
            state.talents["2:11"] = 2  -- Savage Fury +20%
            state.talents["3:4"] = 5   -- Naturalist +10% physical
            local r = Pipeline.Calculate(1082, state)
            -- Total additive: 1 + 0.20 + 0.10 = 1.30
            assert.is_near(357.857 * 1.30, r.minDmg, 0.1)
            assert.is_near(407.857 * 1.30, r.maxDmg, 0.1)
        end)

        it("Predatory Instincts should apply crit mult to Shred", function()
            -- Sharpened Claws (2:5) removed from TalentMap (plan 44, Bug A); the
            -- +6% crit it provided is now counted in stats.meleeCrit only.
            local state = makeDruidState()
            state.talents["2:19"] = 5  -- Predatory Instincts +0.16 crit mult
            local r = Pipeline.Calculate(5221, state)
            -- critChance unchanged from base meleeCrit (0.25)
            -- critMult = 2.0 + 0.16 = 2.16
            assert.is_near(0.25, r.critChance, 0.001)
            assert.is_near(2.16, r.critMult, 0.001)
        end)

        it("Gift of Nature + Improved Rejuvenation should stack additively on Rejuv", function()
            local state = makeDruidState()
            state.talents["3:8"] = 5   -- Gift of Nature +10%
            state.talents["3:10"] = 3  -- Imp Rejuv +15%
            local r = Pipeline.Calculate(774, state)
            -- Total additive: 1 + 0.10 + 0.15 = 1.25
            assert.is_near(1832 * 1.25, r.totalDmg, 1)
        end)

        it("Empowered Touch + Gift of Nature should both affect HT", function()
            local state = makeDruidState()
            state.talents["3:16"] = 2  -- Empowered Touch: coeff 1.0 → 1.20
            state.talents["3:8"] = 5   -- Gift of Nature: +10% additive dmg
            local r = Pipeline.Calculate(5185, state)
            -- Coeff bonus: SP = 800 * 1.20 = 960
            -- Base: min = 3229 + 960 = 4189, max = 3811 + 960 = 4771
            -- Dmg mult: * 1.10
            -- min = 4189 * 1.10 = 4607.9, max = 4771 * 1.10 = 5248.1
            assert.is_near(4607.9, r.minDmg, 1)
            assert.is_near(5248.1, r.maxDmg, 1)
        end)

        it("Wrath of Cenarius + Moonfury + Lunar Guidance on Wrath", function()
            local state = makeDruidState()
            state.talents["1:19"] = 5  -- WoC: Wrath coeff +0.10
            state.talents["1:11"] = 5  -- Moonfury: +10% dmg
            state.talents["1:15"] = 3  -- Lunar Guidance: +87.5 SP
            local r = Pipeline.Calculate(5176, state)
            -- Effective SP = 800 + 87.5 = 887.5
            -- Effective coeff = 0.571 + 0.10 = 0.671
            -- SP bonus = 887.5 * 0.671 = 595.5125
            -- Raw avg = 407.5 + 595.5125 = 1003.0125
            -- Moonfury dmg mult: * 1.10
            -- Final avg = 1003.0125 * 1.10 = 1103.31
            -- min = (383 + 595.5125) * 1.10 = 978.5125 * 1.10 = 1076.36
            -- max = (432 + 595.5125) * 1.10 = 1027.5125 * 1.10 = 1130.26
            assert.is_near(1076.36, r.minDmg, 0.5)
            assert.is_near(1130.26, r.maxDmg, 0.5)
        end)
    end)
end)
