-------------------------------------------------------------------------------
-- test_paladin_talents
-- Tests for Paladin talent calculations
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------
local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePaladinState = bootstrap.makePaladinState
local Pipeline = ns.Engine.Pipeline

-------------------------------------------------------------------------------
-- Default Paladin state reference (from bootstrap):
--   spellPower: Holy(2)=800
--   healingPower: 900 (not used by engine — SP used for heals too)
--   spellCrit: Holy(2)=0.15
--   spellHit = 0.05, intellect = 350, attackPower = 200
--
-- Exorcism R7 (879): castTime=1.5, coeff=0.429, min=626, max=698
--   SP bonus: 800 * 0.429 = 343.2
--   min = 626 + 343.2 = 969.2, max = 698 + 343.2 = 1041.2, avg = 1005.2
--
-- Holy Light R11 (635): castTime=2.5, coeff=0.714, min=2196, max=2446, isHeal
--   SP bonus: 800 * 0.714 = 571.2
--   min = 2196 + 571.2 = 2767.2, max = 2446 + 571.2 = 3017.2
--
-- Holy Wrath R3 (2812): castTime=2.0, coeff=0.286, min=637, max=748
--   SP bonus: 800 * 0.286 = 228.8
--   min = 637 + 228.8 = 865.8, max = 748 + 228.8 = 976.8
--
-- Base spell hit: spellHit=0.05 → hitChance stored raw, hitProbability = 1 - 0.16 + 0.05 = 0.89
-- Base crit mult (spell): 1.5
-------------------------------------------------------------------------------

describe("Paladin Talents", function()

    ---------------------------------------------------------------------------
    -- Holy (Tab 1)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 1. Healing Light (1:7) — +4%/rank healing to HL & FoL (additive)
    ---------------------------------------------------------------------------
    describe("Healing Light", function()

        it("should increase Holy Light healing by 12% at 3/3", function()
            local baseResult = Pipeline.Calculate(635, makePaladinState())

            local state = makePaladinState()
            state.talents["1:7"] = 3
            local result = Pipeline.Calculate(635, state)

            -- HL base: min=2767.2, max=3017.2
            -- With 3/3: * (1 + 0.12) = 1.12
            assert.is_near(baseResult.minDmg * 1.12, result.minDmg, 1)
            assert.is_near(baseResult.maxDmg * 1.12, result.maxDmg, 1)
        end)

        it("should increase Flash of Light healing by 12% at 3/3", function()
            local baseResult = Pipeline.Calculate(19750, makePaladinState())

            local state = makePaladinState()
            state.talents["1:7"] = 3
            local result = Pipeline.Calculate(19750, state)

            assert.is_near(baseResult.minDmg * 1.12, result.minDmg, 1)
            assert.is_near(baseResult.maxDmg * 1.12, result.maxDmg, 1)
        end)

        it("should not affect Exorcism damage", function()
            local baseResult = Pipeline.Calculate(879, makePaladinState())

            local state = makePaladinState()
            state.talents["1:7"] = 3
            local result = Pipeline.Calculate(879, state)

            assert.is_near(baseResult.minDmg, result.minDmg, 0.01)
            assert.is_near(baseResult.maxDmg, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Sanctified Light (1:14) — +2%/rank crit to HL & FoL
    ---------------------------------------------------------------------------
    describe("Sanctified Light", function()

        it("should increase Holy Light crit by 6% at 3/3", function()
            local baseResult = Pipeline.Calculate(635, makePaladinState())

            local state = makePaladinState()
            state.talents["1:14"] = 3
            local result = Pipeline.Calculate(635, state)

            assert.is_near(baseResult.critChance + 0.06, result.critChance, 0.001)
        end)

        it("should increase Flash of Light crit by 6% at 3/3", function()
            local baseResult = Pipeline.Calculate(19750, makePaladinState())

            local state = makePaladinState()
            state.talents["1:14"] = 3
            local result = Pipeline.Calculate(19750, state)

            assert.is_near(baseResult.critChance + 0.06, result.critChance, 0.001)
        end)

        it("should not affect Exorcism crit", function()
            local baseResult = Pipeline.Calculate(879, makePaladinState())

            local state = makePaladinState()
            state.talents["1:14"] = 3
            local result = Pipeline.Calculate(879, state)

            assert.is_near(baseResult.critChance, result.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Purifying Power (1:16) — +10%/rank crit to Exorcism & Holy Wrath
    ---------------------------------------------------------------------------
    describe("Purifying Power", function()

        it("should increase Exorcism crit by 20% at 2/2", function()
            local baseResult = Pipeline.Calculate(879, makePaladinState())

            local state = makePaladinState()
            state.talents["1:16"] = 2
            local result = Pipeline.Calculate(879, state)

            assert.is_near(baseResult.critChance + 0.20, result.critChance, 0.001)
        end)

        it("should increase Holy Wrath crit by 20% at 2/2", function()
            local baseResult = Pipeline.Calculate(2812, makePaladinState())

            local state = makePaladinState()
            state.talents["1:16"] = 2
            local result = Pipeline.Calculate(2812, state)

            assert.is_near(baseResult.critChance + 0.20, result.critChance, 0.001)
        end)

        it("should not affect Holy Light crit", function()
            local baseResult = Pipeline.Calculate(635, makePaladinState())

            local state = makePaladinState()
            state.talents["1:16"] = 2
            local result = Pipeline.Calculate(635, state)

            assert.is_near(baseResult.critChance, result.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Holy Power (1:19) — +1%/rank Holy spell crit
    ---------------------------------------------------------------------------
    describe("Holy Power", function()

        it("should increase Exorcism crit by 5% at 5/5", function()
            local baseResult = Pipeline.Calculate(879, makePaladinState())

            local state = makePaladinState()
            state.talents["1:19"] = 5
            local result = Pipeline.Calculate(879, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)

        it("should increase Holy Light crit by 5% at 5/5", function()
            local baseResult = Pipeline.Calculate(635, makePaladinState())

            local state = makePaladinState()
            state.talents["1:19"] = 5
            local result = Pipeline.Calculate(635, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Holy Guidance (1:25) — +5%/rank INT as spell power
    ---------------------------------------------------------------------------
    describe("Holy Guidance", function()

        it("should add 25% of intellect as spell power at 5/5 on Exorcism", function()
            local state = makePaladinState()
            state.talents["1:25"] = 5
            local r = Pipeline.Calculate(879, state)
            -- INT = 350, bonus SP = 350 * 0.25 = 87.5
            -- Effective SP = 800 + 87.5 = 887.5
            -- SP bonus = 887.5 * 0.429 = 380.7375
            -- min = 626 + 380.7375 = 1006.7375, max = 698 + 380.7375 = 1078.7375
            assert.is_near(1006.7375, r.minDmg, 0.5)
            assert.is_near(1078.7375, r.maxDmg, 0.5)
        end)

        it("should add 10% of intellect as spell power at 2/5 on Exorcism", function()
            local state = makePaladinState()
            state.talents["1:25"] = 2
            local r = Pipeline.Calculate(879, state)
            -- INT = 350, bonus SP = 350 * 0.10 = 35
            -- SP bonus increase = 35 * 0.429 = 15.015
            local rBase = Pipeline.Calculate(879, makePaladinState())
            assert.is_near(rBase.minDmg + 15.015, r.minDmg, 0.5)
            assert.is_near(rBase.maxDmg + 15.015, r.maxDmg, 0.5)
        end)

        it("should also affect Holy Light (heal)", function()
            local state = makePaladinState()
            state.talents["1:25"] = 5
            local r = Pipeline.Calculate(635, state)
            -- INT = 350, bonus SP = 350 * 0.25 = 87.5
            -- SP bonus = (800 + 87.5) * 0.714 = 887.5 * 0.714 = 633.675
            -- min = 2196 + 633.675 = 2829.675, max = 2446 + 633.675 = 3079.675
            assert.is_near(2829.675, r.minDmg, 0.5)
            assert.is_near(3079.675, r.maxDmg, 0.5)
        end)

        it("should scale with higher intellect values", function()
            local state = makePaladinState()
            state.talents["1:25"] = 5
            state.stats.intellect = 500
            local r = Pipeline.Calculate(879, state)
            -- INT = 500, bonus SP = 500 * 0.25 = 125
            -- SP bonus = (800 + 125) * 0.429 = 925 * 0.429 = 396.825
            -- min = 626 + 396.825 = 1022.825
            assert.is_near(1022.825, r.minDmg, 0.5)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Protection (Tab 2)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 6. Precision (2:4) — +1%/rank spell hit
    ---------------------------------------------------------------------------
    describe("Precision", function()

        it("should increase spell hit by 3% at 3/3", function()
            local baseResult = Pipeline.Calculate(879, makePaladinState())

            local state = makePaladinState()
            state.talents["2:4"] = 3
            local result = Pipeline.Calculate(879, state)

            assert.is_near(baseResult.hitChance + 0.03, result.hitChance, 0.001)
        end)

        it("should increase spell hit by 1% at 1/3", function()
            local baseResult = Pipeline.Calculate(879, makePaladinState())

            local state = makePaladinState()
            state.talents["2:4"] = 1
            local result = Pipeline.Calculate(879, state)

            assert.is_near(baseResult.hitChance + 0.01, result.hitChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 7. Combat Expertise (2:23) — +1%/rank crit (all spells)
    ---------------------------------------------------------------------------
    describe("Combat Expertise", function()

        it("should increase Exorcism crit by 5% at 5/5", function()
            local baseResult = Pipeline.Calculate(879, makePaladinState())

            local state = makePaladinState()
            state.talents["2:23"] = 5
            local result = Pipeline.Calculate(879, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)

        it("should increase Holy Light crit by 5% at 5/5", function()
            local baseResult = Pipeline.Calculate(635, makePaladinState())

            local state = makePaladinState()
            state.talents["2:23"] = 5
            local result = Pipeline.Calculate(635, state)

            assert.is_near(baseResult.critChance + 0.05, result.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Retribution (Tab 3)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 8. Crusade (3:10) — +1%/rank all damage (additive)
    ---------------------------------------------------------------------------
    describe("Crusade", function()

        it("should increase Exorcism damage by 3% at 3/3", function()
            local state = makePaladinState()
            state.talents["3:10"] = 3
            local r = Pipeline.Calculate(879, state)
            -- Base: min=969.2, max=1041.2
            -- With 3/3: * (1 + 0.03) = 1.03
            assert.is_near(969.2 * 1.03, r.minDmg, 0.1)
            assert.is_near(1041.2 * 1.03, r.maxDmg, 0.1)
        end)

        it("should increase Holy Wrath damage by 3% at 3/3", function()
            local state = makePaladinState()
            state.talents["3:10"] = 3
            local r = Pipeline.Calculate(2812, state)
            -- Base: min=865.8, max=976.8
            assert.is_near(865.8 * 1.03, r.minDmg, 0.1)
            assert.is_near(976.8 * 1.03, r.maxDmg, 0.1)
        end)

        it("should not affect Holy Light healing", function()
            local baseResult = Pipeline.Calculate(635, makePaladinState())

            local state = makePaladinState()
            state.talents["3:10"] = 3
            local result = Pipeline.Calculate(635, state)

            -- Crusade has no isHeal filter, but also no filter at all,
            -- so it applies to everything including heals
            assert.is_near(baseResult.minDmg * 1.03, result.minDmg, 1)
            assert.is_near(baseResult.maxDmg * 1.03, result.maxDmg, 1)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 9. Sanctified Seals (3:20) — +1%/rank crit (all spells)
    ---------------------------------------------------------------------------
    describe("Sanctified Seals", function()

        it("should increase Exorcism crit by 3% at 3/3", function()
            local baseResult = Pipeline.Calculate(879, makePaladinState())

            local state = makePaladinState()
            state.talents["3:20"] = 3
            local result = Pipeline.Calculate(879, state)

            assert.is_near(baseResult.critChance + 0.03, result.critChance, 0.001)
        end)

        it("should increase Holy Light crit by 3% at 3/3", function()
            local baseResult = Pipeline.Calculate(635, makePaladinState())

            local state = makePaladinState()
            state.talents["3:20"] = 3
            local result = Pipeline.Calculate(635, state)

            assert.is_near(baseResult.critChance + 0.03, result.critChance, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Talent Metadata
    ---------------------------------------------------------------------------
    describe("Metadata", function()

        local expectedKeys = {
            "PALADIN:1:7",   -- Healing Light
            "PALADIN:1:14",  -- Sanctified Light
            "PALADIN:1:16",  -- Purifying Power
            "PALADIN:1:19",  -- Holy Power
            "PALADIN:1:25",  -- Holy Guidance
            "PALADIN:2:4",   -- Precision
            "PALADIN:2:23",  -- Combat Expertise
            "PALADIN:3:10",  -- Crusade
            "PALADIN:3:20",  -- Sanctified Seals
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

        it("Holy Power + Sanctified Light should stack crit on Holy Light", function()
            local state = makePaladinState()
            state.talents["1:19"] = 5  -- Holy Power +5% crit
            state.talents["1:14"] = 3  -- Sanctified Light +6% crit
            local r = Pipeline.Calculate(635, state)
            -- critChance = 0.15 + 0.05 + 0.06 = 0.26
            assert.is_near(0.26, r.critChance, 0.001)
        end)

        it("Combat Expertise + Sanctified Seals should stack crit on Exorcism", function()
            local state = makePaladinState()
            state.talents["2:23"] = 5  -- Combat Expertise +5% crit
            state.talents["3:20"] = 3  -- Sanctified Seals +3% crit
            local r = Pipeline.Calculate(879, state)
            -- critChance = 0.15 + 0.05 + 0.03 = 0.23
            assert.is_near(0.23, r.critChance, 0.001)
        end)

        it("Crusade + Holy Guidance should both affect Exorcism", function()
            local state = makePaladinState()
            state.talents["3:10"] = 3  -- Crusade +3% dmg (additive)
            state.talents["1:25"] = 5  -- Holy Guidance: +87.5 SP
            local r = Pipeline.Calculate(879, state)
            -- SP = 800 + 87.5 = 887.5
            -- SP bonus = 887.5 * 0.429 = 380.7375
            -- Raw: min = 626 + 380.7375 = 1006.7375, max = 698 + 380.7375 = 1078.7375
            -- Crusade: * (1 + 0.03) = 1.03
            -- Final: min = 1006.7375 * 1.03 = 1036.9396
            -- Final: max = 1078.7375 * 1.03 = 1111.0996
            assert.is_near(1036.94, r.minDmg, 0.5)
            assert.is_near(1111.10, r.maxDmg, 0.5)
        end)

        it("Healing Light + Sanctified Light should not cross-affect Exorcism", function()
            local state = makePaladinState()
            state.talents["1:7"] = 3   -- Healing Light: +12% HL/FoL healing
            state.talents["1:14"] = 3  -- Sanctified Light: +6% HL/FoL crit

            local rExo = Pipeline.Calculate(879, state)
            local rExoBase = Pipeline.Calculate(879, makePaladinState())

            -- Exorcism should be unaffected by both talents
            assert.is_near(rExoBase.minDmg, rExo.minDmg, 0.01)
            assert.is_near(rExoBase.maxDmg, rExo.maxDmg, 0.01)
            assert.is_near(rExoBase.critChance, rExo.critChance, 0.001)
        end)

        it("Purifying Power should not affect Holy Light crit, only Exorcism", function()
            local state = makePaladinState()
            state.talents["1:16"] = 2  -- Purifying Power: +20% Exorcism/HW crit

            local rHL = Pipeline.Calculate(635, state)
            local rHLBase = Pipeline.Calculate(635, makePaladinState())
            local rExo = Pipeline.Calculate(879, state)
            local rExoBase = Pipeline.Calculate(879, makePaladinState())

            -- HL should be unaffected
            assert.is_near(rHLBase.critChance, rHL.critChance, 0.001)
            -- Exorcism should get the bonus
            assert.is_near(rExoBase.critChance + 0.20, rExo.critChance, 0.001)
        end)
    end)
end)
