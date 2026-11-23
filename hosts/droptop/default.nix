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

  # Home Manager rejects `extensions` for Google Chrome on Linux, so the Claude
  # extension is placed in the external-extensions directory next to the chrome
  # binary, which Chrome scans at startup and installs from the Web Store.
  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        mkdir -p $out/share/google/chrome/extensions
        echo '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }' \
          > $out/share/google/chrome/extensions/fcoeoabgfenejglbffodgkkbkcdhcgfn.json
      '';
    });
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
