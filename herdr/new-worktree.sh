# herdr popup action: herdr's "new worktree" dialog, except the worktree goes
# under <repo>/.worktrees/, made with git-mito when the repo has a git-mito
# base and with plain `git worktree add` otherwise.

# herdr's branch_to_path_slug: lowercase ASCII alphanumerics, every other run
# of characters becomes one dash.
set_slug() {
  slug=${1,,}
  slug=${slug//[^a-z0-9]/-}
  while [[ $slug == *--* ]]; do slug=${slug//--/-}; done
  slug=${slug#-}
  slug=${slug%-}
  slug=${slug:-worktree}
}

main='' branch='' cursor=0 creating='' error='' add=(git worktree add)

render() {
  local width=$((cols - 2)) offset=0 shown=''
  ((cursor <= width)) || offset=$((cursor - width))
  set_slug "$branch"
  [ -z "$main" ] || set_shown "$main/.worktrees/$slug"

  printf '\e[?25l'
  row 0 "$text" "$panel_bg" "new worktree" 1
  row 1 "$text" "$panel_bg" ""
  row 2 "$overlay0" "$panel_bg" " branch"
  row 3 "$text" "$surface0" " ${branch:offset:width}"
  row 4 "$text" "$panel_bg" ""
  row 5 "$overlay0" "$panel_bg" " checkout (${add[*]:0:2})"
  row 6 "$subtext0" "$panel_bg" " $shown"
  row 7 "$text" "$panel_bg" ""
  if [ -n "$creating" ]; then
    row 8 "$accent" "$panel_bg" " creating…"
  elif [ -n "$error" ]; then
    row 8 "$red" "$panel_bg" " $error"
  else
    row 8 "$text" "$panel_bg" ""
  fi
  buttons 9 ' ↵ create and open  ' 20 "$accent"

  [ -n "$creating" ] || printf '\e[4;%dH\e[?25h' "$((2 + cursor - offset))"
}

submit() {
  if [ -z "$branch" ]; then
    error="enter a branch name"
    return
  fi
  if ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
    error="not a valid branch name"
    return
  fi
  set_slug "$branch"
  local path="$main/.worktrees/$slug" out add_args
  # Same as herdr's built-in: check out the branch if it exists, else create it.
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    add_args=("$path" "$branch")
  else
    add_args=(-b "$branch" "$path")
  fi

  creating=1
  render
  if ! out=$("${add[@]}" "${add_args[@]}" 2>&1); then
    creating=''
    set_error "$out"
    return
  fi
  if ! out=$("${HERDR_BIN_PATH:-herdr}" worktree open --cwd "$main" \
    --path "$path" --focus 2>&1); then
    creating=''
    set_error "$out"
    return
  fi
  exit 0
}

# Work from the main worktree, as herdr's built-in does: new branches start at
# its HEAD, and herdr opens worktrees from the repo's parent workspace. The
# first entry is always the main worktree, even when run from a linked one.
cd "${HERDR_ACTIVE_PANE_CWD:-$PWD}"
if ! worktrees=$(git worktree list --porcelain 2>/dev/null); then
  error="not inside a git repository"
  render
  printf '\e[?25l'
  IFS= read -rsn1 -d '' _ || true
  exit 0
fi
main_line=${worktrees%%$'\n'*}
main=${main_line#worktree }
cd "$main"

# `git mito update` locks the base it creates with this reason.
if [[ $worktrees == *$'\nlocked managed by git-mito'* ]]; then
  add=(git mito add)
fi

while :; do
  render
  IFS= read -rsn1 -d '' key || exit 0
  case $key in
  $'\e')
    read_escape
    case $esc in
    '') exit 0 ;;
    '[D' | OD) ((cursor == 0)) || cursor=$((cursor - 1)) ;;
    '[C' | OC) ((cursor == ${#branch})) || cursor=$((cursor + 1)) ;;
    '[H' | OH | '[1~') cursor=0 ;;
    '[F' | OF | '[4~') cursor=${#branch} ;;
    '[3~') branch=${branch:0:cursor}${branch:cursor+1} ;;
    esac
    ;;
  $'\n' | $'\r') submit ;;
  $'\x03') exit 0 ;;
  $'\x01') cursor=0 ;;
  $'\x05') cursor=${#branch} ;;
  $'\x7f' | $'\b')
    if ((cursor > 0)); then
      branch=${branch:0:cursor-1}${branch:cursor}
      cursor=$((cursor - 1))
    fi
    ;;
  $'\x15')
    branch=${branch:cursor}
    cursor=0
    ;;
  $'\x17')
    head=${branch:0:cursor}
    while [[ $head == *[^[:alnum:]] ]]; do head=${head%?}; done
    while [[ $head == *[[:alnum:]] ]]; do head=${head%?}; done
    branch=$head${branch:cursor}
    cursor=${#head}
    ;;
  *)
    if [[ $key == [[:print:]] ]]; then
      branch=${branch:0:cursor}$key${branch:cursor}
      cursor=$((cursor + 1))
      error=''
    fi
    ;;
  esac
done
