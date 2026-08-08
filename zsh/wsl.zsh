# ─────────────────────────────────────────────────────────────
#  Linux / WSL overrides
#
#  aliases.zsh and functions.zsh are byte-identical to the macOS
#  repo. Everything that cannot be identical lives here, sourced
#  last so it wins.
# ─────────────────────────────────────────────────────────────

# ── BSD → GNU ────────────────────────────────────────────────
# The macOS versions of these shell out to `top -l` and `lsof`.
alias free='free -h'
alias ports='ss -tulpn'

# ── Config shortcuts ─────────────────────────────────────────
# Ghostty has no Windows build; Windows Terminal owns the terminal here
# and its config lives on the Windows side of the filesystem.
unalias ghosttyconf 2>/dev/null
alias wtconf='$EDITOR "$DOTFILES/windows/settings.json"'
alias wslconf='$EDITOR "$DOTFILES/zsh/wsl.zsh"'

# Everything below is WSL-only; a plain Linux box stops here.
grep -qi microsoft /proc/version 2>/dev/null || return 0

# ── Windows interop ──────────────────────────────────────────
# `open .` opens the current directory in Explorer, as it does on macOS.
open() { explorer.exe "$(wslpath -w "${1:-.}")" 2>/dev/null || true; }

# The macOS clipboard commands, via Windows' own. Get-Clipboard costs ~200ms
# a call, which is fine at the prompt — it is only nvim, putting on every
# keystroke, that would have felt it.
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -NoProfile -Command "Get-Clipboard -Raw" | tr -d "\r"'

# Jump to the Windows user profile. USERPROFILE comes back with a trailing
# CR from powershell, and wslpath turns C:\Users\… into /mnt/c/Users/….
winhome() {
  local p
  p="$(powershell.exe -NoProfile -Command 'Write-Output $env:USERPROFILE' 2>/dev/null | tr -d '\r')"
  [[ -n "$p" ]] && builtin cd "$(wslpath -u "$p")"
}
