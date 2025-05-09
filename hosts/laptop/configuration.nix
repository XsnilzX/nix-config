{ config, pkgs, lib, zen-browser, inputs, ... }:

let
  cryptroot = "/dev/mapper/cryptroot";
  cryptswap = "/dev/mapper/cryptswap";

  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    #./hardware-configuration.nix
  ];

  # Initiale Kernelmodule für das Initramfs
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "amdgpu" ]; # AMD-V und AMD-Grafik
  boot.extraModulePackages = [ ];

  # Aktiviert Flakes & Nix-CLI
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basis-Systemeinstellungen
  networking.hostName = "xsnilzx-lenovo-nix";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = lib.mkForce "de";

  # EFI + systemd-boot Setup
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Aktiviert btrfs Tools
  #programs.btrfs-progs.enable = true

  # LUKS Verschlüsselung für Root und Swap
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/bbc5858e-96c5-4bdd-87aa-cb4184a54f95";
    preLVM = true;
    name = "cryptroot";
  };
  boot.initrd.luks.devices."cryptswap" = {
    device = "/dev/disk/by-uuid/45550035-c24a-4646-b5ca-5ed81969eb9f";
    preLVM = true;
    name = "cryptswap";
  };

  # Hibernate Support (Swap-Resume)
  boot.resumeDevice = cryptswap;
  boot.kernelParams = [ "resume=${cryptswap}" ];

  # Swap Device Definition
  swapDevices = [
    { device = cryptswap; }
  ];

  # Btrfs mit Subvolumes + optimierten SSD-Optionen
  fileSystems."/" = {
    device = cryptroot;
    fsType = "btrfs";
    options = [ "subvol=@" "noatime" "compress=zstd:5" "ssd" "discard=async" "space_cache=v2" ];
  };
  fileSystems."/home" = {
    device = cryptroot;
    fsType = "btrfs";
    options = [ "subvol=@home" "noatime" "compress=zstd:5" "ssd" "discard=async" "space_cache=v2" ];
  };
  fileSystems."/nix" = {
    device = cryptroot;
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" "compress=zstd:5" "ssd" "discard=async" "space_cache=v2" ];
  };
  fileSystems."/var/log" = {
    device = cryptroot;
    fsType = "btrfs";
    options = [ "subvol=@log" "noatime" "compress=zstd:5" "ssd" "discard=async" "space_cache=v2" ];
  };

  # EFI Boot-Partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FD9B-5E8F";
    fsType = "vfat";
  };

  # Grafische Oberfläche: Hyprland + SDDM
  services.xserver.enable = true;
  services.libinput.enable = true; # Touchpad & Eingabegeräte (empfohlen für Laptops)
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  }

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

  # Netzwerk & Audio
  networking.networkmanager.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
  };

  # TRIM-Timer für SSDs aktivieren
  services.fstrim.enable = true;

  # Microcode-Updates für AMD
  hardware.cpu.amd.updateMicrocode = true;

  # Stromsparmaßnahmen für Laptops mit AMDGPU
  services.tlp = {
    enable = true;
    settings = {
      TLP_DEFAULT_MODE = "auto";
      TLP_PERSISTENT_DEFAULT = 1;

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      SOUND_POWER_SAVE_ON_AC = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      USB_AUTOSUSPEND = 1;
      USB_BLACKLIST = "1-1";

      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "min_power";

      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersave";

      WIFI_PWR_ON_AC = 1;
      WIFI_PWR_ON_BAT = 5;
    };
  };
  services.power-profiles-daemon.enable = false;

  # Konsolen-Schriftart für Bootscreen
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;

  # Nützliche Tools
  environment.systemPackages = with pkgs; [
    nano neovim zsh wget curl neofetch tlp btrfs-progs
    # Hyprland-Tools
    #hyprland-protocols
    hypridle
  ];

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

  # Wichtig für Upgrade-Kompatibilität
  system.stateVersion = "24.11";
}
