{
  description = "Home Manager configuration of vetle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    csharp-language-server = {
      url = "github:razzmatazz/csharp-language-server/main";
      flake = false;
    };
    neofsharp-vim = {
      url = "github:adelarsq/neofsharp.vim/master";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      # Flakes evaluate purely, so ~/.config/nixpkgs/config.nix isn't read.
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
        };
      };
    in
    {
      homeConfigurations.vetle = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
