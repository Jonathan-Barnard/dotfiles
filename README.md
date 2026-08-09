# dotfiles

Ghostty · zsh · Starship · Neovim — one Gruvbox Dark Hard palette across the whole terminal, powerline everywhere.

**One repo, three platforms: macOS, Linux and WSL.** The same `install.sh`, the same `Brewfile`, the same Neovim. Everything that genuinely has to differ lives in exactly two places — `zsh/os.zsh` and `windows/`.

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
git clone git@github.com:Jonathan-Barnard/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Clone to `~/.dotfiles` on every machine — `$DOTFILES` and the `dot` / `zshconf` / `nvimconf` aliases assume that path.

Preview first if you'd rather: `./install.sh --dry-run`. The installer is idempotent — run it whenever you pull changes.

| Flag | Effect |
| --- | --- |
| `--dry-run` | Print every action, change nothing |
| `--no-brew` | Skip prerequisites, Homebrew and package installation |
| `--no-font` | Skip the JetBrainsMono Nerd Font |
| `--force` | Replace existing files without prompting |

### What differs per platform

Everything below is handled by the installer; nothing needs a flag.

| | macOS | Linux | WSL |
| --- | --- | --- | --- |
| Prerequisites | none needed | apt / dnf / pacman | apt / dnf / pacman |
| Packages | Homebrew | Homebrew | Homebrew |
| Nerd Font | Brewfile cask | downloaded to `~/.local/share/fonts` | **you install it in Windows** |
| Terminal | Ghostty | Ghostty | Windows Terminal, [set up by hand](windows/README.md) |
| nvim clipboard | built in | `wl-clipboard` or `xclip` | terminal copy/paste |

On WSL there is one manual step, once: the font and colours belong to Windows Terminal, which lives outside WSL where the installer cannot reach. See [windows/README.md](windows/README.md).

### Why Homebrew everywhere

Ubuntu ships eza not at all, and zoxide, starship, fzf, bat and Neovim old enough to matter. Homebrew has a bottle for every one of them, at the same relative paths as on macOS — which is what lets `zsh/zshrc` source its plugins from `$(brew --prefix)/share/…` on all three platforms with no branch at all.

The native package manager is used only for what Homebrew itself needs to exist (a compiler, `curl`, `file`, `git`), plus `zsh`, a clipboard tool and `fontconfig`.

## Where things go

Everything is symlinked, so editing the installed path edits the repo.

| Repo | Installed to |
| --- | --- |
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` |
| `zsh/functions.zsh` | `~/.config/zsh/functions.zsh` |
| `zsh/os.zsh` | `~/.config/zsh/os.zsh` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `bat/config` | `~/.config/bat/config` |
| `nvim/` | `~/.config/nvim` |

Every path is linked on every platform — a Ghostty config on a machine without Ghostty is just an unread file, and that's cheaper than a conditional.

Anything already at one of those paths is moved to `~/.dotfiles-backup/<timestamp>/` first, keeping its position under `$HOME` — so `ghostty/config` and `bat/config` land in separate subdirectories rather than overwriting each other.

`~/.zshrc.local` is sourced last and is git-ignored. Machine-specific `PATH` entries and work tokens belong there, not in `zsh/zshrc`.

`windows/settings.json` is **not** linked — Windows Terminal rewrites its own settings file and its profile GUIDs are machine-specific.

### What `install.sh` does

1. On Linux, installs Homebrew's own prerequisites plus `zsh`, a clipboard tool and the `en_US.UTF-8` locale
2. Installs Homebrew if it's missing
3. `brew bundle` from the `Brewfile` — Starship, zsh plugins, CLI tools
4. Installs the Nerd Font, by whichever route this platform needs
5. Symlinks the table above, backing up anything already there
6. Sets zsh as the login shell

Then a doctor report flags any expected tool missing from `PATH`, whether the font is installed, and on Linux whether a clipboard tool is present.

Commit and push with `dotpush "message"`.

## The one platform file

**`zsh/os.zsh`** is sourced after `aliases.zsh`, so it can override it. It sets `$DOTFILES_OS` (`macos` / `linux`) and `$DOTFILES_WSL`, then hands out:

| | |
| --- | --- |
| macOS | `free` via `top -l 1`, `ports` via `lsof` |
| Linux | `free -h`, `ports` via `ss` |
| Linux desktop | `open` → `xdg-open`, `pbcopy`/`pbpaste` → `wl-copy` or `xclip` |
| WSL | `open` → Explorer, `pbcopy`/`pbpaste` → `clip.exe`/PowerShell, `winhome`, `wtconf` |

`aliases.zsh` and `functions.zsh` hold nothing platform-specific, so there is only ever one file to look in.

### Clipboard

Neovim sets `clipboard = "unnamedplus"` everywhere. macOS has `pbcopy` built in; desktop Linux gets `wl-clipboard` or `xclip` from the prerequisites step.

WSL deliberately has no provider — routing paste through `powershell.exe Get-Clipboard` costs ~200 ms, which you'd pay on every put. Copy in and out with the terminal instead: `copyOnSelect` is on, `Ctrl+Shift+C` copies, `Ctrl+V` pastes. If you later want `"+y` to reach Windows, put `win32yank` on `PATH` and Neovim will find it on its own.

## Keybindings

### Ghostty (macOS, Linux)

| Keys | Action |
| --- | --- |
| `⌘D` / `⌘⇧D` | Split right / down |
| `⌘⌥` arrows | Move between splits |
| `⌘T` | New tab |
| `⌘⇧` ←/→ | Previous / next tab |
| `⌘K` | Clear screen |
| `⌘⇧,` | Reload config |

On Linux, Ghostty uses `Ctrl` where macOS uses `⌘`. Windows Terminal's equivalents are in [windows/README.md](windows/README.md).

### zsh

| Keys | Action |
| --- | --- |
| `↑` / `↓` | Prefix-aware history search |
| `Ctrl+Space` | Accept autosuggestion |
| `Ctrl+R` | fzf history search |
| `Ctrl+T` | fzf file picker (with `bat` preview) |
| `Alt+C` | fzf directory jump |
| `Ctrl+X Ctrl+E` | Edit current command line in `$EDITOR` |

Handy functions: `mkcd`, `extract`, `ff` (fuzzy open in editor), `fkill`, `gcob` (fuzzy branch checkout), `up 3`, `dotpush`. Plus `open` everywhere, and `winhome` on WSL.

### Neovim

Leader is `Space`. The modifier tells you what you're moving between — `Ctrl` windows, `Tab` tab pages, `⇧` buffers, `⌥`/`Alt` resizes — and `<leader>` is for commands rather than movement. `Ctrl+D`/`Ctrl+U` are the deliberate exception: they scroll, because that's what they do in every other Vim.

| Keys | Action |
| --- | --- |
| `<leader>w` / `<leader>q` / `<leader>Q` | Write / quit / quit all |
| `<leader>e` | File tree (neo-tree) — `<` / `>` switch files / buffers / git |
| `<leader>l` | `:Lazy` — plugin manager |
| `Ctrl+H/J/K/L` | Move between splits |
| `<leader>sv` / `<leader>sh` | Split right / down |
| `<leader>sc` / `<leader>s=` | Close split / equalise |
| `⌥`/`Alt` arrows | Resize split — macOS keeps `Ctrl`+arrows for Mission Control |
| `⇧H` / `⇧L` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `Tab` `h` / `Tab` `l` | Previous / next tab |
| `Tab` `n` / `Tab` `q` / `Tab` `o` | New tab / close it / close the others |
| `Tab` `1`…`9` | Jump to that tab |
| `Tab` `⇧H` / `Tab` `⇧L` | Move the tab left / right along the bar |
| `Tab` `m` | Move the current window to its own tab |
| `<leader>tt` / `<leader>tv` / `<leader>tT` | Terminal in a bottom split / right split / new tab |
| `<leader>c…` | Code — see below |
| `Esc Esc` | Leave terminal mode |
| `J` / `K` (visual) | Move the selection up/down |
| `Esc` | Clear search highlight |

Splits and their bindings deliberately mirror the terminal's, so `⌘D` outside nvim and `<leader>sv` inside it do the same thing.

`Tab` is a prefix, never a key on its own. It shares a byte with `Ctrl+I` in a legacy terminal, which would normally cost you jumplist-forward — Ghostty speaks the kitty keyboard protocol and nvim reads it, so the two stay distinct. `gt` / `gT` still work; they're just not the way in any more.

> **On WSL this is the one thing that doesn't survive.** Windows Terminal does not implement the kitty keyboard protocol, so `Tab` arrives as `Ctrl+I` and the whole family collides with jumplist-forward. The keymaps are deliberately left identical across platforms rather than forked.

Terminals are built-in `:terminal` rather than a plugin — every press opens a *new* shell, so when one turns out to be long-running, `Tab` `m` promotes it to its own tab and it stays there. A clean `exit` closes the split itself; a non-zero exit is left on screen. Ctrl+L, Ctrl+J, Ctrl+K and Alt+arrows are deliberately unmapped in terminal mode so they still belong to zsh — press `Esc Esc` first.

#### Code

`<leader>c` is the code group, and it only has anything in it once a language server has attached. Neovim 0.11 already binds `grn` rename, `gra` code action, `grr` references, `gri` implementation, `K` hover and `[d` / `]d` between diagnostics, so this adds the gaps rather than a second set.

| Keys | Action |
| --- | --- |
| `gd` / `gD` / `gy` | Definition / declaration / type definition |
| `<leader>ca` / `<leader>cn` | Code action / rename |
| `<leader>cf` | Format buffer (also runs on save) |
| `<leader>cd` / `<leader>cD` | Diagnostics for the line / all of them to the quickfix list |
| `<leader>ch` | Toggle inlay hints — on by default where the server offers them |
| `<leader>cs` / `<leader>cS` | Document / workspace symbols |
| `<leader>ci` | `:checkhealth vim.lsp` |

Rename is `<leader>cn`, not `cr`, because `<leader>cr` and `<leader>cp` are the two language subgroups. They appear only in a buffer of that filetype:

| Keys | Action |
| --- | --- |
| `<leader>cr` `r` / `t` / `b` | `cargo run` / `test` / `build` |
| `<leader>cr` `c` / `C` | `cargo check` / `cargo clippy` |
| `<leader>cr` `m` / `p` | Expand the macro under the cursor / go to the parent module |
| `<leader>cr` `o` | Open `Cargo.toml` |
| `<leader>cp` `r` / `t` | `uv run` this file / `uv run pytest` |
| `<leader>cp` `i` | Organise imports |
| `<leader>cp` `v` | Show the interpreter basedpyright resolved |

The cargo and uv keys open a bottom `:terminal` split, so they inherit the rule above: a clean run closes its own split and a failure is left on screen with its output. Silence means it passed.

## The palette

Gruvbox Dark Hard, used identically by the terminal, Starship, fzf, bat and zsh syntax highlighting.

| | hex | | hex |
| --- | --- | --- | --- |
| bg | `#1d2021` | fg | `#ebdbb2` |
| red | `#fb4934` | green | `#b8bb26` |
| yellow | `#fabd2f` | blue | `#83a598` |
| purple | `#d3869b` | aqua | `#8ec07c` |
| orange | `#fe8019` | grey | `#928374` |

## Customising

- **Machine-specific shell config** — `~/.zshrc.local`, sourced last, git-ignored
- **Anything platform-specific** — `zsh/os.zsh`, so every other file stays platform-neutral
- **Transparency** — `ghostty/config`'s `background-opacity`, or `opacity` in `windows/settings.json`
- **Editor** — `EDITOR`/`VISUAL` in `zsh/zshrc`, `nvim` when it's installed, `vim` otherwise
- **Adding a config** — drop the file in the repo and add one `src:dest` line to the `LINKS` array at the top of `install.sh`
- **Adding a Neovim plugin** — create `nvim/lua/plugins/<name>.lua` returning a lazy.nvim spec table. It's picked up automatically by the `{ import = "plugins" }` spec; no other file needs editing. `nvim/lazy-lock.json` pins the versions and is committed.
- **Adding a language server** — add its binary to the `Brewfile`, name it in `vim.lsp.enable` at the foot of `nvim/lua/plugins/lsp.lua`, and put any settings in `nvim/after/lsp/<server>.lua`. Nothing goes in `install.sh`.

### What's in the Neovim config

Still deliberately small — options, keymaps, a colourscheme, a statusline, a file tree, terminals and key hints, plus language support for Python, Rust and Lua. No treesitter or fuzzy finder yet.

No icon provider is installed, so every file in the tree shares one glyph — add `nvim-web-devicons` or `mini.icons` and per-filetype icons appear with no further config. netrw is disabled; neo-tree handles `nvim .` too.

```
nvim/
├── init.lua
├── .stylua.toml
├── lua/config/{options,keymaps,autocmds,lazy}.lua
├── lua/plugins/{colorscheme,lualine,neo-tree,which-key,lsp,format}.lua
└── after/lsp/{basedpyright,ruff,rust_analyzer,lua_ls}.lua
```

The lualine theme is written from `starship.toml`'s palette rather than lualine's bundled gruvbox — same separator glyphs, same colours, so the prompt and the statusline read as one thing.

#### Language servers

Nine plugins now, of which two do the language work: `nvim-lspconfig` and `conform.nvim`. Four deliberate choices sit behind that number, each of which is the reason a more common plugin *isn't* here.

**The binaries come from the Brewfile, not Mason.** Mason is the usual answer, and it would mean a second package manager installing into `~/.local/share/nvim/mason/bin` — invisible to the shell, to CI and to `install.sh`'s `doctor()`. Every server needed is a bottled formula on all three platforms, so one `brew "…"` line does the same job in the place this repo already keeps its packages. That drops mason, mason-lspconfig and mason-tool-installer.

**Rust is the one exception, and comes from rustup:**

```sh
rustup component add rust-analyzer
```

`rust-analyzer` has to match the toolchain that built the crate or it reports proc-macro expansion failures and trait errors that aren't real. Note that `command -v rust-analyzer` will succeed *before* you run that — rustup symlinks a shim into `~/.cargo/bin` whether or not the component exists, and it fails with "Unknown binary" when called. `doctor()` runs the binary rather than trusting the path for exactly that reason.

**Per-server settings live in `after/lsp/`, not `lsp/`.** Neovim folds every `lsp/<name>.lua` on the runtimepath with `tbl_deep_extend("force")`, so the last one wins — and nvim-lspconfig's copy comes after `~/.config/nvim`'s. `after/` is last on the runtimepath by definition, which is what `:h lsp-config-merge` points at for overriding a plugin's config. Putting them in `lsp/` appears to work, because the keys people usually override (`settings`) aren't ones nvim-lspconfig sets; it fails silently the moment you touch `root_markers`, `cmd` or `filetypes`.

**Completion is Neovim's own.** 0.12 ships insert-mode completion — `'autocomplete'` draws from the sources in `'complete'`, where `o` means omnifunc, which `vim.lsp.completion.enable()` sets. No nvim-cmp, no blink, no capabilities plumbing.

Python runs two servers: `ruff` for lint, format and imports, `basedpyright` for types, hover and goto. Ruff's hover is switched off so basedpyright answers `K`. Rust runs plain `rust_analyzer` rather than rustaceanvim — `<leader>crm` and `<leader>crp` implement the two extensions worth having directly.

If third-party imports come up unresolved, basedpyright has picked the wrong interpreter — `<leader>cpv` shows which one it resolved. It looks for `.venv/bin/python` under the project root, and `uv.lock` is the first root marker so uv workspaces anchor at the workspace rather than the member package. Better still, commit it:

```toml
[tool.basedpyright]
venvPath = "."
venv = ".venv"
```

Formatting is conform.nvim's alone — ruff for Python, rustfmt for Rust, stylua for Lua, with `lsp_format = "never"` so the LSP client never races it. `nvim/.stylua.toml` matches the config's own 2-space style; without it stylua defaults to tabs and rewrites all fourteen files. The column-aligned trailing comments it still wants to collapse are wrapped in `-- stylua: ignore` where they appear.

## Starting over

If a machine ran an older version of this repo, its Neovim state is still on disk and the current config doesn't use any of it.

```sh
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim
cd ~/.dotfiles && ./install.sh
```

## Requirements

- macOS, Linux, or Windows with WSL 2
- Neovim ≥ 0.12 (`'autocomplete'`, `vim.lsp.completion`) — the Brewfile installs it
- A terminal using JetBrainsMono Nerd Font — Ghostty is configured for it; set it yourself in any other terminal, or the powerline separators show as boxes
- For Rust only: a [rustup](https://rustup.rs) toolchain plus `rustup component add rust-analyzer`. `install.sh` neither installs nor manages this — it only warns when the component is missing.
