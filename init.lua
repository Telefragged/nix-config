vim.g.mapleader = " "

vim.opt.clipboard = "unnamedplus"

vim.opt.cursorline = true

vim.opt.signcolumn = "yes"

vim.keymap.set({ 'n', 'v' }, '<C-Up>', '<C-u>zz', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-Down>', '<C-d>zz', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-k>', '<C-u>zz', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-j>', '<C-d>zz', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>bf', vim.lsp.buf.format, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>gg', ':Gedit :<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gs', '<C-w>s:Gedit :<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gv', '<C-w>v:Gedit :<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>aa', vim.lsp.buf.hover, { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>ac', vim.lsp.buf.code_action, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { noremap = true, silent = true })

vim.keymap.set('n', '<C-w>z', '<C-w>|<C-w>_', { noremap = true, silent = true })

vim.keymap.set({ 'i', 'v' }, '<C-e>', '<Esc>', { noremap = true, silent = true })

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'fsharp' },
    command = 'setlocal commentstring=//\\ %s',
})

require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

local dap = require('dap')
vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { noremap = true, silent = true })
vim.keymap.set('n', '<F5>', dap.continue, { noremap = true, silent = true })
vim.keymap.set('n', '<F10>', dap.step_over, { noremap = true, silent = true })
vim.keymap.set('n', '<F11>', dap.step_into, { noremap = true, silent = true })

require('nvim-dap-virtual-text').setup {}

local dapui = require('dapui')
dapui.setup(nil)

vim.keymap.set('n', '<leader>dd', dapui.toggle, { noremap = true, silent = true })

require('copilot').setup({
    suggestion = {
        enabled = true,
        auto_trigger = true,
    },
    panel = { enabled = false },
})

local copilot_suggestion = require('copilot.suggestion')

vim.keymap.set('i', '<C-a>', function()
    return copilot_suggestion.accept()
end, { silent = true })

require("lsp_signature").setup {}

require("bufferline").setup {}

require("telescope").setup {}
local t_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', t_builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', t_builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', t_builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', t_builtin.help_tags, {})
vim.keymap.set('n', '<leader>fs', t_builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>fw', t_builtin.lsp_workspace_symbols, {})

local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = {
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
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        }),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'path' },
    })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local lspconfig = require('lspconfig')

lspconfig['pyright'].setup { capabilities = capabilities }
lspconfig['nixd'].setup { capabilities = capabilities }
lspconfig['vimls'].setup { capabilities = capabilities }
lspconfig['marksman'].setup { capabilities = capabilities }

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

lspconfig['csharp_ls'].setup {
    cmd = { "/home/vetle/.nix-profile/bin/CSharpLanguageServer" },
    filetypes = { "cs" },
    root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git"),
    capabilities = capabilities,
}


lspconfig['fsautocomplete'].setup { capabilities = capabilities }

require('rust-tools').setup {
    tools = {
        inlay_hints = {
            auto = false,
        },
    },
    dap = {
        adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
    },
    server = {
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy"
                },
            },
        },
    },
}

vim.cmd([[vnoremap <C-h> ""y:%s/<C-R>=escape(@", '/\')<CR>//g<Left><Left>]])

require('lightspeed').setup {}
vim.cmd 'let g:everforest_background = "hard"'
vim.cmd 'colorscheme everforest'

require('lualine').setup {
    options = {
        theme = 'everforest',
        section_separators = '',
        component_separators = '',
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', path = 1 }, 'diagnostics' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
    },
}

vim.api.nvim_command(
    [[ hi diffAdded ctermfg=188 ctermbg=64 cterm=NONE guifg=#ffffff guibg=#335533 gui=NONE ]]
)
vim.api.nvim_command(
    [[ hi diffRemoved ctermfg=88 ctermbg=NONE cterm=NONE guifg=#ffffff guibg=#553333 gui=NONE ]]
)

require('bufdel').setup {
    next = 'tabs', -- or 'cycle, 'alternate'
    quit = false,  -- quit Neovim when last buffer is closed
}

vim.keymap.set('n', '<leader>w', ':BufDel<cr>', { noremap = true, silent = true })

require('trouble').setup {}

vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>",
    { silent = true, noremap = true }
)
vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
    { silent = true, noremap = true }
)
vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",
    { silent = true, noremap = true }
)
vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>",
    { silent = true, noremap = true }
)
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
    { silent = true, noremap = true }
)

local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>ra", harpoon_mark.add_file,
    { silent = true, noremap = true }
)

vim.keymap.set("n", "<leader>rr", harpoon_ui.toggle_quick_menu,
    { silent = true, noremap = true }
)

for i = 1, 4, 1 do
    local nav_function = function()
        harpoon_ui.nav_file(i)
    end
    vim.keymap.set("n", "<leader>" .. i, nav_function, { silent = true, noremap = true })
end

require("telescope").load_extension('harpoon')

vim.keymap.set("n", "<leader>fr", "<cmd>Telescope harpoon marks<cr>",
    { silent = true, noremap = true }
)

require('nvim-surround').setup {}

-- Enable document highlight on hover for lsp clients that support it
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd('CursorHold', {
                buffer = bufnr,
                callback = function() vim.lsp.buf.document_highlight() end,
            })

            vim.api.nvim_create_autocmd('CursorMoved', {
                buffer = bufnr,
                callback = function() vim.lsp.buf.clear_references() end,
            })
        end
    end,
})

vim.cmd 'set updatetime=250'
