-- ─────────────────────────────────────────────────────────────
--  Neovim  ·  Gruvbox Dark Hard
--  Matches ghostty/config and starship/starship.toml
-- ─────────────────────────────────────────────────────────────

-- Leader must be set before lazy.nvim loads, or plugin mappings
-- get bound against the old leader.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
