-------------------------------------------------------------------------------
-- test_critcalc.lua
-- Unit tests for PhDamage Engine.CritCalc
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

describe("CritCalc", function()
    local playerState
    local SpellCalc = ns.Engine.SpellCalc
    local ModifierCalc = ns.Engine.ModifierCalc
    local CritCalc = ns.Engine.CritCalc

    before_each(function()
        playerState = makePlayerState()
    end)

    --- Helper: run the full chain ComputeBase → ApplyModifiers → ApplyExpectedCrit
    local function runFullChain(spellID, state)
        local spellData = ns.SpellData[spellID]
        local _, rankData = SpellCalc.GetCurrentRank(spellData, state)
        local baseResult = SpellCalc.ComputeBase(spellData, rankData, state)
        local modResult, mods = ModifierCalc.ApplyModifiers(
            baseResult, spellData, state, ns.TalentMap, ns.AuraMap
        )
        local finalResult = CritCalc.ApplyExpectedCrit(modResult, spellData, state, mods)
        return finalResult, modResult, mods, spellData
    end

    ---------------------------------------------------------------------------
    -- ApplyExpectedCrit — direct spells
    ---------------------------------------------------------------------------
    describe("ApplyExpectedCrit for direct spells", function()
        it("should apply crit scaling to Shadow Bolt with 20% crit", function()
            playerState.stats.spellCrit[32] = 0.20
            local result, modResult = runFullChain(686, playerState)

            -- critChance = baseCrit + critBonus = 0.20 + 0 = 0.20
            -- critMultiplier = BASE_CRIT_MULTIPLIER = 1.5
            -- expectedDamage = totalDamage * (1 + 0.20 * 0.5)
            local expectedDamage = modResult.totalDamage * (1 + 0.20 * 0.5)
            assert.is_near(expectedDamage, result.expectedDamage, 0.1)
            assert.is_near(0.20, result.critChance, 0.001)
            assert.is_near(1.5, result.critMultiplier, 0.001)
        end)

        it("should factor in hit chance for Shadow Bolt", function()
            playerState.stats.spellCrit[32] = 0.20
            local result, modResult = runFullChain(686, playerState)

            -- hitChance = 1 - BASE_MISS (0.17) + spellHit (0.03) = 0.86
            local hitChance = 1 - 0.17 + 0.03
            local expectedDamage = modResult.totalDamage * (1 + 0.20 * 0.5)
            local expectedWithMiss = expectedDamage * hitChance

            assert.is_near(hitChance, result.hitProbability, 0.001)
            assert.is_near(expectedWithMiss, result.expectedDamageWithMiss, 0.1)
        end)

        it("should compute correct DPS for Shadow Bolt", function()
            playerState.stats.spellCrit[32] = 0.20
            local result, modResult = runFullChain(686, playerState)

            local hitChance = 0.86
            local expectedDamage = modResult.totalDamage * (1 + 0.20 * 0.5)
            local expectedWithMiss = expectedDamage * hitChance
            -- Shadow Bolt cast time = 3.0s, which is > GCD (1.5s)
            local dps = expectedWithMiss / 3.0

            assert.is_near(dps, result.dps, 0.1)
            assert.is_near(3.0, result.castTime, 0.001)
        end)

        it("should use GCD as minimum cast time for instant spells", function()
            -- Shadowburn is instant (castTime = 0), should use GCD = 1.5
            local result = runFullChain(17877, playerState)

            assert.is_near(1.5, result.castTime, 0.001)
        end)

        it("should set isDot and isChanneled flags correctly for direct spells", function()
            local result = runFullChain(686, playerState)

            assert.is_false(result.isDot)
            assert.is_false(result.isChanneled)
            assert.are.equal("direct", result.spellType)
        end)

        it("should include spell metadata in the result", function()
            local result = runFullChain(686, playerState)

            assert.are.equal("Shadow Bolt", result.spellName)
            assert.are.equal(32, result.school)
            assert.are.equal(27209, result.spellID)
        end)

        it("should include base damage range", function()
            local result = runFullChain(686, playerState)

            assert.is_not_nil(result.baseDamage)
            assert.are.equal(544, result.baseDamage.min)
            assert.are.equal(607, result.baseDamage.max)
        end)

        it("should clamp crit chance to maximum of 1.0", function()
            playerState.stats.spellCrit[32] = 0.95
            -- Add more crit via Devastation 5/5 + Backlash 3/3 = 0.08
            playerState.talents["3:11"] = 5
            playerState.talents["3:21"] = 3
            local result = runFullChain(686, playerState)

            -- Total: 0.95 + 0.05 + 0.03 = 1.03, clamped to 1.0
            assert.is_near(1.0, result.critChance, 0.001)
        end)

        it("should cap hit chance at MAX_SPELL_HIT (0.99)", function()
            playerState.stats.spellHit = 0.20  -- way above cap
            local result = runFullChain(686, playerState)

            -- rawHit = 1 - 0.17 + 0.20 = 1.03, capped at 0.99
            assert.is_near(0.99, result.hitProbability, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- ApplyExpectedCrit — periodic spells (canCrit = false)
    ---------------------------------------------------------------------------
    describe("ApplyExpectedCrit for periodic spells", function()
        it("should not apply crit to Corruption (canCrit = false)", function()
            playerState.stats.spellCrit[32] = 0.30  -- high crit, should be ignored
            local result, modResult = runFullChain(172, playerState)

            assert.is_near(0, result.critChance, 0.001)
            -- expectedDamage = totalDamage * (1 + 0 * 0.5) = totalDamage
            assert.is_near(modResult.totalDamage, result.expectedDamage, 0.1)
        end)

        it("should set isDot flag for Corruption", function()
            local result = runFullChain(172, playerState)

            assert.is_true(result.isDot)
            assert.is_false(result.isChanneled)
            assert.are.equal("dot", result.spellType)
        end)

        it("should include tick and duration info for Corruption", function()
            local result = runFullChain(172, playerState)

            assert.are.equal(6, result.numTicks)
            assert.are.equal(18, result.duration)
            assert.is_not_nil(result.tickDamage)
            assert.is_true(result.tickDamage > 0)
        end)

        it("should compute DPS using castTime + duration for DoTs", function()
            local result, modResult = runFullChain(172, playerState)

            -- Corruption: castTime = 2.0s (> GCD), duration = 18s
            -- dpsDivisor = castTime + duration = 2.0 + 18 = 20
            local hitChance = 0.86
            local expectedWithMiss = modResult.totalDamage * hitChance
            local dps = expectedWithMiss / 20.0

            assert.is_near(dps, result.dps, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- ApplyExpectedCrit — canCrit = false on a direct spell
    ---------------------------------------------------------------------------
    describe("ApplyExpectedCrit for canCrit = false direct spells", function()
        it("should not apply crit to Death Coil even with high crit", function()
            playerState.stats.spellCrit[32] = 0.50
            local result, modResult = runFullChain(6789, playerState)

            assert.is_near(0, result.critChance, 0.001)
            assert.is_near(modResult.totalDamage, result.expectedDamage, 0.1)
        end)

        it("should still apply hit chance to Death Coil", function()
            local result, modResult = runFullChain(6789, playerState)

            local hitChance = 0.86
            local expectedWithMiss = modResult.totalDamage * hitChance
            assert.is_near(hitChance, result.hitProbability, 0.001)
            assert.is_near(expectedWithMiss, result.expectedDamageWithMiss, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- ApplyExpectedCrit — channeled spells
    ---------------------------------------------------------------------------
    describe("ApplyExpectedCrit for channeled spells", function()
        it("should use channel duration as DPS divisor", function()
            local result, modResult = runFullChain(689, playerState)

            -- Drain Life: isChanneled = true, duration = 5
            -- dpsDivisor = duration = 5
            local hitChance = 0.86
            local expectedWithMiss = modResult.totalDamage * hitChance
            local dps = expectedWithMiss / 5.0

            assert.is_near(dps, result.dps, 0.1)
            assert.is_true(result.isChanneled)
        end)

        it("should include tick info for channeled spells", function()
            local result = runFullChain(689, playerState)

            assert.are.equal(5, result.numTicks)
            assert.are.equal(5, result.duration)
            assert.is_not_nil(result.tickDamage)
        end)
    end)

    ---------------------------------------------------------------------------
    -- ApplyExpectedCrit — hybrid spells
    ---------------------------------------------------------------------------
    describe("ApplyExpectedCrit for hybrid spells", function()
        it("should apply crit only to direct portion of Immolate", function()
            playerState.stats.spellCrit[4] = 0.25
            local result = runFullChain(348, playerState)

            -- Direct portion gets crit; DoT portion does not
            assert.is_near(0.25, result.critChance, 0.001)
            assert.are.equal("hybrid", result.spellType)
            assert.is_not_nil(result.directDamage)
            assert.is_not_nil(result.dotDamage)
        end)

        it("should compute DPS using castTime + duration for hybrid spells", function()
            local result = runFullChain(348, playerState)

            -- Immolate: castTime = 2.0, duration = 15
            -- totalDuration = castTime + duration = 2.0 + 15 = 17
            local hitChance = 0.86
            local expectedTotal = result.expectedDamage
            local expectedWithMiss = expectedTotal * hitChance
            local dps = expectedWithMiss / 17.0

            assert.is_near(dps, result.dps, 0.1)
        end)

        it("should include tick info for hybrid spells", function()
            local result = runFullChain(348, playerState)

            assert.are.equal(5, result.numTicks)
            assert.are.equal(15, result.duration)
            assert.is_not_nil(result.tickDamage)
        end)
    end)

    ---------------------------------------------------------------------------
    -- ApplyExpectedCrit — utility spells
    ---------------------------------------------------------------------------
    describe("ApplyExpectedCrit for utility spells", function()
        it("should return dps = 0 for Life Tap", function()
            local result = runFullChain(1454, playerState)

            assert.are.equal(0, result.dps)
        end)

        it("should preserve mana gain and health cost", function()
            local result = runFullChain(1454, playerState)

            assert.is_not_nil(result.manaGain)
            assert.is_true(result.manaGain > 0)
            assert.are.equal(582, result.healthCost)
        end)

        it("should set correct metadata for utility spells", function()
            local result = runFullChain(1454, playerState)

            assert.are.equal("Life Tap", result.spellName)
            assert.are.equal("utility", result.spellType)
            assert.is_false(result.isDot)
            assert.is_false(result.isChanneled)
        end)
    end)
end)
