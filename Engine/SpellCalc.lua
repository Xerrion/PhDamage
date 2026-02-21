-------------------------------------------------------------------------------
-- SpellCalc.lua
-- Base damage computation: raw damage + spell power contribution
-- Pure Lua — no WoW API calls
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local SpellCalc = {}
ns.Engine.SpellCalc = SpellCalc

-------------------------------------------------------------------------------
-- GetCurrentRank(spellData, playerState)
-- Returns the highest rank the player can use based on level.
-- Returns: rankNumber, rankData  (or nil, nil if no rank qualifies)
-------------------------------------------------------------------------------
function SpellCalc.GetCurrentRank(spellData, playerState)
    local bestRank, bestData = nil, nil

    -- pairs used intentionally: handles sparse rank tables gracefully
    for rank, data in pairs(spellData.ranks) do
        if data.level <= playerState.level then
            if bestRank == nil or rank > bestRank then
                bestRank = rank
                bestData = data
            end
        end
    end

    return bestRank, bestData
end

-------------------------------------------------------------------------------
-- ComputeBase(spellData, rankData, playerState)
-- Computes raw damage values before talent/aura modifiers.
-- Returns an intermediate result table.
-------------------------------------------------------------------------------
function SpellCalc.ComputeBase(spellData, rankData, playerState)
    local spellType = spellData.spellType

    if spellType == "direct" then
        return SpellCalc.ComputeDirect(spellData, rankData, playerState)
    elseif spellType == "dot" then
        return SpellCalc.ComputeDot(spellData, rankData, playerState)
    elseif spellType == "hybrid" then
        return SpellCalc.ComputeHybrid(spellData, rankData, playerState)
    elseif spellType == "channel" then
        return SpellCalc.ComputeChannel(spellData, rankData, playerState)
    elseif spellType == "utility" then
        return SpellCalc.ComputeUtility(spellData, rankData, playerState)
    end

    return nil
end

-------------------------------------------------------------------------------
-- ComputeDirect — direct damage spells (Shadow Bolt, etc.)
-------------------------------------------------------------------------------
function SpellCalc.ComputeDirect(spellData, rankData, playerState)
    local avgBase = (rankData.minDmg + rankData.maxDmg) / 2
    local sp = playerState.stats.spellPower[spellData.school] or 0
    local spBonus = sp * spellData.coefficient

    return {
        spellData = spellData,
        rankData = rankData,
        avgBaseDamage = avgBase,
        minBaseDamage = rankData.minDmg,
        maxBaseDamage = rankData.maxDmg,
        coefficient = spellData.coefficient,
        spellPowerBonus = spBonus,
        totalDamage = avgBase + spBonus,
        totalMin = rankData.minDmg + spBonus,
        totalMax = rankData.maxDmg + spBonus,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeDot — periodic damage spells (Corruption, Curse of Agony, etc.)
-------------------------------------------------------------------------------
function SpellCalc.ComputeDot(spellData, rankData, playerState)
    local sp = playerState.stats.spellPower[spellData.school] or 0
    local spBonus = sp * spellData.coefficient
    local totalDmg = rankData.totalDmg + spBonus
    local tickDmg = totalDmg / spellData.numTicks

    return {
        spellData = spellData,
        rankData = rankData,
        avgBaseDamage = rankData.totalDmg,
        coefficient = spellData.coefficient,
        spellPowerBonus = spBonus,
        totalDamage = totalDmg,
        tickDamage = tickDmg,
        numTicks = spellData.numTicks,
        duration = spellData.duration,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeHybrid — spells with both direct + DoT portions (Immolate)
-------------------------------------------------------------------------------
function SpellCalc.ComputeHybrid(spellData, rankData, playerState)
    local sp = playerState.stats.spellPower[spellData.school] or 0

    -- Direct portion
    local directAvg = (rankData.minDmg + rankData.maxDmg) / 2
    local directSpBonus = sp * spellData.directCoefficient
    local directDamage = directAvg + directSpBonus

    -- DoT portion
    local dotSpBonus = sp * spellData.dotCoefficient
    local dotDamage = rankData.dotDmg + dotSpBonus
    local tickDamage = dotDamage / spellData.numTicks

    return {
        spellData = spellData,
        rankData = rankData,
        -- Direct fields
        avgBaseDamage = directAvg,
        minBaseDamage = rankData.minDmg,
        maxBaseDamage = rankData.maxDmg,
        directCoefficient = spellData.directCoefficient,
        directSpBonus = directSpBonus,
        directDamage = directDamage,
        directMin = rankData.minDmg + directSpBonus,
        directMax = rankData.maxDmg + directSpBonus,
        -- DoT fields
        dotCoefficient = spellData.dotCoefficient,
        dotSpBonus = dotSpBonus,
        dotBaseDamage = rankData.dotDmg,
        dotDamage = dotDamage,
        tickDamage = tickDamage,
        numTicks = spellData.numTicks,
        duration = spellData.duration,
        -- Combined
        coefficient = spellData.directCoefficient + spellData.dotCoefficient,
        spellPowerBonus = directSpBonus + dotSpBonus,
        totalDamage = directDamage + dotDamage,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeChannel — channeled damage spells (Drain Life, Drain Soul, etc.)
-------------------------------------------------------------------------------
function SpellCalc.ComputeChannel(spellData, rankData, playerState)
    local sp = playerState.stats.spellPower[spellData.school] or 0
    local spBonus = sp * spellData.coefficient
    local totalDmg = rankData.totalDmg + spBonus
    local tickDmg = totalDmg / spellData.numTicks

    return {
        spellData = spellData,
        rankData = rankData,
        avgBaseDamage = rankData.totalDmg,
        coefficient = spellData.coefficient,
        spellPowerBonus = spBonus,
        totalDamage = totalDmg,
        tickDamage = tickDmg,
        numTicks = spellData.numTicks,
        duration = spellData.duration,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeUtility — resource conversion spells (Life Tap)
-------------------------------------------------------------------------------
function SpellCalc.ComputeUtility(spellData, rankData, playerState)
    local sp = playerState.stats.spellPower[spellData.school] or 0
    local spBonus = sp * spellData.coefficient
    local manaGain = rankData.manaGain + spBonus

    return {
        spellData = spellData,
        rankData = rankData,
        coefficient = spellData.coefficient,
        spellPowerBonus = spBonus,
        healthCost = rankData.healthCost,
        manaGain = manaGain,
        castTime = spellData.castTime or 0,
    }
end
