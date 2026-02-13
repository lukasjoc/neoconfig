-- WARN: AI Generated

local M = {}

function M.setup()
    -- Claude command for quick code completion
    vim.api.nvim_create_user_command('Claude', function(opts)
        local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
        local code = table.concat(lines, '\n')
        local args = opts.args

        -- Get file info
        local file_path = vim.api.nvim_buf_get_name(0)
        if file_path == "" then
            file_path = "[no file]"
        end

        local file_type = vim.bo.filetype
        if file_type == "" then
            file_type = "unknown"
        end

        -- Get line numbers
        local start_line = opts.line1
        local end_line = opts.line2

        -- Get git root
        local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub('\n', '')
        if vim.v.shell_error ~= 0 then
            git_root = nil
        end

        -- Get current git branch
        local git_branch = nil
        if git_root then
            git_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub('\n', '')
            if vim.v.shell_error ~= 0 then
                git_branch = nil
            end
        end

        -- Get current working directory
        local cwd = vim.fn.getcwd()

        -- Try to find enclosing function/class using treesitter
        local scope_name = nil
        local ok, ts = pcall(require, 'nvim-treesitter')
        if ok then
            local buf = vim.api.nvim_get_current_buf()
            local parser = vim.treesitter.get_parser(buf, file_type)
            if parser then
                local root = parser:parse()[1]:root()
                local query = vim.treesitter.query.parse(file_type,
                    '((function_declaration name: (identifier) @fname) (class_declaration name: (type_identifier) @cname))')
                if query then
                    for id, node in query:iter_captures(root, buf, start_line - 1, end_line) do
                        if query.captures[id] == "fname" or query.captures[id] == "cname" then
                            scope_name = vim.treesitter.get_node_text(node, buf)
                        end
                    end
                end
            end
        end

        -- Find terminal buffer
        local term_buf = nil
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buftype == 'terminal' then
                term_buf = buf
                break
            end
        end

        if not term_buf then
            vim.notify("No terminal buffer found", vim.log.levels.WARN)
            return
        end

        -- Build the context message
        local context = "File: " .. file_path .. "\n"
        context = context .. "Type: " .. file_type .. "\n"
        context = context .. "Lines: " .. start_line .. "-" .. end_line .. "\n"
        context = context .. "Working Dir: " .. cwd .. "\n"

        if git_root then
            context = context .. "Git Root: " .. git_root .. "\n"
        end

        if git_branch then
            context = context .. "Git Branch: " .. git_branch .. "\n"
        end

        if scope_name then
            context = context .. "Scope: " .. scope_name .. "\n"
        end

        -- Build the full message
        local message = context .. "\n"
        if args and args ~= "" then
            message = message .. args .. "\n\n"
        end
        message = message .. code

        -- Get the terminal job ID and send text to it
        local job_id = vim.b[term_buf].terminal_job_id
        if job_id then
            vim.fn.chansend(job_id, '/compact\n')
            vim.fn.chansend(job_id, message .. '\n')
        else
            vim.notify("Terminal job ID not found", vim.log.levels.WARN)
        end
    end, { range = true, nargs = '*' })
end

return M
