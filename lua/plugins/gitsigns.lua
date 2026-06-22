-- Gitsigns
require('gitsigns').setup({
    on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation (Jump between hunks)
        map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gitsigns.nav_hunk('next') end)
            return '<Ignore>'
        end, { expr = true, desc = "Next Hunk" })

        map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gitsigns.nav_hunk('prev') end)
            return '<Ignore>'
        end, { expr = true, desc = "Prev Hunk" })

        -- Actions (Stage, Reset, Preview)
        map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = "Stage Hunk" })
        map('v', '<leader>ghs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
            { desc = "Stage Selection" })
        map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = "Reset Hunk" })
        map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = "Preview Hunk" })
        map('n', '<leader>ghu', gitsigns.undo_stage_hunk, { desc = "Undo Stage Hunk" })
    end
})
