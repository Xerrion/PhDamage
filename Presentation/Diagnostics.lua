-------------------------------------------------------------------------------
-- Diagnostics.lua
-- Slash command diagnostic output for PhDamage
-- Provides /phd, /phd state, /phd spell <name> commands
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local Diagnostics = {}
ns.Diagnostics = Diagnostics

-- Color codes
local COLOR_HEADER = "|cff00ccff"   -- cyan
local COLOR_SPELL = "|cffffcc00"    -- gold
local COLOR_VALUE = "|cffffffff"    -- white
local COLOR_LABEL = "|cffaaaaaa"    -- gray
local COLOR_GOOD = "|cff00ff00"     -- green
local COLOR_RESET = "|r"

-- School-specific colors
local SCHOOL_COLORS = {
    [ns.SCHOOL_SHADOW]   = "|cff9b59b6",
    [ns.SCHOOL_FIRE]     = "|cffe74c3c",
    [ns.SCHOOL_HOLY]     = "|cfff1c40f",
    [ns.SCHOOL_NATURE]   = "|cff2ecc71",
    [ns.SCHOOL_FROST]    = "|cff3498db",
    [ns.SCHOOL_ARCANE]   = "|cff1abc9c",
    [ns.SCHOOL_PHYSICAL] = "|cffbdc3c7",
}

-- Decorative line characters (WoW chat supports UTF-8)
local LINE_DOUBLE = string.rep("\226\149\144", 40)  -- ═ repeated
local LINE_SINGLE = string.rep("\226\148\128", 28)  -- ─ repeated

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

function Diagnostics.Print(msg)
    ns.Addon:Print(msg)
end

function Diagnostics.FormatNumber(n)
    if n == nil then
        return "?"
    end
    if n == math.floor(n) then
        return tostring(math.floor(n))
    end
    return string.format("%.1f", n)
end

function Diagnostics.FormatPercent(fraction)
    if fraction == nil then
        return "?"
    end
    return string.format("%.1f%%", fraction * 100)
end

function Diagnostics.GetSchoolColor(school)
    return SCHOOL_COLORS[school] or COLOR_VALUE
end

local function GetSchoolName(school)
    return ns.SCHOOL_NAMES[school] or "Unknown"
end

local function SafeCoefficient(coeff)
    return (coeff and coeff > 0) and coeff or 1
end

local function LabelValue(label, value)
    return COLOR_LABEL .. label .. ": " .. COLOR_RESET .. COLOR_VALUE .. value .. COLOR_RESET
end

-------------------------------------------------------------------------------
-- PrintAll()
-- Dump all spell computations: header + one-line summary per spell
-------------------------------------------------------------------------------
function Diagnostics.PrintAll()
    local state = ns.StateCollector.GetCachedState()
    if not state then
        Diagnostics.Print("No player state available.")
        return
    end

    local results = ns.Engine.Pipeline.CalculateAll(state)
    if not results or #results == 0 then
        Diagnostics.Print("No spells computed. Is spell data loaded for your class?")
        return
    end

    -- Header
    local className = state.class or "Unknown"
    local level = state.level or "?"
    Diagnostics.Print(COLOR_HEADER .. "PhDamage \226\128\148 "
        .. className .. " (Level " .. level .. ")" .. COLOR_RESET)
    Diagnostics.Print(COLOR_HEADER .. LINE_DOUBLE .. COLOR_RESET)

    for _, r in ipairs(results) do
        Diagnostics.PrintSpellSummary(r)
    end
end

-------------------------------------------------------------------------------
-- PrintSpellSummary(r)
-- One-line + detail line for a single SpellResult in the PrintAll list
-------------------------------------------------------------------------------
function Diagnostics.PrintSpellSummary(r)
    local FN = Diagnostics.FormatNumber
    local FP = Diagnostics.FormatPercent
    local schoolColor = Diagnostics.GetSchoolColor(r.school)
    local rankStr = r.rank and (" (R" .. r.rank .. ")") or ""

    if r.spellType == "utility" then
        -- Life Tap style: health cost → mana gain
        Diagnostics.Print(
            COLOR_SPELL .. r.spellName .. rankStr .. COLOR_RESET .. ": "
            .. COLOR_VALUE .. FN(r.healthCost) .. COLOR_RESET .. " HP \226\134\146 "
            .. COLOR_GOOD .. FN(r.manaGain) .. COLOR_RESET .. " mana"
        )
        Diagnostics.Print(
            "  " .. LabelValue("Coeff", string.format("%.4f", r.coefficient or 0))
            .. " | " .. LabelValue("+SP", FN(r.spellPowerBonus))
        )
        return
    end

    if r.spellType == "hybrid" then
        -- Immolate style: direct + DoT
        local castStr = r.castTime and (FN(r.castTime) .. "s cast") or "instant"
        Diagnostics.Print(
            COLOR_SPELL .. r.spellName .. rankStr .. COLOR_RESET .. ": "
            .. COLOR_VALUE .. FN(r.directDamage) .. COLOR_RESET .. " direct + "
            .. COLOR_VALUE .. FN(r.dotDamage) .. COLOR_RESET .. " DoT expected | "
            .. castStr
        )
        local directBase = r.baseDamage
            and (FN((r.baseDamage.min + r.baseDamage.max) / 2))
            or FN(r.avgBaseDamage)
        Diagnostics.Print(
            "  " .. LabelValue("Direct", directBase .. " base + " .. FN(r.spellPowerBonus) .. " SP")
            .. " | " .. LabelValue("Crit", r.critChance > 0
                and (FP(r.critChance) .. " (\195\151" .. string.format("%.2f", r.critMultiplier) .. ")")
                or "n/a")
        )
        return
    end

    if r.isDot or r.spellType == "dot" then
        -- Pure DoT
        local durStr = r.duration and (FN(r.duration) .. "s DoT") or "DoT"
        Diagnostics.Print(
            COLOR_SPELL .. r.spellName .. rankStr .. COLOR_RESET .. ": "
            .. schoolColor .. FN(r.expectedDamageWithMiss) .. COLOR_RESET .. " expected | "
            .. durStr .. " | "
            .. COLOR_GOOD .. FN(r.dps) .. " DPS" .. COLOR_RESET
        )
        Diagnostics.Print(
            "  " .. LabelValue("Base", FN(r.avgBaseDamage))
            .. " | " .. LabelValue("+SP", FN(r.spellPowerBonus))
            .. " | " .. LabelValue("Crit", "n/a")
        )
        return
    end

    if r.isChanneled or r.spellType == "channel" then
        -- Channel
        local durStr = r.duration and (FN(r.duration) .. "s channel") or "channel"
        Diagnostics.Print(
            COLOR_SPELL .. r.spellName .. rankStr .. COLOR_RESET .. ": "
            .. schoolColor .. FN(r.expectedDamageWithMiss) .. COLOR_RESET .. " expected | "
            .. durStr .. " | "
            .. COLOR_GOOD .. FN(r.dps) .. " DPS" .. COLOR_RESET
        )
        Diagnostics.Print(
            "  " .. LabelValue("Base", FN(r.avgBaseDamage))
            .. " | " .. LabelValue("+SP", FN(r.spellPowerBonus))
            .. " | " .. LabelValue("Ticks", (r.numTicks or "?") .. "\195\151" .. FN(r.tickDamage))
        )
        return
    end

    -- Direct damage (Shadow Bolt, etc.)
    local castStr = (r.castTime and r.castTime > 0)
        and (FN(r.castTime) .. "s cast")
        or "instant"
    Diagnostics.Print(
        COLOR_SPELL .. r.spellName .. rankStr .. COLOR_RESET .. ": "
        .. schoolColor .. FN(r.expectedDamageWithMiss) .. COLOR_RESET .. " expected | "
        .. castStr .. " | "
        .. COLOR_GOOD .. FN(r.dps) .. " DPS" .. COLOR_RESET
    )
    local critStr = r.critChance > 0
        and (FP(r.critChance) .. " (\195\151" .. string.format("%.2f", r.critMultiplier) .. ")")
        or "n/a"
    Diagnostics.Print(
        "  " .. LabelValue("Base", FN(r.avgBaseDamage))
        .. " | " .. LabelValue("+SP", FN(r.spellPowerBonus))
        .. " | " .. LabelValue("Crit", critStr)
    )
end

-------------------------------------------------------------------------------
-- PrintSpell(spellName)
-- Detailed breakdown for a single spell
-------------------------------------------------------------------------------
function Diagnostics.PrintSpell(spellName)
    if not spellName or spellName == "" then
        Diagnostics.Print("Usage: /phd spell <name>")
        return
    end

    local state = ns.StateCollector.GetCachedState()
    if not state then
        Diagnostics.Print("No player state available.")
        return
    end

    local r = ns.Engine.Pipeline.CalculateByName(spellName, state)
    if not r then
        Diagnostics.Print("Spell not found: " .. COLOR_SPELL .. spellName .. COLOR_RESET)
        return
    end

    local FN = Diagnostics.FormatNumber
    local FP = Diagnostics.FormatPercent
    local schoolColor = Diagnostics.GetSchoolColor(r.school)
    local schoolName = GetSchoolName(r.school)
    local rankStr = r.rank and ("Rank " .. r.rank) or ""

    -- Header
    Diagnostics.Print(
        COLOR_SPELL .. r.spellName .. COLOR_RESET
        .. (rankStr ~= "" and (" (" .. rankStr .. ")") or "")
        .. " \226\128\148 " .. schoolColor .. schoolName .. COLOR_RESET
    )
    Diagnostics.Print(COLOR_LABEL .. LINE_SINGLE .. COLOR_RESET)

    if r.spellType == "utility" then
        Diagnostics.PrintSpellUtility(r, FN, FP)
        return
    end

    if r.spellType == "hybrid" then
        Diagnostics.PrintSpellHybrid(r, FN, FP, schoolColor, schoolName)
        return
    end

    if r.spellType == "dot" then
        Diagnostics.PrintSpellDot(r, FN, FP, schoolColor, schoolName)
        return
    end

    if r.spellType == "channel" then
        Diagnostics.PrintSpellChannel(r, FN, FP, schoolColor, schoolName)
        return
    end

    -- Direct damage
    Diagnostics.PrintSpellDirect(r, FN, FP, schoolColor, schoolName)
end

-------------------------------------------------------------------------------
-- PrintSpellDirect — detailed direct damage spell
-------------------------------------------------------------------------------
function Diagnostics.PrintSpellDirect(r, FN, FP, schoolColor, schoolName)
    if r.baseDamage then
        Diagnostics.Print("  " .. LabelValue("Base damage",
            FN(r.baseDamage.min) .. " - " .. FN(r.baseDamage.max)
            .. " (avg " .. FN(r.avgBaseDamage) .. ")"))
    else
        Diagnostics.Print("  " .. LabelValue("Base damage", FN(r.avgBaseDamage)))
    end
    Diagnostics.Print("  " .. LabelValue("SP coefficient", string.format("%.4f", r.coefficient or 0)))
    Diagnostics.Print("  " .. LabelValue("Spell power",
        schoolColor .. FN(r.spellPowerBonus / SafeCoefficient(r.coefficient)) .. " " .. schoolName .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("SP contribution",
        COLOR_GOOD .. "+" .. FN(r.spellPowerBonus) .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("Damage before mods", FN(r.damageBeforeMods)))
    Diagnostics.Print("  " .. LabelValue("Damage after mods", FN(r.damageAfterMods)))
    Diagnostics.Print("  " .. LabelValue("Duration",
        FN(r.duration) .. "s (" .. (r.numTicks or "?") .. " ticks)"))
    Diagnostics.Print("  " .. LabelValue("Per tick", FN(r.tickDamage)))
    Diagnostics.Print("  " .. LabelValue("Expected total", COLOR_VALUE .. FN(r.expectedDamage) .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("Hit chance", FP(r.hitChance)))
    Diagnostics.Print("  " .. LabelValue("Expected with miss",
        schoolColor .. FN(r.expectedDamageWithMiss) .. COLOR_RESET))
    local castStr = (r.castTime and r.castTime > 0) and (FN(r.castTime) .. "s") or "instant"
    Diagnostics.Print("  " .. LabelValue("Cast time", castStr))
    Diagnostics.Print("  " .. LabelValue("DPS", COLOR_GOOD .. FN(r.dps) .. COLOR_RESET))
end

-------------------------------------------------------------------------------
-- PrintSpellChannel — detailed channel spell
-------------------------------------------------------------------------------
function Diagnostics.PrintSpellChannel(r, FN, FP, schoolColor, schoolName)
    Diagnostics.Print("  " .. LabelValue("Total base damage", FN(r.avgBaseDamage)))
    Diagnostics.Print("  " .. LabelValue("SP coefficient", string.format("%.4f", r.coefficient or 0)))
    Diagnostics.Print("  " .. LabelValue("Spell power",
        schoolColor .. FN(r.spellPowerBonus / SafeCoefficient(r.coefficient)) .. " " .. schoolName .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("SP contribution",
        COLOR_GOOD .. "+" .. FN(r.spellPowerBonus) .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("Damage before mods", FN(r.damageBeforeMods)))
    Diagnostics.Print("  " .. LabelValue("Damage after mods", FN(r.damageAfterMods)))
    Diagnostics.Print("  " .. LabelValue("Channel duration",
        FN(r.duration) .. "s (" .. (r.numTicks or "?") .. " ticks)"))
    Diagnostics.Print("  " .. LabelValue("Per tick", FN(r.tickDamage)))
    Diagnostics.Print("  " .. LabelValue("Expected total", COLOR_VALUE .. FN(r.expectedDamage) .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("Hit chance", FP(r.hitChance)))
    Diagnostics.Print("  " .. LabelValue("Expected with miss",
        schoolColor .. FN(r.expectedDamageWithMiss) .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("DPS", COLOR_GOOD .. FN(r.dps) .. COLOR_RESET))
end

-------------------------------------------------------------------------------
-- PrintSpellHybrid — detailed hybrid spell (Immolate)
-------------------------------------------------------------------------------
function Diagnostics.PrintSpellHybrid(r, FN, FP, schoolColor, schoolName)
    -- Direct portion
    Diagnostics.Print("  " .. COLOR_HEADER .. "Direct Portion" .. COLOR_RESET)
    if r.baseDamage then
        Diagnostics.Print("    " .. LabelValue("Base damage",
            FN(r.baseDamage.min) .. " - " .. FN(r.baseDamage.max)
            .. " (avg " .. FN((r.baseDamage.min + r.baseDamage.max) / 2) .. ")"))
    else
        Diagnostics.Print("    " .. LabelValue("Base damage", FN(r.avgBaseDamage)))
    end
    Diagnostics.Print("    " .. LabelValue("Expected direct",
        COLOR_VALUE .. FN(r.directDamage) .. COLOR_RESET))

    -- DoT portion
    Diagnostics.Print("  " .. COLOR_HEADER .. "DoT Portion" .. COLOR_RESET)
    Diagnostics.Print("    " .. LabelValue("Duration",
        FN(r.duration) .. "s (" .. (r.numTicks or "?") .. " ticks)"))
    Diagnostics.Print("    " .. LabelValue("Per tick", FN(r.tickDamage)))
    Diagnostics.Print("    " .. LabelValue("Total DoT",
        COLOR_VALUE .. FN(r.dotDamage) .. COLOR_RESET))

    -- Combined
    Diagnostics.Print("  " .. COLOR_HEADER .. "Combined" .. COLOR_RESET)
    Diagnostics.Print("    " .. LabelValue("SP coefficient", string.format("%.4f", r.coefficient or 0)))
    Diagnostics.Print("    " .. LabelValue("SP contribution",
        COLOR_GOOD .. "+" .. FN(r.spellPowerBonus) .. COLOR_RESET))
    Diagnostics.Print("    " .. LabelValue("Crit chance",
        r.critChance > 0
            and (FP(r.critChance) .. " (\195\151" .. string.format("%.2f", r.critMultiplier)
                .. " multiplier, direct only)")
            or "n/a"))
    Diagnostics.Print("    " .. LabelValue("Expected total", COLOR_VALUE .. FN(r.expectedDamage) .. COLOR_RESET))
    Diagnostics.Print("    " .. LabelValue("Hit chance", FP(r.hitChance)))
    Diagnostics.Print("    " .. LabelValue("Expected with miss",
        schoolColor .. FN(r.expectedDamageWithMiss) .. COLOR_RESET))
    local castStr = (r.castTime and r.castTime > 0) and (FN(r.castTime) .. "s") or "instant"
    Diagnostics.Print("    " .. LabelValue("Cast time", castStr))
    Diagnostics.Print("    " .. LabelValue("DPS", COLOR_GOOD .. FN(r.dps) .. COLOR_RESET))
end

-------------------------------------------------------------------------------
-- PrintSpellUtility — detailed utility spell (Life Tap)
-------------------------------------------------------------------------------
function Diagnostics.PrintSpellUtility(r, FN, FP)
    Diagnostics.Print("  " .. LabelValue("Health cost", COLOR_VALUE .. FN(r.healthCost) .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("Mana gained", COLOR_GOOD .. FN(r.manaGain) .. COLOR_RESET))
    Diagnostics.Print("  " .. LabelValue("SP coefficient", string.format("%.4f", r.coefficient or 0)))
    Diagnostics.Print("  " .. LabelValue("SP contribution",
        COLOR_GOOD .. "+" .. FN(r.spellPowerBonus) .. COLOR_RESET))
    local castStr = (r.castTime and r.castTime > 0) and (FN(r.castTime) .. "s") or "instant"
    Diagnostics.Print("  " .. LabelValue("Cast time", castStr))
end

-------------------------------------------------------------------------------
-- PrintState()
-- Dump the current PlayerState snapshot
-------------------------------------------------------------------------------
function Diagnostics.PrintState()
    local state = ns.StateCollector.GetCachedState()
    if not state then
        Diagnostics.Print("No player state available.")
        return
    end

    local FN = Diagnostics.FormatNumber
    local FP = Diagnostics.FormatPercent

    -- Header
    Diagnostics.Print(COLOR_HEADER .. "PhDamage \226\128\148 Player State" .. COLOR_RESET)
    Diagnostics.Print(COLOR_HEADER .. LINE_DOUBLE .. COLOR_RESET)

    -- Class and level
    Diagnostics.Print(
        LabelValue("Class", state.class or "?")
        .. " | " .. LabelValue("Level", tostring(state.level or "?")))

    -- Spell Power per school
    Diagnostics.Print("")
    Diagnostics.Print(COLOR_HEADER .. "Spell Power:" .. COLOR_RESET)
    local spLine = {}
    for _, school in ipairs(ns.MAGIC_SCHOOLS) do
        local name = GetSchoolName(school)
        local color = Diagnostics.GetSchoolColor(school)
        local sp = state.stats.spellPower[school] or 0
        spLine[#spLine + 1] = color .. name .. ": " .. COLOR_VALUE .. FN(sp) .. COLOR_RESET
    end
    Diagnostics.Print("  " .. table.concat(spLine, " | "))

    -- Healing power
    Diagnostics.Print(LabelValue("Healing Power", FN(state.stats.healingPower or 0)))

    -- Spell Crit per school
    Diagnostics.Print("")
    Diagnostics.Print(COLOR_HEADER .. "Spell Crit:" .. COLOR_RESET)
    local critLine = {}
    for _, school in ipairs(ns.MAGIC_SCHOOLS) do
        local name = GetSchoolName(school)
        local color = Diagnostics.GetSchoolColor(school)
        local crit = state.stats.spellCrit[school] or 0
        critLine[#critLine + 1] = color .. name .. ": " .. COLOR_VALUE .. FP(crit) .. COLOR_RESET
    end
    Diagnostics.Print("  " .. table.concat(critLine, " | "))

    -- Spell Hit and Haste
    Diagnostics.Print(LabelValue("Spell Hit", FP(state.stats.spellHit or 0)))
    Diagnostics.Print(LabelValue("Spell Haste", FP(state.stats.spellHaste or 0)))

    -- Mana Regen
    if state.stats.manaRegen then
        Diagnostics.Print(
            LabelValue("Mana Regen",
                FN(state.stats.manaRegen.base or 0) .. " base / "
                .. FN(state.stats.manaRegen.casting or 0) .. " casting"))
    end

    -- Talents
    Diagnostics.Print("")
    Diagnostics.Print(COLOR_HEADER .. "Talents (active):" .. COLOR_RESET)
    local talentLines = {}
    local sortedKeys = {}
    for key, rank in pairs(state.talents) do
        if rank > 0 then
            sortedKeys[#sortedKeys + 1] = key
        end
    end
    table.sort(sortedKeys, function(a, b)
        local aTab, aIdx = a:match("^(%d+):(%d+)$")
        local bTab, bIdx = b:match("^(%d+):(%d+)$")
        aTab, aIdx = tonumber(aTab), tonumber(aIdx)
        bTab, bIdx = tonumber(bTab), tonumber(bIdx)
        if aTab ~= bTab then
            return aTab < bTab
        end
        return aIdx < bIdx
    end)

    for _, key in ipairs(sortedKeys) do
        local rank = state.talents[key]
        local entry = ns.TalentMap[key]
        local name = entry and entry.name or key
        local maxRank = entry and entry.maxRank or "?"
        talentLines[#talentLines + 1] = COLOR_LABEL .. key .. COLOR_RESET .. " "
            .. COLOR_VALUE .. name .. COLOR_RESET
            .. " (" .. rank .. "/" .. maxRank .. ")"
    end

    if #talentLines > 0 then
        -- Print talents in groups of 2 per line for readability
        for i = 1, #talentLines, 2 do
            local line = "  " .. talentLines[i]
            if talentLines[i + 1] then
                line = line .. " | " .. talentLines[i + 1]
            end
            Diagnostics.Print(line)
        end
    else
        Diagnostics.Print("  " .. COLOR_LABEL .. "(none)" .. COLOR_RESET)
    end

    -- Auras
    Diagnostics.Print("")
    Diagnostics.Print(COLOR_HEADER .. "Active Auras:" .. COLOR_RESET)

    local function PrintAuras(label, auraSet)
        local names = {}
        for spellID, _ in pairs(auraSet) do
            local entry = ns.AuraMap[spellID]
            local name = entry and entry.name or ("ID:" .. spellID)
            names[#names + 1] = name
        end
        table.sort(names)
        if #names > 0 then
            Diagnostics.Print("  " .. COLOR_LABEL .. label .. ": " .. COLOR_RESET
                .. COLOR_VALUE .. table.concat(names, ", ") .. COLOR_RESET)
        else
            Diagnostics.Print("  " .. COLOR_LABEL .. label .. ": (none)" .. COLOR_RESET)
        end
    end

    PrintAuras("Player", state.auras.player or {})
    PrintAuras("Target", state.auras.target or {})
end
