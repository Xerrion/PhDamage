-------------------------------------------------------------------------------
-- StateCollector.lua
-- Reads WoW APIs to produce a PlayerState snapshot for the engine
-- This is the bridge between WoW and the pure-Lua engine
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

-- Cache WoW API functions as locals
local UnitLevel = UnitLevel
local UnitClass = UnitClass
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing
local GetSpellCritChance = GetSpellCritChance
local GetCombatRatingBonus = GetCombatRatingBonus
local GetTalentInfo = GetTalentInfo
local GetNumTalentTabs = GetNumTalentTabs
local GetNumTalents = GetNumTalents
local GetManaRegen = GetManaRegen

local StateCollector = {}
ns.StateCollector = StateCollector

-- Affliction spell IDs for Soul Siphon counting
-- Includes: Curses, Corruption, SoC, Siphon Life, UA, Drain Life, Fear, Immolate
local AFFLICTION_SPELL_IDS = {
    -- Corruption (all ranks - base spellID 172)
    [172] = true, [6222] = true, [6223] = true, [7648] = true,
    [11671] = true, [11672] = true, [25311] = true, [27216] = true,
    -- Curse of Agony (all ranks - base 980)
    [980] = true, [1014] = true, [6217] = true, [11711] = true,
    [11712] = true, [11713] = true, [27218] = true,
    -- Unstable Affliction (all ranks - base 30108)
    [30108] = true, [30404] = true, [30405] = true,
    -- Siphon Life (all ranks - base 18265)
    [18265] = true, [18879] = true, [18880] = true, [18881] = true,
    [27264] = true, [30911] = true,
    -- Curse of Doom (all ranks)
    [603] = true, [30910] = true,
    -- Curse of Elements (all ranks)
    [1490] = true, [11721] = true, [11722] = true, [27228] = true,
    -- Curse of Shadow (all ranks)
    [17862] = true, [17937] = true, [32862] = true,
    -- Curse of Recklessness (all ranks)
    [704] = true, [7658] = true, [7659] = true, [11717] = true, [27226] = true,
    -- Curse of Tongues (all ranks)
    [1714] = true, [11719] = true,
    -- Curse of Weakness (all ranks)
    [702] = true, [1108] = true, [6205] = true, [7646] = true,
    [11707] = true, [11708] = true, [27224] = true, [30909] = true,
    -- Seed of Corruption
    [27243] = true,
    -- Drain Life (all ranks - self counts as affliction effect)
    [689] = true, [699] = true, [709] = true, [7651] = true,
    [11699] = true, [11700] = true, [27219] = true, [27220] = true,
    -- Fear
    [5782] = true, [6213] = true, [6215] = true,
    -- Immolate (all ranks - counts as affliction dot on target)
    [348] = true, [707] = true, [1094] = true, [2941] = true,
    [11665] = true, [11667] = true, [11668] = true, [25309] = true, [27215] = true,
}

-- School index to bitmask constant mapping
-- GetSpellBonusDamage(school) uses: 1=Physical, 2=Holy, 3=Fire, 4=Nature, 5=Frost, 6=Shadow, 7=Arcane
local schoolIndexToConstant = {
    [1] = ns.SCHOOL_PHYSICAL,
    [2] = ns.SCHOOL_HOLY,
    [3] = ns.SCHOOL_FIRE,
    [4] = ns.SCHOOL_NATURE,
    [5] = ns.SCHOOL_FROST,
    [6] = ns.SCHOOL_SHADOW,
    [7] = ns.SCHOOL_ARCANE,
}

function StateCollector.CollectPlayerState()
    local state = {
        level = UnitLevel("player"),
        class = select(2, UnitClass("player")),  -- English class token
        stats = {
            spellPower = {},
            healingPower = 0,
            spellCrit = {},
            spellHit = 0,
            spellHaste = 0,
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

    local ok, result

    -- Collect spell power per school (skip physical at index 1)
    for i = 2, 7 do
        ok, result = pcall(GetSpellBonusDamage, i)
        if ok and result ~= nil then
            state.stats.spellPower[schoolIndexToConstant[i]] = result
        end
    end

    -- Healing power
    ok, result = pcall(GetSpellBonusHealing)
    if ok and result ~= nil then
        state.stats.healingPower = result
    end

    -- Spell crit per school (same school indices as spell power)
    for i = 2, 7 do
        ok, result = pcall(GetSpellCritChance, i)
        if ok and result ~= nil then
            state.stats.spellCrit[schoolIndexToConstant[i]] = result / 100  -- Convert percentage to fraction
        end
    end

    -- Spell hit from rating (CR_HIT_SPELL)
    ok, result = pcall(GetCombatRatingBonus, ns.CR_HIT_SPELL)
    if ok and result ~= nil then
        state.stats.spellHit = result / 100
    end

    -- Spell haste from rating (CR_HASTE_SPELL)
    ok, result = pcall(GetCombatRatingBonus, ns.CR_HASTE_SPELL)
    if ok and result ~= nil then
        state.stats.spellHaste = result / 100
    end

    -- Mana regen
    do
        local ok, base, casting = pcall(GetManaRegen)
        if ok then
            state.stats.manaRegen = { base = base or 0, casting = casting or 0 }
        end
    end

    -- Talents
    StateCollector.CollectTalents(state)

    -- Auras
    StateCollector.CollectAuras(state)

    return state
end

function StateCollector.CollectTalents(state)
    local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 0
    for tab = 1, numTabs do
        local numTalents = GetNumTalents and GetNumTalents(tab) or 0
        for index = 1, numTalents do
            local ok, name, _, _, _, rank = pcall(GetTalentInfo, tab, index)
            if ok and name and rank and rank > 0 then
                local key = tab .. ":" .. index
                state.talents[key] = rank
            end
        end
    end
end

-- Cached watched-auras set; ns.AuraMap is static after addon init
local watchedAurasCache = nil

local function GetWatchedAuras()
    if watchedAurasCache then return watchedAurasCache end
    watchedAurasCache = {}
    if ns.AuraMap then
        for spellID, entry in pairs(ns.AuraMap) do
            watchedAurasCache[spellID] = entry.target
        end
    end
    return watchedAurasCache
end

function StateCollector.CollectAuras(state)
    local watchedAuras = GetWatchedAuras()

    -- Scan player buffs using C_UnitAuras.GetPlayerAuraBySpellID if available
    local hasGetPlayerAura = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID
    if hasGetPlayerAura then
        for spellID, target in pairs(watchedAuras) do
            if target == "player" then
                local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                if auraData then
                    state.auras.player[spellID] = true
                end
            end
        end
    end

    -- Helper to scan auras on a unit via C_UnitAuras
    local scanUnit = function(unit, auraType, stateKey)
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local i = 1
            while true do
                local ok, auraData = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, auraType)
                if not ok or not auraData then break end
                if auraData.spellId and watchedAuras[auraData.spellId] then
                    state.auras[stateKey][auraData.spellId] = true
                end
                i = i + 1
            end
        end
    end

    -- Scan target debuffs via C_UnitAuras (also count affliction effects for Soul Siphon)
    local afflictionCount = 0
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        local i = 1
        while true do
            local ok, auraData = pcall(C_UnitAuras.GetAuraDataByIndex, "target", i, "HARMFUL")
            if not ok or not auraData then break end
            if auraData.spellId then
                if watchedAuras[auraData.spellId] then
                    state.auras.target[auraData.spellId] = true
                end
                if AFFLICTION_SPELL_IDS[auraData.spellId] then
                    afflictionCount = afflictionCount + 1
                end
            end
            i = i + 1
        end
    end
    state.afflictionCountOnTarget = afflictionCount

    -- Scan player buffs via C_UnitAuras if GetPlayerAuraBySpellID was not available
    if not hasGetPlayerAura then
        scanUnit("player", "HELPFUL", "player")
    end
end

-------------------------------------------------------------------------------
-- Cached state management
-------------------------------------------------------------------------------

local cachedState = nil
local isDirty = true

function StateCollector.Invalidate()
    isDirty = true
end

function StateCollector.GetCachedState()
    if isDirty or not cachedState then
        cachedState = StateCollector.CollectPlayerState()
        isDirty = false
    end
    return cachedState
end

-- StateCollector is accessible via ns.StateCollector
