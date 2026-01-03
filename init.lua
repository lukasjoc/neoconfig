-- NOTE: Requires v0.11.0

-- The `require("lspconfig")` "framework" is deprecated, use vim.lsp.config (see :h elp lspconfig-nvim-0.11) instead.
vim.deprecate = function() end -- TODO: fix this deprecation

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

-- Prevent automatic comment insertion.
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
    { "neovim/nvim-lspconfig", }, -- @deprecated (eslint :eyes:)
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
    { "nvim-telescope/telescope.nvim",   tag = "0.1.8" },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "numToStr/Comment.nvim" },                                              -- TOOD: Find a way to get rid of this
    { "RRethy/nvim-align" },                                                  -- TOOD: Find a way to get rid of this
    { "lewis6991/gitsigns.nvim" },
    { "akinsho/git-conflict.nvim",       version = "2.1.0",  config = true }, -- TOOD: Find a way to get rid of this
    {
        "saghen/blink.cmp",
        -- dependencies = { "rafamadriz/friendly-snippets" },

        -- use a release tag to download pre-built binaries
        version = "1.*",

        ---@module "blink.cmp"
        ---@type blink.cmp.Config
        opts = {
            -- "default" (recommended) for mappings similar to built-in completions (C-y to accept)
            -- "super-tab" for mappings similar to vscode (tab to accept)
            -- "enter" for enter to accept
            -- "none" for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = {
                preset = "default",
                ["<C-w>"] = { "select_and_accept", "fallback" },
            },

            appearance = {
                -- "mono" (default) for "Nerd Font Mono" or "normal" for "Nerd Font"
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono"
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = {
                documentation = { auto_show = false },
                accept = { auto_brackets = { enabled = false }, },
                ghost_text = { enabled = true },
            },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" }
    }
}

require("lazy").setup(lazyPackages, {})

vim.cmd.colorscheme(
-- "default",
    "zenburn"
)

local hi = vim.api.nvim_set_hl
hi(0, "ColorColumn", { bg = "#333333" })
hi(0, "SignColumn", { bg = "#333333" })
hi(0, "NormalFloat", { link = "Float" })
hi(0, "Comment", { fg = "#82a282", italic = true })
hi(0, "@comment", { fg = "#82a282", bg = "NONE", italic = true })
hi(0, "@comment.note", { fg = "cyan", bg = "NONE", bold = true })
hi(0, "@comment.warning", { fg = "yellow", bg = "NONE", bold = true })
hi(0, "@comment.error", { fg = "red", bg = "NONE", bold = true })

require("Comment").setup({
    toggler = { line = "<leader>c" },
    opleader = { line = "<leader>c" },
})

require("telescope").setup({
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

require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "comment" },
    sync_install = true,
    auto_install = false,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
})

local make_picker_for_cmd = function(cmd)
    return function()
        cmd(require("telescope.themes").get_ivy({
            border = false,
            shorten_path = true,
            layout_config = { height = 40 }
        }))
    end
end

vim.keymap.set("n", "<leader><leader>f", make_picker_for_cmd(require("telescope.builtin").find_files), {})
vim.keymap.set("n", "<leader><leader>l", make_picker_for_cmd(require("telescope.builtin").current_buffer_fuzzy_find), {})
vim.keymap.set("n", "<leader><leader>o", make_picker_for_cmd(require("telescope.builtin").oldfiles), {})
vim.keymap.set("n", "<leader><leader>g", make_picker_for_cmd(require("telescope.builtin").live_grep), {})
vim.keymap.set("n", "<leader><leader>s", make_picker_for_cmd(require("telescope.builtin").grep_string), {})
vim.keymap.set("n", "<leader><leader>r", make_picker_for_cmd(require("telescope.builtin").resume), {})
vim.keymap.set("n", "<leader><leader>b", make_picker_for_cmd(require("telescope.builtin").buffers), {})

if vim.loop.fs_stat(vim.loop.cwd() .. "/" .. ".oxlintrc.json") then
    vim.lsp.enable("oxlint")
else
    -- TODO: lspconfig sets up the client commands in a certain way that i dont get
    -- out of the box with `vim.lsp.` so i have to find a way to achive that as well.
    require("lspconfig").eslint.setup({
        cmd = { "vscode-eslint-language-server", "--stdio" },
        filetypes = { "vue", "typescript", "javascript" },
    })
end

--- @return string
local nvm_bin = function()
    local nvm_bin = require("os").getenv("NVM_BIN") or ""
    return string.match(nvm_bin, "(.*)/", nil) or ""
end

vim.lsp.config("typescript", {
    cmd = { "typescript-language-server", "--stdio" },
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = nvm_bin() .. "/lib/node_modules/@vue/language-server",
                languages = { "vue" },
                configNamespace = "typescript",
            },
        },
    },
    filetypes = { "typescript", "javascript", "vue" },
})

vim.lsp.config("vue", {
    cmd = { "vue-language-server", "--stdio" },
    filetypes = { "vue" },
    on_init = function(client)
        client.handlers["tsserver/request"] = function(_, result, context)
            local ts_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "typescript" })
            local clients = {}

            vim.list_extend(clients, ts_clients)

            if #clients == 0 then
                vim.notify("Could not find `vtsls` or `typescript` lsp client, `vue` would not work without it.",
                    vim.log.levels.ERROR)
                return
            end
            local ts_client = clients[1]

            ---@diagnostic disable-next-line: deprecated
            local id, command, payload = unpack(unpack(result))
            ts_client:exec_cmd({
                title = "vue_request_forward", -- You can give title anything as it"s used to represent a command in the UI, `:h Client:exec_cmd`
                command = "typescript.tsserverRequest",
                arguments = {
                    command,
                    payload,
                },
            }, { bufnr = context.bufnr }, function(_, r)
                local response = r and r.body
                -- TODO: handle error or response nil here, e.g. logging
                -- NOTE: Do NOT return if there"s an error or no response, just return nil back to the vue to prevent memory leak
                local response_data = { { id, response } }

                ---@diagnostic disable-next-line: param-type-mismatch
                client:notify("tsserver/response", response_data)
            end)
        end
    end,
})

vim.lsp.config.lua    = {
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

vim.lsp.config.go     = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gosum" },
}

vim.lsp.config.rust   = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
}

vim.lsp.config.json   = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json" },
}

vim.lsp.config.yaml   = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
}

vim.lsp.config.python = {
    cmd = { "pylsp" },
    filetypes = { "python" },
    plugins = {
        ruff = {
            enabled = true,       -- Enable the plugin
            formatEnabled = true, -- Enable formatting using ruffs formatter
            -- executable = "<path-to-ruff-bin>", -- Custom path to ruff
            -- config = "<path_to_custom_ruff_toml>", -- Custom config for ruff to use
            extendSelect = { "I" },          -- Rules that are additionally used by ruff
            extendIgnore = { "C90" },        -- Rules that are additionally ignored by ruff
            format = { "I" },                -- Rules that are marked as fixable by ruff that should be fixed when running textDocument/formatting
            severities = { ["D212"] = "I" }, -- Optional table of rules where a custom severity is desired
            unsafeFixes = false,             -- Whether or not to offer unsafe fixes as code actions. Ignored with the "Fix All" action
            unfixable = { "F401" },          -- Rules that are excluded when checking the code actions (including the "Fix All" action)

            -- Rules that are ignored when a pyproject.toml or ruff.toml is present:
            lineLength = 90,                                 -- Line length to pass to ruff checking and formatting
            exclude = { "__about__.py" },                    -- Files to be excluded by ruff checking
            select = { "F" },                                -- Rules to be enabled by ruff
            ignore = { "D210" },                             -- Rules to be ignored by ruff
            perFileIgnores = { ["__init__.py"] = "CPY001" }, -- Rules that should be ignored for specific files
            preview = false,                                 -- Whether to enable the preview style linting and formatting.
            targetVersion = "py310",                         -- The minimum python version to target (applies for both linting and formatting).
        },
    },
}

vim.lsp.enable({
    "lua",
    "go",
    "rust",
    "json",
    "yaml",
    "typescript",
    "vue",
    "python",
})

require("gitsigns").setup();

vim.keymap.set("n", "<leader>bl", function()
    require("gitsigns").blame_line({
        full = true,
        ignore_whitespace = true,
    })
end, { noremap = true, silent = true })

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

vim.keymap.set("n", "<leader>w", "<C-^>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", "<CMD>:Explore<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>r", vim.cmd.nohl, { noremap = true, silent = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(event)
        local opts = { buffer = event.buf, noremap = true }
        vim.keymap.set("n", "<leader>v", toggle_virtual_lines, opts)
        vim.keymap.set("n", "F", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "single" })
        end, opts)
        vim.keymap.set("n", "S", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>re", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gl", vim.lsp.buf.definition, opts)
        vim.keymap.set({ "n", "v" }, "<leader>we", function()
            if #vim.lsp.get_clients({ name = "eslint" }) > 0 then
                vim.api.nvim_command("EslintFixAll")
            else
                vim.lsp.buf.format({ async = true })
            end
        end, opts)
        vim.keymap.set("n", "<leader><leader>e", make_picker_for_cmd(require("telescope.builtin").diagnostics), opts)
        vim.keymap.set("n", "U", make_picker_for_cmd(require("telescope.builtin").lsp_references), opts)
    end
})

-- Setup for custom text formats and languages..
vim.filetype.add({ extension = { tsm = "tsm" } })   -- tiny IR format
vim.filetype.add({ extension = { tm = "tm" } })     -- tiny source format
vim.filetype.add({ extension = { act = "act" } })
vim.filetype.add({ extension = { aocl = "aocl" } }) -- AOC Language Challenge

print("Were vimming.. Have a nice day hacking! (@<@)")
