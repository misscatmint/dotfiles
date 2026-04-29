-- plugins
vim.pack.add({
  'https://github.com/akinsho/bufferline.nvim.git', -- buffer tabs
  'https://github.com/folke/noice.nvim.git', -- ui/notif niceties
  -- bigfile/image/quickload/scope objects/smooth scroll (neo-tree uses image)
  'https://github.com/folke/snacks.nvim.git',
  'https://github.com/folke/trouble.nvim.git', -- diagnostic window
  'https://github.com/ibhagwan/fzf-lua.git', -- fuzzy file finder
  'https://github.com/lewis6991/gitsigns.nvim.git', -- git (for statuscol)
  'https://github.com/lukas-reineke/indent-blankline.nvim.git', -- scopes
  'https://github.com/luukvbaal/statuscol.nvim.git', -- nicer status column
  -- library (for noice, neo-tree)
  'https://github.com/MunifTanjim/nui.nvim.git',
  'https://github.com/neovim/nvim-lspconfig.git', -- language server setup
  'https://github.com/nvim-lua/plenary.nvim.git', -- library (for neo-tree)
  'https://github.com/nvim-lualine/lualine.nvim.git', -- fancy status line
  'https://github.com/nvim-neo-tree/neo-tree.nvim.git', -- file tree
  -- icon library (for bufferline, snacks, trouble, fzf-lua, lualine, neo-tree)
  'https://github.com/nvim-tree/nvim-web-devicons.git',
  'https://github.com/nvim-treesitter/nvim-treesitter.git', -- syntax
  'https://github.com/rcarriga/nvim-notify.git', -- library (for noice)
  -- theme
  { src = 'https://github.com/catppuccin/nvim.git', name = 'catppuccin' },
  -- syntax objects
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects.git',
    version = 'main'
  },
  -- autocompletion
  { src = 'https://github.com/saghen/blink.cmp.git', version = 'v1.10.2' },
})

-- theme
require('catppuccin').setup({ auto_integrations = true })
vim.cmd.colorscheme('catppuccin')

-- setup
require('blink.cmp').setup({
  completion = {
    documentation = { auto_show = true },
  },
})
bufferline = require('bufferline')
bufferline.setup({
  highlights = require('catppuccin.special.bufferline').get_theme(),
  options = { separator_style = 'slant', diagnostics = 'nvim_lsp' },
})
require('fzf-lua').setup()
require('gitsigns').setup()
require('ibl').setup({
  -- make guide character lighter than the default pipe
  indent = { char = '│' },
  -- don't show scope borders
  scope = { show_end = false, show_start = false },
})
require('lualine').setup({ options = {
  -- make status line span windows
  globalstatus = true
}})
require('neo-tree').setup({
  window = {
    width = 30, -- default was 40
  },
})
require('noice').setup({
  lsp = {
    progress = { enabled = false },
    override = {
      -- override the default lsp markdown formatter with noice
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      -- override the lsp markdown formatter with noice
      ['vim.lsp.util.stylize_markdown'] = true,
    },
    --signature = { auto_open = { enabled = false } },
  },
})
require('nvim-treesitter').install({
  'bash', 'c', 'caddy', 'cmake', 'cpp', 'css', 'csv', 'diff', 'dockerfile',
  'fish', 'git_config', 'git_rebase', 'gitattributes', 'gitcommit',
  'gitignore', 'go', 'gpg', 'html', 'ini', 'javascript', 'json', 'lua',
  'make', 'markdown', 'markdown_inline', 'nim', 'printf', 'python',
  'query', 'regex', 'requirements', 'ruby', 'rust', 'toml', 'typescript',
  'vim', 'vimdoc', 'xml', 'zig'
})
require('nvim-treesitter-textobjects').setup({ select = { lookahead = true } })
require('snacks').setup({
  bigfile = { enabled = true }, -- limit plugins on large files
  image = { enabled = true }, -- display images
  quickfile = { enabled = true }, -- speed up startup time
  scope = { enabled = true }, -- treesitter-based scope objects
  scroll = { enabled = true }, -- smooth scrolling for motions
})
require('statuscol').setup()
require('trouble').setup()

-- lsp
vim.lsp.enable('clangd') -- c/c++
vim.lsp.enable('basedpyright') -- python (uv tool install -U basedpyright)

-- diagnostics
vim.diagnostic.config({
  -- display highest severity sign
  severity_sort = true,
  -- replace default ascii icons with fancy ones
  signs = {
    text = {'', '', '', '󰌵'},
  },
})

-- general
vim.o.autowrite = true -- auto-save in certain situations
vim.o.cursorline = true -- highlight line cursor is on
vim.o.foldcolumn = '1' -- gutter column for folds
vim.o.mouse = 'a' -- enable mouse support
vim.o.number = true -- show line numbers
vim.o.scrolloff = 4 -- lines of context to show when scrolling
vim.o.sidescrolloff = 8 -- same but horizontally
vim.o.signcolumn = 'yes' -- always show diagnostic gutter
vim.o.showmatch = true -- highlight opening bracket when typing close bracket
vim.o.smoothscroll = true -- smoothly scroll within wrapped lines
vim.o.title = true -- set terminal title
vim.opt.virtualedit:append('block') -- enable virtual editing in visual block

-- list/whitespace
vim.opt.list = true
vim.opt.listchars = {
  extends = '…',
  nbsp = '␣',
  precedes = '…',
  tab = '⇥ ',
  trail = '·',
}
vim.opt.showbreak = '↳'

-- formatting
vim.opt.formatoptions:remove('o') -- disable auto-comment
vim.opt.formatoptions:remove('t') -- disable auto-wrap
vim.opt.formatoptions:append('j') -- join comments
vim.opt.formatoptions:append('n') -- format numbered lists
vim.opt.formatoptions:append('1') -- don't break lines after one letter words
vim.o.expandtab = true -- expand tabs to spaces
vim.o.shiftwidth = 4 -- shift by 4 spaces
vim.o.softtabstop = 4 -- 4 spaces per expanded tab
vim.o.textwidth = 78 -- wrap lines at 78 characters when pasting/formatting
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'css', 'html', 'lua', 'xhtml', 'xml', 'yaml'},
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'gitconfig', 'go', 'make'},
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 8
    vim.bo.softtabstop = 0
  end
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'hgcommit', 'gitcommit'},
  callback = function()
    vim.opt_local.formatoptions:append('t')
    vim.bo.textwidth = 72
  end
})

-- search
vim.o.ignorecase = true -- case-insensitive search
vim.o.smartcase = true -- case-sensitive with uppercase letters

-- backups
vim.o.backup = true -- enable backup files
-- only put backup files in the state folder (not alongside the actual file)
vim.o.backupdir = vim.fn.stdpath('state') .. '/backup//'
vim.o.swapfile = false -- disable swap file support
vim.o.undofile = true -- create undo files (in the state folder)

-- mappings
vim.g.mapleader = ',' -- prefix for global shortcuts
vim.g.maplocalleader = '\\' -- prefix for buffer-specific shortcuts
vim.keymap.set({'n', 'v', 'o'}, '<Leader>y', '"+y') -- os-level copy
vim.keymap.set({'n', 'v', 'o'}, '<Leader>p', '"+p') -- os-level paste
vim.keymap.set('c', '<C-a>', '<Home>') -- make ^A work in the command line
vim.keymap.set('n', '<Leader>q', '<Cmd>q<CR>') -- quit
vim.keymap.set('n', '<Leader>w', '<Cmd>w<CR>') -- save file
vim.keymap.set('n', '<Leader>x', '<Cmd>x<CR>') -- save and quit
vim.keymap.set('n', '<Leader>e', '<Esc>:e<Space>') -- open :e
-- toggle the file tree
vim.keymap.set('n', '<Leader>t', '<Cmd>Neotree toggle<CR>')
vim.keymap.set('n', '<Leader>f', FzfLua.files) -- open fuzzy file finder
vim.keymap.set('n', '<Leader>s', '<C-w>s') -- split window horizontally
vim.keymap.set('n', '<Leader>v', '<C-w>v') -- split window vertically
vim.keymap.set('n', '<Leader>o', '<C-w>o') -- close all other windows
-- turn off search highlights
vim.keymap.set('n', '<Leader><Space>', '<Cmd>noh<CR>')
vim.keymap.set('n', '<Leader><Tab>', '<Cmd>bn<CR>') -- next buffer
vim.keymap.set('n', '<Leader><S-Tab>', '<Cmd>bp<CR>') -- previous buffer
vim.keymap.set('n', '<Leader>c', '<Cmd>bd<CR>') -- close buffer
-- jump to definition
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
-- show references
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
-- jump to implementation(s) (of abstract classes)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
-- display information about the item under the cursor
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
-- rename variable/etc.
vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename)
-- show code action menu
vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action)
-- toggle diagnostic floating window
vim.keymap.set('n', 'ge', vim.diagnostic.open_float)
-- toggle diagnostic list
vim.keymap.set('n', '<Leader>d', '<Cmd>Trouble diagnostics toggle focus=true<CR>')
-- go to bufferline tab
vim.keymap.set('n', '<Leader>0', function() bufferline.go_to(-1, true) end)
for n=1,9 do
  vim.keymap.set('n', '<Leader>' .. n, function() bufferline.go_to(n, true) end)
end

-- nvim-treesitter-textobjects mappings
function select_textobject(group)
  return function()
    require('nvim-treesitter-textobjects.select').select_textobject(
      group, 'textobjects'
    )
  end
end
function goto_next_start(group)
  return function()
    require('nvim-treesitter-textobjects.move').goto_next_start(
      group, 'textobjects'
    )
  end
end
function goto_next_end(group)
  return function()
    require('nvim-treesitter-textobjects.select').goto_next_end(
      group, 'textobjects'
    )
  end
end
function goto_previous_start(group)
  return function()
    require('nvim-treesitter-textobjects.move').goto_previous_start(
      group, 'textobjects'
    )
  end
end
function goto_previous_end(group)
  return function()
    require('nvim-treesitter-textobjects.select').goto_previous_end(
      group, 'textobjects'
    )
  end
end
vim.keymap.set({'x', 'o'}, 'ac', select_textobject('@class.outer'))
vim.keymap.set({'x', 'o'}, 'ic', select_textobject('@class.inner'))
vim.keymap.set({'x', 'o'}, 'af', select_textobject('@function.outer'))
vim.keymap.set({'x', 'o'}, 'if', select_textobject('@function.inner'))
vim.keymap.set({'x', 'o'}, 'ab', select_textobject('@block.outer'))
vim.keymap.set({'x', 'o'}, 'ib', select_textobject('@block.inner'))
vim.keymap.set({'n', 'x', 'o'}, ']c', goto_next_start('@class.outer'))
vim.keymap.set({'n', 'x', 'o'}, ']f', goto_next_start('@function.outer'))
vim.keymap.set({'n', 'x', 'o'}, ']b', goto_next_start('@block.outer'))
vim.keymap.set({'n', 'x', 'o'}, ']C', goto_next_end('@class.outer'))
vim.keymap.set({'n', 'x', 'o'}, ']F', goto_next_end('@function.outer'))
vim.keymap.set({'n', 'x', 'o'}, ']B', goto_next_end('@block.outer'))
vim.keymap.set({'n', 'x', 'o'}, '[c', goto_previous_start('@class.outer'))
vim.keymap.set({'n', 'x', 'o'}, '[f', goto_previous_start('@function.outer'))
vim.keymap.set({'n', 'x', 'o'}, '[b', goto_previous_start('@block.outer'))
vim.keymap.set({'n', 'x', 'o'}, '[C', goto_previous_end('@class.outer'))
vim.keymap.set({'n', 'x', 'o'}, '[F', goto_previous_end('@function.outer'))
vim.keymap.set({'n', 'x', 'o'}, '[B', goto_previous_end('@block.outer'))
