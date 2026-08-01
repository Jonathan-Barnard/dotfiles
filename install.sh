#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  dotfiles installer
#  Usage: ./install.sh [--dry-run] [--no-brew] [--no-font]
#                      [--no-nvim-sync] [--force] [--help]
# ─────────────────────────────────────────────────────────────
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

DRY_RUN=0
DO_BREW=1
DO_FONT=1
DO_NVIM_SYNC=1
FORCE=0

# ── Pretty output (gruvbox-ish) ──────────────────────────────
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
  C_RED=$'\033[38;5;167m'; C_GREEN=$'\033[38;5;142m'
  C_YELLOW=$'\033[38;5;214m'; C_BLUE=$'\033[38;5;109m'
  C_AQUA=$'\033[38;5;108m'; C_ORANGE=$'\033[38;5;208m'
else
  C_RESET=""; C_DIM=""; C_BOLD=""
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_AQUA=""; C_ORANGE=""
fi

info()  { printf '%s  %s%s\n' "$C_BLUE" "$*" "$C_RESET"; }
ok()    { printf '%s  %s%s\n' "$C_GREEN" "$*" "$C_RESET"; }
warn()  { printf '%s  %s%s\n' "$C_YELLOW" "$*" "$C_RESET"; }
err()   { printf '%s  %s%s\n' "$C_RED" "$*" "$C_RESET" >&2; }
skip()  { printf '%s  %s%s\n' "$C_DIM" "$*" "$C_RESET"; }

header() {
  printf '\n%s%s╭─────────────────────────────────────────────────╮%s\n' "$C_BOLD" "$C_ORANGE" "$C_RESET"
  printf '%s%s│%s %-47s %s%s│%s\n' "$C_BOLD" "$C_ORANGE" "$C_RESET" "$1" "$C_BOLD" "$C_ORANGE" "$C_RESET"
  printf '%s%s╰─────────────────────────────────────────────────╯%s\n' "$C_BOLD" "$C_ORANGE" "$C_RESET"
}

banner() {
  printf '%s\n' "$C_ORANGE"
  cat <<'ART'
   ╔╦╗╔═╗╔╦╗╔═╗╦╦  ╔═╗╔═╗
    ║║║ ║ ║ ╠╣ ║║  ║╣ ╚═╗
   ═╩╝╚═╝ ╩ ╚  ╩╩═╝╚═╝╚═╝
ART
  printf '%s   ghostty · zsh · starship · neovim  %s│%s  gruvbox\n%s\n' \
    "$C_DIM" "$C_ORANGE" "$C_DIM" "$C_RESET"
}

usage() {
  cat <<'USAGE'
dotfiles installer

  ./install.sh [options]

Options:
  --dry-run        Show what would happen, change nothing
  --no-brew        Skip Homebrew and package installation
  --no-font        Skip the Nerd Font cask
  --no-nvim-sync   Skip headless Neovim plugin sync
  --force          Replace existing files without prompting
  -h, --help       Show this help

The script is idempotent: run it as often as you like.
Anything it replaces is backed up to ~/.dotfiles-backup/<timestamp>/
USAGE
}

# ── Arg parsing ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)      DRY_RUN=1 ;;
    --no-brew)      DO_BREW=0 ;;
    --no-font)      DO_FONT=0 ;;
    --no-nvim-sync) DO_NVIM_SYNC=0 ;;
    --force)        FORCE=1 ;;
    -h|--help)      usage; exit 0 ;;
    *)              err "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s    would run: %s%s\n' "$C_DIM" "$*" "$C_RESET"
  else
    "$@"
  fi
}

# ── OS detection ─────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      err "Unsupported OS: $OS"; exit 1 ;;
esac

# ── 1. Homebrew ──────────────────────────────────────────────
install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew already installed ($(brew --version | head -1))"
  else
    info "Installing Homebrew…"
    if [[ $DRY_RUN -eq 1 ]]; then
      skip "would install Homebrew from brew.sh"
      return
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Make brew available in this shell session
  for p in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x "$p" ]] && eval "$("$p" shellenv)" && break
  done
}

# ── 2. Packages ──────────────────────────────────────────────
install_packages() {
  if ! command -v brew >/dev/null 2>&1; then
    warn "brew not on PATH — skipping package install"
    return
  fi

  local brewfile="$DOTFILES_DIR/Brewfile"
  if [[ $DO_FONT -eq 0 ]]; then
    brewfile="$(mktemp)"
    grep -v 'nerd-font' "$DOTFILES_DIR/Brewfile" > "$brewfile"
    warn "Skipping Nerd Font (--no-font) — powerline glyphs will render as boxes"
  fi

  if [[ "$PLATFORM" != "macos" ]] && grep -q '^cask' "$brewfile"; then
    local tmp; tmp="$(mktemp)"
    grep -v '^cask' "$brewfile" > "$tmp"
    brewfile="$tmp"
    warn "Casks are macOS-only — install a Nerd Font manually on Linux"
  fi

  info "Installing packages from Brewfile…"
  run brew bundle --file="$brewfile"
  ok "Packages up to date"
}

# ── 3. Symlinking ────────────────────────────────────────────
link() {
  local src="$DOTFILES_DIR/$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    err "Missing source: $src"
    return 1
  fi

  # Already pointing where we want it
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    skip "linked   ${dest/#$HOME/\~}"
    return 0
  fi

  run mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ $FORCE -eq 0 && $DRY_RUN -eq 0 && -t 0 ]]; then
      printf '%s  ?  %s exists. Back up and replace? [Y/n] %s' \
        "$C_YELLOW" "${dest/#$HOME/\~}" "$C_RESET"
      read -r reply
      [[ "$reply" =~ ^[Nn]$ ]] && { skip "kept     ${dest/#$HOME/\~}"; return 0; }
    fi
    run mkdir -p "$BACKUP_DIR"
    run mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
    warn "backed up ${dest/#$HOME/\~} → ${BACKUP_DIR/#$HOME/\~}/"
  fi

  run ln -sfn "$src" "$dest"
  ok "linked   ${dest/#$HOME/\~}"
}

LINK_FAILURES=0

link_all() {
  # A single bad link should not abort the whole install.
  link "zsh/zshrc"                "$HOME/.zshrc"                    || LINK_FAILURES=$((LINK_FAILURES + 1))
  link "zsh/aliases.zsh"          "$CONFIG_HOME/zsh/aliases.zsh"    || LINK_FAILURES=$((LINK_FAILURES + 1))
  link "zsh/functions.zsh"        "$CONFIG_HOME/zsh/functions.zsh"  || LINK_FAILURES=$((LINK_FAILURES + 1))
  link "starship/starship.toml"   "$CONFIG_HOME/starship.toml"      || LINK_FAILURES=$((LINK_FAILURES + 1))
  link "ghostty/config"           "$CONFIG_HOME/ghostty/config"     || LINK_FAILURES=$((LINK_FAILURES + 1))
  link "bat/config"               "$CONFIG_HOME/bat/config"         || LINK_FAILURES=$((LINK_FAILURES + 1))
  link "nvim"                     "$CONFIG_HOME/nvim"               || LINK_FAILURES=$((LINK_FAILURES + 1))

  if [[ $LINK_FAILURES -gt 0 ]]; then
    err "$LINK_FAILURES link(s) failed — see the messages above"
  fi
}

# ── 4. Shell ─────────────────────────────────────────────────
set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  [[ -z "$zsh_path" ]] && { warn "zsh not found — skipping"; return; }

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    ok "zsh is already your login shell"
    return
  fi

  if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    info "Adding $zsh_path to /etc/shells (needs sudo)"
    if [[ $DRY_RUN -eq 1 ]]; then
      skip "would append $zsh_path to /etc/shells"
    else
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
  fi

  info "Setting default shell to $zsh_path (needs your password)"
  run chsh -s "$zsh_path"
  ok "Default shell set — takes effect in new terminals"
}

# ── 5. Neovim plugin sync ────────────────────────────────────
sync_neovim() {
  if ! command -v nvim >/dev/null 2>&1; then
    warn "nvim not found — skipping plugin sync"
    return
  fi
  info "Syncing Neovim plugins (this takes a minute on first run)…"
  if [[ $DRY_RUN -eq 1 ]]; then
    skip "would run: nvim --headless '+Lazy! sync' +qa"
    return
  fi
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || warn "Plugin sync reported issues — open nvim and run :Lazy"
  ok "Neovim plugins installed"
}

# ── 6. Post-install checks ───────────────────────────────────
doctor() {
  local missing=()
  for tool in zsh nvim starship eza bat fd rg fzf zoxide git; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    ok "All expected tools are on PATH"
  else
    warn "Not found on PATH: ${missing[*]}"
    warn "Open a new terminal (Homebrew's PATH may not be loaded yet) and re-check."
  fi

  if [[ "$PLATFORM" == "macos" ]]; then
    local font_found=0 dir
    for dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
      [[ -d "$dir" ]] || continue
      if compgen -G "$dir/JetBrainsMono*Nerd*" >/dev/null; then font_found=1; break; fi
    done
    if [[ $font_found -eq 1 ]]; then
      ok "JetBrainsMono Nerd Font detected"
    else
      warn "JetBrainsMono Nerd Font not detected — powerline glyphs may render as boxes"
    fi
  fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
  banner
  [[ $DRY_RUN -eq 1 ]] && warn "DRY RUN — nothing will be modified"
  info "Platform: $PLATFORM"
  info "Dotfiles: $DOTFILES_DIR"

  if [[ $DO_BREW -eq 1 ]]; then
    header "1/5  Homebrew"
    install_homebrew
    header "2/5  Packages"
    install_packages
  else
    warn "Skipping Homebrew and packages (--no-brew)"
  fi

  header "3/5  Symlinks"
  link_all

  header "4/5  Default shell"
  set_default_shell

  header "5/5  Neovim"
  if [[ $DO_NVIM_SYNC -eq 1 ]]; then
    sync_neovim
  else
    warn "Skipping Neovim plugin sync (--no-nvim-sync)"
  fi

  header "Doctor"
  doctor

  printf '\n%s%s  Done.%s\n' "$C_BOLD" "$C_GREEN" "$C_RESET"
  cat <<EOF

  ${C_AQUA}Next steps${C_RESET}
    1. Quit and reopen Ghostty (or press ⌘⇧, to reload its config)
    2. Open a new terminal — the powerline prompt should appear
    3. Run ${C_YELLOW}nvim${C_RESET}; Mason will fetch LSP servers on first launch
    4. Run ${C_YELLOW}:checkhealth${C_RESET} inside Neovim to confirm everything is wired up

  ${C_DIM}Backups (if any): ${BACKUP_DIR}${C_RESET}
  ${C_DIM}Machine-specific overrides go in ~/.zshrc.local (git-ignored)${C_RESET}

EOF
}

main "$@"
