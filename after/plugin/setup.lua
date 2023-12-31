local treesitter = require("nvim-treesitter.configs")
local treesitter_spec = {
    ensure_installed = { "vim", "lua", "c", "bash", "vimdoc" },
    sync_install = true,
    auto_install = false,
    ignore_install = { "java", "fish", "erlang" },
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
}
treesitter.setup(treesitter_spec)

local gitsigns = require("gitsigns")
gitsigns.setup({})

local comment = require("Comment")
---@diagnostic disable-next-line: missing-fields
comment.setup({
    ---@diagnostic disable-next-line: missing-fields
    toggler = { line = "<leader>c" },
    ---@diagnostic disable-next-line: missing-fields
    opleader = { line = "<leader>c" },
})

local colorizer = require("colorizer")
colorizer.setup({ user_default_options = { names = false } })

local telescope_builtin = require("telescope.builtin")
local telescope_themes = require("telescope.themes")
local define_picker = function(picker_spec)
    local ivy = telescope_themes.get_ivy({
        border = false,
        shorten_path = true,
        layout_config = {
            height = 35,
        }
    })
    return function() picker_spec(ivy) end
end

local keymap_set_opts = {}
vim.keymap.set("n", "<leader><leader>f", define_picker(telescope_builtin.find_files), keymap_set_opts)
vim.keymap.set("n", "<leader><leader>l", define_picker(telescope_builtin.current_buffer_fuzzy_find), keymap_set_opts)
vim.keymap.set("n", "<leader><leader>o", define_picker(telescope_builtin.oldfiles), keymap_set_opts)
vim.keymap.set("n", "<leader><leader>g", define_picker(telescope_builtin.live_grep), keymap_set_opts)
vim.keymap.set("n", "<leader><leader>s", define_picker(telescope_builtin.grep_string), keymap_set_opts)
vim.keymap.set("n", "<leader><leader>r", define_picker(telescope_builtin.resume), keymap_set_opts)
vim.keymap.set("n", "<leader><leader>b", define_picker(telescope_builtin.buffers), keymap_set_opts)

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-w>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})


local mason = require("mason")
mason.setup()

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
    ensure_installed = {
        "lua_ls",
        "volar",
        "tsserver",
        "eslint",
        "rust_analyzer",
    }
})

local lspconfig = require("lspconfig")
local cmp_lsp = require("cmp_nvim_lsp")
local define_lsp = function(lsp, config)
    lspconfig[lsp].setup({ capabilities = cmp_lsp.default_capabilities() })
end

local default_handler_func = function(lsp)
    local config = {}
    -- "Takeover Mode" Support for volar over tsserver
    if require("neoconf").get(lsp .. ".disable") then return; end
    if lsp == "volar" then
        config.filetypes = {
            'typescript', 'javascript', 'javascriptreact',
            'typescriptreact', 'vue', 'json'
        }
    end
    if lsp == "eslint" then
        config.filetypes = { "vue", "typescript", "javascript" }
    end
    define_lsp(lsp, config)
end

local handlers = { default_handler_func }
local define_handler = function(name, config)
    local handler = { [name] = function() define_lsp(name, config) end }
    table.insert(handlers, handler)
end

define_handler("lua_ls", {
    filetypes = { "lua" },
    single_file_support = true,
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            completion = { callSnippet = "Replace" }
        }
    }
})
mason_lspconfig.setup_handlers(handlers)

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(event)
        local opts = { buffer = event.buf, noremap = true }
        vim.keymap.set("n", "F", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "S", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>re", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>tq", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gl", vim.lsp.buf.definition, opts)
        vim.keymap.set({ "n", "v" }, "<leader>we", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set("n", "<leader><leader>e", define_picker(telescope_builtin.diagnostics),
            { unpack(opts), buffer = 0 })
    end
})
