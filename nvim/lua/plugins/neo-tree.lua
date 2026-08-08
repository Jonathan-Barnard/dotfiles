-- ─────────────────────────────────────────────────────────────
--  neo-tree  ·  file explorer, replaces netrw
--
--  <leader>e toggles it (config/keymaps.lua). There is no keymap
--  per source — the winbar tabs below, and < / >, switch between
--  files, buffers and git status from inside the tree.
--
--  No icon provider is installed, so every file gets the same
--  `default` glyph below. Adding nvim-web-devicons or mini.icons
--  would light up per-filetype icons without any change here —
--  neo-tree pcalls for nvim-web-devicons and falls back quietly.
--
--  Colours live in plugins/colorscheme.lua with the rest of the
--  gruvbox overrides.
-- ─────────────────────────────────────────────────────────────
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    init = function()
      -- :Neotree covers the normal case. The exception is `nvim .`,
      -- where the plugin has to be loaded up front to claim the
      -- window netrw used to own.
      if vim.fn.argc(-1) == 1 then
        local stat = (vim.uv or vim.loop).fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded", -- matches opt.winborder
      enable_git_status = true,
      enable_diagnostics = true,

      window = {
        position = "left",
        width = 30,
        mappings = {
          -- Leader is <Space>; neo-tree binds it to toggle_node by
          -- default, which would shadow every leader map in the tree.
          ["<space>"] = "none",
        },
      },

      -- Tabs across the top of the tree. The glyphs are the ones
      -- already used elsewhere: 󰓩 is which-key's buffer group,
      --  is lualine's branch icon.
      source_selector = {
        winbar = true,
        statusline = false,
        sources = {
          { source = "filesystem", display_name = " 󰙅 Files " },
          { source = "buffers", display_name = " 󰓩 Buffers " },
          { source = "git_status", display_name = "  Git " },
        },
      },

      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰉖",
          default = "", -- neo-tree's own default is a bare "*"
        },
        modified = { symbol = "●" }, -- same as lualine's modified flag
        git_status = {
          symbols = {
            added = "+",
            modified = "!",
            deleted = "✘", -- the three above match lualine's diff section
            renamed = "󰁕",
            untracked = "?",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
        diagnostics = {
          -- Nothing produces these until an LSP is configured, but
          -- they match lualine's diagnostics section when it is.
          symbols = { hint = "󰌵", info = "", warn = "", error = "" },
        },
      },

      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        -- netrw is disabled in config/lazy.lua, so `nvim .` lands
        -- here; open in the current window the way netrw did.
        hijack_netrw_behavior = "open_current",
        filtered_items = {
          visible = false, -- H toggles the hidden ones back on
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_by_name = { ".git", ".DS_Store" },
        },
      },
    },
  },
}
