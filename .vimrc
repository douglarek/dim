set autowrite
set backspace=2
syntax on
filetype plugin on
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 ( option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

call plug#begin()
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries', 'for': 'go' }
Plug 'AndrewRadev/splitjoin.vim'
Plug 'SirVer/ultisnips'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'joshdick/onedark.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'honza/vim-snippets'
Plug 'roxma/nvim-completion-manager', { 'for': ['go', 'python'] }
if !has('nvim')
  Plug 'roxma/vim-hug-neovim-rpc', { 'for': ['go', 'python'] }
endif
Plug 'roxma/python-support.nvim', { 'for': 'python' }
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
call plug#end()

" leader key mapped to ',' not default '\'
" let mapleader = ","

" quickfix keymap
let g:go_list_type = "quickfix"

" run go run with key '\r'
autocmd FileType go nmap <leader>r  <Plug>(go-run)

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
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>


" toggle 'go test -coverprofile tempfile' with key '\c' and again remove it
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)

" use 'go fmt' with goimports
let g:go_fmt_command = "goimports"

" generate go struct tags witg camel case not default snake case
let g:go_addtags_transform = "camelcase"

" go check
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave = 1
let g:go_metalinter_deadline = "5s"

" switch between foo.go and foo_test.go keymap
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit') "a new vertical split
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split') " a new split view
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe') " new tab

" show identifier info in status bar automatically
let g:go_auto_type_info = 1

" automatically highlight matching identifiers
" let g:go_auto_sameids = 1


" use atom one dark theme
silent! colorscheme onedark

" enable strip whitespace on save
let g:better_whitespace_filetypes_blacklist=['go']
autocmd BufEnter * silent! EnableStripWhitespaceOnSave

" cd to current file path automatically
autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif

" \\ | FZF
if has('nvim')
  let $FZF_DEFAULT_OPTS .= ' --inline-info'
  " let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

nnoremap <silent> <expr> <Leader><Leader> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
nnoremap <silent> <Leader>C        :Colors<CR>
nnoremap <silent> <Leader><Enter>  :Buffers<CR>
nnoremap <silent> <Leader>ag       :Ag <C-R><C-W><CR>
nnoremap <silent> <Leader>AG       :Ag <C-R><C-A><CR>
xnoremap <silent> <Leader>ag       y:Ag <C-R>"<CR>
nnoremap <silent> <Leader>`        :Marks<CR>

" use ultisnips engine
let g:UltiSnipsSnippetsDir = $HOME.'/.vim/plugged/vim-snippets/UltiSnips'

" nvim-completion-manager cr keymap
imap <expr> <CR>  (pumvisible() ?  "\<c-y>\<Plug>(cm_inject_snippet)\<Plug>(expand_or_nl)" : "\<CR>")
" here assuming ultisnips default expand key is tab
imap <expr> <Plug>(expand_or_nl) (has_key(v:completed_item,'snippet')?"\<tab>":"\<CR>")

" for python completions
let g:python_support_python2_require = 0
let g:python_support_python3_require = 0
let g:python_support_python3_requirements = add(get(g:,'python_support_python3_requirements',[]),'jedi')
" language specific completions on markdown file
let g:python_support_python3_requirements = add(get(g:,'python_support_python3_requirements',[]),'mistune')
" utils, optional
let g:python_support_python3_requirements = add(get(g:,'python_support_python3_requirements',[]),'psutil')
let g:python_support_python3_requirements = add(get(g:,'python_support_python3_requirements',[]),'setproctitle')

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
