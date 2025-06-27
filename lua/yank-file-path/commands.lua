local utils = require("yank-file-path.utils")

-- Single file commands
vim.api.nvim_create_user_command("YankRelativeFilePath", function()
  utils.copy_to_clipboard(utils.format_path(":."))
end, { nargs = 0, force = true, desc = "Copy relative file path to the clipboard" })

vim.api.nvim_create_user_command("YankAbsoluteFilePath", function()
  utils.copy_to_clipboard(utils.format_path(":p"))
end, { nargs = 0, force = true, desc = "Copy absolute file path to the clipboard" })

vim.api.nvim_create_user_command("YankRelativeFilePathFromHome", function()
  utils.copy_to_clipboard(utils.format_path(":~"))
end, { nargs = 0, force = true, desc = "Copy relative file path from $HOME to the clipboard" })

vim.api.nvim_create_user_command("YankFileName", function()
  utils.copy_to_clipboard(utils.format_path(":t"))
end, { nargs = 0, force = true, desc = "Copy just the file name to the clipboard" })

vim.api.nvim_create_user_command("YankRootRelativeFilePath", function()
  utils.copy_to_clipboard(utils.format_path(":root"))
end, { nargs = 0, force = true, desc = "Copy root-relative file path to the clipboard" })

-- Single file commands with line numbers
vim.api.nvim_create_user_command("YankRelativeFilePathWithLine", function()
  utils.copy_to_clipboard(utils.format_path(":.", nil, true))
end, { nargs = 0, force = true, desc = "Copy relative file path with line number to the clipboard" })

vim.api.nvim_create_user_command("YankAbsoluteFilePathWithLine", function()
  utils.copy_to_clipboard(utils.format_path(":p", nil, true))
end, { nargs = 0, force = true, desc = "Copy absolute file path with line number to the clipboard" })

vim.api.nvim_create_user_command("YankRelativeFilePathFromHomeWithLine", function()
  utils.copy_to_clipboard(utils.format_path(":~", nil, true))
end, { nargs = 0, force = true, desc = "Copy relative file path from $HOME with line number to the clipboard" })

vim.api.nvim_create_user_command("YankFileNameWithLine", function()
  utils.copy_to_clipboard(utils.format_path(":t", nil, true))
end, { nargs = 0, force = true, desc = "Copy file name with line number to the clipboard" })

vim.api.nvim_create_user_command("YankRootRelativeFilePathWithLine", function()
  utils.copy_to_clipboard(utils.format_path(":root", nil, true))
end, { nargs = 0, force = true, desc = "Copy root-relative file path with line number to the clipboard" })

-- Multiple files commands
vim.api.nvim_create_user_command("YankAllRelativeFilePaths", function(opts)
  utils.copy_all_buffer_paths(":.", opts)
end, { nargs = "?", force = true, desc = "Copy all relative file paths to the clipboard" })

vim.api.nvim_create_user_command("YankAllAbsoluteFilePaths", function(opts)
  utils.copy_all_buffer_paths(":p", opts)
end, { nargs = "?", force = true, desc = "Copy all absolute file paths to the clipboard" })

vim.api.nvim_create_user_command("YankAllRelativeFilePathsFromHome", function(opts)
  utils.copy_all_buffer_paths(":~", opts)
end, { nargs = "?", force = true, desc = "Copy all relative file paths from $HOME to the clipboard" })

vim.api.nvim_create_user_command("YankAllFileNames", function(opts)
  utils.copy_all_buffer_paths(":t", opts)
end, { nargs = "?", force = true, desc = "Copy all file names to the clipboard" })

vim.api.nvim_create_user_command("YankAllRootRelativeFilePaths", function(opts)
  utils.copy_all_buffer_paths(":root", opts)
end, { nargs = "?", force = true, desc = "Copy all root-relative file paths to the clipboard" })

-- Alias
vim.cmd("command! YankFilePath YankRelativeFilePath")
