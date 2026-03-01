-------------------------------------------------------------------------------
-- test_modifiercalc.lua
-- Unit tests for PhDamage Engine.ModifierCalc
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState

describe("ModifierCalc", function()
    local playerState
    local SpellCalc = ns.Engine.SpellCalc
    local ModifierCalc = ns.Engine.ModifierCalc

    before_each(function()
        playerState = makePlayerState()
    end)

    ---------------------------------------------------------------------------
    -- MatchesFilter
    ---------------------------------------------------------------------------
    describe("MatchesFilter", function()
        it("should match Shadow Bolt with school = 32 filter", function()
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local filter = { school = 32 }
            assert.is_true(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should not match Searing Pain with school = 32 filter", function()
            local spellData = ns.SpellData[5676]
            local rankData = spellData.ranks[8]
            local filter = { school = 32 }
            assert.is_false(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should match Searing Pain with school = 4 (Fire) filter", function()
            local spellData = ns.SpellData[5676]
            local rankData = spellData.ranks[8]
            local filter = { school = 4 }
            assert.is_true(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should match Shadow Bolt with spellNames filter containing its name", function()
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local filter = { spellNames = {"Shadow Bolt"} }
            assert.is_true(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should not match Corruption with spellNames = {'Shadow Bolt'}", function()
            local spellData = ns.SpellData[172]
            local rankData = spellData.ranks[8]
            local filter = { spellNames = {"Shadow Bolt"} }
            assert.is_false(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should match Shadow Bolt with spellType = 'direct' filter", function()
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local filter = { spellType = "direct" }
            assert.is_true(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should not match Corruption with spellType = 'direct' filter", function()
            local spellData = ns.SpellData[172]
            local rankData = spellData.ranks[8]
            local filter = { spellType = "direct" }
            assert.is_false(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should match Corruption with spellType = 'dot' filter", function()
            local spellData = ns.SpellData[172]
            local rankData = spellData.ranks[8]
            local filter = { spellType = "dot" }
            assert.is_true(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should match Shadow Bolt with combined school + spellType filter", function()
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local filter = { school = 32, spellType = "direct" }
            assert.is_true(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should not match Corruption with school = 32 + spellType = 'direct'", function()
            local spellData = ns.SpellData[172]
            local rankData = spellData.ranks[8]
            local filter = { school = 32, spellType = "direct" }
            assert.is_false(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should match with schools list filter", function()
            local spellData = ns.SpellData[5676]  -- Searing Pain (Fire = 4)
            local rankData = spellData.ranks[8]
            local filter = { schools = {4, 32} }
            assert.is_true(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should not match when school is absent from schools list", function()
            local spellData = ns.SpellData[686]  -- Shadow Bolt (Shadow = 32)
            local rankData = spellData.ranks[11]
            local filter = { schools = {4, 16} }  -- Fire, Frost
            assert.is_false(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should match with spellID filter on the correct rank", function()
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local filter = { spellID = 27209 }
            assert.is_true(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should not match with spellID filter on a different rank", function()
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local filter = { spellID = 25307 }  -- rank 10 spellID
            assert.is_false(ModifierCalc.MatchesFilter(filter, spellData, rankData))
        end)

        it("should match everything with nil filter", function()
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            assert.is_true(ModifierCalc.MatchesFilter(nil, spellData, rankData))
        end)

        it("should match everything with empty filter table", function()
            local spellData = ns.SpellData[172]
            local rankData = spellData.ranks[8]
            assert.is_true(ModifierCalc.MatchesFilter({}, spellData, rankData))
        end)
    end)

    ---------------------------------------------------------------------------
    -- CreateModAccumulator (tested indirectly via ApplyModifiers with no mods)
    ---------------------------------------------------------------------------
    describe("CreateModAccumulator (via ApplyModifiers with no talents/auras)", function()
        it("should return default accumulator values", function()
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.0, mods.damageMultiplier, 0.001)
            assert.is_near(0.0, mods.talentDamageBonus, 0.001)
            assert.is_near(1.0, mods.directDamageMultiplier, 0.001)
            assert.is_near(1.0, mods.dotDamageMultiplier, 0.001)
            assert.is_near(0.0, mods.coefficientBonus, 0.001)
            assert.is_near(0.0, mods.critBonus, 0.001)
            assert.is_near(0.0, mods.critMultBonus, 0.001)
            assert.is_near(0.0, mods.castTimeReduction, 0.001)
            assert.is_nil(mods.castTimeOverride)
            assert.is_near(0.0, mods.spellHitBonus, 0.001)
            assert.is_near(0.0, mods.flatDamageBonus, 0.001)
            assert.is_near(0.0, mods.spellPowerBonus, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- ApplyModifiers — talent effects
    ---------------------------------------------------------------------------
    describe("ApplyModifiers with talents", function()
        it("should apply Shadow Mastery 5/5 as +0.10 talentDamageBonus on Shadow Bolt", function()
            playerState.talents["1:11"] = 5
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.10, mods.talentDamageBonus, 0.001)
        end)

        it("should scale Shadow Mastery linearly with rank", function()
            playerState.talents["1:11"] = 3
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.06, mods.talentDamageBonus, 0.001)  -- 3 * 0.02
        end)

        it("should apply Contagion 5/5 as +0.05 talentDamageBonus on Corruption", function()
            playerState.talents["1:18"] = 5
            local spellData = ns.SpellData[172]
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.05, mods.talentDamageBonus, 0.001)
        end)

        it("should stack SM 5/5 + Contagion 5/5 additively on Corruption", function()
            playerState.talents["1:11"] = 5  -- +10% Shadow
            playerState.talents["1:18"] = 5  -- +5% Corruption
            local spellData = ns.SpellData[172]
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.15, mods.talentDamageBonus, 0.001)  -- 0.10 + 0.05
        end)

        it("should not apply Contagion to Shadow Bolt (name mismatch)", function()
            playerState.talents["1:18"] = 5
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.0, mods.talentDamageBonus, 0.001)
        end)

        it("should apply Emberstorm 5/5 as +0.10 talentDamageBonus on Searing Pain", function()
            playerState.talents["3:8"] = 5
            local spellData = ns.SpellData[5676]
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.10, mods.talentDamageBonus, 0.001)
        end)

        it("should not apply Emberstorm to Shadow spells", function()
            playerState.talents["3:8"] = 5
            local spellData = ns.SpellData[686]  -- Shadow Bolt (Shadow)
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.0, mods.talentDamageBonus, 0.001)
        end)

        it("should apply Devastation 5/5 as +0.05 critBonus on Shadow Bolt", function()
            playerState.talents["3:11"] = 5
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.05, mods.critBonus, 0.001)
        end)

        it("should apply Bane 5/5 as -0.5 castTimeReduction on Shadow Bolt", function()
            playerState.talents["3:2"] = 5
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local result, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.5, mods.castTimeReduction, 0.001)
            assert.is_near(2.5, result.castTime, 0.001)  -- 3.0 - 0.5
        end)

        it("should apply Improved Searing Pain rank 3 as +0.10 critBonus", function()
            playerState.talents["3:7"] = 3
            local spellData = ns.SpellData[5676]
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.10, mods.critBonus, 0.001)
        end)

        it("should apply Ruin as +0.5 critMultBonus on Shadow Bolt", function()
            playerState.talents["3:9"] = 1
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.5, mods.critMultBonus, 0.001)
        end)

        it("should apply totalDamage multiplier from Shadow Mastery to modified result", function()
            playerState.talents["1:11"] = 5  -- +10% Shadow damage
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local result, _ = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            local expectedTotal = baseResult.totalDamage * 1.10
            assert.is_near(expectedTotal, result.totalDamage, 0.1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- ApplyModifiers — aura effects
    ---------------------------------------------------------------------------
    describe("ApplyModifiers with auras", function()
        it("should apply Misery +5% as damageMultiplier on any spell", function()
            playerState.auras.target[33198] = true
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.05, mods.damageMultiplier, 0.001)
        end)

        it("should apply Misery to Fire spells as well", function()
            playerState.auras.target[33198] = true
            local spellData = ns.SpellData[5676]  -- Searing Pain (Fire)
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.05, mods.damageMultiplier, 0.001)
        end)

        it("should apply Shadow Weaving +10% damageMultiplier on Shadow spells", function()
            playerState.auras.target[15258] = true
            local spellData = ns.SpellData[686]  -- Shadow Bolt
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.10, mods.damageMultiplier, 0.001)
        end)

        it("should not apply Shadow Weaving to Fire spells", function()
            playerState.auras.target[15258] = true
            local spellData = ns.SpellData[5676]  -- Searing Pain (Fire)
            local rankData = spellData.ranks[8]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)

        it("should multiply Misery and Shadow Weaving on Shadow spells", function()
            playerState.auras.target[33198] = true  -- Misery +5%
            playerState.auras.target[15258] = true  -- Shadow Weaving +10%
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            -- Both are multiplicative: 1.05 * 1.10 = 1.155
            assert.is_near(1.155, mods.damageMultiplier, 0.001)
        end)

        it("should not apply alreadyInStats auras (Fel Armor)", function()
            playerState.auras.player[28189] = true  -- Fel Armor R2
            local spellData = ns.SpellData[686]
            local rankData = spellData.ranks[11]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(0.0, mods.spellPowerBonus, 0.001)
        end)

        it("should apply Immolate aura flat damage bonus to Incinerate", function()
            playerState.auras.target[27215] = true  -- Immolate on target
            local spellData = ns.SpellData[29722]   -- Incinerate
            local rankData = spellData.ranks[2]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, playerState)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, playerState, ns.TalentMap, ns.AuraMap
            )

            assert.is_near(120, mods.flatDamageBonus, 0.01)
        end)
    end)
end)
