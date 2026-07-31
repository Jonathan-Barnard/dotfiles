-- ── language servers ───────────────────────────────────────────────────────
-- Neovim 0.11 introduced a native LSP API, and the old require("lspconfig")
-- framework is deprecated. So:
--
--   * nvim-lspconfig is still installed, but only as a *data* package — it
--     ships the per-server defaults (command, filetypes, root markers) in its
--     lsp/ directory, which vim.lsp picks up automatically.
--   * mason.nvim downloads the server binaries.
--   * mason-lspconfig v2 calls vim.lsp.enable() for whatever mason installed.
--   * vim.lsp.config(name, {...}) below only adds our own overrides.
--
-- Do not add require("lspconfig").xxx.setup() calls; that API is on its way out.

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- Installed automatically on first launch. Add or remove freely, then
      -- restart Neovim. :Mason shows everything available.
      ensure_installed = {
        -- config, scripting, docs
        "lua_ls", "bashls", "marksman", "jsonls", "yamlls",
        -- python
        "pyright", "ruff",
        -- web
        "ts_ls", "html", "cssls", "tailwindcss",
        -- compiled
        "rust_analyzer", "clangd",
      },
      -- v2 default: vim.lsp.enable() each installed server for us.
      automatic_enable = true,
    },
    config = function(_, opts)
      -- Let blink.cmp advertise its completion capabilities to every server.
      local has_blink, blink = pcall(require, "blink.cmp")
      if has_blink then
        vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities({}, true) })
      end

      -- Per-server overrides. Everything not mentioned uses nvim-lspconfig's
      -- shipped defaults, which are almost always what you want.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            -- stop it warning that `vim` is undefined in your own config
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = { yaml = { keyOrdering = false } },
      })

      require("mason-lspconfig").setup(opts)
    end,
  },

  -- Buffer-local keymaps, applied whenever a server attaches. Neovim 0.11+
  -- already provides grn (rename), gra (code action), grr (references) and K
  -- (hover) out of the box; these are the more familiar aliases.
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("cfg_lsp_attach", { clear = true }),
        callback = function(event)
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", "<cmd>Telescope lsp_definitions<cr>", "Go to definition")
          map("gr", "<cmd>Telescope lsp_references<cr>", "List references")
          map("gI", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation")
          map("gy", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<C-k>", vim.lsp.buf.signature_help, "Signature help", "i")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols")

          -- Inlay hints, if this server supports them
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>th", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
            end, "Toggle inlay hints")
          end
        end,
      })
    end,
  },
}
