# Contributing to PhDamage

Thank you for your interest in contributing to **PhDamage** - a floating combat text replacement addon for World of Warcraft! This guide will help you get started.

## How to Contribute

### Reporting Bugs
- Use the [bug report template](https://github.com/Xerrion/PhDamage/issues/new?template=bug-report.yml)
- Include your WoW version, PhDamage version, and steps to reproduce

### Suggesting Features
- Use the [feature request template](https://github.com/Xerrion/PhDamage/issues/new?template=feature-request.yml)
- Explain the problem your feature would solve

### Contributing Code
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Prerequisites

- World of Warcraft client (Retail, TBC Anniversary, MoP Classic, Cata, or Classic)
- [Lua 5.1](https://www.lua.org/) or [Lua 5.4](https://www.lua.org/) (for linting and testing)
- [Luacheck](https://github.com/mpeterv/luacheck) (for static analysis)
- [Busted](https://olivinelabs.com/busted/) (for unit tests)
- [Git](https://git-scm.com/)

## Development Setup

1. **Fork and clone** the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/PhDamage.git
   cd PhDamage
   ```

2. **Initialize submodules** (for Ace3 and other embedded libraries):
   ```bash
   git submodule update --init --recursive
   ```

3. **Symlink** the addon into your WoW AddOns folder:
   ```bash
   # Windows (PowerShell as Admin)
   New-Item -ItemType SymbolicLink -Path "$env:PROGRAMFILES\World of Warcraft\_retail_\Interface\AddOns\PhDamage" -Target "$(Get-Location)"
   ```

4. **Reload** in-game with `/reload`

## Code Style

### Formatting
- Indent with **4 spaces** (no tabs)
- Max line length: **120 characters**
- Spaces around operators: `local x = 1 + 2`
- No trailing whitespace

### File Header
Every Lua file should start with:
```lua
-------------------------------------------------------------------------------
-- FileName.lua
-- Brief description
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------
```

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | PascalCase | `PhDamage_Core.lua` |
| SavedVariables | PascalCase | `PhDamageDB` |
| Local variables | camelCase | `local damageAmount` |
| Functions | PascalCase | `local function FormatDamage()` |
| Constants | UPPER_SNAKE | `local MAX_FRAMES = 20` |

### Architecture

PhDamage follows a layered architecture:

| Layer | Directory | Purpose |
|-------|-----------|---------|
| Core | `Core/` | WoW API interaction, addon lifecycle |
| Engine | `Engine/` | Pure Lua logic, calculations |
| Data | `Data/` | Static data tables, configuration |
| Presentation | `Presentation/` | UI frames, animations |

### Libraries
PhDamage uses the Ace3 framework:

| Library | Purpose |
|---------|---------|
| AceAddon-3.0 | Addon lifecycle |
| AceEvent-3.0 | Event handling |
| AceDB-3.0 | Saved variables |
| AceConsole-3.0 | Slash commands |

### Error Handling
- Use defensive nil checks for optional APIs
- Use `pcall` for APIs that may be missing in some versions
- Prefer `or` fallbacks over runtime version checks

## Linting

Run luacheck before submitting changes:

```bash
luacheck .
luacheck path/to/File.lua    # single file for fast feedback
```

## Testing

### Automated Tests
PhDamage uses [busted](https://olivinelabs.com/busted/) for unit testing. Tests live in the `tests/` directory.

CI still runs tests with Lua 5.1. Local runs may use Lua 5.1 or Lua 5.4.

Use the repo-local launcher instead of calling `busted` directly. Invoke it with whichever interpreter you want to verify, such as `lua`, `lua5.1`, or `lua5.4`. The launcher asks LuaRocks where `busted.runner` is installed and prepends that rock tree to `package.path` and `package.cpath` for the active interpreter.

```bash
lua tests/RunBusted.lua --verbose            # run all tests
lua tests/RunBusted.lua tests/some_spec.lua  # run a single test file
lua5.4 tests/RunBusted.lua --verbose         # explicitly test under Lua 5.4
```

If `busted --verbose` fails with `module 'busted.runner' not found`, your `busted` wrapper and your active interpreter are using different module paths. The launcher above avoids that mismatch without hard-coded machine-specific paths.

### Manual Testing
1. Load the addon in the target game version
2. Attack a target dummy to verify floating combat text
3. Enable Lua errors: `/console scriptErrors 1`
4. Verify no errors in the error frame

## Submitting Changes

1. **Branch** from `master`:
   ```bash
   git checkout -b feat/your-feature-name
   ```

2. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/):
   ```bash
   git commit -m "feat: add critical hit animation (#42)"
   ```

3. **Push** your branch and open a PR against `master`

4. **Fill out** the PR template and wait for CI checks

### Branch Naming

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feat/` | New feature | `feat/14-busted-ci` |
| `fix/` | Bug fix | `fix/15-damage-display` |
| `docs/` | Documentation | `docs/update-readme` |
| `refactor/` | Code improvement | `refactor/16-engine-cleanup` |

## AI-Assisted Contributions

AI tools are welcome, but you remain responsible for everything you submit. This policy is separate from our [Code of Conduct](CODE_OF_CONDUCT.md).

1. **Disclose it.** Say in the PR description which AI tool you used and how much of the change it produced.
2. **Review it yourself.** You must review, understand, and be able to explain every line you submit. Do not submit unreviewed agent output.
3. **Verify it.** Run `luacheck .` and the busted tests (see [Linting](#linting) and [Testing](#testing)), and test in-game before submitting. Never claim a check passed without running it.
4. **Do not invent APIs.** Do not make up WoW API behaviour. Check it against [warcraft.wiki.gg](https://warcraft.wiki.gg) and Blizzard's FrameXML source.
5. **No spam.** No bulk or drive-by AI-generated issues or PRs. Keep each PR to one scoped change, linked to an issue.
6. **Licensing.** You are responsible for licensing. Do not paste code of unknown origin.
7. **Agent conduct.** AI agents working on your behalf must follow the repo's `AGENTS.md`, never push to `master`, never merge release-please PRs (`chore(master): release X.Y.Z`; the owner merges those), and not touch secrets or workflow permissions without explicit approval.

PR titles must be conventional commits (`feat:`, `fix(scope):`, `chore:` ...). Squash merges use the PR title as the commit message, and release-please derives versions from it.

Maintainers may close undisclosed or unreviewed AI-assisted PRs without review.

## What Happens After Your PR

1. **CI** runs luacheck and busted tests automatically
2. **Review** by a maintainer
3. **Squash merge** into `master`
4. **Release-please** creates a release PR when ready

Thank you for contributing to PhDamage!
