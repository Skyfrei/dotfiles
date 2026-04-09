return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {
    modes = {
      diagnostics = {
        filter = {severity = vim.diagnostic.severity.ERROR},
        focus = false,
        win = { size = 5 },
        groups = {},
        format = "{severity_icon} {message:md}",
      },
      symbols = {
        groups = {},
        win = {
          position = "left",
        },
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
