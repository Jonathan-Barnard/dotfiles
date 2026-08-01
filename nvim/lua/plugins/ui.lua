return {
  -- ── Icons ──────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  -- ── Powerline statusline ───────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local colors = {
        bg     = "#282828",
        bg1    = "#3c3836",
        bg2    = "#504945",
        fg     = "#ebdbb2",
        grey   = "#928374",
        red    = "#fb4934",
        green  = "#b8bb26",
        yellow = "#fabd2f",
        blue   = "#83a598",
        purple = "#d3869b",
        aqua   = "#8ec07c",
        orange = "#fe8019",
        dark   = "#1d2021",
      }

      local theme = {
        normal = {
          a = { fg = colors.dark, bg = colors.blue, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg2 },
          c = { fg = colors.fg, bg = colors.bg1 },
        },
        insert  = { a = { fg = colors.dark, bg = colors.green,  gui = "bold" } },
        visual  = { a = { fg = colors.dark, bg = colors.orange, gui = "bold" } },
        replace = { a = { fg = colors.dark, bg = colors.red,    gui = "bold" } },
        command = { a = { fg = colors.dark, bg = colors.yellow, gui = "bold" } },
        terminal= { a = { fg = colors.dark, bg = colors.aqua,   gui = "bold" } },
        inactive = {
          a = { fg = colors.grey, bg = colors.bg },
          b = { fg = colors.grey, bg = colors.bg },
          c = { fg = colors.grey, bg = colors.bg },
        },
      }

      return {
        options = {
          theme = theme,
          globalstatus = true,
          icons_enabled = true,
          -- powerline separators
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "alpha", "neo-tree" } },
          refresh = { statusline = 200 },
        },
        sections = {
          lualine_a = {
            { "mode", fmt = function(s) return " " .. s end },
          },
          lualine_b = {
            { "branch", icon = "" },
          },
          lualine_c = {
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
              diagnostics_color = {
                error = { fg = colors.red },
                warn  = { fg = colors.yellow },
                info  = { fg = colors.blue },
                hint  = { fg = colors.aqua },
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = " ", readonly = " ", unnamed = "[No Name]" } },
          },
          lualine_x = {
            {
              -- active LSP clients
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then return "" end
                local names = {}
                for _, c in ipairs(clients) do names[#names + 1] = c.name end
                return "  " .. table.concat(names, ", ")
              end,
              color = { fg = colors.aqua },
            },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
              diff_color = {
                added    = { fg = colors.green },
                modified = { fg = colors.yellow },
                removed  = { fg = colors.red },
              },
            },
            { "encoding", fmt = string.upper },
            { "fileformat", symbols = { unix = "", mac = "", dos = "" } },
          },
          lualine_y = {
            { "progress" },
          },
          lualine_z = {
            { "location", icon = "" },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "lazy", "mason", "quickfix", "neo-tree", "trouble" },
      }
    end,
  },

  -- ── Powerline-slanted bufferline ───────────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Close unpinned buffers" },
    },
    opts = {
      options = {
        separator_style = "slant",
        always_show_bufferline = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = { Error = " ", Warn = " ", Info = " " }
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          { filetype = "neo-tree", text = "  Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },

  -- ── Start screen ───────────────────────────────────────────
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        [[                                                    ]],
        [[ ██████   █████                   █████   █████ ███ ]],
        [[░░██████ ░░███                   ░░███   ░░███ ░░░  ]],
        [[ ░███░███ ░███   ██████   ██████  ░███    ░███ ████ ]],
        [[ ░███░░███░███  ███░░███ ███░░███ ░███    ░███░░███ ]],
        [[ ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███  ░███ ]],
        [[ ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░   ░███ ]],
        [[ █████  ░░█████░░██████ ░░██████     ░░███     █████]],
        [[░░░░░    ░░░░░  ░░░░░░   ░░░░░░       ░░░     ░░░░░ ]],
        [[                                                    ]],
      }
      dashboard.section.header.opts.hl = "GruvboxOrange"

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",    "<cmd>Telescope find_files<CR>"),
        dashboard.button("n", "  New file",     "<cmd>ene | startinsert<CR>"),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Live grep",    "<cmd>Telescope live_grep<CR>"),
        dashboard.button("c", "  Config",       "<cmd>e $MYVIMRC<CR>"),
        dashboard.button("l", "󰒲  Lazy",         "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit",         "<cmd>qa<CR>"),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "GruvboxAqua"
        button.opts.hl_shortcut = "GruvboxYellow"
      end

      dashboard.section.footer.opts.hl = "GruvboxGray"
      dashboard.opts.layout[1].val = 6

      alpha.setup(dashboard.opts)

      -- `VeryLazy` is fired by lazy.nvim itself (LazyVimStarted is distro-only)
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local stats = require("lazy").stats()
          local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
          dashboard.section.footer.val = ("󱐋 %d plugins loaded in %sms"):format(stats.loaded, ms)
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- ── Keybinding hints ───────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = { border = "rounded" },
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>x", group = "diagnostics/quickfix" },
      },
    },
  },

  -- ── Indent guides ──────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "▏", tab_char = "▏" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "help", "alpha", "neo-tree", "lazy", "mason", "notify", "toggleterm", "checkhealth" },
      },
    },
  },

  -- ── Nicer UI for input/select ──────────────────────────────
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
