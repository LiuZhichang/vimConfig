let mapleader=" "
  
call plug#begin('~/.nvim/plugged')
Plug 'Chiel92/vim-autoformat'
Plug 'skywind3000/asyncrun.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'luochen1990/rainbow'
Plug 'honza/vim-snippets'
Plug 'Yggdroot/LeaderF'
Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'kristijanhusak/defx-icons'
Plug 'liuchengxu/vista.vim'
Plug 'tpope/vim-fugitive'

"Plug 'octol/vim-cpp-enhanced-highlight'
call plug#end()

"------------------------------ autoformat
"
let g:formatdef_my_cpp = '"astyle --style=google --pad-oper "'
let g:formatters_cpp = ['my_cpp']

"------------------------------ asyrun
"
let g:asyncrun_open = 15
let g:asyncrun_bell = 0
nnoremap <F10> :call asyncrun#quickfix_toggle(12)<cr>
nnoremap <silent> <F3> :AsyncRun cmake . <cr>
nnoremap <silent> <F4> :AsyncRun make <cr>
nnoremap <silent> <F5> :AsyncRun g++ "$(VIM_FILEPATH)"  -std=c++2a -o "../build/$(VIM_FILENOEXT)" -g  <cr>
nnoremap <silent> <F6> :AsyncRun -raw -cwd=$(VIM_FILEDIR) "../build/$(VIM_FILENOEXT)" <cr>
nnoremap <silent> <F7> :AsyncRun zsh "./$(VIM_FILENOEXT).sh" <cr>
nnoremap <silent> <F12> :AsyncRun lua "./$(VIM_FILENOEXT).lua" <cr>
let g:asyncrun_rootmarks = ['.svn', '.git', '.root', '_darcs', 'build.xml']

"------------------------------ cocvim
"
nmap <silent>g] <Plug>(coc-definition)
nmap <silent>gy <Plug>(coc-type-definition)
nmap <silent>gr <Plug>(coc-references)
nmap <leader>es <Plug>(coc-diagnostic-info)
nmap <leader>en <Plug>(coc-diagnostic-next-error)
nmap <leader>ep <Plug>(coc-diagnostic-prev-error)
nmap <leader>qf  <Plug>(coc-fix-current)
nmap <Leader>r :CocCommand clangd.switchSourceHeader<CR>
nmap <Leader>t <Plug>(coc-translator-p)
vmap <Leader>t <Plug>(coc-translator-pv)
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

"------------------------------ airline
"
let g:airline_theme= "tomorrow"
" 设置状态栏
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
 " 关闭状态显示空白符号计数
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#whitespace#symbol = '!'
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
"let g:airline_section_b = '%{strftime("%m/%d/%y - %H:%M")}'
let g:airline_left_sep = '▶'
let g:airline_left_alt_sep = '❯'
let g:airline_right_sep = '◀'
let g:airline_right_alt_sep = '❮'
nnoremap [b :bp<CR>
nnoremap ]b :bn<CR>
" 设置切换tab的快捷键 <\> + <i> 切换到第i个 tab
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9


"------------------------------- rainbow
"
let g:rainbow_active = 1
let g:rainbow_conf = {
\   'guifgs': ['darkorange3', 'seagreen3', 'royalblue3', 'firebrick'],
\   'ctermfgs': ['lightyellow', 'lightcyan','lightblue', 'lightmagenta'],
\   'operators': '_,_',
\   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\   'separately': {
\       '*': {},
\       'tex': {
\           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
\       },
\       'lisp': {
\           'guifgs': ['darkorange3', 'seagreen3', 'royalblue3', 'firebrick'],
\       },
\       'vim': {
\           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
\       },
\       'html': {
\           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\       },
\       'css': 0,
\   }
\}

"-------------------------------- leaderF
"
noremap <leader>l :LeaderfLine		<cr>
noremap <leader>f :LeaderfFunction	<cr>
noremap <leader>F :LeaderfFile		<cr>
noremap <leader>n :LeaderfMru		<cr>

let g:Lf_WildIgnore = {
            \ 'dir': ['.svn','.git','.hg','.vscode','.wine','.deepinwine','.oh-my-zsh'],
            \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
            \}

" 按Esc键退出函数列表
let g:Lf_NormalMap = {
	\ "File":			[["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"			<CR>']],
	\ "Buffer":			[["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"			<CR>']],
	\ "Mru":			[["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"			<CR>']],
	\ "Tag":			[["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"			<CR>']],
	\ "Function":		[["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"		<CR>']],
	\ "Colorscheme":    [["<ESC>", ':exec g:Lf_py "colorschemeExplManager.quit()"	<CR>']],
	\ }

let g:Lf_HideHelp = 1
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 0
let g:Lf_IgnoreCurrentBufferName = 1
let g:Lf_RootMarkers = ['.project','.root','.svn','.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePaht = 0
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function':0,'BufTag':0}


"----------------------------------- dixygenTookit
"
let g:DoxygenToolkit_authorName="Liu zhichang"
let g:DoxygenToolkit_paramTag_pre="@param[in] "
noremap <leader>df : Dox <CR>

"----------------------------------- defx
"
call defx#custom#option('_', {
      \ 'winwidth': 40,
      \ 'split': 'vertical',
      \ 'direction': 'topleft',
      \ 'show_ignored_files': 0,
      \ 'buffer_name': '',
      \ 'toggle': 1,
      \ 'resume': 1
      \ })
autocmd FileType defx call s:defx_mappings()

function! s:defx_mappings() abort
  nnoremap <silent><buffer><expr> l     <SID>defx_toggle_tree()                    " 打开或者关闭文件夹，文件
  nnoremap <silent><buffer><expr> .     defx#do_action('toggle_ignored_files')     " 显示隐藏文件
  nnoremap <silent><buffer><expr> <C-r>  defx#do_action('redraw')
endfunction

function! s:defx_toggle_tree() abort
	" Open current file, or toggle directory expand/collapse
	if defx#is_directory()
		return defx#do_action('open_or_close_tree')
	endif
	return defx#do_action('multi', ['drop'])
endfunction

noremap <silent> <F8> :Defx <cr>

"---------------------------------- vista
"
function! NearestMethodOrFunction() abort
	return get(b:, 'vista_nearest_method_or_function', '')
endfunction
set statusline+=%{NearestMethodOrFunction()}
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
let g:vista_fzf_preview = ['right:50%']
let g:vista#renderer#enable_icon = 1
let g:vista_default_executive = 'ctags'
let g:vista_executive_for = {
  \ 'cpp': 'coc',
  \ }
let g:vista_ctags_cmd = {
			\ 'haskell': 'hasktags -x -o - -c',
			\ }
let g:vista#renderer#icons = {
\   "function": "\uf794",
\   "variable": "\uf71b",
\  }
noremap <silent> <F9> :<C-u>Vista!!<cr>


"----------------------------------- config
"
set nu
syntax on
filetype on
filetype plugin on
filetype indent on
color xcode-dark
set t_Co=256
set autoread
set autowrite
set confirm
set nocompatible
set mouse=a
set cursorline
set ruler
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
"set autoindent
set cindent
set smarttab
set history=200
set ignorecase
set laststatus=2
set langmenu=zh_CN.UTF-8
set enc=utf-8
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
set wildmenu
set fillchars=vert:\ ,stl:\ ,stlnc:\
set scrolloff=2
set clipboard=unnamed
set nobackup
set noswapfile
set signcolumn=yes

"hi Normal ctermfg=252 ctermbg=none
hi Comment ctermfg =13
hi Pmenu ctermfg=141 ctermbg=236 guifg=#9a9aba guibg=#34323e                             
"hi Pmenu ctermfg=141 ctermbg=236 guifg=#9a9aba guibg=#34323e                             
"hi PmenuSel ctermfg=251 ctermbg=97 guifg=#c6c6c6 guibg=#875faf                           
"hi PmenuSbar ctermfg=28 ctermbg=233 guifg=#c269fe guibg=#303030
"hi PmenuThumb ctermfg=160 ctermbg=97 guifg=#e0211d guibg=#875faf
"
"
autocmd FileType c,cpp,sh,java,html,js,css,py exec ":call flzt#AutoCompleteSymbol()"
autocmd FileType c,cpp exec "call flzt#InitFlzt()"
