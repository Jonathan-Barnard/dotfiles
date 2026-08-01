-- ─────────────────────────────────────────────────────────────
--  Neovim  ·  Gruvbox + lazy.nvim
--  entry point: options -> keymaps -> autocmds -> plugins
-- ─────────────────────────────────────────────────────────────

if vim.fn.has("nvim-0.11") == 0 then
  vim.notify("This config targets Neovim >= 0.11. Please upgrade.", vim.log.levels.WARN)
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
