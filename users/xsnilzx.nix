{ pkgs, ... }:

let
  username = "xsnilzx";
  homeDir = "/home/${username}";
in
{
  imports = [
     #inputs.zen-browser.homeModules.beta
     inputs.zen-browser.homeModules.twilight
     # or inputs.zen-browser.homeModules.twilight-official
   ];

   programs.zen-browser = {
     enable = true;
     policies = {
       DisableAppUpdate = true;
       DisableTelemetry = true;
       DisablePocket = true;
       DisableSearchEngineInstall = true;
       # find more options here: https://mozilla.github.io/policy-templates/
     };
   };
  home.username = username;
  home.homeDirectory = homeDir;

  home.stateVersion = "24.11";

  # Programme aktivieren
  programs.zsh = {
    enable = true;
    #ohMyZsh = {
    #  enable = true;
    #  plugins = [ "git" ];
    #  theme = "xiong-chiamiov-plus";
    #};
    shellAliases = {
      ls = "eza";
      cat = "bat";
      ll = "ls -l";
      gs = "git status";
    };
  };

  programs.git = {
    enable = true;
    # Additional configuration options can be added here
    userEmail = "richard.hans.taesler@stud.uni-hannover.de";
    userName = "Richard Taesler";
  };

  #programs.rofi.enable = true;
  #programs.waybar.enable = true;
  #programs.dunst.enable = true;

  # Pakete installieren
  home.packages = with pkgs; [
    git
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
