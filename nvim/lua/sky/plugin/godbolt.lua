return {
  "krady21/compiler-explorer.nvim",
  dependencies = {
      "stevearc/dressing.nvim", 
  },
  cmd = {
      "CECompile",
      "CECompileLive",
      "CEFormat",
      "CEAddLibrary",
      "CELoadExample",
      "CEOpenWebsite",
      "CEDeleteCache",
      "CEShowTooltip",
      "CEGotoLabel",
  },
keys =
  {
    {
      "<leader>gb",
      function()
          local actions = {
              "1. Compile Once",
              "2. Compile Live",
              "3. Format Code",
          }
          vim.ui.select(actions, { prompt = "Godbolt explorer:" }, function(choice)
              if not choice then return end
              vim.schedule(function()
                  if choice:match("Compile Once") then
                      vim.cmd("CECompile")
                  elseif choice:match("Compile Live") then
                      vim.cmd("CECompileLive")
                  elseif choice:match("Format Code") then
                      vim.cmd("CEFormat")
                  end
              end)
          end)
      end,
      mode = "n",
      desc = "Open Compiler Explorer Menu",
    },
  },
}
