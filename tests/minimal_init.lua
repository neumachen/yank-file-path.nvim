-- Minimal init for testing
vim.cmd [[set runtimepath=$VIMRUNTIME]]
vim.cmd [[runtime! plugin/plenary.vim]]

-- Add current directory to runtimepath so we can require our plugin
vim.opt.runtimepath:append(".")
