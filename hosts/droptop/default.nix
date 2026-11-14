# Configuration that only applies to droptop. Shared configuration lives in
# ../../home.nix.
{ ... }:
{
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
}
