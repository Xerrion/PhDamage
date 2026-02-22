-------------------------------------------------------------------------------
-- test_rogue_spells.lua
-- Tests for Rogue base spell damage computation
--
-- Default Rogue state:
--   AP=2000, meleeCrit=25%, meleeHit=0%, targetArmor=0
--   MH: 130-243 dmg, 2.6 speed, ONE_HAND (normalized 2.4)
--   attackingFromBehind=true
--
-- AP bonus (ONE_HAND): 2000 / 14 * 2.4 = 342.857142857
-- AP bonus (DAGGER):   2000 / 14 * 1.7 = 242.857142857
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makeRogueState = bootstrap.makeRogueState

local Pipeline = ns.Engine.Pipeline

-------------------------------------------------------------------------------
-- Helper: create a dagger-equipped rogue state for Backstab/Ambush/Mutilate
-- Dagger: 100-187 dmg, 1.8 speed, DAGGER type
-- Normalized speed for DAGGER = 1.7
-------------------------------------------------------------------------------
local function makeDaggerRogueState()
    local state = makeRogueState()
    state.stats.mainHandWeaponType = "DAGGER"
    state.stats.mainHandWeaponDmgMin = 100
    state.stats.mainHandWeaponDmgMax = 187
    state.stats.mainHandWeaponSpeed = 1.8
    return state
end

describe("Rogue Spells", function()

    ---------------------------------------------------------------------------
    -- 1. Sinister Strike (baseID 1752)
    -- weaponMult=1.0, R10 flat=98
    -- AP bonus = 2000/14 * 2.4 = 342.857
    -- R10 min = (130 + 342.857 + 98) * 1.0 = 570.857
    -- R10 max = (243 + 342.857 + 98) * 1.0 = 683.857
    -- R1 min = (130 + 342.857 + 3) * 1.0 = 475.857
    -- R1 max = (243 + 342.857 + 3) * 1.0 = 588.857
    ---------------------------------------------------------------------------
    describe("Sinister Strike", function()

        it("calculates R10 base damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1752, state)
            assert.is_not_nil(result)
            assert.equals("Sinister Strike", result.spellName)
            assert.is_near(570.86, result.minDmg, 0.01)
            assert.is_near(683.86, result.maxDmg, 0.01)
        end)

        it("calculates R1 base damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1752, state, 1)
            assert.is_not_nil(result)
            assert.equals("Sinister Strike", result.spellName)
            assert.is_near(475.86, result.minDmg, 0.01)
            assert.is_near(588.86, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeRogueState()
            state.stats.attackPower = 3000
            -- AP bonus = 3000/14 * 2.4 = 514.286
            -- R10 min = (130 + 514.286 + 98) * 1.0 = 742.286
            -- R10 max = (243 + 514.286 + 98) * 1.0 = 855.286
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(742.29, result.minDmg, 0.01)
            assert.is_near(855.29, result.maxDmg, 0.01)
        end)

        it("has correct spell metadata", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1752, state)
            assert.equals("Sinister Strike", result.spellName)
            assert.equals(ns.SCHOOL_PHYSICAL, result.school)
            assert.equals("direct", result.spellType)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Backstab (baseID 53)
    -- weaponMult=1.5, R10 flat=255, requires dagger
    -- Dagger AP bonus = 2000/14 * 1.7 = 242.857
    -- R10 min = (100 + 242.857 + 255) * 1.5 = 896.786
    -- R10 max = (187 + 242.857 + 255) * 1.5 = 1027.286
    -- R1 min = (100 + 242.857 + 15) * 1.5 = 536.786
    -- R1 max = (187 + 242.857 + 15) * 1.5 = 667.286
    ---------------------------------------------------------------------------
    describe("Backstab", function()

        it("calculates R10 base damage with dagger", function()
            local state = makeDaggerRogueState()
            local result = Pipeline.Calculate(53, state)
            assert.is_not_nil(result)
            assert.equals("Backstab", result.spellName)
            assert.is_near(896.79, result.minDmg, 0.01)
            assert.is_near(1027.29, result.maxDmg, 0.01)
        end)

        it("calculates R1 base damage with dagger", function()
            local state = makeDaggerRogueState()
            local result = Pipeline.Calculate(53, state, 1)
            assert.is_not_nil(result)
            assert.is_near(536.79, result.minDmg, 0.01)
            assert.is_near(667.29, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDaggerRogueState()
            state.stats.attackPower = 3000
            -- AP bonus = 3000/14 * 1.7 = 364.286
            -- R10 min = (100 + 364.286 + 255) * 1.5 = 1078.929
            -- R10 max = (187 + 364.286 + 255) * 1.5 = 1209.429
            local result = Pipeline.Calculate(53, state)
            assert.is_near(1078.93, result.minDmg, 0.01)
            assert.is_near(1209.43, result.maxDmg, 0.01)
        end)

        it("applies 1.5x weapon multiplier", function()
            local state = makeDaggerRogueState()
            local result = Pipeline.Calculate(53, state)
            -- Verify multiplier by checking ratio: with flat=0 and same weapon,
            -- damage should be exactly 1.5x of a 1.0 multiplier strike
            -- min without mult = 100 + 242.857 + 255 = 597.857
            -- min with 1.5x mult = 597.857 * 1.5 = 896.786
            assert.is_near(896.79, result.minDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Ambush (baseID 8676)
    -- weaponMult=2.75, R7 flat=335, requires dagger + stealth
    -- Dagger AP bonus = 2000/14 * 1.7 = 242.857
    -- R7 min = (100 + 242.857 + 335) * 2.75 = 1864.107
    -- R7 max = (187 + 242.857 + 335) * 2.75 = 2103.357
    -- R1 min = (100 + 242.857 + 70) * 2.75 = 1135.357
    -- R1 max = (187 + 242.857 + 70) * 2.75 = 1374.607
    ---------------------------------------------------------------------------
    describe("Ambush", function()

        it("calculates R7 base damage with dagger", function()
            local state = makeDaggerRogueState()
            local result = Pipeline.Calculate(8676, state)
            assert.is_not_nil(result)
            assert.equals("Ambush", result.spellName)
            assert.is_near(1864.11, result.minDmg, 0.01)
            assert.is_near(2103.36, result.maxDmg, 0.01)
        end)

        it("calculates R1 base damage with dagger", function()
            local state = makeDaggerRogueState()
            local result = Pipeline.Calculate(8676, state, 1)
            assert.is_not_nil(result)
            assert.is_near(1135.36, result.minDmg, 0.01)
            assert.is_near(1374.61, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDaggerRogueState()
            state.stats.attackPower = 3000
            -- AP bonus = 3000/14 * 1.7 = 364.286
            -- R7 min = (100 + 364.286 + 335) * 2.75 = 2198.036
            -- R7 max = (187 + 364.286 + 335) * 2.75 = 2437.286
            local result = Pipeline.Calculate(8676, state)
            assert.is_near(2198.04, result.minDmg, 0.01)
            assert.is_near(2437.29, result.maxDmg, 0.01)
        end)

        it("applies 2.75x weapon multiplier", function()
            local state = makeDaggerRogueState()
            local result = Pipeline.Calculate(8676, state)
            -- R7 base before mult = 100 + 242.857 + 335 = 677.857
            -- * 2.75 = 1864.107
            assert.is_near(1864.11, result.minDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Hemorrhage (baseID 16511)
    -- weaponMult=1.1, all ranks flat=0
    -- AP bonus = 2000/14 * 2.4 = 342.857 (ONE_HAND)
    -- R4 min = (130 + 342.857 + 0) * 1.1 = 520.143
    -- R4 max = (243 + 342.857 + 0) * 1.1 = 644.443
    -- R1 min = (130 + 342.857 + 0) * 1.1 = 520.143
    -- R1 max = (243 + 342.857 + 0) * 1.1 = 644.443
    ---------------------------------------------------------------------------
    describe("Hemorrhage", function()

        it("calculates R4 base damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(16511, state)
            assert.is_not_nil(result)
            assert.equals("Hemorrhage", result.spellName)
            assert.is_near(520.14, result.minDmg, 0.01)
            assert.is_near(644.44, result.maxDmg, 0.01)
        end)

        it("calculates R1 base damage (same as R4 — all ranks have 0 flat)", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(16511, state, 1)
            assert.is_not_nil(result)
            assert.is_near(520.14, result.minDmg, 0.01)
            assert.is_near(644.44, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeRogueState()
            state.stats.attackPower = 3000
            -- AP bonus = 3000/14 * 2.4 = 514.286
            -- R4 min = (130 + 514.286 + 0) * 1.1 = 708.714
            -- R4 max = (243 + 514.286 + 0) * 1.1 = 833.014
            local result = Pipeline.Calculate(16511, state)
            assert.is_near(708.71, result.minDmg, 0.01)
            assert.is_near(833.01, result.maxDmg, 0.01)
        end)

        it("applies 1.1x weapon multiplier", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(16511, state)
            -- min before mult = 130 + 342.857 = 472.857
            -- * 1.1 = 520.143
            assert.is_near(520.14, result.minDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Ghostly Strike (baseID 14278)
    -- weaponMult=1.25, flat=0, single rank
    -- AP bonus = 2000/14 * 2.4 = 342.857 (ONE_HAND)
    -- R1 min = (130 + 342.857 + 0) * 1.25 = 591.071
    -- R1 max = (243 + 342.857 + 0) * 1.25 = 732.321
    ---------------------------------------------------------------------------
    describe("Ghostly Strike", function()

        it("calculates R1 base damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(14278, state)
            assert.is_not_nil(result)
            assert.equals("Ghostly Strike", result.spellName)
            assert.is_near(591.07, result.minDmg, 0.01)
            assert.is_near(732.32, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeRogueState()
            state.stats.attackPower = 3000
            -- AP bonus = 3000/14 * 2.4 = 514.286
            -- R1 min = (130 + 514.286 + 0) * 1.25 = 805.357
            -- R1 max = (243 + 514.286 + 0) * 1.25 = 946.607
            local result = Pipeline.Calculate(14278, state)
            assert.is_near(805.36, result.minDmg, 0.01)
            assert.is_near(946.61, result.maxDmg, 0.01)
        end)

        it("applies 1.25x weapon multiplier", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(14278, state)
            -- min before mult = 130 + 342.857 = 472.857
            -- * 1.25 = 591.071
            assert.is_near(591.07, result.minDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 6. Mutilate (baseID 1329)
    -- weaponMult=1.0, R4 flat=101, dualWieldStrike=true, requires dagger
    -- Engine computes MH only (OH is a separate concern)
    -- Dagger AP bonus = 2000/14 * 1.7 = 242.857
    -- R4 min = (100 + 242.857 + 101) * 1.0 = 443.857
    -- R4 max = (187 + 242.857 + 101) * 1.0 = 530.857
    -- R1 min = (100 + 242.857 + 44) * 1.0 = 386.857
    -- R1 max = (187 + 242.857 + 44) * 1.0 = 473.857
    ---------------------------------------------------------------------------
    describe("Mutilate", function()

        it("calculates R4 base damage (MH) with dagger", function()
            local state = makeDaggerRogueState()
            local result = Pipeline.Calculate(1329, state)
            assert.is_not_nil(result)
            assert.equals("Mutilate", result.spellName)
            assert.is_near(443.86, result.minDmg, 0.01)
            assert.is_near(530.86, result.maxDmg, 0.01)
        end)

        it("calculates R1 base damage (MH) with dagger", function()
            local state = makeDaggerRogueState()
            local result = Pipeline.Calculate(1329, state, 1)
            assert.is_not_nil(result)
            assert.is_near(386.86, result.minDmg, 0.01)
            assert.is_near(473.86, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeDaggerRogueState()
            state.stats.attackPower = 3000
            -- AP bonus = 3000/14 * 1.7 = 364.286
            -- R4 min = (100 + 364.286 + 101) * 1.0 = 565.286
            -- R4 max = (187 + 364.286 + 101) * 1.0 = 652.286
            local result = Pipeline.Calculate(1329, state)
            assert.is_near(565.29, result.minDmg, 0.01)
            assert.is_near(652.29, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 7. Shiv (baseID 5938)
    -- weaponMult=1.0, flat=0, offHandOnly=true
    -- Engine reads MH stats (offHandOnly is a flag, not engine-handled yet)
    -- AP bonus = 2000/14 * 2.4 = 342.857 (ONE_HAND)
    -- R1 min = (130 + 342.857 + 0) * 1.0 = 472.857
    -- R1 max = (243 + 342.857 + 0) * 1.0 = 585.857
    ---------------------------------------------------------------------------
    describe("Shiv", function()

        it("calculates R1 base damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(5938, state)
            assert.is_not_nil(result)
            assert.equals("Shiv", result.spellName)
            assert.is_near(472.86, result.minDmg, 0.01)
            assert.is_near(585.86, result.maxDmg, 0.01)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeRogueState()
            state.stats.attackPower = 3000
            -- AP bonus = 3000/14 * 2.4 = 514.286
            -- R1 min = (130 + 514.286 + 0) * 1.0 = 644.286
            -- R1 max = (243 + 514.286 + 0) * 1.0 = 757.286
            local result = Pipeline.Calculate(5938, state)
            assert.is_near(644.29, result.minDmg, 0.01)
            assert.is_near(757.29, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 8. Gouge (baseID 1776)
    -- No weapon, flat damage only (Type 3 in engine)
    -- R6 min = max = 105
    -- R1 min = max = 10
    ---------------------------------------------------------------------------
    describe("Gouge", function()

        it("calculates R6 base damage (flat only)", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1776, state)
            assert.is_not_nil(result)
            assert.equals("Gouge", result.spellName)
            assert.is_near(105, result.minDmg, 0.01)
            assert.is_near(105, result.maxDmg, 0.01)
        end)

        it("calculates R1 base damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1776, state, 1)
            assert.is_not_nil(result)
            assert.is_near(10, result.minDmg, 0.01)
            assert.is_near(10, result.maxDmg, 0.01)
        end)

        it("is not affected by AP changes", function()
            local state = makeRogueState()
            state.stats.attackPower = 5000
            local result = Pipeline.Calculate(1776, state)
            assert.is_near(105, result.minDmg, 0.01)
            assert.is_near(105, result.maxDmg, 0.01)
        end)

        it("is not affected by weapon changes", function()
            local state = makeRogueState()
            state.stats.mainHandWeaponDmgMin = 500
            state.stats.mainHandWeaponDmgMax = 700
            local result = Pipeline.Calculate(1776, state)
            assert.is_near(105, result.minDmg, 0.01)
            assert.is_near(105, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 9. Eviscerate (baseID 2098)
    -- Finishing move: flat min/max + AP coefficient, no weapon
    -- apCoefficient = 0.15 (5 CP), R10: minDmg=985, maxDmg=1105
    --
    -- CORRECT behavior (base + AP):
    --   AP damage = 2000 * 0.15 = 300
    --   min = 985 + 300 = 1285
    --   max = 1105 + 300 = 1405
    --   avg = 1345
    --
    -- NOTE: Current engine Type 2 (apCoefficient without weaponDamage) computes
    -- ONLY AP*coeff, discarding rankData min/max. These tests assert the CORRECT
    -- expected values. If they fail, the engine needs to be updated to combine
    -- both base damage and AP scaling for finishing moves.
    ---------------------------------------------------------------------------
    describe("Eviscerate", function()

        it("calculates R10 damage (base + AP coefficient)", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(2098, state)
            assert.is_not_nil(result)
            assert.equals("Eviscerate", result.spellName)
            assert.is_near(1285, result.minDmg, 1)
            assert.is_near(1405, result.maxDmg, 1)
        end)

        it("calculates R1 damage", function()
            local state = makeRogueState()
            -- R1: minDmg=95, maxDmg=105, apCoeff=0.15
            -- AP dmg = 2000 * 0.15 = 300
            -- min = 95 + 300 = 395, max = 105 + 300 = 405
            local result = Pipeline.Calculate(2098, state, 1)
            assert.is_not_nil(result)
            assert.is_near(395, result.minDmg, 1)
            assert.is_near(405, result.maxDmg, 1)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeRogueState()
            state.stats.attackPower = 3000
            -- AP damage = 3000 * 0.15 = 450
            -- R10 min = 985 + 450 = 1435
            -- R10 max = 1105 + 450 = 1555
            local result = Pipeline.Calculate(2098, state)
            assert.is_near(1435, result.minDmg, 1)
            assert.is_near(1555, result.maxDmg, 1)
        end)

        it("has correct spell metadata", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(2098, state)
            assert.equals("Eviscerate", result.spellName)
            assert.equals(ns.SCHOOL_PHYSICAL, result.school)
            assert.equals("direct", result.spellType)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 10. Rupture (baseID 1943)
    -- DoT finishing move, canCrit=false, apCoefficient=0.24
    -- R7: totalDmg=1000, duration=16, numTicks=8
    --
    -- CORRECT behavior (base + AP):
    --   AP damage = 2000 * 0.24 = 480
    --   totalDmg = 1000 + 480 = 1480
    --   tickDmg = 1480 / 8 = 185
    --
    -- NOTE: Current engine melee DoT branch uses spellData.coefficient (not
    -- apCoefficient), so AP scaling may not be applied. Tests assert CORRECT
    -- behavior; engine may need update.
    ---------------------------------------------------------------------------
    describe("Rupture", function()

        it("calculates R7 total DoT damage (base + AP)", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1943, state)
            assert.is_not_nil(result)
            assert.equals("Rupture", result.spellName)
            assert.is_near(1480, result.totalDmg, 1)
        end)

        it("has correct tick damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1943, state)
            -- 1480 / 8 ticks = 185 per tick
            assert.is_near(185, result.tickDmg, 1)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeRogueState()
            state.stats.attackPower = 3000
            -- AP damage = 3000 * 0.24 = 720
            -- totalDmg = 1000 + 720 = 1720
            local result = Pipeline.Calculate(1943, state)
            assert.is_near(1720, result.totalDmg, 1)
        end)

        it("cannot crit", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1943, state)
            assert.equals(0, result.critChance)
        end)

        it("has correct DoT metadata", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(1943, state)
            assert.is_true(result.isDot)
            assert.equals(8, result.numTicks)
            assert.equals(16, result.duration)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 11. Envenom (baseID 32645)
    -- Nature direct, canCrit=false, apCoefficient=0.15
    -- R2: minDmg=900, maxDmg=900
    --
    -- CORRECT behavior (base + AP):
    --   AP damage = 2000 * 0.15 = 300
    --   min = max = 900 + 300 = 1200
    --
    -- NOTE: Same engine limitation as Eviscerate — Type 2 discards base damage.
    ---------------------------------------------------------------------------
    describe("Envenom", function()

        it("calculates R2 damage (base + AP coefficient)", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(32645, state)
            assert.is_not_nil(result)
            assert.equals("Envenom", result.spellName)
            assert.is_near(1200, result.minDmg, 1)
            assert.is_near(1200, result.maxDmg, 1)
        end)

        it("calculates R1 damage", function()
            local state = makeRogueState()
            -- R1: minDmg=650, maxDmg=650, apCoeff=0.15
            -- AP dmg = 300, total = 650 + 300 = 950
            local result = Pipeline.Calculate(32645, state, 1)
            assert.is_not_nil(result)
            assert.is_near(950, result.minDmg, 1)
            assert.is_near(950, result.maxDmg, 1)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeRogueState()
            state.stats.attackPower = 3000
            -- AP damage = 3000 * 0.15 = 450
            -- R2 total = 900 + 450 = 1350
            local result = Pipeline.Calculate(32645, state)
            assert.is_near(1350, result.minDmg, 1)
            assert.is_near(1350, result.maxDmg, 1)
        end)

        it("cannot crit", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(32645, state)
            assert.equals(0, result.critChance)
        end)

        it("has Nature school", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(32645, state)
            assert.equals(ns.SCHOOL_NATURE, result.school)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 12. Deadly Throw (baseID 26679)
    -- Ranged finishing move, weaponDamage=true, weaponMult=1.0
    -- scalingType="ranged" — uses ranged weapon stats and RAP
    -- R1: minDmg=584, maxDmg=600
    --
    -- The default rogue state lacks ranged weapon stats, so this test sets up
    -- a minimal ranged state and verifies the pipeline can process the spell.
    ---------------------------------------------------------------------------
    describe("Deadly Throw", function()

        it("processes without error and returns correct name", function()
            local state = makeRogueState()
            -- Add minimal ranged stats so the pipeline can run
            state.stats.rangedAttackPower = 2000
            state.stats.rangedCrit = 0.25
            state.stats.rangedHit = 0.00
            state.stats.weaponDamage = { min = 33, max = 50 }
            local result = Pipeline.Calculate(26679, state)
            assert.is_not_nil(result)
            assert.equals("Deadly Throw", result.spellName)
        end)

        it("includes flat bonus from rank data", function()
            local state = makeRogueState()
            state.stats.rangedAttackPower = 0
            state.stats.rangedCrit = 0.25
            state.stats.rangedHit = 0.00
            state.stats.weaponDamage = { min = 0, max = 0 }
            local result = Pipeline.Calculate(26679, state)
            assert.is_not_nil(result)
            -- With 0 RAP and 0 weapon damage, only flat bonus remains
            -- avgBase = (584 + 600) / 2 = 592
            assert.is_near(592, result.avgBaseDamage, 1)
        end)

        it("has correct spell metadata", function()
            local state = makeRogueState()
            state.stats.rangedAttackPower = 0
            state.stats.rangedCrit = 0
            state.stats.rangedHit = 0
            state.stats.weaponDamage = { min = 0, max = 0 }
            local result = Pipeline.Calculate(26679, state)
            assert.equals("Deadly Throw", result.spellName)
            assert.equals(ns.SCHOOL_PHYSICAL, result.school)
            assert.equals("direct", result.spellType)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 13. Garrote (baseID 703)
    -- DoT, canCrit=false, apCoefficient=0.18
    -- R8: totalDmg=810, duration=18, numTicks=6
    --
    -- CORRECT behavior (base + AP):
    --   AP damage = 2000 * 0.18 = 360
    --   totalDmg = 810 + 360 = 1170
    --   tickDmg = 1170 / 6 = 195
    --
    -- NOTE: Same engine limitation as Rupture — uses coefficient instead of
    -- apCoefficient for melee DoTs. Tests assert CORRECT behavior.
    ---------------------------------------------------------------------------
    describe("Garrote", function()

        it("calculates R8 total DoT damage (base + AP)", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(703, state)
            assert.is_not_nil(result)
            assert.equals("Garrote", result.spellName)
            assert.is_near(1170, result.totalDmg, 1)
        end)

        it("has correct tick damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(703, state)
            -- 1170 / 6 ticks = 195 per tick
            assert.is_near(195, result.tickDmg, 1)
        end)

        it("calculates R1 total DoT damage", function()
            local state = makeRogueState()
            -- R1: totalDmg=144, apCoeff=0.18
            -- AP damage = 2000 * 0.18 = 360
            -- total = 144 + 360 = 504
            local result = Pipeline.Calculate(703, state, 1)
            assert.is_not_nil(result)
            assert.is_near(504, result.totalDmg, 1)
        end)

        it("scales with AP increase to 3000", function()
            local state = makeRogueState()
            state.stats.attackPower = 3000
            -- AP damage = 3000 * 0.18 = 540
            -- R8 totalDmg = 810 + 540 = 1350
            local result = Pipeline.Calculate(703, state)
            assert.is_near(1350, result.totalDmg, 1)
        end)

        it("cannot crit", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(703, state)
            assert.equals(0, result.critChance)
        end)

        it("has correct DoT metadata", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(703, state)
            assert.is_true(result.isDot)
            assert.equals(6, result.numTicks)
            assert.equals(18, result.duration)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 14. Instant Poison (baseID 8679)
    -- Nature direct, flat damage only (Type 3), no weapon, no AP scaling
    -- R7: minDmg=146, maxDmg=194
    -- R1: minDmg=19, maxDmg=25
    ---------------------------------------------------------------------------
    describe("Instant Poison", function()

        it("calculates R7 base damage (flat only)", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(8679, state)
            assert.is_not_nil(result)
            assert.equals("Instant Poison", result.spellName)
            assert.is_near(146, result.minDmg, 0.01)
            assert.is_near(194, result.maxDmg, 0.01)
        end)

        it("calculates R1 base damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(8679, state, 1)
            assert.is_not_nil(result)
            assert.is_near(19, result.minDmg, 0.01)
            assert.is_near(25, result.maxDmg, 0.01)
        end)

        it("is not affected by AP changes", function()
            local state = makeRogueState()
            state.stats.attackPower = 5000
            local result = Pipeline.Calculate(8679, state)
            assert.is_near(146, result.minDmg, 0.01)
            assert.is_near(194, result.maxDmg, 0.01)
        end)

        it("has Nature school", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(8679, state)
            assert.equals(ns.SCHOOL_NATURE, result.school)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 15. Deadly Poison (baseID 2823)
    -- Nature DoT, flat damage only, canCrit=false
    -- R7: totalDmg=180, duration=12, numTicks=4
    -- tickDmg = 180 / 4 = 45
    -- R1: totalDmg=36, tickDmg = 36 / 4 = 9
    ---------------------------------------------------------------------------
    describe("Deadly Poison", function()

        it("calculates R7 total DoT damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(2823, state)
            assert.is_not_nil(result)
            assert.equals("Deadly Poison", result.spellName)
            assert.is_near(180, result.totalDmg, 0.01)
        end)

        it("has correct tick damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(2823, state)
            -- 180 / 4 = 45
            assert.is_near(45, result.tickDmg, 0.01)
        end)

        it("calculates R1 total DoT damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(2823, state, 1)
            assert.is_not_nil(result)
            assert.is_near(36, result.totalDmg, 0.01)
        end)

        it("is not affected by AP changes", function()
            local state = makeRogueState()
            state.stats.attackPower = 5000
            local result = Pipeline.Calculate(2823, state)
            assert.is_near(180, result.totalDmg, 0.01)
        end)

        it("cannot crit", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(2823, state)
            assert.equals(0, result.critChance)
        end)

        it("has correct DoT metadata", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(2823, state)
            assert.is_true(result.isDot)
            assert.equals(4, result.numTicks)
            assert.equals(12, result.duration)
        end)

        it("has Nature school", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(2823, state)
            assert.equals(ns.SCHOOL_NATURE, result.school)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 16. Wound Poison (baseID 13219)
    -- Nature direct, flat damage only, no weapon, no AP scaling
    -- R5: minDmg=65, maxDmg=65
    -- R1: minDmg=17, maxDmg=17
    ---------------------------------------------------------------------------
    describe("Wound Poison", function()

        it("calculates R5 base damage (flat only)", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(13219, state)
            assert.is_not_nil(result)
            assert.equals("Wound Poison", result.spellName)
            assert.is_near(65, result.minDmg, 0.01)
            assert.is_near(65, result.maxDmg, 0.01)
        end)

        it("calculates R1 base damage", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(13219, state, 1)
            assert.is_not_nil(result)
            assert.is_near(17, result.minDmg, 0.01)
            assert.is_near(17, result.maxDmg, 0.01)
        end)

        it("is not affected by AP changes", function()
            local state = makeRogueState()
            state.stats.attackPower = 5000
            local result = Pipeline.Calculate(13219, state)
            assert.is_near(65, result.minDmg, 0.01)
            assert.is_near(65, result.maxDmg, 0.01)
        end)

        it("has Nature school", function()
            local state = makeRogueState()
            local result = Pipeline.Calculate(13219, state)
            assert.equals(ns.SCHOOL_NATURE, result.school)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Spell metadata verification
    ---------------------------------------------------------------------------
    describe("Spell metadata", function()

        it("has all 16 Rogue spells in SpellData", function()
            local baseIDs = {
                1752, 53, 8676, 16511, 14278, 1329, 5938,  -- weapon strikes
                1776,                                        -- non-weapon melee
                2098, 1943, 32645, 26679,                   -- finishing moves
                703,                                         -- DoTs
                8679, 2823, 13219,                           -- poisons
            }
            for _, id in ipairs(baseIDs) do
                assert.is_not_nil(ns.SpellData[id], "Missing spell base ID " .. id)
            end
        end)

        it("has correct spell types", function()
            -- Direct spells
            assert.equals("direct", ns.SpellData[1752].spellType)  -- Sinister Strike
            assert.equals("direct", ns.SpellData[53].spellType)    -- Backstab
            assert.equals("direct", ns.SpellData[8676].spellType)  -- Ambush
            assert.equals("direct", ns.SpellData[16511].spellType) -- Hemorrhage
            assert.equals("direct", ns.SpellData[14278].spellType) -- Ghostly Strike
            assert.equals("direct", ns.SpellData[1329].spellType)  -- Mutilate
            assert.equals("direct", ns.SpellData[5938].spellType)  -- Shiv
            assert.equals("direct", ns.SpellData[1776].spellType)  -- Gouge
            assert.equals("direct", ns.SpellData[2098].spellType)  -- Eviscerate
            assert.equals("direct", ns.SpellData[32645].spellType) -- Envenom
            assert.equals("direct", ns.SpellData[26679].spellType) -- Deadly Throw
            assert.equals("direct", ns.SpellData[8679].spellType)  -- Instant Poison
            assert.equals("direct", ns.SpellData[13219].spellType) -- Wound Poison
            -- DoT spells
            assert.equals("dot", ns.SpellData[1943].spellType)  -- Rupture
            assert.equals("dot", ns.SpellData[703].spellType)   -- Garrote
            assert.equals("dot", ns.SpellData[2823].spellType)  -- Deadly Poison
        end)

        it("has correct schools", function()
            -- Physical spells
            local physicalIDs = { 1752, 53, 8676, 16511, 14278, 1329, 5938, 1776, 2098, 1943, 703, 26679 }
            for _, id in ipairs(physicalIDs) do
                assert.equals(ns.SCHOOL_PHYSICAL, ns.SpellData[id].school,
                    "Expected Physical school for spell " .. id)
            end
            -- Nature spells (poisons + Envenom)
            local natureIDs = { 32645, 8679, 2823, 13219 }
            for _, id in ipairs(natureIDs) do
                assert.equals(ns.SCHOOL_NATURE, ns.SpellData[id].school,
                    "Expected Nature school for spell " .. id)
            end
        end)

        it("has correct canCrit flags", function()
            -- Can crit
            local crittable = { 1752, 53, 8676, 16511, 14278, 1329, 5938, 1776, 2098, 26679, 8679, 13219 }
            for _, id in ipairs(crittable) do
                assert.is_true(ns.SpellData[id].canCrit,
                    "Expected canCrit=true for spell " .. id)
            end
            -- Cannot crit
            local nonCrittable = { 1943, 32645, 703, 2823 }
            for _, id in ipairs(nonCrittable) do
                assert.is_false(ns.SpellData[id].canCrit,
                    "Expected canCrit=false for spell " .. id)
            end
        end)

        it("weapon strikes have weaponDamage=true", function()
            local weaponIDs = { 1752, 53, 8676, 16511, 14278, 1329, 5938, 26679 }
            for _, id in ipairs(weaponIDs) do
                assert.is_true(ns.SpellData[id].weaponDamage,
                    "Expected weaponDamage=true for spell " .. id)
            end
        end)

        it("non-weapon spells have weaponDamage=false", function()
            local nonWeaponIDs = { 1776, 2098, 1943, 32645, 703, 8679, 2823, 13219 }
            for _, id in ipairs(nonWeaponIDs) do
                assert.is_false(ns.SpellData[id].weaponDamage,
                    "Expected weaponDamage=false for spell " .. id)
            end
        end)
    end)
end)
