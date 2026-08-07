-- ── automatic behaviours ───────────────────────────────────────────────────

local augroup = function(name)
  return vim.api.nvim_create_augroup("cfg_" .. name, { clear = true })
end

-- Briefly highlight whatever you just yanked, so you can see what you got.
-- vim.highlight was renamed vim.hl in 0.11; fall back for older versions.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    local hl = vim.hl or vim.highlight
    hl.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- Reopen a file where you left off.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then return end
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Create missing parent directories when saving a new file.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("mkdir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Let q close throwaway windows, rather than needing :q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "man", "qf", "checkhealth", "lspinfo", "startuptime", "query" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Prose settings for text filetypes: wrap at the window edge, spellcheck on.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_gb"
  end,
})

-- Equalise split sizes when the terminal window is resized.
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize"),
  command = "tabdo wincmd =",
})

-- Close a terminal's window automatically when the shell exits cleanly,
-- rather than leaving a dead "[Process exited 0]" buffer behind.
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup("term_close"),
  callback = function(event)
    if vim.v.event.status == 0 then
      pcall(vim.api.nvim_win_close, vim.fn.bufwinid(event.buf), false)
    end
  end,
})
