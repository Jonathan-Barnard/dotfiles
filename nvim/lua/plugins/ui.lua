-- ── appearance: colours, statusline, keybinding hints ──────────────────────
return {

  -- The colourscheme. priority 1000 + lazy = false makes it load before
  -- everything else, otherwise you get a flash of the default theme.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        neotree = true,
        telescope = { enabled = true },
        which_key = true,
        mason = true,
        indent_blankline = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Powerline statusline, using the same arrow glyphs as the shell prompt.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    -- catppuccin listed here so it is always loaded before the theme is built
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    opts = function()
      -- Catppuccin does not ship a lualine/themes/catppuccin.lua, so the
      -- string name "catppuccin" will not resolve — lualine reports
      -- "Theme `catppuccin` not found" and falls back to auto. It exposes a
      -- builder function instead, which returns the theme table directly.
      local theme = "auto"
      local ok, build = pcall(require, "catppuccin.utils.lualine")
      if ok then theme = build("mocha") end

      return {
        options = {
          theme = theme,
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "neo-tree", "lazy", "mason" } },
        },
        sections = {
          -- padding = { left = , right = } — the older left_padding and
          -- right_padding options are deprecated and trigger :LualineNotices
          lualine_a = {
            { "mode", separator = { left = "" }, padding = { left = 1, right = 2 } },
          },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
            },
          },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " " } },
          },
          lualine_x = {
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
            },
            -- which language servers are attached to this buffer
            {
              function()
                local names = {}
                for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
                  table.insert(names, client.name)
                end
                if #names == 0 then return "" end
                return "  " .. table.concat(names, ", ")
              end,
            },
          },
          lualine_y = { "filetype", "progress" },
          lualine_z = {
            { "location", separator = { right = "" }, padding = { left = 2, right = 1 } },
          },
        },
        extensions = { "neo-tree", "lazy", "mason", "quickfix" },
      }
    end,
  },

  -- Press <leader> and wait: a popup lists what you can press next.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = { border = "rounded" },
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>m", group = "move window" },
        { "<leader>t", group = "terminal" },
        { "<leader><Tab>", group = "tab" },
      },
    },
  },

  -- Faint vertical lines showing indentation levels.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "help", "lazy", "mason", "neo-tree", "checkhealth", "man" },
      },
    },
  },
}
