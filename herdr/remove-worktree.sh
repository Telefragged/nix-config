# herdr popup action: remove the current linked worktree and its branch, then
# close its herdr workspace. Enter only removes a clean worktree whose branch
# is merged into the main checkout's branch or its upstream; D removes it
# anyway.

wt='' branch='' workspace='' mito='' targets=()
fatal='' checking=1 removing='' error='' changes='' merged_into=''

safe() {
  [ "$changes" = 0 ] && { [ -z "$branch" ] || [ -n "$merged_into" ]; }
}

render() {
  local shown
  set_shown "$wt"
  printf '\e[?25l'
  if [ -n "$fatal" ]; then
    row 0 "$red" "$panel_bg" " can't remove this worktree" 1
    row 1 "$text" "$panel_bg" " $fatal"
    for r in 2 3 4 5 6; do row "$r" "$text" "$panel_bg" ""; done
    buttons 7 '' 0 ''
    return
  fi

  row 0 "$red" "$panel_bg" " remove worktree?" 1
  row 1 "$subtext0" "$panel_bg" " $shown"
  if [ -n "$branch" ]; then
    row 2 "$text" "$panel_bg" " Deletes the folder and the branch $branch."
  else
    row 2 "$text" "$panel_bg" " Deletes the folder. HEAD is detached, so there's no branch."
  fi
  if [ -n "$workspace" ]; then
    row 3 "$text" "$panel_bg" " The herdr workspace will close."
  else
    row 3 "$text" "$panel_bg" ""
  fi

  if [ -n "$checking" ]; then
    row 4 "$overlay0" "$panel_bg" " · uncommitted changes"
    row 5 "$overlay0" "$panel_bg" " · merged"
  else
    if [ "$changes" = 0 ]; then
      row 4 "$green" "$panel_bg" " ✓ no uncommitted changes"
    else
      local files='files'
      [ "$changes" != 1 ] || files='file'
      row 4 "$red" "$panel_bg" " ✗ $changes $files with uncommitted changes"
    fi
    if [ -z "$branch" ]; then
      row 5 "$text" "$panel_bg" ""
    elif [ -n "$merged_into" ]; then
      row 5 "$green" "$panel_bg" " ✓ merged into $merged_into"
    elif [ ${#targets[@]} -eq 0 ]; then
      row 5 "$red" "$panel_bg" " ✗ the main checkout has no branch to compare with"
    else
      local into=${targets[0]}
      [ ${#targets[@]} -lt 2 ] || into+=" or ${targets[1]}"
      row 5 "$red" "$panel_bg" " ✗ not merged into $into"
    fi
  fi

  if [ -n "$checking" ]; then
    row 6 "$accent" "$panel_bg" " checking…"
  elif [ -n "$removing" ]; then
    row 6 "$accent" "$panel_bg" " removing…"
  elif [ -n "$error" ]; then
    row 6 "$red" "$panel_bg" " $error"
  elif ! safe; then
    row 6 "$text" "$panel_bg" " Press D to remove it anyway."
  else
    row 6 "$text" "$panel_bg" ""
  fi

  if [ -n "$checking" ] || safe; then
    buttons 7 '     ↵ remove     ' 18 "$red"
  else
    buttons 7 ' D remove anyway  ' 18 "$red"
  fi
}

# Count uncommitted changes (untracked files too, not ignored ones), and find
# a target the branch is merged into: either the branch is in its history, or
# merging the branch would change nothing, which covers squash and rebase
# merges as long as the target hasn't edited the same lines since.
check() {
  local out lines t tree
  if ! out=$(git -C "$wt" status --porcelain 2>&1); then
    set_error "$out"
    changes='?'
    return
  fi
  mapfile -t lines < <(printf '%s' "$out")
  changes=${#lines[@]}
  [ -n "$branch" ] || return 0
  for t in "${targets[@]}"; do
    if git merge-base --is-ancestor "$branch" "$t" 2>/dev/null; then
      merged_into=$t
      return
    fi
    if tree=$(git merge-tree --write-tree "$t" "$branch" 2>/dev/null) &&
      [ "${tree%%$'\n'*}" = "$(git rev-parse "$t^{tree}")" ]; then
      merged_into=$t
      return
    fi
  done
}

remove() {
  local out remove=(git worktree remove)
  [ -z "$mito" ] || remove=(git mito remove)
  [ "$changes" = 0 ] || remove+=(--force)
  removing=1
  error=''
  render
  if ! out=$("${remove[@]}" "$wt" 2>&1); then
    removing=''
    set_error "$out"
    return
  fi
  if [ -n "$branch" ] && ! out=$(git branch -D "$branch" 2>&1); then
    removing=''
    set_error "$out"
    return
  fi
  if [ -n "$workspace" ]; then
    "${HERDR_BIN_PATH:-herdr}" workspace close "$workspace" >/dev/null 2>&1 || true
  fi
  exit 0
}

# Show $1 instead of the dialog and wait for a key.
fail() {
  fatal=$1
  render
  IFS= read -rsn1 -d '' _ || true
  exit 0
}

cd "${HERDR_ACTIVE_PANE_CWD:-$PWD}"
wt=$(git rev-parse --show-toplevel 2>/dev/null) || fail "not inside a git repository"
branch=$(git symbolic-ref --short -q HEAD) || branch=''
worktrees=$(git worktree list --porcelain)
main_line=${worktrees%%$'\n'*}
main=${main_line#worktree }
[ "$wt" != "$main" ] || fail "This is the main checkout, not a linked worktree."
# `git mito update` locks the base it creates with this reason.
entry=${worktrees#*$'\n'"worktree $wt"$'\n'}
entry=${entry%%$'\n\n'*}
[[ $'\n'$entry$'\n' != *$'\nlocked managed by git-mito\n'* ]] ||
  fail "This is git-mito's base."
[[ $worktrees != *$'\nlocked managed by git-mito'* ]] || mito=1
cd "$main"

if main_branch=$(git symbolic-ref --short -q HEAD); then
  targets=("$main_branch")
  if upstream=$(git rev-parse --abbrev-ref -q "$main_branch@{upstream}" 2>/dev/null); then
    targets+=("$upstream")
  fi
fi

# The herdr workspace showing this worktree, if it's open.
if out=$("${HERDR_BIN_PATH:-herdr}" worktree list --cwd "$main" 2>/dev/null); then
  workspace=$(jq -r --arg path "$wt" \
    '.result.worktrees[] | select(.path == $path) | .open_workspace_id // empty' \
    <<<"$out" 2>/dev/null) || workspace=''
fi

render
check
checking=''

while :; do
  render
  IFS= read -rsn1 -d '' key || exit 0
  case $key in
  $'\e')
    read_escape
    [ -n "$esc" ] || exit 0
    ;;
  $'\x03' | q) exit 0 ;;
  $'\n' | $'\r') if safe; then remove; fi ;;
  D) remove ;;
  esac
done
