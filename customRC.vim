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
nnoremap <silent> <S-w> :bd<CR>

nnoremap <silent> <M-Left> <C-o>
nnoremap <silent> <M-Right> <C-i>

autocmd BufWritePre * :%s/\s\+$//e

let g:airline#extensions#tabline#enabled = 0

set background=dark
colors serenade

nnoremap <silent> <char-62> :BufferLineCycleNext<CR>
nnoremap <silent> <char-60> :BufferLineCyclePrev<CR>
nnoremap <silent> <C-j> <S-}>
nnoremap <silent> <C-k> <S-{>

lua require("lsp_signature").setup{}

lua require("bufferline").setup{}

inoremap <S-Tab> <C-d>

set completeopt=menu,menuone,noselect

lua <<EOF
  vim.g.mapleader = " "

  require("telescope").setup{}
  local t_builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', t_builtin.find_files, {})
  vim.keymap.set('n', '<leader>fg', t_builtin.live_grep, {})
  vim.keymap.set('n', '<leader>fb', t_builtin.buffers, {})
  vim.keymap.set('n', '<leader>fh', t_builtin.help_tags, {})

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end

  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
      ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'path' }
    })
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

  local lspconfig = require('lspconfig')

  lspconfig['pyright'].setup { capabilities = capabilities }
  lspconfig['rnix'].setup { capabilities = capabilities }
  lspconfig['vimls'].setup { capabilities = capabilities }
EOF
