-------------------------------------------------------------------------------
-- test_shaman_talents
-- Tests for Shaman talent calculations
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeShamanState = bootstrap.makeShamanState
local Pipeline = ns.Engine.Pipeline

-------------------------------------------------------------------------------
-- Default Shaman state reference (from bootstrap):
--   spellPower: Nature(8)=800, Fire(4)=800, Frost(16)=800
--   spellCrit: Nature=0.10, Fire=0.10, Frost=0.10
--   spellHit = 0.03, intellect = 350, attackPower = 2000
--   meleeCrit = 0.25, meleeHit = 0
--   attackingFromBehind = true, targetLevel = 73
--
-- Lightning Bolt R12 (403): castTime=2.5, coeff=0.794, min=571, max=652
--   SP bonus: 800 * 0.794 = 635.2
--   min = 571 + 635.2 = 1206.2, max = 652 + 635.2 = 1287.2
--
-- Chain Lightning R6 (421): castTime=2.0, coeff=0.651, min=734, max=838
--   SP bonus: 800 * 0.651 = 520.8
--   min = 734 + 520.8 = 1254.8, max = 838 + 520.8 = 1358.8
--
-- Earth Shock R8 (8042): castTime=1.5, coeff=0.386, min=658, max=692
--   SP bonus: 800 * 0.386 = 308.8
--   min = 658 + 308.8 = 966.8, max = 692 + 308.8 = 1000.8
--
-- Healing Wave R12 (331): castTime=3.0, coeff=0.857, min=2134, max=2436
--   SP bonus: 800 * 0.857 = 685.6
--   min = 2134 + 685.6 = 2819.6, max = 2436 + 685.6 = 3121.6
--
-- Lesser Healing Wave R7 (8004): castTime=1.5, coeff=0.429, min=1051, max=1198
--   SP bonus: 800 * 0.429 = 343.2
--   min = 1051 + 343.2 = 1394.2, max = 1198 + 343.2 = 1541.2
--
-- Chain Heal R5 (1064): castTime=2.5, coeff=0.714, min=833, max=950
--   SP bonus: 800 * 0.714 = 571.2
--   min = 833 + 571.2 = 1404.2, max = 950 + 571.2 = 1521.2
--
-- Base spell hit probability: 1 - 0.16 + 0.03 = 0.87 (TBC 3% hit)
-- Base crit mult (spell): 1.5
-------------------------------------------------------------------------------

describe("Shaman Talents", function()

    ---------------------------------------------------------------------------
    -- Elemental (Tab 1)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 1. Call of Thunder (1:2) — +1%/rank crit to LB, CL
    ---------------------------------------------------------------------------
    describe("Call of Thunder", function()

        it("should increase Lightning Bolt crit by 5% at 5/5", function()
            local baseState = makeShamanState()
            local baseResult = Pipeline.Calculate(403, baseState)

            local state = makeShamanState()
            state.talents["1:2"] = 5
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)

        it("should increase Chain Lightning crit by 5% at 5/5", function()
            local baseResult = Pipeline.Calculate(421, makeShamanState())

            local state = makeShamanState()
            state.talents["1:2"] = 5
            local result = Pipeline.Calculate(421, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)

        it("should not affect Earth Shock crit", function()
            local baseResult = Pipeline.Calculate(8042, makeShamanState())

            local state = makeShamanState()
            state.talents["1:2"] = 5
            local result = Pipeline.Calculate(8042, state)

            assert.is_near(baseResult.critChance, result.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Concussion (1:3) — +1%/rank damage to LB, CL, all Shocks (additive)
    ---------------------------------------------------------------------------
    describe("Concussion", function()

        it("should increase Lightning Bolt damage by 5% at 5/5", function()
            local state = makeShamanState()
            state.talents["1:3"] = 5
            local r = Pipeline.Calculate(403, state)
            -- Base: min=1206.2, max=1287.2
            -- With 5/5: * (1 + 0.05) = 1.05
            assert.is_near(1206.2 * 1.05, r.minDmg, 0.1)
            assert.is_near(1287.2 * 1.05, r.maxDmg, 0.1)
        end)

        it("should increase Earth Shock damage by 5% at 5/5", function()
            local state = makeShamanState()
            state.talents["1:3"] = 5
            local r = Pipeline.Calculate(8042, state)
            -- Base: min=966.8, max=1000.8
            assert.is_near(966.8 * 1.05, r.minDmg, 0.1)
            assert.is_near(1000.8 * 1.05, r.maxDmg, 0.1)
        end)

        it("should not affect Healing Wave damage", function()
            local state = makeShamanState()
            state.talents["1:3"] = 5
            local r = Pipeline.Calculate(331, state)
            -- Healing Wave should be unaffected (it's a heal, not in the filter)
            assert.is_near(2819.6, r.minDmg, 0.1)
            assert.is_near(3121.6, r.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Elemental Fury (1:5) — +50% crit multiplier (1 rank)
    ---------------------------------------------------------------------------
    describe("Elemental Fury", function()

        it("should increase crit multiplier from 1.5 to 2.0 on Lightning Bolt", function()
            local baseResult = Pipeline.Calculate(403, makeShamanState())

            local state = makeShamanState()
            state.talents["1:5"] = 1
            local result = Pipeline.Calculate(403, state)

            assert.is_near(1.5, baseResult.critMult, 0.001)
            assert.is_near(2.0, result.critMult, 0.001)
        end)

        it("should increase crit multiplier on Earth Shock", function()
            local state = makeShamanState()
            state.talents["1:5"] = 1
            local r = Pipeline.Calculate(8042, state)
            assert.is_near(2.0, r.critMult, 0.001)
        end)

        it("should increase crit multiplier on Healing Wave", function()
            local state = makeShamanState()
            state.talents["1:5"] = 1
            local r = Pipeline.Calculate(331, state)
            -- No filter → applies to all spells including heals
            assert.is_near(2.0, r.critMult, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Lightning Mastery (1:11) — -0.1s/rank cast time to LB, CL
    ---------------------------------------------------------------------------
    describe("Lightning Mastery", function()

        it("should reduce Lightning Bolt cast time by 0.5s at 5/5", function()
            local state = makeShamanState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(403, state)
            -- castTime = 2.5 - 5*0.1 = 2.0
            assert.is_near(2.0, r.castTime, 0.01)
        end)

        it("should reduce Chain Lightning cast time by 0.5s at 5/5", function()
            local state = makeShamanState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(421, state)
            -- castTime = 2.0 - 5*0.1 = 1.5
            assert.is_near(1.5, r.castTime, 0.01)
        end)

        it("should not affect Healing Wave cast time", function()
            local state = makeShamanState()
            state.talents["1:11"] = 5
            local r = Pipeline.Calculate(331, state)
            local rBase = Pipeline.Calculate(331, makeShamanState())
            assert.is_near(rBase.castTime, r.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Elemental Precision (1:18) — +2%/rank spell hit (all spells)
    ---------------------------------------------------------------------------
    describe("Elemental Precision", function()

        it("should increase spell hit by 6% at 3/3", function()
            local baseResult = Pipeline.Calculate(403, makeShamanState())

            local state = makeShamanState()
            state.talents["1:18"] = 3
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.hitChance + 0.06, result.hitChance, 0.001)
        end)

        it("should increase spell hit by 2% at 1/3", function()
            local baseResult = Pipeline.Calculate(403, makeShamanState())

            local state = makeShamanState()
            state.talents["1:18"] = 1
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.hitChance + 0.02, result.hitChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Enhancement (Tab 2)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 6. Weapon Mastery (2:15) — +2%/rank melee damage (additive)
    ---------------------------------------------------------------------------
    describe("Weapon Mastery", function()

        it("should have correct talent definition structure", function()
            local def = ns.TalentMap["SHAMAN:2:15"]
            assert.is_not_nil(def)
            assert.are.equal("Weapon Mastery", def.name)
            assert.are.equal(5, def.maxRank)
            assert.are.equal(1, #def.effects)
            assert.are.equal(ns.MOD.DAMAGE_MULTIPLIER, def.effects[1].type)
            assert.are.equal(0.02, def.effects[1].value)
            assert.is_true(def.effects[1].perRank)
            assert.are.equal("melee", def.effects[1].filter.scalingType)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 7. Mental Quickness (2:19) — 10%/rank AP as spell power
    ---------------------------------------------------------------------------
    describe("Mental Quickness", function()

        it("should add 30% of AP as spell power at 3/3 on Lightning Bolt", function()
            local state = makeShamanState()
            state.talents["2:19"] = 3
            local r = Pipeline.Calculate(403, state)
            -- AP = 2000, bonus SP = 2000 * 0.30 = 600
            -- Effective SP = 800 + 600 = 1400
            -- SP bonus = 1400 * 0.794 = 1111.6
            -- min = 571 + 1111.6 = 1682.6, max = 652 + 1111.6 = 1763.6
            assert.is_near(1682.6, r.minDmg, 0.5)
            assert.is_near(1763.6, r.maxDmg, 0.5)
        end)

        it("should add 10% of AP as spell power at 1/3 on Lightning Bolt", function()
            local state = makeShamanState()
            state.talents["2:19"] = 1
            local r = Pipeline.Calculate(403, state)
            -- AP = 2000, bonus SP = 2000 * 0.10 = 200
            -- Effective SP = 800 + 200 = 1000
            -- SP bonus = 1000 * 0.794 = 794
            -- min = 571 + 794 = 1365, max = 652 + 794 = 1446
            assert.is_near(1365, r.minDmg, 0.5)
            assert.is_near(1446, r.maxDmg, 0.5)
        end)

        it("should also affect Healing Wave", function()
            local state = makeShamanState()
            state.talents["2:19"] = 3
            local r = Pipeline.Calculate(331, state)
            -- AP = 2000, bonus SP = 600
            -- Effective SP = 800 + 600 = 1400
            -- SP bonus = 1400 * 0.857 = 1199.8
            -- min = 2134 + 1199.8 = 3333.8, max = 2436 + 1199.8 = 3635.8
            assert.is_near(3333.8, r.minDmg, 0.5)
            assert.is_near(3635.8, r.maxDmg, 0.5)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 8. Dual Wield Specialization (2:20) — +2%/rank hit for melee
    ---------------------------------------------------------------------------
    describe("Dual Wield Specialization", function()

        it("should have correct talent definition structure", function()
            local def = ns.TalentMap["SHAMAN:2:20"]
            assert.is_not_nil(def)
            assert.are.equal("Dual Wield Specialization", def.name)
            assert.are.equal(3, def.maxRank)
            assert.are.equal(1, #def.effects)
            assert.are.equal(ns.MOD.SPELL_HIT_BONUS, def.effects[1].type)
            assert.are.equal(0.02, def.effects[1].value)
            assert.is_true(def.effects[1].perRank)
            assert.are.equal("melee", def.effects[1].filter.scalingType)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Restoration (Tab 3)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 9. Improved Healing Wave (3:4) — -0.1s/rank HW cast time
    ---------------------------------------------------------------------------
    describe("Improved Healing Wave", function()

        it("should reduce Healing Wave cast time by 0.5s at 5/5", function()
            local state = makeShamanState()
            state.talents["3:4"] = 5
            local r = Pipeline.Calculate(331, state)
            -- castTime = 3.0 - 5*0.1 = 2.5
            assert.is_near(2.5, r.castTime, 0.01)
        end)

        it("should reduce Healing Wave cast time by 0.3s at 3/5", function()
            local state = makeShamanState()
            state.talents["3:4"] = 3
            local r = Pipeline.Calculate(331, state)
            -- castTime = 3.0 - 3*0.1 = 2.7
            assert.is_near(2.7, r.castTime, 0.01)
        end)

        it("should not affect Lesser Healing Wave cast time", function()
            local state = makeShamanState()
            state.talents["3:4"] = 5
            local r = Pipeline.Calculate(8004, state)
            local rBase = Pipeline.Calculate(8004, makeShamanState())
            assert.is_near(rBase.castTime, r.castTime, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 10. Purification (3:10) — +2%/rank healing (additive, isHeal filter)
    ---------------------------------------------------------------------------
    describe("Purification", function()

        it("should increase Healing Wave by 10% at 5/5", function()
            local state = makeShamanState()
            state.talents["3:10"] = 5
            local r = Pipeline.Calculate(331, state)
            -- HW base: min=2819.6, max=3121.6
            -- With 5/5: * (1 + 0.10) = 1.10
            assert.is_near(2819.6 * 1.10, r.minDmg, 1)
            assert.is_near(3121.6 * 1.10, r.maxDmg, 1)
        end)

        it("should increase Lesser Healing Wave by 10% at 5/5", function()
            local state = makeShamanState()
            state.talents["3:10"] = 5
            local r = Pipeline.Calculate(8004, state)
            -- LHW base: min=1394.2, max=1541.2
            assert.is_near(1394.2 * 1.10, r.minDmg, 1)
            assert.is_near(1541.2 * 1.10, r.maxDmg, 1)
        end)

        it("should not affect Lightning Bolt damage", function()
            local state = makeShamanState()
            state.talents["3:10"] = 5
            local r = Pipeline.Calculate(403, state)
            assert.is_near(1206.2, r.minDmg, 0.1)
            assert.is_near(1287.2, r.maxDmg, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 11. Tidal Mastery (3:12) — +1%/rank crit to LB, CL, HW, LHW, CH
    ---------------------------------------------------------------------------
    describe("Tidal Mastery", function()

        it("should increase Lightning Bolt crit by 5% at 5/5", function()
            local baseResult = Pipeline.Calculate(403, makeShamanState())

            local state = makeShamanState()
            state.talents["3:12"] = 5
            local result = Pipeline.Calculate(403, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)

        it("should increase Healing Wave crit by 5% at 5/5", function()
            local baseResult = Pipeline.Calculate(331, makeShamanState())

            local state = makeShamanState()
            state.talents["3:12"] = 5
            local result = Pipeline.Calculate(331, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)

        it("should increase Chain Heal crit by 5% at 5/5", function()
            local baseResult = Pipeline.Calculate(1064, makeShamanState())

            local state = makeShamanState()
            state.talents["3:12"] = 5
            local result = Pipeline.Calculate(1064, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)

        it("should not affect Earth Shock crit", function()
            local baseResult = Pipeline.Calculate(8042, makeShamanState())

            local state = makeShamanState()
            state.talents["3:12"] = 5
            local result = Pipeline.Calculate(8042, state)

            assert.is_near(baseResult.critChance, result.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 12. Nature's Blessing (3:17) — 10%/rank INT as spell power (heals only)
    ---------------------------------------------------------------------------
    describe("Nature's Blessing", function()

        it("should add 30% of intellect as spell power to Healing Wave at 3/3", function()
            local state = makeShamanState()
            state.talents["3:17"] = 3
            local r = Pipeline.Calculate(331, state)
            -- INT = 350, bonus SP = 350 * 0.30 = 105
            -- Effective SP = 800 + 105 = 905
            -- SP bonus = 905 * 0.857 = 775.585
            -- min = 2134 + 775.585 = 2909.585, max = 2436 + 775.585 = 3211.585
            assert.is_near(2909.585, r.minDmg, 0.5)
            assert.is_near(3211.585, r.maxDmg, 0.5)
        end)

        it("should add 10% of intellect as spell power to heals at 1/3", function()
            local state = makeShamanState()
            state.talents["3:17"] = 1
            local r = Pipeline.Calculate(331, state)
            -- INT = 350, bonus SP = 350 * 0.10 = 35
            -- SP bonus increase = 35 * 0.857 = 29.995
            local rBase = Pipeline.Calculate(331, makeShamanState())
            assert.is_near(rBase.minDmg + 29.995, r.minDmg, 0.5)
            assert.is_near(rBase.maxDmg + 29.995, r.maxDmg, 0.5)
        end)

        it("should not affect Lightning Bolt (not a heal)", function()
            local state = makeShamanState()
            state.talents["3:17"] = 3
            local r = Pipeline.Calculate(403, state)
            -- LB should be unaffected
            assert.is_near(1206.2, r.minDmg, 0.1)
            assert.is_near(1287.2, r.maxDmg, 0.1)
        end)

        it("should scale with higher intellect values", function()
            local state = makeShamanState()
            state.talents["3:17"] = 3
            state.stats.intellect = 500
            local r = Pipeline.Calculate(331, state)
            -- INT = 500, bonus SP = 500 * 0.30 = 150
            -- SP bonus = (800 + 150) * 0.857 = 950 * 0.857 = 813.95
            -- min = 2134 + 813.95 = 2947.95
            assert.is_near(2947.95, r.minDmg, 0.5)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Talent Metadata
    ---------------------------------------------------------------------------
    describe("Metadata", function()

        local expectedKeys = {
            "SHAMAN:1:2",   -- Call of Thunder
            "SHAMAN:1:3",   -- Concussion
            "SHAMAN:1:5",   -- Elemental Fury
            "SHAMAN:1:11",  -- Lightning Mastery
            "SHAMAN:1:18",  -- Elemental Precision
            "SHAMAN:2:15",  -- Weapon Mastery
            "SHAMAN:2:19",  -- Mental Quickness
            "SHAMAN:2:20",  -- Dual Wield Specialization
            "SHAMAN:3:4",   -- Improved Healing Wave
            "SHAMAN:3:10",  -- Purification
            "SHAMAN:3:12",  -- Tidal Mastery
            "SHAMAN:3:17",  -- Nature's Blessing
        }

        for _, key in ipairs(expectedKeys) do
            it("should have talent " .. key .. " registered in TalentMap", function()
                assert.is_not_nil(ns.TalentMap[key],
                    "Missing TalentMap entry: " .. key)
                assert.is_not_nil(ns.TalentMap[key].name,
                    "Missing name for " .. key)
                assert.is_not_nil(ns.TalentMap[key].maxRank,
                    "Missing maxRank for " .. key)
                assert.is_not_nil(ns.TalentMap[key].effects,
                    "Missing effects for " .. key)
                assert.is_true(#ns.TalentMap[key].effects > 0,
                    "Empty effects for " .. key)
            end)
        end
    end)

    ---------------------------------------------------------------------------
    -- Talent Stacking Tests
    ---------------------------------------------------------------------------
    describe("Stacking", function()

        it("Call of Thunder + Tidal Mastery should stack crit on Lightning Bolt", function()
            local state = makeShamanState()
            state.talents["1:2"] = 5   -- Call of Thunder +5% crit
            state.talents["3:12"] = 5  -- Tidal Mastery +5% crit
            local r = Pipeline.Calculate(403, state)
            -- critChance = 0.10 + 0.05 + 0.05 = 0.20
            assert.is_near(0.20, r.critChance, 0.001)
        end)

        it("Concussion + Mental Quickness should both affect Lightning Bolt", function()
            local state = makeShamanState()
            state.talents["1:3"] = 5   -- Concussion +5% dmg (additive)
            state.talents["2:19"] = 3  -- Mental Quickness: +600 SP
            local r = Pipeline.Calculate(403, state)
            -- SP = 800 + 600 = 1400
            -- SP bonus = 1400 * 0.794 = 1111.6
            -- Raw: min = 571 + 1111.6 = 1682.6, max = 652 + 1111.6 = 1763.6
            -- Concussion: * (1 + 0.05) = 1.05
            -- Final: min = 1682.6 * 1.05 = 1766.73, max = 1763.6 * 1.05 = 1851.78
            assert.is_near(1766.73, r.minDmg, 0.5)
            assert.is_near(1851.78, r.maxDmg, 0.5)
        end)

        it("Purification + Nature's Blessing should both affect Healing Wave", function()
            local state = makeShamanState()
            state.talents["3:10"] = 5  -- Purification +10% healing (additive)
            state.talents["3:17"] = 3  -- Nature's Blessing: +105 SP
            local r = Pipeline.Calculate(331, state)
            -- SP = 800 + 105 = 905
            -- SP bonus = 905 * 0.857 = 775.585
            -- Raw: min = 2134 + 775.585 = 2909.585, max = 2436 + 775.585 = 3211.585
            -- Purification: * (1 + 0.10) = 1.10
            -- min = 2909.585 * 1.10 = 3200.5435
            -- max = 3211.585 * 1.10 = 3532.7435
            assert.is_near(3200.54, r.minDmg, 1)
            assert.is_near(3532.74, r.maxDmg, 1)
        end)

        it("Lightning Mastery + Improved Healing Wave should not cross-affect", function()
            local state = makeShamanState()
            state.talents["1:11"] = 5  -- Lightning Mastery: -0.5s LB/CL
            state.talents["3:4"] = 5   -- Improved HW: -0.5s HW

            local rLB = Pipeline.Calculate(403, state)
            local rHW = Pipeline.Calculate(331, state)

            -- LB should only get Lightning Mastery reduction
            assert.is_near(2.0, rLB.castTime, 0.01)
            -- HW should only get Improved HW reduction
            assert.is_near(2.5, rHW.castTime, 0.01)
        end)
    end)
end)
