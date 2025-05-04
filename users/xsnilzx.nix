{ config, pkgs, ... }:

{
  home.username = "xsnilzx";
  home.homeDirectory = "/home/xsnilzx";

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    # deine Wunschprogramme später hier eintragen
    ghostty zed-editor flatpak flatseal vscodium firefox discord btop eza bat bottom
    # Zen Browser
    inputs.zen-browser.packages.${pkgs.system}.twilight  {
     policies = {
         DisableAppUpdate = true;
         DisableTelemetry = true;
         DisablePocket = true;
         DisableSearchEngineInstall = true;
         # find more options here: https://mozilla.github.io/policy-templates/
     };
    # hyprland stuff
    waybar
    rofi-wayland
    dunst
    hyprpaper
    wlogout
    cliphist
  ];

  # Ganze Ordner einbinden (inkl. Scripts, Styles usw.)
  xdg.configFile."hypr".source = "${dotfiles}/dotfiles/hypr";
  xdg.configFile."waybar".source = "${dotfiles}/dotfiles/waybar";
  xdg.configFile."rofi".source = "${dotfiles}/dotfiles/rofi";
  xdg.configFile."dunst".source = "${dotfiles}/dotfiles/dunst";
  xdg.configFile."wlogout".source = "${dotfiles}/dotfiles/wlogout";
  xdg.configFile."ghostty".source = "${dotfiles}/dotfiles/ghostty";

  # Optional: Scripts nach ~/bin oder ~/.local/bin
  # home.file.".local/bin".source = "${dotfiles}/dotfiles/scripts";

  home.stateVersion = "24.11";
}
