{ pkgs ? import <nixpkgs> { }, sources ? import ./nix/sources.nix }:
with pkgs;
let
  neofsharp-vim = pkgs.vimUtils.buildVimPlugin {
    name = "neofsharp-vim";
    nativeBuildInputs = [ ];
    src = sources.neofsharp-vim;
  };

  nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins:
    with tree-sitter-grammars; [
      tree-sitter-nix
      tree-sitter-python
      tree-sitter-rust
      tree-sitter-json
      tree-sitter-lua
      tree-sitter-vim
      tree-sitter-bash
      tree-sitter-regex
    ]);
in
with pkgs.vimPlugins; [
  vim-nix
  lualine-nvim

  vim-deus
  gruvbox
  everforest

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
  vim-commentary
  nvim-surround

  telescope-nvim
  harpoon

  copilot-lua

  trouble-nvim

  nerdtree
  bufferline-nvim
  nvim-web-devicons
  vim-devicons

  vim-fugitive

  which-key-nvim
  lightspeed-nvim

  nui-nvim

  neofsharp-vim
]
