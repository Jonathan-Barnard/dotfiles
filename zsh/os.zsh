# ─────────────────────────────────────────────────────────────
#  Per-OS overrides
#
#  aliases.zsh and functions.zsh are platform-neutral. Anything
#  that has to differ between macOS, Linux and WSL lives here,
#  and this file is sourced last so it wins.
# ─────────────────────────────────────────────────────────────

case "$(uname -s)" in
  Darwin) DOTFILES_OS="macos" ;;
  Linux)  DOTFILES_OS="linux" ;;
  *)      DOTFILES_OS="unknown" ;;
esac

# WSL is Linux with a Windows host bolted on, so it takes both blocks.
DOTFILES_WSL=0
[[ "$DOTFILES_OS" == "linux" ]] \
  && grep -qi microsoft /proc/version 2>/dev/null \
  && DOTFILES_WSL=1

export DOTFILES_OS DOTFILES_WSL

alias osconf='$EDITOR "$DOTFILES/zsh/os.zsh"'

# ── macOS ────────────────────────────────────────────────────
if [[ "$DOTFILES_OS" == "macos" ]]; then
  alias free='top -l 1 -s 0 | grep PhysMem'
  alias ports='lsof -i -P -n | grep LISTEN'
  # pbcopy/pbpaste and open are already real commands here.
fi

# ── Linux, including WSL ─────────────────────────────────────
if [[ "$DOTFILES_OS" == "linux" ]]; then
  alias free='free -h'
  alias ports='ss -tulpn'
fi

# ── Linux on a real desktop ──────────────────────────────────
if [[ "$DOTFILES_OS" == "linux" ]] && (( ! DOTFILES_WSL )); then
  open() { xdg-open "${1:-.}" >/dev/null 2>&1 & }

  # The macOS clipboard names, on whichever tool this box has.
  if command -v wl-copy &>/dev/null; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  elif command -v xclip &>/dev/null; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
  fi
fi

# ── WSL ──────────────────────────────────────────────────────
if (( DOTFILES_WSL )); then
  alias wtconf='$EDITOR "$DOTFILES/windows/settings.json"'

  # `open .` opens the current directory in Explorer, as it does on macOS.
  open() { explorer.exe "$(wslpath -w "${1:-.}")" 2>/dev/null || true; }

  # Get-Clipboard costs ~200ms a call, which is fine at the prompt — it is
  # only nvim, putting on every keystroke, that would have felt it.
  alias pbcopy='clip.exe'
  alias pbpaste='powershell.exe -NoProfile -Command "Get-Clipboard -Raw" | tr -d "\r"'

  # Jump to the Windows user profile. USERPROFILE comes back with a trailing
  # CR from powershell, and wslpath turns C:\Users\… into /mnt/c/Users/….
  winhome() {
    local p
    p="$(powershell.exe -NoProfile -Command 'Write-Output $env:USERPROFILE' 2>/dev/null | tr -d '\r')"
    [[ -n "$p" ]] && builtin cd "$(wslpath -u "$p")"
  }
fi
