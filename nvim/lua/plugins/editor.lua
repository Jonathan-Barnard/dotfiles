return {
  -- ── File explorer ──────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Explorer" },
      { "<leader>E", "<cmd>Neotree reveal<CR>", desc = "Explorer (reveal file)" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { visible = false, hide_dotfiles = false, hide_gitignored = true },
      },
      window = {
        width = 32,
        mappings = { ["<space>"] = "none", ["l"] = "open", ["h"] = "close_node" },
      },
      default_component_configs = {
        indent = { with_expanders = true, expander_collapsed = "", expander_expanded = "" },
        git_status = {
          symbols = {
            added = "", modified = "", deleted = "✖", renamed = "󰁕",
            untracked = "", ignored = "", unstaged = "󰄱", staged = "", conflict = "",
          },
        },
      },
    },
  },

  -- ── Git signs in the gutter ────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      current_line_blame = false,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end
        -- gitsigns >= 1.0 renamed next_hunk/prev_hunk to nav_hunk
        local function nav(dir)
          return function()
            if gs.nav_hunk then gs.nav_hunk(dir) else gs[dir .. "_hunk"]() end
          end
        end
        map("n", "]h", nav("next"), "Next hunk")
        map("n", "[h", nav("prev"), "Previous hunk")
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        if gs.undo_stage_hunk then
          map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        end
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>gd", gs.diffthis, "Diff this")
      end,
    },
  },

  -- ── Comments ───────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ── Auto pairs & surround ──────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true, fast_wrap = {} },
  },
  {
    "kylechui/nvim-surround",
    event = { "BufReadPost", "BufNewFile" },
    version = "*",
    opts = {},
  },

  -- ── TODO / FIXME highlighting ──────────────────────────────
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>st", "<cmd>TodoTelescope<CR>", desc = "Todo comments" },
      { "<leader>xt", "<cmd>TodoTrouble<CR>", desc = "Todo (Trouble)" },
    },
    opts = { signs = true },
  },

  -- ── Diagnostics list ───────────────────────────────────────
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<CR>", desc = "Symbols (Trouble)" },
    },
  },

  -- ── Floating terminal ──────────────────────────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
      { "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", desc = "Lazygit" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      shade_terminals = false,
      float_opts = { border = "rounded", winblend = 0 },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
      function _LAZYGIT_TOGGLE()
        if vim.fn.executable("lazygit") == 1 then
          lazygit:toggle()
        else
          vim.notify("lazygit is not installed", vim.log.levels.WARN)
        end
      end
    end,
  },

  -- ── Session persistence ────────────────────────────────────
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>ss", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    },
  },
}
