{ pkgs, lib, inputs, ... }:

let
  cryptswap = "/path/to/disk";
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    ./hardware-configuration.nix
  ];

  # Aktiviert Flakes & Nix-CLI
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ## Basis-Systemeinstellungen
  # Timezone
  time.timeZone = "Europe/Berlin";

  # internationalisation properties
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # console keymap
  console.keyMap = "de";

  # EFI + systemd-boot Setup
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Aktiviert btrfs Tools
  programs.btrfs-progs.enable = true;

  # Hibernate Support (Swap-Resume)
  boot.resumeDevice = cryptswap;
  boot.kernelParams = [ "resume=${cryptswap}" ];

  # Swap Device Definition
  swapDevices = [
    { device = cryptswap; }
  ];

  # Grafische Oberfläche: Hyprland + SDDM
  services.xserver.enable = true;
  services.libinput.enable = true; # Touchpad & Eingabegeräte (empfohlen für Laptops)
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  hardware.opengl = {
    package = pkgs-unstable.mesa.drivers;

    # if you also want 32-bit support (e.g for Steam)
    driSupport32Bit = true;
    package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
    };
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sessionPackages = [ pkgs.hyprland ];

  # Benutzerkonfiguration
  users.users.xsnilzx = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
  };
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs; };
    users = {
      "xsnilzx" = import ../../users/xsnilzx.nix;
    };
  };

  # CUPS printingsupport
  services.printing.enable = true;

  # Netzwerk
  networking.networkmanager.enable = true;
  networking.hostName = "xsnilzx-lenovo-nix";
  networking.wireless.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # TRIM-Timer für SSDs aktivieren
  services.fstrim.enable = true;

  # Stromsparmaßnahmen für Laptops mit AMDGPU
  programs.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  services.power-profiles-daemon.enable = false;

  # Konsolen-Schriftart für Bootscreen
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;

  # Nützliche Tools
  environment.systemPackages = with pkgs; [
    nano neovim zsh wget curl neofetch auto-cpufreq btrfs-progs
    # Hyprland-Tools
    #hyprland-protocols
    hypridle
  ];

  # Enable non free Software
  nixpkgs.config.allowUnfree = true;

  # Flatpak + Flathub Setup
  services.flatpak.enable = true;
  systemd.user.services.flatpak-setup = {
    description = "Flathub Remote hinzufügen";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
      RemainAfterExit = true;
    };
  };

  # hardware gaming
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
    };
  };

  # Wichtig für Upgrade-Kompatibilität
  system.stateVersion = "24.11";
}
