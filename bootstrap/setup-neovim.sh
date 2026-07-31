#!/usr/bin/env bash
#
# ── Neovim for WSL Ubuntu ───────────────────────────────────────────────────
#   Neovim 0.12 + a hand-rolled modular config, Catppuccin Mocha, powerline
#   statusline, LSP, completion and a fuzzy finder. Matches the terminal setup.
#
#   Usage:   bash setup-neovim.sh
#
#   Safe to re-run. An existing ~/.config/nvim is backed up first.
#
#   Config layout, all under ~/.config/nvim:
#     init.lua                  entry point
#     lua/config/options.lua    editor settings
#     lua/config/keymaps.lua    key bindings
#     lua/config/autocmds.lua   automatic behaviours
#     lua/config/lazy.lua       plugin manager bootstrap
#     lua/plugins/*.lua         one file per concern
# ───────────────────────────────────────────────────────────────────────────

set -euo pipefail

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
tilde() { printf '%s' "${1/#$HOME/\~}"; }

[[ $EUID -ne 0 ]] || die "Run this as your normal user, not root."
command -v apt-get >/dev/null || die "This script expects a Debian/Ubuntu system."

ARCH="$(uname -m)"
[[ "$ARCH" == "x86_64" ]] || die "This script builds for x86_64; yours is $ARCH."

printf '%s╭───────────────────────────────────────────────╮\n' "$B"
printf '│  Neovim + Catppuccin Mocha for WSL Ubuntu     │\n'
printf '╰───────────────────────────────────────────────╯%s\n' "$R"

# ── 1. dependencies ────────────────────────────────────────────────────────
step "Installing dependencies"
sudo apt-get update -qq
# build-essential: telescope-fzf-native compiles a small C helper
# nodejs/npm:      many language servers are npm packages
# python3-venv:    mason builds python tools in a venv
DEPS=(git curl wget tar unzip build-essential ripgrep fd-find
      nodejs npm python3 python3-pip python3-venv)
sudo apt-get install -y -qq "${DEPS[@]}" >/dev/null
ok "build tools, node $(node --version 2>/dev/null || echo '?'), python3, ripgrep, fd"

# ── 2. neovim ──────────────────────────────────────────────────────────────
# Ubuntu 24.04 ships Neovim 0.9.5. The config below needs 0.11+ for the native
# vim.lsp.config API and prefers 0.12, which bundles treesitter parsers, so we
# install the upstream release tarball into /opt instead of using apt.
step "Installing Neovim"
need_nvim=1
if command -v nvim >/dev/null; then
  cur="$(nvim --version | head -1 | sed 's/^NVIM v//')"
  major="${cur%%.*}"; rest="${cur#*.}"; minor="${rest%%.*}"
  if (( major > 0 || minor >= 11 )); then
    ok "neovim $cur already installed"
    need_nvim=0
  else
    warn "neovim $cur is too old for this config — upgrading"
  fi
fi

if (( need_nvim )); then
  TARBALL="nvim-linux-x86_64.tar.gz"
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  curl -fL# -o "$TMP/$TARBALL" \
    "https://github.com/neovim/neovim/releases/latest/download/$TARBALL" \
    || die "could not download Neovim — check your connection"
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf "$TMP/$TARBALL"
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  hash -r
  ok "neovim $(nvim --version | head -1 | sed 's/^NVIM v//') → /opt, linked into /usr/local/bin"
fi

# ── 3. back up any existing config ─────────────────────────────────────────
step "Preparing ~/.config/nvim"
NVIM="$HOME/.config/nvim"
if [[ -e "$NVIM" ]]; then
  BACKUP="$HOME/.dotfiles-backup/nvim-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$(dirname "$BACKUP")"
  mv "$NVIM" "$BACKUP"
  warn "existing config moved to $(tilde "$BACKUP")"
fi
mkdir -p "$NVIM/lua/config" "$NVIM/lua/plugins"
ok "$(tilde "$NVIM")"

# ── 4. init.lua ────────────────────────────────────────────────────────────
step "Writing configuration"
cat > "$NVIM/init.lua" <<'EOF'
-- ═══════════════════════════════════════════════════════════════════════════
--  Neovim entry point.
--  Each require below maps to a file in lua/config/. Read them in this order.
-- ═══════════════════════════════════════════════════════════════════════════

-- The leader key must be set before lazy.nvim loads, or plugin mappings that
-- use <leader> will bind to the wrong key.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
EOF
ok "init.lua"

# ── 5. options ─────────────────────────────────────────────────────────────
cat > "$NVIM/lua/config/options.lua" <<'EOF'
-- ── editor settings ────────────────────────────────────────────────────────
-- `vim.o` is the modern way to set options. Anything here is a plain default
-- you can change freely.

local o = vim.o

-- ── unused language providers ──────────────────────────────────────────────
-- These exist for plugins written in Node, Python, Perl or Ruby. Nothing in
-- this config uses one, and leaving them on makes :checkhealth complain that
-- the corresponding host packages are missing. Disabling also trims a little
-- startup time. If you ever add a plugin that needs pynvim, delete the
-- python3 line and run: pip install --user pynvim
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- appearance
o.number = true                -- absolute line number on the cursor line
o.relativenumber = true        -- relative numbers elsewhere, so 5j / 3k are easy
o.signcolumn = "yes"           -- always show the gutter, stops text jumping
o.cursorline = true            -- subtle highlight on the current line
o.termguicolors = true         -- 24-bit colour, required by Catppuccin
o.laststatus = 3               -- one global statusline, not one per split
o.showmode = false             -- lualine already shows the mode
o.wrap = false
o.scrolloff = 8                -- keep 8 lines visible above/below the cursor
o.sidescrolloff = 8
o.winborder = "rounded"        -- rounded borders on hover/diagnostic popups
o.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- indentation: 2 spaces, no tabs
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true
o.breakindent = true

-- searching
o.ignorecase = true            -- case-insensitive...
o.smartcase = true             -- ...unless you type a capital
o.hlsearch = true
o.incsearch = true
o.inccommand = "split"         -- live preview of :%s substitutions

-- splits open where you expect
o.splitright = true
o.splitbelow = true

-- files and history
o.undofile = true              -- undo survives closing the file
o.undolevels = 10000
o.swapfile = false
o.backup = false
o.autoread = true
o.confirm = true               -- ask to save rather than refusing to quit

-- timing
o.updatetime = 250             -- how quickly diagnostics and git signs refresh
o.timeoutlen = 400             -- how long which-key waits before popping up

-- completion
o.completeopt = "menu,menuone,noselect"
o.pumheight = 12               -- cap the completion popup height

o.mouse = "a"

-- ── clipboard on WSL ───────────────────────────────────────────────────────
-- Deliberately NOT setting clipboard = "unnamedplus". On WSL, reading the
-- Windows clipboard shells out to powershell.exe, which takes ~200ms — and
-- with unnamedplus every single put would pay that cost. Instead the "+
-- register is wired up here, and <leader>y / <leader>p in keymaps.lua use it
-- explicitly. Normal yanking stays instant.
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "wsl-clipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -NoProfile -Command "Get-Clipboard -Raw" | tr -d "\r"',
      ["*"] = 'powershell.exe -NoProfile -Command "Get-Clipboard -Raw" | tr -d "\r"',
    },
    cache_enabled = 0,
  }
end

-- ── diagnostics ────────────────────────────────────────────────────────────
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
      [vim.diagnostic.severity.HINT]  = "󰌵 ",
    },
  },
  underline = true,
  update_in_insert = false,   -- don't nag while you are mid-thought
  severity_sort = true,
  float = { border = "rounded", source = true },
})

-- Neovim 0.12 bundles treesitter parsers for common languages and turns
-- highlighting on by default, so there is no nvim-treesitter plugin here.
-- For a language that is not bundled: install tree-sitter-cli, then :TSInstall
EOF
ok "lua/config/options.lua"

# ── 6. keymaps ─────────────────────────────────────────────────────────────
cat > "$NVIM/lua/config/keymaps.lua" <<'EOF'
-- ── key bindings ───────────────────────────────────────────────────────────
-- Leader is Space. Plugin-specific maps live with their plugin, in
-- lua/plugins/, so that they load only when that plugin does.

local map = function(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { silent = true, desc = desc }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- files
map("n", "<leader>w", "<cmd>write<cr>", "Save file")
map("n", "<leader>W", "<cmd>wall<cr>", "Save all files")
map("n", "<leader>q", "<cmd>quit<cr>", "Quit window")
map("n", "<leader>Q", "<cmd>qall!<cr>", "Quit everything, discarding changes")

-- clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")

-- window navigation, same keys as vim splits everywhere else
map("n", "<C-h>", "<C-w>h", "Go to left window")
map("n", "<C-j>", "<C-w>j", "Go to window below")
map("n", "<C-k>", "<C-w>k", "Go to window above")
map("n", "<C-l>", "<C-w>l", "Go to right window")

-- window sizing
map("n", "<C-Up>", "<cmd>resize +2<cr>", "Taller window")
map("n", "<C-Down>", "<cmd>resize -2<cr>", "Shorter window")
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", "Narrower window")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", "Wider window")

-- splits
map("n", "<leader>-", "<cmd>split<cr>", "Split horizontally")
map("n", "<leader>|", "<cmd>vsplit<cr>", "Split vertically")

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", "Previous buffer")
map("n", "<S-l>", "<cmd>bnext<cr>", "Next buffer")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Close buffer")

-- keep the cursor centred when jumping around, much easier to follow
map("n", "<C-d>", "<C-d>zz", "Half page down")
map("n", "<C-u>", "<C-u>zz", "Half page up")
map("n", "n", "nzzzv", "Next search result")
map("n", "N", "Nzzzv", "Previous search result")

-- move the selected lines up and down
map("v", "J", ":m '>+1<cr>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<cr>gv=gv", "Move selection up")

-- stay in visual mode when indenting, so you can press < or > repeatedly
map("v", "<", "<gv", "Outdent")
map("v", ">", ">gv", "Indent")

-- paste over a selection without losing what you had yanked
map("v", "p", '"_dP', "Paste without clobbering the register")

-- system clipboard, explicit because it crosses into Windows (see options.lua)
map({ "n", "v" }, "<leader>y", '"+y', "Yank to Windows clipboard")
map("n", "<leader>Y", '"+Y', "Yank line to Windows clipboard")
map({ "n", "v" }, "<leader>p", '"+p', "Paste from Windows clipboard")

-- diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostic under cursor")
map("n", "<leader>dl", vim.diagnostic.setloclist, "Diagnostics to location list")

-- terminal: Esc twice to get back to normal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")
map("n", "<leader>tt", "<cmd>terminal<cr>", "Open a terminal")

-- quick access to this config
map("n", "<leader>,", "<cmd>edit $MYVIMRC<cr>", "Edit init.lua")
EOF
ok "lua/config/keymaps.lua"

# ── 7. autocmds ────────────────────────────────────────────────────────────
cat > "$NVIM/lua/config/autocmds.lua" <<'EOF'
-- ── automatic behaviours ───────────────────────────────────────────────────

local augroup = function(name)
  return vim.api.nvim_create_augroup("cfg_" .. name, { clear = true })
end

-- Briefly highlight whatever you just yanked, so you can see what you got.
-- vim.highlight was renamed vim.hl in 0.11; fall back for older versions.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    local hl = vim.hl or vim.highlight
    hl.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- Reopen a file where you left off.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then return end
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Create missing parent directories when saving a new file.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("mkdir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Let q close throwaway windows, rather than needing :q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "man", "qf", "checkhealth", "lspinfo", "startuptime", "query" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Prose settings for text filetypes: wrap at the window edge, spellcheck on.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_gb"
  end,
})

-- Equalise split sizes when the terminal window is resized.
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize"),
  command = "tabdo wincmd =",
})
EOF
ok "lua/config/autocmds.lua"

# ── 8. lazy.nvim bootstrap ─────────────────────────────────────────────────
cat > "$NVIM/lua/config/lazy.lua" <<'EOF'
-- ── plugin manager ─────────────────────────────────────────────────────────
-- lazy.nvim installs itself on first launch, then loads every file in
-- lua/plugins/. Neovim 0.12 has a built-in manager (vim.pack) but lazy.nvim
-- still has far better lazy-loading and a much larger body of documentation.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true, notify = false },  -- check for updates quietly
  change_detection = { notify = false },
  ui = { border = "rounded" },
  -- No plugin here needs luarocks. Left enabled, lazy.nvim tries to bootstrap
  -- a private Lua 5.1 + luarocks under ~/.local/share/nvim/lazy-rocks and
  -- reports an ERROR in :checkhealth when that fails. Turning it off is the
  -- documented fix rather than a workaround.
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin",
      },
    },
  },
})
EOF
ok "lua/config/lazy.lua"

# ── 9. UI plugins ──────────────────────────────────────────────────────────
cat > "$NVIM/lua/plugins/ui.lua" <<'EOF'
-- ── appearance: colours, statusline, keybinding hints ──────────────────────
return {

  -- The colourscheme. priority 1000 + lazy = false makes it load before
  -- everything else, otherwise you get a flash of the default theme.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        neotree = true,
        telescope = { enabled = true },
        which_key = true,
        mason = true,
        indent_blankline = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Powerline statusline, using the same arrow glyphs as the shell prompt.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    -- catppuccin listed here so it is always loaded before the theme is built
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    opts = function()
      -- Catppuccin does not ship a lualine/themes/catppuccin.lua, so the
      -- string name "catppuccin" will not resolve — lualine reports
      -- "Theme `catppuccin` not found" and falls back to auto. It exposes a
      -- builder function instead, which returns the theme table directly.
      local theme = "auto"
      local ok, build = pcall(require, "catppuccin.utils.lualine")
      if ok then theme = build("mocha") end

      return {
        options = {
          theme = theme,
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "neo-tree", "lazy", "mason" } },
        },
        sections = {
          -- padding = { left = , right = } — the older left_padding and
          -- right_padding options are deprecated and trigger :LualineNotices
          lualine_a = {
            { "mode", separator = { left = "" }, padding = { left = 1, right = 2 } },
          },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
            },
          },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " " } },
          },
          lualine_x = {
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
            },
            -- which language servers are attached to this buffer
            {
              function()
                local names = {}
                for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
                  table.insert(names, client.name)
                end
                if #names == 0 then return "" end
                return "  " .. table.concat(names, ", ")
              end,
            },
          },
          lualine_y = { "filetype", "progress" },
          lualine_z = {
            { "location", separator = { right = "" }, padding = { left = 2, right = 1 } },
          },
        },
        extensions = { "neo-tree", "lazy", "mason", "quickfix" },
      }
    end,
  },

  -- Press <leader> and wait: a popup lists what you can press next.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = { border = "rounded" },
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>t", group = "terminal / toggle" },
      },
    },
  },

  -- Faint vertical lines showing indentation levels.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "help", "lazy", "mason", "neo-tree", "checkhealth", "man" },
      },
    },
  },
}
EOF
ok "lua/plugins/ui.lua"

# ── 10. editor plugins ─────────────────────────────────────────────────────
cat > "$NVIM/lua/plugins/editor.lua" <<'EOF'
-- ── finding, browsing, git, editing conveniences ───────────────────────────
return {

  -- Telescope: fuzzy finder, the editor counterpart to fzf in your shell.
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Compiled C sorter — much faster on big repositories. Needs `make`,
      -- which the installer put there via build-essential.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep in project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find open buffer" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Search help" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find word under cursor" },
      { "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    },
    opts = {
      defaults = {
        prompt_prefix = "  ",
        selection_caret = "▶ ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = { horizontal = { prompt_position = "top", preview_width = 0.55 } },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<Esc>"] = "close",
          },
        },
        file_ignore_patterns = { "%.git/", "node_modules/", "%.cache/" },
      },
      pickers = {
        find_files = { hidden = true },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- File tree down the left-hand side.
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>tf", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
      { "<leader>tr", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in tree" },
    },
    opts = {
      close_if_last_window = true,
      window = { width = 32 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".git", "node_modules" },
        },
      },
    },
  },

  -- Git status in the sign column, plus staging and blame.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end
        -- gitsigns 1.0 replaced next_hunk/prev_hunk with nav_hunk; support both
        local function nav(direction)
          return function()
            if gs.nav_hunk then
              gs.nav_hunk(direction)
            else
              gs[direction .. "_hunk"]()
            end
          end
        end
        map("n", "]h", nav("next"), "Next git hunk")
        map("n", "[h", nav("prev"), "Previous git hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gd", gs.diffthis, "Diff this file")
      end,
    },
  },

  -- Automatically close brackets and quotes.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- cs"' changes surrounding quotes, ysiw) wraps a word in brackets, and so on.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Highlight and list TODO / FIXME / HACK comments.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODO comments" },
    },
  },
}
EOF
ok "lua/plugins/editor.lua"

# ── 11. LSP ────────────────────────────────────────────────────────────────
cat > "$NVIM/lua/plugins/lsp.lua" <<'EOF'
-- ── language servers ───────────────────────────────────────────────────────
-- Neovim 0.11 introduced a native LSP API, and the old require("lspconfig")
-- framework is deprecated. So:
--
--   * nvim-lspconfig is still installed, but only as a *data* package — it
--     ships the per-server defaults (command, filetypes, root markers) in its
--     lsp/ directory, which vim.lsp picks up automatically.
--   * mason.nvim downloads the server binaries.
--   * mason-lspconfig v2 calls vim.lsp.enable() for whatever mason installed.
--   * vim.lsp.config(name, {...}) below only adds our own overrides.
--
-- Do not add require("lspconfig").xxx.setup() calls; that API is on its way out.

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- Installed automatically on first launch. Add or remove freely, then
      -- restart Neovim. :Mason shows everything available.
      ensure_installed = {
        -- config, scripting, docs
        "lua_ls", "bashls", "marksman", "jsonls", "yamlls",
        -- python
        "pyright", "ruff",
        -- web
        "ts_ls", "html", "cssls", "tailwindcss",
        -- compiled
        "rust_analyzer", "clangd",
      },
      -- v2 default: vim.lsp.enable() each installed server for us.
      automatic_enable = true,
    },
    config = function(_, opts)
      -- Let blink.cmp advertise its completion capabilities to every server.
      local has_blink, blink = pcall(require, "blink.cmp")
      if has_blink then
        vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities({}, true) })
      end

      -- Per-server overrides. Everything not mentioned uses nvim-lspconfig's
      -- shipped defaults, which are almost always what you want.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            -- stop it warning that `vim` is undefined in your own config
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = { yaml = { keyOrdering = false } },
      })

      require("mason-lspconfig").setup(opts)
    end,
  },

  -- Buffer-local keymaps, applied whenever a server attaches. Neovim 0.11+
  -- already provides grn (rename), gra (code action), grr (references) and K
  -- (hover) out of the box; these are the more familiar aliases.
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("cfg_lsp_attach", { clear = true }),
        callback = function(event)
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", "<cmd>Telescope lsp_definitions<cr>", "Go to definition")
          map("gr", "<cmd>Telescope lsp_references<cr>", "List references")
          map("gI", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation")
          map("gy", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<C-k>", vim.lsp.buf.signature_help, "Signature help", "i")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols")

          -- Inlay hints, if this server supports them
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>th", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
            end, "Toggle inlay hints")
          end
        end,
      })
    end,
  },
}
EOF
ok "lua/plugins/lsp.lua"

# ── 12. completion ─────────────────────────────────────────────────────────
cat > "$NVIM/lua/plugins/completion.lua" <<'EOF'
-- ── autocompletion ─────────────────────────────────────────────────────────
-- blink.cmp rather than nvim-cmp: sources for LSP, paths, snippets and the
-- current buffer are built in rather than being separate plugins, and it
-- updates on every keystroke instead of debouncing.
return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "*",       -- use the latest tagged release, which ships a prebuilt binary
    opts = {
      keymap = {
        preset = "default",          -- <C-space> opens, <C-n>/<C-p> cycle, <C-e> cancels
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        menu = { border = "rounded" },
        ghost_text = { enabled = false },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
EOF
ok "lua/plugins/completion.lua"

# ── 13. formatting ─────────────────────────────────────────────────────────
cat > "$NVIM/lua/plugins/format.lua" <<'EOF'
-- ── formatting ─────────────────────────────────────────────────────────────
-- conform.nvim runs a dedicated formatter where one is installed, and falls
-- back to the language server's own formatting otherwise — so this works out
-- of the box, and gets better as you install formatters through :Mason.
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        python = { "ruff_format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        rust = { "rustfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function(bufnr)
        -- :FormatDisable turns this off for a session, :FormatEnable restores
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
    init = function()
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "Disable format on save (! for this buffer only)", bang = true })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable format on save" })
    end,
  },
}
EOF
ok "lua/plugins/format.lua"

# ── 14. hook into the shell ────────────────────────────────────────────────
step "Wiring Neovim into the shell"
if [[ -f "$HOME/.config/zsh/aliases.zsh" ]] \
   && ! grep -q "alias vim=" "$HOME/.config/zsh/aliases.zsh"; then
  cat >> "$HOME/.config/zsh/aliases.zsh" <<'ALIAS_EOF'

# ── neovim ─────────────────────────────────────────────────────────────────
if command -v nvim >/dev/null; then
  alias vim='nvim'
  alias vi='nvim'
  alias v='nvim'
  # open the shell config in neovim
  alias nvimrc='nvim ~/.config/nvim/init.lua'
fi
ALIAS_EOF
  ok "added vim/vi/v aliases to ~/.config/zsh/aliases.zsh"
elif [[ -f "$HOME/.config/zsh/aliases.zsh" ]]; then
  ok "shell aliases already present"
else
  warn "no ~/.config/zsh/aliases.zsh found — run setup-terminal.sh first for the shell side"
fi

# The terminal setup picks EDITOR up dynamically, so nvim becomes the default
# editor for git, crontab and so on as soon as it is on PATH.
if [[ -f "$HOME/.zshrc" ]] && grep -q 'command -v nvim' "$HOME/.zshrc"; then
  ok "EDITOR will resolve to nvim automatically"
else
  warn "set EDITOR=nvim in ~/.zshrc.local to make it your default editor"
fi

# ── 15. first-run plugin sync ──────────────────────────────────────────────
step "Installing plugins (this takes a minute on first run)"
if nvim --headless "+Lazy! sync" +qa 2>&1 | tail -3; then
  ok "plugins installed"
else
  warn "plugin sync reported problems — open nvim and run :Lazy to inspect"
fi

# ── done ───────────────────────────────────────────────────────────────────
cat <<FINAL

$B$GRN Done.$R  Start it with:  ${B}nvim${R}

 ${B}First launch${R} downloads language servers in the background. ${B}:Mason${R}
 shows progress, ${B}:checkhealth${R} flags anything missing.

 ${B}Essential keys${R}   ${DIM}(leader is Space)${R}
   ${B}<leader><leader>${R}  find files          ${B}<leader>fg${R}  grep the project
   ${B}<leader>tf${R}        toggle file tree    ${B}<leader>ca${R}  code action
   ${B}gd${R}                go to definition    ${B}K${R}           hover docs
   ${B}<leader>cr${R}        rename symbol       ${B}<leader>cf${R}  format
   Press ${B}<leader>${R} and pause — which-key lists everything else.

 ${B}Config${R}  $(tilde "$NVIM")/  — start with lua/config/options.lua
 ${B}Plugins${R} one file per concern in lua/plugins/

FINAL

