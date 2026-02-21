-------------------------------------------------------------------------------
-- ModifierCalc.lua
-- Talent and aura modifier application
-- Pure Lua — no WoW API calls
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local MOD = ns.MOD

local ModifierCalc = {}
ns.Engine.ModifierCalc = ModifierCalc

-------------------------------------------------------------------------------
-- MatchesFilter(filter, spellData)
-- Returns true if the spell matches all filter criteria (AND logic).
-- A nil filter matches everything.
-------------------------------------------------------------------------------
function ModifierCalc.MatchesFilter(filter, spellData)
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

    -- Spell name in list
    if filter.spellNames then
        local found = false
        for _, name in ipairs(filter.spellNames) do
            if name == spellData.name then
                found = true
                break
            end
        end
        if not found then
            return false
        end
    end

    -- Spell ID match (check any rank's spellID)
    if filter.spellID then
        local found = false
        if spellData.ranks then
            for _, rankData in pairs(spellData.ranks) do
                if rankData.spellID == filter.spellID then
                    found = true
                    break
                end
            end
        end
        if not found then
            return false
        end
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
-- ApplyEffect(mods, effect, rank)
-- Applies a single modifier effect to the accumulator.
-- rank = talent rank (for perRank effects) or 1 (for auras).
-------------------------------------------------------------------------------
local function ApplyEffect(mods, effect, rank)
    local effectType = effect.type
    local value = effect.value

    if effectType == MOD.DAMAGE_MULTIPLIER then
        if effect.perRank then
            mods.damageMultiplier = mods.damageMultiplier * (1 + value * rank)
        else
            mods.damageMultiplier = mods.damageMultiplier * (1 + value)
        end

    elseif effectType == MOD.DIRECT_DAMAGE_MULTIPLIER then
        if effect.perRank then
            mods.directDamageMultiplier = mods.directDamageMultiplier * (1 + value * rank)
        else
            mods.directDamageMultiplier = mods.directDamageMultiplier * (1 + value)
        end

    elseif effectType == MOD.DOT_DAMAGE_MULTIPLIER then
        if effect.perRank then
            mods.dotDamageMultiplier = mods.dotDamageMultiplier * (1 + value * rank)
        else
            mods.dotDamageMultiplier = mods.dotDamageMultiplier * (1 + value)
        end

    elseif effectType == MOD.COEFFICIENT_BONUS then
        if effect.perRank then
            mods.coefficientBonus = mods.coefficientBonus + value * rank
        else
            mods.coefficientBonus = mods.coefficientBonus + value
        end

    elseif effectType == MOD.CRIT_BONUS then
        if effect.perRank then
            mods.critBonus = mods.critBonus + value * rank
        else
            mods.critBonus = mods.critBonus + value
        end

    elseif effectType == MOD.CRIT_MULT_BONUS then
        if effect.perRank then
            mods.critMultBonus = mods.critMultBonus + value * rank
        else
            mods.critMultBonus = mods.critMultBonus + value
        end

    elseif effectType == MOD.CAST_TIME_REDUCTION then
        if effect.perRank then
            mods.castTimeReduction = mods.castTimeReduction + value * rank
        else
            mods.castTimeReduction = mods.castTimeReduction + value
        end

    elseif effectType == MOD.CAST_TIME_OVERRIDE then
        mods.castTimeOverride = value

    elseif effectType == MOD.SPELL_HIT_BONUS then
        if effect.perRank then
            mods.spellHitBonus = mods.spellHitBonus + value * rank
        else
            mods.spellHitBonus = mods.spellHitBonus + value
        end

    elseif effectType == MOD.FLAT_DAMAGE_BONUS then
        if effect.perRank then
            mods.flatDamageBonus = mods.flatDamageBonus + value * rank
        else
            mods.flatDamageBonus = mods.flatDamageBonus + value
        end

    elseif effectType == MOD.SPELL_POWER_BONUS then
        if effect.perRank then
            mods.spellPowerBonus = mods.spellPowerBonus + value * rank
        else
            mods.spellPowerBonus = mods.spellPowerBonus + value
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

    ---------------------------------------------------------------------------
    -- 1. Talent modifiers
    ---------------------------------------------------------------------------
    for key, entry in pairs(talentMap) do
        local talentRank = playerState.talents[key]
        if talentRank and talentRank > 0 then
            for _, effect in ipairs(entry.effects) do
                if ModifierCalc.MatchesFilter(effect.filter, spellData) then
                    ApplyEffect(mods, effect, talentRank)
                end
            end
        end
    end

    ---------------------------------------------------------------------------
    -- 2. Aura modifiers
    ---------------------------------------------------------------------------
    for spellID, entry in pairs(auraMap) do
        if not entry.alreadyInStats then
            local isActive = false
            if entry.target == "player" then
                isActive = playerState.auras.player[spellID]
            elseif entry.target == "target" then
                isActive = playerState.auras.target[spellID]
            end

            if isActive then
                for _, effect in ipairs(entry.effects) do
                    if ModifierCalc.MatchesFilter(effect.filter, spellData) then
                        ApplyEffect(mods, effect, 1)
                    end
                end
            end
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

        local totalAvg = (avgBase + spBonus) * mods.damageMultiplier * mods.directDamageMultiplier
        local totalMin = (baseMin + spBonus) * mods.damageMultiplier * mods.directDamageMultiplier
        local totalMax = (baseMax + spBonus) * mods.damageMultiplier * mods.directDamageMultiplier

        result.totalDamage = totalAvg
        result.totalMin = totalMin
        result.totalMax = totalMax
    else
        -- DoT or Channel
        local baseTotalDmg = baseResult.avgBaseDamage + mods.flatDamageBonus
        result.avgBaseDamage = baseTotalDmg
        result.damageBeforeMods = baseTotalDmg + spBonus

        local totalDmg = (baseTotalDmg + spBonus) * mods.damageMultiplier * mods.dotDamageMultiplier
        result.totalDamage = totalDmg
        result.numTicks = baseResult.numTicks
        result.duration = baseResult.duration
        result.tickDamage = totalDmg / baseResult.numTicks
    end

    return result
end

-------------------------------------------------------------------------------
-- BuildHybridResult(baseResult, spellData, effectiveSp, mods)
-- Handles hybrid spells (Immolate) with separate direct + DoT portions.
-------------------------------------------------------------------------------
function ModifierCalc.BuildHybridResult(baseResult, spellData, effectiveSp, mods)
    local result = {}
    result.spellData = baseResult.spellData
    result.rankData = baseResult.rankData

    -- Direct portion
    local directCoeff = (baseResult.directCoefficient or 0) + mods.coefficientBonus
    local directSpBonus = effectiveSp * directCoeff
    local directMin = (baseResult.minBaseDamage + mods.flatDamageBonus + directSpBonus)
        * mods.damageMultiplier * mods.directDamageMultiplier
    local directMax = (baseResult.maxBaseDamage + mods.flatDamageBonus + directSpBonus)
        * mods.damageMultiplier * mods.directDamageMultiplier
    local directAvg = (directMin + directMax) / 2

    result.directCoefficient = directCoeff
    result.directSpBonus = directSpBonus
    result.directDamage = directAvg
    result.directMin = directMin
    result.directMax = directMax

    -- DoT portion (coefficient bonus does not apply to DoT side by default)
    local dotCoeff = baseResult.dotCoefficient or 0
    local dotSpBonus = effectiveSp * dotCoeff
    local dotDamage = (baseResult.dotBaseDamage + dotSpBonus)
        * mods.damageMultiplier * mods.dotDamageMultiplier

    result.dotCoefficient = dotCoeff
    result.dotSpBonus = dotSpBonus
    result.dotDamage = dotDamage
    result.numTicks = baseResult.numTicks
    result.duration = baseResult.duration
    result.tickDamage = dotDamage / baseResult.numTicks

    -- Combined
    result.coefficient = directCoeff + dotCoeff
    result.spellPowerBonus = directSpBonus + dotSpBonus
    result.avgBaseDamage = baseResult.avgBaseDamage
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

    return result
end
