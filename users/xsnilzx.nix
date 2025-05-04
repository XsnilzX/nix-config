{ config, pkgs, hyprland-dotfiles, ... }:

let
  username = "xsnilzx";
  homeDir = "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDir;

  home.stateVersion = "24.11";

  # Programme aktivieren
  programs.zsh.enable = true;
  programs.rofi.enable = true;
  programs.waybar.enable = true;
  programs.dunst.enable = true;
  programs.home-manager.enable = true;

  # Pakete installieren
  home.packages = with pkgs; [
    ghostty
    zed-editor
    flatpak
    vscodium
    firefox
    discord
    btop
    eza
    bat
    bottom

    # Hyprland Tools
    waybar
    rofi
    dunst
    hyprpaper
    wlogout
    cliphist
  ];

  # Ganze Ordner aus hyprland-dotfiles einbinden
  xdg.configFile."hypr".source = "${hyprland-dotfiles}/dotfiles/hypr";
  xdg.configFile."waybar".source = "${hyprland-dotfiles}/dotfiles/waybar";
  xdg.configFile."rofi".source = "${hyprland-dotfiles}/dotfiles/rofi";
  xdg.configFile."dunst".source = "${hyprland-dotfiles}/dotfiles/dunst";
  xdg.configFile."wlogout".source = "${hyprland-dotfiles}/dotfiles/wlogout";
  xdg.configFile."ghostty".source = "${hyprland-dotfiles}/dotfiles/ghostty";

  # Optional: falls du Scripts hast
  # home.file.".local/bin".source = "${hyprland-dotfiles}/dotfiles/scripts";
}
