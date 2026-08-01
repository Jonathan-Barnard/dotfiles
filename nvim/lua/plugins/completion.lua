return {
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then return end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
          },
        },
      },
    },
    opts = {
      snippets = { preset = "luasnip" },
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 150,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
