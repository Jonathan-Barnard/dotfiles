# dotfiles

Ghostty · zsh · Starship — one Gruvbox Dark Hard palette across the whole terminal, powerline everywhere.

```
┌──────────────────────────────────────────────────────────┐
│  Ghostty        gruvbox palette, JetBrainsMono Nerd Font │
│  zsh            history, completion, syntax highlighting │
│  Starship       two-line powerline prompt                │
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
- **Editor** — `EDITOR`/`VISUAL` in `zsh/zshrc`, currently `vim`
- **Adding a config** — drop the file in the repo and add one `src:dest` line to the `LINKS` array at the top of `install.sh`

## Requirements

- macOS or Linux
- A terminal using JetBrainsMono Nerd Font — Ghostty is configured for it, but set it in any other terminal you use or the powerline separators will show as boxes
