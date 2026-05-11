local M = {}
local asm_buf = nil
local asm_win = nil
local source_buf = nil
local ns_id = vim.api.nvim_create_namespace("snippet_asm_highlights")
local line_map = {} 
local group = vim.api.nvim_create_augroup("SnippetAsmSync", { clear = true })

--- Gets the current visual selection AND the starting row
local function get_visual_selection()
    local _, srow, scol = unpack(vim.fn.getpos("v"))
    local _, erow, ecol = unpack(vim.fn.getpos("."))
    
    if srow > erow or (srow == erow and scol > ecol) then
        srow, erow = erow, srow
        scol, ecol = ecol, scol
    end

    local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
    if #lines == 0 then return "", srow end

    lines[#lines] = string.sub(lines[#lines], 1, ecol)
    lines[1] = string.sub(lines[1], scol)
    return table.concat(lines, "\n"), srow
end

local function process_asm(raw_lines, source_srow, header_line_count)
    local cleaned = {}
    line_map = {}
    local current_src_line = nil
    local asm_line_index = 1
    
    local in_lib_func = false 

    for _, line in ipairs(raw_lines) do
        -- 0. Check if we are entering a new function
        local func_name = line:match("^([a-zA-Z0-9_]+):")
        if func_name then
            -- The Ultimate GCC / Libstdc++ Mute Filter
            if func_name:match("^_Z.*St") or        -- Catches all std:: instantiations
               func_name:match("^_Z.*__gnu_cxx") or -- Catches GCC standard library internals
               func_name:match("^_Znw") or          -- Catches 'operator new'
               func_name:match("^_Zdl") or          -- Catches 'operator delete'
               func_name:match("^__") then          -- Catches compiler built-ins
                in_lib_func = true
            else
                in_lib_func = false
            end
        end

        if not in_lib_func then
            -- 1. Catch location directives
            local loc_line = line:match("^%s*%.loc%s+%d+%s+(%d+)")
            if loc_line then
                local stdin_line = tonumber(loc_line)
                current_src_line = source_srow + (stdin_line - header_line_count - 1)
            end

            -- 2. Strip comments
            local stripped_line = line:gsub("%s*#.*", ""):gsub("%s*//.*", "")

            -- 3. The Ultimate Metadata Filter (Now GCC aware!)
            if not stripped_line:match("^%s*%.cfi_") and
               not stripped_line:match("^%s*%.type") and
               not stripped_line:match("^%s*%.size") and
               not stripped_line:match("^%s*%.ident") and
               not stripped_line:match("^%s*%.file") and
               not stripped_line:match("^%s*%.p2align") and
               not stripped_line:match("^%s*%.text") and
               not stripped_line:match("^%s*%.section") and
               not stripped_line:match("^%s*%.globl") and
               not stripped_line:match("^%s*%.weak") and
               not stripped_line:match("^%s*%.addrsig") and
               not stripped_line:match("^%s*%.loc") and
               
               -- Kill data bytes
               not stripped_line:match("^%s*%.byte") and   
               not stripped_line:match("^%s*%.long") and   
               not stripped_line:match("^%s*%.short") and
               not stripped_line:match("^%s*%.quad") and
               not stripped_line:match("^%s*%.value") and
               not stripped_line:match("^%s*%.zero") and
               not stripped_line:match("^%s*%.ascii") and
               not stripped_line:match("^%s*%.asciz") and
               
               -- Kill DWARF string tables
               not stripped_line:match("^%s*%.Linfo") and
               not stripped_line:match("^%s*%.Ldebug") and
               not stripped_line:match("^%s*%.Lcu_") and
               not stripped_line:match("^%s*%.Lrnglists_") and
               not stripped_line:match("^%s*%.Lstr_") and
               not stripped_line:match("^%s*%.Lline_") and
               not stripped_line:match("^%s*%.Laddr_") and
               not stripped_line:match("^%s*%.uleb128") and
               
               -- Kill Clang visual clutter
               not stripped_line:match("^%s*%.Ltmp") and
               not stripped_line:match("^%s*%.Lfunc_") and
               
               -- NEW: Kill GCC visual clutter and RISC-V directives
               not stripped_line:match("^%s*%.LFB") and
               not stripped_line:match("^%s*%.LFE") and
               not stripped_line:match("^%s*%.LBB") and
               not stripped_line:match("^%s*%.LBE") and
               not stripped_line:match("^%s*%.LVL") and
               not stripped_line:match("^%s*%.Ltext") and
               not stripped_line:match("^%s*%.align") and
               not stripped_line:match("^%s*%.set") and
               not stripped_line:match("^%s*%.option") and
               not stripped_line:match("^%s*%.attribute") then
                
                -- If the line isn't empty after stripping, keep it!
                if stripped_line:match("%S") then
                    table.insert(cleaned, stripped_line)
                    
                    if current_src_line and not line_map[current_src_line] then
                        line_map[current_src_line] = asm_line_index
                    end
                    
                    asm_line_index = asm_line_index + 1
                end
            end
        end
    end
    return cleaned
end
local function sync_highlight()
    if not asm_win or not vim.api.nvim_win_is_valid(asm_win) then return end
    if vim.api.nvim_get_current_buf() ~= source_buf then return end

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local src_line = cursor_pos[1]
    local target_asm_line = line_map[src_line]

    -- Clear the previous highlight
    vim.api.nvim_buf_clear_namespace(asm_buf, ns_id, 0, -1)

    if target_asm_line then
        -- Add highlight to the matched assembly line
        pcall(vim.api.nvim_buf_add_highlight, asm_buf, ns_id, "Visual", target_asm_line - 1, 0, -1)
        
        -- Smoothly scroll the assembly window so the highlight is centered,
        -- WITHOUT stealing your cursor from the C++ window.
        vim.api.nvim_win_call(asm_win, function()
            pcall(vim.api.nvim_win_set_cursor, asm_win, { target_asm_line, 0 })
            vim.cmd("normal! zz")
        end)
    end
end

--- Compiles the snippet and opens the assembly view
function M.compile_selection()
    local snippet, srow = get_visual_selection()
    if snippet == "" then
        print("No text selected!")
        return
    end

    source_buf = vim.api.nvim_get_current_buf()
    local source_win_id = vim.api.nvim_get_current_win()

    local headers = {
"#include <iostream>",
"#include <vector>",
"#include <string>",
"#include <algorithm>",
"#include <memory>",
"#include <map>",
"#include <unordered_map>",
"#include <string>",
"#include <type_traits>",
"#include <set>",
""
    }
    local header_line_count = #headers
    local cpp_code = table.concat(headers, "\n") .. snippet

      local cmd = { 
        "riscv64-linux-gnu-g++", "-x", "c++", "-", "-S", "-g", "-std=c++20", 
        "-march=rv64gc",

        "-fomit-frame-pointer", 
        "-fno-asynchronous-unwind-tables", 
        "-fno-exceptions", 
        "-fno-rtti",
        "-o", "-" 
    }    vim.system(cmd, { stdin = cpp_code, text = true }, function(out)
        vim.schedule(function()
            if out.code ~= 0 then
                print("Snippet failed to compile!")
                local errors = vim.split(out.stderr, "\n", { plain = true })
                for i = 1, math.min(#errors, 5) do
                    if errors[i] ~= "" then vim.api.nvim_err_writeln(errors[i]) end
                end
                return
            end

            -- Setup the split window
            vim.cmd("vsplit")
            asm_win = vim.api.nvim_get_current_win()
            asm_buf = vim.api.nvim_create_buf(false, true)
            
            vim.api.nvim_win_set_buf(asm_win, asm_buf)
            vim.bo[asm_buf].filetype = "asm"
            vim.bo[asm_buf].bufhidden = "wipe"

            -- Parse, clean, and map the assembly
            local raw_lines = vim.split(out.stdout, "\n", { plain = true })
            local clean_lines = process_asm(raw_lines, srow, header_line_count)
            
            vim.api.nvim_buf_set_lines(asm_buf, 0, -1, false, clean_lines)
            vim.api.nvim_set_current_win(source_win_id)

            -- Setup the autocmd to track your cursor movements!
            vim.api.nvim_clear_autocmds({ group = group })
            vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
                group = group,
                buffer = source_buf,
                callback = sync_highlight,
            })
            
            -- Trigger an initial highlight
            sync_highlight()
        end)
    end)
end

vim.keymap.set('v', '<leader>c', function()
    M.compile_selection()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'x', false)
end, { desc = "Compile selection to Assembly" })

return M
