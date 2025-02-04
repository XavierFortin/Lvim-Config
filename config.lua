-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Enable powershell as your default shell
vim.opt.shell = "pwsh.exe"
vim.opt.termguicolors = true
vim.opt.shellcmdflag =
"-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.cmd [[
		let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		set shellquote= shellxquote=
  ]]

-- Set a compatible clipboard manager
vim.g.clipboard    = {
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "win32yank.exe -o --lf",
    ["*"] = "win32yank.exe -o --lf",
  },
}

vim.opt.timeoutlen = 100
vim.keymap.set('n', '<M-h>', '<cmd>BufferLineCyclePrev<cr>', { silent = true })
vim.keymap.set('n', '<M-l>', '<cmd>BufferLineCycleNext<cr>', { silent = true })
vim.keymap.set('n', "<C-k>", '<cmd>lua vim.lsp.buf.signature_help()<CR>', { silent = true })

lvim.lsp.installer.setup.automatic_installation           = false

lvim.builtin.telescope.defaults.layout_config.width       = 0.95

lvim.builtin.which_key.setup.plugins.presets.g            = true
lvim.builtin.which_key.setup.plugins.presets.text_objects = true
lvim.builtin.which_key.setup.plugins.presets.z            = true
lvim.builtin.which_key.setup.plugins.presets.operators    = true
lvim.builtin.nvimtree.setup.renderer.root_folder_label    = false
lvim.format_on_save.enabled                               = true




local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "eslint_d",  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
  { command = "jsonlint",  filetypes = { "json" } },
  { command = "stylelint", filetypes = { "css", "scss", "less" } },
}

lvim.plugins = {
  -- Copilot plugins are defined below:
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup({
        suggestion = { enabled = true },
        panel = { enabled = false }
      })
    end
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts) require 'lsp_signature'.setup(opts) end
  },
  {
    "folke/tokyonight.nvim",
  },
  {
    "navarasu/onedark.nvim",
    lazy = false,
    config = function()
      require("onedark").setup({
        style = "deep",
      })
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup {
        current_line_blame = true,
      }
    end,
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup {
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      }
    end
  },
  {
    "rcarriga/nvim-notify",
    config = {
      render = "compact",
      fps = 60,
      timeout = 300,
      stages = "fade",
    }
  },
  { 'echasnovski/mini.icons', version = false },
  {
    'echasnovski/mini.ai',
    version = false,
    config = function()
      require('mini.ai').setup()
    end
  },
  {
    "debugloop/telescope-undo.nvim",
    dependencies = { -- note how they're inverted to above example
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { -- lazy style key map
        "<leader>u",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
    },
    opts = {
      -- don't use `defaults = { }` here, do this in the main telescope spec
      extensions = {
        undo = {
          -- telescope-undo.nvim config, see below
        },
        -- no other extensions here, they can have their own spec too
      },
    },
    config = function(_, opts)
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is in it's own namespace (telescope
      -- defaults, as well as each extension).
      require("telescope").setup()
      require("telescope").load_extension("undo")
    end,
  },
}

lvim.builtin.which_key.mappings["u"] = {
  "<cmd>Telescope undo<cr>", "Undo Tree"
}

vim.notify = require("notify")

lvim.colorscheme = "tokyonight-night"
-- Below config is required to prevent copilot overriding Tab with a suggestion
-- when you're just trying to indent!
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end
local on_tab = vim.schedule_wrap(function(fallback)
  local cmp = require("cmp")
  if cmp.visible() and has_words_before() then
    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
  else
    fallback()
  end
end)
lvim.builtin.cmp.mapping["<Tab>"] = on_tab
