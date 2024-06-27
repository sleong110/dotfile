set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'morhetz/gruvbox'
Plugin 'fatih/vim-go'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'nvim-lua/popup.nvim'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'nvim-telescope/telescope.nvim'
Plugin 'nvim-telescope/telescope-fzy-native.nvim'
Plugin 'svermeulen/vimpeccable'
Plugin 'kyazdani42/nvim-web-devicons'
Plugin 'kyazdani42/nvim-tree.lua'
Plugin 'tpope/vim-commentary'
Plugin 'hashivim/vim-terraform'
Plugin 'jparise/vim-graphql'
Plugin 'jameshuynh/auto-save.nvim'
Plugin 'avakhov/vim-yaml'
Plugin 'pangloss/vim-javascript'
Plugin 'tpope/vim-surround'
Plugin 'svermeulen/vim-easyclip'
call vundle#end()
filetype plugin indent on

set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set autowrite

" Go syntax highlighting
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

" Auto formatting and importing
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

autocmd vimenter * ++nested colorscheme gruvbox

set number 			" Display line numbers beside buffer
set nocompatible		" Don't maintain compatibility with Vi
set hidden			" Allow buffer change w/o saving
set lazyredraw			" Don't update while executing marcros
set backspace=indent,eol,start	" Sane backsapce behavior
set history=1000		" Remember last 1000 commands
set scrolloff=4			" Keep at least 4 lines below cursor

syntax on

let mapleader = ","
nnoremap <c-p> <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

lua << EOF
local actions = require("telescope.actions")
require('telescope').setup{
  defaults = {
    file_ignore_patterns = {'vendor', 'node_modules'},
    mappings = {
      i = {
        ["<Esc>"] = actions.close,
      },
    },
  },
  extensions = {
		fzy_native = {
			override_generic_sorter = false,
			override_file_sorter = true,
		},
	},
}
require("telescope").load_extension("fzy_native")
EOF

lua << EOF
local vimp = require('vimp')
local isEmpty = function(s)
  return s == nil or s == ''
end

local searchForText = function()
  local keyword = vim.fn.input('> ')
  if not isEmpty(keyword) then
    require('telescope.builtin').grep_string({ search = keyword })
  end
end

vimp.nnoremap('\\', function()
  searchForText()
end)
vimp.nmap('<leader>lg', ':Telescope live_grep<CR>')
require('nvim-tree').setup {
  open_on_setup = false,
  open_on_setup_file = false,
  open_on_tab = false,
  filters = {
    dotfiles = true,
    custom = {},
    exclude = {".envrc", ".env", ".env.dev"},
  },
  git = {
    enable = false,
    ignore = true,
    timeout = 400,
  },
  actions = {
    change_dir = {
      enable = true,
      global = false,
      restrict_above_cwd = false,
    },
    open_file = {
      resize_window = true,
    },
  },
  hijack_directories = {
    enable = true,
    auto_open = false
  }
}
local smartNvimTreeFindFile = function()
  local currentFile = vim.api.nvim_buf_get_name(0)
  if vim.fn.isdirectory(currentFile) == 1 or currentFile == "" then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(
        ':NvimTreeToggle<CR>', true, false, true), 'n', true)
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(
        ':NvimTreeFindFile<CR>',true,false,true), 'n', true)
  end
end

vimp.nnoremap('<Leader>ne', ':NvimTreeToggle<CR>')
vimp.nnoremap('<Leader>nf', function()
  smartNvimTreeFindFile()
end)
vim.opt.clipboard = 'unnamedplus'

-- open vimrc in a horizontal split
vimp.nnoremap('<Leader>vr', ':sp $MYVIMRC<CR>')

-- Select all
vimp.nmap('<Leader>sa', ':<esc>ggVG')

-- Copy all
vimp.nmap('<Leader>ca', ':<esc>:%y+<CR>')

local autosave = require("AutoSave")
autosave.setup({
  enabled = true,
  execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
  events = {"InsertLeave", "TextChanged"},
  conditions = {
    exists = true,
    filename_is_not = {},
    filetype_is_not = {},
    modifiable = true
  },
  write_all_buffers = false,
  on_off_commands = true,
  clean_command_line_interval = 0,
  debounce_delay = 135
})

vimp.nmap({'silent'}, '<Leader>je', ':%!jq .<CR>')
vimp.nmap({'silent'}, '<Leader>jc', ':%!jq -c .<CR>')
vim.wo.relativenumber = true
EOF

nnoremap <leader>jt :! jsctags -o tags server test admin<CR>
