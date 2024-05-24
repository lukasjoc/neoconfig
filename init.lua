vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.opt.title = true
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.signcolumn = "yes"
vim.opt.list = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.scrolloff = 25
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.laststatus = 0
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.colorcolumn = "80"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.splitright = true
vim.wo.wrap = false
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.opt.listchars = { tab = '  ', trail = '·' }
vim.g.netrw_banner = 0
vim.g.netrw_fastbrowse = 1
vim.g.netrw_liststyle = 1

-- Dont autmatically add commented newlines
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

local spec = {}
---@diagnostic disable-next-line: unused-local
local plug = function(plugin, _doc) table.insert(spec, plugin); end
plug({ "folke/neodev.nvim", ft = "lua" }, "For a generally better nvim experience")
plug({ "folke/neoconf.nvim" }, "For a generally better nvim config experience")
plug({ "nvim-lua/plenary.nvim" })
plug({ "nvim-telescope/telescope.nvim", tag = "0.1.7" })
plug({ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" })
plug({ "williamboman/mason.nvim" })
plug({ "williamboman/mason-lspconfig.nvim" })
plug({ "neovim/nvim-lspconfig" })
plug({ "hrsh7th/nvim-cmp" })
plug({ "hrsh7th/cmp-nvim-lsp" })
plug({ "hrsh7th/cmp-buffer" })
plug({ "hrsh7th/cmp-path" })
plug({ "L3MON4D3/LuaSnip" })
plug({ "saadparwaiz1/cmp_luasnip" })
plug({ "stevearc/oil.nvim" })
plug({ "numToStr/Comment.nvim" }, "Sticking to this over builtin as I like my leader-c")
plug({ "NvChad/nvim-colorizer.lua" }, "Show colors as colors. Wow")
plug({ "RRethy/nvim-align" }, "Light, handy auto-align by some seperator over range")
plug({ "lewis6991/gitsigns.nvim" })
plug({ "NLKNguyen/papercolor-theme" })
plug({ "rose-pine/neovim", name = "rose-pine" })
require("lazy").setup(spec, {})

require("rose-pine").setup({}); vim.cmd("colorscheme rose-pine")
require("neoconf").setup()
require("neodev").setup()

---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "vim", "lua", "comment", "c", "bash", "vimdoc", "go", "typescript",
    },
    sync_install = true,
    auto_install = false,
    ignore_install = { "java", "tsx", "fish", "erlang" },
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
})

local telescope_builtin = require("telescope.builtin")
local telescope_picker = function(cmd)
    local ivy = require("telescope.themes").get_ivy({
        border = false,
        shorten_path = true,
        layout_config = { height = 35 }
    })
    return function() cmd(ivy) end
end
vim.keymap.set("n", "<leader><leader>f", telescope_picker(telescope_builtin.find_files), {})
vim.keymap.set("n", "<leader><leader>l", telescope_picker(telescope_builtin.current_buffer_fuzzy_find), {})
vim.keymap.set("n", "<leader><leader>o", telescope_picker(telescope_builtin.oldfiles), {})
vim.keymap.set("n", "<leader><leader>g", telescope_picker(telescope_builtin.live_grep), {})
vim.keymap.set("n", "<leader><leader>s", telescope_picker(telescope_builtin.grep_string), {})
vim.keymap.set("n", "<leader><leader>r", telescope_picker(telescope_builtin.resume), {})
-- vim.keymap.set("n", "<leader><leader>b", ivy_picker(telescope_builtin.buffers), {})

local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
    snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-2),
        ['<C-f>'] = cmp.mapping.scroll_docs(2),
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

require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = { "lua_ls", "gopls" } })

local lsp = function(name, config)
    config.capabilities = require("cmp_nvim_lsp").default_capabilities()
    -- "Takeover Mode" Support for volar over tsserver
    -- if require("neoconf").get(lsp .. ".disable") then return; end
    -- if lsp == "volar" then
    --     config.filetypes = {
    --         "typescript", "javascript", "javascriptreact",
    --         "typescriptreact", "vue", "json"
    --     }
    -- end
    -- if lsp == "eslint" then
    --     config.filetypes = { "vue", "typescript", "javascript" }
    -- end
    require("lspconfig")[name].setup(config)
end

local default_handler_func = function(name)
    local config = {}
    lsp(name, config)
end

local handlers = { default_handler_func }
table.insert(handlers, {
    ["lua_ls"] = function()
        lsp("lua_ls", {
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
    end
})
require("mason-lspconfig").setup_handlers(handlers)

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(event)
        local opts = { buffer = event.buf, noremap = true }
        vim.keymap.set("n", "F", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "S", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>re", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gl", vim.lsp.buf.definition, opts)
        vim.keymap.set({ "n", "v" }, "<leader>we", function()
            -- FIXME: this is broken
            -- local eslint_lsp_active = #vim.lsp.get_active_clients({ name = "eslint_lsp" })
            -- if eslint_lsp_active ~= 1 then
            --     vim.api.nvim_command("EslintFixAll")
            --     return;
            -- end
            vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set("n", "<leader><leader>e",
            telescope_picker(telescope_builtin.diagnostics),
            { unpack(opts), buffer = 0 })
        vim.keymap.set("n", "U",
            telescope_picker(telescope_builtin.lsp_references),
            { unpack(opts), buffer = 0 })
    end
})

---@diagnostic disable-next-line: missing-fields
require("Comment").setup({ toggler = { line = "<leader>c" }, opleader = { line = "<leader>c" }, })
require("colorizer").setup({ user_default_options = { names = false } })
require("gitsigns").setup()
require("oil").setup()

vim.fn.sign_define("DiagnosticSignInfo", { texthl = "DiagnosticSignInfo", text = "I", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { texthl = "DiagnosticSignHint", text = "H", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { texthl = "DiagnosticSignWarn", text = "W", numhl = "" })
vim.fn.sign_define("DiagnosticSignError", { texthl = "DiagnosticSignError", text = "E", numhl = "" })
vim.diagnostic.config({ virtual_text = false, severity_sort = true, })

vim.keymap.set("n", '<leader>w', '<C-^>', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>r", vim.cmd.nohl, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>bl", "<CMD> Gitsigns blame_line<CR>", { noremap = true, silent = true })

-- NOTE!!: Custom Languages Section (for ft specific stuff see ftplugin/[name].lua)
-- local parsers = require("nvim-treesitter.parsers").get_parser_configs()
-- local register_ft = function(name)
--     vim.filetype.add({ extension = { act = name } })
--     vim.treesitter.language.register(name, name)
-- end
-- register_ft("stacks")

---@class stacks
-- s.stacks = {
--     install_info                   = {
--         url   = "~/fun/stacks/tree-sitter", -- local path or git repo
--         files = { "src/parser.c" },
--     },
--     filetype                       = "stacks", -- if filetype does not match the parser name
--     branch                         = "main",
--     generate_requires_npm          = false,    -- if stand-alone parser without npm dependencies
--     requires_generate_from_grammar = false,    -- if folder contains pre-generated src/parser.c
-- }
-- register_ft("act")

print("We're vimming.. Have a nice day hacking! (@<@)")
