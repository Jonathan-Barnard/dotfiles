-- ─────────────────────────────────────────────────────────────
--  lualine  ·  powerline statusline
--
--  The theme below is hand-written from starship.toml's
--  [palettes.gruvbox_dark] rather than lualine's bundled gruvbox,
--  so the prompt and the statusline are the same object. Note
--  these are the *normal* gruvbox variants (#458588, #d65d0e),
--  not the bright ones — that's what starship uses.
-- ─────────────────────────────────────────────────────────────
local colors = {
  fg0 = "#fbf1c7",
  fg1 = "#ebdbb2",
  bg1 = "#3c3836",
  bg3 = "#665c54",
  blue = "#458588",
  aqua = "#689d6a",
  green = "#98971a",
  orange = "#d65d0e",
  purple = "#b16286",
  red = "#cc241d",
  yellow = "#d79921",
  grey = "#928374",
}

-- Modes not listed here fall back to `normal`.
local theme = {
  normal = {
    a = { fg = colors.fg0, bg = colors.orange, gui = "bold" },
    b = { fg = colors.fg0, bg = colors.aqua },
    c = { fg = colors.fg1, bg = colors.bg1 },
    x = { fg = colors.fg0, bg = colors.blue },
    y = { fg = colors.fg1, bg = colors.bg3 },
    z = { fg = colors.fg1, bg = colors.bg1 },
  },
  insert = { a = { fg = colors.fg0, bg = colors.green, gui = "bold" } },
  visual = { a = { fg = colors.fg0, bg = colors.yellow, gui = "bold" } },
  replace = { a = { fg = colors.fg0, bg = colors.red, gui = "bold" } },
  command = { a = { fg = colors.fg0, bg = colors.aqua, gui = "bold" } },
  terminal = { a = { fg = colors.fg0, bg = colors.blue, gui = "bold" } },
  inactive = {
    a = { fg = colors.grey, bg = colors.bg1 },
    b = { fg = colors.grey, bg = colors.bg1 },
    c = { fg = colors.grey, bg = colors.bg1 },
  },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = theme,
        globalstatus = true, -- pairs with laststatus = 3
        -- Tabs only exist here to park long-running terminals in, so
        -- the tabline stays hidden until there's a second one.
        always_show_tabline = false,
        -- U+E0B0 / U+E0B2, the same glyphs starship uses. The
        -- JetBrainsMono Nerd Font cask in the Brewfile provides them.
        section_separators = { left = "", right = "" },
        -- Starship has no dividers inside a segment, so neither do we.
        component_separators = { left = "", right = "" },
      },
      sections = {
        -- The rounded end caps (U+E0B6 / U+E0B4) match the ones
        -- starship puts at either end of its prompt.
        lualine_a = {
          { "mode", separator = { left = "", right = "" } },
        },
        lualine_b = {
          { "branch", icon = "" },
          { "diff", symbols = { added = "+", modified = "!", removed = "✘" } },
        },
        lualine_c = {
          {
            "filename",
            path = 1, -- relative to cwd
            symbols = { modified = " ●", readonly = " 󰌾", unnamed = "[No Name]" },
            -- A terminal buffer is named term://<cwd>//<pid>:/bin/zsh,
            -- which path = 1 would print in full. Show the shell instead.
            fmt = function(name)
              if vim.bo.buftype ~= "terminal" then
                return name
              end
              -- b:term_title starts out as that same term:// string and
              -- only becomes useful once the program sets an OSC title.
              local title = vim.b.term_title
              if not title or title:find("^term://") then
                title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
              end
              return " " .. title
            end,
          },
        },
        lualine_x = {
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
            separator = { left = "" },
          },
          { "filetype", separator = { left = "" } },
        },
        lualine_y = { "encoding", "fileformat" },
        lualine_z = {
          "progress",
          { "location", separator = { right = "" } },
        },
      },
      -- lualine renders the whole tabline itself and colours it from the
      -- theme above, so gruvbox's TabLine* groups never get drawn — no
      -- overrides needed in colorscheme.lua.
      tabline = {
        lualine_a = {
          {
            "tabs",
            mode = 2, -- number + name; a terminal tab reads "2 zsh"
            path = 0,
            -- The active tab picks up lualine_a's orange, so the tabline
            -- and the statusline read as the same object. This component
            -- draws separators *between* tabs from section_separators
            -- above; a component-level `separator` would be ignored.
            tabs_color = {
              active = { fg = colors.fg0, bg = colors.orange, gui = "bold" },
              inactive = { fg = colors.grey, bg = colors.bg1 },
            },
          },
        },
      },
      -- Only names under lualine/extensions/ are valid here.
      extensions = { "lazy", "neo-tree" },
    },
  },
}
