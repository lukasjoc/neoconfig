print("Have a nice day hacking! (*<*)")

-- local vscode = require("vscode")
-- local vscode_colors = require('vscode.colors').get_colors()
-- vscode.setup({
--     transparent = false,
--     italic_comments = false,
--     disable_nvimtree_bg = true,
--     color_overrides = {
--         vscLineNumber = '#FFFFFF',
--     },
--     group_overrides = {
--         Cursor = {
--             fg = vscode_colors.vscDarkBlue,
--             bg = vscode_colors.vscLightGreen,
--             bold = true,
--         },
--     }
-- })

vim.cmd([[ let g:everforest_better_performance = 1 ]])
-- vim.cmd([[ let g:everforest_background = "hard" ]])
vim.cmd("colorscheme everforest")

local neoconf = require("neoconf")
neoconf.setup()

local neodev = require("neodev")
neodev.setup()
