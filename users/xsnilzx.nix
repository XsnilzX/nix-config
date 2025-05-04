{ config, pkgs, hyprland-dotfiles, zen-browser, ... }:

{
  home.username = "xsnilzx";
  home.homeDirectory = "/home/xsnilzx";

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    # deine Wunschprogramme später hier eintragen
    ghostty zed-editor flatpak vscodium firefox discord btop eza bat bottom
    # Zen Browser
    zen-browser.packages.${pkgs.system}.twilight  {
     policies = {
         DisableAppUpdate = true;
         DisableTelemetry = true;
         DisablePocket = true;
         DisableSearchEngineInstall = true;
         # find more options here: https://mozilla.github.io/policy-templates/
     };
    }
    # hyprland stuff
    waybar
    rofi
    dunst
    hyprpaper
    wlogout
    cliphist
  ];

  # Ganze Ordner einbinden (inkl. Scripts, Styles usw.)
  xdg.configFile."hypr".source = "${hyprland-dotfiles}/dotfiles/hypr";
  xdg.configFile."waybar".source = "${hyprland-dotfiles}/dotfiles/waybar";
  xdg.configFile."rofi".source = "${hyprland-dotfiles}/dotfiles/rofi";
  xdg.configFile."dunst".source = "${hyprland-dotfiles}/dotfiles/dunst";
  xdg.configFile."wlogout".source = "${hyprland-dotfiles}/dotfiles/wlogout";
  xdg.configFile."ghostty".source = "${hyprland-dotfiles}/dotfiles/ghostty";

  # Optional: Scripts nach ~/bin oder ~/.local/bin
  # home.file.".local/bin".source = "${dotfiles}/dotfiles/scripts";

  home.stateVersion = "24.11";
}
