return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {

      "saghen/blink.cmp",
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
      local blink = require('blink.cmp')
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      end

      vim.lsp.config('clangd', {
        cmd = { "clangd",
                "--background-index=false",
                "--clang-tidy",
                "--compile-commands-dir=build",
                "--header-insertion=never",
              },
        filetypes = { "c", "cpp" },
        root_markers = { "compile_commands.json", ".git" },
        init_options = {
          fallbackFlags = { "-std=c++23", "-I." },
        },
        -- Attach your logic here
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities(),
      })

      vim.lsp.config('lua_ls', {
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities(),
      })

      -- 4. Enable the server
      vim.lsp.enable('clangd')
      vim.lsp.enable('lua_ls')

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
        callback = function(args)
          vim.lsp.buf.format({ bufnr = args.buf })
        end,
      })

      -- Quickfix auto-quit
      vim.api.nvim_create_autocmd("WinEnter", {
        callback = function()
          if vim.fn.winnr('$') == 1 and vim.bo.buftype == "quickfix" then
            vim.cmd("quit")
          end
        end,
      })
    end
  },

  {
    'saghen/blink.cmp',
    version = '*',
    opts = {
      keymap = { preset = 'default',
        ['<C-j>']={'select_next'},
        ['<C-k>']={'select_prev'},
      
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },
}
