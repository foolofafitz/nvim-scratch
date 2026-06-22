-- 1. Mini.Pairs Toggle
local function toggle_pairs()
    vim.g.minipairs_disable = not vim.g.minipairs_disable
    print("Mini.pairs: " .. (vim.g.minipairs_disable and "OFF" or "ON"))
end
vim.keymap.set("n", "<leader>up", toggle_pairs, { desc = "Toggle Auto Pairs" })

-- 2. Native Diagnostics Toggle
local function toggle_diagnostics()
    if vim.diagnostic.is_enabled() then
        vim.diagnostic.enable(false)
        print("Diagnostics: OFF")
    else
        vim.diagnostic.enable(true)
        print("Diagnostics: ON")
    end
end
vim.keymap.set("n", "<leader>ud", toggle_diagnostics, { desc = "Toggle Diagnostics" })
