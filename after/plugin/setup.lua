local treesitter = require("nvim-treesitter.configs")
local treesitter_spec = {
    ensure_installed = { "vim", "lua", "c", "bash" },
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
-- TODO: there is a way to autostart this shit
vim.cmd(":COQnow --shut-up")
local coq = require("coq")
local define_lsp = function(lsp, config)
    lspconfig[lsp].setup(coq.lsp_ensure_capabilities(config))
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
