# The Windows half

`install.sh` runs inside WSL and cannot reach the Windows side, so the font and
the terminal are set up once by hand. Both live in Windows, not Ubuntu.

## 1. Font

```powershell
winget install --id DEVCOM.JetBrainsMonoNerdFont
```

Without a Nerd Font the powerline prompt, the neo-tree glyphs and the fzf
pointer all render as boxes.

## 2. Windows Terminal

`settings.json` in this directory is the Gruvbox Dark Hard translation of the
macOS repo's `ghostty/config`. **Do not copy it over your own settings.json** —
Windows Terminal rewrites that file itself, and its `profiles.list` GUIDs are
specific to your machine.

Open yours with `Ctrl+Shift+,` (or Settings → Open JSON file). It lives at:

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

Then merge three blocks across:

| From `settings.json` here | Into yours |
|---|---|
| the `"Gruvbox Dark Hard"` object | append to the top-level `"schemes"` array |
| the whole `"profiles" → "defaults"` object | merge into your `"profiles"."defaults"` |
| the `"keybindings"` array | merge into your top-level `"keybindings"` |

Also set `"copyOnSelect": true` at the top level — that's Ghostty's
`copy-on-select`.

Saving the file applies it immediately; no restart needed.

## Keybindings

Ghostty's `super+` (⌘) becomes `ctrl+shift+` here. Terminals send `ctrl+shift+X`
distinctly from `ctrl+X`, so none of these are stolen from Neovim.

| macOS (Ghostty) | Windows Terminal | |
|---|---|---|
| `⌘D` | `Ctrl+Shift+D` | split right |
| `⌘⇧D` | `Ctrl+Shift+S` | split down |
| `⌘⇧W` | `Ctrl+Shift+W` | close pane |
| `⌘⌥←→↑↓` | `Ctrl+Alt+←→↑↓` | move focus between panes |
| `⌘T` | `Ctrl+Shift+T` | new tab |
| `⌘⇧←` / `⌘⇧→` | `Ctrl+Shift+←` / `Ctrl+Shift+→` | previous / next tab |
| `⌘+` `⌘-` `⌘0` | `Ctrl++` `Ctrl+-` `Ctrl+0` | font size |
| `⌘⇧,` | `Ctrl+Shift+,` | open settings |

Deliberately untouched, because Neovim wants them: `Ctrl+H/J/K/L` (window
navigation), `Ctrl+D` / `Ctrl+U` (half-page scroll), and plain `Alt+←→↑↓`
(split resize). Windows Terminal binds none of those by default.

## Known difference from macOS

Neovim's `<Tab>h/l/n/q/o/m/H/L/1…9` tab-page family relies on the terminal
speaking the kitty keyboard protocol, which is what keeps `<Tab>` and `<C-i>`
distinct. **Windows Terminal does not implement it**, so `<Tab>` arrives as
`<C-i>` and that family collides with jump-list-forward.

The keymaps are left exactly as they are on macOS rather than forked. If it
gets annoying, the fix is a Windows-only override in `nvim/` — or a terminal
that speaks the protocol (WezTerm, Alacritty).
