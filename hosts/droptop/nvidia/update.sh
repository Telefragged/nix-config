#!/usr/bin/env bash
# Regenerates nvidia/driver.json from the driver version the host kernel is
# currently running, so targets.genericLinux.gpu.nvidia stays in sync with it.
#
# Usage: ./nvidia/update.sh [version]

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Matches the version format home-manager's gpu.nvidia.version option accepts.
version_re='[0-9]{3}\.[0-9]{2,3}(\.[0-9]{2,3})?'

host_version() {
  # Present on most distributions ...
  if [[ -r /sys/module/nvidia/version ]]; then
    cat /sys/module/nvidia/version
    return
  fi

  # ... but not all of them, so fall back to the NVRM banner, whose wording
  # differs between the proprietary and open kernel modules.
  if [[ -r /proc/driver/nvidia/version ]]; then
    grep -Eom1 "$version_re" /proc/driver/nvidia/version
    return
  fi

  echo "no loaded Nvidia driver found; pass the version explicitly" >&2
  return 1
}

case "$(uname -m)" in
  x86_64) arch=x86_64 ;;
  aarch64) arch=aarch64 ;;
  *)
    echo "unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

version="${1:-$(host_version)}"

if ! grep -Eqx "$version_re" <<<"$version"; then
  echo "unexpected driver version: $version" >&2
  exit 1
fi

# Prefetching downloads the whole ~400MB installer, so don't redo it when the
# pinned version is already the requested one (e.g. an Arch pkgrel-only bump).
if [[ -e driver.json ]] && [[ "$(jq -r .version driver.json)" == "$version" ]]; then
  echo "nvidia/driver.json: already at $version, nothing to do" >&2
  exit 0
fi

url="https://download.nvidia.com/XFree86/Linux-$arch/$version/NVIDIA-Linux-$arch-$version.run"

sha256="$(nix store prefetch-file --json "$url" | jq -r .hash)"

jq -n --arg version "$version" --arg sha256 "$sha256" '{ $version, $sha256 }' \
  > driver.json

echo "nvidia/driver.json: $version ($sha256)" >&2
