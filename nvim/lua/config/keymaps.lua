-- ─────────────────────────────────────────────────────────────
--  Keymaps  ·  leader is <Space>
-- ─────────────────────────────────────────────────────────────
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- ── General ──────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
map("n", "<leader>w", "<cmd>write<CR>", "Write file")
map("n", "<leader>q", "<cmd>quit<CR>", "Quit window")
map("n", "<leader>Q", "<cmd>quitall<CR>", "Quit all")
map("n", "<leader>l", "<cmd>Lazy<CR>", "Lazy: plugin manager")
map("n", "<leader>e", "<cmd>Explore<CR>", "Explore: file browser")

-- ── Windows ──────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", "Go to left window")
map("n", "<C-j>", "<C-w>j", "Go to lower window")
map("n", "<C-k>", "<C-w>k", "Go to upper window")
map("n", "<C-l>", "<C-w>l", "Go to right window")

map("n", "<C-Up>", "<cmd>resize +2<CR>", "Increase window height")
map("n", "<C-Down>", "<cmd>resize -2<CR>", "Decrease window height")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Decrease window width")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Increase window width")

-- Mirrors the Ghostty split binds (⌘D / ⌘⇧D / ⌘⇧W / ⌘⇧=)
map("n", "<leader>sv", "<cmd>vsplit<CR>", "Split right")
map("n", "<leader>sh", "<cmd>split<CR>", "Split down")
map("n", "<leader>sc", "<cmd>close<CR>", "Close split")
map("n", "<leader>s=", "<C-w>=", "Equalise splits")

-- ── Buffers ──────────────────────────────────────────────────
map("n", "<S-h>", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<S-l>", "<cmd>bnext<CR>", "Next buffer")
map("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")

-- ── Moving around ────────────────────────────────────────────
-- Keep the cursor centred so you don't lose your place.
map("n", "<C-d>", "<C-d>zz", "Half page down")
map("n", "<C-u>", "<C-u>zz", "Half page up")
map("n", "n", "nzzzv", "Next search result")
map("n", "N", "Nzzzv", "Previous search result")

-- ── Visual mode ──────────────────────────────────────────────
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")
map("v", "<", "<gv", "Indent left and keep selection")
map("v", ">", ">gv", "Indent right and keep selection")
map("v", "p", '"_dP', "Paste without clobbering the register")

-- ── Terminal ─────────────────────────────────────────────────
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Leave terminal mode")
