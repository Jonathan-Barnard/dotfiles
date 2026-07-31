# ── fuzzy finding: fzf + zoxide ────────────────────────────────────────────
# Sourced by ~/.zshrc. Safe to edit.

if command -v fzf >/dev/null; then

  # Use fd for listing — fast, skips .git, respects .gitignore.
  # Ubuntu names the binary fdfind.
  #
  # Deliberately NOT using --follow. On WSL it is common to keep a symlink to
  # the Windows side (~/to_windows -> /mnt/c/Users/you), and --follow would
  # make every search descend through it into the whole Windows profile, over
  # the slow interop filesystem. Symlinks are still listed, just not entered;
  # cd into one and searches there work normally.
  _fd="$(command -v fdfind || command -v fd || true)"
  if [[ -n $_fd ]]; then
    _fd_common="--hidden --exclude .git --exclude node_modules --exclude .cache"
    export FZF_DEFAULT_COMMAND="$_fd --type=file ${_fd_common}"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$_fd --type=directory ${_fd_common}"
    unset _fd_common
  fi
  unset _fd

  # Catppuccin Mocha, matching the rest of the setup
  export FZF_DEFAULT_OPTS="
    --height=60% --layout=reverse --border=rounded --info=inline
    --prompt='  ' --pointer='▶' --marker='✚'
    --cycle --multi --scroll-off=3
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-a:select-all,ctrl-d:deselect-all'
    --bind='shift-up:preview-page-up,shift-down:preview-page-down'
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --color=border:#585b70,gutter:#1e1e2e"

  # Ctrl+T — find a file, with a preview pane
  export FZF_CTRL_T_OPTS="
    --preview='fzf-preview {}'
    --preview-window='right:60%:wrap'
    --header='enter: insert path · ctrl-/: hide preview'"

  # Alt+C — jump into a directory
  export FZF_ALT_C_OPTS="
    --preview='fzf-preview {}'
    --preview-window='right:55%'
    --header='enter: cd into directory'"

  # Ctrl+R — search history. Preview hidden until you hit ctrl-/, since long
  # commands are the only ones that need it.
  export FZF_CTRL_R_OPTS="
    --preview='echo {2..}'
    --preview-window='down:4:hidden:wrap'
    --header='enter: run · ctrl-/: show full command'"

  # Shell integration. fzf 0.48+ can emit it directly; Ubuntu 24.04 ships
  # 0.44, which installs the scripts under /usr/share instead.
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    for _f in /usr/share/doc/fzf/examples/key-bindings.zsh \
              /usr/share/doc/fzf/examples/completion.zsh \
              /usr/share/fzf/key-bindings.zsh \
              /usr/share/fzf/completion.zsh; do
      [[ -f $_f ]] && source $_f
    done
    unset _f
  fi

  # ── helper functions ─────────────────────────────────────────────────────

  # ff — fuzzy-find a file and open it in $EDITOR
  ff() {
    local file
    file=$(fzf --preview='fzf-preview {}' --preview-window='right:60%:wrap' \
               --header='select a file to edit') || return
    [[ -n $file ]] && ${EDITOR:-nano} -- "$file"
  }

  # fh — search history and put the chosen command on the command line
  fh() {
    local cmd
    cmd=$(fc -rl 1 | fzf --tac --header='select a command' | sed 's/^ *[0-9]* *//') || return
    [[ -n $cmd ]] && print -z -- "$cmd"
  }

  # fbr — check out a git branch, local or remote
  fbr() {
    git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; return 1; }
    local branch
    branch=$(git branch --all --color=never \
      | grep -v HEAD | sed 's/^[* ] //;s#^remotes/[^/]*/##' | sort -u \
      | fzf --ansi --header='select a branch to check out' \
            --preview='git log --oneline --graph --color=always -20 {}') || return
    [[ -n $branch ]] && git checkout "$branch"
  }

  # fkill — pick a process and terminate it
  fkill() {
    local pids
    pids=$(ps -eo pid,ppid,user,pcpu,pmem,comm --sort=-pcpu \
      | fzf --header-lines=1 --multi \
            --header='select process(es) to kill · tab to multi-select' \
      | awk '{print $1}') || return
    [[ -n $pids ]] && echo "$pids" | xargs --no-run-if-empty kill "${@:--15}"
  }

  # frg — ripgrep across the tree, then open the match at the right line
  frg() {
    [[ -n ${1:-} ]] || { echo "usage: frg <pattern>" >&2; return 1; }
    local match file line
    match=$(rg --line-number --no-heading --color=always --smart-case -- "$1" \
      | fzf --ansi --delimiter=: \
            --preview='fzf-preview {1}' --preview-window='right:60%:+{2}-/2') || return
    [[ -n $match ]] || return
    file=${match%%:*}; line=${${match#*:}%%:*}
    ${EDITOR:-nano} +"$line" -- "$file"
  }
fi

# ── zoxide: jump to directories by partial name ─────────────────────────────
# `z proj` goes to the project directory you use most; `zi` picks from a list.
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi
