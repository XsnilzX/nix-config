# 💻 NixOS Laptop Config

Dies ist meine persönliche NixOS-Konfiguration für meinen Laptop. Sie basiert auf [flakes](https://nixos.wiki/wiki/Flakes) und ist modular aufgebaut, um langfristig wartbar und erweiterbar zu bleiben. Das ganze Projekt ist Work in Progress.

## ✨ Features

- Modular aufgebaute Systemkonfiguration
- Home-Manager für benutzerbezogene Einstellungen
- Flake-basiert für reproduzierbare Builds

## 📁 Struktur

```text
.
├── flake.nix        # Einstiegspunkt für das System
├── flake.lock       # Abhängigkeitensperre
├── hosts/laptop     # Laptop-spezifische Konfiguration
├── modules/         # Eigene NixOS-Module
└── home/            # Home-Manager Setup

```

## 🚀 Installation

```bash
git clone https://github.com/XsnilzX/nixconfig.git
cd nixconfig
nixos-install --flake .#laptop
```

## 📝 Lizenz

Dieses Projekt ist unter der [MIT-Lizenz](LICENSE) lizenziert.
