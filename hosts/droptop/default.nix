# Configuration that only applies to droptop. Shared configuration lives in
# ../../home.nix.
{ lib, ... }:
let
  # The Nvidia driver version must match the one the host kernel runs, so
  # ./nvidia/driver.json is generated from it by ./nvidia/update.sh — rerun that
  # script after a host driver upgrade.
  nvidia-driver = lib.importJSON ./nvidia/driver.json;
in
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

  targets.genericLinux.gpu.nvidia = {
    enable = true;
    inherit (nvidia-driver) version sha256;
  };
}
