-------------------------------------------------------------------------------
-- test_melee_engine.lua
-- Unit tests for melee damage engine support
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns

local Pipeline = ns.Engine.Pipeline
local SpellCalc = ns.Engine.SpellCalc

-------------------------------------------------------------------------------
-- Local melee player state helper (bootstrap doesn't have one yet)
-------------------------------------------------------------------------------
local function makeMeleeState()
    return {
        level = 70,
        class = "WARRIOR",
        stats = {
            spellPower = {},
            healingPower = 0,
            spellCrit = {},
            spellHit = 0,
            spellHaste = 0,
            attackPower = 1000,
            meleeCrit = 0.10,
            meleeHit = 0.0,
            meleeHaste = 0,
            mainHandWeaponDmgMin = 100,
            mainHandWeaponDmgMax = 200,
            mainHandWeaponType = "TWO_HAND",
            mainHandWeaponSpeed = 3.3,
            expertise = 0,
        },
        talents = {},
        auras = { player = {}, target = {} },
        gear = { setBonuses = {} },
        targetArmor = 0,
        attackingFromBehind = nil,  -- default: behind (no parry)
    }
end

-------------------------------------------------------------------------------
-- Synthetic spell data for engine testing (not real Warrior spells)
-------------------------------------------------------------------------------

-- 99001: Weapon strike (Mortal Strike-style)
ns.SpellData[99001] = {
    name = "Test Melee Strike",
    spellType = "direct",
    scalingType = "melee",
    school = ns.SCHOOL_PHYSICAL,
    weaponDamage = true,
    weaponMultiplier = 1.0,
    castTime = 0,
    ranks = {
        { spellID = 99001, minDmg = 100, maxDmg = 100, level = 1 },
    },
}

-- 99002: AP-based ability (Bloodthirst-style)
ns.SpellData[99002] = {
    name = "Test AP Strike",
    spellType = "direct",
    scalingType = "melee",
    school = ns.SCHOOL_PHYSICAL,
    apCoefficient = 0.45,
    castTime = 0,
    ranks = {
        { spellID = 99002, minDmg = 0, maxDmg = 0, level = 1 },
    },
}

-- 99003: Flat damage ability (Thunder Clap-style)
ns.SpellData[99003] = {
    name = "Test Flat Melee",
    spellType = "direct",
    scalingType = "melee",
    school = ns.SCHOOL_PHYSICAL,
    castTime = 0,
    ranks = {
        { spellID = 99003, minDmg = 123, maxDmg = 123, level = 1 },
    },
}

-- 99004: Melee bleed DoT (Rend-style)
ns.SpellData[99004] = {
    name = "Test Melee Bleed",
    spellType = "dot",
    scalingType = "melee",
    school = ns.SCHOOL_PHYSICAL,
    isDot = true,
    coefficient = 0,
    numTicks = 5,
    duration = 15,
    castTime = 0,
    canCrit = false,
    ranks = {
        { spellID = 99004, totalDmg = 500, level = 1, numTicks = 5 },
    },
}

-- 99005: Weapon strike with multiplier > 1 (Overpower-style)
ns.SpellData[99005] = {
    name = "Test Multiplied Strike",
    spellType = "direct",
    scalingType = "melee",
    school = ns.SCHOOL_PHYSICAL,
    weaponDamage = true,
    weaponMultiplier = 1.25,
    castTime = 0,
    ranks = {
        { spellID = 99005, minDmg = 50, maxDmg = 50, level = 1 },
    },
}

-- 99006: AP-scaled DoT (Deep Wounds-style)
ns.SpellData[99006] = {
    name = "Test AP Bleed",
    spellType = "dot",
    scalingType = "melee",
    school = ns.SCHOOL_PHYSICAL,
    isDot = true,
    coefficient = 0.10,
    numTicks = 4,
    duration = 12,
    castTime = 0,
    canCrit = false,
    ranks = {
        { spellID = 99006, totalDmg = 200, level = 1 },
    },
}

-- 99007: Flat damage with range (Thunder Clap with min/max difference)
ns.SpellData[99007] = {
    name = "Test Flat Range",
    spellType = "direct",
    scalingType = "melee",
    school = ns.SCHOOL_PHYSICAL,
    castTime = 0,
    ranks = {
        { spellID = 99007, minDmg = 100, maxDmg = 200, level = 1 },
    },
}

-------------------------------------------------------------------------------
-- Tests
-------------------------------------------------------------------------------

describe("Melee Engine", function()

    describe("SpellCalc weapon strike", function()

        it("should compute weapon strike with normalized AP", function()
            local state = makeMeleeState()
            -- weapon: 100-200, TWO_HAND normalized speed = 3.3
            -- AP bonus = 1000/14 * 3.3 = 235.714...
            -- flat bonus from rank = 100
            -- min = (100 + 235.714 + 100) * 1.0 = 435.714
            -- max = (200 + 235.714 + 100) * 1.0 = 535.714
            -- avg = (435.714 + 535.714) / 2 = 485.714
            local spellData = ns.SpellData[99001]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(485.714, result.totalDamage, 0.01)
            assert.is_near(435.714, result.totalMin, 0.01)
            assert.is_near(535.714, result.totalMax, 0.01)
        end)

        it("should use ONE_HAND normalized speed for one-handers", function()
            local state = makeMeleeState()
            state.stats.mainHandWeaponType = "ONE_HAND"
            -- AP bonus = 1000/14 * 2.4 = 171.428
            -- min = (100 + 171.428 + 100) * 1.0 = 371.428
            -- max = (200 + 171.428 + 100) * 1.0 = 471.428
            local spellData = ns.SpellData[99001]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(371.428, result.totalMin, 0.01)
            assert.is_near(471.428, result.totalMax, 0.01)
        end)

        it("should use DAGGER normalized speed for daggers", function()
            local state = makeMeleeState()
            state.stats.mainHandWeaponType = "DAGGER"
            -- AP bonus = 1000/14 * 1.7 = 121.428
            -- min = (100 + 121.428 + 100) * 1.0 = 321.428
            local spellData = ns.SpellData[99001]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(321.428, result.totalMin, 0.01)
        end)

        it("should default to 2.4 for unknown weapon type", function()
            local state = makeMeleeState()
            state.stats.mainHandWeaponType = nil
            -- AP bonus = 1000/14 * 2.4 = 171.428
            -- min = (100 + 171.428 + 100) * 1.0 = 371.428
            local spellData = ns.SpellData[99001]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(371.428, result.totalMin, 0.01)
        end)

        it("should apply weaponMultiplier > 1.0", function()
            local state = makeMeleeState()
            -- weaponMultiplier = 1.25
            -- AP bonus = 1000/14 * 3.3 = 235.714
            -- flat bonus = 50
            -- min = (100 + 235.714 + 50) * 1.25 = 482.142
            -- max = (200 + 235.714 + 50) * 1.25 = 607.142
            local spellData = ns.SpellData[99005]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(482.142, result.totalMin, 0.1)
            assert.is_near(607.142, result.totalMax, 0.1)
        end)

        it("should handle zero weapon damage", function()
            local state = makeMeleeState()
            state.stats.mainHandWeaponDmgMin = 0
            state.stats.mainHandWeaponDmgMax = 0
            -- AP bonus = 1000/14 * 3.3 = 235.714
            -- min = (0 + 235.714 + 100) * 1.0 = 335.714
            local spellData = ns.SpellData[99001]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(335.714, result.totalMin, 0.01)
        end)

        it("should handle zero AP", function()
            local state = makeMeleeState()
            state.stats.attackPower = 0
            -- AP bonus = 0
            -- min = (100 + 0 + 100) * 1.0 = 200
            -- max = (200 + 0 + 100) * 1.0 = 300
            local spellData = ns.SpellData[99001]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(200, result.totalMin, 0.01)
            assert.is_near(300, result.totalMax, 0.01)
        end)
    end)

    describe("SpellCalc AP-based ability", function()

        it("should compute AP * coefficient", function()
            local state = makeMeleeState()
            -- AP = 1000, coeff = 0.45
            -- damage = 1000 * 0.45 = 450
            local spellData = ns.SpellData[99002]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(450, result.totalDamage, 0.01)
            -- min == max for AP-based
            assert.is_near(450, result.totalMin, 0.01)
            assert.is_near(450, result.totalMax, 0.01)
        end)

        it("should scale with different AP values", function()
            local state = makeMeleeState()
            state.stats.attackPower = 2000
            -- 2000 * 0.45 = 900
            local spellData = ns.SpellData[99002]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(900, result.totalDamage, 0.01)
        end)
    end)

    describe("SpellCalc flat damage ability", function()

        it("should return rank min/max values directly", function()
            local state = makeMeleeState()
            -- minDmg = maxDmg = 123
            local spellData = ns.SpellData[99003]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(123, result.totalDamage, 0.01)
            assert.is_near(123, result.totalMin, 0.01)
            assert.is_near(123, result.totalMax, 0.01)
        end)

        it("should handle min/max range", function()
            local state = makeMeleeState()
            -- minDmg = 100, maxDmg = 200
            local spellData = ns.SpellData[99007]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(150, result.totalDamage, 0.01)
            assert.is_near(100, result.totalMin, 0.01)
            assert.is_near(200, result.totalMax, 0.01)
        end)
    end)

    describe("SpellCalc melee bleed DoT", function()

        it("should compute simple bleed with no AP scaling", function()
            local state = makeMeleeState()
            -- totalDmg = 500, coefficient = 0, numTicks = 5
            -- total = 500, tick = 100
            local spellData = ns.SpellData[99004]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(500, result.totalDamage, 0.01)
            assert.is_near(100, result.tickDamage, 0.01)
        end)

        it("should compute AP-scaled bleed", function()
            local state = makeMeleeState()
            -- totalDmg = 200, coefficient = 0.10, AP = 1000, numTicks = 4
            -- spBonus = 1000 * 0.10 = 100
            -- total = 200 + 100 = 300, tick = 75
            local spellData = ns.SpellData[99006]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(300, result.totalDamage, 0.01)
            assert.is_near(75, result.tickDamage, 0.01)
        end)
    end)

    describe("CritCalc melee crit multiplier", function()

        it("should use 2.0 base crit multiplier for melee", function()
            local state = makeMeleeState()
            state.stats.meleeCrit = 0.20
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(2.0, result.critMultiplier, 0.001)
        end)

        it("should NOT use 2.0 for spell crit (still 1.5)", function()
            local state = bootstrap.makePlayerState()
            local result = Pipeline.Calculate(686, state)
            assert.is_near(1.5, result.critMultiplier, 0.001)
        end)

        it("should use meleeCrit for melee abilities", function()
            local state = makeMeleeState()
            state.stats.meleeCrit = 0.25
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.25, result.critChance, 0.001)
        end)
    end)

    describe("CritCalc melee hit probability", function()

        it("should use 8% base miss rate for melee", function()
            local state = makeMeleeState()
            state.stats.meleeHit = 0
            -- hitProb = 1 - 0.08 - 0.065 - 0 (behind) = 0.855
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.855, result.hitProbability, 0.001)
        end)

        it("should reduce miss with hit rating", function()
            local state = makeMeleeState()
            state.stats.meleeHit = 0.05
            -- miss = max(0, 0.08 - 0.05) = 0.03
            -- hitProb = 1 - 0.03 - 0.065 - 0 = 0.905
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.905, result.hitProbability, 0.001)
        end)

        it("should cap miss at 0 (cannot go negative)", function()
            local state = makeMeleeState()
            state.stats.meleeHit = 0.15
            -- miss = max(0, 0.08 - 0.15) = 0
            -- hitProb = 1 - 0 - 0.065 - 0 = 0.935
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.935, result.hitProbability, 0.001)
        end)
    end)

    describe("CritCalc dodge avoidance", function()

        it("should include 6.5% dodge in hit calculation", function()
            local state = makeMeleeState()
            state.stats.meleeHit = 0.08  -- removes all miss
            -- hitProb = 1 - 0 - 0.065 - 0 = 0.935
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.935, result.hitProbability, 0.001)
            assert.is_near(0.065, result.dodgeChance, 0.001)
        end)

        it("should reduce dodge with expertise", function()
            local state = makeMeleeState()
            state.stats.meleeHit = 0.08
            state.stats.expertise = 10  -- 10 * 0.25% = 2.5% reduction
            -- dodge = max(0, 0.065 - 0.025) = 0.04
            -- hitProb = 1 - 0 - 0.04 - 0 = 0.96
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.96, result.hitProbability, 0.001)
            assert.is_near(0.04, result.dodgeChance, 0.001)
        end)

        it("should cap dodge at 0 with enough expertise", function()
            local state = makeMeleeState()
            state.stats.meleeHit = 0.08
            state.stats.expertise = 26  -- 26 * 0.25% = 6.5% = full dodge removal
            -- dodge = max(0, 0.065 - 0.065) = 0
            -- hitProb = 1 - 0 - 0 - 0 = 1.0
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(1.0, result.hitProbability, 0.001)
            assert.is_near(0, result.dodgeChance, 0.001)
        end)

        it("should cap dodge at 0 with excess expertise", function()
            local state = makeMeleeState()
            state.stats.meleeHit = 0.08
            state.stats.expertise = 40  -- more than enough
            -- dodge = max(0, 0.065 - 0.1) = 0
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0, result.dodgeChance, 0.001)
            assert.is_near(1.0, result.hitProbability, 0.001)
        end)
    end)

    describe("CritCalc parry avoidance", function()

        it("should have zero parry when attacking from behind (default)", function()
            local state = makeMeleeState()
            -- attackingFromBehind is nil → treated as behind → no parry
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0, result.parryChance, 0.001)
        end)

        it("should have zero parry when attackingFromBehind is true", function()
            local state = makeMeleeState()
            state.attackingFromBehind = true
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0, result.parryChance, 0.001)
        end)

        it("should include 14% parry when attacking from front", function()
            local state = makeMeleeState()
            state.attackingFromBehind = false
            state.stats.meleeHit = 0.08
            -- miss = 0, dodge = 0.065, parry = 0.14
            -- hitProb = 1 - 0 - 0.065 - 0.14 = 0.795
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.14, result.parryChance, 0.001)
            assert.is_near(0.795, result.hitProbability, 0.001)
        end)

        it("should reduce parry with expertise (from front)", function()
            local state = makeMeleeState()
            state.attackingFromBehind = false
            state.stats.meleeHit = 0.08
            state.stats.expertise = 20  -- 20 * 0.25% = 5% reduction
            -- dodge = max(0, 0.065 - 0.05) = 0.015
            -- parry = max(0, 0.14 - 0.05) = 0.09
            -- hitProb = 1 - 0 - 0.015 - 0.09 = 0.895
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.015, result.dodgeChance, 0.001)
            assert.is_near(0.09, result.parryChance, 0.001)
            assert.is_near(0.895, result.hitProbability, 0.001)
        end)

        it("should NOT reduce parry when attacking from behind", function()
            local state = makeMeleeState()
            state.stats.expertise = 20
            -- from behind: parry = 0 regardless of expertise
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0, result.parryChance, 0.001)
        end)
    end)

    describe("Armor reduction with melee", function()

        it("should apply armor reduction to melee physical abilities", function()
            local state = makeMeleeState()
            state.targetArmor = 7684
            local result = Pipeline.Calculate(99001, state)
            assert.is_true(result.armorReduction > 0)
            assert.is_near(0.42124, result.armorReduction, 0.001)
        end)

        it("should reduce expected damage with armor", function()
            local noArmor = makeMeleeState()
            noArmor.targetArmor = 0
            local withArmor = makeMeleeState()
            withArmor.targetArmor = 7684
            local r1 = Pipeline.Calculate(99001, noArmor)
            local r2 = Pipeline.Calculate(99001, withArmor)
            assert.is_true(r2.expectedDamageWithMiss < r1.expectedDamageWithMiss)
        end)
    end)

    describe("Melee modifier application", function()

        it("should apply damage multiplier modifier to melee", function()
            local state = makeMeleeState()
            -- Register a synthetic talent that boosts Test Melee Strike by 15%
            ns.TalentMap["WARRIOR:test_dmg"] = {
                effects = {
                    {
                        type = ns.MOD.DAMAGE_MULTIPLIER,
                        value = 0.05,
                        perRank = true,
                        stacking = "additive",
                        filter = { spellNames = { "Test Melee Strike" } },
                    },
                },
            }
            state.talents["test_dmg"] = 3  -- 3 ranks = +15%

            local result = Pipeline.Calculate(99001, state)
            -- Base avg ≈ 485.714
            -- With 15% bonus: 485.714 * 1.15 ≈ 558.571
            assert.is_near(558.571, result.damageAfterMods, 0.1)

            -- Cleanup
            ns.TalentMap["WARRIOR:test_dmg"] = nil
        end)

        it("should apply crit bonus modifier to melee", function()
            local state = makeMeleeState()
            state.stats.meleeCrit = 0.0
            ns.TalentMap["WARRIOR:test_crit"] = {
                effects = {
                    {
                        type = ns.MOD.CRIT_BONUS,
                        value = 0.05,
                        perRank = true,
                        filter = { spellNames = { "Test Melee Strike" } },
                    },
                },
            }
            state.talents["test_crit"] = 2  -- +10% crit

            local result = Pipeline.Calculate(99001, state)
            assert.is_near(0.10, result.critChance, 0.001)

            ns.TalentMap["WARRIOR:test_crit"] = nil
        end)

        it("should apply crit mult bonus (Impale-style) to melee", function()
            local state = makeMeleeState()
            state.stats.meleeCrit = 0.0
            ns.TalentMap["WARRIOR:test_impale"] = {
                effects = {
                    {
                        type = ns.MOD.CRIT_MULT_BONUS,
                        value = 0.10,
                        perRank = true,
                        filter = { spellNames = { "Test Melee Strike" } },
                    },
                },
            }
            state.talents["test_impale"] = 2  -- +0.20 crit mult

            local result = Pipeline.Calculate(99001, state)
            -- base melee crit mult = 2.0, + 0.20 = 2.20
            assert.is_near(2.20, result.critMultiplier, 0.001)

            ns.TalentMap["WARRIOR:test_impale"] = nil
        end)

        it("should apply flat damage bonus to melee", function()
            local state = makeMeleeState()
            ns.TalentMap["WARRIOR:test_flat"] = {
                effects = {
                    {
                        type = ns.MOD.FLAT_DAMAGE_BONUS,
                        value = 50,
                        filter = { spellNames = { "Test Flat Melee" } },
                    },
                },
            }
            state.talents["test_flat"] = 1

            local result = Pipeline.Calculate(99003, state)
            -- base = 123, flat bonus = 50 → 173
            assert.is_near(173, result.damageAfterMods, 0.01)

            ns.TalentMap["WARRIOR:test_flat"] = nil
        end)
    end)

    describe("Pipeline melee integration", function()

        it("should compute full pipeline for weapon strike", function()
            local state = makeMeleeState()
            state.targetArmor = 0
            local result = Pipeline.Calculate(99001, state)
            assert.is_not_nil(result)
            assert.equals("Test Melee Strike", result.spellName)
            assert.equals(ns.SCHOOL_PHYSICAL, result.school)
            assert.equals("direct", result.spellType)
            assert.is_true(result.dps > 0)
        end)

        it("should compute full pipeline for AP-based ability", function()
            local state = makeMeleeState()
            local result = Pipeline.Calculate(99002, state)
            assert.is_not_nil(result)
            assert.equals("Test AP Strike", result.spellName)
            assert.is_near(450, result.damageAfterMods, 0.01)
        end)

        it("should compute full pipeline for flat ability", function()
            local state = makeMeleeState()
            local result = Pipeline.Calculate(99003, state)
            assert.is_not_nil(result)
            assert.equals("Test Flat Melee", result.spellName)
            assert.is_near(123, result.damageAfterMods, 0.01)
        end)

        it("should compute full pipeline for bleed DoT", function()
            local state = makeMeleeState()
            local result = Pipeline.Calculate(99004, state)
            assert.is_not_nil(result)
            assert.equals("Test Melee Bleed", result.spellName)
            assert.is_near(500, result.damageAfterMods, 0.01)
        end)

        it("should use meleeHaste for GCD calculation", function()
            local state = makeMeleeState()
            state.stats.meleeHaste = 0.20
            -- GCD = 1.5 / 1.2 = 1.25
            local result = Pipeline.Calculate(99001, state)
            assert.is_near(1.25, result.castTime, 0.01)
        end)
    end)

    describe("Melee spellPowerBonus modifier", function()

        it("should resolve spellPowerBonus against attackPower for melee", function()
            local state = makeMeleeState()
            state.stats.attackPower = 1000
            ns.TalentMap["WARRIOR:test_sp_bonus"] = {
                effects = {
                    {
                        type = ns.MOD.SPELL_POWER_BONUS,
                        value = 200,
                        filter = { spellNames = { "Test AP Strike" } },
                    },
                },
            }
            state.talents["test_sp_bonus"] = 1

            local result = Pipeline.Calculate(99002, state)
            -- AP-based: (1000 + 200) * 0.45 = 540
            assert.is_near(540, result.damageAfterMods, 0.01)

            ns.TalentMap["WARRIOR:test_sp_bonus"] = nil
        end)
    end)
end)
