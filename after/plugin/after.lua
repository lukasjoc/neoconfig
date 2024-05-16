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
-- vscode.load();
-- vim.cmd([[ color morning ]])
-- vim.cmd([[ set bg=light ]])
-- vim.cmd([[ let g:everforest_better_performance = 1 ]])
-- vim.cmd([[ let g:everforest_background = "hard" ]])
-- vim.cmd("colorscheme everforest")

-- vim.cmd [[
--     let g:monotone_emphasize_comments = 1
--     " let g:monotone_color = [140, 60, 85] " Green-ish
--     let g:monotone_color = [270, 25, 90] "Black
--     let g:monotone_secondary_hue_offset = 10
--     colorscheme monotone
-- ]]

local grail = require("grail")
grail.setup()
grail.load()

local neoconf = require("neoconf")
neoconf.setup()

local neodev = require("neodev")
neodev.setup()
