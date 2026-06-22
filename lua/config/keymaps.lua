-- Clear highlights on Escape
vim.keymap.set('n', '<ESC>', ':nohlsearch<CR>', { silent = true })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to window left' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window lower' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window upper' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to window right' })

-- Buffer navigation
vim.keymap.set('n', 'H', ':BufferLineCyclePrev<CR>', { silent = true, desc = 'Prev buffer' })
vim.keymap.set('n', 'L', ':BufferLineCycleNext<CR>', { silent = true, desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bd', ':bn|bd#<CR>', { silent = true, desc = 'Delete buffer' })
vim.keymap.set("n", "<leader>bo", function()
    local current_buf = vim.api.nvim_get_current_buf()
    local bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(bufs) do
        -- Only close listed buffers that are not the current one
        if buf ~= current_buf and vim.bo[buf].buflisted then
            -- force = false ensures it won't accidentally kill unsaved work
            pcall(vim.api.nvim_buf_delete, buf, { force = false })
        end
    end
end, { desc = "Close other buffers" })

-- Tool Toggles
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { silent = true, desc = 'Toggle Neo-tree' })
vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', { silent = true, desc = 'Open LazyGit' })

-- Global LSP Diagnostics
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end,
    { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end,
    { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })
