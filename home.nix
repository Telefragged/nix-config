{ pkgs, lib, ... }:
let
  sources = import ./npins;

  # Pinned claude-code. nixpkgs lags upstream releases, so we vendor a copy of
  # its native-binary derivation (./claude-code) and pin the version via
  # ./claude-code/manifest.json — bump that file to update independently.
  claude-code = pkgs.callPackage ./claude-code/package.nix { };

  vscode-lldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;

  codelldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  liblldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";

  csharpls = pkgs.buildDotnetModule {
    pname = "csharp-language-server";
    version = "0.22.0";

    src = sources.csharp-language-server;

    dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0;
    dotnet-runtime = pkgs.dotnetCorePackages.sdk_10_0;

    projectFile = "src/CSharpLanguageServer/CSharpLanguageServer.fsproj";

    nugetDeps = ./deps.json;
  };

  # If we need to upgrade csharpls
  fetch-deps-csharpls = pkgs.writeScriptBin "fetch-deps-csharpls" ''
    ${csharpls.passthru.fetch-deps}
  '';

  claude = pkgs.writeShellScriptBin "claude" ''
    claude_dir=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    if git_dir=$(git rev-parse --git-common-dir); then
      git_flag="--bind $git_dir $git_dir"
    else
      git_flag=""
    fi

    # From a linked worktree, also expose the main checkout, so Claude finds
    # the CLAUDE.local.md there when walking up from a nested worktree.
    main_dir=$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
    if [ -n "$main_dir" ] && [ "$main_dir" != "$claude_dir" ]; then
      main_flag="--bind $main_dir $main_dir"
    else
      main_flag=""
    fi

    if gh_token=$(gh auth token); then
      gh_flag="--setenv GH_TOKEN $gh_token"
    else
      gh_flag=""
    fi

    # Expose the Wayland socket so wl-copy/wl-paste work inside the sandbox
    wayland_socket="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    if [ -n "$WAYLAND_DISPLAY" ] && [ -S "$wayland_socket" ]; then
      wayland_flag="--bind $wayland_socket $wayland_socket"
    else
      wayland_flag=""
    fi

    profile_link=$(readlink "$HOME/.nix-profile")
    profile_dir=$(dirname "$profile_link")

    exec "${pkgs.bubblewrap}/bin/bwrap" \
        --ro-bind /usr /usr \
        --ro-bind /lib /lib \
        --ro-bind /lib64 /lib64 \
        --ro-bind /bin /bin \
        --ro-bind /etc/resolv.conf /etc/resolv.conf \
        --ro-bind /etc/hosts /etc/hosts \
        --ro-bind /etc/ssl /etc/ssl \
        --ro-bind /etc/ca-certificates /etc/ca-certificates \
        --ro-bind /etc/passwd /etc/passwd \
        --ro-bind /etc/group /etc/group \
        --ro-bind "$HOME/.nix-channels" "$HOME/.nix-channels" \
        --ro-bind "$HOME/.nix-defexpr" "$HOME/.nix-defexpr" \
        --ro-bind "$profile_dir" "$profile_dir" \
        --symlink "$profile_link" "$HOME/.nix-profile" \
        --ro-bind "$HOME/.config/nix" "$HOME/.config/nix" \
        --ro-bind "$HOME/.config/nixpkgs" "$HOME/.config/nixpkgs" \
        --ro-bind "$HOME/.config/git" "$HOME/.config/git" \
        --ro-bind "$HOME/.config/nvim" "$HOME/.config/nvim" \
        --ro-bind "$HOME/.local/share/nvim" "$HOME/.local/share/nvim" \
        --ro-bind "$HOME/.local/share/nit" "$HOME/.local/share/nit" \
        --bind "$HOME/.local/share/nit/watch" "$HOME/.local/share/nit/watch" \
        --ro-bind "/nix" "/nix" \
        --bind "$HOME/.claude" "$HOME/.claude" \
        --bind "$HOME/.claude.json" "$HOME/.claude.json" \
        --bind "$HOME/.rustup" "$HOME/.rustup" \
        --bind "$HOME/.cargo" "$HOME/.cargo" \
        $main_flag \
        --bind "$claude_dir" "$claude_dir" \
        $git_flag \
        $gh_flag \
        $wayland_flag \
        --size 8589934592 --tmpfs /tmp \
        --proc /proc \
        --dev /dev \
        --share-net \
        --unshare-pid \
        --die-with-parent \
        -- \
        "${claude-code}"/bin/claude "$@"
  '';

  dclaude = pkgs.writeScriptBin "dclaude" ''
    exec ${claude}/bin/claude --allow-dangerously-skip-permissions $@
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

  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user = {
        email = "vetle.braend@gmail.com";
        name = "Vetle Brænd";
      };
      rebase.autoStash = true;
    };
  };

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
    npins
    nixfmt
    claude
    dclaude
    nerd-fonts.iosevka
    nerd-fonts.zed-mono
    nerd-fonts.caskaydia-cove
  ];
}
