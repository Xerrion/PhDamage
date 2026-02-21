# PhDamage — Agent Guidelines

Project-specific rules for the PhDamage addon. See the parent `AGENTS.md` for general WoW addon development rules.

---

## Architecture

PhDamage uses a strict 4-layer architecture:

| Layer | Directory | Rule |
|-------|-----------|------|
| Shell | `Core/` | Only layer that calls WoW APIs |
| Engine | `Engine/` | **Pure Lua only** — zero WoW API calls, zero WoW globals |
| Data | `Data/` | Declarative tables only — no functions, no WoW API calls |
| Presentation | `Presentation/` | May call WoW APIs for display (chat output, tooltips) |

### Engine Purity Rule

Files in `Engine/` must NEVER reference WoW API functions (GetSpellBonusDamage, UnitLevel, CreateFrame, etc.) or WoW global variables (DEFAULT_CHAT_FRAME, Enum, etc.). They receive plain Lua tables and return plain Lua tables. This makes the engine testable outside of WoW.

### Data Layer Rule

Files in `Data/` contain only declarative table definitions. No computation logic, no functions as values, no WoW API calls. All modifier effects use descriptor tables (type + value + filter), never callback functions.

---

## Namespace Convention

All files share the addon namespace via `local ADDON_NAME, ns = ...`

Sub-namespaces:
- `ns.Addon` — The AceAddon object
- `ns.SpellData` — Spell definitions (populated by Data/SpellData_*.lua)
- `ns.TalentMap` — Talent modifiers (populated by Data/TalentMap_*.lua)
- `ns.AuraMap` — Aura modifiers (populated by Data/AuraMap_*.lua)
- `ns.Engine.Pipeline` — Main computation pipeline
- `ns.Engine.SpellCalc` — Base damage computation
- `ns.Engine.ModifierCalc` — Modifier application
- `ns.Engine.CritCalc` — Crit/hit expected value
- `ns.StateCollector` — WoW API → PlayerState bridge
- `ns.Events` — Event registration
- `ns.Diagnostics` — Slash command output
- `ns.Tooltip` — Tooltip hook and spell display
- `ns.ActionBar` — Action bar overlay management

---

## Data Sources

- **Spell base values, coefficients, talent effects**: Wowhead TBC Classic (https://www.wowhead.com/tbc/)
- **Aura spellIDs**: Verify in-game with `/dump GetPlayerAuraBySpellID(id)`
- **Talent tree indices**: Verify in-game with `/dump GetTalentInfo(tab, index)`

---

## Adding a New Class

1. Create `Data/SpellData_<Class>.lua` — spell definitions keyed by base spellID
2. Create `Data/TalentMap_<Class>.lua` — talent modifiers keyed by "tab:index"
3. Create `Data/AuraMap_<Class>.lua` — buff/debuff modifiers keyed by spellID
4. Add all three files to `PhDamage.toc` in the Data section
5. The engine (Pipeline, SpellCalc, ModifierCalc, CritCalc) requires no changes — it's class-agnostic

---

## Adding a New Modifier Type

1. Add the constant to `ns.MOD` in `Core/Constants.lua`
2. Add handling in `Engine/ModifierCalc.lua` → `ApplyEffect()` function
3. Use the new type in TalentMap or AuraMap descriptors

---

## Modifier Descriptor Format

```lua
{
    type = ns.MOD.DAMAGE_MULTIPLIER,  -- required: modifier type constant
    value = 0.02,                      -- required: modifier value (delta, NOT full multiplier)
    perRank = true,                    -- optional: multiply value by talent rank
    filter = {                         -- optional: restrict which spells this affects
        school = ns.SCHOOL_SHADOW,     -- exact school match
        schools = { SCHOOL_FIRE, ... },-- any school in list
        spellType = "dot",             -- spell type match
        spellNames = { "Shadow Bolt" },-- spell name in list
        spellID = 686,                 -- exact spellID match
    },
}
```

**IMPORTANT**: DAMAGE_MULTIPLIER values are DELTAS (e.g., 0.15 for +15%), not full multipliers (NOT 1.15). The engine computes `finalMult = baseMult * (1 + delta)`.

---

## Current Scope

- **Phase 1**: TBC Anniversary only, Warlock only, diagnostics slash command only
- **Phase 2** (active): Tooltip hooks, actionbar text overlay
- **Future**: Additional classes, multi-version support, options panel
