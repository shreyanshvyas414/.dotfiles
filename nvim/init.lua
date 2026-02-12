-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


-- EDITOR OPTIONS

-- Line numbers & UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.showmode = false
vim.opt.scrolloff = 5
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.winborder = "rounded"
vim.cmd([[hi @lsp.type.number gui=italic]])
vim.cmd([[set noswapfile]])


-- Tabs & indentation
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true

-- Files & undo
vim.opt.swapfile = false
vim.opt.undofile = true

-- Mouse
vim.opt.mouse = "a"

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Window splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Whitespace visualization
vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- Completion options
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- CORE KEYMAPS

-- File operations
vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Write file" })
vim.keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>o", ":update<CR>:source<CR>", { desc = "Save + reload config" })

-- System clipboard
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })

-- Center cursor on navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Completion keymaps
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })
vim.keymap.set("i", "<C-n>", "<C-n>", { desc = "Next completion item" })
vim.keymap.set("i", "<C-p>", "<C-p>", { desc = "Previous completion item" })


-- AUTOCOMMANDS

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
  desc = "Highlight yanked text",
})


vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("ColorizerAutoAttach", { clear = true }),
  callback = function(args)
    local ok, colorizer = pcall(require, "colorizer")
    if ok then
      colorizer.attach_to_buffer(args.buf)
    end
  end,
})

-- PLUGIN MANAGEMENT

vim.pack.add({
  -- Theme
  { src = "https://github.com/vague2k/vague.nvim" },

  -- File explorer
  { src = "https://github.com/stevearc/oil.nvim" },

  -- Fuzzy finder
  { src = "https://github.com/echasnovski/mini.pick" },

  -- LSP support
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },

  -- Formatter
  { src = "https://github.com/stevearc/conform.nvim" },

  -- Treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },

  -- Node selection
  { src = "https://github.com/shreyanshvyas414/ts-node-select", version = "v0.1.2" },

  -- UI helpers
  { src = "https://github.com/shreyanshvyas414/lite-ui" },

  -- Which-key
  { src = "https://github.com/folke/which-key.nvim" },

  -- Autopairs
  { src = "https://github.com/windwp/nvim-autopairs" },

  -- Git signs
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- Marks.nvim
  { src = "https://github.com/chentoast/marks.nvim" },

  -- Web dev icons
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- Rainbow delimiters
  { src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },

  -- Markdown
  {
    src = "https://github.com/selimacerbas/markdown-preview.nvim",
    build = "cd app && npm install",
  },

  -- Rust
  { src = "https://github.com/mrcjkb/rustaceanvim",        version = "v7.1.9" },

  -- Colorizer
  { src = "https://github.com/catgoose/nvim-colorizer.lua" }
})


-- vim.pack Helpers
local function pack_remove()
  local name = vim.fn.input("Plugin name to remove: ")

  if name == "" then
    vim.notify("No plugin name provided.", vim.log.levels.WARN)
    return
  end

  for _, plugin in ipairs(vim.pack.get()) do
    if plugin.spec.name == name then
      if plugin.active then
        vim.notify(
          "Plugin is currently active. Remove it from init.lua and restart before deleting.",
          vim.log.levels.ERROR
        )
        return
      end

      if vim.fn.confirm("Remove plugin '" .. name .. "'?", "&Yes\n&No", 2) == 1 then
        vim.pack.del({ name })
        vim.notify("Removed plugin: " .. name, vim.log.levels.INFO)
      end

      return
    end
  end

  vim.notify("Plugin not found: " .. name, vim.log.levels.ERROR)
end


local function pack_clean()
  local unused = {}

  for _, plugin in ipairs(vim.pack.get()) do
    if not plugin.active then
      table.insert(unused, plugin.spec.name)
    end
  end

  if #unused == 0 then
    vim.notify("No unused plugins.", vim.log.levels.INFO)
    return
  end

  if vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2) == 1 then
    vim.pack.del(unused)
  end
end

local function pack_update()
  vim.notify("Updating plugins…", vim.log.levels.INFO)
  vim.pack.update()
end

vim.keymap.set("n", "<leader>pr", pack_remove, { desc = "Pack: remove plugin" })
vim.keymap.set("n", "<leader>pc", pack_clean, { desc = "Pack: clean unused plugins" })
vim.keymap.set("n", "<leader>pu", pack_update, { desc = "Pack: update plugins" })


-- PLUGIN CONFIGURATIONS


local plugins = {
  ["colorizer"] = {
    config = {}
  },
  ["rustaceanvim"] = {
    config = {
      lazy = false,
    }
  },
  ["markdown-preview"] = {
    no_require = true,
    config = function()
      vim.g.mkdp_port = "2001"
      vim.g.mkdp_auto_start = 0
    end,
  },

  ["rainbow-delimiters"] = {
    no_require = true,
    config = function()
      vim.g.rainbow_delimiters = {
        highlight = {
          "RainbowDelimiterYellow",
          "RainbowDelimiterViolet",
          "RainbowDelimiterBlue",
        },
      }
    end,
  },
  ["marks"] = {
    module = "marks",
    config = { builtin_marks = { "<", ">", "^" }, },
  },
  ["oil"] = {
    module = "oil",
    config = {
      lsp_file_methods = {
        enabled = true,
        timeout_ms = 1000,
        autosave_changes = true,
      },
      columns = { "icon" },
      float = {
        -- max_width = 0.3,
        -- max_height = 0.6,
        border = "rounded",
      },
    },
  },
  ["lite-ui"] = {
    module = "lite-ui",
    config = {
      input = {
        auto_detect_word = true,
      },
    },
  },
  ["conform"] = {
    module = "conform",
    config = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    }
  },
  ["mason"] = { module = "mason", config = {} },
  ["ts-node-select"] = { module = "ts-node-select", config = {} },
  ["nvim-treesitter.config"] = {
    module = "nvim-treesitter.config",
    config = {
      ensure_installed = { "lua", "vim", "vimdoc", "python" },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    },
  },
  ["mini.pick"] = { module = "mini.pick", config = {} },
  ["which-key"] = { module = "which-key", config = {} },
  ["nvim-autopairs"] = { module = "nvim-autopairs", config = {} },
  ["gitsigns"] = { module = "gitsigns", config = {} },
  ["nvim-web-devicons"] = {
    module = "nvim-web-devicons",
    config = {
      color_icons = true,
      variant = "light|dark",
      strict = true,
      default = true,
      blend = 0
    },
  },
}

-- Automate config
for _, spec in pairs(plugins) do
  if spec.no_require then
    if type(spec.config) == "function" then
      spec.config()
    end
  else
    local ok, mod = pcall(require, spec.module)
    if ok and spec.config then
      mod.setup(spec.config)
    end
  end
end


-- DIAGNOSTICS

vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  virtual_text = { spacing = 2, prefix = "●" },
  underline = true,
  update_in_insert = false,
})


-- Rainbow delimiters
vim.g.rainbow_delimiters = {
  highlight = {
    "RainbowDelimiterYellow",
    "RainbowDelimiterViolet",
    "RainbowDelimiterBlue",
  },
}


-- LSP SETUP

-- Enable LSP servers
vim.lsp.enable({ "lua_ls" })

-- LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, {
        buffer = event.buf,
        desc = "LSP: " .. desc,
      })
    end

    -- LSP keybindings using mini.pick
    local pick = require("mini.pick")

    map("grr", function()
      pick.builtin.lsp({ scope = "references" })
    end, "References")

    map("gri", function()
      pick.builtin.lsp({ scope = "implementation" })
    end, "Implementations")

    map("grd", function()
      pick.builtin.lsp({ scope = "definition" })
    end, "Definitions")

    map("<leader>cr", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
    map("K", vim.lsp.buf.hover, "Hover Documentation")

    -- Enable built-in completion for this buffer
    vim.lsp.completion.enable(true, event.data.client_id, event.buf, {
      autotrigger = true,
    })
  end,
})

-- Auto trigger completion

local completion_timer = nil
local completion_delay = 100

vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
  group = vim.api.nvim_create_augroup("auto-completion", { clear = true }),
  callback = function()
    -- Cancel any pending completion
    if completion_timer then
      vim.fn.timer_stop(completion_timer)
      completion_timer = nil
    end

    -- Only proceed if menu is not visible
    if vim.fn.pumvisible() == 0 then
      -- Set a timer to trigger completion after delay
      completion_timer = vim.fn.timer_start(completion_delay, function()
        -- Check if we're still in insert mode
        if vim.fn.mode() == "i" then
          local line = vim.api.nvim_get_current_line()
          local col = vim.fn.col(".") - 1

          -- Only trigger if we have text before cursor
          if col > 0 then
            local before_cursor = line:sub(1, col)
            -- Trigger if last character is a word character or dot/colon
            if before_cursor:match("[%w_%.:]$") then
              -- Check if LSP clients are attached before trying omni-completion
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients > 0 then
                -- LSP available, use omni-completion
                local keys = vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true)
                vim.api.nvim_feedkeys(keys, "n", false)
              else
                -- No LSP, use regular keyword completion
                local keys = vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
                vim.api.nvim_feedkeys(keys, "n", false)
              end
            end
          end
        end
        completion_timer = nil
      end)
    end
  end,
})


-- LSP UTILITY COMMANDS

vim.api.nvim_create_user_command("LspLog", function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify("No LSP clients running", vim.log.levels.INFO)
  else
    for _, client in ipairs(clients) do
      vim.notify(
        string.format(
          "Client: %s (id: %d) - Status: %s",
          client.name,
          client.id,
          client.initialized and "running" or "initializing"
        ),
        vim.log.levels.INFO
      )
    end
  end
end, {})

vim.api.nvim_create_user_command("LspRestart", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP client attached to this buffer", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    vim.notify("Restarting " .. client.name, vim.log.levels.INFO)
    vim.lsp.stop_client(client.id)
    vim.defer_fn(function()
      vim.cmd("edit")
    end, 500)
  end
end, {})


-- MINI.PICK KEYMAPS

local pick = require("mini.pick")

vim.keymap.set("n", "<leader>ff", function()
  pick.builtin.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fg", function()
  pick.builtin.grep_live()
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>fb", function()
  pick.builtin.buffers()
end, { desc = "Find buffers" })

vim.keymap.set("n", "<leader>fh", function()
  pick.builtin.help()
end, { desc = "Find help" })

vim.keymap.set("n", "<leader>fd", function()
  pick.builtin.diagnostic()
end, { desc = "Find diagnostics" })

vim.keymap.set("n", "<leader>fr", function()
  pick.builtin.resume()
end, { desc = "Resume picker" })

vim.keymap.set("n", "<leader>/", function()
  pick.builtin.grep({ pattern = "", scope = "current" })
end, { desc = "Grep current buffer" })


-- OTHER PLUGIN KEYMAPS

-- Oil
vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", { desc = "Open parent directory" })

-- Diagnostics
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Open diagnostic float" })

-- Conform
vim.keymap.set("n", "<leader>cf", function()
  require("conform").format()
end, { desc = "Format file" })

-- Which-key
vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer keymaps" })


-- THEME

vim.cmd.colorscheme("vague")
