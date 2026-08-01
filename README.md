# dotfiles

Ghostty · zsh · Starship · Neovim — one Gruvbox Dark Hard palette across the whole stack, powerline everywhere.

```
┌─ terminal ──────────────────────────────────────────────┐
│  Ghostty        gruvbox palette, JetBrainsMono Nerd Font │
│  zsh            history, completion, syntax highlighting │
│  Starship       two-line powerline prompt                │
│  eza bat fd rg fzf zoxide   themed to match              │
└─ editor ────────────────────────────────────────────────┘
│  Neovim         lazy.nvim, gruvbox.nvim, LSP, treesitter │
│  lualine        powerline statusline                     │
│  bufferline     slanted powerline tabs                   │
└──────────────────────────────────────────────────────────┘
```

## Install

```sh
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Preview first if you'd rather:

```sh
./install.sh --dry-run
```

The installer is idempotent — run it whenever you pull changes. Anything it replaces is moved to `~/.dotfiles-backup/<timestamp>/` first.

### Flags

| Flag | Effect |
| --- | --- |
| `--dry-run` | Print every action, change nothing |
| `--no-brew` | Skip Homebrew and package installation |
| `--no-font` | Skip the JetBrainsMono Nerd Font cask |
| `--no-nvim-sync` | Skip the headless Neovim plugin sync |
| `--force` | Replace existing files without prompting |

### What it does

1. Installs Homebrew if missing
2. `brew bundle` from the `Brewfile` (Neovim, Starship, zsh plugins, CLI tools, Nerd Font)
3. Symlinks configs into place, backing up anything already there
4. Sets zsh as the login shell
5. Runs `nvim --headless "+Lazy! sync"` to install plugins
6. Prints a doctor report of anything missing from `PATH`

## Layout

```
.
├── install.sh              # the installer
├── Brewfile                # every package, one place
├── ghostty/config          → ~/.config/ghostty/config
├── starship/starship.toml  → ~/.config/starship.toml
├── zsh/
│   ├── zshrc               → ~/.zshrc
│   ├── aliases.zsh         → ~/.config/zsh/aliases.zsh
│   └── functions.zsh       → ~/.config/zsh/functions.zsh
├── bat/config              → ~/.config/bat/config
└── nvim/                   → ~/.config/nvim
    ├── init.lua
    └── lua/
        ├── config/         # options, keymaps, autocmds, lazy bootstrap
        └── plugins/        # one file per concern
```

Everything is symlinked, so editing `~/.config/nvim/init.lua` edits the repo. Commit and push with `dotpush "message"`.

## The palette

Gruvbox Dark Hard, used identically by Ghostty, Starship, fzf, bat, zsh syntax highlighting and Neovim.

| | hex | | hex |
| --- | --- | --- | --- |
| bg | `#1d2021` | fg | `#ebdbb2` |
| red | `#fb4934` | green | `#b8bb26` |
| yellow | `#fabd2f` | blue | `#83a598` |
| purple | `#d3869b` | aqua | `#8ec07c` |
| orange | `#fe8019` | grey | `#928374` |

## Keybindings

### Ghostty

| Keys | Action |
| --- | --- |
| `⌘D` / `⌘⇧D` | Split right / down |
| `⌘⌥` arrows | Move between splits |
| `⌘T` | New tab |
| `⌘⇧` ←/→ | Previous / next tab |
| `⌘K` | Clear screen |
| `⌘⇧,` | Reload config |

### zsh

| Keys | Action |
| --- | --- |
| `↑` / `↓` | Prefix-aware history search |
| `Ctrl+Space` | Accept autosuggestion |
| `Ctrl+R` | fzf history search |
| `Ctrl+T` | fzf file picker (with `bat` preview) |
| `Alt+C` | fzf directory jump |
| `Ctrl+X Ctrl+E` | Edit current command line in Neovim |

Handy functions: `mkcd`, `extract`, `ff` (fuzzy open in editor), `fkill`, `gcob` (fuzzy branch checkout), `up 3`, `dotpush`.

### Neovim

Leader is `<Space>`.

| Keys | Action |
| --- | --- |
| `<leader><space>` | Find files |
| `<leader>sg` | Live grep |
| `<leader>e` | File explorer |
| `<leader>/` | Fuzzy search in buffer |
| `Shift+H` / `Shift+L` | Previous / next buffer |
| `gd` `gr` `gI` `gy` | LSP definitions / references / implementations / types |
| `K` | Hover docs |
| `<leader>ca` / `<leader>cr` | Code action / rename |
| `<leader>cf` | Format buffer |
| `<leader>xx` | Diagnostics list (Trouble) |
| `]h` / `[h` | Next / previous git hunk |
| `<leader>gg` | Lazygit (if installed) |
| `Ctrl+\` | Floating terminal |
| `jk` | Escape from insert mode |
| `Alt+J` / `Alt+K` | Move line or selection |

Press `<Space>` and wait to see everything — which-key lists it.

## Customising

- **Machine-specific shell config** — `~/.zshrc.local` is sourced last and is git-ignored. Put work tokens and one-off `PATH` entries there.
- **Contrast** — `nvim/lua/plugins/colorscheme.lua`, change `contrast = "hard"` to `"soft"` or `""`.
- **Transparency** — `ghostty/config`, `background-opacity`.
- **Format on save** — on by default via conform.nvim. `:FormatToggle` globally, `:FormatToggle!` for the current buffer.
- **More LSP servers** — add to `ensure_installed` in `nvim/lua/plugins/lsp.lua`, or `:Mason` and install interactively.

## Requirements

- macOS or Linux
- Neovim ≥ 0.11 (the Brewfile installs it)
- A terminal using JetBrainsMono Nerd Font — Ghostty is configured for it, but set it in any other terminal you use or the powerline separators will show as boxes

## Uninstall

```sh
rm ~/.zshrc ~/.config/starship.toml ~/.config/ghostty/config ~/.config/bat/config
rm -rf ~/.config/nvim ~/.config/zsh
cp -r ~/.dotfiles-backup/<timestamp>/. ~/    # restore what was there before
```
