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
        -- which-key links these with default = true, so anything set
        -- here wins and survives its ColorScheme re-link.
        WhichKeyNormal = { bg = "#1d2021" },
        WhichKeyBorder = { fg = "#665c54", bg = "NONE" },
        WhichKeyTitle = { fg = "#fabd2f", bold = true },
        WhichKey = { fg = "#fe8019" },          -- the pending key itself
        WhichKeyGroup = { fg = "#83a598" },     -- a prefix with more behind it
        WhichKeyDesc = { fg = "#ebdbb2" },
        WhichKeySeparator = { fg = "#665c54" },
        WhichKeyValue = { fg = "#928374" },     -- register/mark contents
        -- neo-tree: same chrome as the floats above so the sidebar
        -- doesn't read as a different application.
        NeoTreeNormal = { bg = "#1d2021" },
        NeoTreeNormalNC = { bg = "#1d2021" },
        NeoTreeEndOfBuffer = { fg = "#1d2021", bg = "#1d2021" },
        NeoTreeWinSeparator = { fg = "#3c3836", bg = "NONE" },
        NeoTreeFloatBorder = { fg = "#665c54", bg = "NONE" },
        NeoTreeFloatTitle = { fg = "#fabd2f", bold = true },
        NeoTreeCursorLine = { bg = "#282828" },
        NeoTreeIndentMarker = { fg = "#3c3836" },
        NeoTreeExpander = { fg = "#665c54" },
        NeoTreeRootName = { fg = "#fe8019", bold = true },
        NeoTreeDirectoryName = { fg = "#83a598" },
        NeoTreeDirectoryIcon = { fg = "#83a598" },
        NeoTreeFileNameOpened = { fg = "#fabd2f" },
        NeoTreeDotfile = { fg = "#928374" },
        -- the source_selector winbar tabs
        NeoTreeTabActive = { fg = "#fe8019", bg = "#1d2021", bold = true },
        NeoTreeTabInactive = { fg = "#928374", bg = "#282828" },
        NeoTreeTabSeparatorActive = { fg = "#1d2021", bg = "#1d2021" },
        NeoTreeTabSeparatorInactive = { fg = "#282828", bg = "#282828" },
        -- git columns, matching lualine's diff colours
        NeoTreeGitAdded = { fg = "#b8bb26" },
        NeoTreeGitModified = { fg = "#fabd2f" },
        NeoTreeGitDeleted = { fg = "#fb4934" },
        NeoTreeGitRenamed = { fg = "#d3869b" },
        NeoTreeGitUntracked = { fg = "#928374" },
        NeoTreeGitConflict = { fg = "#fb4934", bold = true },
        NeoTreeGitIgnored = { fg = "#665c54" },
      },
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },
}
