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
LoadFile("Data/SpellData_Hunter.lua")
LoadFile("Data/TalentMap_Hunter.lua")
LoadFile("Data/AuraMap_Hunter.lua")
LoadFile("Data/SpellData_Mage.lua")
LoadFile("Data/TalentMap_Mage.lua")
LoadFile("Data/AuraMap_Mage.lua")
LoadFile("Data/SpellData_Priest.lua")
LoadFile("Data/TalentMap_Priest.lua")
LoadFile("Data/AuraMap_Priest.lua")
LoadFile("Data/SpellData_Warrior.lua")
LoadFile("Data/TalentMap_Warrior.lua")
LoadFile("Data/AuraMap_Warrior.lua")
LoadFile("Data/SpellData_Rogue.lua")
LoadFile("Data/TalentMap_Rogue.lua")
LoadFile("Data/AuraMap_Rogue.lua")
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
-- Default Hunter player state for testing
-------------------------------------------------------------------------------
local DEFAULT_HUNTER_STATE = {
    level = 70,
    class = "HUNTER",
    stats = {
        spellPower = {},
        healingPower = 0,
        spellCrit = {},
        spellHit = 0,
        spellHaste = 0,
        rangedAttackPower = 1000,
        rangedCrit = 0.15,
        rangedHit = 0.05,
        rangedHaste = 0,
        weaponDamage = { min = 100, max = 200 },
        rangedSpeed = 2.8,
        manaRegen = { base = 100, casting = 50 },
    },
    talents = {},
    auras = {
        player = {},
        target = {},
    },
    gear = {
        setBonuses = {},
    },
    targetArmor = 0,
    targetCreatureType = nil,
    afflictionCountOnTarget = 0,
}

-------------------------------------------------------------------------------
-- Factory function: returns a fresh deep copy of the default Hunter state
-------------------------------------------------------------------------------
local function MakeHunterState()
    return DeepCopy(DEFAULT_HUNTER_STATE)
end

-------------------------------------------------------------------------------
-- Default Mage player state for testing
-------------------------------------------------------------------------------
local DEFAULT_MAGE_STATE = {
    level = 70,
    class = "MAGE",
    stats = {
        spellPower = { [4] = 1000, [16] = 1000, [64] = 1000 },
        healingPower = 0,
        spellCrit = { [4] = 0.10, [16] = 0.10, [64] = 0.10 },
        spellHit = 0.03,
        spellHaste = 0,
    },
    talents = {},
    auras = { player = {}, target = {} },
    gear = { setBonuses = {} },
    targetHealthPercent = 100,
    targetCreatureType = nil,
    afflictionCountOnTarget = 0,
}

-------------------------------------------------------------------------------
-- Factory function: returns a fresh deep copy of the default Mage state
-------------------------------------------------------------------------------
local function MakeMageState()
    return DeepCopy(DEFAULT_MAGE_STATE)
end

-------------------------------------------------------------------------------
-- Default Priest player state for testing
-------------------------------------------------------------------------------
local DEFAULT_PRIEST_STATE = {
    level = 70,
    class = "PRIEST",
    stats = {
        spellPower = { [2] = 1000, [32] = 1000 },
        healingPower = 0,
        spellCrit = { [2] = 0.10, [32] = 0.10 },
        spellHit = 0.03,
        spellHaste = 0,
    },
    talents = {},
    auras = { player = {}, target = {} },
    gear = { setBonuses = {} },
    targetHealthPercent = 100,
    targetCreatureType = nil,
    afflictionCountOnTarget = 0,
}

-------------------------------------------------------------------------------
-- Factory function: returns a fresh deep copy of the default Priest state
-------------------------------------------------------------------------------
local function MakePriestState()
    return DeepCopy(DEFAULT_PRIEST_STATE)
end

-------------------------------------------------------------------------------
-- Default Warrior player state for testing
-------------------------------------------------------------------------------
local DEFAULT_WARRIOR_STATE = {
    level = 70,
    targetLevel = 73,
    class = "WARRIOR",
    stats = {
        spellPower = {},
        healingPower = 0,
        spellCrit = {},
        spellHit = 0,
        spellHaste = 0,
        attackPower = 2000,
        meleeCrit = 0.25,
        meleeHit = 0.00,
        meleeHaste = 0.00,
        expertise = 0,
        mainHandWeaponDmgMin = 200,
        mainHandWeaponDmgMax = 350,
        mainHandWeaponSpeed = 3.6,
        mainHandWeaponType = "TWO_HAND",
    },
    talents = {},
    auras = { player = {}, target = {} },
    gear = { setBonuses = {} },
    attackingFromBehind = true,
    targetArmor = 0,
}

-------------------------------------------------------------------------------
-- Factory function: returns a fresh deep copy of the default Warrior state
-------------------------------------------------------------------------------
local function makeWarriorState(overrides)
    local state = DeepCopy(DEFAULT_WARRIOR_STATE)
    if overrides then
        for k, v in pairs(overrides) do
            state[k] = v
        end
    end
    return state
end

-------------------------------------------------------------------------------
-- Default Rogue player state for testing
-------------------------------------------------------------------------------
local DEFAULT_ROGUE_STATE = {
    level = 70,
    targetLevel = 73,
    class = "ROGUE",
    stats = {
        spellPower = {},
        healingPower = 0,
        spellCrit = {},
        spellHit = 0,
        spellHaste = 0,
        attackPower = 2000,
        meleeCrit = 0.25,
        meleeHit = 0.00,
        meleeHaste = 0.00,
        expertise = 0,
        mainHandWeaponDmgMin = 130,
        mainHandWeaponDmgMax = 243,
        mainHandWeaponSpeed = 2.6,
        mainHandWeaponType = "ONE_HAND",
    },
    talents = {},
    auras = { player = {}, target = {} },
    gear = { setBonuses = {} },
    attackingFromBehind = true,
    targetArmor = 0,
}

-------------------------------------------------------------------------------
-- Factory function: returns a fresh deep copy of the default Rogue state
-------------------------------------------------------------------------------
local function makeRogueState(overrides)
    local state = DeepCopy(DEFAULT_ROGUE_STATE)
    if overrides then
        for k, v in pairs(overrides) do
            state[k] = v
        end
    end
    return state
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
    makeHunterState = MakeHunterState,
    makeMageState = MakeMageState,
    makePriestState = MakePriestState,
    makeWarriorState = makeWarriorState,
    makeRogueState = makeRogueState,
}
