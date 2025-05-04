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
    #hyprland-dotfiles = {
    #    url = "github:XsnilzX/hyprland-dotfiles";
    #    flake = false;
    #  };
    zen-browser = {
        url = "github:0xc000022070/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, zen-browser, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        extraSpecialArgs = {
          inherit inputs;
        };

        modules = [
          ./hosts/laptop/configuration.nix
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd

          # Aktiviert unfreie Software systemweit
          ({ config, ... }: {
            nixpkgs.config.allowUnfree = true;
          })
        ];
      };
    };
}
