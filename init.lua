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

require('config.keymaps')
require('plugins.gitsigns')
require('plugins.neotree')
require('plugins.telescope')

-- Theme Setup
-- require('onedark').setup({ style = 'warmer' })
-- require('onedark').load()
vim.cmd [[colorscheme retrobox]]

-- Mini Plugins & Extras
require('mini.ai').setup()
require('mini.basics').setup()
require('mini.surround').setup()
require('mini.pairs').setup()
require('mini.icons').setup()
require('which-key').setup()

-- Bufferline
require("bufferline").setup({
    options = {
        mode = "buffers",
        separator_style = "thin",
        always_show_bufferline = true,
    }
})

-- MQL
require("mql")


-- ====================================================================
-- Native Neovim 0.11+ LSP Configuration
-- ====================================================================

-- 1. Safely fetch default templates from nvim-lspconfig
-- (We use the internal configs table to bypass those giant deprecated warnings)
local configs            = require('lspconfig.configs')
local zls_config         = configs.zls and configs.zls.default_config or {}
local lua_config         = configs.lua_ls and configs.lua_ls.default_config or {}
local bash_config        = configs.bashls and configs.bashls.default_config or {}

-- 2. Inject native root_markers
-- (Crucial for starting 'nvim .' from a root dir so it matches your project)
zls_config.root_markers  = { 'build.zig', 'zls.json', '.git' }
bash_config.root_markers = { '.git' }

-- 3. Tailor your settings
lua_config.root_markers  = { '.luarc.json', '.git' }
lua_config.settings      = {
    Lua = {
        diagnostics = { globals = { 'vim' } },
    },
}

-- 4. Formally register them to the native Neovim system
vim.lsp.config('zls', zls_config)
vim.lsp.config('lua_ls', lua_config)
vim.lsp.config('bashls', bash_config)

-- 5. Globally enable them for automatic attachment
vim.lsp.enable('zls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('bashls')

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
require("conform").setup({
    formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
    },
    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_fallback = true,
    },
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
