return {
  -- ── Mason: install LSP servers / formatters / linters ──────
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "", package_pending = "", package_uninstalled = "" },
      },
    },
  },

  -- ── LSP configuration ──────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Buffer-local keymaps once a server attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("dotfiles_lsp_attach", { clear = true }),
        callback = function(event)
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", "<cmd>Telescope lsp_definitions<CR>", "Goto definition")
          map("gr", "<cmd>Telescope lsp_references<CR>", "Goto references")
          map("gI", "<cmd>Telescope lsp_implementations<CR>", "Goto implementation")
          map("gy", "<cmd>Telescope lsp_type_definitions<CR>", "Goto type definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover docs")
          map("<C-k>", function() vim.lsp.buf.signature_help({ border = "rounded" }) end, "Signature help", "i")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>cs", "<cmd>Telescope lsp_document_symbols<CR>", "Document symbols")
          map("<leader>cS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", "Workspace symbols")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- highlight references under the cursor
          if client and client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("dotfiles_lsp_highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf, group = hl_group, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf, group = hl_group, callback = vim.lsp.buf.clear_references,
            })
          end
          -- inlay hints toggle
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>ch", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
            end, "Toggle inlay hints")
          end
        end,
      })

      -- Broadcast blink.cmp's extra capabilities to every server
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities({}, false) })
      end

      -- Per-server overrides
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
            hint = { enable = true },
            telemetry = { enable = false },
          },
        },
      })

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "bashls",
          "jsonls",
          "yamlls",
          "pyright",
          "ts_ls",
          "rust_analyzer",
          "gopls",
        },
        automatic_enable = true,
      })
    end,
  },

  -- ── Formatting ─────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, desc = "Format buffer" },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        python = { "ruff_format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        rust = { "rustfmt" },
        go = { "gofmt" },
      },
    },
    init = function()
      vim.api.nvim_create_user_command("FormatToggle", function(args)
        if args.bang then
          vim.b.disable_autoformat = not vim.b.disable_autoformat
        else
          vim.g.disable_autoformat = not vim.g.disable_autoformat
        end
      end, { desc = "Toggle format-on-save (! for buffer only)", bang = true })
    end,
  },
}
