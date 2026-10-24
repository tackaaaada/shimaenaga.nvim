-- Offline validation profile: copied user modules, isolated state, shared installed clones.
local root=vim.fn.fnamemodify(debug.getinfo(1,'S').source:sub(2),':p:h:h:h')
local installed=vim.fn.expand('~/.local/share/nvim/lazy')
vim.opt.rtp:prepend(installed..'/lazy.nvim')
vim.opt.rtp:append(vim.fn.expand('~/.local/share/nvim/site'))
vim.env.PATH=vim.fn.expand('~/.local/share/nvim/mason/bin')..':'..vim.env.PATH
vim.g.mapleader=' '
vim.g.validation_root=root
local style=vim.env.SHIMAENAGA_STYLE or 'yukiyo'
local transparent=vim.env.SHIMAENAGA_TRANSPARENT=='1'
require('lazy').setup({
  root=installed,
  lockfile=vim.fn.stdpath('config')..'/lazy-lock.json',
  local_spec=false,
  spec={
    {'LazyVim/LazyVim',import='lazyvim.plugins',opts={colorscheme='shimaenaga-'..style}},
    {import='plugins'},
    {dir=root,name='shimaenaga.nvim',lazy=false,priority=1000,opts={transparent=transparent},config=function(_,opts)
      require('shimaenaga').setup(opts)
      vim.cmd.colorscheme('shimaenaga-'..style)
    end},
    {'nvim-treesitter/nvim-treesitter',opts=function(_,opts) opts.ensure_installed={} end},
    {'mason-org/mason.nvim',opts=function(_,opts)
      opts.ensure_installed={}
      opts.install_root_dir=vim.fn.stdpath('data')..'/mason'
    end,config=function(_,opts)
      require('mason').setup(opts)
      -- Offline profile: no registry refresh, package installation or update.
      require('mason-registry').refresh=function(callback) if callback then callback(false,{}) end end
    end},
    {'mason-org/mason-lspconfig.nvim',opts=function(_,opts) opts.ensure_installed={} end},
    {'neovim/nvim-lspconfig',opts=function(_,opts)
      for name,server in pairs(opts.servers) do
        if name~='*' and type(server)=='table' then
          server.mason=false
          if vim.env.SHIMAENAGA_QUICK=='1' then server.enabled=false end
        end
      end
      if opts.servers.ruby_lsp then opts.servers.ruby_lsp.enabled=false end
    end},
    {'davidgranstrom/scnvim',ft='supercollider',config=function()
      require('scnvim').setup({ensure_installed=false,postwin={float={enabled=true}},editor={highlight={color='IncSearch'}}})
    end},
    {'nvim-lualine/lualine.nvim',opts={options={
      theme='shimaenaga',
      section_separators={left='',right=''},
      component_separators={left='',right=''},
    }}},
  },
  install={missing=false,colorscheme={}},
  checker={enabled=false},change_detection={enabled=false},readme={enabled=false},
})
-- ensure_installed tables can be extended by imported specs; empty the merged lists.
for _,name in ipairs({'mason.nvim','mason-lspconfig.nvim','nvim-treesitter'}) do
  local plugin=require('lazy.core.config').plugins[name]
  if plugin then
    local values=require('lazy.core.plugin').values(plugin,'opts',false)
    values.ensure_installed={}
  end
end

vim.opt.rtp:append(vim.fn.expand("~/.local/share/nvim/site"))

vim.opt.swapfile=false

-- Comparison controls exist only in this isolated validation session.
dofile(root..'/scripts/validation/backgrounds.lua').install()
