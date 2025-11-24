vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.opt.title = true
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.signcolumn = "no"
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

vim.cmd.colorscheme("default");
local hi = vim.api.nvim_set_hl
hi(0, "Normal", { bg = "#111111" })
hi(0, "ColorColumn", { bg = "#222222" })
hi(0, "SignColumn", { bg = "#222222" })
hi(0, "Comment", { fg = "orange", italic = true })
hi(0, "@comment", { fg = "orange", bg = "NONE", italic = true })
hi(0, "@comment.note", { fg = "cyan", bg = "NONE", bold = true })
hi(0, "@comment.warning", { fg = "yellow", bg = "NONE", bold = true })
hi(0, "@comment.error", { fg = "red", bg = "NONE", bold = true })

vim.keymap.set("n", '<leader>w', '<C-^>', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", "<CMD>:Explore<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>r", "<CMD>:nohl<CR>", { noremap = true, silent = true })

print("We're vimming.. Have a nice day hacking! (@<@)")
