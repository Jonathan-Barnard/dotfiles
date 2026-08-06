-- ─────────────────────────────────────────────────────────────
--  Options
-- ─────────────────────────────────────────────────────────────
local opt = vim.opt

-- ── UI ───────────────────────────────────────────────────────
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"          -- always on, so text doesn't jump
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true            -- if wrap is turned on, break at words
opt.termguicolors = true
opt.background = "dark"
opt.showmode = false            -- lualine already shows the mode
opt.laststatus = 3              -- one statusline for the whole window
opt.pumheight = 10
opt.winborder = "rounded"       -- matches FZF_DEFAULT_OPTS --border=rounded

opt.list = true
opt.listchars = { tab = "󰇘 ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
opt.fillchars = { eob = " ", vert = "│", horiz = "─", fold = " " }

-- ── Editing ──────────────────────────────────────────────────
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true
opt.smartindent = true
opt.clipboard = "unnamedplus"   -- share with the macOS clipboard
opt.mouse = "a"
opt.confirm = true              -- ask instead of failing on :q with changes

-- ── Search ───────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true            -- …unless the pattern has a capital
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "split"        -- live preview of :s

-- ── Splits ───────────────────────────────────────────────────
opt.splitright = true
opt.splitbelow = true

-- ── Files ────────────────────────────────────────────────────
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.swapfile = false
opt.backup = false
opt.updatetime = 250
opt.timeoutlen = 400

-- ── netrw ────────────────────────────────────────────────────
-- The only file browser here until a plugin replaces it (<leader>e).
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3       -- tree view
vim.g.netrw_winsize = 25
