return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- 1. Setup Mason as usual
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd" },
      })

      -- 2. Define your shared settings (on_attach and capabilities)
      local blink = require('blink.cmp')
      
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      end

      vim.lsp.config('clangd', {
        cmd = { "clangd", "--background-index", "--clang-tidy", "--compile-commands-dir=build" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
        init_options = {
          fallbackFlags = { "-std=c++23", "-I." },
        },
        -- Attach your logic here
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities(),
      })

      -- 4. Enable the server
      vim.lsp.enable('clangd')

      -- 5. Diagnostic Quickfix Autocmd (Fixed for Neovim 0.11+)
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        callback = function()
          -- vim.schedule defers the function until the next Neovim event loop tick.
          -- This ensures Trouble has finished updating its internal lists before we open it!
          vim.schedule(function()
            local trouble = require("trouble")
            local errors = vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})
            
            if #errors > 0 then
              if not trouble.is_open({ mode = "diagnostics" }) then
                trouble.open({ mode = "diagnostics" })
              end
            else
              if trouble.is_open({ mode = "diagnostics" }) then
                trouble.close({ mode = "diagnostics" })
              end
            end
          end)
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
