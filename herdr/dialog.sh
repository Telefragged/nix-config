# shellcheck disable=SC2034 # each dialog uses only some of the colours
use_catppuccin_mocha() {
  panel_bg='24;24;37'
  surface0='49;50;68'
  overlay0='108;112;134'
  text='205;214;244'
  subtext0='166;173;200'
  accent='137;180;250'
  green='166;227;161'
  red='243;139;168'
}
use_catppuccin_mocha

saved_tty=$(stty -g)
cleanup() {
  local status=$?
  printf '\e[0m\e[?25h'
  stty "$saved_tty"
  exit "$status"
}
trap cleanup EXIT
stty -icanon -echo -isig -ixon
size=$(stty size)
cols=${size#* }

row() {
  local line=$1 fg=$2 bg=$3 content=$4 sgr=${5:-}
  printf '\e[%d;1H\e[0;38;2;%s;48;2;%sm' "$((line + 1))" "$fg" "$bg"
  [ -z "$sgr" ] || printf '\e[%sm' "$sgr"
  printf '%s\e[K' "${content:0:cols}"
}

buttons() {
  local line=$1 label=$2 label_width=$3 label_bg=$4 width=12
  [ -z "$label" ] || width=$((label_width + 2 + 12))
  row "$line" "$text" "$panel_bg" ""
  printf '\e[%d;%dH' "$((line + 1))" "$(((cols - width) / 2 + 1))"
  if [ -n "$label" ]; then
    printf '\e[0;1;38;2;%s;48;2;%sm%s' "$panel_bg" "$label_bg" "$label"
    printf '\e[0;38;2;%s;48;2;%sm  ' "$text" "$panel_bg"
  fi
  printf '\e[0;1;38;2;%s;48;2;%sm esc cancel ' "$text" "$surface0"
}

set_shown() {
  shown=${1/#"$HOME"/\~}
  ((${#shown} < cols - 1)) || shown="…${shown: -$((cols - 3))}"
}

set_error() {
  local line
  error=''
  while IFS= read -r line; do
    [ -z "$line" ] || error=$line
  done <<<"$1"
  if [[ $error =~ \"message\":\"([^\"]*)\" ]]; then
    error=${BASH_REMATCH[1]}
  fi
}

read_escape() {
  local c
  esc=''
  while IFS= read -rsn1 -d '' -t 0.02 c; do
    esc+=$c
    if [ ${#esc} -eq 1 ] && [ "$c" != '[' ] && [ "$c" != O ]; then break; fi
    if [ ${#esc} -gt 1 ] && [[ $c == [A-Za-z~] ]]; then break; fi
  done
}

set_merge_targets() {
  local main_branch upstream
  targets=()
  main_branch=$(git symbolic-ref --short -q HEAD) || return 0
  targets=("$main_branch")
  if upstream=$(git rev-parse --abbrev-ref -q "$main_branch@{upstream}" 2>/dev/null); then
    targets+=("$upstream")
  fi
}
