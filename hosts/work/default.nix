# Configuration that only applies to the work machine
# (vetle-Precision-3630-Tower). Shared configuration lives in ../../home.nix.
{ pkgs, ... }:
{
  programs.git.settings.user.email = "vbr@resoptima.com";

  home.packages = with pkgs; [
    nerd-fonts.ubuntu-mono
    nerd-fonts.ubuntu-sans
  ];
}
