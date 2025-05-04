{
  description = "NixOS configuration with Hyprland + LUKS for Yoga Pro 7";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Hyprland dotfiles
    hyprland-dotfiles = {
        url = "github:XsnilzX/hyprland-dotfiles";
        flake = false;
      };
    zen-browser = {
        url = "github:0xc000022070/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, hyprland-dotfiles, zen-browser, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit self;
          inherit (self.inputs) hyprland-dotfiles zen-browser;
        };

        modules = [
          ./hosts/laptop/configuration.nix
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.xsnilzx = import ./users/xsnilzx.nix {
              inherit hyprland-dotfiles;
            };
          }

          # Aktiviert unfreie Software systemweit
          ({ config, ... }: {
            nixpkgs.config.allowUnfree = true;
          })
        ];
      };
    };
}
