-- ~/.config/nvim/init.lua
-- Native Neovim config (lazy.nvim). Ports the previous LunarVim setup:
-- gruvbox, vim-tmux-navigator, treesitter, LSP, format-on-save.

------------------------------------------------------------------- options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.tmux_navigator_no_mappings = 1 -- we set our own C-h/j/k/l below

local opt = vim.opt
opt.scrolloff = 0
opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.clipboard = "unnamedplus"

------------------------------------------------------------------- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
opt.rtp:prepend(lazypath)

------------------------------------------------------------------- plugins
require("lazy").setup({
  -- Colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function() vim.cmd.colorscheme("gruvbox") end,
  },

  -- Seamless vim<->tmux pane navigation (mirrors .tmux.conf bindings)
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp",
      "TmuxNavigateRight", "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>",     silent = true },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>",     silent = true },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>",       silent = true },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>",    silent = true },
      { "<c-o>", "<cmd>TmuxNavigatePrevious<cr>", silent = true },
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "javascript", "json", "lua", "python", "typescript",
          "tsx", "dockerfile", "css", "go", "yaml", "markdown",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>F", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
      { "<leader>b", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
    },
  },

  -- File explorer (left side, like the old nvimtree setup)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" } },
    config = function()
      require("nvim-tree").setup({
        view = { side = "left" },
        renderer = { icons = { show = { git = false } } },
      })
    end,
  },

  -- Git signs in the gutter
  { "lewis6991/gitsigns.nvim", config = true },

  -- LSP + Mason (installs language servers into user space, no sudo)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local servers = { "gopls", "ts_ls", "pyright", "lua_ls", "bashls", "yamlls" }
      require("mason-lspconfig").setup({ ensure_installed = servers })

      local caps = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then caps = cmp_lsp.default_capabilities(caps) end

      local lspconfig = require("lspconfig")
      for _, s in ipairs(servers) do
        lspconfig[s].setup({ capabilities = caps })
      end
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = { { name = "nvim_lsp" }, { name = "luasnip" } },
      })
    end,
  },

  -- Formatting on save (replaces the old null-ls sources)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          go = { "gofmt", "golines" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          css = { "prettier" },
          yaml = { "prettier" },
        },
        format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
      })
    end,
  },
}, {
  install = { colorscheme = { "gruvbox" } },
  checker = { enabled = false },
})
