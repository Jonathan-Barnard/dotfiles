# dotfiles

Ghostty · zsh · Starship · Neovim — one Gruvbox Dark Hard palette across the whole terminal, powerline everywhere.

```
┌──────────────────────────────────────────────────────────┐
│  Ghostty        gruvbox palette, JetBrainsMono Nerd Font │
│  zsh            history, completion, syntax highlighting │
│  Starship       two-line powerline prompt                │
│  Neovim         lazy.nvim, neo-tree, statusline, gruvbox │
│  eza bat fd rg fzf zoxide   themed to match              │
└──────────────────────────────────────────────────────────┘
```

## Install

```sh
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Preview first if you'd rather: `./install.sh --dry-run`

The installer is idempotent — run it whenever you pull changes.

| Flag | Effect |
| --- | --- |
| `--dry-run` | Print every action, change nothing |
| `--no-brew` | Skip Homebrew and package installation |
| `--no-font` | Skip the JetBrainsMono Nerd Font cask |
| `--force` | Replace existing files without prompting |

## Where things go

Everything is symlinked, so editing the installed path edits the repo.

| Repo | Installed to |
| --- | --- |
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` |
| `zsh/functions.zsh` | `~/.config/zsh/functions.zsh` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `bat/config` | `~/.config/bat/config` |
| `nvim/` | `~/.config/nvim` |

Anything already at one of those paths is moved to `~/.dotfiles-backup/<timestamp>/` first, keeping its position under `$HOME` — so `ghostty/config` and `bat/config` land in separate subdirectories rather than overwriting each other.

`~/.zshrc.local` is sourced last and is git-ignored. Machine-specific `PATH` entries and work tokens belong there, not in `zsh/zshrc`.

### What `install.sh` does

1. Installs Homebrew if it's missing
2. `brew bundle` from the `Brewfile` — Starship, zsh plugins, CLI tools, Nerd Font
3. Symlinks the table above, backing up anything already there
4. Sets zsh as the login shell

Then a doctor report flags any expected tool missing from `PATH`, and whether the Nerd Font is installed.

Commit and push with `dotpush "message"`.

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
| `Ctrl+X Ctrl+E` | Edit current command line in `$EDITOR` |

Handy functions: `mkcd`, `extract`, `ff` (fuzzy open in editor), `fkill`, `gcob` (fuzzy branch checkout), `up 3`, `dotpush`.

### Neovim

Leader is `Space`.

| Keys | Action |
| --- | --- |
| `<leader>w` / `<leader>q` / `<leader>Q` | Write / quit / quit all |
| `<leader>e` | File tree (neo-tree) — `<` / `>` switch files / buffers / git |
| `<leader>l` | `:Lazy` — plugin manager |
| `Ctrl+H/J/K/L` | Move between splits |
| `<leader>sv` / `<leader>sh` | Split right / down |
| `<leader>sc` / `<leader>s=` | Close split / equalise |
| `⌥` arrows | Resize split — macOS keeps `Ctrl`+arrows for Mission Control |
| `⇧H` / `⇧L` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>tt` / `<leader>tv` / `<leader>tT` | Terminal in a bottom split / right split / new tab |
| `<leader>tm` | Move the current window to its own tab |
| `Esc Esc` | Leave terminal mode |
| `gt` / `gT` | Next / previous tab |
| `J` / `K` (visual) | Move the selection up/down |
| `Esc` | Clear search highlight |

Splits and their bindings deliberately mirror Ghostty's, so `⌘D` outside nvim and `<leader>sv` inside it do the same thing.

Terminals are built-in `:terminal` rather than a plugin — every press opens a *new* shell, so when one turns out to be long-running, `<leader>tm` promotes it to its own tab and it stays there. A clean `exit` closes the split itself; a non-zero exit is left on screen. Ctrl+L, Ctrl+J, Ctrl+K and Alt+arrows are deliberately unmapped in terminal mode so they still belong to zsh — press `Esc Esc` first.

## The palette

Gruvbox Dark Hard, used identically by Ghostty, Starship, fzf, bat and zsh syntax highlighting.

| | hex | | hex |
| --- | --- | --- | --- |
| bg | `#1d2021` | fg | `#ebdbb2` |
| red | `#fb4934` | green | `#b8bb26` |
| yellow | `#fabd2f` | blue | `#83a598` |
| purple | `#d3869b` | aqua | `#8ec07c` |
| orange | `#fe8019` | grey | `#928374` |

## Customising

- **Machine-specific shell config** — `~/.zshrc.local`, sourced last, git-ignored
- **Transparency** — `ghostty/config`, `background-opacity`
- **Editor** — `EDITOR`/`VISUAL` in `zsh/zshrc`, `nvim` when it's installed, `vim` otherwise
- **Adding a config** — drop the file in the repo and add one `src:dest` line to the `LINKS` array at the top of `install.sh`
- **Adding a Neovim plugin** — create `nvim/lua/plugins/<name>.lua` returning a lazy.nvim spec table. It's picked up automatically by the `{ import = "plugins" }` spec; no other file needs editing. `nvim/lazy-lock.json` pins the versions and is committed.

### What's in the Neovim config

Deliberately small — options, keymaps, a colourscheme, a statusline, a file tree, terminals and key hints, with lazy.nvim ready for whatever comes next. No LSP, treesitter or fuzzy finder yet.

No icon provider is installed, so every file in the tree shares one glyph — add `nvim-web-devicons` or `mini.icons` and per-filetype icons appear with no further config. netrw is disabled; neo-tree handles `nvim .` too.

```
nvim/
├── init.lua
├── lua/config/{options,keymaps,autocmds,lazy}.lua
└── lua/plugins/{colorscheme,lualine,neo-tree,which-key}.lua
```

The lualine theme is written from `starship.toml`'s palette rather than lualine's bundled gruvbox — same separator glyphs, same colours, so the prompt and the statusline read as one thing.

## Requirements

- macOS or Linux
- Neovim ≥ 0.11 (`vim.hl.on_yank`, `vim.o.winborder`) — the Brewfile installs it
- A terminal using JetBrainsMono Nerd Font — Ghostty is configured for it, but set it in any other terminal you use or the powerline separators will show as boxes
