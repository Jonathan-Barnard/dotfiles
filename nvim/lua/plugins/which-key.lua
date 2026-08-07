-- ─────────────────────────────────────────────────────────────
--  which-key  ·  popup hints for pending keybinds
--
--  It reads the `desc` you already pass to map() in
--  config/keymaps.lua, so single mappings need nothing here.
--  Only *groups* (a prefix that isn't a mapping on its own,
--  like <leader>s) have to be declared, in `spec` below.
--
--  Colours live in plugins/colorscheme.lua with the rest of the
--  gruvbox overrides.
-- ─────────────────────────────────────────────────────────────
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- "helix" is a small rounded panel in the bottom-right; it
      -- matches winborder = "rounded". The alternatives are
      -- "modern" (wide, centred) and "classic" (full-width, no border).
      preset = "modern",

      -- which-key has its own timer and ignores timeoutlen, so
      -- opt.timeoutlen = 400 still governs mapping resolution only.
      delay = function(ctx)
        -- 0 for marks/registers/spelling — those lists are the
        -- whole point of pressing the key.
        return ctx.plugin and 0 or 300
      end,

      spec = {
        { "<leader>b", group = "buffer", icon = { icon = "󰓩 ", color = "blue" } },
        { "<leader>s", group = "split", icon = { icon = " ", color = "green" } },
      },

      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true, suggestions = 20 },
        presets = {
          operators = true,    -- d, y, c …
          motions = true,
          text_objects = true,
          windows = true,      -- <C-w>
          nav = true,
          z = true,
          g = true,
        },
      },

      icons = {
        -- have_nerd_font is set in init.lua; JetBrainsMono Nerd Font
        -- comes from the Brewfile.
        mappings = vim.g.have_nerd_font,
        breadcrumb = "»",
        separator = "➜",
        group = "",
      },

      win = { padding = { 1, 2 } },
      layout = { width = { min = 20 }, spacing = 3 },

      -- Sort local (buffer) mappings first, then keep the order I
      -- wrote them in keymaps.lua rather than alphabetising.
      sort = { "local", "order", "group", "alphanum", "mod" },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer-local keymaps",
      },
    },
  },
}
