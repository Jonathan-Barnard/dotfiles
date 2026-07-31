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
