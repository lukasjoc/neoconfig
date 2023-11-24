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
-- Dont autmatically add commented newlines
vim.cmd("au BufEnter * set fo-=c fo-=r fo-=0")
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

local plugins = {}
local plugin_add = function(spec)
    table.insert(plugins, spec)
end

plugin_add({ "folke/neodev.nvim", ft = "lua" })
plugin_add({ "folke/neoconf.nvim" })
plugin_add({ "numToStr/Comment.nvim" })
plugin_add({ "NvChad/nvim-colorizer.lua" })
plugin_add({ "RRethy/nvim-align" })
plugin_add({ "kkoomen/vim-doge", build = ":call doge#install()" })
plugin_add({ "Mofiqul/vscode.nvim" })
plugin_add({ "lewis6991/gitsigns.nvim" })
plugin_add({ "nvim-lua/plenary.nvim" })
plugin_add({ "nvim-telescope/telescope.nvim", tag = "0.1.4" })
plugin_add({ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" })
plugin_add({ "williamboman/mason.nvim" })
plugin_add({ "williamboman/mason-lspconfig.nvim" })
plugin_add({ "neovim/nvim-lspconfig" })
plugin_add({ "ms-jpq/coq_nvim" })
plugin_add({ "ms-jpq/coq.artifacts" })

local opts = {}
require("lazy").setup(plugins, opts)

local sign_define = function(name, text)
    local sign_spec = {
        texthl = name,
        text = text,
        numhl = "",
    }
    vim.fn.sign_define(opts.name, sign_spec)
end

sign_define("DiagnosticSignInfo", "I")
sign_define("DiagnosticSignHint", "H")
sign_define("DiagnosticSignWarn", "W")
sign_define("DiagnosticSignError", "E")

vim.diagnostic.config({
    -- INFO: hide inline stuff
    virtual_text = false,
    severity_sort = true,
})

local keymap_set_opts = { noremap = true, silent = true }
vim.keymap.set("n", '<leader>w', '<C-^>', keymap_set_opts)
vim.keymap.set("n", "<leader>e", vim.cmd.Explore, keymap_set_opts)
vim.keymap.set("n", "<leader>r", vim.cmd.nohl, keymap_set_opts)
