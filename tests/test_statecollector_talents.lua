-------------------------------------------------------------------------------
-- test_statecollector_talents.lua
-- Unit tests for StateCollector.CollectTalents name-based matching logic
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- WoW API global stubs
-- StateCollector.lua caches these at module load time (lines 12-36),
-- so they must exist BEFORE we loadfile the module.
-------------------------------------------------------------------------------

-- Shared mock state table. Closures reference this single table so that
-- clearing its fields in resetMocks() is visible to the cached locals
-- inside StateCollector (which capture the function references at load time).
local mockState = {
    talentData = {},          -- [tab][index] = { name, iconTexture, tier, column, rank, maxRank, ... }
    numTabs = 0,
    numTalentsPerTab = {},
}

_G.GetTalentInfo = function(tab, index)
    local t = mockState.talentData[tab]
    if not t or not t[index] then return nil end
    local d = t[index]
    return d.name, d.iconTexture, d.tier, d.column, d.rank, d.maxRank, d.isExceptional, d.available
end

_G.GetNumTalentTabs = function()
    return mockState.numTabs
end

_G.GetNumTalents = function(tab)
    return mockState.numTalentsPerTab[tab] or 0
end

-- Other globals cached by StateCollector at load time
_G.UnitLevel = function() return 70 end
_G.UnitClass = function() return "Warlock", "WARLOCK" end
_G.GetSpellBonusDamage = function() return 0 end
_G.GetSpellBonusHealing = function() return 0 end
_G.GetSpellCritChance = function() return 0 end
_G.GetCombatRatingBonus = function() return 0 end
_G.GetManaRegen = function() return 0, 0 end
_G.UnitRangedAttackPower = function() return 0, 0, 0 end
_G.GetRangedCritChance = function() return 0 end
_G.UnitCreatureType = function() return "Humanoid" end
_G.UnitExists = function() return false end
_G.UnitHealth = function() return 100 end
_G.UnitHealthMax = function() return 100 end
_G.UnitCanAttack = function() return false end
_G.UnitRangedDamage = function() return 0, 0, 0 end
_G.UnitAttackPower = function() return 0, 0, 0 end
_G.GetCritChance = function() return 0 end
_G.GetExpertise = function() return 0 end
_G.UnitDamage = function() return 0, 0, 0, 0, 0, 0, 0 end
_G.UnitAttackSpeed = function() return 2.0, 2.0 end
_G.GetInventoryItemLink = function() return nil end
_G.GetItemInfo = function() return nil end
_G.UnitStat = function() return 0, 0 end
_G.Enum = Enum or {}
_G.C_UnitAuras = nil  -- CollectAuras is not under test; nil avoids scanning

-------------------------------------------------------------------------------
-- Namespace setup - minimal ns with only what StateCollector needs
-------------------------------------------------------------------------------
local ns = {}

-- Load Constants.lua to populate ns.SCHOOL_*, ns.MOD, ns.CR_*, ns.SCALING_TYPE
local fn, err = loadfile("Core/Constants.lua")
if not fn then error("Failed to load Core/Constants.lua: " .. tostring(err)) end
fn("PhDamage", ns)

ns.SpellData = {}
ns.AuraMap = {}
ns.TalentMap = {}
ns.Engine = {}

-------------------------------------------------------------------------------
-- Load StateCollector.lua into ns
-------------------------------------------------------------------------------
local scFn, scErr = loadfile("Core/StateCollector.lua")
if not scFn then error("Failed to load Core/StateCollector.lua: " .. tostring(scErr)) end
scFn("PhDamage", ns)

local StateCollector = ns.StateCollector

-------------------------------------------------------------------------------
-- Helper: reset mock state between tests
-------------------------------------------------------------------------------
local function resetMocks()
    mockState.talentData = {}
    mockState.numTabs = 0
    mockState.numTalentsPerTab = {}
    ns.TalentMap = {}
end

-------------------------------------------------------------------------------
-- Helper: create a talent entry in the mock API
-------------------------------------------------------------------------------
local function setTalent(tab, index, name, rank, maxRank)
    if not mockState.talentData[tab] then mockState.talentData[tab] = {} end
    mockState.talentData[tab][index] = {
        name = name,
        iconTexture = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        tier = 1,
        column = 1,
        rank = rank,
        maxRank = maxRank or 5,
        isExceptional = false,
        available = true,
    }
    -- Update tab count and max talent index per tab
    -- CollectTalents iterates `for index = 1, GetNumTalents(tab)` so we need
    -- the max index, not the entry count.
    if tab > mockState.numTabs then mockState.numTabs = tab end
    local maxIndex = mockState.numTalentsPerTab[tab] or 0
    if index > maxIndex then mockState.numTalentsPerTab[tab] = index end
end

-------------------------------------------------------------------------------
-- Tests
-------------------------------------------------------------------------------
describe("StateCollector.CollectTalents", function()
    before_each(function()
        resetMocks()
    end)

    -----------------------------------------------------------------------
    -- Test 1: Name-based matching maps talents to TalentMap keys
    -----------------------------------------------------------------------
    it("maps talents by name rather than API index", function()
        -- TalentMap says "Improved Life Tap" is at key WARLOCK:1:7
        ns.TalentMap["WARLOCK:1:7"] = {
            name = "Improved Life Tap",
            maxRank = 2,
            effects = {},
        }

        -- But the WoW API returns "Improved Life Tap" at tab=1, index=3
        -- (simulating a client reorder)
        setTalent(1, 3, "Improved Life Tap", 2, 2)

        local state = { class = "WARLOCK", talents = {} }
        StateCollector.CollectTalents(state)

        -- Should use the TalentMap key (1:7), not the API position (1:3)
        assert.are.equal(2, state.talents["1:7"])
        assert.is_nil(state.talents["1:3"])
    end)

    -----------------------------------------------------------------------
    -- Test 2: maxRank clamping
    -----------------------------------------------------------------------
    it("clamps rank to maxRank from TalentMap entry", function()
        ns.TalentMap["WARLOCK:2:5"] = {
            name = "Emberstorm",
            maxRank = 2,
            effects = {},
        }

        -- API returns rank 5, but maxRank is 2
        setTalent(2, 1, "Emberstorm", 5, 5)

        local state = { class = "WARLOCK", talents = {} }
        StateCollector.CollectTalents(state)

        assert.are.equal(2, state.talents["2:5"])
    end)

    -----------------------------------------------------------------------
    -- Test 3: Untracked talents use raw tab:index key
    -----------------------------------------------------------------------
    it("stores untracked talents under raw tab:index key", function()
        -- TalentMap has nothing for this talent
        setTalent(3, 2, "Some Untracked Talent", 3, 5)

        local state = { class = "WARLOCK", talents = {} }
        StateCollector.CollectTalents(state)

        assert.are.equal(3, state.talents["3:2"])
    end)

    -----------------------------------------------------------------------
    -- Test 4: Zero-rank talents are skipped
    -----------------------------------------------------------------------
    it("does not store talents with rank 0", function()
        ns.TalentMap["WARLOCK:1:1"] = {
            name = "Suppression",
            maxRank = 5,
            effects = {},
        }

        setTalent(1, 1, "Suppression", 0, 5)

        local state = { class = "WARLOCK", talents = {} }
        StateCollector.CollectTalents(state)

        assert.is_nil(state.talents["1:1"])
        -- Also verify no raw key
        assert.is_nil(state.talents["1:1"])
    end)

    -----------------------------------------------------------------------
    -- Test 5: Multiple talents with mixed matching
    -----------------------------------------------------------------------
    it("handles a mix of tracked, untracked, and zero-rank talents", function()
        -- Tracked: TalentMap key 1:7, API returns at tab=1, index=3
        ns.TalentMap["WARLOCK:1:7"] = {
            name = "Improved Corruption",
            maxRank = 5,
            effects = {},
        }

        -- Tracked: TalentMap key 2:5, API returns at tab=2, index=4
        ns.TalentMap["WARLOCK:2:5"] = {
            name = "Improved Shadow Bolt",
            maxRank = 5,
            effects = {},
        }

        -- Tab 1: tracked, untracked, and zero-rank talents
        setTalent(1, 1, "Something Else", 2, 5)       -- untracked, rank > 0
        setTalent(1, 2, "Another Talent", 0, 3)        -- rank 0, should skip
        setTalent(1, 3, "Improved Corruption", 3, 5)   -- tracked -> key 1:7
        setTalent(1, 4, "Filler Talent", 0, 3)          -- rank 0, should skip

        -- Tab 2: tracked, untracked, and zero-rank talents
        setTalent(2, 1, "Bane", 0, 5)                   -- rank 0, skip
        setTalent(2, 2, "Aftermath", 2, 5)               -- untracked, rank > 0
        setTalent(2, 3, "Cataclysm", 1, 3)              -- untracked, rank > 0
        setTalent(2, 4, "Improved Shadow Bolt", 5, 5)   -- tracked -> key 2:5

        local state = { class = "WARLOCK", talents = {} }
        StateCollector.CollectTalents(state)

        -- Tracked talents use TalentMap keys (not API indices)
        assert.are.equal(3, state.talents["1:7"])   -- Improved Corruption
        assert.are.equal(5, state.talents["2:5"])   -- Improved Shadow Bolt

        -- Untracked talents use raw tab:index keys
        assert.are.equal(2, state.talents["1:1"])   -- Something Else
        assert.are.equal(2, state.talents["2:2"])   -- Aftermath
        assert.are.equal(1, state.talents["2:3"])   -- Cataclysm

        -- Zero-rank talents should not appear at all
        assert.is_nil(state.talents["1:2"])   -- Another Talent (rank 0)
        assert.is_nil(state.talents["1:4"])   -- Filler Talent (rank 0)
        assert.is_nil(state.talents["2:1"])   -- Bane (rank 0)
    end)

    -----------------------------------------------------------------------
    -- Test 6: Only the matching class prefix is scanned
    -----------------------------------------------------------------------
    it("ignores TalentMap entries for other classes", function()
        -- MAGE talent in the map
        ns.TalentMap["MAGE:1:2"] = {
            name = "Arcane Focus",
            maxRank = 5,
            effects = {},
        }

        -- WARLOCK talent in the map
        ns.TalentMap["WARLOCK:1:1"] = {
            name = "Suppression",
            maxRank = 5,
            effects = {},
        }

        -- API returns both talent names but state.class is WARLOCK
        setTalent(1, 1, "Suppression", 3, 5)
        setTalent(1, 2, "Arcane Focus", 2, 5)  -- same name but wrong class

        local state = { class = "WARLOCK", talents = {} }
        StateCollector.CollectTalents(state)

        -- Suppression is tracked (WARLOCK:1:1 -> key "1:1")
        assert.are.equal(3, state.talents["1:1"])
        -- "Arcane Focus" has no WARLOCK TalentMap entry, so it uses raw key
        assert.are.equal(2, state.talents["1:2"])
    end)

    -----------------------------------------------------------------------
    -- Test 7: Talent with no maxRank in TalentMap entry is not clamped
    -----------------------------------------------------------------------
    it("does not clamp when TalentMap entry has no maxRank", function()
        ns.TalentMap["WARLOCK:3:1"] = {
            name = "Demonic Embrace",
            -- no maxRank field
            effects = {},
        }

        setTalent(3, 2, "Demonic Embrace", 5, 5)

        local state = { class = "WARLOCK", talents = {} }
        StateCollector.CollectTalents(state)

        -- Should use mapped key "3:1" with unclamped rank
        assert.are.equal(5, state.talents["3:1"])
    end)

    -----------------------------------------------------------------------
    -- Test 8: Empty talent tree produces empty talents table
    -----------------------------------------------------------------------
    it("produces empty talents when there are no talent tabs", function()
        mockState.numTabs = 0

        local state = { class = "WARLOCK", talents = {} }
        StateCollector.CollectTalents(state)

        local count = 0
        for _ in pairs(state.talents) do count = count + 1 end
        assert.are.equal(0, count)
    end)
end)
