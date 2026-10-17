{
  description = "Arch Linux Developer Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-opencode.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixpkgs-opencode,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "sam";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          opencodePkgs = nixpkgs-opencode.legacyPackages.${system};
        };

        modules = [
          ./home.nix
        ];
      };
    };
}
