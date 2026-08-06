# ─────────────────────────────────────────────────────────────
#  Functions
# ─────────────────────────────────────────────────────────────

# mkcd — make a directory and cd into it
mkcd() { mkdir -p -- "$1" && cd -- "$1" || return; }

# extract — unpack (almost) any archive
extract() {
  [[ -f "$1" ]] || { echo "extract: '$1' is not a file" >&2; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1"   ;;
    *.tar.gz|*.tgz)   tar xzf "$1"   ;;
    *.tar.xz)         tar xJf "$1"   ;;
    *.tar)            tar xf "$1"    ;;
    *.bz2)            bunzip2 "$1"   ;;
    *.gz)             gunzip "$1"    ;;
    *.zip)            unzip "$1"     ;;
    *.7z)             7z x "$1"      ;;
    *.rar)            unrar x "$1"   ;;
    *.Z)              uncompress "$1";;
    *) echo "extract: don't know how to handle '$1'" >&2; return 1 ;;
  esac
}

# ff — fuzzy-find a file and open it in $EDITOR
ff() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range :300 {}') || return
  [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
}

# fkill — fuzzy-pick a process and kill it
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --header='[kill:process]' | awk '{print $2}') || return
  [[ -n "$pid" ]] && echo "$pid" | xargs kill "-${1:-15}"
}

# gcob — fuzzy git branch checkout
gcob() {
  local branch
  branch=$(git branch --all --sort=-committerdate |
    grep -v HEAD | sed 's/^[* ]*//;s#^remotes/[^/]*/##' | awk '!seen[$0]++' |
    fzf --header='[checkout:branch]') || return
  [[ -n "$branch" ]] && git checkout "$branch"
}

# up — go up N directories: `up 3`
up() {
  local n="${1:-1}" p="" i
  for (( i = 0; i < n; i++ )); do p="../$p"; done
  cd "$p" || return
}

# dotpush — commit and push the dotfiles repo in one shot
dotpush() {
  git -C "$DOTFILES" add --all &&
  git -C "$DOTFILES" commit -m "${1:-chore: update dotfiles}" &&
  git -C "$DOTFILES" push
}
