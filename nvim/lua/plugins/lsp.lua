-- ─────────────────────────────────────────────────────────────
--  LSP  ·  Python (ruff + basedpyright), Rust, Lua
--
--  The binaries come from the Brewfile and rustup, not Mason — one
--  package manager for the whole repo, and the same versions the shell
--  and CI use. nvim-lspconfig is here purely as the data it ships:
--  lsp/<server>.lua files holding cmd, filetypes and root markers.
--  Per-server overrides live in nvim/after/lsp/.
--
--  Nothing calls require("lspconfig").<server>.setup{} — that API is
--  pre-0.11 and vim.lsp.enable() replaces it.
-- ─────────────────────────────────────────────────────────────

local servers = { "basedpyright", "ruff", "rust_analyzer", "lua_ls" }

-- Open a command in a bottom terminal split, matching <leader>tt.
-- The TermClose autocmd in config/autocmds.lua means a clean run closes
-- its own split and a failure is left on screen with its output — which
-- is the right way round for a build: silence on success, detail on error.
local function term(cmd)
  return function()
    vim.cmd("15split | terminal " .. cmd)
  end
end

-- rust-analyzer speaks a few requests that aren't in the LSP spec. These
-- two are the reason people reach for rustaceanvim; they're a dozen lines
-- each, so the plugin can stay out until something else justifies it.
local function rust_expand_macro()
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request(0, "rust-analyzer/expandMacro", params, function(err, result)
    if err or not result then
      vim.notify("No macro under the cursor", vim.log.levels.INFO)
      return
    end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "rust"
    vim.bo[buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result.expansion, "\n"))
    vim.cmd.vsplit()
    vim.api.nvim_win_set_buf(0, buf)
  end)
end

local function rust_parent_module()
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request(0, "experimental/parentModule", params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify("No parent module", vim.log.levels.INFO)
      return
    end
    vim.lsp.util.show_document(result[1], "utf-8", { focus = true })
  end)
end

-- The single most common Python LSP failure is the server resolving the
-- system interpreter and calling every third-party import unresolved.
-- One key to see what it actually picked turns that into a five-second check.
local function python_interpreter()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })) do
    local path = vim.tbl_get(client.settings or {}, "python", "pythonPath")
    vim.notify(path or "basedpyright has no pythonPath set", vim.log.levels.INFO)
    return
  end
  vim.notify("basedpyright is not attached to this buffer", vim.log.levels.WARN)
end

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- ── Diagnostics ──────────────────────────────────────────
      -- The glyphs match the ones lualine and neo-tree already declare,
      -- so the same problem reads the same in all three places.
      -- signcolumn is already "yes", so nothing shifts when one appears.
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 2, prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "󰌵",
          },
        },
      })

      -- ── On attach ────────────────────────────────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("dotfiles_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then
            return
          end
          local buf = ev.buf

          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc, silent = true })
          end

          -- Completion. 'autocomplete' draws the menu from the sources in
          -- 'complete', where "o" means omnifunc — which is what
          -- vim.lsp.completion.enable() sets. So LSP first, then buffers.
          -- autotrigger is off deliberately: 'autocomplete' already fires on
          -- every keystroke, and turning it on adds a second trigger path on
          -- the server's own trigger characters.
          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, buf, { autotrigger = false })
            vim.bo[buf].complete = "o^10,.^5,b^5"
          end

          if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
            map("<leader>ch", function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }),
                { bufnr = buf }
              )
            end, "Toggle inlay hints")
          end

          -- 0.11 already binds grn rename, gra code action, grr references,
          -- gri implementation, K hover and [d / ]d. Only the gaps below.
          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gy", vim.lsp.buf.type_definition, "Goto type definition")

          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("<leader>cD", vim.diagnostic.setqflist, "All diagnostics → quickfix")
          map("<leader>cs", vim.lsp.buf.document_symbol, "Document symbols")
          map("<leader>cS", vim.lsp.buf.workspace_symbol, "Workspace symbols")
          map("<leader>ci", "<cmd>checkhealth vim.lsp<CR>", "LSP health")
        end,
      })

      -- ── Language extras ──────────────────────────────────────
      local ft_group = vim.api.nvim_create_augroup("dotfiles_lsp_filetype", { clear = true })

      local function language_maps(filetype, prefix, group, maps)
        vim.api.nvim_create_autocmd("FileType", {
          group = ft_group,
          pattern = filetype,
          callback = function(ev)
            for lhs, spec in pairs(maps) do
              vim.keymap.set("n", prefix .. lhs, spec[1], {
                buffer = ev.buf,
                desc = spec[2],
                silent = true,
              })
            end
            pcall(function()
              require("which-key").add({ { prefix, group = group, buffer = ev.buf } })
            end)
          end,
        })
      end

      language_maps("rust", "<leader>cr", "rust", {
        r = { term("cargo run"), "cargo run" },
        t = { term("cargo test"), "cargo test" },
        b = { term("cargo build"), "cargo build" },
        c = { term("cargo check"), "cargo check" },
        C = { term("cargo clippy --all-targets"), "cargo clippy" },
        o = { "<cmd>edit Cargo.toml<CR>", "Open Cargo.toml" },
        m = { rust_expand_macro, "Expand macro" },
        p = { rust_parent_module, "Parent module" },
      })

      language_maps("python", "<leader>cp", "python", {
        r = { term("uv run %"), "uv run this file" },
        t = { term("uv run pytest"), "uv run pytest" },
        i = {
          function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" }, diagnostics = {} },
              apply = true,
            })
          end,
          "Organize imports",
        },
        v = { python_interpreter, "Show resolved interpreter" },
      })

      -- ── Go ───────────────────────────────────────────────────
      -- Resolves each name against lsp/<name>.lua on the runtimepath:
      -- nvim-lspconfig's defaults, with nvim/after/lsp/ layered on top.
      vim.lsp.enable(servers)
    end,
  },
}
