-- ─────────────────────────────────────────────────────────────
--  Gruvbox Dark Hard
--  contrast = "hard" gives #1d2021 — the same background as
--  ghostty/config. Leave transparent_mode off so Ghostty's
--  background-opacity applies evenly to shell and editor.
-- ─────────────────────────────────────────────────────────────
return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = false,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      inverse = true,
      contrast = "hard", -- "hard" | "soft" | ""
      palette_overrides = {},
      dim_inactive = false,
      transparent_mode = false,
      overrides = {
        -- softer, more modern chrome
        SignColumn = { bg = "NONE" },
        GruvboxRedSign = { bg = "NONE" },
        GruvboxGreenSign = { bg = "NONE" },
        GruvboxYellowSign = { bg = "NONE" },
        GruvboxBlueSign = { bg = "NONE" },
        GruvboxPurpleSign = { bg = "NONE" },
        GruvboxAquaSign = { bg = "NONE" },
        GruvboxOrangeSign = { bg = "NONE" },
        CursorLine = { bg = "#282828" },
        CursorLineNr = { fg = "#fabd2f", bold = true },
        LineNr = { fg = "#665c54" },
        WinSeparator = { fg = "#3c3836", bg = "NONE" },
        FloatBorder = { fg = "#665c54", bg = "NONE" },
        NormalFloat = { bg = "#1d2021" },
        Visual = { bg = "#3c3836" },
        -- #fe8019 is ghostty's cursor-color
        Search = { fg = "#1d2021", bg = "#fabd2f" },
        IncSearch = { fg = "#1d2021", bg = "#fe8019" },
      },
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },
}
