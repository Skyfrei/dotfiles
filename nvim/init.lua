require ("sky")
vim.g.mapleader = " "
vim.opt.guicursor = "n:block-Cursor/lCursor-blinkon0,i:ver50-iCursor"
vim.api.nvim_set_hl(0, 'Visual', { fg = '#FF6C6B', bg = '#2C2222' })
vim.cmd([[highlight Cursor guifg=Green guibg=Red]])

vim.opt.relativenumber = true
vim.opt.nu = true

-- Just tab inditiation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.laststatus = 0

-- vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME").. "/.config/nvim/undodir"
vim.env.PATH = vim.env.PATH .. ':/etc/profiles/per-user/sky/bin'
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.hlsearch = false

vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50
--vim.opt.colorcolumn = "80"
vim.opt.termguicolors = true

-- clipboard copy
vim.opt.clipboard = "unnamedplus"
vim.o.pumheight = 2

vim.keymap.set("n", "<C-a>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-x>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-O>", {desc = "Jump behind in the buffer"})
vim.keymap.set("n", "<C-k>", "<C-I>", {desc = "Jump ahead in the buffer"})



vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99

vim.keymap.set('n', '<Tab>', 'za', { noremap = true }) -- Toggle fold
