#!/usr/bin/env bash
# Entry point for the pacman hook (see ./nvidia-nix-driver.hook).
#
# Takes the driver version from pacman rather than from the running kernel
# module: right after an upgrade the old module is still loaded, so
# /proc/driver/nvidia/version would report the version we're replacing.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pkg="${1:-nvidia-utils}"

# e.g. "nvidia-utils 615.71.09-1" -> "615.71.09-1"
pkgver="$(pacman -Q "$pkg" | awk '{ print $2 }')"

# Drop a leading epoch ("1:") and the trailing pkgrel ("-1") to get the
# upstream version that download.nvidia.com is indexed by.
version="${pkgver#*:}"
version="${version%-*}"

exec ./update.sh "$version"
