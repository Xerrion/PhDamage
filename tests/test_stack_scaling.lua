-------------------------------------------------------------------------------
-- test_stack_scaling.lua
-- Verifies stack-aware aura scaling: ModifierCalc multiplies aura values by
-- (applications / maxStacks) for entries that declare a maxStacks field.
--
-- Covered auras:
--   17800 / 17803 - Shadow Vulnerability  (5 stacks, +4% per stack, +20% max)
--   15258         - Shadow Weaving        (5 stacks, +2% per stack, +10% max)
--   22959         - Fire Vulnerability    (5 stacks, +3% per stack, +15% max)
--   29203         - Healing Way           (3 stacks, +6% per stack, +18% max)
--
-- Also verifies:
--   - Stacks above maxStacks clamp to maxStacks (no over-application).
--   - Legacy boolean `true` writes coerce to 1 stack (back-compat).
--   - Auras without maxStacks are unaffected by stack count.
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns
local makePlayerState = bootstrap.makePlayerState
local makeMageState = bootstrap.makeMageState
local makePriestState = bootstrap.makePriestState
local makeShamanState = bootstrap.makeShamanState

local SpellCalc = ns.Engine.SpellCalc
local ModifierCalc = ns.Engine.ModifierCalc
local Pipeline = ns.Engine.Pipeline

-- Helper: run ApplyModifiers for Shadow Bolt (686) and return the multiplier accumulator.
local function shadowBoltMods(state)
    local spellData = ns.SpellData[686]
    local rankData = spellData.ranks[11]
    local baseResult = SpellCalc.ComputeBase(spellData, rankData, state)
    local _, mods = ModifierCalc.ApplyModifiers(
        baseResult, spellData, state, ns.TalentMap, ns.AuraMap
    )
    return mods
end

describe("Stack-aware aura scaling", function()

    ---------------------------------------------------------------------------
    -- Shadow Vulnerability (Improved Shadow Bolt, Warlock, 5 stacks, +20% max)
    ---------------------------------------------------------------------------
    describe("Shadow Vulnerability (17800)", function()
        local cases = {
            { stacks = 1, expected = 1.04 },
            { stacks = 2, expected = 1.08 },
            { stacks = 3, expected = 1.12 },
            { stacks = 4, expected = 1.16 },
            { stacks = 5, expected = 1.20 },
        }

        for _, c in ipairs(cases) do
            it("scales linearly: " .. c.stacks .. " stacks -> "
                    .. string.format("%.2f", c.expected) .. "x", function()
                local state = makePlayerState()
                state.auras.target[17800] = c.stacks
                local mods = shadowBoltMods(state)
                assert.is_near(c.expected, mods.damageMultiplier, 0.001)
            end)
        end

        it("clamps stacks above maxStacks to the at-max value", function()
            local state = makePlayerState()
            state.auras.target[17800] = 6  -- impossible in-game, defensive only
            local mods = shadowBoltMods(state)
            assert.is_near(1.20, mods.damageMultiplier, 0.001)
        end)

        it("treats legacy boolean true as 1 stack (back-compat)", function()
            local state = makePlayerState()
            state.auras.target[17800] = true
            local mods = shadowBoltMods(state)
            assert.is_near(1.04, mods.damageMultiplier, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Shadow Vulnerability alternate spellID (17803)
    ---------------------------------------------------------------------------
    describe("Shadow Vulnerability alternate (17803)", function()
        it("scales identically to 17800 at 3 stacks", function()
            local state = makePlayerState()
            state.auras.target[17803] = 3
            local mods = shadowBoltMods(state)
            assert.is_near(1.12, mods.damageMultiplier, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Shadow Weaving (Priest, 5 stacks, +10% max)
    ---------------------------------------------------------------------------
    describe("Shadow Weaving (15258)", function()
        it("delivers +2% at 1 stack", function()
            local state = makePlayerState()
            state.auras.target[15258] = 1
            local mods = shadowBoltMods(state)
            assert.is_near(1.02, mods.damageMultiplier, 0.001)
        end)

        it("delivers +6% at 3 stacks", function()
            local state = makePlayerState()
            state.auras.target[15258] = 3
            local mods = shadowBoltMods(state)
            assert.is_near(1.06, mods.damageMultiplier, 0.001)
        end)

        it("delivers +10% at 5 stacks (max)", function()
            local state = makePlayerState()
            state.auras.target[15258] = 5
            local mods = shadowBoltMods(state)
            assert.is_near(1.10, mods.damageMultiplier, 0.001)
        end)

        it("multiplies multiplicatively with Shadow Vulnerability", function()
            -- Both scale independently then combine: (1 + 0.04*3/5*5) * (1 + 0.10*3/5)
            -- Shadow Vuln 5 stacks = 1.20, Shadow Weaving 3 stacks = 1.06
            local state = makePlayerState()
            state.auras.target[17800] = 5
            state.auras.target[15258] = 3
            local mods = shadowBoltMods(state)
            assert.is_near(1.20 * 1.06, mods.damageMultiplier, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Fire Vulnerability / Improved Scorch (Mage, 5 stacks, +15% max)
    ---------------------------------------------------------------------------
    describe("Fire Vulnerability (22959)", function()
        local function fireballMods(state)
            local spellData = ns.SpellData[133]  -- Fireball R1 (any rank works for mods)
            local rankData = spellData.ranks[1]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, state)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, state, ns.TalentMap, ns.AuraMap
            )
            return mods
        end

        it("delivers +3% at 1 stack on Fire spells", function()
            local state = makeMageState()
            state.auras.target[22959] = 1
            local mods = fireballMods(state)
            assert.is_near(1.03, mods.damageMultiplier, 0.001)
        end)

        it("delivers +15% at 5 stacks (max) on Fire spells", function()
            local state = makeMageState()
            state.auras.target[22959] = 5
            local mods = fireballMods(state)
            assert.is_near(1.15, mods.damageMultiplier, 0.001)
        end)

        it("does not affect non-Fire spells (Frostbolt)", function()
            local state = makeMageState()
            state.auras.target[22959] = 5
            local spellData = ns.SpellData[116]  -- Frostbolt R1
            local rankData = spellData.ranks[1]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, state)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, state, ns.TalentMap, ns.AuraMap
            )
            assert.is_near(1.0, mods.damageMultiplier, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Healing Way (Shaman, 3 stacks, +18% max on Healing Wave only)
    ---------------------------------------------------------------------------
    describe("Healing Way (29203)", function()
        local function healingWaveMods(state)
            local spellData = ns.SpellData[331]  -- Healing Wave (any rank)
            local rankData = spellData.ranks[#spellData.ranks]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, state)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, state, ns.TalentMap, ns.AuraMap
            )
            return mods
        end

        it("delivers +6% at 1 stack", function()
            local state = makeShamanState()
            state.auras.target[29203] = 1
            local mods = healingWaveMods(state)
            assert.is_near(1.06, mods.damageMultiplier, 0.001)
        end)

        it("delivers +12% at 2 stacks", function()
            local state = makeShamanState()
            state.auras.target[29203] = 2
            local mods = healingWaveMods(state)
            assert.is_near(1.12, mods.damageMultiplier, 0.001)
        end)

        it("delivers +18% at 3 stacks (max)", function()
            local state = makeShamanState()
            state.auras.target[29203] = 3
            local mods = healingWaveMods(state)
            assert.is_near(1.18, mods.damageMultiplier, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Non-stacking aura: behavior is unchanged regardless of stack count.
    -- Curse of the Elements R4 (27228) has no maxStacks - should be flat +10%.
    ---------------------------------------------------------------------------
    describe("Non-stacking aura (no maxStacks)", function()
        local function fireballMods(state)
            local spellData = ns.SpellData[133]
            local rankData = spellData.ranks[1]
            local baseResult = SpellCalc.ComputeBase(spellData, rankData, state)
            local _, mods = ModifierCalc.ApplyModifiers(
                baseResult, spellData, state, ns.TalentMap, ns.AuraMap
            )
            return mods
        end

        it("delivers full value with 1 application", function()
            local state = makeMageState()
            state.auras.target[27228] = 1
            local mods = fireballMods(state)
            assert.is_near(1.10, mods.damageMultiplier, 0.001)
        end)

        it("delivers full value with legacy boolean", function()
            local state = makeMageState()
            state.auras.target[27228] = true
            local mods = fireballMods(state)
            assert.is_near(1.10, mods.damageMultiplier, 0.001)
        end)

        it("ignores artificially high stack counts", function()
            local state = makeMageState()
            state.auras.target[27228] = 99
            local mods = fireballMods(state)
            assert.is_near(1.10, mods.damageMultiplier, 0.001)
        end)
    end)

    ---------------------------------------------------------------------------
    -- End-to-end: stack count flows through Pipeline.Calculate
    ---------------------------------------------------------------------------
    describe("End-to-end via Pipeline", function()
        it("scales Shadow Bolt damage by stack count", function()
            local s1 = makePlayerState()
            s1.auras.target[17800] = 1
            local r1 = Pipeline.Calculate(686, s1)

            local s5 = makePlayerState()
            s5.auras.target[17800] = 5
            local r5 = Pipeline.Calculate(686, s5)

            -- Ratio between 5-stack and 1-stack damage should equal 1.20 / 1.04
            local ratio = r5.minDmg / r1.minDmg
            assert.is_near(1.20 / 1.04, ratio, 0.001)
        end)

        it("scales Mind Blast damage by Shadow Weaving stack count", function()
            local s1 = makePriestState()
            s1.auras.target[15258] = 1
            local r1 = Pipeline.Calculate(8092, s1)

            local s5 = makePriestState()
            s5.auras.target[15258] = 5
            local r5 = Pipeline.Calculate(8092, s5)

            local ratio = r5.minDmg / r1.minDmg
            assert.is_near(1.10 / 1.02, ratio, 0.001)
        end)
    end)
end)
