#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  dotfiles installer  ·  macOS · Linux · WSL
#  Usage: ./install.sh [--dry-run] [--no-brew] [--no-font]
#                      [--force] [--help]
#
#  One declarative LINKS array and one Brewfile. Homebrew on every
#  platform, so all three machines get the same versions of the same
#  tools at the same paths; the native package manager is used only
#  for Homebrew's own prerequisites and the things it cannot supply.
# ─────────────────────────────────────────────────────────────
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

DRY_RUN=0
DO_BREW=1
DO_FONT=1
FORCE=0

# Everything this repo installs, as src:dest pairs.
LINKS=(
  "zsh/zshrc:$HOME/.zshrc"
  "zsh/aliases.zsh:$CONFIG_HOME/zsh/aliases.zsh"
  "zsh/functions.zsh:$CONFIG_HOME/zsh/functions.zsh"
  "zsh/os.zsh:$CONFIG_HOME/zsh/os.zsh"
  "starship/starship.toml:$CONFIG_HOME/starship.toml"
  "ghostty/config:$CONFIG_HOME/ghostty/config"
  "bat/config:$CONFIG_HOME/bat/config"
  "nvim:$CONFIG_HOME/nvim"
)

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
header() { printf '\n%s%s── %s %s%s\n' "$C_BOLD" "$C_ORANGE" "$1" \
             "$(printf '─%.0s' $(seq 1 $((44 - ${#1}))))" "$C_RESET"; }

# Shorten $HOME to ~ for display. The replacement goes through a variable
# because a literal `\~` here would survive into the output as a backslash.
tilde() { local t='~'; printf '%s' "${1/#$HOME/$t}"; }

usage() {
  cat <<'USAGE'
dotfiles installer

  ./install.sh [options]

Options:
  --dry-run    Show what would happen, change nothing
  --no-brew    Skip Homebrew and package installation
  --no-font    Skip the JetBrainsMono Nerd Font
  --force      Replace existing files without prompting
  -h, --help   Show this help

Works on macOS, Linux and WSL. The script is idempotent: run it as
often as you like. Anything it replaces is backed up to
~/.dotfiles-backup/<timestamp>/

On WSL the font and colours belong to Windows Terminal, which lives
outside WSL — see windows/README.md for that half.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --no-brew) DO_BREW=0 ;;
    --no-font) DO_FONT=0 ;;
    --force)   FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *)         err "Unknown option: $1"; usage; exit 1 ;;
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

case "$(uname -s)" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      err "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

IS_WSL=0
grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=1

# ── 0. Prerequisites (Linux only) ────────────────────────────
# macOS arrives with a compiler, zsh and a working locale. Linux does not,
# and Homebrew will not install without them. A desktop Linux box also needs
# a clipboard tool for Neovim and fontconfig for the Nerd Font — WSL gets
# both from Windows instead.
install_prereqs() {
  [[ "$PLATFORM" == "linux" ]] || return 0

  local desktop=()
  if [[ $IS_WSL -eq 0 ]]; then
    desktop=(fontconfig xclip wl-clipboard)
  fi

  info "Installing prerequisites (needs sudo)…"
  if command -v apt-get >/dev/null 2>&1; then
    run sudo apt-get update -qq
    run sudo apt-get install -y -qq \
      build-essential procps curl file git zsh unzip locales "${desktop[@]}"
  elif command -v dnf >/dev/null 2>&1; then
    run sudo dnf install -y -q \
      @development-tools procps-ng curl file git zsh unzip "${desktop[@]}"
  elif command -v pacman >/dev/null 2>&1; then
    run sudo pacman -S --needed --noconfirm \
      base-devel procps-ng curl file git zsh unzip "${desktop[@]}"
  else
    warn "No apt-get, dnf or pacman — install these yourself, then re-run:"
    warn "  a C toolchain, procps, curl, file, git, zsh, unzip ${desktop[*]}"
    return 0
  fi

  # zshrc exports LANG=en_US.UTF-8; on a stock Ubuntu image it is not generated.
  if command -v locale-gen >/dev/null 2>&1 \
     && ! locale -a 2>/dev/null | grep -qix 'en_US.utf8'; then
    info "Generating the en_US.UTF-8 locale…"
    run sudo locale-gen en_US.UTF-8
  fi
  ok "Prerequisites in place"
}

# ── 1. Homebrew ──────────────────────────────────────────────
install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew already installed ($(brew --version | head -1))"
  elif [[ $DRY_RUN -eq 1 ]]; then
    skip "would install Homebrew from brew.sh"
    return
  else
    info "Installing Homebrew…"
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

  # `brew cleanup` runs automatically after each install and will abort the
  # whole bundle if it trips over a stale cache entry or a missing lock file —
  # even though the formula itself poured fine. Turn it off for this run.
  export HOMEBREW_NO_INSTALL_CLEANUP=1
  export HOMEBREW_NO_ENV_HINTS=1

  # Homebrew occasionally loses its locks directory; recreate it if so.
  local locks_dir
  locks_dir="$(brew --prefix)/var/homebrew/locks"
  [[ -d "$locks_dir" ]] || run mkdir -p "$locks_dir"

  # `brew bundle` is built in since Homebrew 4.5.0; the old tap is deprecated.
  if brew tap 2>/dev/null | grep -qx 'homebrew/bundle'; then
    info "Removing the deprecated homebrew/bundle tap…"
    run brew untap homebrew/bundle
  fi

  local brewfile="$DOTFILES_DIR/Brewfile"
  if [[ $DO_FONT -eq 0 ]]; then
    brewfile="$(mktemp)"
    grep -v 'nerd-font' "$DOTFILES_DIR/Brewfile" > "$brewfile"
  fi

  if [[ "$PLATFORM" != "macos" ]] && grep -q '^cask' "$brewfile"; then
    local tmp; tmp="$(mktemp)"
    grep -v '^cask' "$brewfile" > "$tmp"
    brewfile="$tmp"
    skip "casks are macOS-only — the font is handled separately below"
  fi

  info "Installing packages from Brewfile…"
  run brew bundle --file="$brewfile"
  ok "Packages up to date"
}

# ── 3. Nerd Font ─────────────────────────────────────────────
# macOS gets it from the cask in the Brewfile. WSL renders in Windows
# Terminal, so the font has to be installed on the Windows side. That
# leaves desktop Linux, which has no cask and needs the release zip.
install_font() {
  if [[ $DO_FONT -eq 0 ]]; then
    skip "skipping the Nerd Font (--no-font) — powerline glyphs will be boxes"
    return 0
  fi

  if [[ "$PLATFORM" == "macos" ]]; then
    skip "font comes from the Brewfile cask"
    return 0
  fi

  if [[ $IS_WSL -eq 1 ]]; then
    info "Windows Terminal owns the font — see windows/README.md"
    return 0
  fi

  local dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  if compgen -G "$dir/*.ttf" >/dev/null 2>&1; then
    ok "JetBrainsMono Nerd Font already installed"
    return 0
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    skip "would download JetBrainsMono Nerd Font to $(tilde "$dir")"
    return 0
  fi

  local tmp url
  tmp="$(mktemp -d)"
  url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

  info "Downloading JetBrainsMono Nerd Font…"
  if curl -fsSL "$url" -o "$tmp/font.zip" \
     && mkdir -p "$dir" \
     && unzip -q -o "$tmp/font.zip" '*.ttf' -d "$dir"; then
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$dir" >/dev/null 2>&1
    ok "Nerd Font installed to $(tilde "$dir")"
  else
    warn "Font download failed — powerline glyphs will render as boxes"
  fi
  rm -rf "$tmp"
}

# ── 4. Symlinks ──────────────────────────────────────────────
link() {
  local src="$DOTFILES_DIR/$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    err "Missing source: $src"
    return 1
  fi

  # Already pointing where we want it
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    skip "current  $(tilde "$dest")"
    return 0
  fi

  run mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ $FORCE -eq 0 && $DRY_RUN -eq 0 && -t 0 ]]; then
      printf '%s  ?  %s exists. Back up and replace? [Y/n] %s' \
        "$C_YELLOW" "$(tilde "$dest")" "$C_RESET"
      read -r reply
      [[ "$reply" =~ ^[Nn]$ ]] && { skip "kept     $(tilde "$dest")"; return 0; }
    fi
    # Mirror the path under $HOME so same-named files (starship.toml and
    # bat/config, say) can't clobber each other inside the backup.
    local rel="${dest#"$HOME"/}"
    rel="${rel#/}"
    run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    run mv "$dest" "$BACKUP_DIR/$rel"
    warn "backed up $(tilde "$dest") → $(tilde "$BACKUP_DIR")/$rel"
  fi

  run ln -sfn "$src" "$dest"
  ok "linked   $(tilde "$dest")"
}

link_all() {
  # A single bad link should not abort the whole install.
  local entry failures=0
  for entry in "${LINKS[@]}"; do
    link "${entry%%:*}" "${entry#*:}" || failures=$((failures + 1))
  done
  [[ $failures -gt 0 ]] && err "$failures link(s) failed — see the messages above"
  return 0
}

# ── 5. Shell ─────────────────────────────────────────────────
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

# ── Post-install checks ──────────────────────────────────────
doctor() {
  local missing=() tool
  for tool in zsh starship nvim eza bat fd rg fzf zoxide git \
              uv ruff basedpyright lua-language-server stylua; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    ok "All expected tools are on PATH"
  else
    warn "Not found on PATH: ${missing[*]}"
    warn "Open a new terminal (Homebrew's PATH may not be loaded yet) and re-check."
  fi

  # Rust is deliberately not in the Brewfile — see the comment there. rustup
  # symlinks a `rust-analyzer` shim into ~/.cargo/bin whether or not the
  # component is installed, so `command -v` says yes and the binary then
  # fails with "Unknown binary". Ask the binary, not the PATH.
  if command -v rustup >/dev/null 2>&1; then
    if rust-analyzer --version >/dev/null 2>&1; then
      ok "rust-analyzer matches the active Rust toolchain"
    else
      warn "rust-analyzer missing — nvim will have no Rust LSP. Fix with:"
      warn "  rustup component add rust-analyzer"
    fi
  else
    info "No rustup — install from https://rustup.rs if you want Rust in nvim"
  fi

  # Neovim's clipboard = "unnamedplus" needs a provider on desktop Linux.
  # macOS has pbcopy built in; on WSL the terminal handles copy and paste.
  if [[ "$PLATFORM" == "linux" && $IS_WSL -eq 0 ]]; then
    if command -v wl-copy >/dev/null 2>&1 || command -v xclip >/dev/null 2>&1; then
      ok "Clipboard tool present — nvim's yanks reach the desktop"
    else
      warn "No wl-clipboard or xclip — nvim's clipboard won't leave the editor"
    fi
  fi

  # Fonts: a cask on macOS, a directory on Linux, and out of reach on WSL.
  local font_found=0 dir
  case "$PLATFORM" in
    macos)
      for dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
        [[ -d "$dir" ]] || continue
        if compgen -G "$dir/JetBrainsMono*Nerd*" >/dev/null; then font_found=1; break; fi
      done
      ;;
    linux)
      if [[ $IS_WSL -eq 1 ]]; then
        info "Nerd Font and colours are set in Windows Terminal — see windows/README.md"
        return 0
      fi
      fc-list 2>/dev/null | grep -qi 'jetbrainsmono.*nerd' && font_found=1
      ;;
  esac

  if [[ $font_found -eq 1 ]]; then
    ok "JetBrainsMono Nerd Font detected"
  else
    warn "JetBrainsMono Nerd Font not detected — powerline glyphs may render as boxes"
  fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
  printf '\n%s%sdotfiles%s %s· zsh · starship · nvim · gruvbox%s\n' \
    "$C_BOLD" "$C_ORANGE" "$C_RESET" "$C_DIM" "$C_RESET"
  [[ $DRY_RUN -eq 1 ]] && warn "DRY RUN — nothing will be modified"
  info "Platform: $PLATFORM$([[ $IS_WSL -eq 1 ]] && printf ' (WSL)')"
  info "Dotfiles: $DOTFILES_DIR"

  if [[ $DO_BREW -eq 1 ]]; then
    header "1/6  Prerequisites"
    install_prereqs
    header "2/6  Homebrew"
    install_homebrew
    header "3/6  Packages"
    install_packages
  else
    warn "Skipping prerequisites, Homebrew and packages (--no-brew)"
  fi

  header "4/6  Nerd Font"
  install_font

  header "5/6  Symlinks"
  link_all

  header "6/6  Default shell"
  set_default_shell

  header "Doctor"
  doctor

  printf '\n%s%s  Done.%s\n' "$C_BOLD" "$C_GREEN" "$C_RESET"

  # Step 1 is the only thing that differs between the three platforms.
  local first_step
  if [[ $IS_WSL -eq 1 ]]; then
    first_step="Apply the Windows Terminal half once — see windows/README.md
       (JetBrainsMono Nerd Font + the Gruvbox scheme and keybinds)"
  elif [[ "$PLATFORM" == "macos" ]]; then
    first_step="Quit and reopen Ghostty (or press ⌘⇧, to reload its config)"
  else
    first_step="Restart Ghostty, or point your terminal at JetBrainsMono
       Nerd Font if you use a different one"
  fi

  cat <<EOF

  ${C_AQUA}Next steps${C_RESET}
    1. $first_step
    2. Open a new terminal — the powerline prompt should appear
    3. Run nvim — the first launch bootstraps lazy.nvim and installs
       its plugins, then you're done

  ${C_DIM}Backups (if any): $(tilde "$BACKUP_DIR")${C_RESET}
  ${C_DIM}Machine-specific overrides go in ~/.zshrc.local (git-ignored)${C_RESET}

EOF
}

main "$@"
