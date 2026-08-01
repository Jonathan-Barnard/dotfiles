return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope git_files<CR>", desc = "Find git files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>sg", "<cmd>Telescope live_grep<CR>", desc = "Grep (live)" },
      { "<leader>sw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
      { "<leader>sh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>sc", "<cmd>Telescope commands<CR>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>sr", "<cmd>Telescope resume<CR>", desc = "Resume last picker" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
      { "<leader>gt", "<cmd>Telescope git_status<CR>", desc = "Git status" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in buffer" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          entry_prefix = "  ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          winblend = 0,
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.9,
            height = 0.85,
          },
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          file_ignore_patterns = { "node_modules", "%.git/", "%.venv", "target/", "dist/" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
          buffers = { sort_lastused = true, ignore_current_buffer = true },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
