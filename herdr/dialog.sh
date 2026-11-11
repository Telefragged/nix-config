# Shared by the herdr popup dialogs, which home.nix builds as this file
# followed by the dialog's own script, with writeShellApplication (so errexit,
# nounset and pipefail are on). The look is copied from herdr's own dialogs
# (src/client/shell/worktree_overlays.rs).

# herdr's default theme (Catppuccin Mocha), whatever theme herdr is set to.
# Every cell gets an explicit background, so popups stay opaque.
# shellcheck disable=SC2034 # each dialog uses only some of the colours
{
  panel_bg='24;24;37'
  surface0='49;50;68'
  overlay0='108;112;134'
  text='205;214;244'
  subtext0='166;173;200'
  accent='137;180;250'
  green='166;227;161'
  red='243;139;168'
}

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

# Draw $4 on row $1 (0-based) in colour $2 on $3, filling the rest of the row
# with the same background. $5 adds SGR attributes, e.g. 1 for bold.
row() {
  printf '\e[%d;1H\e[0;38;2;%s;48;2;%sm' "$(($1 + 1))" "$2" "$3"
  [ -z "${5:-}" ] || printf '\e[%sm' "$5"
  printf '%s\e[K' "${4:0:cols}"
}

# Buttons on row $1, centred like herdr's: a primary button with label $2,
# padded to $3 cells and drawn on colour $4 (left out when $2 is empty), then
# "esc cancel".
buttons() {
  local width=12
  [ -z "$2" ] || width=$(($3 + 2 + 12))
  row "$1" "$text" "$panel_bg" ""
  printf '\e[%d;%dH' "$(($1 + 1))" "$(((cols - width) / 2 + 1))"
  if [ -n "$2" ]; then
    printf '\e[0;1;38;2;%s;48;2;%sm%s' "$panel_bg" "$4" "$2"
    printf '\e[0;38;2;%s;48;2;%sm  ' "$text" "$panel_bg"
  fi
  printf '\e[0;1;38;2;%s;48;2;%sm esc cancel ' "$text" "$surface0"
}

# Shorten path $1 to fit a row: $HOME as ~, and the start cut off if needed.
set_shown() {
  shown=${1/#"$HOME"/\~}
  ((${#shown} < cols - 1)) || shown="…${shown: -$((cols - 3))}"
}

# Last non-empty line of $1, unwrapping herdr's JSON errors to their message.
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

# Read the rest of an escape sequence into $esc; empty means a lone Esc.
read_escape() {
  local c
  esc=''
  while IFS= read -rsn1 -d '' -t 0.02 c; do
    esc+=$c
    if [ ${#esc} -eq 1 ] && [ "$c" != '[' ] && [ "$c" != O ]; then break; fi
    if [ ${#esc} -gt 1 ] && [[ $c == [A-Za-z~] ]]; then break; fi
  done
}
