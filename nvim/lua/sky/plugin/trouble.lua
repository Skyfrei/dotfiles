return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {
    modes = {
      diagnostics = {
        -- Disable grouping items by filename
        groups = {},
        -- Format the output to only show the severity icon and the message
        -- This strips away any inline file names, line numbers, or paths
        format = "{severity_icon} {message:md}",
      },
      symbols = {
        groups = {},
        format = "{kind_icon} {symbol.name}",
      },
    },
  },
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>os",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>gr",
      "<cmd>Trouble lsp_references toggle<cr>",
      desc = "LSP References (Trouble)",
    },
   },
}
