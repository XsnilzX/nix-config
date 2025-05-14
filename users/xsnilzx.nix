{ pkgs, inputs, lib, ... }:

let
  username = "xsnilzx";
  homeDir = "/home/${username}";
in
{
  imports = [
     #inputs.zen-browser.homeModules.beta
     inputs.zen-browser.homeModules.twilight
     # or inputs.zen-browser.homeModules.twilight-official
     # Hyprlanmd configFile
     ./hyprland.nix
     ./walker.nix
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

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfer
  };

  #programs.rofi.enable = true;
  #programs.waybar.enable = true;
  #programs.dunst.enable = true;

  fonts.fontconfig.enable = true;
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
    seafile-client
    steam

    # Hyprland Tools
    walker
    dunst
    hyprlock
    hypridle
    hyprpaper
    waybar
    wlogout
    cliphist

    # fonts
    (nerdfonts.override { fonts = [ "FiraMono" ]; })
  ];

  # hyprland congigs
  xdg.configFile."hypr".source = ../../dotfiles/hypr;
  # Optional: make script executable
  home.file.".config/hypr/scripts/wallpaper-cycle.sh".executable = true;

  # waybar
  xdg.configFile."waybar".source = ../../dotfiles/waybar;
  home.activation.makeWaybarScriptsExecutable = lib.hm.dag.entryAfter ["writeBoundary"] ''
    chmod +x ~/.config/waybar/scripts/*.sh ~/.config/waybar/scripts/*.py
  '';

  # wlogout
  xdg.configFile."wlogout".source = ../../dotfiles/wlogout;

  # Ghostty config
  home.file.".config/ghostty/config".text = ''
    theme = Dracula
    font-family = FiraMono Nerd Font
  '';
  # Optional: falls du Scripts hast
  # home.file.".local/bin".source = "${hyprland-dotfiles}/dotfiles/scripts";
}
