#!/usr/bin/env python3

import time
import subprocess
import sys
import json
import tkinter as tk
from tkinter import ttk

def get_cliphist_entries():
    """Holt die cliphist-Einträge und gibt sie als Liste zurück."""
    result = subprocess.run(["cliphist", "list"], capture_output=True, text=True)
    entries = result.stdout.strip().split("\n")
    # print(f"Cliphist-Einträge (roh): {entries}")  # Debugging
    # Extrahiere nur den Textteil (nach dem Tabulator)
    cleaned_entries = []
    for entry in entries:
        if "\t" in entry:
            text_part = entry.split("\t", 1)[1]  # Nimm den Teil nach dem ersten Tabulator
            cleaned_entries.append(text_part)
        else:
            cleaned_entries.append(entry)  # Falls kein Tabulator vorhanden ist
    # print(f"Cliphist-Einträge (bereinigt): {cleaned_entries}")  # Debugging
    return cleaned_entries

def copy_to_clipboard(text):
    """Kopiert den ausgewählten Text in die Zwischenablage."""
    subprocess.run(["wl-copy"], input=text, text=True)  # Für Wayland
    # subprocess.run(["xclip", "-selection", "clipboard"], input=text, text=True)  # Für X11

def delete_entry(entry_text):
    """Löscht einen Eintrag aus der cliphist-History."""
    print(f"Versuche, Eintrag zu löschen: {entry_text}")  # Debugging
    result = subprocess.run(["cliphist", "list"], capture_output=True, text=True)
    entries = result.stdout.strip().split("\n")
    for entry in entries:
        if entry.split("\t")[1] == entry_text:
            entry_id = entry.split("\t")[0]
            print(f"Eintrag gefunden: ID={entry_id}, Text={entry_text}")  # Debugging
            # Führe den Löschbefehl aus und überprüfe die Ausgabe
            process = subprocess.Popen(["cliphist", "delete-query", entry_text], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            stdout, stderr = process.communicate()
            print(f"Stdout: {stdout.decode()}")  # Debugging
            print(f"Stderr: {stderr.decode()}")  # Debugging
            if process.returncode == 0:
                print("Eintrag erfolgreich gelöscht.")  # Debugging
            else:
                print("Fehler beim Löschen des Eintrags.")  # Debugging
            return
    print("Eintrag nicht gefunden.")  # Debugging

def show_selection_window():
    """Zeigt das Fenster mit den cliphist-Einträgen zur Auswahl an."""
    root = tk.Tk()
    root.title("Cliphist History")
    root.attributes("-type", "dialog")  # Fenstertyp als Dialog
    root.geometry("800x550")  # Größeres Fenster (Breite x Höhe)

    # Darkmode-Farben
    bg_color = "#2d2d2d"  # Dunkler Hintergrund
    fg_color = "#ffffff"  # Weiße Schrift
    highlight_color = "#4d4d4d"  # Hervorhebungsfarbe

    # Stil für das Fenster
    root.configure(bg=bg_color)
    style = ttk.Style(root)
    style.theme_use("clam")  # Ein einfaches, anpassbares Theme
    style.configure("TListbox", background=bg_color, foreground=fg_color, selectbackground=highlight_color, selectforeground=fg_color, font=("JetBrainsMono Nerd Font", 14))
    style.configure("TFrame", background=bg_color)
    style.configure("TLabel", background=bg_color, foreground=fg_color)

    # Frame für die Liste
    frame = ttk.Frame(root)
    frame.pack(fill=tk.BOTH, expand=True, padx=4, pady=4)  # Abstand zum Fensterrand

    # Liste der Einträge
    listbox = tk.Listbox(frame, selectmode=tk.SINGLE, bg=bg_color, fg=fg_color, selectbackground=highlight_color, selectforeground=fg_color, font=("JetBrainsMono Nerd Font", 14))
    listbox.pack(fill=tk.BOTH, expand=True)
    listbox.focus_set()  # Fokus auf die Listbox setzen

    def update_listbox():
        """Aktualisiert die Liste der Einträge."""
        listbox.delete(0, tk.END)  # Lösche alle vorhandenen Einträge
        entries = get_cliphist_entries()
        for i, entry in enumerate(entries, start=1):
            listbox.insert(tk.END, f"{i}. {entry}")
        listbox.selection_set(0)  # Ersten Eintrag automatisch auswählen

    # Initialisiere die Liste
    update_listbox()

    # Auswahl-Event binden
    def on_select(event=None):
        selected_index = listbox.curselection()
        if selected_index:
            selected_text = listbox.get(selected_index)
            copy_to_clipboard(selected_text.split(". ", 1)[1])  # Nummer entfernen
            root.destroy()  # Schließe das Fenster nach der Auswahl

    listbox.bind("<<ListboxSelect>>", on_select)
    listbox.bind("<Return>", on_select)  # Enter-Taste für Auswahl

    # Löschen mit der Entf-Taste
    def on_delete(event):
        print("Entf-Taste gedrückt!")  # Debugging
        selected_index = listbox.curselection()
        print(f"Ausgewählter Index: {selected_index}")  # Debugging
        if selected_index:
            selected_text = listbox.get(selected_index)
            print(f"Ausgewählter Text: {selected_text}")  # Debugging
            entry_text = selected_text.split(". ", 1)[1]  # Nummer entfernen
            delete_entry(entry_text)
            time.sleep(1)
            update_listbox()  # Aktualisiere die Liste nach dem Löschen
        else:
            print("Kein Eintrag ausgewählt!")  # Debugging

    listbox.bind("<Delete>", on_delete)

    # Pfeiltasten für Navigation
    def on_key(event):
        if event.keysym == "Up":
            current_index = listbox.curselection()
            if current_index:
                listbox.selection_clear(current_index)
                listbox.selection_set(current_index[0] - 1 if current_index[0] > 0 else 0)
        elif event.keysym == "Down":
            current_index = listbox.curselection()
            if current_index:
                listbox.selection_clear(current_index)
                listbox.selection_set(current_index[0] + 1 if current_index[0] < len(get_cliphist_entries()) - 1 else len(get_cliphist_entries()) - 1)

    listbox.bind("<Up>", on_key)
    listbox.bind("<Down>", on_key)

    # Schließe das Fenster mit der Escape-Taste
    def on_escape(event):
        root.destroy()

    root.bind("<Escape>", on_escape)

    root.mainloop()

def get_waybar_output():
    """Gibt das Symbol und die Tooltip-Daten für Waybar zurück."""
    entries = get_cliphist_entries()
    # Nur die ersten 5 Einträge anzeigen
    first_5_entries = entries[:5]
    # Ersetze Zeilenumbrüche durch Leerzeichen
    cleaned_entries = [entry.replace("\n", " ") for entry in first_5_entries]
    tooltip_text = "\n".join([f"{i + 1}. {entry}" for i, entry in enumerate(cleaned_entries)])
    waybar_output = {
        "text": "📋",
        "tooltip": tooltip_text
    }
    # Gib das JSON-Objekt als String aus (ohne zusätzliche Zeichen)
    print(json.dumps(waybar_output), end="")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--click":
        # Klick-Modus: Fenster anzeigen
        show_selection_window()
    else:
        # Normaler Modus: Waybar-Daten ausgeben
        get_waybar_output()
