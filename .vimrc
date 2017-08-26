if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" vim-plug
if !has('python3')
  echo "ensure you have installed python3 and execute `pip install neovim`"
  finish
endif
" disable python 2 support
let g:loaded_python_provider = 1
call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries', 'on': [] }
Plug 'AndrewRadev/splitjoin.vim'
Plug 'SirVer/ultisnips'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'joshdick/onedark.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'honza/vim-snippets'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
function! BuildYCM(info)
  if a:info.status == 'installed' || a:info.force
    !./install.py --clang-completer --gocode-completer --racer-completer
  endif
endfunction
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM'), 'on': [] }
Plug 'rhysd/vim-clang-format', { 'on': [] }
Plug 'rust-lang/rust.vim', { 'on': [] }
Plug 'vim-syntastic/syntastic', { 'on': [] }
Plug 'tell-k/vim-autopep8', { 'for': ['python'] }
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'raimondi/delimitmate'
Plug 'mileszs/ack.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make', 'on': [] }
call plug#end()

" vim auto save
set autowrite
" enable mac delete key
set backspace=2
" close complete preview
set completeopt-=preview
" open at the same line number I closed it at last time
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
" cd to current file path automatically
autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif

if (empty($TMUX))
  if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" use atom one dark theme
silent! colorscheme onedark

" enable strip whitespace on save
let g:better_whitespace_filetypes_blacklist=['go']
autocmd BufEnter * silent! EnableStripWhitespaceOnSave

" use ultisnips engine
let g:UltiSnipsExpandTrigger="<nop>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:ulti_expand_or_jump_res = 0
function! ExpandSnippetOrCarriageReturn()
    let snippet = UltiSnips#ExpandSnippetOrJump()
    if g:ulti_expand_or_jump_res > 0
        return snippet
    else
        return "\<CR>"
    endif
endfunction
inoremap <expr> <CR> pumvisible() ? "\<C-R>=ExpandSnippetOrCarriageReturn()\<CR>" : "\<CR>"

" nerdcommenter
let g:NERDSpaceDelims = 1
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1

" \tt | NERD Tree
nnoremap <silent> <Leader>tt :NERDTreeToggle<cr>

" undotree
if has("persistent_undo")
  set undodir=~/.undodir/
  set undofile
endif
let g:undotree_WindowLayout = 2
nnoremap U :UndotreeToggle<CR>

" \gt | gitgutter
let g:gitgutter_enabled = 0
nnoremap <silent> <Leader>gt :GitGutterToggle<cr>

" ycm
function! SetYCM()
  let g:ycm_confirm_extra_conf = 0
  let g:ycm_always_populate_location_list = 1
  let g:ycm_autoclose_preview_window_after_completion = 1
  nnoremap <buffer> ]d :YcmCompleter GoTo<CR>
  call plug#load('YouCompleteMe')
endfunction

" syntastic
function! SetSyntastic()
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_check_on_wq = 0
  call plug#load('syntastic')
endfunction

" clang
function! SetClang()
  call SetYCM()
  nnoremap <buffer> K  :YcmCompleter GetType<CR>
  if !executable('clang-format')
    echom "clang-format is not installed"
  else
    let g:clang_format#style_options = {"BasedOnStyle": "LLVM", "IndentWidth": 4}
    call plug#load('vim-clang-format')
    ClangFormatAutoEnable
  endif
endfunction
autocmd FileType c,cpp call SetClang()

" deoplete-go
function! SetDeopleteGo()
  set completeopt+=noinsert
  set completeopt+=noselect
  call plug#load('deoplete-go')
endfunction

" vim-go
function! SetGolang()
  " quickfix keymap
  let g:go_list_type = "quickfix"

  " run go run with key '\r'
  nmap <leader>r  <Plug>(go-run)

  map <C-n> :cnext<CR>
  map <C-m> :cprevious<CR>
  nnoremap <leader>a :cclose<CR>

  " go test timeout
  let g:go_test_timeout = '10s'
  " run go test with key '\t'
  autocmd FileType go nmap <leader>t  <Plug>(go-test)

  " run :GoBuild or :GoTestCompile based on the go file
  function! s:build_go_files()
    let l:file = expand('%')
    if l:file =~# '^\f\+_test\.go$'
      call go#test#Test(0, 1)
    elseif l:file =~# '^\f\+\.go$'
      call go#cmd#Build(0)
    endif
  endfunction

  " run 'go build' with key '\b'
  nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

  " toggle 'go test -coverprofile tempfile' with key '\c' and again remove it
  nmap <Leader>c <Plug>(go-coverage-toggle)

  " use 'go fmt' with goimports
  let g:go_fmt_command = "goimports"

  " generate go struct tags witg camel case not default snake case
  let g:go_addtags_transform = "camelcase"

  " go check
  let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
  let g:go_metalinter_autosave = 1
  let g:go_metalinter_deadline = "5s"

  " switch between foo.go and foo_test.go keymap
  command! -bang A call go#alternate#Switch(<bang>0, 'edit')
  command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit') "a new vertical split
  command! -bang AS call go#alternate#Switch(<bang>0, 'split') " a new split view
  command! -bang AT call go#alternate#Switch(<bang>0, 'tabe') " new tab

  " show identifier info in status bar automatically
  let g:go_auto_type_info = 1

  " automatically highlight matching identifiers
  " let g:go_auto_sameids = 1

  call plug#load('vim-go')
  call SetDeopleteGo()
endfunction
autocmd FileType go call SetGolang()

" rust
function! SetRust()
  if !executable('rustc')
    echom "rust is not installed"
  else
    let g:ycm_rust_src_path = substitute(system('rustc --print sysroot'), '\n\+$', '', '') . "/lib/rustlib/src/rust/src"
    if v:shell_error
      echom "failed when rustc --print sysroot"
    endif
  endif
  call SetYCM()
  nnoremap <buffer> K  :YcmCompleter GetType<CR>
  let g:syntastic_rust_checkers = ['cargo']
  call SetSyntastic()
  let g:rustfmt_autosave = 1
  call plug#load('rust.vim')
endfunction
autocmd FileType rust call SetRust()

" python
function! SetAutopep8()
  if !executable('autopep8')
    echom "autopep8 is not installed"
  else
    let g:autopep8_max_line_length = 99
    let g:autopep8_pep8_passes = 119
    let g:autopep8_disable_show_diff = 1
    call plug#load('vim-autopep8')
    autocmd BufWritePre *.py call Autopep8()
  endif
endfunction
function! SetPython()
  call SetYCM()
  if !executable('flake8')
    echom "flake8 is not installed"
  else
    let g:syntastic_python_checkers = ['flake8']
    let g:syntastic_python_flake8_args = '--max-line-length=119'
  call SetSyntastic()
  endif
  call SetAutopep8()
endfunction
autocmd FileType python call SetPython()

" ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" deoplete
let g:deoplete#enable_at_startup = 1

" vim: set expandtab sw=2:
