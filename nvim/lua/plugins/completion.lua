-- ── autocompletion ─────────────────────────────────────────────────────────
-- blink.cmp rather than nvim-cmp: sources for LSP, paths, snippets and the
-- current buffer are built in rather than being separate plugins, and it
-- updates on every keystroke instead of debouncing.
return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "*",       -- use the latest tagged release, which ships a prebuilt binary
    opts = {
      keymap = {
        preset = "default",          -- <C-space> opens, <C-n>/<C-p> cycle, <C-e> cancels
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        menu = { border = "rounded" },
        ghost_text = { enabled = false },
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
