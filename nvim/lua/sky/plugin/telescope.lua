return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      
      telescope.setup({
        defaults = {
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "bottom",
            },
          },
        },
      })
      
      -- Enable fzf native sorter
      telescope.load_extension("fzf")

      -- Essential keymaps
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find word under cursor' })
      vim.keymap.set('n', '<leader>an', function()
            builtin.find_files{
                cwd = vim.fn.stdpath("config")
            }
        end
        )
    end,
  }
}
