-- ── plugin manager ─────────────────────────────────────────────────────────
-- lazy.nvim installs itself on first launch, then loads every file in
-- lua/plugins/. Neovim 0.12 has a built-in manager (vim.pack) but lazy.nvim
-- still has far better lazy-loading and a much larger body of documentation.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
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
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true, notify = false },  -- check for updates quietly
  change_detection = { notify = false },
  ui = { border = "rounded" },
  -- No plugin here needs luarocks. Left enabled, lazy.nvim tries to bootstrap
  -- a private Lua 5.1 + luarocks under ~/.local/share/nvim/lazy-rocks and
  -- reports an ERROR in :checkhealth when that fails. Turning it off is the
  -- documented fix rather than a workaround.
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin",
      },
    },
  },
})
