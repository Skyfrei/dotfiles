return {
  "neurapy/asmview.nvim",
  cmd = { "AsmViewToggle", "AsmViewOpen", "AsmViewRebuild" },
  keys = {
    { 
      "<leader>od", 
      function()
        -- 1. Scan the build folder for compiled Linux executables
        -- (Finds files, max depth 1, executable permissions, ignores errors)
        local handle = io.popen('find build -maxdepth 1 -type f -executable 2>/dev/null')
        local binaries = {}
        
        if handle then
          for file in handle:lines() do
             table.insert(binaries, file)
          end
          handle:close()
        end

        if #binaries == 0 then
          vim.notify("No executables found in build/. Run CMake first!", vim.log.levels.ERROR)
          return
        end

        -- 2. The function that dynamically configures and launches the plugin
        local function launch_asmview(selected_path)
           -- Extracts just the name (e.g., "Trader" from "build/Trader")
           local target_name = vim.fn.fnamemodify(selected_path, ":t")

           -- Dynamically inject the correct paths right before opening!
           require("asmview").setup({
              make_cmd = { "make", "-C", "build", target_name },
              elf_path = selected_path,
              objdump_cmd = { "objdump" },
              objdump_args = { "-d", "-l", "--demangle", "--no-show-raw-insn" },
              split = "vert rightbelow vsplit",
              auto_sync = true,
           })

           vim.notify("Disassembling " .. target_name .. "...", vim.log.levels.INFO)
           
           -- If the file doesn't exist yet, build it
           if vim.fn.filereadable(selected_path) == 0 then
              vim.cmd("AsmViewRebuild")
           end
           
           vim.cmd("AsmViewOpen")
        end

        -- 3. If only one binary exists, open it. If multiple, show a UI prompt.
        if #binaries == 1 then
           launch_asmview(binaries[1])
        else
           vim.ui.select(binaries, { prompt = "Select target to view assembly:" }, function(choice)
              if choice then 
                  launch_asmview(choice) 
              end
           end)
        end
      end, 
      desc = "AsmView: Search & Toggle" 
    },
    { "<leader>or", "<cmd>AsmViewRebuild<cr>", desc = "AsmView: rebuild" },
  },
  -- We remove the static `opts = {}` block entirely, because we are 
  -- now handling the setup dynamically inside the keymap function above!
}
