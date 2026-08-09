-- ─────────────────────────────────────────────────────────────
--  lua-language-server — mostly here for editing this config
--
--  nvim-lspconfig's own lsp/lua_ls.lua already points the server at the
--  Neovim runtime when a project has no .luarc.json, so this only adds
--  the deltas.
-- ─────────────────────────────────────────────────────────────

---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      -- Without this, opening any plugin's Lua triggers a "do you want to
      -- configure your work environment as luassert?" prompt per project.
      workspace = { checkThirdParty = false },
      diagnostics = { globals = { "vim" } },
      format = { enable = false }, -- stylua formats, via conform
      telemetry = { enable = false },
      hint = { enable = true, arrayIndex = "Disable" },
    },
  },
}
