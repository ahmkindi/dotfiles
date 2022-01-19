--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]] -- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.lsp.diagnostics.virtual_text = false
lvim.colorscheme = "gruvbox"

vim.opt.scrolloff = 0
vim.cmd("let g:tmux_navigator_no_mappings = 1")
vim.cmd("nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>")
vim.cmd("nnoremap <silent> <c-j> :TmuxNavigateDown<cr>")
vim.cmd("nnoremap <silent> <c-k> :TmuxNavigateUp<cr>")
vim.cmd("nnoremap <silent> <c-l> :TmuxNavigateRight<cr>")
vim.cmd("nnoremap <silent> <c-o> :TmuxNavigatePrevious<cr>")

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = false
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
-- }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dashboard.active = true
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
    "bash", "javascript", "json", "lua", "python", "typescript", "dockerfile",
    "css", "go", "yaml"
}

lvim.builtin.treesitter.ignore_install = {"haskell"}
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---@usage Select which servers should be configured manually. Requires `:LvimCacheRest` to take effect.
-- See the full default list `:lua print(vim.inspect(lvim.lsp.override))`
-- vim.list_extend(lvim.lsp.override, { "pyright" })

-- ---@usage setup a server -- see: https://www.lunarvim.org/languages/#overriding-the-default-configuration
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pylsp", opts)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

local null_ls = require("null-ls")

-- register any number of sources simultaneously
local sources = {
    null_ls.builtins.formatting.prettier, null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.formatting.lua_format,
    null_ls.builtins.formatting.codespell,
    null_ls.builtins.diagnostics.write_good,
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.diagnostics.golangci_lint,
    null_ls.builtins.formatting.golines, null_ls.builtins.formatting.black
}

null_ls.setup({sources = sources})

-- Additional Plugins
lvim.plugins = {
    {"ellisonleao/gruvbox.nvim"}, {"folke/trouble.nvim", cmd = "TroubleToggle"},
    {"jxnblk/vim-mdx-js"}, {"christoomey/vim-tmux-navigator"}
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
-- }
