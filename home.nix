{ pkgs, lib, ... }:
let
  sources = import ./nix/sources.nix;

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
        --ro-bind "$HOME/.nix-profile" "$HOME/.nix-profile" \
        --ro-bind "$HOME/.config/nix" "$HOME/.config/nix" \
        --ro-bind "$HOME/.config/nixpkgs" "$HOME/.config/nixpkgs" \
        --ro-bind "$HOME/.config/git" "$HOME/.config/git" \
        --ro-bind "$HOME/.config/nvim" "$HOME/.config/nvim" \
        --ro-bind "$HOME/.local/share/nvim" "$HOME/.local/share/nvim" \
        --bind "/nix" "/nix" \
        --bind "$HOME/.claude" "$HOME/.claude" \
        --bind "$HOME/.claude.json" "$HOME/.claude.json" \
        --bind "$HOME/.rustup" "$HOME/.rustup" \
        --bind "$HOME/.cargo" "$HOME/.cargo" \
        --bind "$claude_dir" "$claude_dir" \
        $git_flag \
        --size 4294967296 --tmpfs /tmp \
        --proc /proc \
        --dev /dev \
        --share-net \
        --unshare-pid \
        --die-with-parent \
        -- \
        "${pkgs.claude-code}"/bin/claude "$@"
  '';

  dclaude = pkgs.writeScriptBin "dclaude" ''
    exec ${claude}/bin/claude --allow-dangerously-skip-permissions $@
  '';
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

      set -g default-terminal "screen-256color"
      set-option -ga terminal-overrides ",*:Tc"
    '';
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export EDITOR=nvim
      export PATH=$PATH:$HOME/.cargo/bin
    '';
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    icons = "auto";
  };

  programs.git.enable = true;

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
    niv
    nixfmt
    claude
    dclaude
    nerd-fonts.iosevka
    nerd-fonts.zed-mono
    nerd-fonts.caskaydia-cove
  ];
}
