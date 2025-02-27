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
vim.opt.listchars = { tab = "  ", trail = "·" }
vim.opt.fillchars = "eob: "
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

-- Lazy (TODO: Try to reduce dependencies)
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

vim.opt.rtp:prepend(lazypath)

local spec = {}
local plug = function(plugin, _doc) table.insert(spec, plugin); end
plug({ "folke/neodev.nvim", ft = "lua" })
plug({
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/playground" },
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = { enable = true },
            playground = { enable = true },
        })
    end
})
plug({ "nvim-lua/plenary.nvim" })
plug({ "nvim-telescope/telescope.nvim", tag = "0.1.8" })
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
plug({ "numToStr/Comment.nvim" }, "Sticking to this over builtin as I like my leader-c")
plug({ "RRethy/nvim-align" }, "Light, handy auto-align by some separator over range")
plug({ "lewis6991/gitsigns.nvim" })
plug({ "akinsho/git-conflict.nvim", version = "2.1.0", config = true }, "Conflict Markers UI")
plug({
    "lukasjoc/vibr.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    -- dir = "~/fun/vibr.nvim", -- Path to your local plugin
    -- name = "vibr.nvim",      -- Optional: plugin name
    -- dev = true,              -- Optional: Marks it as a dev plugin
})

require("lazy").setup(spec, {})

vim.cmd.colorscheme("vibr")
-- TODO: Put this into the vibr theme plugin
local hl = vim.api.nvim_set_hl
hl(0, "GitConflictCurrent", { link = "DiffChange" })
hl(0, "GitConflictIncoming", { link = "DiffChange" })
hl(0, "GitConflictAncestor", { link = "DiffText" }) -- Not sure what that is
hl(0, "GitConflictCurrentLabel", { link =  "DiffText" })
hl(0, "GitConflictIncomingLabel", { link = "DiffText" })
hl(0, "GitConflictAncestorLabel", { link = "DiffText" }) -- Not sure what that is

require("neodev").setup()

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "vim", "lua", "comment", "c", "bash", "vimdoc", "rust",
        "javascript", "html", "css", "go", "typescript",
    },
    sync_install = true,
    auto_install = false,
    ignore_install = { "java", "tsx", "fish" },
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
})

local telescope = require("telescope")
telescope.setup({
    pickers = {
        find_files = {
            hidden = true,
            find_command = {
                "rg",
                "--ignore",
                "--files",
                "--hidden",
                "--glob=!**/.git/*",
                "--glob=!**/dist/*",
                "--glob=!**/target/*",
                "--glob=!**/node_modules/*",
            },
        }
    },
})
local telescope_builtin = require("telescope.builtin")
local telescope_picker = function(cmd)
    local ivy = require("telescope.themes").get_ivy({
        border = false,
        shorten_path = true,
        layout_config = { height = 60 }
    })
    return function() cmd(ivy) end
end

vim.keymap.set("n", "<leader><leader>f", telescope_picker(telescope_builtin.find_files), {})
vim.keymap.set("n", "<leader><leader>l", telescope_picker(telescope_builtin.current_buffer_fuzzy_find), {})
vim.keymap.set("n", "<leader><leader>o", telescope_picker(telescope_builtin.oldfiles), {})
vim.keymap.set("n", "<leader><leader>g", telescope_picker(telescope_builtin.live_grep), {})
vim.keymap.set("n", "<leader><leader>s", telescope_picker(telescope_builtin.grep_string), {})
vim.keymap.set("n", "<leader><leader>r", telescope_picker(telescope_builtin.resume), {})
vim.keymap.set("n", "<leader><leader>b", telescope_picker(telescope_builtin.buffers), {})

local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
    snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-w>"] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }, {
        { name = "buffer" },
    })
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "gopls", "clangd", "rust_analyzer" },
})

local setup_with_defaults = function(name, config)
    local config = config or {}
    config.capabilities = require("cmp_nvim_lsp").default_capabilities()
    require("lspconfig")[name].setup(config)
end

local setup_clangd        = function()
    local config = {
        cmd = { "clangd", "--background-index" },
        filetypes = { "c" },
    }
    setup_with_defaults("clangd", config)
end

local setup_eslint        = function()
    local config = {
        filetypes = { "vue", "typescript", "javascript" }
    };
    setup_with_defaults("eslint", config)
end

local setup_volar         = function()
    local config = {
        filetypes = { "vue" }
    }
    setup_with_defaults("volar", config)
end

local setup_tsls          = function()
    --- @type string
    local nvm_current_node = require("os").getenv("NVM_BIN"):match("(.*)/")
    --- @type string
    local node_modules = nvm_current_node .. "/lib/node_modules/"
    local config = {
        filetypes = { "javascript", "typescript", "vue", "typescriptreact" },
        init_options = {
            plugins = {
                {
                    name = "@vue/typescript-plugin",
                    location = node_modules .. "@vue/typescript-plugin",
                    languages = { "javascript", "typescript", "vue" },
                },
            },
        }
    }
    setup_with_defaults("ts_ls", config)
end

local setup_luals         = function()
    local config = {
        format = {
            enable = true,
        },
        filetypes = { "lua" },
        single_file_support = true,
        settings = {
            Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
                completion = { callSnippet = "Replace" }
            }
        }
    }
    setup_with_defaults("lua_ls", config)
end

require("mason-lspconfig").setup_handlers({
    ["lua_ls"] = setup_luals,
    ["clangd"] = setup_clangd,
    ["volar"] = setup_volar,
    ["ts_ls"] = setup_tsls,
    ["eslint"] = setup_eslint,
    setup_with_defaults,
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
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gl", vim.lsp.buf.definition, opts)
        vim.keymap.set({ "n", "v" }, "<leader>we", function()
            local eslint_lsp_active = #vim.lsp.get_clients({ name = "eslint" })
            if eslint_lsp_active > 0 then
                vim.api.nvim_command("EslintFixAll")
                return;
            end
            vim.lsp.buf.format({ async = true })
        end, opts)
        vim.keymap.set("n", "<leader><leader>e", telescope_picker(telescope_builtin.diagnostics),
            { unpack(opts), buffer = 0 })
        vim.keymap.set("n", "U", telescope_picker(telescope_builtin.lsp_references), { unpack(opts), buffer = 0 })
    end
})

require("Comment").setup({
    toggler = { line = "<leader>c" },
    opleader = { line = "<leader>c" },
})

require("gitsigns").setup();

local gitsigns_show_blame_info = function()
    require("gitsigns").blame_line({ full = true, ignore_whitespace = true })
end

vim.keymap.set("n", "<leader>bl", gitsigns_show_blame_info, { noremap = true, silent = true })
vim.fn.sign_define("DiagnosticSignInfo", { texthl = "DiagnosticSignInfo", text = "I", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { texthl = "DiagnosticSignHint", text = "H", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { texthl = "DiagnosticSignWarn", text = "W", numhl = "" })
vim.fn.sign_define("DiagnosticSignError", { texthl = "DiagnosticSignError", text = "E", numhl = "" })
vim.diagnostic.config({ virtual_text = false, severity_sort = true, })

vim.keymap.set("n", "<leader>w", "<C-^>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", "<CMD>:Explore<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>r", vim.cmd.nohl, { noremap = true, silent = true })

-- Setup for custom text formats and languages..
vim.filetype.add({ extension = { tsm = "tsm" } }) -- tiny IR format
vim.filetype.add({ extension = { tm = "tm" } })   -- tiny source format
vim.filetype.add({ extension = { act = "act" } })

print("Were vimming.. Have a nice day hacking! (@<@)")
