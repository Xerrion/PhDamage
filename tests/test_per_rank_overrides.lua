-------------------------------------------------------------------------------
-- test_per_rank_overrides.lua
-- Locks in the engine's per-rank coefficient precedence behavior.
--
-- The engine reads `rankData.coefficient` (or directCoefficient/dotCoefficient
-- on hybrids; apCoefficient on AP-scaling melee) before falling back to the
-- spell-level value. This is required for TBC sub-cap-level penalty ranks
-- where Wowhead reports a lower SP mod than the top-rank flat value.
--
-- Critical guard: ComputeMeleeDirect must NOT use rank.coefficient for AP
-- scaling - it strictly uses apCoefficient. This locks in the post-revert
-- behavior; see PR #46.
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local SpellCalc = ns.Engine.SpellCalc
local Pipeline = ns.Engine.Pipeline

describe("Per-rank coefficient overrides", function()

    ---------------------------------------------------------------------------
    -- 1. Direct-damage path: Frostbolt R4
    -- Spell-level coefficient: 0.814 (top rank).
    -- Rank 4 override: coefficient = 0.706 (Wowhead spell=7322).
    -- Expected SP bonus with 1000 Frost SP = 706.
    ---------------------------------------------------------------------------
    describe("Direct path (ComputeDirect)", function()
        it("Frostbolt R4 uses rank coefficient 0.706, not spell-level 0.814", function()
            local state = bootstrap.makeMageState()
            local r = Pipeline.Calculate(116, state, 4)
            assert.is_not_nil(r)
            -- R4: level=20, maxLevel=25. spellLevel=20 means LvlPenalty = 0.
            -- cMaNGOS-TBC penalty (20, 25, 70):
            --   LvlPenalty = 0 (only applies when spellLevel < 20)
            --   LvlFactor  = (25+6)/70 = 0.44286
            --   penalty    = 0.44286
            -- min = 78 + 1000*0.706*0.44286 = 390.66
            -- max = 87 + 1000*0.706*0.44286 = 399.66
            assert.is_near(390.66, r.minDmg, 1)
            assert.is_near(399.66, r.maxDmg, 1)
            -- The reported coefficient is the raw rank override; penalty is applied
            -- by the engine downstream, so r.coefficient must remain 0.706.
            assert.is_near(0.706, r.coefficient, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Caster DoT path: Shadow Word: Pain R1
    -- Spell-level coefficient: 1.098 (top rank).
    -- Rank 1 override: coefficient = 0.4392 (Wowhead spell=589).
    -- Expected SP bonus with 1000 Shadow SP = 439.2.
    ---------------------------------------------------------------------------
    describe("DoT path (ComputeDot)", function()
        it("Shadow Word: Pain R1 uses rank coefficient 0.4392, not spell-level 1.098", function()
            local state = bootstrap.makePriestState()
            local r = Pipeline.Calculate(589, state, 1)
            assert.is_not_nil(r)
            -- R1: level=4, maxLevel=9. cMaNGOS-TBC penalty (4, 9, 70):
            --   LvlPenalty = (20-4)*3.75 = 60
            --   LvlFactor  = (9+6)/70    = 0.21429
            --   penalty    = (100-60)*0.21429/100 = 0.085714
            -- totalDmg = 30 + 1000*0.4392*0.085714 = 67.6457
            -- tickDmg  = 67.6457/6 = 11.27
            assert.is_near(67.6457, r.totalDmg, 0.01)
            assert.is_near(11.27, r.tickDmg, 0.01)
            assert.is_near(0.4392, r.coefficient, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Channel path: Drain Soul R1
    -- Spell-level coefficient: 2.145 (top rank).
    -- Rank 1 override: coefficient = 1.34 (Wowhead spell=1120).
    -- Expected SP bonus with 1000 Shadow SP = 1340.
    ---------------------------------------------------------------------------
    describe("Channel path (ComputeChannel)", function()
        it("Drain Soul R1 uses rank coefficient 1.34, not spell-level 2.145", function()
            local state = bootstrap.makePlayerState()  -- Warlock with Shadow SP=1000
            local r = Pipeline.Calculate(1120, state, 1)
            assert.is_not_nil(r)
            -- R1: level=10, maxLevel=23. cMaNGOS-TBC penalty (10, 23, 70):
            --   LvlPenalty = (20-10)*3.75 = 37.5
            --   LvlFactor  = (23+6)/70    = 0.41429
            --   penalty    = (100-37.5)*0.41429/100 = 0.258929
            -- totalDmg = 55 + 1000*1.34*0.258929 = 401.96
            -- tickDmg  = 401.96/5 = 80.39
            assert.is_near(401.96, r.totalDmg, 1)
            assert.is_near(80.39, r.tickDmg, 1)
            assert.is_near(1.34, r.coefficient, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Hybrid path: Moonfire R3
    -- Spell-level: directCoefficient = 0.15, dotCoefficient = 0.52.
    -- Rank 3 overrides: directCoefficient = 0.128, dotCoefficient = 0.444.
    ---------------------------------------------------------------------------
    describe("Hybrid path (ComputeHybrid)", function()
        it("Moonfire R3 uses rank directCoefficient 0.128 and dotCoefficient 0.444", function()
            local state = bootstrap.makeDruidState()
            -- Druid bootstrap state: Arcane SP[64]=800
            local r = Pipeline.Calculate(8921, state, 3)
            assert.is_not_nil(r)
            -- Direct: 30-30 + 800*0.128 = 132.4 each
            assert.is_near(132.4, r.directMin, 0.1)
            assert.is_near(132.4, r.directMax, 0.1)
            -- DoT: 52 + 800*0.444 = 407.2 total
            assert.is_near(407.2, r.dotTotalDmg, 0.1)
            -- Engine reports per-rank coefficients on the result
            assert.is_near(0.128, r.directCoefficient, 0.001)
            assert.is_near(0.444, r.dotCoefficient, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Fall-through: Arcane Missiles R11
    -- No per-rank coefficient on R11; engine should use spell-level 1.43.
    ---------------------------------------------------------------------------
    describe("Fall-through to spell-level coefficient", function()
        it("Arcane Missiles R11 (no per-rank field) uses spell-level 1.43", function()
            local state = bootstrap.makeMageState()
            local r = Pipeline.Calculate(5143, state, 11)
            assert.is_not_nil(r)
            -- R11: 1430 base + 1000*1.43 = 2860
            assert.is_near(2860, r.totalDmg, 1)
            assert.is_near(1.43, r.coefficient, 0.001)
            -- Sanity: the rank itself MUST NOT carry an override field, otherwise
            -- this test would be testing an override path rather than fall-through.
            local rank11 = ns.SpellData[5143].ranks[11]
            assert.is_nil(rank11.coefficient,
                "R11 must not declare a per-rank coefficient for this fall-through test")
        end)
    end)

    ---------------------------------------------------------------------------
    -- 6. MeleeDirect SP-vs-AP guard.
    -- Construct a synthetic spell with BOTH rank.coefficient (SP-style) AND
    -- spellData.apCoefficient (AP-style). The engine must use apCoefficient
    -- (0.1), NOT rank.coefficient (0.5). This locks in the post-revert
    -- behavior: rank.coefficient is reserved for SP-scaling spells and must
    -- never bleed into the melee/AP path.
    ---------------------------------------------------------------------------
    describe("MeleeDirect SP-vs-AP guard", function()
        it("ComputeMeleeDirect ignores rank.coefficient; uses apCoefficient only", function()
            local fakeSpell = {
                name = "Synthetic AP Spell",
                school = ns.SCHOOL_PHYSICAL or 1,
                spellType = "direct",
                scalingType = "melee",
                apCoefficient = 0.1,         -- AP-style coefficient
                castTime = 0,
                canCrit = true,
                ranks = {
                    [1] = {
                        spellID = 999001,
                        minDmg = 100,
                        maxDmg = 100,
                        coefficient = 0.5,   -- SP-style; MUST be ignored on melee path
                        level = 1,
                    },
                },
            }
            local state = {
                level = 70,
                stats = {
                    spellPower = {},
                    attackPower = 1000,
                    mainHandWeaponType = "ONE_HAND",
                },
            }

            local r = SpellCalc.ComputeMeleeDirect(fakeSpell, fakeSpell.ranks[1], state)
            assert.is_not_nil(r)
            -- AP path: 100 + 1000*0.1 = 200 (NOT 100 + 1000*0.5 = 600).
            assert.is_near(200, r.totalDamage, 0.01)
            assert.is_near(0.1, r.coefficient, 0.001)
        end)

        it("ComputeMeleeDirect respects rank.apCoefficient override", function()
            local fakeSpell = {
                name = "Synthetic AP Spell with rank override",
                school = ns.SCHOOL_PHYSICAL or 1,
                spellType = "direct",
                scalingType = "melee",
                apCoefficient = 0.1,
                castTime = 0,
                canCrit = true,
                ranks = {
                    [1] = {
                        spellID = 999002,
                        minDmg = 100,
                        maxDmg = 100,
                        apCoefficient = 0.25,   -- per-rank AP override
                        coefficient = 0.5,      -- SP-style red herring; must be ignored
                        level = 1,
                    },
                },
            }
            local state = {
                level = 70,
                stats = {
                    spellPower = {},
                    attackPower = 1000,
                    mainHandWeaponType = "ONE_HAND",
                },
            }

            local r = SpellCalc.ComputeMeleeDirect(fakeSpell, fakeSpell.ranks[1], state)
            -- 100 + 1000 * 0.25 = 350
            assert.is_near(350, r.totalDamage, 0.01)
            assert.is_near(0.25, r.coefficient, 0.001)
        end)
    end)
end)
