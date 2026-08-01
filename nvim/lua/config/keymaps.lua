local map = vim.keymap.set

-- ── Basics ───────────────────────────────────────────────────
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>confirm q<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>confirm qall<CR>", { desc = "Quit all" })

-- ── Better up/down on wrapped lines ──────────────────────────
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- ── Window navigation ────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- ── Window resize ────────────────────────────────────────────
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- ── Splits ───────────────────────────────────────────────────
map("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Split vertically" })
map("n", "<leader>-", "<cmd>split<CR>", { desc = "Split horizontally" })

-- ── Buffers ──────────────────────────────────────────────────
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete other buffers" })
map("n", "<leader>`", "<cmd>e #<CR>", { desc = "Alternate buffer" })

-- ── Move lines ───────────────────────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ── Indent without losing selection ──────────────────────────
map("v", "<", "<gv")
map("v", ">", ">gv")

-- ── Keep the cursor centred ──────────────────────────────────
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- ── Paste/delete without clobbering the register ─────────────
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- ── Diagnostics ──────────────────────────────────────────────
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })

-- ── Quickfix ─────────────────────────────────────────────────
map("n", "<leader>xq", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })

-- ── Terminal ─────────────────────────────────────────────────
map("t", "<C-\\><C-n>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- ── Lazy / Mason ─────────────────────────────────────────────
map("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy" })
map("n", "<leader>M", "<cmd>Mason<CR>", { desc = "Mason" })
