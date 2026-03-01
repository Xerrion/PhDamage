-------------------------------------------------------------------------------
-- Format.lua
-- Shared formatting helpers for Presentation layer (Tooltip, ActionBar)
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local format = string.format
local floor = math.floor

local Format = {}
ns.Format = Format

-------------------------------------------------------------------------------
-- Color Palette (shared across Tooltip and ActionBar)
-------------------------------------------------------------------------------
Format.COLOR_GOLD   = "|cffd1a800"    -- Headers, addon name
Format.COLOR_GREEN  = "|cff00ff00"    -- DPS values, positive modifiers
Format.COLOR_WHITE  = "|cffffffff"    -- Default stat values
Format.COLOR_LABEL  = "|cffc0a060"    -- Dim labels (Coeff, Cast, etc.)
Format.COLOR_RESET  = "|r"

-------------------------------------------------------------------------------
-- Symbol Constants (replace raw UTF-8 escape sequences)
-------------------------------------------------------------------------------
Format.MULTIPLY = "x"     -- crit multiplier prefix
Format.ARROW    = "->"    -- used in utility spells (HP -> mana)
Format.BULLET   = "-"     -- list separator

-------------------------------------------------------------------------------
-- FormatNumber(n)
-- Compact display: 10000+ -> "15k", 1000-9999 -> "1.5k", else integer "581"
-------------------------------------------------------------------------------
function Format.FormatNumber(n)
    if n == nil then return "?" end
    if n >= 10000 then
        return format("%.0fk", n / 1000)
    elseif n >= 1000 then
        return format("%.1fk", n / 1000)
    else
        return tostring(floor(n + 0.5))
    end
end

-------------------------------------------------------------------------------
-- FormatDPS(n)
-- DPS/HPS with one decimal place, "k" suffix for large values.
-------------------------------------------------------------------------------
function Format.FormatDPS(n)
    if n == nil then return "?" end
    if n >= 10000 then
        return format("%.0fk", n / 1000)
    elseif n >= 1000 then
        return format("%.1fk", n / 1000)
    else
        return format("%.1f", n)
    end
end

-------------------------------------------------------------------------------
-- GetSchoolColor(school)
-- Returns the WoW color escape code for a spell school bitmask.
-- Falls back to white for unknown schools.
-------------------------------------------------------------------------------
function Format.GetSchoolColor(school)
    return ns.SCHOOL_COLORS and ns.SCHOOL_COLORS[school] or Format.COLOR_WHITE
end

-------------------------------------------------------------------------------
-- ColorValue(text, school)
-- Wraps a string in school color codes with reset.
-------------------------------------------------------------------------------
function Format.ColorValue(text, school)
    return Format.GetSchoolColor(school) .. text .. Format.COLOR_RESET
end
