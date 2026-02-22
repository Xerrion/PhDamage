-------------------------------------------------------------------------------
-- test_ranged_engine.lua
-- Unit tests for ranged damage engine generalization + armor reduction
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeHunterState = bootstrap.makeHunterState

local Pipeline = ns.Engine.Pipeline
local SpellCalc = ns.Engine.SpellCalc
local CritCalc = ns.Engine.CritCalc

describe("Ranged Engine", function()

    describe("SpellCalc ranged scaling", function()

        it("should use RAP for ranged direct spells (Arcane Shot)", function()
            local state = makeHunterState()
            -- Arcane Shot rank 9: base 273, coeff 0.15, RAP 1000
            -- expected: 273 + 1000*0.15 = 423
            local spellData = ns.SpellData[3044]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(423, result.totalDamage, 0.01)
        end)

        it("should include weapon damage for Steady Shot", function()
            local state = makeHunterState()
            -- Steady Shot: base 150, coeff 0.20, RAP 1000, weapon avg (100+200)/2=150
            -- expected: 150 + 1000*0.20 + 150 = 500
            local spellData = ns.SpellData[34120]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(500, result.totalDamage, 0.01)
        end)

        it("should include weapon damage for Aimed Shot", function()
            local state = makeHunterState()
            -- Aimed Shot rank 7: base 600, coeff 0.20, RAP 1000, weapon avg 150
            -- expected: 600 + 200 + 150 = 950
            local spellData = ns.SpellData[19434]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(950, result.totalDamage, 0.01)
        end)

        it("should handle no weapon damage gracefully", function()
            local state = makeHunterState()
            state.stats.weaponDamage = nil
            -- Steady Shot: base 150, coeff 0.20, RAP 1000, no weapon
            -- expected: 150 + 200 = 350
            local spellData = ns.SpellData[34120]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(350, result.totalDamage, 0.01)
        end)

        it("should use RAP for ranged DoT spells (Serpent Sting)", function()
            local state = makeHunterState()
            -- Serpent Sting rank 10: totalDmg 990, coeff 0.10, RAP 1000
            -- expected: 990 + 100 = 1090
            local spellData = ns.SpellData[1978]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(1090, result.totalDamage, 0.01)
        end)

        it("should use RAP for channel spells (Volley)", function()
            local state = makeHunterState()
            -- Volley rank 4: totalDmg 450, coeff 0.50, RAP 1000
            -- expected: 450 + 500 = 950
            local spellData = ns.SpellData[1510]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(950, result.totalDamage, 0.01)
        end)

        it("should use RAP for hybrid spells (Explosive Trap)", function()
            local state = makeHunterState()
            -- Explosive Trap rank 4: direct avg (256+338)/2=297, dotDmg=520, dotCoeff 0.10
            -- Direct: 297 + 0 = 297 (directCoefficient = 0.00)
            -- DoT: 520 + 1000*0.10 = 620
            local spellData = ns.SpellData[13813]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(297, result.directDamage, 0.01)
            assert.is_near(620, result.dotDamage, 0.01)
        end)

        it("should scale with different RAP values", function()
            local state = makeHunterState()
            state.stats.rangedAttackPower = 2000
            -- Arcane Shot rank 9: 273 + 2000*0.15 = 573
            local spellData = ns.SpellData[3044]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(573, result.totalDamage, 0.01)
        end)

        it("should handle zero RAP", function()
            local state = makeHunterState()
            state.stats.rangedAttackPower = 0
            -- Arcane Shot rank 9: 273 + 0 = 273
            local spellData = ns.SpellData[3044]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(273, result.totalDamage, 0.01)
        end)
    end)

    describe("Armor Reduction", function()

        it("should compute correct armor reduction at level 70", function()
            local state = makeHunterState()
            state.targetArmor = 7684
            -- K = 467.5*70 - 22167.5 = 32725 - 22167.5 = 10557.5
            -- DR = 7684 / (7684 + 10557.5) = 7684 / 18241.5 ≈ 0.42124
            local dr = CritCalc.ComputeArmorReduction(state)
            assert.is_near(0.42124, dr, 0.001)
        end)

        it("should cap armor reduction at 75%", function()
            local state = makeHunterState()
            state.targetArmor = 100000
            local dr = CritCalc.ComputeArmorReduction(state)
            assert.is_near(0.75, dr, 0.001)
        end)

        it("should return 0 for zero armor", function()
            local state = makeHunterState()
            state.targetArmor = 0
            local dr = CritCalc.ComputeArmorReduction(state)
            assert.equals(0, dr)
        end)

        it("should return 0 for nil armor", function()
            local state = makeHunterState()
            state.targetArmor = nil
            local dr = CritCalc.ComputeArmorReduction(state)
            assert.equals(0, dr)
        end)

        it("should apply armor reduction to physical direct spells", function()
            local state = makeHunterState()
            state.targetArmor = 7684
            -- Steady Shot through pipeline
            local result = Pipeline.Calculate(34120, state)
            assert.is_true(result.armorReduction > 0)
            -- Verify damage is reduced
            local noArmorState = makeHunterState()
            noArmorState.targetArmor = 0
            local noArmorResult = Pipeline.Calculate(34120, noArmorState)
            assert.is_true(result.expectedDamageWithMiss < noArmorResult.expectedDamageWithMiss)
        end)

        it("should NOT apply armor reduction to Arcane school spells", function()
            local state = makeHunterState()
            state.targetArmor = 7684
            local result = Pipeline.Calculate(3044, state)
            assert.equals(0, result.armorReduction)
        end)

        it("should NOT apply armor reduction to Nature school spells", function()
            local state = makeHunterState()
            state.targetArmor = 7684
            local result = Pipeline.Calculate(1978, state)
            assert.equals(0, result.armorReduction)
        end)

        it("should NOT apply armor reduction to Fire school spells", function()
            local state = makeHunterState()
            state.targetArmor = 7684
            local result = Pipeline.Calculate(13795, state)
            assert.equals(0, result.armorReduction)
        end)

        it("should apply correct armor DR value to Steady Shot", function()
            local state = makeHunterState()
            state.targetArmor = 7684
            local result = Pipeline.Calculate(34120, state)
            -- DR ≈ 0.42124
            assert.is_near(0.42124, result.armorReduction, 0.001)
        end)

        it("should compute armor reduction at different levels", function()
            local state = makeHunterState()
            state.level = 60
            state.targetArmor = 5000
            -- K = 467.5*60 - 22167.5 = 28050 - 22167.5 = 5882.5
            -- DR = 5000 / (5000 + 5882.5) = 5000/10882.5 ≈ 0.4594
            local dr = CritCalc.ComputeArmorReduction(state)
            assert.is_near(0.4594, dr, 0.001)
        end)
    end)

    describe("CritCalc ranged routing", function()

        it("should use rangedCrit for ranged spells", function()
            local state = makeHunterState()
            state.stats.rangedCrit = 0.25  -- 25% crit
            local result = Pipeline.Calculate(3044, state)
            assert.is_near(0.25, result.critChance, 0.001)
        end)

        it("should use rangedHit for ranged spells", function()
            local state = makeHunterState()
            state.stats.rangedHit = 0.09  -- 9% bonus hit = 100% total
            local result = Pipeline.Calculate(3044, state)
            assert.is_near(1.0, result.hitProbability, 0.001)
        end)

        it("should use 9% base miss for ranged (not 17%)", function()
            local state = makeHunterState()
            state.stats.rangedHit = 0
            local result = Pipeline.Calculate(3044, state)
            -- base hit = 1 - 0.09 = 0.91
            assert.is_near(0.91, result.hitProbability, 0.001)
        end)

        it("should allow 100% hit for ranged (not capped at 99%)", function()
            local state = makeHunterState()
            state.stats.rangedHit = 0.15  -- way over cap
            local result = Pipeline.Calculate(3044, state)
            assert.is_near(1.0, result.hitProbability, 0.001)
        end)

        it("should apply rangedHaste to cast time", function()
            local state = makeHunterState()
            state.stats.rangedHaste = 0.20  -- 20% haste
            -- Steady Shot: 1.5s cast / 1.2 = 1.25s, but GCD = 1.5/1.2 = 1.25s
            -- effectiveCast = max(1.25, 1.25) = 1.25
            local result = Pipeline.Calculate(34120, state)
            assert.is_near(1.25, result.castTime, 0.01)
        end)

        it("should use spellCrit for caster spells (not affected by ranged routing)", function()
            local state = bootstrap.makePlayerState()
            -- Warlock Shadow Bolt: should use spellCrit, not rangedCrit
            local result = Pipeline.Calculate(686, state)
            assert.is_near(0.10, result.critChance, 0.001)
        end)
    end)

    describe("Multi-Shot", function()
        it("should compute Multi-Shot with RAP scaling", function()
            local state = makeHunterState()
            -- Multi-Shot rank 6: base 205, coeff 0.20, RAP 1000
            -- expected: 205 + 200 = 405
            local spellData = ns.SpellData[2643]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(405, result.totalDamage, 0.01)
        end)

        it("should be marked as AoE", function()
            local spellData = ns.SpellData[2643]
            assert.is_true(spellData.isAoe)
        end)
    end)

    describe("Silencing Shot", function()
        it("should use weapon damage with weaponMultiplier", function()
            local state = makeHunterState()
            -- Silencing Shot: base 0, coeff 0.00, weaponDamage=true, avg weapon 150
            -- Expected: 0 + 0 + 150*0.50 = 75
            local spellData = ns.SpellData[34490]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(75, result.totalDamage, 0.01)
        end)
    end)

    describe("Immolation Trap", function()
        it("should compute DoT with RAP", function()
            local state = makeHunterState()
            -- Immolation Trap rank 6: totalDmg 1230, coeff 0.10, RAP 1000
            -- expected: 1230 + 100 = 1330
            local spellData = ns.SpellData[13795]
            local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
            local result = SpellCalc.ComputeBase(spellData, rankData, state)
            assert.is_near(1330, result.totalDamage, 0.01)
        end)

        it("should not crit", function()
            local spellData = ns.SpellData[13795]
            assert.is_false(spellData.canCrit)
        end)
    end)
end)
