dir="${CLAUDE_CODE_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/home-manager/claude-code}"

if [[ ! -f "$dir/manifest.zst.json" ]]; then
  echo "no manifest.zst.json in $dir; set CLAUDE_CODE_DIR to its directory" >&2
  exit 1
fi

BASE_URL="https://downloads.claude.ai/claude-code-releases"

current="$(jq -r .version "$dir/manifest.zst.json")"
version="${1:-$(curl -fsSL "$BASE_URL/latest")}"

if [[ "$version" == "$current" ]]; then
  echo "claude-code: already at $version" >&2
  exit 0
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "$BASE_URL/$version/manifest.zst.json" --output "$tmp"
jq -e .version "$tmp" >/dev/null
# cp rather than mv, to keep manifest.zst.json's permissions rather than mktemp's.
cp "$tmp" "$dir/manifest.zst.json"

echo "claude-code: $current -> $version" >&2
