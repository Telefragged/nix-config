set rnu
set encoding=utf-8
set expandtab shiftwidth=4
set termguicolors
set clipboard=unnamed
set list listchars=trail:·

set mouse=a

nnoremap <S-Up> :m-2<CR>
nnoremap <S-Down> :m+<CR>
inoremap <S-Up> <Esc>:m-2<CR>
inoremap <S-Down> <Esc>:m+<CR>

nnoremap <silent> <A-z> :NERDTreeToggle<CR>

nnoremap <F2> :lua vim.lsp.buf.rename()<CR>
inoremap <F2> <Esc>:lua vim.lsp.buf.rename()<CR>

nnoremap <silent> <F12> :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <S-w> :bd<CR>

nnoremap <silent> <M-Left> <C-o>
nnoremap <silent> <M-Right> <C-i>

autocmd BufWritePre * :%s/\s\+$//e

set background=dark
colors gruvbox

call ddc#custom#patch_global('sources', ['nvim-lsp', 'around'])

call ddc#custom#patch_global('sourceOptions', {
    \ '_': {
    \   'matchers': ['matcher_fuzzy'],
    \   'sorters': ['sorter_fuzzy'],
    \   'converters': ['converter_fuzzy']},
    \ })

" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ pumvisible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

call ddc#enable()

lua require'lspconfig'.rnix.setup{}
