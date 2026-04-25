#include <set>

local M = {}

--- Gets the current visual selection
local function get_visual_selection()
    local _, srow, scol = unpack(vim.fn.getpos("v"))
    local _, erow, ecol = unpack(vim.fn.getpos("."))
    
    if srow > erow or (srow == erow and scol > ecol) then
        srow, erow = erow, srow
        scol, ecol = ecol, scol
    end

    local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
    if #lines == 0 then return "" end

    lines[#lines] = string.sub(lines[#lines], 1, ecol)
    lines[1] = string.sub(lines[1], scol)
    return table.concat(lines, "\n")
end

local function clean_asm(raw_lines)
    local cleaned = {}
    for _, line in ipairs(raw_lines) do
        line = line:gsub("%s*#.*", "")
        line = line:gsub("%s*//.*", "")

        if not line:match("^%s*%.cfi_") and
           not line:match("^%s*%.type") and
           not line:match("^%s*%.size") and
           not line:match("^%s*%.ident") and
           not line:match("^%s*%.file") and
           not line:match("^%s*%.p2align") and
           not line:match("^%s*%.text") and
           not line:match("^%s*%.section") and
           not line:match("^%s*%.globl") and
           not line:match("^%s*%.weak") and
           not line:match("^%s*%.addrsig") then
            
            if line:match("%S") then
                table.insert(cleaned, line)
            end
        end
    end
    return cleaned
end
--- Compiles the snippet and opens the assembly view
function M.compile_selection()
    local snippet = get_visual_selection()
    if snippet == "" then
        print("No text selected!")
        return
    end

    local cpp_code = string.format([[
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <memory>
#include <map>
#include <unordered_map>
#include <string>
#include <type_traits>


%s
]], snippet)

    local cmd = { 
        "clang++", "-x", "c++", "-", "-S", 
        "-fomit-frame-pointer", 
        "-masm=intel",
        "-fno-asynchronous-unwind-tables", 
        "-fno-exceptions", 
        "-fno-rtti",
        "-o", "-" 
    }

    vim.system(cmd, { stdin = cpp_code, text = true }, function(out)
        vim.schedule(function()
            if out.code ~= 0 then
                print("Snippet failed to compile!")
                local errors = vim.split(out.stderr, "\n", { plain = true })
                for i = 1, math.min(#errors, 5) do
                    if errors[i] ~= "" then
                        vim.api.nvim_err_writeln(errors[i])
                    end
                end
                return
            end

            -- Open a split and show the assembly
            vim.cmd("vsplit")
            local asm_win = vim.api.nvim_get_current_win()
            local asm_buf = vim.api.nvim_create_buf(false, true)
            
            vim.api.nvim_win_set_buf(asm_win, asm_buf)
            
            -- This applies Neovim's standard Assembly highlighting
            vim.bo[asm_buf].filetype = "asm"
            vim.bo[asm_buf].bufhidden = "wipe"

            -- Parse and clean the output
            local raw_lines = vim.split(out.stdout, "\n", { plain = true })
            local clean_lines = clean_asm(raw_lines)
            
            vim.api.nvim_buf_set_lines(asm_buf, 0, -1, false, clean_lines)
        end)
    end)
end

-- Keymap bound directly in the file
vim.keymap.set('v', '<leader>c', function()
    M.compile_selection()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'x', false)
end, { desc = "Compile selection to Assembly" })

return M
