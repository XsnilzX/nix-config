{ config, pkgs, ... }:

{
  imports = [ ../../users/xsnilzx.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "yoga-pro-7";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  boot.initrd.luks.devices."luks-root" = {
    device = "/dev/disk/by-label/nixos";
    preLVM = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@" "noatime" "compress=zstd" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@home" "noatime" "compress=zstd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" "compress=zstd" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@log" "noatime" "compress=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  services.xserver.enable = true;
  programs.hyprland.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "hyprland";

  users.users.xsnilzx = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };

  services.network-manager.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nano git neovim zsh wget
    # hyprland stuff
    hyprland hyprland-protocols hypridle hyprland
  ];

  services.flatpak.enable = true;

  # Optional aber empfohlen: Flathub als Remote hinzufügen
  systemd.user.services.flatpak-setup = {
    description = "Flathub Remote hinzufügen";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
      RemainAfterExit = true;
    };
  };
  system.stateVersion = "24.11";
}
