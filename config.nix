let
  nixpkgs = import <nixpkgs> {};
  dotnetsdks = import ./dotnet.nix { pkgs = nixpkgs; };
  vim = import ./vim.nix { pkgs = nixpkgs; };
in with nixpkgs; {
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "my-packages";
      paths = [ dotnetsdks
                lsd
                deno
                rnix-lsp
                vim
                nodePackages.pyright ];
    };
  };
}
