-- PLUGINS --


vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
local gh = function(plugin_str) return 'https://github.com/' .. plugin_str end

do
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end
      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

do
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end
  vim.pack.add(telescope_plugins)

  -- See `:help telescope` and `:help telescope.setup()`
  require('telescope').setup {
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  -- Enable Telescope extensions if they are installed
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )
  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf
      -- Find references for the word under your cursor.
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
      -- Jump to the implementation of the word under your cursor.
      -- Useful when your language has ways of declaring types without an actual implementation.
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
      -- Jump to the definition of the word under your cursor.
      -- This is where a variable was first declared, or where a function is defined, etc.
      -- To jump back, press <C-t>.
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
      -- Fuzzy find all the symbols in your current document.
      -- Symbols are things like variables, functions, types, etc.
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
      -- Fuzzy find all the symbols in your current workspace.
      -- Similar to document symbols, except searches over your entire project.
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
      -- Jump to the type of the word under your cursor.
      -- Useful when you're not sure what type a variable is and you want to see
      -- the definition of its *type*, not where it was *defined*.
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  -- Override default behavior and theme when searching
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- It's also possible to pass additional configuration options.
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )
  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
end


vim.pack.add({
  {
    src = gh('lewis6991/gitsigns.nvim'),
    name = 'gitsigns',
  },
  {
    src = gh('Darazaki/indent-o-matic'),
  },
  gh('nvim-tree/nvim-web-devicons'),
  gh('nvim-lualine/lualine.nvim'),
  gh('rebelot/kanagawa.nvim'),
  gh('saghen/blink.lib'),
  gh('saghen/blink.cmp'),
  gh('neovim/nvim-lspconfig'),
  gh('rluba/jai.vim'),
  gh('brenton-leighton/multiple-cursors.nvim'),
  -- gh('mg979/vim-visual-multi'),
  --{
  --}
})

require('indent-o-matic').setup({
  standard_widths = { 2, 4, 8 },
})

vim.o.showmode = false
require('lualine').setup({
})


-- LSP (shit gets real)
local servers = {'ols', 'clangd'}
--vim.lsp.config['ols'] = {}
for i, server in ipairs(servers) do
  vim.lsp.enable(server)
end


local cmp = require('blink.cmp')
local fuzzy_impl = "rust"
if vim.fn.has 'win32' == 1 then
  fuzzy_impl = "lua" -- rust build breaks on windows
else
  cmp.build():wait(60000)
end
cmp.setup({
  sources = { default = { 'lsp', 'path', 'buffer' } },
  fuzzy = {implementation = fuzzy_impl}
})

-- BASIC OPTS

local colorsheme = "kanagawa"
vim.cmd.colorscheme(colorsheme)
vim.cmd 'set completeopt+=noselect'

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
vim.o.wildmenu = true
vim.o.wildmode = "longest:full"

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true


vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.completeopt = "menuone,noinsert,noselect"

vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.updatetime = 300
vim.o.autoread = true

-- TODO: vim.o.showmode = false

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


vim.g.have_nerd_font = true
vim.o.confirm = true

vim.diagnostic.config {
  float = { source = 'if_many'},
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

-- KEYBINDINGS

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear all search highlights" })

vim.keymap.set({ "i", "v" }, "<C-\\>", "<Esc>", { desc = "Enter normal mode"})

vim.keymap.set( "t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Switch from terminal to normal"} )

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set({"n", "i"}, "<C-y>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set({"n", "i"}, "<C-p>", "<cmd>tabNext<CR>", { desc = "Next tab" })

vim.keymap.set("n", "j", "gj", {})
vim.keymap.set("n", "k", "gk", {})

-- vscode-like move lines
-- TODO: for some reason visual does not work
vim.keymap.set("n", "<A-j>", "<cmd>move .+1<CR>==", { desc = "Move line down"})
vim.keymap.set("n", "<A-k>", "<cmd>move .-2<CR>==", { desc = "Move line up"})
vim.keymap.set("x", "<A-j>", "<cmd>move '>+1<CR>gv=gv", { desc = "Move line down"})
vim.keymap.set("x", "<A-k>", "<cmd>move '<-2<CR>gv=gv", { desc = "Move line down"})

-- multiple cursors
local mc = require("multiple-cursors")
mc.setup()

vim.keymap.set({'n', 'x'}, "<C-A-j>", "<cmd>MultipleCursorsAddDown<CR>", {desc = "Add cursor, move down"})
vim.keymap.set({'n', 'x'}, "<C-A-k>", "<cmd>MultipleCursorsAddUp<CR>", {desc = "Add cursor, move up"})
vim.keymap.set({'n', 'x', 'i'}, "<C-A-Up>", "<cmd>MultipleCursorsAddDown<CR>", {desc = "Add cursor, move down"})
vim.keymap.set({'n', 'x', 'i'}, "<C-A-Down>", "<cmd>MultipleCursorsAddUp<CR>", {desc = "Add cursor, move up"})

vim.keymap.set({'n', 'i'}, "<C-LeftMouse>", "<cmd>MultipleCursorsMouseAddDelete<CR>", { desc = "" })
vim.keymap.set('x', "<Leader>m", "<Cmd>MultipleCursorsAddVisualArea<CR>", { desc = "Add cursors to the lines of the visual area"})

vim.keymap.set({'n'}, "<leader>|", function() mc.align() end, { desc = "Aligns to the rightmost cursor"})

vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.keymap.set("v", "<A-k>", "<cmd>move '>.-2<CR>gv=gv", { desc = "Move line up"})
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.keymap.set('n', '<leader>w', ':update<CR>', { desc = 'Update current buffer' })

local config_path = vim.fn.stdpath('config')
-- vim.keymap.set('n', '<leader>sf', '<cmd>Pick files<CR>', { desc = 'Pick [f]iles'} )
--vim.keymap.set('n', '<leader>sg', '<cmd>Pick grep_live<CR>', { desc = 'Pick by [g]iles'} )
--vim.keymap.set('n', '<leader>sb', '<cmd>Pick buffers<CR>', { desc = 'Pick [b]uffers'} )
--vim.keymap.set('n', '<leader>sc', ':edit ' .. config_path .. '<CR>', { desc = 'Open config'} )

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

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


local opacity_state = false

vim.keymap.set('n', '<leader>to', function()
  if opacity_state then
    vim.cmd.colorscheme(colorsheme)
    opacity_state = false
  else
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })
    opacity_state = true
  end
end, { desc = '[O]pacity toggle on/off'} )

local tabstop_state = {
  use_spaces = true,
  len = 0,
}

vim.keymap.set('n', '<leader>tw', function()
  tabstop_state.len = (tabstop_state.len+1) % 3
  local tablen = (2 ^ tabstop_state.len) * 2
  vim.o.tabstop = tablen
  vim.o.shiftwidth = tablen
  vim.o.softtabstop = tablen
  print("Tabwidth is now", tablen)
end, { desc = 'Tab [w]idth toggle' } )


vim.keymap.set('n', '<leader>tt', function()
  tabstop_state.use_spaces = not tabstop_state.use_spaces
  -- for some reason assigning use_spaces to expandtab does not yield
  -- any change
  -- words cannot describe my confusion
  if tabstop_state.use_spaces then
    vim.o.expandtab = true
  else
    vim.o.expandtab = false
  end
  print("Expandtab:", tabstop_state.use_spaces)
end, { desc = '[T]ab/spaces toggle' } )


vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Return to last position when quiting and returning to a buffer',
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

--require('gitsigns').setup({
--})
