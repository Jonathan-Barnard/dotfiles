-- ═══════════════════════════════════════════════════════════════════════════
--  Neovim entry point.
--  Each require below maps to a file in lua/config/. Read them in this order.
-- ═══════════════════════════════════════════════════════════════════════════

-- The leader key must be set before lazy.nvim loads, or plugin mappings that
-- use <leader> will bind to the wrong key.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
