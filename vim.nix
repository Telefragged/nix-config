{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  deno-vim = pkgs.vimUtils.buildVimPlugin {
    name = "deno-vim";
    nativeBuildInputs = [ perl ];
    src = pkgs.fetchFromGitHub {
      owner = "vim-denops";
      repo = "denops.vim";
      rev = "228d446132825bd8035a5530a206611f639f9a74";
      sha256 = "00szxrclnrq0wsdpwip6557yzizcc88f2c3kndpas2zzxjaix2bq";
    };
  };

  vim-deep-space = pkgs.vimUtils.buildVimPlugin {
    name = "vim-deep-space";
    nativeBuildInputs = [ ];
    src = pkgs.fetchFromGitHub {
      owner = "tyrannicaltoucan";
      repo = "vim-deep-space";
      rev = "126d52f4f77877385cd44d983709053d1aab6635";
      sha256 = "1gi4281bzzhbjqbs5r8248bssvxmw9cvyxfynd55wyiijlk200s4";
    };
  };

  serenade = pkgs.vimUtils.buildVimPlugin {
    name = "serenade";
    nativeBuildInputs = [ ];
    src = pkgs.fetchFromGitHub {
      owner = "b4skyx";
      repo = "serenade";
      rev = "3a27c50059ec0d81554473c6cbc267b233f2d131";
      sha256 = "0p12v6gy7j21l2nxx7931mq43gv5hyqii1wbpr9i4biabmc4qr84";
    };
  };

  vim-transparent = pkgs.vimUtils.buildVimPlugin {
    name = "vim-transparent";
    nativeBuildInputs = [ ];
    src = pkgs.fetchFromGitHub {
      owner = "tribela";
      repo = "vim-transparent";
      rev = "e2f16c1e3341773518b68799264c6cfd7ac8bd7a";
      sha256 = "0kzbjp233hj88ri8qjmyakjv753p8lnzsh9yhvh36fgdcwdq53kb";
    };
  };

  codeschool-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "codeschool-nvim";
    nativeBuildInputs = [ ];
    src = pkgs.fetchFromGitHub {
      owner = "adisen99";
      repo = "codeschool.nvim";
      rev = "3824cdd7d40c31a816f4d6b5d7f59568c3fa6e43";
      sha256 = "9iQLEd/TRc7LDakdI2N7WesiB2TeyGGaWkbbZOndC7w=";
    };
  };

  nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins:
    with tree-sitter-grammars; [
      tree-sitter-nix
      tree-sitter-python
      tree-sitter-rust
      tree-sitter-json
      tree-sitter-lua
    ]);

  zenburn-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "zenburn";
    nativeBuildInputs = [ ];
    src = pkgs.fetchFromGitHub {
      owner = "phha";
      repo = "zenburn.nvim";
      rev = "cc78ddba1d65f885d3928692ee628ed40216b900";
      sha256 = "sha256-NExSyE1ZArJuiEZz+HRwnj6MD672Qt0jbRrpxX0GNMA";
    };
  };

in
with pkgs.vimPlugins; [
  vim-nix
  vim-airline
  vim-airline-themes

  vim-deus
  vim-deep-space
  serenade
  gruvbox
  zenburn-nvim
  vim-transparent

  nvim-treesitter

  semshi

  nvim-dap
  nvim-dap-ui
  nvim-dap-virtual-text

  nvim-lspconfig
  lsp_signature-nvim

  rust-tools-nvim

  nvim-cmp
  cmp-nvim-lsp
  cmp-path
  cmp-vsnip
  vim-vsnip

  nvim-bufdel

  telescope-nvim

  copilot-lua
  copilot-cmp

  trouble-nvim

  nerdtree
  bufferline-nvim
  nvim-web-devicons
  vim-devicons

  vim-fugitive

  which-key-nvim
  lightspeed-nvim
]
