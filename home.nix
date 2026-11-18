{ pkgs, lib, ... }:
{
  imports = [
    ./claude-code
    ./herdr
    ./neovim
  ];

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
    marksman
    nixfmt
    nerd-fonts.iosevka
    nerd-fonts.zed-mono
    nerd-fonts.caskaydia-cove
  ];
}
