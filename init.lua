vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.cmd.colorscheme("unokai")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })


vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.wrap = true
vim.o.scrolloff = 10

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true

vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.showmatch = true
vim.o.completeopt = "menuone,noinsert,noselect"

vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.updatetime = 300
vim.o.autoread = true

vim.o.backspace = "indent,eol,start"
vim.o.encoding = "UTF-8"

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear all search highlights" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })


-- vscode-like move lines
-- TODO: for some reason does not work on windows
vim.keymap.set("n", "<A-j>", ":move .+1<CR>==", { desc = "Move line down"})
vim.keymap.set("n", "<A-k>", ":move .-2<CR>==", { desc = "Move line up"})
vim.keymap.set("v", "<A-j>", ":move '>.+1<CR>gv=gv", { desc = "Move line down"})
vim.keymap.set("v", "<A-k>", ":move '>.-2<CR>gv=gv", { desc = "Move line up"})
