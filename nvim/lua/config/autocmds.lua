-- ─────────────────────────────────────────────────────────────
--  Autocommands
-- ─────────────────────────────────────────────────────────────
local function augroup(name)
  return vim.api.nvim_create_augroup("dotfiles_" .. name, { clear = true })
end

-- Briefly highlight whatever was just yanked.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Reopen a file where you left it.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(event.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Keep splits proportional when the terminal window is resized.
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  command = "wincmd =",
})

-- Strip the editor chrome from :terminal buffers — none of it means
-- anything over shell output — and start typing straight away.
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("term_open"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.cursorline = false
    -- stylua: ignore start
    vim.opt_local.list = false      -- listchars would mark up the output
    vim.opt_local.scrolloff = 0     -- the global 8 makes a terminal jump
    -- stylua: ignore end
    vim.cmd.startinsert()
  end,
})

-- TermOpen only, not BufEnter: coming back to a terminal leaves you in
-- normal mode so you can scroll back and yank.

-- A clean `exit` closes its own split. A failure stays on screen showing
-- [Process exited N] so you can read it.
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup("term_close"),
  callback = function(event)
    if vim.v.event.status == 0 and vim.api.nvim_buf_is_valid(event.buf) then
      pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
    end
  end,
})
