-- Telescope
local telescope = require('telescope')
telescope.setup({
    defaults = {
        vimgrep_arguments = {
            'rg', '--color=never', '--no-heading', '--with-filename',
            '--line-number', '--column', '--smart-case',
        },
    },
})
pcall(telescope.load_extension, 'fzf') -- Gracefully try loading fzf extension

-- mappings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader> ', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep word' })
vim.keymap.set('n', '<leader>fr', ':Telescope oldfiles<CR>', { desc = 'Telescope recent files' })
vim.keymap.set('n', '<leader>bb', ':Telescope buffers<CR>', { desc = 'Telescope buffers' })
