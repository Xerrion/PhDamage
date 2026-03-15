# PhDamage - Agent Guidelines

Project-specific rules for the PhDamage addon. See the parent `AGENTS.md` for general WoW addon development rules.

---

## Architecture

PhDamage uses a strict 4-layer architecture:

| Layer | Directory | Rule |
|-------|-----------|------|
| Shell | `Core/` | Only layer that calls WoW APIs |
| Engine | `Engine/` | **Pure Lua only** - zero WoW API calls, zero WoW globals |
| Data | `Data/` | Declarative tables only - no functions, no WoW API calls |
| Presentation | `Presentation/` | May call WoW APIs for display (chat output, tooltips) |

### Engine Purity Rule

Files in `Engine/` must NEVER reference WoW API functions (GetSpellBonusDamage, UnitLevel, CreateFrame, etc.) or WoW global variables (DEFAULT_CHAT_FRAME, Enum, etc.). They receive plain Lua tables and return plain Lua tables. This makes the engine testable outside of WoW.

### Data Layer Rule

Files in `Data/` contain only declarative table definitions. No computation logic, no functions as values, no WoW API calls. All modifier effects use descriptor tables (type + value + filter), never callback functions.

---

## Namespace Convention

All files share the addon namespace via `local ADDON_NAME, ns = ...`

Sub-namespaces:
- `ns.Addon` - The AceAddon object
- `ns.SpellData` - Spell definitions (populated by Data/SpellData_*.lua)
- `ns.TalentMap` - Talent modifiers (populated by Data/TalentMap_*.lua)
- `ns.AuraMap` - Aura modifiers (populated by Data/AuraMap_*.lua)
- `ns.Engine.Pipeline` - Main computation pipeline
- `ns.Engine.SpellCalc` - Base damage computation
- `ns.Engine.ModifierCalc` - Modifier application
- `ns.Engine.CritCalc` - Crit/hit expected value
- `ns.StateCollector` - WoW API → PlayerState bridge
- `ns.Events` - Event registration
- `ns.Diagnostics` - Slash command output
- `ns.Tooltip` - Tooltip hook and spell display
- `ns.ActionBar` - Action bar overlay management

---

## Data Sources

- **Spell base values, coefficients, talent effects**: Wowhead TBC Classic (https://www.wowhead.com/tbc/)
- **Aura spellIDs**: Verify in-game with `/dump GetPlayerAuraBySpellID(id)`
- **Talent tree indices**: Verify in-game with `/dump GetTalentInfo(tab, index)`

---

## Adding a New Class

1. Create `Data/SpellData_<Class>.lua` - spell definitions keyed by base spellID
2. Create `Data/TalentMap_<Class>.lua` - talent modifiers keyed by "tab:index"
3. Create `Data/AuraMap_<Class>.lua` - buff/debuff modifiers keyed by spellID
4. Add all three files to `PhDamage.toc` in the Data section
5. The engine (Pipeline, SpellCalc, ModifierCalc, CritCalc) requires no changes - it's class-agnostic

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

- **Phase 1-5**: Complete - TBC Anniversary, Warlock + Hunter + Mage, diagnostics + tooltip + action bar
- **Phase 6** (active): Mage class support
- **Future**: Additional classes (Priest, Shaman, Druid, Paladin), multi-version support, options panel

---

## CI / CD

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `lint.yml` | `pull_request_target` to `master` | Runs Luacheck and busted tests |
| `release.yml` | Push to `master` | release-please creates/updates a Release PR; dispatches `packager.yml` on release |
| `packager.yml` | `workflow_dispatch` (from release.yml) | Builds and publishes via BigWigsMods packager |

### Branch Protection

- PRs required to merge into `master`
- Luacheck status check must pass
- Branches must be up to date before merging
- No force pushes to `master`
- Squash merge only
- Auto-delete head branches after merge

### Release Flow (release-please)
- **release-please** creates/updates a Release PR on every push to master
- Merging the Release PR creates a git tag + GitHub Release
- release.yml dispatches packager.yml with the tag name via `gh workflow run`
- packager.yml runs BigWigsMods/packager for CurseForge + Wago uploads
- Config: `release-please-config.json`, manifest: `.release-please-manifest.json`
- DO NOT manually create tags - release-please handles versioning

---

## Code Style

### Formatting
- Indent with **4 spaces**, no tabs
- Max line length **120** unless the addon `.luacheckrc` disables it
- Spaces around operators: `local x = 1 + 2`
- No trailing whitespace
- Use plain hyphens (`-`), **never** em or en dashes

### File Header
Every Lua file starts with:

```lua
-------------------------------------------------------------------------------
-- FileName.lua
-- Brief description
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------
```

### Imports and Scoping
- Use the shared namespace: `local ADDON_NAME, ns = ...`
- Cache WoW API and Lua globals used more than once as locals at the top of the file
- Keep addon logic in locals; only SavedVariables and `SLASH_*` are global
- Use `LibStub` for Ace3 or other embedded libs; never global `require`

```lua
local ADDON_NAME, ns = ...
local CreateFrame = CreateFrame
local GetTime = GetTime
local LSM = LibStub("LibSharedMedia-3.0")
```

### Naming

| Element | Convention | Example |
|---------|------------|---------|
| Files | PascalCase | `MyAddon_Core.lua` |
| SavedVariables | PascalCase | `MyAddonDB` |
| Local variables | camelCase | `local currentState` |
| Functions (public or local) | PascalCase | `local function UpdateState()` |
| Constants | UPPER_SNAKE | `local MAX_RETRIES = 5` |
| Slash commands | UPPER_SNAKE | `SLASH_MYADDON1` |
| Color codes | UPPER_SNAKE | `local COLOR_RED = "\|cffff0000"` |
| Unused args | underscore prefix | `local _unused` |

### Types
- Default to plain Lua 5.1 with no annotations
- Only add LuaLS annotations when the file already uses them or for public library APIs
- Keep annotations minimal and accurate; do not introduce new tooling

### Functions and Structure
- Keep functions under 50 lines; extract helpers when longer
- Prefer early returns over deep nesting
- Prefer composition over inheritance
- Keep logic separated by layer when possible: Core (WoW API), Engine (pure Lua),
  Data (tables), Presentation (UI)

### Error Handling
- Use defensive nil checks for optional APIs
- For version differences, prefer `or` fallbacks over runtime version checks
- Use `pcall` for user callbacks or APIs that may be missing in some versions
- Use `error(msg, 2)` for public library input validation (reports at caller site)

---

## Versioning and File Loading
- Do not gate features with runtime version checks
- Split version-specific code into separate files
- Load with TOC `## Interface` / `## Interface-*` directives or packager comment
  directives (`#@retail@`, `#@non-retail@`)

Packager directives are comments locally, so later files can override earlier ones.

---

## Common Pitfalls
- Missing APIs for a target version -- check `docs/` for the exact client build
- Deprecated globals like `COMBATLOGENABLED` and `COMBATLOGDISABLED` (removed in Cata;
  always provide `or` fallbacks)
- Race conditions on `PLAYER_ENTERING_WORLD` -- use a short `C_Timer.After` delay
- Timer leaks -- cancel `C_Timer` or `AceTimer` handles before reusing
- `GetItemInfo` or item data can be nil on first call -- retry with a timer

---

## GitHub Workflow

### Issues
Create issues using the repo's issue templates (`.github/ISSUE_TEMPLATE/`):
- **Bug reports**: Use `bug-report.yml` template. Title prefix: `[Bug]: `
- **Feature requests**: Use `feature-request.yml` template. Title prefix: `[Feature]: `

Create via CLI:
```bash
gh issue create --repo <ORG>/<REPO> --label "bug" --title "[Bug]: <title>" --body "<body matching template fields>"
gh issue create --repo <ORG>/<REPO> --label "enhancement" --title "[Feature]: <title>" --body "<body matching template fields>"
```

### Branches
Use conventional branch prefixes:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feat/` | New feature | `feat/87-mail-toasts` |
| `fix/` | Bug fix | `fix/99-anchor-zorder` |
| `refactor/` | Code improvement | `refactor/96-listener-utils` |

Include the issue number in the branch name when linked to an issue.

### Commits
Use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat: <description> (#issue)` - new feature
- `fix: <description> (#issue)` - bug fix
- `refactor: <description> (#issue)` - code restructuring
- `docs: <description>` - documentation only

### Pull Requests
1. Create PRs via CLI using the repo's `.github/PULL_REQUEST_TEMPLATE.md` format
2. Set the PR title explicitly with `--title`. Do not rely on `gh pr create` defaults.
3. PR titles must use Conventional Commit style and should usually match the primary commit intent.
4. If the branch has multiple commits, write the PR title as a clean Conventional Commit summary of the overall change.
5. Set the PR body explicitly with `--body` or `--body-file`. Do not leave it empty.
6. PR bodies should include short `## Summary`, `## Changes`, and `## Testing` sections.
7. Link to the issue with `Closes #N` in the PR body
8. PRs require passing status checks (luacheck, test) before merge
9. Squash merge only: `gh pr merge <number> --squash`
10. Branches are auto-deleted after merge


#### Board Columns

| Column | Purpose |
|--------|---------|
| To triage | New issues awaiting review |
| Backlog | Accepted but not yet scheduled |
| Ready | Prioritised and ready to pick up |
| In progress | Actively being worked on |
| In review | PR submitted, awaiting review |
| Done | Merged / released |

#### Custom Fields

| Field | Values / Type |
|-------|---------------|
| Priority | P0 (critical), P1 (important), P2 (nice-to-have) |
| Size | XS, S, M, L, XL |
| Estimate | Story points (number) |
| Start date | Date |
| Target date | Date |

#### Workflow

1. **Triage** - New issues land in *To triage*. Assign Priority and Size.
2. **Plan** - Move to *Backlog* or *Ready* depending on urgency.
3. **Start** - Move to *In progress*, create a feature branch, add a comment.
4. **Review** - Open PR, move to *In review*, link the issue.
5. **Ship** - Squash-merge, auto-move to *Done* on close.

---

## Working Agreement for Agents
- Addon-level AGENTS.md overrides root rules when present
- Do not add new dependencies without discussing trade-offs
- Run luacheck before and after changes
- If only manual tests exist, document what you verified in-game
- Verify changes in the game client when possible
- Keep changes small and focused; prefer composition over inheritance

---

## Communication Style

When responding to or commenting on issues, always write in **first-person singular** ("I")
as the repo owner -- never use "we" or "our team". Speak as if you are the developer personally.

**Writing style:**
- Direct, structured, solution-driven. Get to the point fast. Text is a tool, not decoration.
- Think in systems. Break things into flows, roles, rules, and frameworks.
- Bias toward precision. Concrete output, copy-paste-ready solutions, clear constraints. Low
  tolerance for fluff.
- Tone is calm and rational with small flashes of humor and self-awareness.
- When confident in a topic, become more informal and creative.
- When something matters, become sharp and focused.
