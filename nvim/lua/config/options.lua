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
