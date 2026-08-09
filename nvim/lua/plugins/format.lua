-- ─────────────────────────────────────────────────────────────
--  Formatting  ·  conform.nvim
--
--  One path for every language, rather than LSP formatting for some and
--  a CLI for others. All three formatters come from the Brewfile or the
--  rustup toolchain, so a file formats the same here as it does in CI.
-- ─────────────────────────────────────────────────────────────

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "never" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      python = { "ruff_organize_imports", "ruff_format" },
      rust = { "rustfmt" },
      lua = { "stylua" },
    },
    format_on_save = {
      timeout_ms = 1000,
      -- conform owns formatting outright. With the LSP client formatting
      -- too you get races on large files and, occasionally, a mangled buffer.
      lsp_format = "never",
    },
  },
}
