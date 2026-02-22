-------------------------------------------------------------------------------
-- test_rogue_auras.lua
-- Tests for Rogue aura (buff/debuff) modifiers
--
-- Default Rogue state:
--   AP=2000, meleeCrit=25%, meleeHit=0%, targetArmor=0
--   MH: 130-243 dmg, 2.6 speed, ONE_HAND (normalized 2.4)
--   attackingFromBehind=true
--
-- AP bonus (ONE_HAND): 2000 / 14 * 2.4 = 342.857
-- AP bonus (DAGGER):   2000 / 14 * 1.7 = 242.857
--
-- Base values (no auras/talents):
--   SS R10:  min = 570.857,  max = 683.857
--   BS R10:  min = 896.786,  max = 1027.286  (dagger 100-187, 1.8 speed)
--   Ambush R7: min = 1864.107, max = 2103.357 (dagger)
--   Hemo R4: min = 520.143,  max = 644.443
--   GS R1:   min = 591.071,  max = 732.321
--   Mut R4:  min = 443.857,  max = 530.857   (dagger)
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

-- Base damage constants (no auras, no talents)
local SS_MIN  = 570.857    -- Sinister Strike R10
local SS_MAX  = 683.857
local BS_MIN  = 896.786    -- Backstab R10 (dagger)
local BS_MAX  = 1027.286
local AMB_MIN = 1864.107   -- Ambush R7 (dagger)
local AMB_MAX = 2103.357
local HEMO_MIN = 520.143   -- Hemorrhage R4
local HEMO_MAX = 644.443
local GS_MIN  = 591.071    -- Ghostly Strike R1
local GS_MAX  = 732.321
local MUT_MIN = 443.857    -- Mutilate R4 (dagger)
local MUT_MAX = 530.857

describe("Rogue Auras", function()

    ---------------------------------------------------------------------------
    -- 1. Cold Blood (14177) — +100% CRIT_BONUS (global, all spells)
    -- Base meleeCrit = 0.25; Cold Blood adds 1.00 → 1.25 → capped at 1.00
    ---------------------------------------------------------------------------
    describe("Cold Blood", function()

        it("caps Sinister Strike crit chance at 1.00", function()
            local state = makeRogueState()
            state.auras.player[14177] = true
            local result = Pipeline.Calculate(1752, state)
            -- 0.25 + 1.00 = 1.25, capped to 1.00
            assert.is_true(result.critChance >= 1.0,
                "Expected critChance >= 1.0, got " .. tostring(result.critChance))
        end)

        it("caps Backstab crit chance at 1.00", function()
            local state = makeDaggerRogueState()
            state.auras.player[14177] = true
            local result = Pipeline.Calculate(53, state)
            assert.is_true(result.critChance >= 1.0,
                "Expected critChance >= 1.0, got " .. tostring(result.critChance))
        end)

        it("caps Ambush crit chance at 1.00", function()
            local state = makeDaggerRogueState()
            state.auras.player[14177] = true
            local result = Pipeline.Calculate(8676, state)
            assert.is_true(result.critChance >= 1.0,
                "Expected critChance >= 1.0, got " .. tostring(result.critChance))
        end)

        it("caps Hemorrhage crit chance at 1.00", function()
            local state = makeRogueState()
            state.auras.player[14177] = true
            local result = Pipeline.Calculate(16511, state)
            assert.is_true(result.critChance >= 1.0,
                "Expected critChance >= 1.0, got " .. tostring(result.critChance))
        end)

        it("caps Ghostly Strike crit chance at 1.00", function()
            local state = makeRogueState()
            state.auras.player[14177] = true
            local result = Pipeline.Calculate(14278, state)
            assert.is_true(result.critChance >= 1.0,
                "Expected critChance >= 1.0, got " .. tostring(result.critChance))
        end)

        it("caps Mutilate crit chance at 1.00", function()
            local state = makeDaggerRogueState()
            state.auras.player[14177] = true
            local result = Pipeline.Calculate(1329, state)
            assert.is_true(result.critChance >= 1.0,
                "Expected critChance >= 1.0, got " .. tostring(result.critChance))
        end)

        it("does not change Sinister Strike base damage", function()
            local state = makeRogueState()
            state.auras.player[14177] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN, result.minDmg, 0.01)
            assert.is_near(SS_MAX, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 2. Remorseless Attacks R1 (14143) — +20% CRIT_BONUS
    --    Filtered: SS, BS, Hemo, Ambush, GS, Mutilate
    ---------------------------------------------------------------------------
    describe("Remorseless R1", function()

        it("adds 20% crit to Sinister Strike", function()
            local state = makeRogueState()
            state.auras.player[14143] = true
            local result = Pipeline.Calculate(1752, state)
            -- 0.25 + 0.20 = 0.45
            assert.is_near(0.45, result.critChance, 0.01)
        end)

        it("adds 20% crit to Backstab", function()
            local state = makeDaggerRogueState()
            state.auras.player[14143] = true
            local result = Pipeline.Calculate(53, state)
            assert.is_near(0.45, result.critChance, 0.01)
        end)

        it("adds 20% crit to Hemorrhage", function()
            local state = makeRogueState()
            state.auras.player[14143] = true
            local result = Pipeline.Calculate(16511, state)
            assert.is_near(0.45, result.critChance, 0.01)
        end)

        it("adds 20% crit to Ambush", function()
            local state = makeDaggerRogueState()
            state.auras.player[14143] = true
            local result = Pipeline.Calculate(8676, state)
            assert.is_near(0.45, result.critChance, 0.01)
        end)

        it("adds 20% crit to Ghostly Strike", function()
            local state = makeRogueState()
            state.auras.player[14143] = true
            local result = Pipeline.Calculate(14278, state)
            assert.is_near(0.45, result.critChance, 0.01)
        end)

        it("adds 20% crit to Mutilate", function()
            local state = makeDaggerRogueState()
            state.auras.player[14143] = true
            local result = Pipeline.Calculate(1329, state)
            assert.is_near(0.45, result.critChance, 0.01)
        end)

        it("does NOT affect Eviscerate crit chance", function()
            local state = makeRogueState()
            state.auras.player[14143] = true
            local result = Pipeline.Calculate(2098, state)
            -- Eviscerate uses base meleeCrit (0.25), not affected by Remorseless
            assert.is_near(0.25, result.critChance, 0.01)
        end)

        it("does not change Sinister Strike base damage", function()
            local state = makeRogueState()
            state.auras.player[14143] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN, result.minDmg, 0.01)
            assert.is_near(SS_MAX, result.maxDmg, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 3. Remorseless Attacks R2 (14149) — +40% CRIT_BONUS
    --    Same filter as R1
    ---------------------------------------------------------------------------
    describe("Remorseless R2", function()

        it("adds 40% crit to Sinister Strike", function()
            local state = makeRogueState()
            state.auras.player[14149] = true
            local result = Pipeline.Calculate(1752, state)
            -- 0.25 + 0.40 = 0.65
            assert.is_near(0.65, result.critChance, 0.01)
        end)

        it("adds 40% crit to Backstab", function()
            local state = makeDaggerRogueState()
            state.auras.player[14149] = true
            local result = Pipeline.Calculate(53, state)
            assert.is_near(0.65, result.critChance, 0.01)
        end)

        it("adds 40% crit to Hemorrhage", function()
            local state = makeRogueState()
            state.auras.player[14149] = true
            local result = Pipeline.Calculate(16511, state)
            assert.is_near(0.65, result.critChance, 0.01)
        end)

        it("adds 40% crit to Ambush", function()
            local state = makeDaggerRogueState()
            state.auras.player[14149] = true
            local result = Pipeline.Calculate(8676, state)
            assert.is_near(0.65, result.critChance, 0.01)
        end)

        it("adds 40% crit to Ghostly Strike", function()
            local state = makeRogueState()
            state.auras.player[14149] = true
            local result = Pipeline.Calculate(14278, state)
            assert.is_near(0.65, result.critChance, 0.01)
        end)

        it("adds 40% crit to Mutilate", function()
            local state = makeDaggerRogueState()
            state.auras.player[14149] = true
            local result = Pipeline.Calculate(1329, state)
            assert.is_near(0.65, result.critChance, 0.01)
        end)

        it("does NOT affect Eviscerate crit chance", function()
            local state = makeRogueState()
            state.auras.player[14149] = true
            local result = Pipeline.Calculate(2098, state)
            assert.is_near(0.25, result.critChance, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 4. Shadowstep (36563) — +20% DAMAGE_MULTIPLIER (global)
    ---------------------------------------------------------------------------
    describe("Shadowstep", function()

        it("increases Sinister Strike damage by 20%", function()
            local state = makeRogueState()
            state.auras.player[36563] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN * 1.20, result.minDmg, 0.01)
            assert.is_near(SS_MAX * 1.20, result.maxDmg, 0.01)
        end)

        it("increases Backstab damage by 20%", function()
            local state = makeDaggerRogueState()
            state.auras.player[36563] = true
            local result = Pipeline.Calculate(53, state)
            assert.is_near(BS_MIN * 1.20, result.minDmg, 0.01)
            assert.is_near(BS_MAX * 1.20, result.maxDmg, 0.01)
        end)

        it("increases Ambush damage by 20%", function()
            local state = makeDaggerRogueState()
            state.auras.player[36563] = true
            local result = Pipeline.Calculate(8676, state)
            assert.is_near(AMB_MIN * 1.20, result.minDmg, 0.01)
            assert.is_near(AMB_MAX * 1.20, result.maxDmg, 0.01)
        end)

        it("increases Hemorrhage damage by 20%", function()
            local state = makeRogueState()
            state.auras.player[36563] = true
            local result = Pipeline.Calculate(16511, state)
            assert.is_near(HEMO_MIN * 1.20, result.minDmg, 0.01)
            assert.is_near(HEMO_MAX * 1.20, result.maxDmg, 0.01)
        end)

        it("increases Ghostly Strike damage by 20%", function()
            local state = makeRogueState()
            state.auras.player[36563] = true
            local result = Pipeline.Calculate(14278, state)
            assert.is_near(GS_MIN * 1.20, result.minDmg, 0.01)
            assert.is_near(GS_MAX * 1.20, result.maxDmg, 0.01)
        end)

        it("increases Mutilate damage by 20%", function()
            local state = makeDaggerRogueState()
            state.auras.player[36563] = true
            local result = Pipeline.Calculate(1329, state)
            assert.is_near(MUT_MIN * 1.20, result.minDmg, 0.01)
            assert.is_near(MUT_MAX * 1.20, result.maxDmg, 0.01)
        end)

        it("does not change crit chance", function()
            local state = makeRogueState()
            state.auras.player[36563] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(0.25, result.critChance, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 5. Find Weakness R1-R5 — +2/4/6/8/10% DAMAGE_MULTIPLIER
    ---------------------------------------------------------------------------
    describe("Find Weakness", function()

        it("R1 (31234) adds 2% damage to Sinister Strike", function()
            local state = makeRogueState()
            state.auras.player[31234] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN * 1.02, result.minDmg, 0.01)
            assert.is_near(SS_MAX * 1.02, result.maxDmg, 0.01)
        end)

        it("R2 (31235) adds 4% damage to Sinister Strike", function()
            local state = makeRogueState()
            state.auras.player[31235] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN * 1.04, result.minDmg, 0.01)
            assert.is_near(SS_MAX * 1.04, result.maxDmg, 0.01)
        end)

        it("R3 (31236) adds 6% damage to Sinister Strike", function()
            local state = makeRogueState()
            state.auras.player[31236] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN * 1.06, result.minDmg, 0.01)
            assert.is_near(SS_MAX * 1.06, result.maxDmg, 0.01)
        end)

        it("R4 (31237) adds 8% damage to Sinister Strike", function()
            local state = makeRogueState()
            state.auras.player[31237] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN * 1.08, result.minDmg, 0.01)
            assert.is_near(SS_MAX * 1.08, result.maxDmg, 0.01)
        end)

        it("R5 (31238) adds 10% damage to Sinister Strike", function()
            local state = makeRogueState()
            state.auras.player[31238] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN * 1.10, result.minDmg, 0.01)
            assert.is_near(SS_MAX * 1.10, result.maxDmg, 0.01)
        end)

        it("R5 applies to Backstab", function()
            local state = makeDaggerRogueState()
            state.auras.player[31238] = true
            local result = Pipeline.Calculate(53, state)
            assert.is_near(BS_MIN * 1.10, result.minDmg, 0.01)
            assert.is_near(BS_MAX * 1.10, result.maxDmg, 0.01)
        end)

        it("R5 applies to Ambush", function()
            local state = makeDaggerRogueState()
            state.auras.player[31238] = true
            local result = Pipeline.Calculate(8676, state)
            assert.is_near(AMB_MIN * 1.10, result.minDmg, 0.01)
            assert.is_near(AMB_MAX * 1.10, result.maxDmg, 0.01)
        end)

        it("does not change crit chance", function()
            local state = makeRogueState()
            state.auras.player[31238] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(0.25, result.critChance, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 6. Master of Subtlety (31665) — +10% DAMAGE_MULTIPLIER (hardcoded 3/3)
    ---------------------------------------------------------------------------
    describe("Master of Subtlety", function()

        it("increases Sinister Strike damage by 10%", function()
            local state = makeRogueState()
            state.auras.player[31665] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN * 1.10, result.minDmg, 0.01)
            assert.is_near(SS_MAX * 1.10, result.maxDmg, 0.01)
        end)

        it("increases Backstab damage by 10%", function()
            local state = makeDaggerRogueState()
            state.auras.player[31665] = true
            local result = Pipeline.Calculate(53, state)
            assert.is_near(BS_MIN * 1.10, result.minDmg, 0.01)
            assert.is_near(BS_MAX * 1.10, result.maxDmg, 0.01)
        end)

        it("increases Ambush damage by 10%", function()
            local state = makeDaggerRogueState()
            state.auras.player[31665] = true
            local result = Pipeline.Calculate(8676, state)
            assert.is_near(AMB_MIN * 1.10, result.minDmg, 0.01)
            assert.is_near(AMB_MAX * 1.10, result.maxDmg, 0.01)
        end)

        it("increases Hemorrhage damage by 10%", function()
            local state = makeRogueState()
            state.auras.player[31665] = true
            local result = Pipeline.Calculate(16511, state)
            assert.is_near(HEMO_MIN * 1.10, result.minDmg, 0.01)
            assert.is_near(HEMO_MAX * 1.10, result.maxDmg, 0.01)
        end)

        it("does not change crit chance", function()
            local state = makeRogueState()
            state.auras.player[31665] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(0.25, result.critChance, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 7. Blade Flurry (13877) — empty effects (attack speed, no dmg modifier)
    ---------------------------------------------------------------------------
    describe("Blade Flurry", function()

        it("does NOT change Sinister Strike damage", function()
            local state = makeRogueState()
            state.auras.player[13877] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN, result.minDmg, 0.01)
            assert.is_near(SS_MAX, result.maxDmg, 0.01)
        end)

        it("does NOT change Backstab damage", function()
            local state = makeDaggerRogueState()
            state.auras.player[13877] = true
            local result = Pipeline.Calculate(53, state)
            assert.is_near(BS_MIN, result.minDmg, 0.01)
            assert.is_near(BS_MAX, result.maxDmg, 0.01)
        end)

        it("does NOT change crit chance", function()
            local state = makeRogueState()
            state.auras.player[13877] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(0.25, result.critChance, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- 8. Slice and Dice R1/R2 — empty effects (attack speed, no dmg modifier)
    ---------------------------------------------------------------------------
    describe("Slice and Dice", function()

        it("R1 (5171) does NOT change Sinister Strike damage", function()
            local state = makeRogueState()
            state.auras.player[5171] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN, result.minDmg, 0.01)
            assert.is_near(SS_MAX, result.maxDmg, 0.01)
        end)

        it("R2 (6774) does NOT change Sinister Strike damage", function()
            local state = makeRogueState()
            state.auras.player[6774] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(SS_MIN, result.minDmg, 0.01)
            assert.is_near(SS_MAX, result.maxDmg, 0.01)
        end)

        it("R1 does NOT change crit chance", function()
            local state = makeRogueState()
            state.auras.player[5171] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(0.25, result.critChance, 0.01)
        end)

        it("R2 does NOT change crit chance", function()
            local state = makeRogueState()
            state.auras.player[6774] = true
            local result = Pipeline.Calculate(1752, state)
            assert.is_near(0.25, result.critChance, 0.01)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Stacking Tests
    ---------------------------------------------------------------------------
    describe("Stacking", function()

        -----------------------------------------------------------------------
        -- Aura + Aura: multiplicative damage multipliers
        -----------------------------------------------------------------------
        describe("Aura + Aura (multiplicative)", function()

            it("Shadowstep + Find Weakness R5: 1.20 * 1.10 = 1.32", function()
                local state = makeRogueState()
                state.auras.player[36563] = true   -- Shadowstep +20%
                state.auras.player[31238] = true   -- Find Weakness R5 +10%
                local result = Pipeline.Calculate(1752, state)
                -- 1.20 * 1.10 = 1.32
                assert.is_near(SS_MIN * 1.32, result.minDmg, 0.01)
                assert.is_near(SS_MAX * 1.32, result.maxDmg, 0.01)
            end)

            it("Shadowstep + Master of Subtlety: 1.20 * 1.10 = 1.32", function()
                local state = makeRogueState()
                state.auras.player[36563] = true   -- Shadowstep +20%
                state.auras.player[31665] = true   -- Master of Subtlety +10%
                local result = Pipeline.Calculate(1752, state)
                assert.is_near(SS_MIN * 1.32, result.minDmg, 0.01)
                assert.is_near(SS_MAX * 1.32, result.maxDmg, 0.01)
            end)

            it("Shadowstep + Find Weakness R5 on Backstab", function()
                local state = makeDaggerRogueState()
                state.auras.player[36563] = true   -- Shadowstep +20%
                state.auras.player[31238] = true   -- Find Weakness R5 +10%
                local result = Pipeline.Calculate(53, state)
                assert.is_near(BS_MIN * 1.32, result.minDmg, 0.01)
                assert.is_near(BS_MAX * 1.32, result.maxDmg, 0.01)
            end)
        end)

        -----------------------------------------------------------------------
        -- Aura + Talent: Shadowstep (aura, +20%) + Aggression 3/3 (talent, +6% additive)
        -- Aggression is additive among talents on base, Shadowstep multiplies
        -- SS min = 570.857 * (1 + 0.06) * 1.20 = 570.857 * 1.06 * 1.20
        -----------------------------------------------------------------------
        describe("Aura + Talent", function()

            it("Shadowstep + Aggression 3/3 on Sinister Strike", function()
                local state = makeRogueState()
                state.auras.player[36563] = true           -- Shadowstep +20%
                state.talents["2:19"] = 3                   -- Aggression 3/3 (+6%)
                local result = Pipeline.Calculate(1752, state)
                -- Aggression: additive +6% on base → 1.06
                -- Shadowstep: multiplicative +20% → 1.20
                -- Combined: base * 1.06 * 1.20
                local expected_min = SS_MIN * 1.06 * 1.20
                local expected_max = SS_MAX * 1.06 * 1.20
                assert.is_near(expected_min, result.minDmg, 0.1)
                assert.is_near(expected_max, result.maxDmg, 0.1)
            end)
        end)

        -----------------------------------------------------------------------
        -- Crit stacking: Cold Blood + Malice 5/5
        -- Base meleeCrit (0.25) + Cold Blood (1.00) + Malice 5/5 (0.05)
        -- = 1.30, capped at 1.00
        -----------------------------------------------------------------------
        describe("Crit stacking", function()

            it("Cold Blood + Malice 5/5 caps at 1.00", function()
                local state = makeRogueState()
                state.auras.player[14177] = true       -- Cold Blood +100%
                state.talents["1:3"] = 5                    -- Malice 5/5 (+5%)
                local result = Pipeline.Calculate(1752, state)
                -- 0.25 + 1.00 + 0.05 = 1.30 → capped at 1.00
                assert.is_true(result.critChance >= 1.0,
                    "Expected critChance >= 1.0, got " .. tostring(result.critChance))
            end)

            it("Remorseless R2 + Puncturing Wounds 3/3 on Backstab", function()
                local state = makeDaggerRogueState()
                state.auras.player[14149] = true       -- Remorseless R2 +40%
                state.talents["1:6"] = 3                    -- Puncturing Wounds 3/3 (+30% BS)
                local result = Pipeline.Calculate(53, state)
                -- 0.25 + 0.40 + 0.30 = 0.95
                assert.is_near(0.95, result.critChance, 0.01)
            end)

            it("Remorseless R2 + Puncturing Wounds 3/3 on Mutilate", function()
                local state = makeDaggerRogueState()
                state.auras.player[14149] = true       -- Remorseless R2 +40%
                state.talents["1:6"] = 3                    -- Puncturing Wounds 3/3 (+15% Mut)
                local result = Pipeline.Calculate(1329, state)
                -- 0.25 + 0.40 + 0.15 = 0.80
                assert.is_near(0.80, result.critChance, 0.01)
            end)
        end)
    end)
end)
