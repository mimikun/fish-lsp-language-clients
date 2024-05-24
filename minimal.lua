-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify("./.minimal", ":p")

-- set stdpaths to use .repro
for _, name in ipairs({ "config", "data", "state", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- bootstrap lazy
local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.runtimepath:prepend(lazypath)

-- install plugins
local plugins = {
    "folke/tokyonight.nvim",
    -- add any other plugins here
    "nvim-treesitter/nvim-treesitter",
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "nvimtools/none-ls.nvim",
    "jay-babu/mason-null-ls.nvim",
    "nvim-lua/plenary.nvim",
}

require("lazy").setup(plugins, {
    root = root .. "/plugins",
    concurrency = 1,
    git = {
        timeout = 300,
    },
})

vim.cmd.colorscheme("tokyonight")
-- add anything else here
vim.opt.ambiwidth = "double"

-- nvim-treesitter/nvim-treesitter
require("nvim-treesitter.configs").setup({
    highlight = {
        enable = true,
        disable = {},
    },
    ensure_installed = { "fish", "lua", "vim", "vimdoc", "query" },
    sync_install = false,
})

-- neovim/nvim-lspconfig
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
    end,
})

-- williamboman/mason.nvim
-- williamboman/mason-lspconfig.nvim
local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

if not configs.fish_lsp then
    configs.fish_lsp = {
        default_config = {
            root_dir = function(fname)
                local root_files = lspconfig.util.root_pattern(unpack({
                    "config.fish",
                    "$HOME/.config/fish",
                    "/usr/share/fish",
                }))(fname)
                return root_files
            end,
            name = "fish-lsp",
            filetypes = { "fish" },
            autostart = true,
            single_file_support = true,
            --on_new_config = function(new_config, new_root_dir) end,
            --capabilities = {},
            cmd = { "fish-lsp", "start" },
            --handlers = {},
            --init_options = {},
            --on_attach = function(client, bufnr)end,
            settings = {},
        },
    }
end

require("mason").setup({
    max_concurrent_installers = 1,
})

require("mason-lspconfig").setup({
    handlers = {
        function(server_name)
            lspconfig[server_name].setup({})
        end,
    },
})

lspconfig.fish_lsp.setup({})

-- nvimtools/none-ls.nvim
local null_ls = require("null-ls")
local code_actions = null_ls.builtins.code_actions
local diagnostics = null_ls.builtins.diagnostics
local formatting = null_ls.builtins.formatting
--local completion = null_ls.builtins.completion
local hover = null_ls.builtins.hover

null_ls.setup({
    sources = {
        -- Code Actions
        code_actions.gitsigns,
        -- Completion
        --completion.NAME
        -- Diagnostics
        diagnostics.actionlint,
        diagnostics.checkmake,
        diagnostics.fish,
        diagnostics.selene,
        diagnostics.zsh,
        -- Formatting
        formatting.fish_indent,
        formatting.just,
        formatting.shfmt,
        formatting.stylua,
        -- Hover
        hover.dictionary,
        hover.printenv,
    },
})

-- jay-babu/mason-null-ls.nvim
require("mason-null-ls").setup({
    handlers = {},
})
