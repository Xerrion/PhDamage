-------------------------------------------------------------------------------
-- ModifierCalc.lua
-- Talent and aura modifier application
-- Pure Lua — no WoW API calls
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

local MOD = ns.MOD

local ModifierCalc = {}
ns.Engine.ModifierCalc = ModifierCalc

-------------------------------------------------------------------------------
-- MatchesFilter(filter, spellData, rankData)
-- Returns true if the spell matches all filter criteria (AND logic).
-- A nil filter matches everything.
-------------------------------------------------------------------------------
function ModifierCalc.MatchesFilter(filter, spellData, rankData)
    if not filter then
        return true
    end

    -- School exact match
    if filter.school and filter.school ~= spellData.school then
        return false
    end

    -- School in list
    if filter.schools then
        local found = false
        for _, s in ipairs(filter.schools) do
            if s == spellData.school then
                found = true
                break
            end
        end
        if not found then
            return false
        end
    end

    -- Spell type match
    if filter.spellType and filter.spellType ~= spellData.spellType then
        return false
    end

    -- Spell name in list (lazy-built hash set for O(1) lookup)
    if filter.spellNames then
        if not filter._spellNamesSet then
            filter._spellNamesSet = {}
            for _, name in ipairs(filter.spellNames) do
                filter._spellNamesSet[name] = true
            end
        end
        if not filter._spellNamesSet[spellData.name] then
            return false
        end
    end

    -- Spell ID match (check current rank only)
    if filter.spellID and filter.spellID ~= rankData.spellID then
        return false
    end

    return true
end

-------------------------------------------------------------------------------
-- CreateModAccumulator()
-- Returns a fresh modifier accumulator with default values.
-------------------------------------------------------------------------------
local function CreateModAccumulator()
    return {
        damageMultiplier = 1.0,
        talentDamageBonus = 0.0,
        directDamageMultiplier = 1.0,
        dotDamageMultiplier = 1.0,
        coefficientBonus = 0.0,
        critBonus = 0.0,
        critMultBonus = 0.0,
        castTimeReduction = 0.0,
        castTimeOverride = nil,
        spellHitBonus = 0.0,
        flatDamageBonus = 0.0,
        spellPowerBonus = 0.0,
    }
end

-------------------------------------------------------------------------------
-- ApplyEffect(mods, effect, rank, playerState)
-- Applies a single modifier effect to the accumulator.
-- rank = talent rank (for perRank effects) or 1 (for auras).
-- playerState = optional, needed for count-based modifiers (e.g., Soul Siphon).
-------------------------------------------------------------------------------
local function ApplyEffect(mods, effect, rank, playerState)
    local effectType = effect.type

    -- Count-based modifier (e.g., Soul Siphon: +X% per affliction effect on target)
    if effect.countField then
        local count = playerState and playerState[effect.countField] or 0
        local perCount
        if type(effect.value) == "table" then
            perCount = effect.value[rank] or effect.value[#effect.value]
        else
            perCount = effect.value
        end
        local bonus = perCount * count
        -- Apply cap if maxBonus exists
        if effect.maxBonus then
            local cap = type(effect.maxBonus) == "table"
                and (effect.maxBonus[rank] or effect.maxBonus[#effect.maxBonus])
                or effect.maxBonus
            if bonus > cap then
                bonus = cap
            end
        end
        -- Apply as multiplicative damage multiplier
        if effectType == MOD.DAMAGE_MULTIPLIER then
            mods.damageMultiplier = mods.damageMultiplier * (1 + bonus)
        end
        return  -- Skip normal processing
    end

    local value = effect.value

    -- Resolve rank-specific value: table lookup and perRank scaling are mutually exclusive.
    -- Table-valued effects already provide the rank-specific scalar; perRank scales a flat scalar.
    if type(value) == "table" then
        -- Table already provides rank-specific value; no further scaling
        value = value[rank] or value[#value] or 0
    elseif effect.perRank then
        -- Scalar value scaled by talent rank
        value = value * rank
    end

    if effectType == MOD.DAMAGE_MULTIPLIER then
        if effect.stacking == "additive" then
            mods.talentDamageBonus = mods.talentDamageBonus + value
        else
            mods.damageMultiplier = mods.damageMultiplier * (1 + value)
        end

    elseif effectType == MOD.DIRECT_DAMAGE_MULTIPLIER then
        mods.directDamageMultiplier = mods.directDamageMultiplier * (1 + value)

    elseif effectType == MOD.DOT_DAMAGE_MULTIPLIER then
        mods.dotDamageMultiplier = mods.dotDamageMultiplier * (1 + value)

    elseif effectType == MOD.COEFFICIENT_BONUS then
        mods.coefficientBonus = mods.coefficientBonus + value

    elseif effectType == MOD.CRIT_BONUS then
        mods.critBonus = mods.critBonus + value

    elseif effectType == MOD.CRIT_MULT_BONUS then
        mods.critMultBonus = mods.critMultBonus + value

    elseif effectType == MOD.CAST_TIME_REDUCTION then
        mods.castTimeReduction = mods.castTimeReduction + value

    elseif effectType == MOD.CAST_TIME_OVERRIDE then
        mods.castTimeOverride = value

    elseif effectType == MOD.SPELL_HIT_BONUS then
        mods.spellHitBonus = mods.spellHitBonus + value

    elseif effectType == MOD.FLAT_DAMAGE_BONUS then
        mods.flatDamageBonus = mods.flatDamageBonus + value

    elseif effectType == MOD.SPELL_POWER_BONUS then
        mods.spellPowerBonus = mods.spellPowerBonus + value
    end
end

-------------------------------------------------------------------------------
-- ApplyAuraEntry(entry, spellData, rankData, playerState, mods)
-- Applies effects and talentAmplify from a single active aura entry.
-------------------------------------------------------------------------------
local function ApplyAuraEntry(entry, spellData, rankData, playerState, mods)
    if entry.effects then
        for _, effect in ipairs(entry.effects) do
            if ModifierCalc.MatchesFilter(effect.filter, spellData, rankData) then
                ApplyEffect(mods, effect, 1, playerState)
            end
        end
    end

    if entry.talentAmplify then
        local amp = entry.talentAmplify
        local talentRank = playerState.talents[amp.talentKey] or 0
        if talentRank > 0 and entry.effects then
            for _, effect in ipairs(entry.effects) do
                if effect.type == amp.effectType
                        and ModifierCalc.MatchesFilter(effect.filter, spellData, rankData) then
                    local syntheticEffect = {
                        type = amp.effectType,
                        value = amp.perRank * talentRank,
                    }
                    ApplyEffect(mods, syntheticEffect, 1, playerState)
                    break  -- Only amplify once per aura
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-- ApplyModifiers(baseResult, spellData, playerState, talentMap, auraMap)
-- Collects modifiers from talents and auras, then applies them to baseResult.
-- Returns: modifiedResult (new table), modifiers accumulator
-------------------------------------------------------------------------------
function ModifierCalc.ApplyModifiers(baseResult, spellData, playerState, talentMap, auraMap)
    local mods = CreateModAccumulator()
    local rankData = baseResult.rankData

    ---------------------------------------------------------------------------
    -- 1. Talent modifiers (iterate active talents, look up in talentMap)
    ---------------------------------------------------------------------------
    for key, talentRank in pairs(playerState.talents) do
        if talentRank > 0 then
            local entry = talentMap[key]
            if entry and entry.effects then
                for _, effect in ipairs(entry.effects) do
                    if ModifierCalc.MatchesFilter(effect.filter, spellData, rankData) then
                        ApplyEffect(mods, effect, talentRank, playerState)
                    end
                end
            end
        end
    end

    ---------------------------------------------------------------------------
    -- 2. Aura modifiers (iterate active auras, look up in auraMap)
    ---------------------------------------------------------------------------
    for spellID, _ in pairs(playerState.auras.player) do
        local entry = auraMap[spellID]
        if entry and not entry.alreadyInStats and entry.target == "player" then
            ApplyAuraEntry(entry, spellData, rankData, playerState, mods)
        end
    end
    for spellID, _ in pairs(playerState.auras.target) do
        local entry = auraMap[spellID]
        if entry and not entry.alreadyInStats and entry.target == "target" then
            ApplyAuraEntry(entry, spellData, rankData, playerState, mods)
        end
    end

    ---------------------------------------------------------------------------
    -- 3. Build modified result
    ---------------------------------------------------------------------------
    local result = ModifierCalc.BuildModifiedResult(baseResult, spellData, playerState, mods)

    return result, mods
end

-------------------------------------------------------------------------------
-- BuildModifiedResult(baseResult, spellData, playerState, mods)
-- Applies accumulated modifiers to the base result, returning a new table.
-------------------------------------------------------------------------------
function ModifierCalc.BuildModifiedResult(baseResult, spellData, playerState, mods)
    local result = {}

    -- Copy references
    result.spellData = baseResult.spellData
    result.rankData = baseResult.rankData

    -- Effective cast time
    local castTime = baseResult.castTime or 0
    if mods.castTimeOverride then
        castTime = mods.castTimeOverride
    else
        castTime = castTime - mods.castTimeReduction
    end
    if castTime < 0 then
        castTime = 0
    end
    result.castTime = castTime

    -- Spell power with flat SP bonus
    local baseSp = playerState.stats.spellPower[spellData.school] or 0
    local effectiveSp = baseSp + mods.spellPowerBonus

    if spellData.spellType == "utility" then
        -- Utility spells: recalculate mana gain with modified coefficient
        local effectiveCoeff = (baseResult.coefficient or 0) + mods.coefficientBonus
        local spBonus = effectiveSp * effectiveCoeff
        result.coefficient = effectiveCoeff
        result.spellPowerBonus = spBonus
        result.healthCost = baseResult.healthCost
        result.manaGain = (baseResult.rankData.manaGain or 0) + spBonus
        result.critBonus = mods.critBonus
        result.hitBonus = mods.spellHitBonus
        return result
    end
    if spellData.spellType == "hybrid" then
        return ModifierCalc.BuildHybridResult(baseResult, spellData, effectiveSp, mods)
    end

    -- Standard damage spells (direct, dot, channel)
    local effectiveCoeff = (baseResult.coefficient or 0) + mods.coefficientBonus
    local spBonus = effectiveSp * effectiveCoeff

    result.coefficient = effectiveCoeff
    result.spellPowerBonus = spBonus

    if spellData.spellType == "direct" then
        local baseMin = baseResult.minBaseDamage + mods.flatDamageBonus
        local baseMax = baseResult.maxBaseDamage + mods.flatDamageBonus
        local avgBase = (baseMin + baseMax) / 2

        result.minBaseDamage = baseMin
        result.maxBaseDamage = baseMax
        result.avgBaseDamage = avgBase
        result.damageBeforeMods = avgBase + spBonus

        local totalAvg = (avgBase + spBonus)
            * (1 + mods.talentDamageBonus) * mods.damageMultiplier * mods.directDamageMultiplier
        local totalMin = (baseMin + spBonus)
            * (1 + mods.talentDamageBonus) * mods.damageMultiplier * mods.directDamageMultiplier
        local totalMax = (baseMax + spBonus)
            * (1 + mods.talentDamageBonus) * mods.damageMultiplier * mods.directDamageMultiplier

        result.totalDamage = totalAvg
        result.totalMin = totalMin
        result.totalMax = totalMax
    else
        -- DoT or Channel
        local baseTotalDmg = baseResult.avgBaseDamage + mods.flatDamageBonus
        result.avgBaseDamage = baseTotalDmg
        result.damageBeforeMods = baseTotalDmg + spBonus

        local totalDmg = (baseTotalDmg + spBonus)
            * (1 + mods.talentDamageBonus) * mods.damageMultiplier * mods.dotDamageMultiplier
        result.totalDamage = totalDmg
        local numTicks = baseResult.numTicks
        if not numTicks or numTicks == 0 then numTicks = 1 end
        result.numTicks = numTicks
        result.duration = baseResult.duration
        result.tickDamage = totalDmg / numTicks
    end

    result.critBonus = mods.critBonus
    result.hitBonus = mods.spellHitBonus
    result.talentDamageBonus = mods.talentDamageBonus

    return result
end

-------------------------------------------------------------------------------
-- BuildHybridResult(baseResult, spellData, effectiveSp, mods)
-- Handles hybrid spells (Immolate) with separate direct + DoT portions.
-------------------------------------------------------------------------------
function ModifierCalc.BuildHybridResult(baseResult, spellData, effectiveSp, mods)
    if not baseResult.dotBaseDamage then
        return nil
    end

    local result = {}
    result.spellData = baseResult.spellData
    result.rankData = baseResult.rankData

    -- Direct portion
    local directCoeff = (baseResult.directCoefficient or 0) + mods.coefficientBonus
    local directSpBonus = effectiveSp * directCoeff
    local directMin = (baseResult.minBaseDamage + mods.flatDamageBonus + directSpBonus)
        * (1 + mods.talentDamageBonus) * mods.damageMultiplier * mods.directDamageMultiplier
    local directMax = (baseResult.maxBaseDamage + mods.flatDamageBonus + directSpBonus)
        * (1 + mods.talentDamageBonus) * mods.damageMultiplier * mods.directDamageMultiplier
    local directAvg = (directMin + directMax) / 2

    result.directCoefficient = directCoeff
    result.directSpBonus = directSpBonus
    result.directDamage = directAvg
    result.directMin = directMin
    result.directMax = directMax

    -- Design: coefficientBonus applies only to the direct coefficient for hybrid spells.
    -- The DoT portion uses its base coefficient unchanged. To add DoT-specific coefficient
    -- bonuses, a separate dotCoefficientBonus modifier type would be needed.
    local dotCoeff = baseResult.dotCoefficient or 0
    local dotSpBonus = effectiveSp * dotCoeff
    local dotDamage = (baseResult.dotBaseDamage + dotSpBonus)
        * (1 + mods.talentDamageBonus) * mods.damageMultiplier * mods.dotDamageMultiplier

    result.dotCoefficient = dotCoeff
    result.dotSpBonus = dotSpBonus
    result.dotDamage = dotDamage
    local numTicks = baseResult.numTicks
    if not numTicks or numTicks == 0 then numTicks = 1 end
    result.numTicks = numTicks
    result.duration = baseResult.duration
    result.tickDamage = dotDamage / numTicks

    -- Combined
    result.coefficient = directCoeff + dotCoeff
    result.spellPowerBonus = directSpBonus + dotSpBonus
    result.avgBaseDamage = baseResult.avgBaseDamage + mods.flatDamageBonus
    result.damageBeforeMods = baseResult.totalDamage
    result.totalDamage = directAvg + dotDamage

    -- Cast time (apply override or reduction from mods)
    local castTime
    if mods.castTimeOverride then
        castTime = mods.castTimeOverride
    else
        castTime = (baseResult.castTime or 0) - mods.castTimeReduction
    end
    castTime = math.max(castTime, 0)
    result.castTime = castTime

    result.critBonus = mods.critBonus
    result.hitBonus = mods.spellHitBonus
    result.talentDamageBonus = mods.talentDamageBonus

    return result
end
