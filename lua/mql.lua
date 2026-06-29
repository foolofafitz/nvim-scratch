-- Force Neovim to treat mq5 and mqh as C++ for Treesitter's sake
vim.filetype.add({
    extension = {
        mq5 = "cpp",
        mqh = "cpp",
    },
})

-- Tell Treesitter to safely map the mql5 filetype to the cpp parser
-- (Run :TSInstall cpp if you don't have it installed)
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

    -- Use vim.system for clean, modern asynchronous background process execution
    vim.system({
        "wine",
        metaeditor_path,
        "/compile:" .. current_file,
        "/log"
    }, { text = true }, function(obj)
        vim.schedule(function()
            if obj.code == 0 then
                vim.notify("MQL5 Compilation Successful!", vim.log.levels.INFO)
            else
                vim.notify("Compilation Failed! Check logs.", vim.log.levels.ERROR)
                -- Optional: You can inspect obj.stderr or look at the generated .log file here
            end
        end)
    end)
end

-- Bind it to a key of your choice (e.g., <leader>mc for "MQL Compile")
vim.keymap.set("n", "<leader>mc", compile_mql5, { desc = "Compile current MQL5 file via Wine" })
