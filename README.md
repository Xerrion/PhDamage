<div align="center">

# PhDamage

*Expected damage and healing calculator for your World of Warcraft adventures.*

[![Latest Release](https://img.shields.io/github/v/release/Xerrion/PhDamage?style=for-the-badge)](https://github.com/Xerrion/PhDamage/releases/latest)
[![License](https://img.shields.io/github/license/Xerrion/PhDamage?style=for-the-badge)](LICENSE)
[![WoW Version](https://img.shields.io/badge/WoW-TBC%20Anniversary-blue?style=for-the-badge&logo=battledotnet)](https://worldofwarcraft.blizzard.com/)
[![Lint](https://img.shields.io/github/actions/workflow/status/Xerrion/PhDamage/lint.yml?style=for-the-badge&label=lint)](https://github.com/Xerrion/PhDamage/actions)

</div>

## 🎯 Features

- Real-time expected damage and healing on spell tooltips, accounting for hit chance, crit chance, and talent modifiers
- Action bar overlays showing expected damage directly on your buttons
- School-colored companion tooltip with spell name, rank, and full stat breakdown
- All 9 classes supported: Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock, Warrior
- All spell types: direct, DoT, channel, hybrid, melee, ranged, and utility
- Automatically updates when your talents, gear, buffs, or debuffs change
- ElvUI skin matching when detected
- Lightweight with no runtime overhead - calculations only trigger on state changes

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

1. Download the latest release from one of the sources above
2. Extract the `PhDamage` folder into your AddOns directory:

   ```text
   World of Warcraft/_anniversary_/Interface/AddOns/PhDamage/
   ```

3. Restart WoW or type `/reload`

## ⌨️ Commands

All commands use the `/phd` prefix (or the full `/phdamage`):

| Command            | Description                              |
|:-------------------|:-----------------------------------------|
| `/phd`             | Show diagnostic information for all spells |
| `/phd state`       | Show current player state snapshot       |
| `/phd spell <name>` | Detailed breakdown for a specific spell |
| `/phd help`        | List available commands                  |

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for setup, coding standards, and the PR process. All contributors are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## ❤️ Support

If you would like to support PhDamage, you can sponsor the project on [GitHub Sponsors](https://github.com/sponsors/Xerrion) or buy me a coffee on [Ko-fi](https://ko-fi.com/Xerrion).

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](https://github.com/Xerrion/PhDamage/blob/master/LICENSE) file for details.

Made with ❤️ by [Xerrion](https://github.com/Xerrion)
