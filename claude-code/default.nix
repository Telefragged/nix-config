# Claude Code, installed through home-manager's module as `claude`, plus
# `dclaude`, which runs it in a bubblewrap sandbox with permission bypass
# allowed.
{ config, pkgs, ... }:
let
  dclaude = pkgs.writeShellScriptBin "dclaude" ''
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
        --ro-bind "$HOME/.local/share/noise" "$HOME/.local/share/noise" \
        --ro-bind "$HOME/.config/noise" "$HOME/.config/noise" \
        --bind "$HOME/.local/state/noise" "$HOME/.local/state/noise" \
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
        "${config.programs.claude-code.finalPackage}/bin/claude" \
        --allow-dangerously-skip-permissions "$@"
  '';

  update-claude-code = pkgs.writeShellApplication {
    name = "update-claude-code";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];
    text = builtins.readFile ./update.sh;
  };
in
{
  programs.claude-code = {
    enable = true;
    # nixpkgs lags upstream releases, so we vendor a copy of its native-binary
    # derivation (./package.nix) and pin the version via ./manifest.json —
    # bump it with `update-claude-code` to update independently.
    package = pkgs.callPackage ./package.nix { };
  };

  home.packages = [
    dclaude
    update-claude-code
  ];
}
