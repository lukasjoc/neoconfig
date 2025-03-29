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

-- Lazy (TODO: Try to reduce dependencies)
local lazyPackages = {
    --  { "folke/neodev.nvim",               ft = "lua", },
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/playground" },
        config = function()
            require("nvim-treesitter.configs").setup({
                highlight = { enable = true },
                playground = { enable = true },
            })
        end
    },
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim",   branch = "0.1.x" },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },
    { "numToStr/Comment.nvim" },
    { "RRethy/nvim-align" },
    { "lewis6991/gitsigns.nvim" },
    { "akinsho/git-conflict.nvim",       version = "2.1.0",  config = true },
    {
        "lukasjoc/vibr.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        -- dir = "~/fun/vibr.nvim", -- Path to your local plugin
        -- name = "vibr.nvim",      -- Optional: plugin name
        -- dev = true,              -- Optional: Marks it as a dev plugin
    },
}

require("lazy").setup(lazyPackages, {})

vim.cmd.colorscheme("vibr")

-- require("neodev").setup()

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "lua", "comment", "c", "bash", "rust",
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
        layout_config = { height = 40 }
    })
    return function() cmd(ivy) end
end

vim.keymap.set("n", "<leader><leader>f", telescope_picker(telescope_builtin.find_files), { buffer = true })
vim.keymap.set("n", "<leader><leader>l", telescope_picker(telescope_builtin.current_buffer_fuzzy_find), { buffer = true })
vim.keymap.set("n", "<leader><leader>o", telescope_picker(telescope_builtin.oldfiles), { buffer = true })
vim.keymap.set("n", "<leader><leader>g", telescope_picker(telescope_builtin.live_grep), { buffer = true })
vim.keymap.set("n", "<leader><leader>s", telescope_picker(telescope_builtin.grep_string), { buffer = true })
vim.keymap.set("n", "<leader><leader>r", telescope_picker(telescope_builtin.resume), { buffer = true })
vim.keymap.set("n", "<leader><leader>b", telescope_picker(telescope_builtin.buffers), { buffer = true })

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
        { name = "buffer" },
        { name = "path" },
    })
})

-- vim.lsp.config.clangd   = {
--     capabilities = require("cmp_nvim_lsp").default_capabilities(),
--     cmd = { 'clangd', '--background-index' },
--     root_markers = { 'compile_commands.json', 'compile_flags.txt' },
--     filetypes = { 'c', 'h' },
-- }

-- vim.lsp.config.eslint   = {
--     capabilities = require("cmp_nvim_lsp").default_capabilities(),
--     cmd = TBD
--     filetypes = { "vue", "typescript", "javascript" },
-- }
--
-- vim.lsp.config.volar    = {
--     capabilities = require("cmp_nvim_lsp").default_capabilities(),
--     cmd = TBD
--     filetypes = { "vue" },
-- }
--
-- vim.lsp.config.tsls     = {
--     capabilities = require("cmp_nvim_lsp").default_capabilities(),
--     filetypes = { "javascript", "typescript", "vue", "typescriptreact" },
--     cmd = TBD
--     init_options = {
--         plugins = {
--             {
--                 name = "@vue/typescript-plugin",
--                 location = require("os").getenv("NVM_BIN"):match("(.*)/") .. "/lib/node_modules/@vue/typescript-plugin",
--                 languages = { "javascript", "typescript", "vue" },
--             },
--         },
--     }
-- }

vim.lsp.config.luals = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json" },
    setttings = {
        Lua = {
            telemetry = {
                enable = false,
            },
        }
    },
    filetypes = { "lua" },
}

vim.lsp.config.gopls = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gosum" },
}

vim.lsp.enable({
    "luals",
    "gopls",
    -- "eslint",
    -- "volar",
    -- "tsls",
    -- "clangd",
})

require("Comment").setup({
    toggler = { line = "<leader>c" },
    opleader = { line = "<leader>c" },
})

require("gitsigns").setup();

vim.keymap.set("n", "<leader>bl", function()
    require("gitsigns").blame_line({
        full = true,
        ignore_whitespace = true,
    })
end, { buffer = true, noremap = true, silent = true })

vim.diagnostic.config({
    severity_sort = true,
    virtual_text = false,
    virtual_lines = false,
    float = {
        scope = "cursor",
        severity_sort = true,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.HINT] = "H",
            [vim.diagnostic.severity.INFO] = "I",
        },
    }
})

local toggle_virtual_lines = function()
    local opts = vim.diagnostic.config() or {};
    opts.virtual_lines = not opts.virtual_lines
    if opts.virtual_lines then
        opts.virtual_lines = { current_line = false }
    end
    vim.diagnostic.config(opts);
end

vim.keymap.set("n", "<leader>w", "<C-^>", { buffer = true, noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", "<CMD>:Explore<CR>", { buffer = true, noremap = true, silent = true })
vim.keymap.set("n", "<leader>r", vim.cmd.nohl, { buffer = true, noremap = true, silent = true })
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(event)
        local opts = { buffer = event.buf, noremap = true }
        vim.keymap.set("n", "<leader>f", toggle_virtual_lines, opts)
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
        vim.keymap.set("n", "<leader><leader>e", telescope_picker(telescope_builtin.diagnostics), opts)
        vim.keymap.set("n", "U", telescope_picker(telescope_builtin.lsp_references), opts)
    end
})

-- Setup for custom text formats and languages..
vim.filetype.add({ extension = { tsm = "tsm" } }) -- tiny IR format
vim.filetype.add({ extension = { tm = "tm" } })   -- tiny source format
vim.filetype.add({ extension = { act = "act" } })

print("Were vimming.. Have a nice day hacking! (@<@)")
