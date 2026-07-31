#!/usr/bin/env bash
#
# ── Beautiful WSL terminal setup ────────────────────────────────────────────
#   Zsh + Starship + Catppuccin Mocha, for Ubuntu 24.04 under WSL2.
#
#   Usage:   bash setup-terminal.sh
#            bash setup-terminal.sh --fix-mounts    (also tidy /etc/wsl.conf)
#
#   Safe to re-run. Existing dotfiles are backed up to ~/.dotfiles-backup/<timestamp>/
#   Every config it writes lives inside your WSL home directory:
#
#     ~/.zshrc                     shell config (sources the files below)
#     ~/.config/zsh/aliases.zsh    aliases and helper functions
#     ~/.config/starship.toml      the prompt
#     ~/.config/bat/config         bat (syntax-highlighting cat)
#     ~/.config/eza/theme.yml      eza (colourful ls)
#     ~/.config/zsh/plugins/       autosuggestions + syntax highlighting
# ───────────────────────────────────────────────────────────────────────────

set -euo pipefail

FIX_MOUNTS=0
[[ "${1:-}" == "--fix-mounts" ]] && FIX_MOUNTS=1

# ── pretty output helpers ──────────────────────────────────────────────────
if [[ -t 1 ]]; then
  B=$'\033[1m'; DIM=$'\033[2m'; GRN=$'\033[38;5;114m'; BLU=$'\033[38;5;111m'
  YLW=$'\033[38;5;222m'; RED=$'\033[38;5;210m'; R=$'\033[0m'
else
  B=""; DIM=""; GRN=""; BLU=""; YLW=""; RED=""; R=""
fi
step() { printf '\n%s%s▸ %s%s\n' "$B" "$BLU" "$1" "$R"; }
ok()   { printf '  %s✓%s %s\n' "$GRN" "$R" "$1"; }
warn() { printf '  %s!%s %s\n' "$YLW" "$R" "$1"; }
die()  { printf '\n%s✗ %s%s\n' "$RED" "$1" "$R" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die "Run this as your normal user, not root (it writes to \$HOME)."
command -v apt-get >/dev/null || die "This script expects a Debian/Ubuntu system."

BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
# tilde <path> — print a path with $HOME collapsed to ~ (note: the replacement
# must be escaped, or bash tilde-expands it straight back into $HOME)
tilde() { printf '%s' "${1/#$HOME/\~}"; }
backup() {  # backup <path> — move an existing file aside before we overwrite it
  [[ -e "$1" || -L "$1" ]] || return 0
  mkdir -p "$BACKUP"
  mv "$1" "$BACKUP/$(basename "$1")"
  warn "backed up $(basename "$1") → $(tilde "$BACKUP")"
}

printf '%s╭───────────────────────────────────────────────╮\n' "$B"
printf '│  Zsh + Starship + Catppuccin Mocha for WSL    │\n'
printf '╰───────────────────────────────────────────────╯%s\n' "$R"

# ── 1. packages ────────────────────────────────────────────────────────────
step "Installing packages"
sudo apt-get update -qq
PKGS=(zsh git curl wget unzip ca-certificates bat ripgrep fd-find fontconfig file fzf)
sudo apt-get install -y -qq "${PKGS[@]}" >/dev/null
ok "zsh, git, curl, bat, ripgrep, fd, fzf"

# zoxide — directory jumping. In noble's universe repo; upstream script otherwise.
if command -v zoxide >/dev/null; then
  ok "zoxide already present"
elif sudo apt-get install -y -qq zoxide >/dev/null 2>&1; then
  ok "zoxide (from apt)"
elif curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
       | sh -s -- --bin-dir "$HOME/.local/bin" >/dev/null 2>&1; then
  ok "zoxide (upstream installer → ~/.local/bin)"
else
  warn "could not install zoxide — fzf will still work, but 'z' will not"
fi

# eza is in Ubuntu 24.04 (noble) universe; older releases need the upstream repo
if ! command -v eza >/dev/null; then
  if apt-cache show eza >/dev/null 2>&1; then
    sudo apt-get install -y -qq eza >/dev/null && ok "eza (from apt)"
  else
    warn "eza not in apt — adding the upstream repository"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
      | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
      | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo apt-get update -qq && sudo apt-get install -y -qq eza >/dev/null && ok "eza (upstream repo)"
  fi
else
  ok "eza already present"
fi

# ── 2. starship ────────────────────────────────────────────────────────────
step "Installing Starship prompt"
if command -v starship >/dev/null; then
  ok "starship already installed ($(starship --version | head -1))"
else
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes >/dev/null
  ok "starship installed"
fi

# ── 3. zsh plugins ─────────────────────────────────────────────────────────
step "Fetching zsh plugins"
PLUGDIR="$HOME/.config/zsh/plugins"
mkdir -p "$PLUGDIR"
clone_or_pull() {  # clone_or_pull <repo-url> <dest>
  if [[ -d "$2/.git" ]]; then
    git -C "$2" pull --quiet --ff-only 2>/dev/null && ok "$(basename "$2") updated" \
      || warn "$(basename "$2") — could not update, keeping existing copy"
  else
    rm -rf "$2"
    git clone --depth 1 --quiet "$1" "$2" && ok "$(basename "$2") cloned"
  fi
}
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions.git      "$PLUGDIR/zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting.git  "$PLUGDIR/zsh-syntax-highlighting"
clone_or_pull https://github.com/zsh-users/zsh-completions.git          "$PLUGDIR/zsh-completions"

# ── 4. starship.toml ───────────────────────────────────────────────────────
step "Writing configuration files"
mkdir -p "$HOME/.config" "$HOME/.cache/zsh/zcompcache"
backup "$HOME/.config/starship.toml"
cat > "$HOME/.config/starship.toml" <<'STARSHIP_EOF'
# Catppuccin Mocha · https://starship.rs/config
"$schema" = 'https://starship.rs/config-schema.json'

palette = "catppuccin_mocha"
add_newline = true
command_timeout = 1000

# Full powerline — every segment is a filled coloured block:
#
#    jonnyb  ~/projects/app   main !2   20.11.0  󰅐 14:32  ❯❯❯
#
# The arrow separator lives *inside* each module's own format string and is
# coloured fg:prev_bg, so it inherits whatever block rendered before it. That
# is what makes this safe: when a module has nothing to show (not in a repo, no
# node project) it vanishes entirely rather than leaving an orphaned arrow, and
# the next block's arrow still picks up the correct colour.
format = """
[](fg:red)\
$os\
$username\
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$rust\
$golang\
$java\
$docker_context\
$jobs\
$cmd_duration\
$status\
$time\
[](fg:prev_bg)\
$character"""

[os]
disabled = false
style = "bg:red fg:crust"
format = '[ $symbol ]($style)'

[os.symbols]
Ubuntu  = ""
Debian  = ""
Arch    = ""
Fedora  = ""
Alpine  = ""
Linux   = ""
Windows = ""
Macos   = ""

[username]
show_always = true
style_user = "bg:red fg:crust bold"
style_root = "bg:red fg:crust bold"
format = '[$user ]($style)'

[directory]
style = "bg:peach fg:crust bold"
format = '[](fg:prev_bg bg:peach)[ $path ]($style)'
truncation_length = 3
truncation_symbol = "…/"
truncate_to_repo = true          # inside a repo, show the path from its root
read_only = " 󰌾"
read_only_style = "bg:peach fg:crust"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "
"projects" = " "

# Triple chevron, fading from dark to bright so it reads as a gradient.
# Greens when the last command succeeded, reds when it failed.
[character]
success_symbol = "[ ❯](bold green_deep)[❯](bold green_mid)[❯](bold green)"
error_symbol   = "[ ❯](bold red_deep)[❯](bold red_mid)[❯](bold red)"
vimcmd_symbol  = "[ ❮❮❮](bold lavender)"

# git_branch opens the green block; git_status continues inside the same block,
# so there is no arrow between them.
[git_branch]
symbol = " "
style = "bg:green fg:crust bold"
format = '[](fg:prev_bg bg:green)[ $symbol$branch ]($style)'

[git_status]
style = "bg:green fg:crust"
format = '[$all_status$ahead_behind ]($style)'
conflicted = "= "
ahead = "⇡${count} "
behind = "⇣${count} "
diverged = "⇕⇡${ahead_count}⇣${behind_count} "
untracked = "? "
stashed = "$ "
modified = "! "
staged = "+ "
renamed = "» "
deleted = "✘ "

[cmd_duration]
min_time = 2000
style = "bg:surface1 fg:subtext1"
format = '[](fg:prev_bg bg:surface1)[ 󱦟 $duration ]($style)'

# Shows the exit code when a command fails, e.g. ✘ 127 for "not found"
[status]
disabled = false
style = "bg:maroon fg:crust bold"
symbol = "✘ "
map_symbol = true
format = '[](fg:prev_bg bg:maroon)[ $symbol$status ]($style)'

# Background jobs, e.g. after Ctrl+Z
[jobs]
symbol = " "
style = "bg:mauve fg:crust bold"
number_threshold = 1
format = '[](fg:prev_bg bg:mauve)[ $symbol$number ]($style)'

# Always rendered, so it reliably closes the block chain
[time]
disabled = false
time_format = "%R"
style = "bg:lavender fg:crust bold"
format = '[](fg:prev_bg bg:lavender)[ 󰅐 $time ]($style)'

[nodejs]
symbol = ""
style = "bg:teal fg:crust"
format = '[](fg:prev_bg bg:teal)[ $symbol $version ]($style)'

[python]
symbol = ""
style = "bg:yellow fg:crust"
format = '[](fg:prev_bg bg:yellow)[ $symbol $version(\($virtualenv\)) ]($style)'

[rust]
symbol = ""
style = "bg:flamingo fg:crust"
format = '[](fg:prev_bg bg:flamingo)[ $symbol $version ]($style)'

[golang]
symbol = ""
style = "bg:sky fg:crust"
format = '[](fg:prev_bg bg:sky)[ $symbol $version ]($style)'

[java]
symbol = ""
style = "bg:rosewater fg:crust"
format = '[](fg:prev_bg bg:rosewater)[ $symbol $version ]($style)'

[docker_context]
symbol = ""
style = "bg:sapphire fg:crust"
format = '[](fg:prev_bg bg:sapphire)[ $symbol $context ]($style)'
only_with_files = true

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo  = "#f2cdcd"
pink      = "#f5c2e7"
mauve     = "#cba6f7"
red       = "#f38ba8"
maroon    = "#eba0ac"
peach     = "#fab387"
yellow    = "#f9e2af"
green     = "#a6e3a1"
teal      = "#94e2d5"
sky       = "#89dceb"
sapphire  = "#74c7ec"
blue      = "#89b4fa"
lavender  = "#b4befe"
text      = "#cdd6f4"
subtext1  = "#bac2de"
subtext0  = "#a6adc8"
overlay2  = "#9399b2"
overlay1  = "#7f849c"
overlay0  = "#6c7086"
surface2  = "#585b70"
surface1  = "#45475a"
surface0  = "#313244"
base      = "#1e1e2e"
mantle    = "#181825"
crust     = "#11111b"
# extra shades, only used for the triple-chevron gradient
green_deep = "#3d6b4a"
green_mid  = "#6fc47f"
red_deep   = "#7a3b4a"
red_mid    = "#d96a86"
STARSHIP_EOF
ok "~/.config/starship.toml"

# ── 5. bat ─────────────────────────────────────────────────────────────────
BATCMD=$(command -v batcat || command -v bat || true)
if [[ -n "$BATCMD" ]]; then
  BATDIR="$("$BATCMD" --config-dir)"
  mkdir -p "$BATDIR/themes"
  if [[ ! -f "$BATDIR/themes/Catppuccin Mocha.tmTheme" ]]; then
    curl -fsSL -o "$BATDIR/themes/Catppuccin Mocha.tmTheme" \
      "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme" \
      && ok "Catppuccin theme for bat" || warn "could not download the bat theme (offline?)"
  fi
  backup "$BATDIR/config"
  cat > "$BATDIR/config" <<'BAT_EOF'
--theme="Catppuccin Mocha"
--style="numbers,changes,header"
--italic-text=always
BAT_EOF
  "$BATCMD" cache --build >/dev/null 2>&1 || true
  ok "$(tilde "$BATDIR")/config"
fi

# ── 6. eza ─────────────────────────────────────────────────────────────────
mkdir -p "$HOME/.config/eza"
backup "$HOME/.config/eza/theme.yml"
cat > "$HOME/.config/eza/theme.yml" <<'EZA_EOF'
# Catppuccin Mocha for eza
colourful: true
filekinds:
  normal:    { foreground: "#cdd6f4" }
  directory: { foreground: "#89b4fa", is_bold: true }
  symlink:   { foreground: "#94e2d5" }
  pipe:      { foreground: "#7f849c" }
  block_device: { foreground: "#eba0ac", is_bold: true }
  char_device:  { foreground: "#eba0ac", is_bold: true }
  socket:    { foreground: "#7f849c" }
  special:   { foreground: "#cba6f7" }
  executable: { foreground: "#a6e3a1", is_bold: true }
  mount_point: { foreground: "#b4befe" }
perms:
  user_read:            { foreground: "#cdd6f4" }
  user_write:           { foreground: "#f9e2af" }
  user_execute_file:    { foreground: "#a6e3a1", is_bold: true }
  user_execute_other:   { foreground: "#a6e3a1" }
  group_read:           { foreground: "#bac2de" }
  group_write:          { foreground: "#f9e2af" }
  group_execute:        { foreground: "#a6e3a1" }
  other_read:           { foreground: "#a6adc8" }
  other_write:          { foreground: "#f9e2af" }
  other_execute:        { foreground: "#a6e3a1" }
  special_user_file:    { foreground: "#cba6f7" }
  special_other:        { foreground: "#6c7086" }
  attribute:            { foreground: "#a6adc8" }
size:
  major: { foreground: "#cdd6f4" }
  minor: { foreground: "#89dceb" }
  number_byte: { foreground: "#cdd6f4" }
  number_kilo: { foreground: "#bac2de" }
  number_mega: { foreground: "#89b4fa" }
  number_giga: { foreground: "#cba6f7" }
  number_huge: { foreground: "#f5c2e7" }
  unit_byte: { foreground: "#a6adc8" }
  unit_kilo: { foreground: "#89b4fa" }
  unit_mega: { foreground: "#cba6f7" }
  unit_giga: { foreground: "#f5c2e7" }
  unit_huge: { foreground: "#f2cdcd" }
users:
  user_you:            { foreground: "#cdd6f4" }
  user_root:           { foreground: "#f38ba8" }
  user_other:          { foreground: "#cba6f7" }
  group_yours:         { foreground: "#cdd6f4" }
  group_root:          { foreground: "#f38ba8" }
  group_other:         { foreground: "#7f849c" }
links:
  normal:      { foreground: "#94e2d5" }
  multi_link_file: { foreground: "#89dceb" }
git:
  new:         { foreground: "#a6e3a1" }
  modified:    { foreground: "#f9e2af" }
  deleted:     { foreground: "#f38ba8" }
  renamed:     { foreground: "#94e2d5" }
  typechange:  { foreground: "#cba6f7" }
  ignored:     { foreground: "#6c7086" }
  conflicted:  { foreground: "#eba0ac" }
git_repo:
  branch_main: { foreground: "#cdd6f4" }
  branch_other: { foreground: "#cba6f7" }
  git_clean:   { foreground: "#a6e3a1" }
  git_dirty:   { foreground: "#f38ba8" }
punctuation:  { foreground: "#585b70" }
date:         { foreground: "#f9e2af" }
inode:        { foreground: "#a6adc8" }
blocks:       { foreground: "#bac2de" }
header:       { foreground: "#cdd6f4", is_underline: true }
octal:        { foreground: "#94e2d5" }
flags:        { foreground: "#f5c2e7" }
symlink_path: { foreground: "#94e2d5" }
control_char: { foreground: "#89dceb" }
broken_symlink: { foreground: "#f38ba8" }
broken_path_overlay: { is_underline: true }
EZA_EOF
ok "~/.config/eza/theme.yml"

# ── 6b. fzf preview helper ─────────────────────────────────────────────────
# A standalone script rather than a shell function, because fzf runs its
# --preview command in a plain `sh`, which cannot see zsh functions.
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/fzf-preview" <<'PREVIEW_EOF'
#!/usr/bin/env bash
# Preview whatever fzf is currently highlighting: directory tree, syntax-
# highlighted text, or a summary for binaries.
target="${1:-}"
[[ -n "$target" && -e "$target" ]] || exit 0

if [[ -d "$target" ]]; then
  if command -v eza >/dev/null; then
    eza --tree --level=2 --icons=always --colour=always --group-directories-first -- "$target"
  else
    ls -1 -- "$target"
  fi
  exit 0
fi

BAT="$(command -v batcat || command -v bat || true)"
mime="$(file -bL --mime-type -- "$target" 2>/dev/null || echo unknown)"

case "$mime" in
  text/*|application/json|application/javascript|application/xml|*+xml|*+json|inode/x-empty)
    if [[ -n "$BAT" ]]; then
      "$BAT" --style=numbers --color=always --line-range=:300 -- "$target"
    else
      head -n 300 -- "$target"
    fi
    ;;
  image/*)
    printf '  image  %s\n\n' "$target"
    file -bL -- "$target"
    ;;
  *)
    printf '  binary  %s\n\n' "$target"
    file -bL -- "$target"
    printf '\n'
    ls -lh -- "$target" | awk '{print "size: "$5}'
    ;;
esac
PREVIEW_EOF
chmod +x "$HOME/.local/bin/fzf-preview"
ok "~/.local/bin/fzf-preview"

# ── 6c. fzf + zoxide config ────────────────────────────────────────────────
mkdir -p "$HOME/.config/zsh"
backup "$HOME/.config/zsh/fzf.zsh"
cat > "$HOME/.config/zsh/fzf.zsh" <<'FZF_EOF'
# ── fuzzy finding: fzf + zoxide ────────────────────────────────────────────
# Sourced by ~/.zshrc. Safe to edit.

if command -v fzf >/dev/null; then

  # Use fd for listing — fast, skips .git, respects .gitignore.
  # Ubuntu names the binary fdfind.
  #
  # Deliberately NOT using --follow. On WSL it is common to keep a symlink to
  # the Windows side (~/to_windows -> /mnt/c/Users/you), and --follow would
  # make every search descend through it into the whole Windows profile, over
  # the slow interop filesystem. Symlinks are still listed, just not entered;
  # cd into one and searches there work normally.
  _fd="$(command -v fdfind || command -v fd || true)"
  if [[ -n $_fd ]]; then
    _fd_common="--hidden --exclude .git --exclude node_modules --exclude .cache"
    export FZF_DEFAULT_COMMAND="$_fd --type=file ${_fd_common}"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$_fd --type=directory ${_fd_common}"
    unset _fd_common
  fi
  unset _fd

  # Catppuccin Mocha, matching the rest of the setup
  export FZF_DEFAULT_OPTS="
    --height=60% --layout=reverse --border=rounded --info=inline
    --prompt='  ' --pointer='▶' --marker='✚'
    --cycle --multi --scroll-off=3
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-a:select-all,ctrl-d:deselect-all'
    --bind='shift-up:preview-page-up,shift-down:preview-page-down'
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --color=border:#585b70,gutter:#1e1e2e"

  # Ctrl+T — find a file, with a preview pane
  export FZF_CTRL_T_OPTS="
    --preview='fzf-preview {}'
    --preview-window='right:60%:wrap'
    --header='enter: insert path · ctrl-/: hide preview'"

  # Alt+C — jump into a directory
  export FZF_ALT_C_OPTS="
    --preview='fzf-preview {}'
    --preview-window='right:55%'
    --header='enter: cd into directory'"

  # Ctrl+R — search history. Preview hidden until you hit ctrl-/, since long
  # commands are the only ones that need it.
  export FZF_CTRL_R_OPTS="
    --preview='echo {2..}'
    --preview-window='down:4:hidden:wrap'
    --header='enter: run · ctrl-/: show full command'"

  # Shell integration. fzf 0.48+ can emit it directly; Ubuntu 24.04 ships
  # 0.44, which installs the scripts under /usr/share instead.
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    for _f in /usr/share/doc/fzf/examples/key-bindings.zsh \
              /usr/share/doc/fzf/examples/completion.zsh \
              /usr/share/fzf/key-bindings.zsh \
              /usr/share/fzf/completion.zsh; do
      [[ -f $_f ]] && source $_f
    done
    unset _f
  fi

  # ── helper functions ─────────────────────────────────────────────────────

  # ff — fuzzy-find a file and open it in $EDITOR
  ff() {
    local file
    file=$(fzf --preview='fzf-preview {}' --preview-window='right:60%:wrap' \
               --header='select a file to edit') || return
    [[ -n $file ]] && ${EDITOR:-nano} -- "$file"
  }

  # fh — search history and put the chosen command on the command line
  fh() {
    local cmd
    cmd=$(fc -rl 1 | fzf --tac --header='select a command' | sed 's/^ *[0-9]* *//') || return
    [[ -n $cmd ]] && print -z -- "$cmd"
  }

  # fbr — check out a git branch, local or remote
  fbr() {
    git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; return 1; }
    local branch
    branch=$(git branch --all --color=never \
      | grep -v HEAD | sed 's/^[* ] //;s#^remotes/[^/]*/##' | sort -u \
      | fzf --ansi --header='select a branch to check out' \
            --preview='git log --oneline --graph --color=always -20 {}') || return
    [[ -n $branch ]] && git checkout "$branch"
  }

  # fkill — pick a process and terminate it
  fkill() {
    local pids
    pids=$(ps -eo pid,ppid,user,pcpu,pmem,comm --sort=-pcpu \
      | fzf --header-lines=1 --multi \
            --header='select process(es) to kill · tab to multi-select' \
      | awk '{print $1}') || return
    [[ -n $pids ]] && echo "$pids" | xargs --no-run-if-empty kill "${@:--15}"
  }

  # frg — ripgrep across the tree, then open the match at the right line
  frg() {
    [[ -n ${1:-} ]] || { echo "usage: frg <pattern>" >&2; return 1; }
    local match file line
    match=$(rg --line-number --no-heading --color=always --smart-case -- "$1" \
      | fzf --ansi --delimiter=: \
            --preview='fzf-preview {1}' --preview-window='right:60%:+{2}-/2') || return
    [[ -n $match ]] || return
    file=${match%%:*}; line=${${match#*:}%%:*}
    ${EDITOR:-nano} +"$line" -- "$file"
  }
fi

# ── zoxide: jump to directories by partial name ─────────────────────────────
# `z proj` goes to the project directory you use most; `zi` picks from a list.
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi
FZF_EOF
ok "~/.config/zsh/fzf.zsh"

# ── 7. aliases ─────────────────────────────────────────────────────────────
mkdir -p "$HOME/.config/zsh"
backup "$HOME/.config/zsh/aliases.zsh"
cat > "$HOME/.config/zsh/aliases.zsh" <<'ALIAS_EOF'
# ── aliases & small helpers ────────────────────────────────────────────────
# Edit freely; this file is sourced by ~/.zshrc.

# eza — a colourful, git-aware ls
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -l  --group-directories-first --icons=auto --git --time-style=long-iso'
  alias la='eza -la --group-directories-first --icons=auto --git --time-style=long-iso'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
  alias ltt='eza --tree --level=4 --icons=auto --group-directories-first'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lh'
  alias la='ls -lah'
fi

# bat — Ubuntu ships the binary as `batcat`
if command -v batcat >/dev/null; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
elif command -v bat >/dev/null; then
  alias cat='bat --paging=never'
fi

# fd — Ubuntu ships the binary as `fdfind`
command -v fdfind >/dev/null && alias fd='fdfind'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# safety nets
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'
alias mkdir='mkdir -p'

# git
alias g='git'
alias gs='git status --short --branch'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --graph --oneline --decorate --all -20'

# misc
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias path='echo $PATH | tr ":" "\n"'
alias reload='exec zsh'
alias zshrc='${EDITOR:-nano} ~/.zshrc'
alias starconf='${EDITOR:-nano} ~/.config/starship.toml'

# ── WSL conveniences ───────────────────────────────────────────────────────
if grep -qi microsoft /proc/version 2>/dev/null; then
  alias open='explorer.exe'                  # open . opens the folder in Explorer
  alias pbcopy='clip.exe'                    # pipe into the Windows clipboard
  alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard'
  alias winhome='cd "$(wslpath "$(cmd.exe /c echo %USERPROFILE% 2>/dev/null | tr -d "\r")")"'
fi

# mkcd — make a directory and step into it
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# extract — unpack more or less any archive
extract() {
  [[ -f "$1" ]] || { echo "extract: '$1' is not a file" >&2; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf  "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.gz)             gunzip  "$1" ;;
    *.zip)            unzip   "$1" ;;
    *.7z)             7z x    "$1" ;;
    *.rar)            unrar x "$1" ;;
    *) echo "extract: don't know how to handle '$1'" >&2; return 1 ;;
  esac
}
ALIAS_EOF
ok "~/.config/zsh/aliases.zsh"

# ── 8. .zshrc ──────────────────────────────────────────────────────────────
backup "$HOME/.zshrc"
cat > "$HOME/.zshrc" <<'ZSHRC_EOF'
# ══ ~/.zshrc ═══════════════════════════════════════════════════════════════
#  Generated by setup-terminal.sh — edit it however you like, it will not be
#  overwritten unless you re-run the installer (which backs it up first).
# ═══════════════════════════════════════════════════════════════════════════

# ── environment ────────────────────────────────────────────────────────────
# Pick the best editor available, so installing neovim later makes it the
# default for git, crontab and anything else that reads $EDITOR.
if command -v nvim >/dev/null; then
  export EDITOR="nvim"
elif command -v vim >/dev/null; then
  export EDITOR="vim"
else
  export EDITOR="nano"
fi
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R --mouse"
export LANG="${LANG:-C.UTF-8}"

# Colours for ls and for the completion menu. Set before compinit, because the
# completion list-colors zstyle below reads this variable.
# The tw/ow entries stop Windows-mounted directories rendering green-on-green.
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34:st=1;34'

# keep ~/.local/bin and Starship on PATH
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/bin" /usr/local/bin $path)
export PATH

# ── history ────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # record timestamps
setopt INC_APPEND_HISTORY        # write as you go, not just on exit
setopt SHARE_HISTORY             # share between open shells
setopt HIST_IGNORE_ALL_DUPS      # keep only the most recent copy of a command
setopt HIST_IGNORE_SPACE         # a leading space hides a command from history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # expand !! before running it

# ── behaviour ──────────────────────────────────────────────────────────────
setopt AUTO_CD                   # `cd` is optional: typing a directory works
setopt AUTO_PUSHD                # keep a directory stack
setopt PUSHD_IGNORE_DUPS
setopt CORRECT                   # offer spelling corrections for commands
setopt INTERACTIVE_COMMENTS      # allow # comments when typing interactively
setopt NO_BEEP
setopt EXTENDED_GLOB
setopt NOTIFY

# ── completion ─────────────────────────────────────────────────────────────
fpath=("$HOME/.config/zsh/plugins/zsh-completions/src" $fpath)

autoload -Uz compinit
# Rebuild the completion cache at most once a day; otherwise trust it and skip
# the (slow) security check. Keeps shell startup snappy.
_zdump="$HOME/.zcompdump"
_zstale=( $_zdump(N.mh+24) )        # N = no error if absent, .mh+24 = older than 24h
if [[ ! -e $_zdump ]] || (( ${#_zstale} )); then
  compinit -d "$_zdump"
else
  compinit -C -d "$_zdump"
fi
unset _zdump _zstale

zstyle ':completion:*' menu select                      # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}%B%d%b%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true

# ── key bindings ───────────────────────────────────────────────────────────
bindkey -e                                   # emacs-style (Ctrl+A, Ctrl+E …)
bindkey '^[[1;5C' forward-word               # Ctrl+Right
bindkey '^[[1;5D' backward-word              # Ctrl+Left
bindkey '^[[3~'   delete-char                # Delete
bindkey '^[[H'    beginning-of-line          # Home
bindkey '^[[F'    end-of-line                # End
bindkey '^H'      backward-kill-word         # Ctrl+Backspace
bindkey '^[[Z'    reverse-menu-complete      # Shift+Tab

# Up/Down search history for what you have already typed — the single most
# useful binding in this file.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^P'   up-line-or-beginning-search
bindkey '^N'   down-line-or-beginning-search

# ── fuzzy finding (fzf + zoxide) ───────────────────────────────────────────
# Sourced before zsh-syntax-highlighting, because fzf registers zle widgets and
# the highlighter must be loaded after anything that does that.
if [[ -f "$HOME/.config/zsh/fzf.zsh" ]]; then
  source "$HOME/.config/zsh/fzf.zsh"
fi

# ── plugins ────────────────────────────────────────────────────────────────
ZSH_PLUGINS="$HOME/.config/zsh/plugins"

# autosuggestions: shows a greyed-out completion from history; → accepts it
if [[ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#585b70"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
  bindkey '^ ' autosuggest-accept            # Ctrl+Space accepts the suggestion
fi

# syntax highlighting must be sourced last
if [[ -f "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8,bold'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=#89b4fa'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f9e2af'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f9e2af'
  ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f5c2e7,bold'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f5c2e7,bold'
  source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ── aliases & functions ────────────────────────────────────────────────────
if [[ -f "$HOME/.config/zsh/aliases.zsh" ]]; then
  source "$HOME/.config/zsh/aliases.zsh"
fi

# ── bat as the man pager, with syntax colours ──────────────────────────────
if command -v batcat >/dev/null; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
  export MANROFFOPT="-c"
elif command -v bat >/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi

# ── local overrides (not tracked, safe for secrets and machine-specific bits)
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

# ── prompt (must stay at the end) ──────────────────────────────────────────
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

# Leave a clean exit status, so the very first prompt does not show the error
# colour just because the last line of this file was a failed test.
true
ZSHRC_EOF
ok "~/.zshrc"

# ── 9. optional: tidy Windows drive mounts ─────────────────────────────────
if [[ $FIX_MOUNTS -eq 1 ]]; then
  step "Configuring /etc/wsl.conf"
  if grep -q "^\[automount\]" /etc/wsl.conf 2>/dev/null; then
    warn "/etc/wsl.conf already has an [automount] section — leaving it alone"
  else
    sudo tee -a /etc/wsl.conf >/dev/null <<'WSLCONF_EOF'

[automount]
enabled = true
options = "metadata,umask=22,fmask=11"
WSLCONF_EOF
    ok "added [automount] with metadata — run 'wsl --shutdown' in PowerShell to apply"
  fi
fi

# ── 10. make zsh the default shell ─────────────────────────────────────────
step "Setting zsh as your default shell"
if ZSH_BIN="$(command -v zsh)"; then
  grep -qxF "$ZSH_BIN" /etc/shells 2>/dev/null \
    || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  if [[ "${SHELL:-}" == "$ZSH_BIN" ]]; then
    ok "already zsh"
  elif sudo chsh -s "$ZSH_BIN" "$USER" 2>/dev/null; then
    ok "default shell → $ZSH_BIN"
  else
    warn "could not change it automatically; run: chsh -s $ZSH_BIN"
  fi
else
  warn "zsh is not on PATH — the configs are written, but install zsh before using them"
fi

# ── 11. keep a copy of the installer for later ─────────────────────────────
mkdir -p "$HOME/.config/wsl-terminal-setup"
SELF="$(readlink -f "${BASH_SOURCE[0]}")"
[[ "$SELF" == "$HOME/.config/wsl-terminal-setup/install.sh" ]] \
  || cp "$SELF" "$HOME/.config/wsl-terminal-setup/install.sh"

# ── done ───────────────────────────────────────────────────────────────────
cat <<FINAL

$B$GRN Done.$R

 ${B}One thing left, on the Windows side:$R the prompt uses Nerd Font glyphs,
 so install the font and point Windows Terminal at it:

   ${DIM}# in PowerShell${R}
   winget install --id DEVCOM.JetBrainsMonoNerdFont

 Then in Windows Terminal: ${B}Settings → Ubuntu-24.04 → Appearance${R}
   Font face:   ${B}JetBrainsMono Nerd Font${R}
   Color scheme: ${B}Catppuccin Mocha${R}  ${DIM}(add it from windowsterminalthemes.dev)${R}

 Start your new shell with:   ${B}exec zsh${R}

 Try it out:       ${B}Ctrl+T${R} find a file · ${B}Ctrl+R${R} search history
                   ${B}Alt+C${R} jump to a directory · ${B}z <name>${R} jump anywhere

 Configs live in:  ${B}~/.zshrc${R}, ${B}~/.config/starship.toml${R},
                   ${B}~/.config/zsh/aliases.zsh${R}, ${B}~/.config/zsh/fzf.zsh${R}
 Re-run any time:  ${B}bash ~/.config/wsl-terminal-setup/install.sh${R}
FINAL
[[ -d "$BACKUP" ]] && printf ' Old dotfiles saved in: %s%s%s\n' "$B" "$(tilde "$BACKUP")" "$R"
echo
