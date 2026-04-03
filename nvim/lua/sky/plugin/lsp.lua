return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },

    config = function()
        local lsp = vim.lsp
        local buffer_stack = {}
        local on_attach =  function(client, bufnr)
            local opts = {buffer = bufnr}
            vim.keymap.set('n', 'gd', lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gD', lsp.buf.definition, opts)
        end

        -- show error window 
        vim.api.nvim_create_autocmd("DiagnosticChanged", {
            buffer = bufnr,
            callback = function()
                local errors = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
                if #errors > 0 then
                    vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR, open = false })
                    local current_win = vim.api.nvim_get_current_win()
                    vim.cmd("botright copen")
                    vim.api.nvim_set_current_win(current_win)
                else
                    vim.cmd("cclose")
                end
            end,
        })
        -- close the error window when :q
       vim.api.nvim_create_autocmd("WinEnter", {
           callback = function()
               if vim.fn.winnr('$') == 1 and vim.bo.buftype == "quickfix" then
                   vim.cmd("quit")
               end
           end,
       })

        local lsp_table = {'clangd', 'rust_analyzer'}
 
        for _, server_name in ipairs(lsp_table) do
            local server_config = {
                on_attach = on_attach,
            }
            if server_name == 'clangd' then
                server_config.init_options = {
                    fallbackFlags = { "-std=c++23", "-I." },
                }
            end 
            lsp.config[server_name] = server_config 
            
            lsp.enable(server_name)

        end


        local cmp = require('cmp')
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
            })
        })

    end
  },
}
