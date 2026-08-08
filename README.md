# dotfiles · WSL

Windows Terminal · zsh · Starship · Neovim — one Gruvbox Dark Hard palette across the whole terminal, powerline everywhere.

This is the WSL Ubuntu half of a pair. It mirrors the macOS repo file for file: `nvim/`, `Brewfile`, `bat/config`, `starship/starship.toml`, `zsh/aliases.zsh` and `zsh/functions.zsh` are byte-identical, and `zsh/zshrc` differs only by the line that sources `zsh/wsl.zsh`. Everything that cannot be identical lives in that one file plus `windows/`.

```
┌──────────────────────────────────────────────────────────┐
│  Windows Terminal  gruvbox palette, JetBrainsMono NF     │
│  zsh               history, completion, syntax highlight │
│  Starship          two-line powerline prompt             │
│  Neovim            lazy.nvim, neo-tree, statusline       │
│  eza bat fd rg fzf zoxide   themed to match              │
└──────────────────────────────────────────────────────────┘
```

## Install

Inside WSL:

```sh
git clone git@github.com:Jonathan-Barnard/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Preview first if you'd rather: `./install.sh --dry-run`

Clone to `~/.dotfiles`, the same path as on macOS — `$DOTFILES` and the `dot` / `zshconf` / `nvimconf` aliases assume it.

The installer is idempotent — run it whenever you pull changes. Then do the [Windows half](windows/README.md) once: the Nerd Font and the terminal colours live outside WSL, where this script cannot reach them.

| Flag | Effect |
| --- | --- |
| `--dry-run` | Print every action, change nothing |
| `--no-brew` | Skip prerequisites, Homebrew and package installation |
| `--no-font` | Skip the Nerd Font cask (macOS only; a no-op here) |
| `--force` | Replace existing files without prompting |

### Why Homebrew and not apt

Ubuntu ships eza not at all, and zoxide, starship, fzf, bat and Neovim old enough to matter — which is how the previous version of this repo ended up with a GPG keyring for a third-party apt repo, two `curl | sh` installers, a Neovim tarball unpacked into `/opt`, and `batcat`/`fdfind` aliases to paper over Debian's renames.

Homebrew on Linux has a bottle for every one of them, at the same relative paths as on macOS. That is what lets `zshrc` source its zsh plugins from `$(brew --prefix)/share/…` on both machines with no branch, and lets this `install.sh` be the macOS one with a prerequisites step bolted on.

## Where things go

Everything is symlinked, so editing the installed path edits the repo.

| Repo | Installed to |
| --- | --- |
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` |
| `zsh/functions.zsh` | `~/.config/zsh/functions.zsh` |
| `zsh/wsl.zsh` | `~/.config/zsh/wsl.zsh` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `bat/config` | `~/.config/bat/config` |
| `nvim/` | `~/.config/nvim` |

Anything already at one of those paths is moved to `~/.dotfiles-backup/<timestamp>/` first, keeping its position under `$HOME` — so `starship.toml` and `bat/config` land in separate subdirectories rather than overwriting each other.

`~/.zshrc.local` is sourced last and is git-ignored. Machine-specific `PATH` entries and work tokens belong there, not in `zsh/zshrc`.

`windows/settings.json` is **not** linked. Windows Terminal rewrites its own settings file and its profile GUIDs are machine-specific, so it's applied by hand — see [windows/README.md](windows/README.md).

### What `install.sh` does

1. `apt-get` the handful of packages Homebrew itself needs, plus `zsh`, and generates the `en_US.UTF-8` locale
2. Installs Homebrew if it's missing
3. `brew bundle` from the `Brewfile` — Starship, zsh plugins, CLI tools
4. Symlinks the table above, backing up anything already there
5. Sets zsh as the login shell

Then a doctor report flags any expected tool missing from `PATH`.

Commit and push with `dotpush "message"`.

## The WSL-specific part

There is only one, by design: **`zsh/wsl.zsh`**, sourced after `aliases.zsh` so it can override it. It swaps the two BSD-only aliases (`free`, `ports`) for their Linux equivalents, retargets `ghosttyconf` to `wtconf`, and adds the Windows interop: `open` → Explorer, `pbcopy` / `pbpaste`, `winhome`.

`nvim/` needs no WSL branch at all — see the clipboard note below.

### Clipboard

Neovim keeps `clipboard = "unnamedplus"`, byte-identical to macOS, with no provider wired up behind it. Yanks stay inside Neovim; nothing shells out, so nothing is slow.

Getting text in and out is the terminal's job instead: `copyOnSelect` is on, so selecting with the mouse copies, `Ctrl+Shift+C` copies, and `Ctrl+V` pastes. At the shell, `pbcopy` and `pbpaste` from `wsl.zsh` work as they do on macOS.

If you later want `"+y` inside Neovim to reach Windows, the usual fix is `win32yank` on `PATH` — Neovim detects it on its own, with no config change here.

## Keybindings

### Windows Terminal

Ghostty's `⌘` becomes `Ctrl+Shift` here. The full table, and how to apply it, is in [windows/README.md](windows/README.md).

| Keys | Action |
| --- | --- |
| `Ctrl+Shift+D` / `Ctrl+Shift+S` | Split right / down |
| `Ctrl+Alt` arrows | Move between splits |
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift` ←/→ | Previous / next tab |
| `Ctrl+Shift+,` | Open settings |

### zsh

| Keys | Action |
| --- | --- |
| `↑` / `↓` | Prefix-aware history search |
| `Ctrl+Space` | Accept autosuggestion |
| `Ctrl+R` | fzf history search |
| `Ctrl+T` | fzf file picker (with `bat` preview) |
| `Alt+C` | fzf directory jump |
| `Ctrl+X Ctrl+E` | Edit current command line in `$EDITOR` |

Handy functions: `mkcd`, `extract`, `ff` (fuzzy open in editor), `fkill`, `gcob` (fuzzy branch checkout), `up 3`, `dotpush`. Plus `winhome` and `open` from `wsl.zsh`.

### Neovim

Leader is `Space`. The modifier tells you what you're moving between — `Ctrl` windows, `Tab` tab pages, `⇧` buffers, `Alt` resizes — and `<leader>` is for commands rather than movement. `Ctrl+D`/`Ctrl+U` are the deliberate exception: they scroll, because that's what they do in every other Vim.

| Keys | Action |
| --- | --- |
| `<leader>w` / `<leader>q` / `<leader>Q` | Write / quit / quit all |
| `<leader>e` | File tree (neo-tree) — `<` / `>` switch files / buffers / git |
| `<leader>l` | `:Lazy` — plugin manager |
| `Ctrl+H/J/K/L` | Move between splits |
| `<leader>sv` / `<leader>sh` | Split right / down |
| `<leader>sc` / `<leader>s=` | Close split / equalise |
| `Alt` arrows | Resize split |
| `⇧H` / `⇧L` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `Tab` `h` / `Tab` `l` | Previous / next tab |
| `Tab` `n` / `Tab` `q` / `Tab` `o` | New tab / close it / close the others |
| `Tab` `1`…`9` | Jump to that tab |
| `Tab` `⇧H` / `Tab` `⇧L` | Move the tab left / right along the bar |
| `Tab` `m` | Move the current window to its own tab |
| `<leader>tt` / `<leader>tv` / `<leader>tT` | Terminal in a bottom split / right split / new tab |
| `Esc Esc` | Leave terminal mode |
| `J` / `K` (visual) | Move the selection up/down |
| `Esc` | Clear search highlight |

Splits and their bindings deliberately mirror the terminal's, so `Ctrl+Shift+D` outside nvim and `<leader>sv` inside it do the same thing.

> **The one thing that doesn't survive the port.** `Tab` is a prefix, never a key on its own — it shares a byte with `Ctrl+I` in a legacy terminal. On macOS, Ghostty speaks the kitty keyboard protocol and nvim reads it, so the two stay distinct. **Windows Terminal does not implement it**, so here `Tab` arrives as `Ctrl+I` and the whole `Tab` family collides with jumplist-forward. The keymaps are left identical to macOS rather than forked; `gt` / `gT` still work in the meantime.

Terminals are built-in `:terminal` rather than a plugin — every press opens a *new* shell, so when one turns out to be long-running, `Tab` `m` promotes it to its own tab and it stays there. A clean `exit` closes the split itself; a non-zero exit is left on screen. Ctrl+L, Ctrl+J, Ctrl+K and Alt+arrows are deliberately unmapped in terminal mode so they still belong to zsh — press `Esc Esc` first.

## The palette

Gruvbox Dark Hard, used identically by Windows Terminal, Starship, fzf, bat and zsh syntax highlighting.

| | hex | | hex |
| --- | --- | --- | --- |
| bg | `#1d2021` | fg | `#ebdbb2` |
| red | `#fb4934` | green | `#b8bb26` |
| yellow | `#fabd2f` | blue | `#83a598` |
| purple | `#d3869b` | aqua | `#8ec07c` |
| orange | `#fe8019` | grey | `#928374` |

## Customising

- **Machine-specific shell config** — `~/.zshrc.local`, sourced last, git-ignored
- **Anything WSL- or Linux-only** — `zsh/wsl.zsh`, so the other files stay identical to macOS
- **Transparency** — `windows/settings.json`, `opacity`
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

## Starting over

If this machine ran the previous version of this repo, it still has that Neovim on disk — 21 plugins plus mason's 13 language servers, none of which the current config uses.

```sh
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim
cd ~/.dotfiles && ./install.sh
```

## Requirements

- WSL 2 with Ubuntu (or any Debian-based distro)
- Windows Terminal, with the [Windows half](windows/README.md) applied once
- Neovim ≥ 0.11 (`vim.hl.on_yank`, `vim.o.winborder`) — the Brewfile installs it
- JetBrainsMono Nerd Font, installed on the Windows side, or the powerline separators show as boxes
