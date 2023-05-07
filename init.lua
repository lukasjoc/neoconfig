vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.opt.encoding = "utf-8"
vim.opt.ttyfast = true
vim.opt.title = true
vim.opt.paste = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.ruler = true
vim.opt.signcolumn = "yes"
vim.opt.list = true
vim.opt.backspace = "indent,eol,start"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.wo.wrap = false
vim.wo.linebreak = false
vim.opt.scrolloff = 21
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.laststatus = 0
vim.opt.termguicolors = true
vim.opt.colorcolumn = "92"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.cmd([[set listchars=tab:\ \ ,trail:."]])
vim.g.netrw_banner = 0
vim.g.netrw_fastbrowse = 1
vim.g.netrw_liststyle = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    spec = {
        {
            priority = 998,
            "williamboman/mason.nvim",
            build = ":MasonUpdate"
        },
        {
            priority = 999,
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.install").update({ with_sync = true })
            end,
            dependencies = {
                "nvim-treesitter/nvim-treesitter-textobjects"
            }
        },
        {
            "ctrlpvim/ctrlp.vim",
            config = function()
                local opts = { silent = true, noremap = true }
                vim.keymap.set("n", "<leader>f", "<cmd>CtrlP<cr>", opts)
                vim.keymap.set("n", "<leader>o", "<cmd>CtrlPMRUFiles<cr>", opts)
            end,
        },
        {
            "jremmen/vim-ripgrep",
            config = function()
               vim.g["rg_highlight"] = true
            end
        },
        {
            "lewis6991/gitsigns.nvim",
            lazy = true,
            event = { "BufReadPre", "BufNewFile" },
            opts = {
                signs = {
                    add = { text = " " },
                    change = { text = " " },
                    changedelete = { text = "-" },
                    delete = { text = "d" },
                    topdelete = { text = "-" },
                    untracked = { text = "u" },
                },
            },
        },
        { "williamboman/mason-lspconfig.nvim", priority = 998 },
        { "neovim/nvim-lspconfig",             priority = 998 },
        {
            "folke/trouble.nvim",
            lazy = true,
            config = function()
                require("trouble").setup({
                    height = 20,
                    icons = false,
                    fold_open = "v",
                    fold_closed = ">",
                    use_diagnostic_signs = true,
                    indent_lines = false,
                })

                local opts = { silent = true, noremap = true }
                vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", opts)
                vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", opts)
                vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", opts)
                vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", opts)
                vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", opts)
                vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", opts)
            end,

        },
        {
            "L3MON4D3/LuaSnip",
            lazy = true
        },
        {
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
            dependencies = {
                { "hrsh7th/cmp-nvim-lsp" },
                { "hrsh7th/cmp-buffer" },
                { "hrsh7th/cmp-path" },
                { "hrsh7th/cmp-cmdline" },
                { "lukasjoc/cmp-license" },
                { "L3MON4D3/LuaSnip" },
                { "saadparwaiz1/cmp_luasnip" },
            },
            config = function()
                local cmp     = require("cmp")
                local luasnip = require("luasnip")
                local window  = require("cmp.config.window")
                cmp.setup({
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end
                    },
                    mapping = cmp.mapping.preset.insert({
                        -- INFO: Keep the single quotes
                        ['<C-j>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-k>'] = cmp.mapping.scroll_docs(4),
                        ['<C-c>'] = cmp.mapping.abort(),
                        ['<C-w>'] = cmp.mapping.confirm({
                            behavior = cmp.ConfirmBehavior.Insert,
                            select = true
                        }),
                    }),
                    sources = {
                        { name = "nvim_lsp", keyword_length = 4 },
                        { name = "luasnip",  keyword_length = 4 },
                        { name = "path",     keyword_length = 4 },
                        { name = "buffer",   keyword_length = 7 },
                        { name = "license",  keyword_length = 2 },
                    },
                    window = {
                        documentation = window.bordered()
                    },
                    formatting = {
                        fields = { "menu", "abbr", "kind" },
                        format = function(entry, item)
                            local menu_icon = {
                                nvim_lsp = "*",
                                luasnip  = "snip",
                                buffer   = "**",
                                path     = "..",
                                license  = "?",
                            }
                            item.menu = menu_icon[entry.source.name]
                            return item
                        end,
                    },
                })
            end
        },
        {
            "ellisonleao/gruvbox.nvim",
            lazy = false,
            priority = 1000,
            config = function()
                require("gruvbox").setup({
                    undercurl            = true,
                    underline            = true,
                    bold                 = true,
                    italic               = {
                        strings   = true,
                        numbers   = true,
                        comments  = false,
                        operators = false,
                        folds     = true,
                    },
                    strikethrough        = true,
                    invert_selection     = true,
                    invert_signs         = false,
                    invert_tabline       = false,
                    invert_intend_guides = true,
                    inverse              = true,
                    contrast             = "soft",
                    dim_inactive         = false,
                    transparent_mode     = false,
                })

                vim.o.background = "dark"
                vim.cmd("colo gruvbox")
            end
        },

        -- Some tools
        { "numToStr/Comment.nvim" },
        { "NvChad/nvim-colorizer.lua" },
        { "RRethy/nvim-align" },
        {
            "folke/neodev.nvim",
            ft = "lua",
        },
    }
}
require("lazy").setup(plugins)

local sign = function(opts)
    vim.fn.sign_define(opts.name, {
        texthl = opts.name,
        text = opts.text,
        numhl = ""
    })
end

sign({ name = "DiagnosticSignError", text = "e" })
sign({ name = "DiagnosticSignWarn", text = "w" })
sign({ name = "DiagnosticSignHint", text = "h" })
sign({ name = "DiagnosticSignInfo", text = "i" })

vim.diagnostic.config({
    -- remove inline lsp messages
    virtual_text = false,
    severity_sort = true,
})


local opts_keybind = { noremap = true, silent = true }
vim.keymap.set("n", '<leader>w', '<C-^>', opts_keybind)
vim.keymap.set("n", "<leader>e", vim.cmd.Explore, opts_keybind)
vim.keymap.set("n", "<leader>r", vim.cmd.nohl, opts_keybind)

-- Support for the todoreadme/tor ft
vim.filetype.add({
    extension = {
        tor        = "todoreadme",
        todoreadme = "todoreadme",
    },
})

vim.cmd("hi link @todoreadmeHeader Identifier")
vim.cmd("hi link @todoreadmeCategory Special")
vim.cmd("hi link @todoreadmeDelimiter Delimiter")

vim.treesitter.language.register("todoreadme", "tor")

require("nvim-treesitter.parsers").get_parser_configs()["todoreadme"] = {
    install_info                   = {
        url = "~/fun/tree-sitter-todoreadme", -- local path or git repo
        files = { "src/parser.c" },
    },
    filetype                       = "tor", -- if filetype does not match the parser name
    branch                         = "main",
    generate_requires_npm          = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
}

-- TODO: convert to a plugin with better suppoort for everything todoreadme
vim.cmd([[command! TorSync !cd $HOME/todo;git add .;git commit -m 'Update README';git push]])

-- Markdown preview of current file using glow
vim.cmd([[command! GlowPreviewMarkdown !glow %:S ]])

