-- Minimal init for testing
vim.cmd([[set runtimepath=$VIMRUNTIME]])

-- Get the current working directory (should be project root)
local project_root = vim.fn.getcwd()

-- Add project root to runtimepath so Neovim can find our plugin
vim.opt.runtimepath:prepend(project_root)

-- Add plenary to runtimepath - try multiple possible locations
local plenary_paths = {
  vim.fn.stdpath("data") .. "/site/pack/vendor/start/plenary.nvim",
  vim.fn.stdpath("data") .. "/lazy/plenary.nvim",
  vim.fn.expand("~/.local/share/nvim/site/pack/vendor/start/plenary.nvim"),
  vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim"),
}

for _, path in ipairs(plenary_paths) do
  if vim.fn.isdirectory(path) == 1 then
    vim.opt.runtimepath:append(path)
    break
  end
end

-- Set up package path to find lua modules
package.path = project_root .. "/lua/?.lua;" .. project_root .. "/lua/?/init.lua;" .. package.path

-- Load plenary
vim.cmd([[runtime! plugin/plenary.vim]])
