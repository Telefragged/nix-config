{ pkgs, lib, ... }:
let
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

  herdr-new-worktree = herdr-dialog "new-worktree" [ ];

  herdr-remove-worktree = herdr-dialog "remove-worktree" [ pkgs.jq ];

  herdr-builtin-new-worktree-dialog-size = {
    width = 68;
    height = 12;
  };

  herdr-builtin-remove-worktree-dialog-size = {
    width = 72;
    height = 10;
  };
in
{
  programs.herdr = {
    enable = true;
    # herdr hides git_status (ahead and behind counts) on the worktree rows it
    # nests under their repo; show it there too. Drop once upstream does.
    package = pkgs.herdr.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./nested-git-status.patch ];
    });
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
        new_worktree = "prefix+alt+shift+g";
        command = [
          (
            {
              key = "prefix+shift+g";
              type = "popup";
              command = lib.getExe herdr-new-worktree;
              description = "new worktree (git-mito when set up)";
            }
            // herdr-builtin-new-worktree-dialog-size
          )
          (
            {
              key = "prefix+shift+c";
              type = "popup";
              command = lib.getExe herdr-remove-worktree;
              description = "remove worktree and branch";
            }
            // herdr-builtin-remove-worktree-dialog-size
          )
        ];
      };
    };
  };
}
