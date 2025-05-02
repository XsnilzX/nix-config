{
  description = "NixOS configuration with Hyprland + LUKS for Yoga Pro 7";

  # zentrale Versionsvariable
  nixosVersion = "nixos-24.11";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/${nixosVersion}";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    # Hyprland dotfiles
    hyperland-dotfiles = {
        url = "github:XsnilzX/hyprland-dotfiles";
        flake = false;
      };
    zen-browser = {
        url = "github:0xc000022070/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit self;
          inherit (self.inputs) dotfiles zen-browser;
        };

        modules = [
          ./hosts/laptop/configuration.nix
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
