{ config, pkgs, ... }:
let

  vscode-lldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;

  codelldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  liblldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";
in {
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
    extraLuaConfig = ''
      local codelldb_path = "${codelldb}"
      local liblldb_path = "${liblldb}"
    '' + builtins.readFile ./init.lua;
    package = pkgs.neovim-unwrapped.overrideAttrs (p: {
      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "v0.8.3";
        sha256 = "sha256-ItJ8aX/WUfcAovxRsXXyWKBAI92hFloYIZiv7viPIdQ=";
      };
    });
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      setw -g mouse on

      set-window-option -g automatic-rename on
      set-option -g set-titles on

      set-option -g repeat-time 0

      set -g default-terminal "screen-256color"

      unbind C-b
      set-option -g prefix C-b
      bind-key C-b send-prefix

      bind-key v split-window -h -c "#{pane_current_path}"
      bind-key s split-window -v -c "#{pane_current_path}"
      bind-key c new-window -c "#{pane_current_path}"
      bind-key C-c new-window

      set-option -sa terminal-overrides ',alacritty:RGB'
    '';
  };

  home.packages = with pkgs; [
    lsd
    deno
    rust-analyzer
    rnix-lsp
    lua-language-server
    nerdfonts
    nodePackages.vim-language-server
    nodePackages.pyright
    git
    flameshot
    nodejs
    ripgrep
    fd
  ];
}
