-- ── Leader keys (must be set before lazy.nvim loads) ─────────
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- ── UI ───────────────────────────────────────────────────────
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false          -- lualine already shows it
opt.laststatus = 3            -- one global statusline
opt.cmdheight = 1
opt.pumheight = 12
opt.pumblend = 10
opt.winblend = 0
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣", extends = "❯", precedes = "❮" }
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "" }
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.conceallevel = 0

-- ── Editing ──────────────────────────────────────────────────
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.autoindent = true
opt.shiftround = true
opt.virtualedit = "block"
opt.formatoptions = "jcroqlnt"

-- ── Search ───────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"      -- live :s preview
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- ── Files / persistence ──────────────────────────────────────
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.timeoutlen = 400
opt.confirm = true
opt.autowrite = true

-- ── Completion / clipboard / misc ────────────────────────────
opt.completeopt = { "menu", "menuone", "noselect" }
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.wildmode = "longest:full,full"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "folds" }

-- ── Folding (treesitter-powered) ─────────────────────────────
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- ── Diagnostics ──────────────────────────────────────────────
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
})

-- ── Providers we don't need (faster startup) ─────────────────
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
