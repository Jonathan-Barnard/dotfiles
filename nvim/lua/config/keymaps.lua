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
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", "Explorer: file tree")

-- ── Windows ──────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", "Go to left window")
map("n", "<C-j>", "<C-w>j", "Go to lower window")
map("n", "<C-k>", "<C-w>k", "Go to upper window")
map("n", "<C-l>", "<C-w>l", "Go to right window")

map("n", "<M-Up>", "<cmd>resize +2<CR>", "Increase window height")
map("n", "<M-Down>", "<cmd>resize -2<CR>", "Decrease window height")
map("n", "<M-Left>", "<cmd>vertical resize -2<CR>", "Decrease window width")
map("n", "<M-Right>", "<cmd>vertical resize +2<CR>", "Increase window width")

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
-- Built-in :terminal, so every press is a *new* shell rather than
-- one window you toggle. `+terminal` makes the split and the shell
-- a single command. Park a long-running one in its own tab with
-- <leader>tm, then switch tabs with gt / gT.
map("n", "<leader>tt", "<cmd>15split +terminal<CR>", "Terminal: bottom split")
map("n", "<leader>tv", "<cmd>vsplit +terminal<CR>", "Terminal: split right")
map("n", "<leader>tT", "<cmd>tabnew +terminal<CR>", "Terminal: new tab")
map("n", "<leader>tm", "<C-w>T", "Move window to a new tab")

-- Only <Esc><Esc> is mapped in terminal mode: Ctrl+L (clear), Ctrl+J
-- and Ctrl+K stay with zsh, as do Alt+arrows (word motions). Leave
-- terminal mode first, then the usual <C-hjkl> / <M-arrows> apply.
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Leave terminal mode")
