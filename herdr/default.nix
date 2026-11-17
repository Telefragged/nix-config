# herdr, with popup dialogs that create and remove git worktrees.
{ pkgs, lib, ... }:
let
  # herdr popup dialogs: ./<name>.sh with the shared ./dialog.sh in
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
      text = builtins.readFile ./dialog.sh + builtins.readFile (./. + "/${name}.sh");
    };

  # Creates a worktree under <repo>/.worktrees, with git-mito when the repo has
  # a git-mito base, sets it to track the main checkout's branch, and opens it
  # in herdr.
  herdr-new-worktree = herdr-dialog "new-worktree" [ ];

  # Removes the current worktree and its branch, if it's clean and merged.
  herdr-remove-worktree = herdr-dialog "remove-worktree" [ pkgs.jq ];
in
{
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
}
