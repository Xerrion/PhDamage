-------------------------------------------------------------------------------
-- bootstrap.lua
-- Test bootstrap for PhDamage engine - loads pure Lua modules without WoW API
--
-- Usage: local b = require("tests.bootstrap"); local ns = b.ns
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- WoW global stubs (referenced by Data/Constants files)
-------------------------------------------------------------------------------
Enum = Enum or {}

-------------------------------------------------------------------------------
-- Namespace setup (mirrors Core/Init.lua without Ace3 dependencies)
-------------------------------------------------------------------------------
local ns = {}
ns.SpellData = {}
ns.TalentMap = {}
ns.AuraMap = {}
ns.Engine = {}

-------------------------------------------------------------------------------
-- File loader helper
-------------------------------------------------------------------------------
local function LoadFile(path)
    local fn, err = loadfile(path)
    if not fn then
        error("Failed to load " .. path .. ": " .. tostring(err))
    end
    fn("PhDamage", ns)
end

-------------------------------------------------------------------------------
-- Load modules in TOC order
-------------------------------------------------------------------------------
LoadFile("Core/Constants.lua")
LoadFile("Data/SpellData_Warlock.lua")
LoadFile("Data/TalentMap_Warlock.lua")
LoadFile("Data/AuraMap_Warlock.lua")
LoadFile("Engine/SpellCalc.lua")
LoadFile("Engine/ModifierCalc.lua")
LoadFile("Engine/CritCalc.lua")
LoadFile("Engine/Pipeline.lua")

-------------------------------------------------------------------------------
-- Deep copy utility (ensures each test gets an independent state)
-------------------------------------------------------------------------------
local function DeepCopy(orig)
    if type(orig) ~= "table" then
        return orig
    end
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = DeepCopy(v)
    end
    return copy
end

-------------------------------------------------------------------------------
-- Default player state template
-------------------------------------------------------------------------------
local DEFAULT_PLAYER_STATE = {
    level = 70,
    class = "WARLOCK",
    stats = {
        spellPower = {
            [2] = 0,      -- SCHOOL_HOLY
            [4] = 1000,   -- SCHOOL_FIRE
            [8] = 0,      -- SCHOOL_NATURE
            [16] = 0,     -- SCHOOL_FROST
            [32] = 1000,  -- SCHOOL_SHADOW
            [64] = 0,     -- SCHOOL_ARCANE
        },
        healingPower = 0,
        spellCrit = {
            [4] = 0.10,   -- Fire
            [32] = 0.10,  -- Shadow
        },
        spellHit = 0.03,
        spellHaste = 0,
        manaRegen = 0,
    },
    talents = {},
    auras = {
        player = {},
        target = {},
    },
    gear = {
        setBonuses = {},
    },
}

-------------------------------------------------------------------------------
-- Factory function: returns a fresh deep copy of the default player state
-------------------------------------------------------------------------------
local function MakePlayerState()
    return DeepCopy(DEFAULT_PLAYER_STATE)
end

-------------------------------------------------------------------------------
-- Self-test when run directly
-------------------------------------------------------------------------------
local isMain = (arg and arg[0] and arg[0]:find("bootstrap"))

if isMain then
    -- Verify Constants loaded
    assert(ns.SCHOOL_SHADOW == 32, "Constants: SCHOOL_SHADOW expected 32")
    assert(ns.MOD and ns.MOD.DAMAGE_MULTIPLIER, "Constants: ns.MOD missing")

    -- Verify SpellData populated
    local spellCount = 0
    for _ in pairs(ns.SpellData) do spellCount = spellCount + 1 end
    assert(spellCount > 0, "SpellData is empty")

    -- Verify TalentMap populated
    local talentCount = 0
    for _ in pairs(ns.TalentMap) do talentCount = talentCount + 1 end
    assert(talentCount > 0, "TalentMap is empty")

    -- Verify AuraMap populated
    local auraCount = 0
    for _ in pairs(ns.AuraMap) do auraCount = auraCount + 1 end
    assert(auraCount > 0, "AuraMap is empty")

    -- Verify Engine modules wired
    assert(ns.Engine.SpellCalc, "Engine.SpellCalc not loaded")
    assert(ns.Engine.ModifierCalc, "Engine.ModifierCalc not loaded")
    assert(ns.Engine.CritCalc, "Engine.CritCalc not loaded")
    assert(ns.Engine.Pipeline, "Engine.Pipeline not loaded")

    -- Verify Pipeline runs end-to-end
    local state = MakePlayerState()
    local result = ns.Engine.Pipeline.Calculate(686, state)  -- Shadow Bolt
    assert(result, "Pipeline.Calculate returned nil for Shadow Bolt (686)")
    assert(result.spellName == "Shadow Bolt", "Unexpected spellName: " .. tostring(result.spellName))
    assert(result.dps and result.dps > 0, "Shadow Bolt DPS should be > 0")

    -- Verify makePlayerState returns independent copies
    local s1 = MakePlayerState()
    local s2 = MakePlayerState()
    s1.level = 60
    assert(s2.level == 70, "makePlayerState should return independent copies")

    print(string.format(
        "Bootstrap loaded successfully — %d spells, %d talents, %d auras, 4 engine modules",
        spellCount, talentCount, auraCount
    ))
end

-------------------------------------------------------------------------------
-- Module export
-------------------------------------------------------------------------------
return {
    ns = ns,
    makePlayerState = MakePlayerState,
}
