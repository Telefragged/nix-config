{ config, pkgs, ... }:
let
  sources = import ./nix/sources.nix;

  vscode-lldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;

  codelldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  liblldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";

  csharpls = pkgs.buildDotnetModule rec {
    pname = "csharp-language-server";
    version = "0.13.0";

    src = sources.csharp-language-server;

    dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
    dotnet-runtime = pkgs.dotnetCorePackages.sdk_8_0;

    projectFile = "src/CSharpLanguageServer/CSharpLanguageServer.fsproj";

    nugetDeps = ./deps.nix;
  };

  # If we need to upgrade csharpls
  fetch-deps-csharpls = pkgs.writeScriptBin "fetch-deps-csharpls" ''
    ${csharpls.passthru.fetch-deps}
  '';

  flameshot-wayland = pkgs.flameshot.overrideAttrs (o: {
    cmakeFlags = [ "-DUSE_WAYLAND_CLIPBOARD=true" ];
    nativeBuildInputs = o.nativeBuildInputs ++ [ pkgs.libsForQt5.kguiaddons ];
  });
in
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
    plugins = import ./vim.nix { inherit pkgs sources; };
    extraConfig = builtins.readFile ./customRC.vim;
    extraLuaConfig = ''
      local codelldb_path = "${codelldb}"
      local liblldb_path = "${liblldb}"
    '' + builtins.readFile ./init.lua;
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      setw -g mouse on

      set-window-option -g automatic-rename on
      set-option -g set-titles on

      set-option -g repeat-time 0

      unbind C-b
      set-option -g prefix C-b
      bind-key C-b send-prefix

      bind-key v split-window -h -c "#{pane_current_path}"
      bind-key s split-window -v -c "#{pane_current_path}"
      bind-key c new-window -c "#{pane_current_path}"
      bind-key C-c new-window

      set -g default-terminal "screen-256color"
      set-option -ga terminal-overrides ",*:Tc"

    '';
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      . ${pkgs.git}/share/bash-completion/completions/git-prompt.sh

      get_ps1() {
        local RESETC="\[\033[0m\]"

        local USERC="\[\033[38;2;128;187;179m\]"
        local WDIRC="\[\033[38;2;107;132;120m\]"
        local GITC="\[\033[38;2;219;188;127m\]"

        echo "$USERC\u$RESETC:$WDIRC\w$GITC\$(__git_ps1 ' (%s)')$RESETC$ "
      }

      export PS1="$(get_ps1)"
      export EDITOR=nvim
      export PATH=$PATH:$HOME/.cargo/bin
    '';
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  programs.git.enable = true;

  home.packages = with pkgs; [
    deno
    nixd
    lua-language-server
    nerdfonts
    nodePackages.vim-language-server
    nodePackages.pyright
    flameshot
    nodejs
    ripgrep
    fd
    fetch-deps-csharpls
    csharpls
    marksman
    niv
  ];
}
