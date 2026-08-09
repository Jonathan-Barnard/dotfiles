-- ─────────────────────────────────────────────────────────────
--  Options
-- ─────────────────────────────────────────────────────────────
local opt = vim.opt

-- This file is a flat list of assignments with the comments aligned into a
-- column, which is the only thing stylua would change here. Nothing else in
-- it needs formatting, so the whole body opts out.
-- stylua: ignore start

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

-- ── Completion ───────────────────────────────────────────────
-- 0.12 completes in insert mode on its own, so there's no nvim-cmp or
-- blink here. 'complete' stays at its default globally and is set per
-- buffer on LspAttach — no reason for every buffer to scan omnifunc.
opt.autocomplete = true
opt.autocompletedelay = 50      -- 0 pops the menu up mid-keystroke
opt.completeopt = "menu,menuone,popup,fuzzy,noselect"

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

-- stylua: ignore end
