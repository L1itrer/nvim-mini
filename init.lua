-- BASIC OPTS
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

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.backspace = "indent,eol,start"
vim.o.encoding = "UTF-8"

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.scrolloff = 10
vim.o.cursorline = true

vim.o.inccommand = 'split'

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- KEYBINDINGS

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear all search highlights" })

vim.keymap.set({ "i", "v" }, "<C-\\>", "<Esc>", { desc = "Enter normal mode"})

vim.keymap.set( "t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Switch from terminal to normal"} )

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

vim.keymap.set('n', '<leader>w', ':update<CR>', { desc = 'Update current buffer' })


-- CALLBACK SETUP

local terminal_state = {
  window = nil,
  buffer = nil,
  is_open = false,
}

local function FloatingTerminal()
  -- if already open, close
  if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.window) then
    vim.api.nvim_win_close(terminal_state.window, false)
    terminal_state.is_open = false
    return
  end
  if not terminal_state.buffer or not vim.api.nvim_buf_is_valid(terminal_state.buffer) then
    terminal_state.buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = terminal_state.buffer })
  end
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local column = math.floor((vim.o.columns - width) / 2)

  terminal_state.window = vim.api.nvim_open_win(terminal_state.buffer, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = column,
    style = 'minimal',
    border = 'rounded',
  })
  vim.api.nvim_set_option_value('winblend', 0, { win = terminal_state.window })
  vim.api.nvim_set_option_value('winhighlight', 'Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder', { win = terminal_state.window })
  vim.api.nvim_set_hl(0, 'FloatingTermNormal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'FloatingTermBorder', { bg = 'none' })
  -- start terminal
  local has_terminal = false
  local lines = vim.api.nvim_buf_get_lines(terminal_state.buffer, 0, -1, false)
  for _, line in ipairs(lines) do
    if line ~= '' then
      has_terminal = true
      break
    end
  end
  if not has_terminal then
    vim.fn.jobstart(vim.o.shell, { term = true })
  end
  terminal_state.is_open = true
  vim.cmd 'startinsert'

  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = terminal_state.buffer,
    callback = function()
      if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.window) then
        vim.api.nvim_win_close(terminal_state.window, false)
        terminal_state.is_open = false
      end
    end,
    once = true,
  })
end

vim.keymap.set('n', '<C-t>', FloatingTerminal, { noremap = true, silent = true, desc = 'Toggle floating terminal' })

vim.keymap.set('t', '<C-t>', function()
  if terminal_state.is_open then
    vim.api.nvim_win_close(terminal_state.window, false)
    terminal_state.is_open = false
  end
end, { noremap = true, silent = true, desc = 'Close floating terminal' })


local augroup = vim.api.nvim_create_augroup('user_configuration', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})
