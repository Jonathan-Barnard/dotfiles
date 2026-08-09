-- ─────────────────────────────────────────────────────────────
--  rust-analyzer
--
--  The binary comes from rustup, not Homebrew:
--    rustup component add rust-analyzer
--  An analyzer built against a different rustc than the crate reports
--  proc-macro expansion failures and trait errors that aren't real.
--  rustup's component always matches the active toolchain.
-- ─────────────────────────────────────────────────────────────

---@type vim.lsp.Config
return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        buildScripts = { enable = true },
      },
      procMacro = { enable = true },

      -- clippy re-runs on every write. --no-deps skips linting dependencies,
      -- which is most of the cost on a large workspace. If saves still drag,
      -- drop command to "check" and leave clippy to CI.
      checkOnSave = true,
      check = {
        command = "clippy",
        extraArgs = { "--no-deps" },
      },

      inlayHints = {
        lifetimeElisionHints = { enable = "skip_trivial" },
        closureReturnTypeHints = { enable = "with_block" },
      },

      -- Without target/ excluded the analyzer indexes build artefacts, which
      -- is both slow and a source of goto-definition landing in generated code.
      files = {
        excludeDirs = { ".direnv", ".git", "target", "node_modules" },
      },
    },
  },
}
