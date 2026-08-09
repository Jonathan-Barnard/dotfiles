-- ─────────────────────────────────────────────────────────────
--  lazy.nvim  ·  plugin manager
--
--  To add a plugin: create nvim/lua/plugins/<name>.lua returning
--  a spec table. It is picked up automatically — nothing here
--  needs editing.
-- ─────────────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- stylua: ignore start
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable", "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  -- stylua: ignore end
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "gruvbox", "habamax" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
  -- Nothing here needs luarocks; without this :checkhealth complains
  -- about a hererocks install that will never be used.
  rocks = { enabled = false },
  performance = {
    rtp = {
      -- netrwPlugin is off — neo-tree is the file browser now.
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
