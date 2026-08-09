-- ─────────────────────────────────────────────────────────────
--  ruff — Python lint, format and imports
--
--  Runs alongside basedpyright. Ruff deliberately doesn't type-check and
--  basedpyright deliberately doesn't lint well, so both attach and each
--  owns what it's good at.
-- ─────────────────────────────────────────────────────────────

---@type vim.lsp.Config
return {
  init_options = {
    -- Rules live in the project's pyproject.toml or ruff.toml, never here:
    -- an editor and a CI run that disagree about lint rules is a specific
    -- and irritating way to lose an afternoon.
    settings = { logLevel = "error" },
  },

  on_attach = function(client)
    -- basedpyright owns hover — ruff's is thin next to it, and whichever
    -- client answers first wins.
    client.server_capabilities.hoverProvider = false
  end,
}
