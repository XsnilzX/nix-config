{ config, pkgs, ... }:

let
  username = "xsnilzx";
  homeDir = "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDir;

  home.stateVersion = "24.11";

  # Programme aktivieren
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "zsh-autosuggestions" ];
      theme = "xiong-chiamiov-plus";
    };
    shellAliases = {
      ls = "eza";
      cat = "bat";
    };
  };

  programs.git = {
    enable = true;
    # Additional configuration options can be added here
    user = {
      email = "richard.hans.taesler@stud.uni-hannover.de";
      name = "Richard Taesler";
    };
  };

  #programs.rofi.enable = true;
  #programs.waybar.enable = true;
  #programs.dunst.enable = true;
  programs.home-manager.enable = true;

  # Pakete installieren
  home.packages = with pkgs; [
    ghostty
    zed-editor
    vscodium
    firefox
    discord
    btop
    eza
    bat

    # Hyprland Tools
    waybar
    walker
    dunst
    hyprpaper
    wlogout
    cliphist
  ];

  # Ganze Ordner aus hyprland-dotfiles einbinden Geht gerade nicht
  #xdg.configFile."hypr".source = "${hyprland-dotfiles}/dotfiles/hypr";
  #xdg.configFile."waybar".source = "${hyprland-dotfiles}/dotfiles/waybar";
  #xdg.configFile."rofi".source = "${hyprland-dotfiles}/dotfiles/rofi";
  #xdg.configFile."dunst".source = "${hyprland-dotfiles}/dotfiles/dunst";
  #xdg.configFile."wlogout".source = "${hyprland-dotfiles}/dotfiles/wlogout";
  #xdg.configFile."ghostty".source = "${hyprland-dotfiles}/dotfiles/ghostty";

  # Optional: falls du Scripts hast
  # home.file.".local/bin".source = "${hyprland-dotfiles}/dotfiles/scripts";
}
