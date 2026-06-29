-- Force Neovim to treat mq5 and mqh as C++ for Treesitter's sake
vim.filetype.add({
    extension = {
        mq5 = "cpp",
        mqh = "cpp",
    },
})

-- Tell Treesitter to safely map the mql5 filetype to the cpp parser
vim.treesitter.language.register("cpp", "mql5")

local function compile_mql5()
    local current_file = vim.api.nvim_buf_get_name(0)

    -- Only compile if we are actively sitting in an mq5 file
    if not current_file:match("%.mq5$") then
        vim.notify("Not a valid .mq5 file", vim.log.levels.WARN)
        return
    end

    vim.notify("Compiling with MetaEditor...", vim.log.levels.INFO)

    -- Change this to point directly to your actual MT5 installation path
    local metaeditor_path = vim.fn.expand("~/22421/MetaEditor64.exe")

    -- MetaEditor outputs a .log file with the exact same base name as the source file
    local log_file = current_file:gsub("%.mq5$", ".log")

    -- Clean up any old log file before compiling so we don't read stale errors
    if vim.fn.filereadable(log_file) == 1 then
        os.remove(log_file)
    end

    vim.system({
        "wine",
        metaeditor_path,
        "/compile:" .. current_file,
        "/log"
    }, { text = true }, function(obj)
        vim.schedule(function()
            -- MetaEditor inversion: 0 usually means it found errors/failed to build
            -- or didn't output a clean build.
            if obj.code ~= 0 then
                vim.notify("MQL5 Compilation Successful!", vim.log.levels.INFO)
                -- Clean up the log file on success so it doesn't clutter your workspace
                if vim.fn.filereadable(log_file) == 1 then os.remove(log_file) end
                vim.cmd [[ cclose ]]
            else
                vim.notify("Compilation Failed! Loading errors...", vim.log.levels.ERROR)

                if vim.fn.filereadable(log_file) == 1 then
                    -- 1. Read and decode the log file using system iconv
                    local utf8_content = vim.fn.system({ "iconv", "-f", "utf-16le", "-t", "utf-8", log_file })

                    -- Clean up Windows carriage returns
                    utf8_content = utf8_content:gsub("\r", "")
                    local raw_lines = vim.split(utf8_content, "\n", { trimempty = true })

                    local qf_items = {}

                    -- 2. Manually parse each line using a strict Lua pattern match
                    for _, line in ipairs(raw_lines) do
                        -- Match format: path/file.mq5(line,col) : error/warning message
                        local filename, lnum, col, text = line:match("^([^(]+)%((%d+),(%d+)%)%s+:%s+(.*)$")

                        if filename and lnum and col and text then
                            -- Ensure we are using clean absolute paths
                            local clean_filename = vim.trim(filename)

                            table.insert(qf_items, {
                                filename = clean_filename,
                                lnum = tonumber(lnum),
                                col = tonumber(col),
                                text = vim.trim(text),
                                type = text:lower():match("error") and "E" or "W"
                            })
                        end
                    end

                    -- 3. Load the pre-parsed items directly into the quickfix list
                    if #qf_items > 0 then
                        vim.fn.setqflist({}, ' ', {
                            title = "MQL5 Compiler Errors",
                            items = qf_items
                        })
                        -- Automatically open the quickfix window
                        vim.cmd("copen")
                    else
                        vim.notify("Failed to parse errors from log file.", vim.log.levels.WARN)
                    end
                else
                    vim.notify("Could not find compiler log file: " .. log_file, vim.log.levels.WARN)
                end
            end
        end)
    end)
end

-- Bind it to a key of your choice
vim.keymap.set("n", "<leader>mc", compile_mql5, { desc = "Compile current MQL5 file via Wine" })

-- Safely map 'l' to open errors ONLY in a true quickfix window
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function(args)
        -- Get the current buffer name
        local buf_name = vim.api.nvim_buf_get_name(args.buf)

        -- If it's a Neo-Tree buffer acting like a quickfix container, skip it entirely
        if buf_name:match("neo%-tree") then
            return
        end

        -- Strictly map it only to this specific quickfix buffer
        vim.keymap.set("n", "l", "<CR>", {
            buffer = args.buf, -- Explicitly tie it to the validated buffer ID passed by the autocmd
            remap = true,
            desc = "Open quickfix entry under cursor"
        })
    end,
})
