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

## Wowhead Research

Use the `wowhead-researcher` agent (defined in the project-level `opencode.json`) for all Wowhead data lookups. This agent has its own persistent Playwright browser with cookies stored between sessions.

### When to Use

- Verifying spell damage values and ranks for a new class
- Checking talent tooltip text for exact per-rank percentages  
- Confirming aura/buff effects and their spell IDs
- Validating that a class spell list is complete

### Invocation

```
task(subagent_type="wowhead-researcher", prompt="Look up all ranks of Fireball for Mage on Wowhead TBC Classic...")
```

### Key URL Patterns

| Purpose | URL Pattern |
|---------|------------|
| Class spell list | `https://www.wowhead.com/tbc/class={classID}/{classname}#spells;type:7;{offset}+1-3+10` |
| Individual spell | `https://www.wowhead.com/tbc/spell={spellID}` |
| Spell tooltip JSON | `https://www.wowhead.com/tbc/tooltip/spell/{spellID}` |

### Class IDs

1=Warrior, 2=Paladin, 3=Hunter, 4=Rogue, 5=Priest, 7=Shaman, 8=Mage, 9=Warlock, 11=Druid

### Verification Checklist (New Class)

1. Open class spell list page, paginate through all offsets (0, 50, 100, ...)
2. Filter to damage-dealing abilities only (type:7)
3. For each spell, open individual spell page to get all rank IDs and damage values
4. Cross-reference rank count against in-game talent calculator
5. Confirm base spellID = Rank 1 spellID

---

## Current Scope

- **Phase 1-5**: Complete — TBC Anniversary, Warlock + Hunter + Mage, diagnostics + tooltip + action bar
- **Phase 6** (active): Mage class support
- **Future**: Additional classes (Priest, Shaman, Druid, Paladin), multi-version support, options panel
