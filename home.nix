{ config, pkgs, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "vetle";
  home.homeDirectory = "/home/vetle";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  fonts.fontconfig.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = import ./vim.nix { inherit pkgs; };
    extraConfig = builtins.readFile ./customRC.vim;
    package = pkgs.neovim-unwrapped.overrideAttrs (p: {
      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "v0.8.3";
        sha256 = "sha256-ItJ8aX/WUfcAovxRsXXyWKBAI92hFloYIZiv7viPIdQ=";
      };
    });
  };

  home.packages = with pkgs; [
    lsd
    deno
    rnix-lsp
    nerdfonts
    nodePackages.vim-language-server
    nodePackages.pyright
    git
    flameshot
    nodejs
  ];
}
