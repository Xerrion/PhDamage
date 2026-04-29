<div align="center">

# PhDamage

*Expected damage and healing calculator for your World of Warcraft adventures.*

[![Latest Release](https://img.shields.io/github/v/release/Xerrion/PhDamage?style=for-the-badge)](https://github.com/Xerrion/PhDamage/releases/latest)
[![License](https://img.shields.io/github/license/Xerrion/PhDamage?style=for-the-badge)](LICENSE)
[![WoW Version](https://img.shields.io/badge/WoW-TBC%20Anniversary-blue?style=for-the-badge&logo=battledotnet)](https://worldofwarcraft.blizzard.com/)
[![Lint](https://img.shields.io/github/actions/workflow/status/Xerrion/PhDamage/lint.yml?style=for-the-badge&label=lint)](https://github.com/Xerrion/PhDamage/actions)

</div>

PhDamage is a high-precision expected damage and healing calculator built specifically for the TBC Anniversary
environment. It dynamically computes spell values by processing the full TBC combat formula - including base values,
spell power coefficients, talent multipliers, and aura modifiers - and projects these results directly onto action
bar buttons and tooltips for real-time performance feedback.

## 🎯 Features

- **Real-Time Computation**: Full TBC formula processing (base + coefficient × spell power, talents, auras) for
  expected damage and healing values.
- **Action Bar Overlay**: Direct visualization of computed values on every action bar button.
- **Configurable UI**: Adjustable overlay placement (anchor, offset), font size, and number abbreviation (k/M suffixes).
- **Deep Tooltip Integration**: Detailed spell breakdown including rank-specific info and modifier impacts.
- **Diagnostic Inspection**: Slash commands to inspect crit chance, modifier stacks, and the current player state.
- **Zero Overhead**: High-performance architecture with cached calculations that only recompute on state changes.
- **Class Support**: Comprehensive data for all 9 classes and all spell types (Direct, DoT, Channel, Hybrid).

## 🎮 Supported Versions

| Version         | Interface | Status     |
|:----------------|:----------|:-----------|
| TBC Anniversary | 20505     | ✅ Primary |

## 📦 Installation

### Download

[![CurseForge](https://img.shields.io/badge/CurseForge-Download-F16436?style=for-the-badge&logo=curseforge)](https://www.curseforge.com/wow/addons/phdamage)
[![Wago](https://img.shields.io/badge/Wago-Download-C1272D?style=for-the-badge)](https://addons.wago.io/addons/phdamage)
[![GitHub](https://img.shields.io/badge/GitHub-Releases-181717?style=for-the-badge&logo=github)](https://github.com/Xerrion/PhDamage/releases/latest)

### Manual Install

1. Download the latest release from one of the sources above.
2. Extract the `PhDamage` folder into your AddOns directory:

   ```text
   World of Warcraft/_anniversary_/Interface/AddOns/PhDamage/
   ```

3. Restart WoW or type `/reload`.

## ⚙️ Configuration

Use `/phd config` to open the options panel (also available via Blizzard Interface > AddOns > PhDamage). All settings
are backed by AceDB profiles and apply immediately without requiring a UI reload.

| Setting            | Range / Values                                                              |
|:-------------------|:----------------------------------------------------------------------------|
| Anchor             | TOPLEFT, TOP, TOPRIGHT, LEFT, CENTER, RIGHT, BOTTOMLEFT, BOTTOM, BOTTOMRIGHT |
| Horizontal Offset  | -50 to 50 px (step 1)                                                       |
| Vertical Offset    | -50 to 50 px (step 1)                                                       |
| Font Size          | 6 to 32 (step 1)                                                            |
| Abbreviate Numbers | Toggle (shortens 1500 to 1.5k)                                              |
| Reset to Defaults  | Button to restore original settings                                         |

## ⌨️ Commands

All commands use the `/phd` prefix (or the full `/phdamage`):

| Command               | Description                                           |
|:----------------------|:------------------------------------------------------|
| `/phd`                | Prints expected damage/healing for all known spells   |
| `/phd state`          | Prints current player state snapshot (stats, auras)   |
| `/phd spell <target>` | Prints computation for one spell (name, spellID, link)|
| `/phd config`         | Opens the options panel                               |
| `/phd help`           | Prints the command list                               |

## 🏗 Architecture

The addon enforces a strict 4-layer separation to ensure the core engine remains pure and testable outside of the
World of Warcraft environment.

| Layer        | Directory        | Responsibility                                                               |
|:-------------|:-----------------|:-----------------------------------------------------------------------------|
| Shell        | `Core/`          | Owns lifecycle, slash commands, and options; the only layer calling WoW APIs |
| Engine       | `Engine/`        | Pure Lua computation pipeline (coefficients, talents, crit); zero WoW deps  |
| Data         | `Data/`          | Declarative tables for spell data, talent maps, and aura modifiers           |
| Presentation | `Presentation/`  | Display logic including action bar overlays and tooltip formatting           |

## 🧪 Development

Contributors should refer to `AGENTS.md` for full coding standards. The project maintains a 36-spec test suite powered
by busted. Run `luacheck .` for linting and `busted --verbose` to verify the engine before submitting pull requests.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for setup, coding standards, and the PR
process. All contributors are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## ❤️ Support

If you would like to support PhDamage, you can sponsor the project on [GitHub Sponsors](https://github.com/sponsors/Xerrion) or buy me a coffee on [Ko-fi](https://ko-fi.com/Xerrion).

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](https://github.com/Xerrion/PhDamage/blob/master/LICENSE) file for details.

Made with ❤️ by [Xerrion](https://github.com/Xerrion)
