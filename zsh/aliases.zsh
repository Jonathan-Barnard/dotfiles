# ── aliases & small helpers ────────────────────────────────────────────────
# Edit freely; this file is sourced by ~/.zshrc.

# eza — a colourful, git-aware ls
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -l  --group-directories-first --icons=auto --git --time-style=long-iso'
  alias la='eza -la --group-directories-first --icons=auto --git --time-style=long-iso'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
  alias ltt='eza --tree --level=4 --icons=auto --group-directories-first'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lh'
  alias la='ls -lah'
fi

# bat — Ubuntu ships the binary as `batcat`
if command -v batcat >/dev/null; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
elif command -v bat >/dev/null; then
  alias cat='bat --paging=never'
fi

# fd — Ubuntu ships the binary as `fdfind`
command -v fdfind >/dev/null && alias fd='fdfind'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# safety nets
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'
alias mkdir='mkdir -p'

# git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --graph --oneline --decorate --all -20'

# misc
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias path='echo $PATH | tr ":" "\n"'
alias reload='exec zsh'
alias zshrc='${EDITOR:-nano} ~/.zshrc'
alias starconf='${EDITOR:-nano} ~/.config/starship.toml'

# ── WSL conveniences ───────────────────────────────────────────────────────
if grep -qi microsoft /proc/version 2>/dev/null; then
  alias open='explorer.exe'                  # open . opens the folder in Explorer
  alias pbcopy='clip.exe'                    # pipe into the Windows clipboard
  alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard'
  alias winhome='cd "$(wslpath "$(cmd.exe /c echo %USERPROFILE% 2>/dev/null | tr -d "\r")")"'
fi

# mkcd — make a directory and step into it
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# extract — unpack more or less any archive
extract() {
  [[ -f "$1" ]] || { echo "extract: '$1' is not a file" >&2; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf  "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.gz)             gunzip  "$1" ;;
    *.zip)            unzip   "$1" ;;
    *.7z)             7z x    "$1" ;;
    *.rar)            unrar x "$1" ;;
    *) echo "extract: don't know how to handle '$1'" >&2; return 1 ;;
  esac
}

# ── neovim ─────────────────────────────────────────────────────────────────
if command -v nvim >/dev/null; then
  alias vim='nvim'
  alias vi='nvim'
  alias v='nvim'
  # open the shell config in neovim
  alias nvimrc='nvim ~/.config/nvim/init.lua'
fi
