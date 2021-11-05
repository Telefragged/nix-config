let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  dotnetsdks = import ./dotnet.nix { pkgs = nixpkgs; };
  vim = import ./vim.nix { pkgs = nixpkgs; };
in with nixpkgs; {
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "my-packages";
      paths = [ dotnetsdks
                latest.rustChannels.nightly.rust
                lsd
                deno
                rnix-lsp
                vim ];
    };
  };
}
