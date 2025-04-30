{ config, pkgs, ... }:

{
  home.username = "xsnilzx";
  home.homeDirectory = "/home/xsnilzx";

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    # deine Wunschprogramme später hier eintragen
    ghostty
    # hyprland stuff
    waybar rofi-wayland dunst hyprpaper wlogout cliphist
  ];

  home.stateVersion = "24.05";
}
