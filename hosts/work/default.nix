{ pkgs, ... }:
{
  programs.git.settings.user.email = "vbr@resoptima.com";

  home.packages = with pkgs; [
    nerd-fonts.ubuntu-mono
    nerd-fonts.ubuntu-sans
  ];
}
