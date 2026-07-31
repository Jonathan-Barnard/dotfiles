#!/usr/bin/env bash
#
# ── dotfiles ────────────────────────────────────────────────────────────────
#   1. runs the bootstrap scripts (packages, neovim, plugins, default shell)
#   2. links every config in this repo into place
#
#   Usage:   ./install.sh
#            ./install.sh --dry-run     show what would happen, change nothing
#            ./install.sh --link-only   skip the bootstrap, just fix symlinks
#
#   First run on a fresh machine: the bootstrap scripts write their configs,
#   and anything this repo does not already have is moved in here and linked
#   back. So the repo ends up holding the real files without you copying
#   anything by hand.
#
#   Every run after that: the repo wins. Whatever is committed here replaces
#   what the bootstrap scripts just wrote.
# ───────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/link-$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
LINK_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --link-only) LINK_ONLY=1 ;;
    -h|--help)   sed -n '2,20p' "$0" | sed 's/^#//'; exit 0 ;;
    *)           echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

if [[ -t 1 ]]; then
  B=$'\033[1m'; GRN=$'\033[38;5;114m'; BLU=$'\033[38;5;111m'
  YLW=$'\033[38;5;222m'; DIM=$'\033[2m'; R=$'\033[0m'
else
  B=""; GRN=""; BLU=""; YLW=""; DIM=""; R=""
fi
step() { printf '\n%s%s▸ %s%s\n' "$B" "$BLU" "$1" "$R"; }
ok()   { printf '  %s✓%s %s\n' "$GRN" "$R" "$1"; }
warn() { printf '  %s!%s %s\n' "$YLW" "$R" "$1"; }
run()  { if (( DRY_RUN )); then printf '  %swould: %s%s\n' "$DIM" "$*" "$R"; else "$@"; fi; }

# repo path │ where it belongs
LINKS=(
  "zsh/zshrc|$HOME/.zshrc"
  "zsh/aliases.zsh|$HOME/.config/zsh/aliases.zsh"
  "zsh/fzf.zsh|$HOME/.config/zsh/fzf.zsh"
  "starship/starship.toml|$HOME/.config/starship.toml"
  "bat/config|$HOME/.config/bat/config"
  "eza/theme.yml|$HOME/.config/eza/theme.yml"
  "bin/fzf-preview|$HOME/.local/bin/fzf-preview"
  "nvim|$HOME/.config/nvim"
)

(( DRY_RUN )) && printf '\n%s-- dry run: nothing will be changed --%s\n' "$YLW" "$R"

# ── 1. bootstrap ───────────────────────────────────────────────────────────
if (( LINK_ONLY )); then
  step "Skipping bootstrap (--link-only)"
else
  step "Running bootstrap scripts"
  for s in setup-terminal.sh setup-neovim.sh; do
    if [[ -f "$REPO/bootstrap/$s" ]]; then
      printf '  %s→ %s%s\n' "$DIM" "$s" "$R"
      run bash "$REPO/bootstrap/$s"
    else
      warn "bootstrap/$s not found — skipping"
    fi
  done
fi

# ── 2. link ────────────────────────────────────────────────────────────────
step "Linking configs"
for entry in "${LINKS[@]}"; do
  src="$REPO/${entry%%|*}"
  dst="${entry#*|}"
  name="${entry%%|*}"

  # already pointing at the right place — nothing to do
  if [[ -L "$dst" && "$(readlink -f "$dst" 2>/dev/null)" == "$(readlink -f "$src" 2>/dev/null)" ]]; then
    ok "$name ${DIM}(already linked)${R}"
    continue
  fi

  if [[ ! -e "$src" ]]; then
    # First run: the repo does not have this file yet, so adopt whatever the
    # bootstrap just wrote rather than losing it.
    if [[ -e "$dst" ]]; then
      run mkdir -p "$(dirname "$src")"
      run mv "$dst" "$src"
      ok "$name ${DIM}(adopted into the repo)${R}"
    else
      warn "$name — nothing in the repo and nothing at $dst, skipping"
      continue
    fi
  elif [[ -e "$dst" || -L "$dst" ]]; then
    # The repo already has this file, so the repo wins. Keep a copy of what we
    # are about to replace, in case the bootstrap wrote something you wanted.
    run mkdir -p "$BACKUP/$(dirname "$name")"
    run mv "$dst" "$BACKUP/$name"
    ok "$name ${DIM}(replaced, old copy backed up)${R}"
  else
    ok "$name"
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -sfn "$src" "$dst"
done

# ── done ───────────────────────────────────────────────────────────────────
if (( DRY_RUN )); then
  printf '\n%sDry run complete — rerun without --dry-run to apply.%s\n\n' "$B" "$R"
  exit 0
fi

printf '\n%s%s Done.%s  Start a new shell with: %sexec zsh%s\n' "$B" "$GRN" "$R" "$B" "$R"
[[ -d "$BACKUP" ]] && printf ' Replaced files kept in: %s%s%s\n' "$B" "${BACKUP/#$HOME/\~}" "$R"
if [[ -f "$HOME/.config/nvim/lazy-lock.json" && ! -L "$HOME/.config/nvim/lazy-lock.json" ]]; then
  printf ' %sTip: commit nvim/lazy-lock.json to pin your plugin versions.%s\n' "$DIM" "$R"
fi
echo
