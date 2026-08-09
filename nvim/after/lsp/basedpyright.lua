-- ─────────────────────────────────────────────────────────────
--  basedpyright — Python types, hover, goto
--
--  after/lsp/ rather than lsp/: nvim folds every lsp/<name>.lua on the
--  runtimepath with tbl_deep_extend("force"), so the *last* one wins and
--  nvim-lspconfig's copy comes after ~/.config/nvim's. after/ is last on
--  the runtimepath by definition, which is the documented way to override
--  a plugin's server config (:h lsp-config-merge).
-- ─────────────────────────────────────────────────────────────

---@type vim.lsp.Config
return {
  -- uv workspaces keep one .venv at the workspace root while each member
  -- package has its own pyproject.toml, so uv.lock has to win the race or
  -- the client anchors on the member and never finds the interpreter.
  --
  -- Lists are replaced, not merged, so this has to restate nvim-lspconfig's
  -- markers rather than just adding to them.
  root_markers = {
    "uv.lock",
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },

  before_init = function(_, config)
    -- root_dir, not getcwd(): nvim's cwd is wherever it was started, which
    -- stops being the project the moment you open a file outside it.
    local root = config.root_dir or vim.fn.getcwd()
    local venv = root .. "/.venv/bin/python"
    local python = vim.fn.executable(venv) == 1 and venv or vim.fn.exepath("python3")

    -- Mutated in place, not reassigned. The client captures
    -- `self.settings = config.settings` when it is constructed, and
    -- before_init runs after that — swapping the table for a new one
    -- leaves the client holding the original and the path goes nowhere.
    -- (The example in :h vim.lsp.ClientConfig has this trap in it.)
    config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
      pythonPath = python ~= "" and python or "python",
    })
  end,

  settings = {
    basedpyright = {
      analysis = {
        -- basedpyright's own default is "recommended", which is stricter
        -- than pyright and lights up an existing codebase like a tree.
        typeCheckingMode = "standard",
        diagnosticMode = "openFilesOnly", -- "workspace" crawls on big repos
        autoSearchPaths = true,
        -- useLibraryCodeForTypes is deliberately unset. It defaults to true,
        -- and setting it here would override whatever a project's own
        -- pyproject.toml says — basedpyright's docs advise against it.
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
          genericTypes = false, -- noisy, and rarely the thing you forgot
        },
      },
      -- ruff owns imports; two servers offering organiseImports means two
      -- code actions with the same name in the picker.
      disableOrganizeImports = true,
    },
  },
}

-- The before_init fallback above is a convenience for repos that don't say
-- where their venv is. The better fix lives in the project and is committed,
-- so every editor and CI agree:
--
--   [tool.basedpyright]
--   venvPath = "."
--   venv = ".venv"
