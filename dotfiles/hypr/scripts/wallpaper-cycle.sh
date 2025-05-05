#!/bin/bash

# Konfigurationsvariablen
WALLPAPER_DIR="/home/richard/Bilder/Wallpaper"  # Passe den Pfad an
INTERVAL=300  # Zeit in Sekunden (300 = 5 Minuten)
MONITOR="eDP-1"  # Setze hier deinen Monitor-Namen (z.B. "DP-1", "HDMI-A-1", etc.)
echo "PID: $$ Script: /home/richard/.config/hypr/scripts/wallpaper-cycle.sh" > /tmp/wallpaperscript.txt


# Prüfe ob der Wallpaper-Ordner existiert
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Fehler: Wallpaper-Ordner existiert nicht: $WALLPAPER_DIR"
    exit 1
fi

# Hauptschleife
while true; do
    if [ -d "$WALLPAPER_DIR" ]; then
        # Wähle zufälliges Wallpaper
        random_background=$(ls $WALLPAPER_DIR/*.{jpg,jpeg,png} 2>/dev/null | shuf -n 1)

        # Prüfe ob Wallpaper gefunden wurde
        if [ -n "$random_background" ]; then
            # Lade altes Wallpaper aus und setze neues
            hyprctl hyprpaper unload all
            hyprctl hyprpaper preload "$random_background"
            hyprctl hyprpaper wallpaper "$MONITOR,$random_background"

            echo "Wallpaper gewechselt zu: $random_background"
        else
            echo "Keine Bilder im Ordner gefunden"
            exit 1
        fi
    fi

    # Warte für das eingestellte Interval
    sleep $INTERVAL
done
