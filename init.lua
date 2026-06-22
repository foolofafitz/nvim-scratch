-- ========================================================================== --
-- [[ 1. GLOBAL SETTINGS & LEADER ]]                                         --
-- ========================================================================== --

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Quality of life native settings
vim.opt.number = true             -- Show line numbers
vim.opt.mouse = "a"               -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Sync clipboard with OS
vim.opt.termguicolors = true

-- Tabs & Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search tweaks
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Native Omni-Completion tweaks
vim.opt.complete = ".,o"                                 -- Use buffer and omnifunc
vim.opt.completeopt = { "fuzzy", "menuone", "noselect" } -- Smooth completion UI
vim.opt.autocomplete = true
vim.opt.pumheight = 7

-- Plugin specific globals
vim.g.nvim_tree_respect_buf_cwd = 1


-- ========================================================================== --
-- [[ 2. PACKAGE MANAGEMENT ]]                                               --
-- ========================================================================== --

vim.pack.add({
    -- Core dependencies
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",

    -- UI / Aesthetics
    "https://github.com/navarasu/onedark.nvim",
    "https://github.com/akinsho/bufferline.nvim",
    "https://github.com/folke/which-key.nvim",

    -- Utilities & Navigation
    {
        src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
        version = vim.version.range('3')
    },
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
    "https://github.com/kdheepak/lazygit.nvim",

    -- Git & Coding helpers
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/stevearc/conform.nvim",
})


-- ========================================================================== --
-- [[ 3. PLUGIN CONFIGURATIONS ]]                                            --
-- ========================================================================== --

-- Theme Setup
require('onedark').setup({ style = 'darker' })
require('onedark').load()

-- Mini Plugins & Extras
require('mini.ai').setup()
require('mini.basics').setup()
require('mini.surround').setup()
require('mini.pairs').setup()
require('which-key').setup()

-- Gitsigns
require('gitsigns').setup()

-- Bufferline
require("bufferline").setup({
    options = {
        mode = "buffers",
        separator_style = "thin",
        always_show_bufferline = true,
    }
})

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

-- Neo-tree
require("neo-tree").setup({
    window = {
        mappings = {
            ["h"] = "close_node",
            ["l"] = "open",
        }
    },
    filesystem = {
        filesystem = {
            bind_to_cwd = true,
            cwd_target = {
                sidebar = "tab",
                current = "window"
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


-- ========================================================================== --
-- [[ 4. LANGUAGE SERVER SETUP (LSP) ]]                                      --
-- ========================================================================== --

-- 1. Grab default configurations
local zls_config = vim.lsp.config.zls
local lua_config = vim.lsp.config.lua_ls
local bash_config = vim.lsp.config.bashls

-- 2. Tailor settings
lua_config.settings = {
    Lua = {
        diagnostics = { globals = { 'vim' } },
    },
}

-- 3. Register and enable natively
vim.lsp.config('zls', zls_config)
vim.lsp.config('lua_ls', lua_config)
vim.lsp.config('bashls', bash_config)

vim.lsp.enable('zls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('bashls')


-- ========================================================================== --
-- [[ 5. KEYMAPS ]]                                                          --
-- ========================================================================== --

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

-- Telescope mappings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader> ', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep word' })

-- Tool Toggles
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { silent = true, desc = 'Toggle Neo-tree' })
vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', { silent = true, desc = 'Open LazyGit' })

-- Global LSP Diagnostics
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end,
    { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end,
    { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })


-- ========================================================================== --
-- [[ 6. AUTOCOMMANDS & USER COMMANDS ]]                                     --
-- ========================================================================== --

-- Dynamic Context-Based LSP Keymaps
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

        -- Setup Native Autocompletion window item labels
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {
            convert = function(item)
                local abbr = item.label
                abbr = abbr:gsub("%b()", ""):gsub("%b{}", "")
                abbr = abbr:match("[%w_.]+.*") or abbr
                abbr = #abbr > 15 and abbr:sub(1, 14) .. "…" or abbr

                local menu = item.detail or ""
                menu = #menu > 15 and menu:sub(1, 14) .. "…" or menu

                return { abbr = abbr, menu = menu }
            end,
        })
    end,
})

-- Format on Save
local format_sync_grp = vim.api.nvim_create_augroup("FormatOnSave", {})
vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_sync_grp,
    pattern = "*",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- Native Package Commands
vim.api.nvim_create_user_command('PackUpdate', function() vim.pack.update() end, {})

-- Clean Config Hot-Reload
vim.keymap.set("n", "<leader>r", function()
    if pcall(require, "neo-tree") then
        vim.cmd("Neotree close")
    end

    for name, _ in pairs(package.loaded) do
        if name:match("^neo%-tree") or name:match("^user") then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
    print("Config reloaded cleanly!")
end, { desc = "Reload configuration" })
