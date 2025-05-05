#!/bin/sh

profile=$(powerprofilesctl get)

# Icons für jedes Profil
case $profile in
    "performance") icon="🔥" ;;
    "balanced") icon="⚖️" ;;
    "power-saver") icon="💤" ;;
    *) icon="❓" ;;
esac

# Liste aller Profile mit Status (aktiv oder nicht)
tooltip=$(powerprofilesctl list | sed "s/\*$//" | awk '{print ($1 == "'$profile'") ? "• " $1 " (aktiv)" : "  " $1}')

# Ausgabe für Waybar: Erst Icon, dann Tooltip
echo "$icon"
echo "$tooltip"
