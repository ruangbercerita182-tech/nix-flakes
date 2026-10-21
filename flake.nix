{
  description = "Arch Linux Developer Environment";

  inputs = {
    # Home Manager menggunakan Nixpkgs stable 26.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Paket tambahan dari unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Devenv terbaru
    devenv = {
      url = "github:cachix/devenv/v2.4.0";

    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      devenv,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "sam";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Nixpkgs khusus development shell
      pkgs-dev = devenv.inputs.nixpkgs.legacyPackages.${system};
    in
    {
      # Development environment
      devShells.${system}.default = devenv.lib.mkShell {
        inherit inputs;
        pkgs = pkgs-dev;

        modules = [
          ./devenv.nix
        ];
      };

      # Home Manager standalone
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit pkgs-unstable;
        };

        modules = [
          ./home.nix

          # Bun matches the version the workspace pins and that devenv provides.
          ({ ... }: {
            home.packages = [
              nixpkgs-unstable.legacyPackages.${system}.bun
            ];
          })
        ];
      };
    };
}
