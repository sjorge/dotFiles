set nocompatible                  " Must come first because it changes other options.
syntax enable                     " Turn on syntax highlighting.
filetype plugin on                " Turn on file type detection.
set showcmd                       " Display incomplete commands.
set showmode                      " Display the mode you're in.
set backspace=indent,eol,start    " Intuitive backspacing.
set hidden                        " Handle multiple buffers better.
set wildmenu                      " Enhanced command line completion.
set wildmode=list:longest         " Complete files like a shell.
set incsearch                     " Highlight matches as you type.
set hlsearch                      " Highlight matches.
set wrap                          " Turn on line wrapping.
set modeline                      " Allow per file config
set modelines=3                   " Modeline should be one of the last 3 lines
set bg=dark                       " pastel colors

set expandtab                     " expand tabs to spaces
set shiftwidth=4                  " set index to 4 spaces
set softtabstop=4                 " tab inserts 4 spaces
set autoindent                    " auto indent
set paste                         " easier pasting with indents

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" keep cursor position
augroup LastPosition
    autocmd! BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     exe "normal! g`\"" |
        \ endif
augroup END

" multi session undo
if has('persistent_undo') && exists("&undodir")
    set undodir=$HOME/.config/vim/undo//    " Location of undofiles
    set undofile                            " Enable undofile
    set undolevels=500                      " Max undos stored
    set undoreload=10000                    " Buffer stored undos
endif
