print("Have a nice day! =)")

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "vim", "lua", "c", "make",
        "rust", "commonlisp", "cpp",
        "perl", "php", "python",
        "javascript", "jsdoc", "typescript", "vue", "html", "css",
        "go", "gomod", "gowork", "gosum",
        "git_rebase", "gitignore", "gitcommit", "gitattributes",
        "bash", "diff", "dockerfile", "toml", "yaml", "json", "ini",
        "markdown", "sql", "comment",
    },
    sync_install = true,
    auto_instal = true,
    ignore_install = { "java", "fish", "erlang" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
        },
    },
    indent = {
        enable = true
    },
})

require("gitsigns").setup()
require("Comment").setup({
    toggler = { line = "<leader>c", },
    opleader = { line = "<leader>c" },
})

require("colorizer").setup({
    user_default_options = { names = false, }
})

require("mason").setup({
    ui = {
        icons = {
            package_installed = "i",
            package_pending = "p",
            package_uninstalled = "u",
        }
    }
})

require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "rust_analyzer",
    }
})

require("neodev").setup()
local lspconfig = require("lspconfig")

require("mason-lspconfig").setup_handlers({
    function(lsp)
        -- called for each installed language server without a dedicated handler
        require("lspconfig")[lsp].setup({})
    end,
    ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
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
    end,
})

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
        -- NOTE: vmode formatting only works if the lsp supports it
        vim.keymap.set({ "n", "v" }, "<leader>we", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
    end
})
