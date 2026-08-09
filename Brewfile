# ─────────────────────────────────────────────────────────────
#  Brewfile — `brew bundle --file=Brewfile`
#
#  No `tap "homebrew/bundle"` here: `brew bundle` became a built-in
#  command in Homebrew 4.5.0 and that tap is now a deprecated empty
#  archive. If you tapped it previously: brew untap homebrew/bundle
# ─────────────────────────────────────────────────────────────

# ── Core ─────────────────────────────────────────────────────
brew "starship"
brew "git"
brew "neovim"

# ── Zsh plugins ──────────────────────────────────────────────
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-completions"

# ── Modern CLI core ──────────────────────────────────────────
brew "eza"        # ls
brew "bat"        # cat
brew "fd"         # find
brew "ripgrep"    # grep
brew "fzf"        # fuzzy finder
brew "zoxide"     # smarter cd

# ── Language servers & tooling ───────────────────────────────
#  Neovim's LSP setup expects these on PATH — no Mason, no second
#  package manager, and the same binaries the shell and CI use.
#
#  Rust is the exception and stays out of here. rust-analyzer has to
#  match the toolchain that built the crate, or you get proc-macro
#  expansion failures and trait errors that aren't real; rustup's
#  component always matches:  rustup component add rust-analyzer
#  rustup itself comes from rustup.rs — `brew "rustup"` would install
#  a second, competing copy alongside ~/.cargo/bin.
brew "uv"                   # Python envs + packages — `brew upgrade uv`,
                            # not `uv self update`, which brew disables
brew "ruff"                 # Python lint & format — LSP and CLI
brew "basedpyright"         # Python types, hover, goto
brew "lua-language-server"
brew "stylua"               # Lua formatter

# ── Font (powerline / nerd glyphs) ───────────────────────────
cask "font-jetbrains-mono-nerd-font"
