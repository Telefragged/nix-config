# Bumps the pinned Claude Code version by replacing manifest.json with the
# release's manifest. Wrapped as `update-claude-code` by ./default.nix.
#
# Usage: update-claude-code [version]
#
# The manifest is looked up in the home-manager configuration, at the same
# default location home-manager itself uses; set CLAUDE_CODE_DIR to the
# directory holding manifest.json to point it elsewhere.

dir="${CLAUDE_CODE_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/home-manager/claude-code}"

if [[ ! -f "$dir/manifest.json" ]]; then
  echo "no manifest.json in $dir; set CLAUDE_CODE_DIR to its directory" >&2
  exit 1
fi

BASE_URL="https://downloads.claude.ai/claude-code-releases"

current="$(jq -r .version "$dir/manifest.json")"
version="${1:-$(curl -fsSL "$BASE_URL/latest")}"

if [[ "$version" == "$current" ]]; then
  echo "claude-code: already at $version" >&2
  exit 0
fi

# Download to a temporary file first, so a failed request doesn't leave a
# truncated manifest behind.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "$BASE_URL/$version/manifest.json" --output "$tmp"
jq -e .version "$tmp" >/dev/null
# cp rather than mv, to keep manifest.json's permissions rather than mktemp's.
cp "$tmp" "$dir/manifest.json"

echo "claude-code: $current -> $version" >&2
