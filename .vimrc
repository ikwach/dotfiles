set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Keep Plugin commands between vundle#begin/end.
Plugin 'tpope/vim-fugitive'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

Plugin 'sonph/onehalf'                      "theme
Plugin 'joshdick/onedark.vim'   		        "theme
Plugin 'altercation/vim-colors-solarized'  	"theme
Plugin 'jpo/vim-railscasts-theme'		        "theme
Plugin 'lifepillar/vim-solarized8'		      "theme
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'sjl/gundo.vim'
Plugin 'gorodinskiy/vim-coloresque'
Plugin 'dracula/vim' 				                "theme
Plugin 'Chiel92/vim-autoformat'
Plugin 'sheerun/vim-polyglot'			          "all langs in one - can be a reason for problems
Plugin 'sheerun/vim-wombat-scheme'		      "theme
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/nerdtree'
Plugin 'xuyuanp/nerdtree-git-plugin'
Plugin 'bronson/vim-trailing-whitespace'	"can cause problems
"Plugin 'w0rp/ale'				                  "ASYNCHRONOUS LINT ENGINE
"Plugin 'scrooloose/syntastic'			      " also error checcker to try
Plugin 'junegunn/fzf'
Plugin 'prettier/vim-prettier'
Plugin 'mattn/emmet-vim'			            " Type the abbreviation as 'div>p#foo$*3>a' and type '<c-y>,'
"Plugin 'valloric/youcompleteme'			    " visual autocomplete - canmake
"the engine.
Plugin 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'
Plugin 'scrooloose/nerdcommenter'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" " Trigger configuration. Do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

"Prettier
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" LINTERS
"let g:ale_linters = {
      "\  'javascript': ['eslint'],
      "\  'jsx': ['eslint']
      "\}
"let g:ale_fixers = {
      "\  'javascript': ['eslint'],
      "\  'jsx': ['eslint']
      "\}
"let g:ale_sign_column_always = 1
"let g:ale_sign_error = '✘'
"let g:ale_sign_warning = '⚠'
"highlight ALEErrorSign ctermbg=NONE ctermfg=red
"highlight ALEWarningSign ctermbg=NONE ctermfg=yellow

""" here are SETs
let g:gitgutter_max_signs = 900
highlight GitGutterAdd    guifg=#009900 guibg=#073642 ctermfg=2 ctermbg=0
highlight GitGutterChange guifg=#bbbb00 guibg=#073642 ctermfg=3 ctermbg=0
highlight GitGutterDelete guifg=#ff2222 guibg=#073642 ctermfg=1 ctermbg=0
let g:gitgutter_sign_added = '●'
let g:gitgutter_sign_modified = '●'
let g:gitgutter_sign_removed = '●'
let g:gitgutter_sign_modified_removed = '●'
"let g:airline_theme='solarized_flood'
let g:airline_theme='onedark'
syntax enable
set number
set background=dark
let g:solarized_termcolors=256
colorscheme onedark
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif


set ts=4 sw=4
" Disable strange Vi defaults.
set nocompatible

" Turn on filetype plugins (:help filetype-plugin).
if has('autocmd')
  filetype plugin indent on
endif

" Enable syntax highlighting.
if has('syntax')
  syntax enable
endif

" Autoindent when starting new line, or using `o` or `O`.
set autoindent

" Allow backspace in insert mode.
set backspace=indent,eol,start

" Don't scan included files. The .tags file is more performant.
set complete-=i

" Use 'shiftwidth' when using `<Tab>` in front of a line.
" By default it's used only for shift commands (`<`, `>`).
set smarttab

" Disable octal format for number processing.
set nrformats-=octal

" Allow for mappings including `Esc`, while preserving
" zero timeout after pressing it manually.
" (it only nvim needs fixing this)
if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

" Enable highlighted case-insensitive incremential search.
set incsearch

" Indent using two spaces.
set tabstop=2
set shiftwidth=2
set expandtab

" Use `Ctrl-L` to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

" Always show window statuses, even if there's only one.
set laststatus=2

" Show the line and column number of the cursor position.
set ruler

" Autocomplete commands using nice menu in place of window status.
" Enable `Ctrl-N` and `Ctrl-P` to scroll through matches.
set wildmenu

" When 'wrap' is on, display last line even if it doesn't fit.
set display+=lastline

" Force utf-8 encoding
set encoding=utf-8

" Set default whitespace characters when using `:set list`
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

" Delete comment character when joining commented lines
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j
endif

" Search upwards for tags file instead only locally
if has('path_extra')
  setglobal tags-=./tags tags^=./tags;
endif

" Reload unchanged files automatically.
set autoread

" Increase history size to 1000 items.
set history=1000

" Allow for up to 50 opened tabs on Vim start.
set tabpagemax=50

" Always save upper case variables to viminfo file.
set viminfo^=!

" Enable undofile and set undodir and backupdir
let s:dir = has('win32') ? '$APPDATA/Vim' : isdirectory($HOME.'/Library') ? '~/Library/Vim' : empty($XDG_DATA_HOME) ? '~/.local/share/vim' : '$XDG_DATA_HOME/vim'
let &backupdir = expand(s:dir) . '/backup//'
let &undodir = expand(s:dir) . '/undo//'
set undofile

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" `Ctrl-U` in insert mode deletes a lot. Use `Ctrl-G` u to first break undo,
" so that you can undo `Ctrl-U` without undoing what you typed before it.
inoremap <C-U> <C-G>u<C-U>

" Avoid problems with fish shell
" ([issue](https://github.com/tpope/vim-sensible/issues/50)).
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/bin/bash
endif

"" Extras

" Set monako font if using macvim
if has("gui_macvim")
  set guifont=Monaco:h13
endif

" Keep flags when repeating last substitute command.
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Y yanks from the cursor to the end of line as expected. See :help Y.
nnoremap Y y$

" Automatically create directories for backup and undo files.
if !isdirectory(expand(s:dir))
  call system("mkdir -p " . expand(s:dir) . "/{backup,undo}")
end

" Highlight line under cursor. It helps with navigation.
set cursorline

" Keep 8 lines above or below the cursor when scrolling.
set scrolloff=8

" Keep 15 columns next to the cursor when scrolling horizontally.
set sidescroll=1
set sidescrolloff=15

" Set minimum window size to 79x5.
set winwidth=79
set winheight=5
set winminheight=5

" If opening buffer, search first in opened windows.
set switchbuf=usetab

" Hide buffers instead of asking if to save them.
set hidden

" Wrap lines by default
set wrap linebreak
set showbreak=" "

" Allow easy navigation between wrapped lines.
vmap j gj
vmap k gk
nmap j gj
nmap k gk

" For autocompletion, complete as much as you can.
set wildmode=longest,full

" Show line numbers on the sidebar.
set number

" Disable any annoying beeps on errors.
set noerrorbells
set visualbell

" Don't parse modelines (google "vim modeline vulnerability").
set nomodeline

" Do not fold by default. But if, do it up to 3 levels.
set foldmethod=indent
set foldnestmax=3
set nofoldenable

" Enable mouse for scrolling and window resizing.
set mouse=a

" Disable swap to prevent annoying messages.
set noswapfile

" Save up to 100 marks, enable capital marks.
set viminfo='100,f1

" Enable search highlighting.
set hlsearch

" Ignore case when searching.
set ignorecase

" Show mode in statusbar, not separately.
set noshowmode

" Don't ignore case when search has capital letter
" (although also don't ignore case by default).
set smartcase

" Use dash as word separator.
set iskeyword+=-

" Add gems.tags to files searched for tags.
set tags+=gems.tags

" Disable output, vcs, archive, rails, temp and backup files.
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
set wildignore+=*.swp,*~,._*

" Auto center on matched string.
noremap n nzz
noremap N Nzz

" Visually select the text that was last edited/pasted (Vimcast#26).
noremap gV `[v`]

" Expand %% to path of current buffer in command mode.
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Enable saving by `Ctrl-s`
nnoremap <C-s> :w<CR>
inoremap <C-s> <ESC>:w<CR>

" Use Q to intelligently close a window
" (if there are multiple windows into the same buffer)
" or kill the buffer entirely if it's the last window looking into that buffer.
function! CloseWindowOrKillBuffer()
  let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))
  if matchstr(expand("%"), 'NERD') == 'NERD'
    wincmd c
    return
  endif
  if number_of_windows_to_this_buffer > 1
    wincmd c
  else
    bdelete
  endif
endfunction
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<CR>

" Set window title by default.
set title

" Always focus on splited window.
set splitright
set splitbelow

" Don't display the intro message on starting Vim.
set shortmess+=I

" Use Silver Searcher for CtrlP plugin (if available)
" Fallback to git ls-files for fast listing.
" Because we use fast strategies, disable caching.
let g:ctrlp_use_caching = 0
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
    let g:ctrlp_user_command = 'cd %s && ag -l --nocolor -g ""'
else
  let g:ctrlp_user_command = ['.git',
    \ 'cd %s && git ls-files . -co --exclude-standard',
    \ 'find %s -type f' ]
endif

" Accept CtrlP selections also with <Space>
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': ['<Space>', '<CR>', '<2-LeftMouse>'],
  \ }

" Make sure pasting in visual mode doesn't replace paste buffer
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()

" Prevent common mistake of pressing q: instead :q
map q: :q

" Make a simple "search" text object.
" http://vim.wikia.com/wiki/Copy_or_change_search_hit
" It allows for replacing search matches with cs and then /././.
vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
    \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
omap s :normal vs<CR>

" Disable writebackup because some tools have issues with it:
" https://github.com/neoclide/coc.nvim/issues/649
set nowritebackup

" Reduce updatetime from 4000 to 300 to avoid issues with coc.nvim
set updatetime=300

" Auto reload if file was changed somewhere else (for autoread)
au CursorHold * checktime

" Enable loading filetype plugins
filetype plugin on

