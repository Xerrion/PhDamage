-------------------------------------------------------------------------------
-- test_new_spells.lua
-- Comprehensive tests for Phase 3 spells: Death Coil, Shadowfury, Curse of Doom
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

-------------------------------------------------------------------------------
-- Death Coil (base spellID 6789)
-------------------------------------------------------------------------------
describe("Death Coil", function()
    local playerState
    local Pipeline = ns.Engine.Pipeline
    local SpellCalc = ns.Engine.SpellCalc

    before_each(function()
        playerState = makePlayerState()
    end)

    it("should return a result from Pipeline.Calculate", function()
        local result = Pipeline.Calculate(6789, playerState)
        assert.is_not_nil(result)
        assert.are.equal("Death Coil", result.spellName)
        assert.are.equal(32, result.school)  -- SCHOOL_SHADOW
    end)

    it("should have fixed damage: min == max for all ranks", function()
        local spellData = ns.SpellData[6789]
        for rank, rankData in pairs(spellData.ranks) do
            assert.are.equal(rankData.minDmg, rankData.maxDmg,
                string.format("Rank %d should have min == max", rank))
        end
    end)

    it("should have canCrit = false: expectedDamage equals damageAfterMods even with 50% crit", function()
        playerState.stats.spellCrit[32] = 0.50
        local result = Pipeline.Calculate(6789, playerState)
        assert.is_near(result.damageAfterMods, result.expectedDamage, 0.1)
        assert.are.equal(0, result.critChance)
    end)

    it("should apply correct SP scaling: coefficient 0.214", function()
        local result = Pipeline.Calculate(6789, playerState)
        assert.is_near(0.214, result.coefficient, 0.001)
        assert.is_near(0.214 * 1000, result.spellPowerBonus, 0.1)
    end)

    it("should compute Rank 4 (spellID 27223) totalDamage = 519 + 0.214 * 1000 = 733", function()
        -- At level 70, rank 4 is the highest rank (level req 68)
        local result = Pipeline.Calculate(6789, playerState)
        assert.are.equal(4, result.rank)
        assert.are.equal(27223, result.spellID)
        assert.is_near(733, result.damageAfterMods, 0.1)
    end)

    it("should produce baseDamage min == max in pipeline result", function()
        local result = Pipeline.Calculate(6789, playerState)
        assert.are.equal(result.baseDamage.min, result.baseDamage.max)
    end)

    it("should have positive DPS", function()
        local result = Pipeline.Calculate(6789, playerState)
        assert.is_true(result.dps > 0)
    end)

    it("should use GCD (1.5s) as effective cast time for instant spell", function()
        local result = Pipeline.Calculate(6789, playerState)
        assert.is_near(1.5, result.castTime, 0.01)
    end)

    it("should return zero spellPowerBonus with zero SP", function()
        playerState.stats.spellPower[32] = 0
        local result = Pipeline.Calculate(6789, playerState)
        assert.is_near(0, result.spellPowerBonus, 0.01)
        -- With 0 SP, damageAfterMods should be base damage only (519 for R4)
        assert.is_near(519, result.damageAfterMods, 0.1)
    end)
end)

-------------------------------------------------------------------------------
-- Shadowfury (base spellID 30283)
-------------------------------------------------------------------------------
describe("Shadowfury", function()
    local playerState
    local Pipeline = ns.Engine.Pipeline
    local SpellCalc = ns.Engine.SpellCalc

    before_each(function()
        playerState = makePlayerState()
    end)

    it("should return a result from Pipeline.Calculate", function()
        local result = Pipeline.Calculate(30283, playerState)
        assert.is_not_nil(result)
        assert.are.equal("Shadowfury", result.spellName)
        assert.are.equal(32, result.school)  -- SCHOOL_SHADOW
    end)

    it("CAN crit: with 20% crit, expectedDamage should exceed damageAfterMods", function()
        playerState.stats.spellCrit[32] = 0.20
        local result = Pipeline.Calculate(30283, playerState)
        assert.is_true(result.expectedDamage > result.damageAfterMods)
        assert.is_true(result.critChance > 0)
    end)

    it("should use GCD (1.5s) as effective cast time for 0.5s cast", function()
        local result = Pipeline.Calculate(30283, playerState)
        -- 0.5s cast < 1.5s GCD → effective cast = GCD
        assert.is_near(1.5, result.castTime, 0.01)
    end)

    it("should apply correct SP scaling: coefficient 0.193", function()
        local result = Pipeline.Calculate(30283, playerState)
        assert.is_near(0.193, result.coefficient, 0.001)
        assert.is_near(0.193 * 1000, result.spellPowerBonus, 0.1)
    end)

    it("Devastation 5/5 should add +5% crit to Shadowfury", function()
        playerState.talents["3:7"] = 5
        local result = Pipeline.Calculate(30283, playerState)
        -- Base crit = 0.10, Devastation +0.05 = 0.15
        assert.is_near(0.15, result.critChance, 0.001)
    end)

    it("Ruin 1/1 should add +0.5 crit multiplier", function()
        playerState.talents["3:13"] = 1
        local result = Pipeline.Calculate(30283, playerState)
        -- Base crit multiplier = 1.5, Ruin +0.5 = 2.0
        assert.is_near(2.0, result.critMultiplier, 0.001)
    end)

    it("should compute Rank 3 (spellID 30414) damageAfterMods correctly", function()
        -- At level 70, rank 3 is the highest (level req 70)
        local result = Pipeline.Calculate(30283, playerState)
        assert.are.equal(3, result.rank)
        assert.are.equal(30414, result.spellID)
        -- avgBase = (612 + 728) / 2 = 670, spBonus = 0.193 * 1000 = 193
        assert.is_near(863, result.damageAfterMods, 0.1)
    end)

    it("should have positive DPS", function()
        local result = Pipeline.Calculate(30283, playerState)
        assert.is_true(result.dps > 0)
    end)

    it("should be flagged as direct, not DoT or channel", function()
        local result = Pipeline.Calculate(30283, playerState)
        assert.are.equal("direct", result.spellType)
        assert.is_false(result.isDot)
        assert.is_false(result.isChanneled)
    end)

    it("Devastation + Ruin combined should boost expected damage", function()
        -- Without talents
        local r1 = Pipeline.Calculate(30283, playerState)
        -- With talents
        playerState.talents["3:7"] = 5   -- Devastation: +5% crit
        playerState.talents["3:13"] = 1  -- Ruin: +0.5 crit mult
        local r2 = Pipeline.Calculate(30283, playerState)
        assert.is_true(r2.expectedDamage > r1.expectedDamage)
        assert.is_near(0.15, r2.critChance, 0.001)
        assert.is_near(2.0, r2.critMultiplier, 0.001)
    end)
end)

-------------------------------------------------------------------------------
-- Curse of Doom (base spellID 603)
-------------------------------------------------------------------------------
describe("Curse of Doom", function()
    local playerState
    local Pipeline = ns.Engine.Pipeline
    local SpellCalc = ns.Engine.SpellCalc

    before_each(function()
        playerState = makePlayerState()
    end)

    it("should return a result from Pipeline.Calculate", function()
        local result = Pipeline.Calculate(603, playerState)
        assert.is_not_nil(result)
        assert.are.equal("Curse of Doom", result.spellName)
        assert.are.equal(32, result.school)  -- SCHOOL_SHADOW
    end)

    it("should have 60s duration and 1 tick: tickDamage equals expectedDamageWithMiss", function()
        local result = Pipeline.Calculate(603, playerState)
        assert.are.equal(60, result.duration)
        assert.are.equal(1, result.numTicks)
        -- tickDamage should now factor in hit chance
        assert.is_near(result.expectedDamageWithMiss, result.tickDamage, 0.1)
    end)

    it("should have canCrit = false: expectedDamage equals damageAfterMods even with high crit", function()
        playerState.stats.spellCrit[32] = 0.50
        local result = Pipeline.Calculate(603, playerState)
        assert.is_near(result.damageAfterMods, result.expectedDamage, 0.1)
        assert.are.equal(0, result.critChance)
    end)

    it("should apply correct SP scaling: coefficient 2.0", function()
        local result = Pipeline.Calculate(603, playerState)
        assert.is_near(2.0, result.coefficient, 0.001)
        assert.is_near(2.0 * 1000, result.spellPowerBonus, 0.1)
    end)

    it("should compute Rank 2 (spellID 30910) totalDamage = 4200 + 2.0 * 1000 = 6200", function()
        -- At level 70, rank 2 is the highest (level req 70)
        local result = Pipeline.Calculate(603, playerState)
        assert.are.equal(2, result.rank)
        assert.are.equal(30910, result.spellID)
        assert.is_near(6200, result.damageAfterMods, 0.1)
    end)

    it("Shadow Mastery 5/5 should boost damage by +10%", function()
        playerState.stats.spellPower[32] = 0  -- isolate talent effect
        playerState.talents["1:15"] = 5
        local result = Pipeline.Calculate(603, playerState)
        -- baseDmg = 4200, +10% = 4620
        assert.is_near(4620, result.damageAfterMods, 0.1)
        assert.is_near(0.10, result.talentDamageBonus, 0.001)
    end)

    it("should be flagged as DoT, not channel", function()
        local result = Pipeline.Calculate(603, playerState)
        assert.are.equal("dot", result.spellType)
        assert.is_true(result.isDot)
        assert.is_false(result.isChanneled)
    end)

    it("should have positive DPS", function()
        local result = Pipeline.Calculate(603, playerState)
        assert.is_true(result.dps > 0)
    end)

    it("should return zero spellPowerBonus with zero SP", function()
        playerState.stats.spellPower[32] = 0
        local result = Pipeline.Calculate(603, playerState)
        assert.is_near(0, result.spellPowerBonus, 0.01)
        -- With 0 SP, damageAfterMods should be base damage only (4200 for R2)
        assert.is_near(4200, result.damageAfterMods, 0.1)
    end)

    it("should use GCD (1.5s) as effective cast time for instant spell", function()
        local result = Pipeline.Calculate(603, playerState)
        assert.is_near(1.5, result.castTime, 0.01)
    end)
end)
