-- ── finding, browsing, git, editing conveniences ───────────────────────────
return {

  -- Telescope: fuzzy finder, the editor counterpart to fzf in your shell.
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Compiled C sorter — much faster on big repositories. Needs `make`,
      -- which the installer put there via build-essential.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep in project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find open buffer" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Search help" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find word under cursor" },
      { "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    },
    opts = {
      defaults = {
        prompt_prefix = "  ",
        selection_caret = "▶ ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = { horizontal = { prompt_position = "top", preview_width = 0.55 } },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<Esc>"] = "close",
          },
        },
        file_ignore_patterns = { "%.git/", "node_modules/", "%.cache/" },
      },
      pickers = {
        find_files = { hidden = true },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- File tree down the left-hand side.
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
      { "<leader>tf", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
      { "<leader>tr", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in tree" },
    },
    opts = {
      close_if_last_window = true,
      window = { width = 32 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".git", "node_modules" },
        },
      },
    },
  },

  -- Git status in the sign column, plus staging and blame.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end
        -- gitsigns 1.0 replaced next_hunk/prev_hunk with nav_hunk; support both
        local function nav(direction)
          return function()
            if gs.nav_hunk then
              gs.nav_hunk(direction)
            else
              gs[direction .. "_hunk"]()
            end
          end
        end
        map("n", "]h", nav("next"), "Next git hunk")
        map("n", "[h", nav("prev"), "Previous git hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gd", gs.diffthis, "Diff this file")
      end,
    },
  },

  -- Automatically close brackets and quotes.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- cs"' changes surrounding quotes, ysiw) wraps a word in brackets, and so on.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Highlight and list TODO / FIXME / HACK comments.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODO comments" },
    },
  },
}
