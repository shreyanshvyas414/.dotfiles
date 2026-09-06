if vim.g.neovide then
  vim.opt.guifont = "Maple Mono NF:h14"

  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_size = 0.8
  vim.g.neovide_cursor_antialiasing = true

  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_cursor_vfx_particle_density = 14
  vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
  vim.g.neovide_cursor_vfx_particle_speed = 12.0
  vim.g.neovide_cursor_vfx_particle_phase = 1.5
  vim.g.neovide_cursor_vfx_particle_curl = 1.0

  vim.g.neovide_scroll_animation_length = 0.15
  vim.g.neovide_position_animation_length = 0.12

  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  vim.g.neovide_text_gamma = 0.7
  vim.g.neovide_text_contrast = 0.1

  vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


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

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true

vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.mouse = "a"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

vim.opt.completeopt = { "menu", "menuone", "noselect" }


vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Write file" })
vim.keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>o", ":update<CR>:source<CR>", { desc = "Save + reload config" })

vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })
vim.keymap.set("i", "<C-n>", "<C-n>", { desc = "Next completion item" })
vim.keymap.set("i", "<C-p>", "<C-p>", { desc = "Previous completion item" })


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


vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/shreyanshvyas414/ts-node-select", version = "v0.1.2" },
  { src = "https://github.com/shreyanshvyas414/lite-ui" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/chentoast/marks.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
  {
    src = "https://github.com/selimacerbas/markdown-preview.nvim",
    build = "cd app && npm install",
  },
  { src = "https://github.com/mrcjkb/rustaceanvim",        version = "v7.1.9" },
  { src = "https://github.com/catgoose/nvim-colorizer.lua" },
  { src = "https://github.com/jake-stewart/multicursor.nvim", version = "1.0" },
  { src = "https://github.com/coder/claudecode.nvim", version = "v0.3.0" },
})

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


local plugins = {
  ["colorizer"] = {
    config = {},
  },
  ["rustaceanvim"] = {
    config = {
      lazy = false,
    },
  },
  ["markdown-preview"] = {
    no_require = true,
    config = function()
      vim.g.mkdp_port = "2001"
      vim.g.mkdp_auto_start = 0
    end,
  },

  ["claudecode"] = {
    no_require = true,
    config = function()
      require("claudecode").setup({
        terminal = {
          split_side = "right",
          split_width_percentage = 0.35,
          -- "auto" prefers snacks.nvim if present and falls back to Neovim's
          -- built-in terminal otherwise. Not installed here, so: native.
          provider = "auto",
          auto_close = true,
        },
      })

      local set = vim.keymap.set
      set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Claude: toggle" })
      set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude: focus" })
      set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Claude: resume session" })
      set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Claude: continue last" })
      set("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Claude: select model" })
      set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Claude: add current buffer" })
      set("x", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude: send selection" })
      set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Claude: accept diff" })
      set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Claude: deny diff" })
      set("n", "<leader>aS", "<cmd>ClaudeCodeStatus<cr>", { desc = "Claude: status" })

      -- In oil buffers <leader>as adds the file under the cursor instead. The
      -- upstream spec does this via lazy.nvim's `ft` key; vim.pack has no
      -- equivalent, so bind it per-buffer on FileType.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("claudecode-oil", { clear = true }),
        pattern = "oil",
        callback = function(args)
          set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", {
            buffer = args.buf,
            desc = "Claude: add file under cursor",
          })
        end,
      })
    end,
  },

  ["multicursor"] = {
    no_require = true,
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- VS Code's C-d. <C-n> instead, because <C-d> is scroll-and-center above
      -- and <C-n> is free in normal mode (the <C-n> map at the top is insert-only).
      set({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end, { desc = "MC: add cursor at next match" })
      set({ "n", "x" }, "<C-S-n>", function() mc.matchAddCursor(-1) end, { desc = "MC: add cursor at prev match" })
      set({ "n", "x" }, "<M-n>", function() mc.matchSkipCursor(1) end, { desc = "MC: skip match, go next" })

      -- VS Code's C-A-Down / C-A-Up. kitty binds every arrow combination
      -- (alt+, ctrl+alt+, ctrl+alt+shift+arrows) for splits/focus/resize, so
      -- those never reach nvim here - <M-j>/<M-k> are the usable keys, and
      -- j/k match vim's own down/up anyway.
      set({ "n", "x" }, "<M-j>", function() mc.lineAddCursor(1) end, { desc = "MC: add cursor below" })
      set({ "n", "x" }, "<M-k>", function() mc.lineAddCursor(-1) end, { desc = "MC: add cursor above" })
      -- Kept for Neovide and any terminal that doesn't grab these.
      set({ "n", "x" }, "<C-A-Down>", function() mc.lineAddCursor(1) end, { desc = "MC: add cursor below" })
      set({ "n", "x" }, "<C-A-Up>", function() mc.lineAddCursor(-1) end, { desc = "MC: add cursor above" })

      -- VS Code's C-S-l.
      set({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, { desc = "MC: add cursor to all matches" })
      set({ "n", "x" }, "<leader>mt", mc.toggleCursor, { desc = "MC: toggle cursors" })

      -- VS Code's alt+click (ctrl+click here; alt is the Option/Alt key in kitty).
      set("n", "<C-LeftMouse>", mc.handleMouse, { desc = "MC: add/remove cursor at click" })
      set("n", "<C-LeftDrag>", mc.handleMouseDrag)
      set("n", "<C-LeftRelease>", mc.handleMouseRelease)

      -- These only bind while multiple cursors exist, so they don't shadow anything.
      mc.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "<left>", mc.prevCursor, { desc = "MC: previous cursor" })
        layerSet({ "n", "x" }, "<right>", mc.nextCursor, { desc = "MC: next cursor" })
        layerSet({ "n", "x" }, "<leader>mx", mc.deleteCursor, { desc = "MC: delete main cursor" })
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end, { desc = "MC: enable / clear cursors" })
      end)

      -- Vague palette, matching kitty: #f9e2af accent, #3c4048 muted.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { fg = "#f9e2af" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { fg = "#3c4048", reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { fg = "#3c4048" })
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
        condition = function(bufnr)
          local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].ft)
          if not lang then return false end
          local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
          return ok and parser ~= nil
        end,
      }
    end,
  },
  ["marks"] = {
    module = "marks",
    config = { builtin_marks = { "<", ">", "^" } },
  },
  ["oil"] = {
    module = "oil",
    config = {
      view_options = {
        show_hidden = true
      },
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

        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },

        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },

        python = { "isort", "ruff_format" },
      },

    },
  },
  ["mason"] = { module = "mason", config = {} },
  ["ts-node-select"] = { module = "ts-node-select", config = {} },
  ["nvim-treesitter.config"] = {
    module = "nvim-treesitter.config",
    config = {
      ensure_installed = { "lua", "vim", "vimdoc", "python", "typescript", "tsx", "javascript", "json", "jsonc", "html", "css" },
      auto_install = false,
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
  ["which-key"] = {
    no_require = true,
    config = function()
      local wk = require("which-key")
      wk.setup({})

      -- Group labels for the <leader> prefixes. Without these the prefixes show
      -- as bare letters; every individual mapping already carries its own desc.
      wk.add({
        { "<leader>a", group = "ai (claude)" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>h", group = "help" },
        { "<leader>m", group = "multicursor" },
        { "<leader>p", group = "pack" },
      })
    end,
  },
  ["nvim-autopairs"] = { module = "nvim-autopairs", config = {} },
  ["gitsigns"] = { module = "gitsigns", config = {} },
  ["nvim-web-devicons"] = {
    module = "nvim-web-devicons",
    config = {
      color_icons = true,
      strict = true,
      default = true,
      blend = 0,
    },
  },
}

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

-- rust_analyzer is deliberately absent: rustaceanvim starts it itself, and its
-- README says enabling it here too "may cause conflicts".
vim.lsp.enable({ "lua_ls", "ts_ls", "pyright" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, {
        buffer = event.buf,
        desc = "LSP: " .. desc,
      })
    end

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

    vim.lsp.completion.enable(true, event.data.client_id, event.buf, {
      autotrigger = true,
    })
  end,
})


local completion_timer = nil
local completion_delay = 100

vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
  group = vim.api.nvim_create_augroup("auto-completion", { clear = true }),
  callback = function()
    if completion_timer then
      vim.fn.timer_stop(completion_timer)
      completion_timer = nil
    end

    if vim.fn.pumvisible() == 0 then
      completion_timer = vim.fn.timer_start(completion_delay, function()
        if vim.fn.mode() == "i" then
          local line = vim.api.nvim_get_current_line()
          local col = vim.fn.col(".") - 1

          if col > 0 then
            local before_cursor = line:sub(1, col)
            if before_cursor:match("[%w_%.:]$") then
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients > 0 then
                local keys = vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true)
                vim.api.nvim_feedkeys(keys, "n", false)
              else
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

vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", { desc = "Open parent directory" })

vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Open diagnostic float" })

vim.keymap.set("n", "<leader>cf", function()
  require("conform").format({
    async = true,
    lsp_format = "fallback"
  })
end, { desc = "Format file" })

vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer keymaps" })



local cheatsheet = {
  { "Find  (mini.pick)", {
    { "<leader>ff", "Find files" },
    { "<leader>fg", "Live grep" },
    { "<leader>fb", "Buffers" },
    { "<leader>fh", "Help tags" },
    { "<leader>fd", "Diagnostics" },
    { "<leader>fr", "Resume last picker" },
    { "<leader>/",  "Grep current buffer" },
    { "-",          "Parent directory (oil, float)" },
  } },
  { "LSP  (buffer-local, on attach)", {
    { "grd",        "Definitions" },
    { "grr",        "References" },
    { "gri",        "Implementations" },
    { "K",          "Hover documentation" },
    { "gl",         "Diagnostic float" },
    { "<leader>cr", "Rename symbol" },
    { "<leader>ca", "Code action  (n, x)" },
    { "<leader>cf", "Format buffer (conform)" },
  } },
  { "Claude Code  (claudecode.nvim)", {
    { "<leader>ac", "Toggle Claude terminal" },
    { "<leader>af", "Focus the Claude window" },
    { "<leader>ar", "Resume a previous session" },
    { "<leader>aC", "Continue the last session" },
    { "<leader>am", "Select model" },
    { "<leader>ab", "Add current buffer to context" },
    { "<leader>as", "Send selection  (visual mode)" },
    { "<leader>as", "Add file under cursor  (in oil)" },
    { "<leader>aa", "Accept the proposed diff" },
    { "<leader>ad", "Deny the proposed diff" },
    { "<leader>aS", "Integration status / port" },
  } },
  { "Multiple cursors", {
    { "<C-n>",       "Add cursor at next match   (VS Code C-d)" },
    { "<C-S-n>",     "Add cursor at prev match" },
    { "<M-n>",       "Skip this match, go to next" },
    { "<M-j>",       "Add cursor line below   (no pattern needed)" },
    { "<M-k>",       "Add cursor line above" },
    { "",            "(ctrl+alt+arrows also work, but kitty grabs them)" },
    { "<leader>ma",  "Add cursor to ALL matches  (VS Code C-S-l)" },
    { "<leader>mt",  "Toggle cursors on/off" },
    { "<C-LeftMouse>", "Add / remove cursor at click" },
    { "",            "-- while cursors are active --" },
    { "<left> <right>", "Switch which cursor is main" },
    { "<leader>mx",  "Delete the main cursor" },
    { "<Esc>",       "Clear cursors" },
    { "",            "then just type: ciwNEW, I, A, x ... at every cursor" },
  } },
  { "Edit & move", {
    { "<C-d> <C-u>", "Half-page scroll, centered" },
    { "n  N",        "Next / prev search result, centered" },
    { "<leader>y",   "Yank to system clipboard  (n, x)" },
    { "<leader>w",   "Write file" },
    { "<leader>q",   "Quit window" },
    { "<leader>o",   "Save + reload this config" },
    { "<C-Space>",   "Trigger completion  (insert)" },
  } },
  { "Plugins  (vim.pack)", {
    { "<leader>pu", "Update all plugins" },
    { "<leader>pc", "Clean unused plugins" },
    { "<leader>pr", "Remove a plugin by name" },
  } },
  { "Help", {
    { "<Space>",    "which-key popup for leader maps" },
    { "<leader>?",  "which-key: this buffer's keymaps" },
    { "<leader>hk", "This cheatsheet" },
    { ":checkhealth", "Diagnose the config" },
  } },
}

local function show_cheatsheet()
  local lines, hl = {}, {}
  local width = 0

  for _, section in ipairs(cheatsheet) do
    if #lines > 0 then table.insert(lines, "") end
    table.insert(lines, "  " .. section[1])
    table.insert(hl, { line = #lines - 1, group = "Title" })
    for _, row in ipairs(section[2]) do
      local key, desc = row[1], row[2]
      local text = key == ""
        and string.format("      %s", desc)
        or string.format("  %-16s %s", key, desc)
      table.insert(lines, text)
      if key ~= "" then
        table.insert(hl, { line = #lines - 1, group = "Special", col_end = 18 })
      else
        table.insert(hl, { line = #lines - 1, group = "Comment" })
      end
    end
  end
  for _, l in ipairs(lines) do width = math.max(width, vim.fn.strdisplaywidth(l)) end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local ns = vim.api.nvim_create_namespace("cheatsheet")
  for _, h in ipairs(hl) do
    vim.api.nvim_buf_set_extmark(buf, ns, h.line, 0, {
      end_col = math.min(h.col_end or #lines[h.line + 1], #lines[h.line + 1]),
      hl_group = h.group,
    })
  end

  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "cheatsheet"

  local height = math.min(#lines, math.floor(vim.o.lines * 0.8))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width + 4,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - (width + 4)) / 2),
    style = "minimal",
    border = "rounded",
    title = " Keymaps ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end, { buffer = buf, nowait = true, desc = "Close cheatsheet" })
  end
end

vim.api.nvim_create_user_command("Cheatsheet", show_cheatsheet, { desc = "Keymap cheatsheet" })
vim.keymap.set("n", "<leader>hk", show_cheatsheet, { desc = "Keymap cheatsheet" })


vim.cmd.colorscheme("vague")
