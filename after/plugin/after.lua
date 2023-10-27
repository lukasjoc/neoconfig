print("Have a nice day! =)")
require("neoconf").setup()
require("neodev").setup()

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

local builtin = require("telescope.builtin")
local picky = function(picker)
    local themes = require("telescope.themes")
    local ivy = themes.get_ivy({
        border = false,
        shorten_path = true,
        layout_config = {
            height = 20,
        }
    })
    return function() picker(ivy) end
end

vim.keymap.set("n", "<leader><leader>f", picky(builtin.find_files), {})
vim.keymap.set("n", "<leader><leader>l", picky(builtin.current_buffer_fuzzy_find), {})
vim.keymap.set("n", "<leader><leader>o", picky(builtin.oldfiles), {})
vim.keymap.set("n", "<leader><leader>g", picky(builtin.live_grep), {})
vim.keymap.set("n", "<leader><leader>s", picky(builtin.grep_string), {})
vim.keymap.set("n", "<leader><leader>r", picky(builtin.resume), {})
vim.keymap.set("n", "<leader><leader>b", picky(builtin.buffers), {})

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
        "volar",
        "tsserver",
        "eslint",
    },
})

local lspc = require("lspconfig")
require("mason-lspconfig").setup_handlers({
    ["lua_ls"] = function()
        lspc.lua_ls.setup({
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
    function(lsp)
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
        lspc[lsp].setup(config)
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

        vim.keymap.set("n", "<leader><leader>e", picky(builtin.diagnostics), { buffer = 0, noremap = true })
    end
})

local snip = require("luasnip")
local rust_snips = {
    snip.snippet({
        trig = "skip",
        namr = "rustfmt::skip",
        dscr = "add #[rustfmt::skip]",
    }, { snip.text_node("#[rustfmt::skip]") })
}

snip.add_snippets(nil, { rust = rust_snips })
