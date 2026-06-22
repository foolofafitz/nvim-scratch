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
