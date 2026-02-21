-------------------------------------------------------------------------------
-- test_new_talents.lua
-- Comprehensive tests for Improved Immolate, Master Demonologist, Soul Siphon
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

-------------------------------------------------------------------------------
-- Improved Immolate (talent 3:4) — +5% Immolate direct damage per rank
-------------------------------------------------------------------------------
describe("Improved Immolate (3:4)", function()
    local playerState
    local SpellCalc = ns.Engine.SpellCalc
    local ModifierCalc = ns.Engine.ModifierCalc
    local Pipeline = ns.Engine.Pipeline

    before_each(function()
        playerState = makePlayerState()
    end)

    describe("modifier accumulator", function()
        it("5/5 should set directDamageMultiplier to 1.25 on Immolate", function()
            playerState.talents["3:4"] = 5
            local spellData = ns.SpellData[348]
            local rankData = spellData.ranks[9]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.25, mods.directDamageMultiplier, 0.001)
            assert.is_near(1.0, mods.dotDamageMultiplier, 0.001)
            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)

        it("0/5 should leave directDamageMultiplier at default 1.0", function()
            -- No talent set
            local spellData = ns.SpellData[348]
            local rankData = spellData.ranks[9]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.0, mods.directDamageMultiplier, 0.001)
        end)

        it("3/5 should set directDamageMultiplier to 1.15 on Immolate", function()
            playerState.talents["3:4"] = 3
            local spellData = ns.SpellData[348]
            local rankData = spellData.ranks[9]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.15, mods.directDamageMultiplier, 0.001)
        end)

        it("should NOT affect Shadow Bolt (filter is Immolate-only)", function()
            playerState.talents["3:4"] = 5
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.0, mods.directDamageMultiplier, 0.001)
        end)
    end)

    describe("pipeline integration", function()
        it("5/5 should increase Immolate direct portion by 25%, dot unchanged", function()
            -- Calculate without talent
            local r0 = Pipeline.Calculate(348, playerState)

            -- Calculate with talent 5/5
            playerState.talents["3:4"] = 5
            local r5 = Pipeline.Calculate(348, playerState)

            -- Direct portion should be ~1.25x of untalented
            assert.is_near(r0.directDamage * 1.25, r5.directDamage, 0.5)
            -- DoT portion should be identical
            assert.is_near(r0.dotDamage, r5.dotDamage, 0.01)
        end)

        it("3/5 should increase Immolate direct portion by 15%", function()
            local r0 = Pipeline.Calculate(348, playerState)
            playerState.talents["3:4"] = 3
            local r3 = Pipeline.Calculate(348, playerState)

            assert.is_near(r0.directDamage * 1.15, r3.directDamage, 0.5)
            assert.is_near(r0.dotDamage, r3.dotDamage, 0.01)
        end)
    end)
end)

-------------------------------------------------------------------------------
-- Master Demonologist — Succubus (aura 23761) and Felguard (aura 35702)
-------------------------------------------------------------------------------
describe("Master Demonologist", function()
    local playerState
    local SpellCalc = ns.Engine.SpellCalc
    local ModifierCalc = ns.Engine.ModifierCalc
    local Pipeline = ns.Engine.Pipeline

    before_each(function()
        playerState = makePlayerState()
    end)

    describe("Succubus (23761)", function()
        it("aura + talent 5/5 should give +10% damageMultiplier", function()
            playerState.talents["2:16"] = 5
            playerState.auras.player[23761] = true
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            -- Base aura value is 0, talentAmplify adds 0.02 * 5 = 0.10
            assert.is_near(1.10, mods.damageMultiplier, 0.001)
        end)

        it("aura + talent 3/5 should give +6% damageMultiplier", function()
            playerState.talents["2:16"] = 3
            playerState.auras.player[23761] = true
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.06, mods.damageMultiplier, 0.001)
        end)

        it("aura active but talent 0/5 should give no bonus", function()
            -- Talent not set (0/5)
            playerState.auras.player[23761] = true
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            -- Base effect value is 0, and talentAmplify doesn't fire with rank 0
            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)

        it("talent set but no aura should give no bonus", function()
            playerState.talents["2:16"] = 5
            -- No aura active
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)

        it("should apply to all schools (Fire spell too)", function()
            playerState.talents["2:16"] = 5
            playerState.auras.player[23761] = true
            local spellData = ns.SpellData[5676]  -- Searing Pain (Fire)
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.10, mods.damageMultiplier, 0.001)
        end)
    end)

    describe("Felguard (35702)", function()
        it("aura + talent 5/5 should give +5% damageMultiplier", function()
            playerState.talents["2:16"] = 5
            playerState.auras.player[35702] = true
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            -- 0.01 * 5 = 0.05
            assert.is_near(1.05, mods.damageMultiplier, 0.001)
        end)

        it("should differ from Succubus value (0.01 vs 0.02 per rank)", function()
            playerState.talents["2:16"] = 5
            -- Calculate with Felguard aura
            playerState.auras.player[35702] = true
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, modsFg = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            -- Calculate with Succubus aura (separate state)
            local ps2 = makePlayerState()
            ps2.talents["2:16"] = 5
            ps2.auras.player[23761] = true
            local baseResult2 = SpellCalc.ComputeBase(spellData, rankData, ps2)
            local _, modsSu = ModifierCalc.ApplyModifiers(
                baseResult2, spellData, ps2, ns.TalentMap, ns.AuraMap
            )

            -- Felguard +5% vs Succubus +10%
            assert.is_near(1.05, modsFg.damageMultiplier, 0.001)
            assert.is_near(1.10, modsSu.damageMultiplier, 0.001)
            assert.is_true(modsSu.damageMultiplier > modsFg.damageMultiplier)
        end)
    end)

    describe("pipeline integration", function()
        it("Succubus 5/5 should boost Shadow Bolt total damage by 10%", function()
            local r0 = Pipeline.Calculate(686, playerState)

            playerState.talents["2:16"] = 5
            playerState.auras.player[23761] = true
            local r5 = Pipeline.Calculate(686, playerState)

            assert.is_near(r0.damageAfterMods * 1.10, r5.damageAfterMods, 0.5)
        end)
    end)
end)

-------------------------------------------------------------------------------
-- Soul Siphon (talent 1:5) — count-based multiplier for Drain Life/Drain Soul
-------------------------------------------------------------------------------
describe("Soul Siphon (1:5)", function()
    local playerState
    local SpellCalc = ns.Engine.SpellCalc
    local ModifierCalc = ns.Engine.ModifierCalc
    local Pipeline = ns.Engine.Pipeline

    before_each(function()
        playerState = makePlayerState()
    end)

    describe("modifier accumulator (Drain Life)", function()
        local function getMods(talentRank, afflictionCount)
            playerState.talents["1:5"] = talentRank
            playerState.afflictionCountOnTarget = afflictionCount
            local spellData = ns.SpellData[689]  -- Drain Life
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )
            return mods
        end

        it("rank 2 with 3 afflictions should give +12% damageMultiplier", function()
            local mods = getMods(2, 3)
            -- 3 * 0.04 = 0.12 → damageMultiplier = 1.0 * (1 + 0.12) = 1.12
            assert.is_near(1.12, mods.damageMultiplier, 0.001)
        end)

        it("rank 2 with 15 afflictions should be capped at +60%", function()
            local mods = getMods(2, 15)
            -- 15 * 0.04 = 0.60, cap = 0.60 → 1.60
            assert.is_near(1.60, mods.damageMultiplier, 0.001)
        end)

        it("rank 2 with 20 afflictions should still be capped at +60%", function()
            local mods = getMods(2, 20)
            -- 20 * 0.04 = 0.80, cap = 0.60 → 1.60
            assert.is_near(1.60, mods.damageMultiplier, 0.001)
        end)

        it("rank 1 with 15 afflictions should be capped at +24%", function()
            local mods = getMods(1, 15)
            -- 15 * 0.02 = 0.30, cap = 0.24 → 1.24
            assert.is_near(1.24, mods.damageMultiplier, 0.001)
        end)

        it("rank 1 with 5 afflictions should give +10%", function()
            local mods = getMods(1, 5)
            -- 5 * 0.02 = 0.10 → 1.10
            assert.is_near(1.10, mods.damageMultiplier, 0.001)
        end)

        it("rank 2 with 0 afflictions should give no bonus", function()
            local mods = getMods(2, 0)
            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)

        it("rank 0 (untalented) with 5 afflictions should give no bonus", function()
            -- Talent rank 0 means talent not taken; should not be in playerState.talents
            -- at all, but even if set to 0 the talent loop skips rank <= 0
            playerState.afflictionCountOnTarget = 5
            local spellData = ns.SpellData[689]
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )
            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)
    end)

    describe("spell filtering", function()
        it("should NOT affect Shadow Bolt (filter is Drain Life/Drain Soul only)", function()
            playerState.talents["1:5"] = 2
            playerState.afflictionCountOnTarget = 5
            local spellData = ns.SpellData[686]  -- Shadow Bolt
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)

        it("should affect Drain Soul", function()
            playerState.talents["1:5"] = 2
            playerState.afflictionCountOnTarget = 3
            local spellData = ns.SpellData[1120]  -- Drain Soul
            local rankData = spellData.ranks[5]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            -- 3 * 0.04 = 0.12 → 1.12
            assert.is_near(1.12, mods.damageMultiplier, 0.001)
        end)

        it("should NOT affect Corruption", function()
            playerState.talents["1:5"] = 2
            playerState.afflictionCountOnTarget = 5
            local spellData = ns.SpellData[172]  -- Corruption
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)
    end)

    describe("pipeline integration", function()
        it("rank 2 + 3 afflictions should increase Drain Life damage by 12%", function()
            local r0 = Pipeline.Calculate(689, playerState)

            playerState.talents["1:5"] = 2
            playerState.afflictionCountOnTarget = 3
            local r1 = Pipeline.Calculate(689, playerState)

            assert.is_near(r0.damageAfterMods * 1.12, r1.damageAfterMods, 0.5)
        end)

        it("rank 2 + 15 afflictions should cap Drain Life at +60%", function()
            local r0 = Pipeline.Calculate(689, playerState)

            playerState.talents["1:5"] = 2
            playerState.afflictionCountOnTarget = 15
            local r1 = Pipeline.Calculate(689, playerState)

            assert.is_near(r0.damageAfterMods * 1.60, r1.damageAfterMods, 0.5)
        end)

        it("rank 1 + 12 afflictions should cap Drain Life at +24%", function()
            local r0 = Pipeline.Calculate(689, playerState)

            playerState.talents["1:5"] = 1
            playerState.afflictionCountOnTarget = 12
            local r1 = Pipeline.Calculate(689, playerState)

            -- 12 * 0.02 = 0.24, cap = 0.24 → exactly at cap
            assert.is_near(r0.damageAfterMods * 1.24, r1.damageAfterMods, 0.5)
        end)

        it("Drain Soul pipeline with rank 2 + 3 afflictions", function()
            local r0 = Pipeline.Calculate(1120, playerState)

            playerState.talents["1:5"] = 2
            playerState.afflictionCountOnTarget = 3
            local r1 = Pipeline.Calculate(1120, playerState)

            assert.is_near(r0.damageAfterMods * 1.12, r1.damageAfterMods, 0.5)
        end)

        it("Shadow Bolt pipeline should be unaffected by Soul Siphon", function()
            playerState.talents["1:5"] = 2
            playerState.afflictionCountOnTarget = 10
            local r0 = Pipeline.Calculate(686, makePlayerState())
            local r1 = Pipeline.Calculate(686, playerState)

            assert.is_near(r0.damageAfterMods, r1.damageAfterMods, 0.01)
        end)
    end)
end)

-------------------------------------------------------------------------------
-- Demonic Tactics (talent 2:19) — +1% crit per rank, 5 ranks max
-------------------------------------------------------------------------------
describe("Demonic Tactics", function()
    local playerState
    local SpellCalc = ns.Engine.SpellCalc
    local ModifierCalc = ns.Engine.ModifierCalc
    local Pipeline = ns.Engine.Pipeline

    before_each(function()
        playerState = makePlayerState()
    end)

    describe("modifier accumulation", function()
        it("should add 1% crit at rank 1", function()
            playerState.talents["2:19"] = 1
            -- Test with Shadow Bolt (686)
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[1]
            local base = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                base, spellData, playerState, ns.TalentMap, ns.AuraMap
            )
            assert.is_near(0.01, mods.critBonus, 0.001)
        end)

        it("should add 3% crit at rank 3", function()
            playerState.talents["2:19"] = 3
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[1]
            local base = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                base, spellData, playerState, ns.TalentMap, ns.AuraMap
            )
            assert.is_near(0.03, mods.critBonus, 0.001)
        end)

        it("should add 5% crit at rank 5", function()
            playerState.talents["2:19"] = 5
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[1]
            local base = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                base, spellData, playerState, ns.TalentMap, ns.AuraMap
            )
            assert.is_near(0.05, mods.critBonus, 0.001)
        end)

        it("should apply to fire spells too (no filter)", function()
            playerState.talents["2:19"] = 5
            -- Test with Searing Pain (5676) - fire spell
            local spellData = ns.SpellData[5676]
            local rankData = spellData.ranks[1]
            local base = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                base, spellData, playerState, ns.TalentMap, ns.AuraMap
            )
            assert.is_near(0.05, mods.critBonus, 0.001)
        end)
    end)

    describe("pipeline integration", function()
        it("should increase expected damage with crit bonus", function()
            -- Without talent
            local resultBase = Pipeline.Calculate(686, playerState)
            -- With talent rank 5
            playerState.talents["2:19"] = 5
            local resultTalent = Pipeline.Calculate(686, playerState)
            assert.is_true(resultTalent.expectedDamage > resultBase.expectedDamage)
            assert.is_near(resultBase.critChance + 0.05, resultTalent.critChance, 0.001)
        end)

        it("should stack with Devastation crit bonus", function()
            -- Devastation (3:7) gives +5% crit to shadow/fire
            playerState.talents["3:7"] = 5
            local resultDev = Pipeline.Calculate(686, playerState)
            -- Add Demonic Tactics rank 5
            playerState.talents["2:19"] = 5
            local resultBoth = Pipeline.Calculate(686, playerState)
            -- Should have +10% total crit bonus
            assert.is_near(resultDev.critChance + 0.05, resultBoth.critChance, 0.001)
        end)

        it("should affect Shadow Bolt expected damage correctly", function()
            playerState.talents["2:19"] = 3  -- +3% crit
            local result = Pipeline.Calculate(686, playerState)
            -- Base crit is 0.10 (from playerState), +0.03 from talent = 0.13
            assert.is_near(0.13, result.critChance, 0.001)
        end)

        it("should affect Immolate (hybrid) crit", function()
            playerState.talents["2:19"] = 2  -- +2% crit
            local result = Pipeline.Calculate(348, playerState)
            assert.is_near(0.12, result.critChance, 0.001)
        end)

        it("should not affect canCrit=false spells (Corruption)", function()
            playerState.talents["2:19"] = 5
            local result = Pipeline.Calculate(172, playerState)
            -- Corruption has canCrit=false, so critChance should be 0
            assert.are.equal(0, result.critChance)
        end)
    end)
end)
