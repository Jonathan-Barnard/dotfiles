# ─────────────────────────────────────────────────────────────
#  Aliases
# ─────────────────────────────────────────────────────────────

# ── eza (ls replacement) ─────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias l='eza -lbF --git --group-directories-first --icons=auto'
  alias ll='eza -lbGF --git --group-directories-first --icons=auto'
  alias la='eza -lbhHigUmuSa --git --group-directories-first --icons=auto --time-style=long-iso'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
  alias ltt='eza --tree --level=4 --group-directories-first --icons=auto'
else
  alias ls='ls -G'
  alias ll='ls -lh'
  alias la='ls -lah'
fi

# ── bat (cat replacement) ────────────────────────────────────
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'
fi

# ── Navigation ───────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# ── Safety nets ──────────────────────────────────────────────
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# ── Git ──────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gca='git commit -v --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gp='git push'
alias gpl='git pull --rebase'
alias gf='git fetch --all --prune'
alias gb='git branch -vv'
alias gl="git log --graph --pretty=format:'%C(yellow)%h%Creset %C(cyan)%an%Creset %C(green)(%ar)%Creset%C(auto)%d%Creset %s' --abbrev-commit -25"
alias gla="git log --graph --pretty=format:'%C(yellow)%h%Creset %C(cyan)%an%Creset %C(green)(%ar)%Creset%C(auto)%d%Creset %s' --abbrev-commit --all"
alias gst='git stash'
alias gstp='git stash pop'

# ── Editor ───────────────────────────────────────────────────
alias v='vim'
alias nv='vim'

# ── Dotfiles ─────────────────────────────────────────────────
alias dot='cd "$DOTFILES"'
alias dotedit='$EDITOR "$DOTFILES"'
alias reload='exec zsh'
alias zshconf='$EDITOR "$DOTFILES/zsh/zshrc"'
alias ghosttyconf='$EDITOR "$DOTFILES/ghostty/config"'
alias starconf='$EDITOR "$DOTFILES/starship/starship.toml"'

# ── Misc quality of life ─────────────────────────────────────
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='top -l 1 -s 0 | grep PhysMem'
alias path='echo -e ${PATH//:/\\n}'
alias ports='lsof -i -P -n | grep LISTEN'
alias ip='curl -s https://ifconfig.me && echo'
alias serve='python3 -m http.server'
alias week='date +%V'
alias now='date "+%Y-%m-%d %H:%M:%S"'
