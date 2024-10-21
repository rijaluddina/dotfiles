return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "williamboman/mason.nvim",
      { "williamboman/mason-lspconfig.nvim", config = function() end },
    },
    opts = {
      ---@type lspconfig.options
      servers = {
        eslint = {},
        intelephense = {
          diagnostics = { enable = true },
          environment = {
            documentRoot = "/path/to/src",
            includePaths = {
              "/path/to/drupal/root",
            },
            phpVersion = "8.3",
          },
          files = {
            associations = { "*.blade.php", "*.php", "*.module", "*.inc", "*.install" },
            exclude = {
              "/path/to/symlinked/src/under/drupal/root/**",
            },
          },
          format = { enable = true },
          licenseKey = "~/.intelephense",
          telemetry = { enabled = false },
        },
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  "@?class\\(([^]*)\\)",
                  "'([^']*)'",
                },
              },
            },
          },
        },
      },
      setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
        clangd = function(_, opts)
          opts.capabilities.offsetEncoding = { "utf-16" }
        end,
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
        size = {
          width = 0.8,
          height = 0.8,
        },
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      ensure_installed = {
        "black",
        "prettier",
        "blade-formatter",
        "json-lsp",
        "markdown-toc",
        "markdownlint-cli2",
        "vue-language-server",
        "vtsls",
      },
    },
  },
}
