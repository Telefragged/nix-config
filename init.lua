vim.g.mapleader = " "

vim.keymap.set({ 'n', 'v' }, '<C-Up>', '<C-u>zz', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-Down>', '<C-d>zz', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>bf', vim.lsp.buf.format, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>g', ':Gedit :<CR>', { noremap = true, silent = true })

local dap = require('dap')
vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { noremap = true, silent = true })
vim.keymap.set('n', '<F5>', dap.continue, { noremap = true, silent = true })
vim.keymap.set('n', '<F10>', dap.step_over, { noremap = true, silent = true })
vim.keymap.set('n', '<F11>', dap.step_into, { noremap = true, silent = true })

require('nvim-dap-virtual-text').setup{}

require('copilot').setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
})

require("copilot_cmp").setup {}

require("lsp_signature").setup {}

require("bufferline").setup {}

require("telescope").setup {}
local t_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', t_builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', t_builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', t_builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', t_builtin.help_tags, {})

local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = {
        ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
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
        { name = 'path' },
        { name = 'copilot' },
    })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local lspconfig = require('lspconfig')

lspconfig['pyright'].setup { capabilities = capabilities }
lspconfig['rnix'].setup { capabilities = capabilities }
lspconfig['vimls'].setup { capabilities = capabilities }

local lua_settings = {
    Lua = {
        runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
        },
        diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' },
        },
        workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
            enable = false,
        },
    },
}

lspconfig['lua_ls'].setup { settings = lua_settings, capabilities = capabilities }

require("rust-tools").setup {
    dap = {
        adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
    },
}

local function close_buffer(force)
    if vim.bo.buftype == "terminal" then
        force = force or #vim.api.nvim_list_wins() < 2 and ":bd!"
        local swap = force and #vim.api.nvim_list_bufs() > 1 and ":bp | bd!" .. vim.fn.bufnr()
        return vim.cmd(swap or force or "hide")
    end

    local fileExists = vim.fn.filereadable(vim.fn.expand("%p"))
    local modified = vim.api.nvim_buf_get_option(vim.fn.bufnr(), "modified")

    -- if file doesnt exist & its modified
    if fileExists == 0 and modified then
        print("no file name? add it now!")
        return
    end

    force = force or not vim.bo.buflisted or vim.bo.buftype == "nofile"

    -- if not force, change to prev buf and then close current
    local close_cmd = force and ":bd!" or ":bp | bd" .. vim.fn.bufnr()
    vim.cmd(close_cmd)
end

vim.keymap.set("n", "<leader>x", close_buffer, { noremap = true, silent = true })
vim.cmd([[vnoremap <C-h> ""y:%s/<C-R>=escape(@", '/\')<CR>//g<Left><Left>]])

require('lightspeed').setup {}
