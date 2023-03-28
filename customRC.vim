set nu rnu
set encoding=utf-8
set expandtab shiftwidth=4
set termguicolors
set clipboard=unnamed
set list listchars=trail:·

set mouse=a

set nocindent nosmartindent noautoindent
filetype indent off

nnoremap <S-Up> :m-2<CR>
nnoremap <S-Down> :m+<CR>

inoremap <S-Up> <Esc>:m-2<CR>
inoremap <S-Down> <Esc>:m+<CR>

nnoremap <silent> <A-z> :NERDTreeToggle<CR>

nnoremap <F2> :lua vim.lsp.buf.rename()<CR>
inoremap <F2> <Esc>:lua vim.lsp.buf.rename()<CR>

nnoremap <silent> <F12> :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <S-F12> :lua vim.lsp.buf.references()<CR>
nnoremap <silent> <S-q> :q<CR>

nnoremap <silent> <M-Left> <C-o>
nnoremap <silent> <M-Right> <C-i>

autocmd BufWritePre * :%s/\s\+$//e

let g:airline#extensions#tabline#enabled = 0

set background=dark

nnoremap <silent> <char-62> :BufferLineCycleNext<CR>
nnoremap <silent> <char-60> :BufferLineCyclePrev<CR>

inoremap <S-Tab> <C-d>

set completeopt=menu,menuone,noselect
set laststatus=3
