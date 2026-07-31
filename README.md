# dotfiles

WSL Ubuntu terminal and editor setup: zsh + Starship, Neovim, Catppuccin Mocha throughout.

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
```

---

## What it sets up

**Shell** — zsh with a full powerline Starship prompt, fzf fuzzy finding (`Ctrl+T`, `Ctrl+R`, `Alt+C`), zoxide directory jumping, and modern replacements for the core tools: eza, bat, fd, ripgrep.

**Editor** — Neovim 0.12 with LSP, completion, Telescope, a file tree, git signs, and a matching powerline statusline.

Both are documented in `docs/` — `TERMINAL-SETUP.md` and `NEOVIM-SETUP.md` cover every keybinding.

---

## Layout

```
dotfiles/
├── install.sh              bootstrap, then symlink everything
├── bootstrap/
│   ├── setup-terminal.sh   installs zsh, starship, fzf, eza, bat, fd
│   └── setup-neovim.sh     installs neovim + language servers
├── zsh/
│   ├── zshrc               → ~/.zshrc
│   ├── aliases.zsh         → ~/.config/zsh/aliases.zsh
│   └── fzf.zsh             → ~/.config/zsh/fzf.zsh
├── starship/starship.toml  → ~/.config/starship.toml
├── bat/config              → ~/.config/bat/config
├── eza/theme.yml           → ~/.config/eza/theme.yml
├── bin/fzf-preview         → ~/.local/bin/fzf-preview
├── nvim/                   → ~/.config/nvim
└── docs/
```

Everything under `~` is a symlink back into this repo, so editing either path edits the same file and `git status` picks it up immediately.

---

## How install.sh behaves

| Situation | What happens |
|---|---|
| Fresh machine, empty repo | Bootstrap writes the configs, then they're **moved into the repo** and linked back |
| Fresh machine, populated repo | Bootstrap runs for the packages, then the repo's configs **replace** what it wrote |
| Re-run on a working machine | Existing correct symlinks are left alone; anything else is relinked |

Replaced files are kept in `~/.dotfiles-backup/` rather than deleted.

```bash
./install.sh --dry-run     # show what would change, touch nothing
./install.sh --link-only   # skip the bootstrap, just repair symlinks
```

---

## Machine-specific things

Anything that shouldn't be public — API keys, work paths, one-off `PATH` entries — goes in `~/.zshrc.local`. It's sourced automatically if present and is gitignored.

`nvim/lazy-lock.json` **is** committed. It pins exact plugin versions, so a clone six months from now reproduces this setup rather than whatever the plugins have become. `:Lazy restore` rolls back to it.

---

## The Windows half

Windows Terminal owns the font and colour scheme, and lives outside WSL. Install the font once:

```powershell
winget install --id DEVCOM.JetBrainsMonoNerdFont
```

Then set the Ubuntu profile's font face to `JetBrainsMono Nerd Font`. Without a Nerd Font the prompt renders as boxes. `docs/TERMINAL-SETUP.md` has the Catppuccin Mocha colour scheme JSON to paste in.

---

## Starting over

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim
cd ~/dotfiles && ./install.sh
```
