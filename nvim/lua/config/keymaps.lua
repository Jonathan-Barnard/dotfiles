-- ── key bindings ───────────────────────────────────────────────────────────
-- Leader is Space. Plugin-specific maps live with their plugin, in
-- lua/plugins/, so that they load only when that plugin does.

local map = function(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { silent = true, desc = desc }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- editing
map("n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")

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

-- save
map("n", "<leader>w", "<cmd>write<cr>", "Save file")
map("n", "<leader>W", "<cmd>wall<cr>", "Save all files")

-- quit
map("n", "<leader>q", "<cmd>quit<cr>", "Quit window")
map("n", "<leader>Q", "<cmd>qall!<cr>", "Quit everything, discarding changes")

-- copies
map({ "n", "v" }, "<leader>y", '"+y', "Yank to Windows clipboard")
map("n", "<leader>Y", '"+Y', "Yank line to Windows clipboard")

-- pastes
map({ "n", "v" }, "<leader>p", '"+p', "Paste from Windows clipboard")

-- paste over a selection without losing what you had yanked
map("v", "p", '"_dP', "Paste without clobbering the register")

-- splits
map("n", "<leader>-", "<cmd>split<cr>", "Split horizontally")
map("n", "<leader>|", "<cmd>vsplit<cr>", "Split vertically")

-- window moves
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

-- window rearranging: these all wrap plain vim <C-w> commands, they just
-- give them a memorable, which-key-discoverable home
map("n", "<leader>mh", "<C-w>H", "Move window to far left")
map("n", "<leader>mj", "<C-w>J", "Move window to bottom")
map("n", "<leader>mk", "<C-w>K", "Move window to top")
map("n", "<leader>ml", "<C-w>L", "Move window to far right")
map("n", "<leader>mr", "<C-w>r", "Rotate windows")
map("n", "<leader>mx", "<C-w>x", "Swap window with next")
map("n", "<leader>mo", "<C-w>o", "Maximise window (close others)")
map("n", "<leader>m=", "<C-w>=", "Equalise window sizes")

-- zoom the current window to fill the tab, press again to restore. Zoom
-- state is tracked per-tab so it doesn't leak across tab pages.
local function toggle_zoom()
  if vim.t.zoomed then
    vim.cmd.wincmd("=")
    vim.t.zoomed = false
  else
    vim.cmd.wincmd("_")
    vim.cmd.wincmd("|")
    vim.t.zoomed = true
  end
end
map("n", "<leader>z", toggle_zoom, "Toggle zoom on window")

-- tabs, same h=previous/l=next convention as the buffer cycling below
map("n", "<leader><Tab>n", "<cmd>tabnew<cr>", "New tab")
map("n", "<leader><Tab>c", "<cmd>tabclose<cr>", "Close tab")
map("n", "<leader><Tab>o", "<cmd>tabonly<cr>", "Close other tabs")
map("n", "<leader><Tab>h", "<cmd>tabprevious<cr>", "Previous tab")
map("n", "<leader><Tab>l", "<cmd>tabnext<cr>", "Next tab")

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", "Previous buffer")
map("n", "<S-l>", "<cmd>bnext<cr>", "Next buffer")
map("n", "<leader>bb", "<cmd>b#<cr>", "Switch to last buffer")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Close buffer")
map("n", "<leader>bD", "<cmd>bdelete!<cr>", "Close buffer, discarding changes")

local function close_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then vim.api.nvim_buf_delete(buf, {}) end
  end
end
map("n", "<leader>bo", close_other_buffers, "Close other buffers")

-- term: Esc twice to get back to normal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")

-- A fresh docked terminal every time: split along the bottom and spawn a
-- new shell. Quit it like any other window (<leader>q) when you're done
-- with it, or <C-w>T to break it out into its own tab if you want it to
-- keep running.
local function open_terminal()
  vim.cmd("split")
  vim.cmd.terminal()
  vim.cmd.startinsert()
end
map("n", "<leader>tt", open_terminal, "Open a new terminal (docked at bottom)")

-- lua edit: quick access to this config
map("n", "<leader>,", "<cmd>edit $MYVIMRC<cr>", "Edit init.lua")

-- diagnostics
map("n", "<leader>dd", vim.diagnostic.open_float, "Show diagnostic under cursor")
map("n", "<leader>dl", vim.diagnostic.setloclist, "Diagnostics to location list")
