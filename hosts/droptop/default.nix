# Configuration that only applies to droptop. Shared configuration lives in
# ../../home.nix.
{ pkgs, lib, ... }:
let
  # The Nvidia driver version must match the one the host kernel runs, so
  # ./nvidia/driver.json is generated from it by ./nvidia/update.sh — rerun that
  # script after a host driver upgrade.
  nvidia-driver = lib.importJSON ./nvidia/driver.json;
in
{
  programs.git.settings.user.email = "vetle.braend@gmail.com";

  targets.genericLinux.gpu.nvidia = {
    enable = true;
    inherit (nvidia-driver) version sha256;
  };

  services.ollama = {
    enable = true;

    package = pkgs.ollama-cuda;

    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_CONTEXT_LENGTH = "204800";
    };
  };
}
