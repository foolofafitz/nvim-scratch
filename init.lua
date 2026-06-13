-- Remap space as leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Quality of life native settings
vim.opt.number = true             -- Show line numbers
-- vim.opt.relativenumber = true  -- Relative line numbers (great for jumps)
vim.opt.mouse = "a"               -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Sync clipboard with OS

-- Tabs & Indentation (Adjust to your liking)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search tweaks
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.g.nvim_tree_respect_buf_cwd = 1

-- Keep the default color scheme you liked!
-- vim.cmd("colorscheme habamax") -- Or "torte", "quiet", etc. Try :colorscheme <tab>

-- Nuke and reload config
vim.keymap.set("n", "<leader>r", function()
    -- 1. Cleanly shut down Neo-tree so it destroys its buffers
    local pcall_ok, neotree = pcall(require, "neo-tree")
    if pcall_ok then
        vim.cmd("Neotree close")
    end

    -- 2. Clear Neo-tree and user modules from Lua's cache
    for name, _ in pairs(package.loaded) do
        if name:match("^neo%-tree") or name:match("^user") then
            package.loaded[name] = nil
        end
    end

    -- 3. Reload the config
    dofile(vim.env.MYVIMRC)
    print("Config reloaded cleanly!")
end, { desc = "Reload configuration" })

vim.pack.add({
    {
        src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
        version = vim.version.range('3')
    },
    -- dependencies
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/akinsho/bufferline.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    'https://github.com/nvim-mini/mini.nvim',
    "https://github.com/folke/which-key.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
})

require('gitsigns').setup({
    -- Default settings will automatically show:
    --  +  green plus signs for added lines
    --  ~  orange tildes for modified lines
    --  _  red underlines/bars for deleted lines
})

require("neo-tree").setup({
    window = {
        mappings = {
            ["h"] = "close_node",
            ["l"] = "open",
        }
    },
    filesystem = {
        filesystem = {
            bind_to_cwd = true,    -- true creates a 2-way binding between vim's cwd and neo-tree's root
            cwd_target = {
                sidebar = "tab",   -- sidebar is when position = left or right
                current = "window" -- current is when position = current
            },
        },

    },
    default_component_configs = {
        git_status = {
            symbols = {
                added     = "✚",
                modified  = "",
                deleted   = "✖",
                renamed   = "󰁕",
                untracked = "",
                ignored   = "",
                unstaged  = "󰄱",
                staged    = "",
                conflict  = "",
            }
        }
    },
})

-- Window navigation shortcuts
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to window left' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window lower' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window upper' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to window right' })

-- Toggle Neo-tree file explorer
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { silent = true, desc = 'Toggle Neo-tree' })

-- Initialize the bufferline
require("bufferline").setup({
    options = {
        mode = "buffers",         -- Show open buffers, not vim tabs
        separator_style = "thin", -- Clean minimalist look
        always_show_bufferline = true,
    }
})

-- Move between buffers with Shift+H and Shift+L
vim.keymap.set('n', 'H', ':BufferLineCyclePrev<CR>', { silent = true, desc = 'Prev buffer' })
vim.keymap.set('n', 'L', ':BufferLineCycleNext<CR>', { silent = true, desc = 'Next buffer' })

-- Create an autocommand group for formatting
local format_sync_grp = vim.api.nvim_create_augroup("FormatOnSave", {})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_sync_grp,
    pattern = "*",
    callback = function()
        -- This invokes the native Neovim LSP formatter asynchronously
        vim.lsp.buf.format({ async = false })
    end,
})

-- Modern Neovim LSP Configuration (v0.11+)
-- No 'require', everything goes straight into the native core API

-- 1. Get the default configurations shipped by the plugin repository
local zls_config = vim.lsp.config.zls
local lua_config = vim.lsp.config.lua_ls
local bash_config = vim.lsp.config.bashls

-- 2. Modify the Lua settings so it doesn't complain about the 'vim' global
lua_config.settings = {
    Lua = {
        diagnostics = {
            globals = { 'vim' },
        },
    },
}

-- 3. Register and enable the configurations natively
vim.lsp.config('zls', zls_config)
vim.lsp.config('lua_ls', lua_config)
vim.lsp.config('bashls', bash_config)

vim.lsp.enable('zls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('bashls')

-- prevent the built-in vim.lsp.completion autotrigger from selecting the first item
vim.opt.completeopt = { "menuone", "noselect", "popup" }
-- require("lspconfig")["lua_ls"].setup({
--     on_attach = function(client, bufnr)
--         vim.lsp.completion.enable(true, client.id, bufnr, {
--             autotrigger = true,
--             convert = function(item)
--                 return { abbr = item.label:gsub("%b()", "") }
--             end,
--         })
--         vim.keymap.set("i", "<C-space>", vim.lsp.completion.get, { desc = "trigger autocompletion" })
--     end
-- })

-- Global LSP Diagnostics mappings
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to diagnostic error' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to diagnostic error' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })

-- Use an autocommand to only map these keys when an LSP actually attaches to a file
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }

        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)                   -- Jump to definition!
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                         -- Show documentation popup
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)               -- Smart rename variable across file
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- Code actions/quick fixes
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)                   -- Find where this is used
    end,
})

require('mini.basics').setup()
require('mini.surround').setup()
require('which-key').setup()

-- Using vim.pack
vim.pack.add({
    "https://github.com/navarasu/onedark.nvim",
})
require('onedark').setup {
    style = 'darker'
}
require('onedark').load()

-- Completion
vim.o.complete = ".,o"                       -- use buffer and omnifunc
vim.o.completeopt = "fuzzy,menuone,noselect" -- add 'popup' for docs (sometimes)
vim.o.autocomplete = true
vim.o.pumheight = 7

vim.lsp.enable({ "mylangservers" })

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {
            -- Optional formating of items
            convert = function(item)
                -- Remove leading misc chars for abbr name,
                -- and cap field to 25 chars
                --local abbr = item.label
                --abbr = abbr:match("[%w_.]+.*") or abbr
                --abbr = #abbr > 25 and abbr:sub(1, 24) .. "…" or abbr
                --
                -- Remove return value
                --local menu = ""

                -- Only show abbr name, remove leading misc chars (bullets etc.),
                -- and cap field to 15 chars
                local abbr = item.label
                abbr = abbr:gsub("%b()", ""):gsub("%b{}", "")
                abbr = abbr:match("[%w_.]+.*") or abbr
                abbr = #abbr > 15 and abbr:sub(1, 14) .. "…" or abbr

                -- Cap return value field to 15 chars
                local menu = item.detail or ""
                menu = #menu > 15 and menu:sub(1, 14) .. "…" or menu

                return { abbr = abbr, menu = menu }
            end,
        })
    end,
})

vim.api.nvim_create_user_command('PackUpdate', function() vim.pack.update() end, {})
