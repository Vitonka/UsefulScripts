" Romka's .vimrc, borrowed from ignat@ and slightly modified =)
" execute pathogen#infect()

" This setting prevents vim from emulating the original vi's
" bugs and limitations.
set nocompatible

" The first setting tells vim to use "autoindent" (that is,
" use the current line's indent level to set the indent level of new lines).
" The second makes vim attempt to intelligently guess the indent level of
" any new line based on the previous line, assuming the source file is
" in a C-like language.
set autoindent
set smartindent

" All indents are 4-spaces. Don't use tab.
set tabstop=4
set shiftwidth=2
set softtabstop=4
set expandtab

" set foldmethod=syntax
" set foldcolumn=5

" This setting will cause the cursor to very briefly jump to
" a brace/parenthese/bracket's "match" whenever you type a closing or
" opening brace/parenthese/bracket.
" set showmatch

" Turns off any errors
set noerrorbells
set novisualbell
set vb t_vb=

" Makes awesome statusline
set ruler
set laststatus=2
set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P

" Turns off search highlighting.
set nohls
set incsearch

" Turn on syntax highlighting.
syntax on

" Change highlight theme to more comfortable
set bg=dark

" Turn on file autosave. CTRL+Z apply this to all opened files.
set autowrite

" Change space on page down and backspace on page up for scrolling
noremap <Space> <C-D>
noremap <BS> <C-U>

" End file viewing
map § <C-^>
imap § <C-^>

" Highlight very long lines and trailing spaces
" highlight BAD_FORMATTING ctermbg=red
" autocmd Syntax * syntax match BAD_FORMATTING /\s\+$\|\t\|.\{79\}/ containedin=ALL
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Allow to copy text to clipboard using cc command
map cc :w !pbcopy

" Allow backspace to delete all symbols
set backspace=indent,eol,start
set whichwrap+=<,>,h,l

set cpoptions=aABceFsmq
"             |||||||||
"             ||||||||+-- When joining lines, leave the cursor
"             |||||||      between joined lines
"             |||||||+-- When a new match is created (showmatch)
"             ||||||      pause for .5
"             ||||||+-- Set buffer options when entering the
"             |||||      buffer
"             |||||+-- :write command updates current file name
"             ||||+-- Automatically add <CR> to the last line
"             |||      when using :@r
"             |||+-- Searching continues at the end of the match
"             ||      at the cursor position
"             ||+-- A backslash has no special meaning in mappings
"             |+-- :write updates alternative file name
"             +-- :read updates alternative file name

" Always switch to the current file directory
set autochdir

" None of these are word dividers
set iskeyword+=_,$,@,%,#

" Vim remembers 500 commands
set history=500

" Set 7 lines to the curors - when moving vertical..
set scrolloff=7

" Autoread file when it changes
set autoread

" Add executable mode to bash and python scripts
function! SetExecutableMode()
    if getline(1) =~ "^#!"
        if getline(1) =~ "/bin/"
            " silent !chmod a+x <afile>
        endif
    endif
endfunction

autocmd BufWritePost * call SetExecutableMode()

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Shortcut for saving
nmap <leader>w :w!<cr>

" Shortcut for set on/off list
function! ChangeList()
    if &list
        set nolist
    else
        set list
    endif
endfunction

map <leader>l :call ChangeList()<CR>

" Shortcut for set on/off paste
function! ChangePaste()
    if &paste
        set nopaste
    else
        set paste
    endif
endfunction

map <leader>p :call ChangePaste()<CR>

" Shortcut to expand tab
function! ChangeTab()
    if &expandtab
        set noexpandtab
    else
        set expandtab
    endif
endfunction

map <leader>t :call ChangeTab()<CR>

" Shortcut for replace
map <leader>r :%s///gc<left><left><left><left>

" Awesome search by ack-grep
map <leader>s :! ack-grep <right>

" When vimrc is edited, reload it
autocmd! BufWritePost .vimrc source ~/.vimrc

" Shortcuts to make program
set makeprg=make
map <C-B> :w<CR>:make<CR>
imap <C-B> <ESC>:w<CR>:make<CR>

" Turn on nice python highlight
let python_highlight_all = 1
au FileType python syn keyword pythonDecorator True None False self


" In visual mode when you press * or # to search for the current selection
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>

" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSearch('gv')<CR>
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

" From an idea by Michael Naumann
function! VisualSearch(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

function! ResCur()
if line("'\"") <= line("$")
    normal! g`"
return 1
endif
    endfunction

    augroup resCur
    autocmd!
autocmd BufWinEnter * call ResCur()
    augroup END

set mouse=a

function! InsertTabWrapper(direction)
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    elseif "backward" == a:direction
        return "\<c-p>"
    else
        return "\<c-n>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper ("forward")<cr>
inoremap <s-tab> <c-r>=InsertTabWrapper ("backward")<cr>

let c_no_curly_error=1
:autocmd CursorMoved * highlight UnderCursor ctermbg=236
:autocmd CursorMoved * exe printf('match UnderCursor /\V\<%s\>/', escape(expand('<cword>'), '/\'))

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                YouCompleteMe                            "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_confirm_extra_conf = 0
let g:ycm_use_ultisnips_completer = 0
let g:ycm_complete_in_comments = 1
let g:ycm_goto_buffer_command = 'new-tab'
let g:ycm_error_symbol = '☓'
let g:ycm_warning_symbol = '☝'
let g:ycm_filetype_specific_completion_to_disable = {
    \ 'csv' : 1,
    \ 'diff' : 1,
    \ 'gitcommit' : 1,
    \ 'help' : 1,
    \ 'infolog' : 1,
    \ 'mail' : 1,
    \ 'markdown' : 1,
    \ 'notes' : 1,
    \ 'pandoc' : 1,
    \ 'qf' : 1,
    \ 'svn' : 1,
    \ 'tagbar' : 1,
    \ 'text' : 1,
    \ 'unite' : 1,
    \ 'vimwiki' : 1
    \}
autocmd FileType c,cpp,python nnoremap <buffer> <C-]> :YcmCompleter GoTo<CR>
autocmd FileType c,cpp,python nnoremap <buffer> <F10> :YcmDiags<CR>

au BufRead,BufNewFile *.launch set filetype=xml
