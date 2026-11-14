{ pkgs, lib, inputs, ... }:
let
  vscode-lldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;

  codelldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  liblldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";

  csharpls = pkgs.buildDotnetModule {
    pname = "csharp-language-server";
    version = "0.22.0";

    src = inputs.csharp-language-server;

    dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0;
    dotnet-runtime = pkgs.dotnetCorePackages.sdk_10_0;

    projectFile = "src/CSharpLanguageServer/CSharpLanguageServer.fsproj";

    nugetDeps = ./deps.json;
  };

  # If we need to upgrade csharpls
  fetch-deps-csharpls = pkgs.writeScriptBin "fetch-deps-csharpls" ''
    ${csharpls.passthru.fetch-deps}
  '';

  # herdr popup dialogs: ./herdr/<name>.sh with the shared ./herdr/dialog.sh in
  # front. git-mito comes from PATH, since it's installed with `nix profile`
  # rather than by this config.
  herdr-dialog =
    name: extraInputs:
    pkgs.writeShellApplication {
      name = "herdr-${name}";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.git
      ]
      ++ extraInputs;
      text = builtins.readFile ./herdr/dialog.sh + builtins.readFile (./herdr + "/${name}.sh");
    };

  # Creates a worktree under <repo>/.worktrees, with git-mito when the repo has
  # a git-mito base, and opens it in herdr.
  herdr-new-worktree = herdr-dialog "new-worktree" [ ];

  # Removes the current worktree and its branch, if it's clean and merged.
  herdr-remove-worktree = herdr-dialog "remove-worktree" [ pkgs.jq ];
in
{
  imports = [ ./claude-code ];

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
    plugins = import ./vim.nix { inherit pkgs inputs; };
    extraConfig = builtins.readFile ./customRC.vim;
    initLua = ''
      local codelldb_path = "${codelldb}"
      local liblldb_path = "${liblldb}"
    ''
    + builtins.readFile ./init.lua;

    withRuby = false;
    withPython3 = false;
  };

  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = lib.concatStrings [
        "$nix_shell"
        "$username"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_metrics"
        "$cmd_duration"
        "$status"
        "$character"
      ];

      follow_symlinks = false;

      character = rec {
        success_symbol = "\\$";
        error_symbol = success_symbol;
      };

      cmd_duration.format = "[$duration]($style) ";

      directory = {
        format = "[$read_only]($read_only_style)[$path]($style) ";

        style = "#6B8478";
        truncation_symbol = "../";

        read_only = "\(RO\)";
        read_only_style = "bold red";
      };

      git_branch = {
        format = "[$branch(:$remote_branch)]($style) ";

        style = "#DBBC7F";
      };

      git_metrics.disabled = false;

      nix_shell = {
        format = "[\\($state$name\\)]($style) ";
        impure_msg = "";
        pure_msg = "pure ";
      };

      status = {
        disabled = false;

        format = "[\\($status\\)]($style)";
        symbol = "";

        pipestatus = true;
      };

      username = {
        style_user = "#80BBB3";
        show_always = true;

        format = "[$user]($style):";
      };

    };
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

      bind-key k select-pane -U
      bind-key j select-pane -D
      bind-key h select-pane -L
      bind-key l select-pane -R

      set -g default-terminal "screen-256color"
      set-option -ga terminal-overrides ",*:Tc"
    '';
  };

  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;

      theme = {
        name = "gruvbox";
        auto_switch = false;
      };

      ui = {
        sound.enabled = false;
        toast.delivery = "herdr";
      };

      keys = {
        # Moved off its default (prefix+shift+g) to make room for the action
        # below, which uses git-mito when the repo has a git-mito base.
        new_worktree = "prefix+alt+shift+g";
        command = [
          {
            key = "prefix+shift+g";
            type = "popup";
            command = lib.getExe herdr-new-worktree;
            description = "new worktree (git-mito when set up)";
            # Same size as herdr's own new worktree dialog.
            width = 68;
            height = 12;
          }
          {
            key = "prefix+shift+c";
            type = "popup";
            command = lib.getExe herdr-remove-worktree;
            description = "remove worktree and branch";
            # Same size as herdr's own remove worktree dialog.
            width = 72;
            height = 10;
          }
        ];
      };
    };
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export EDITOR=nvim
      export PATH=$PATH:$HOME/.cargo/bin
    '';
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    icons = "auto";
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    nixd
    lua-language-server
    vim-language-server
    nodejs
    ripgrep
    fd
    fetch-deps-csharpls
    csharpls
    marksman
    nixfmt
    nerd-fonts.iosevka
    nerd-fonts.zed-mono
    nerd-fonts.caskaydia-cove
  ];
}
