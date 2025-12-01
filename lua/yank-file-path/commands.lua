local utils = require("yank-file-path.utils")

---@param args string command arguments
---@return table parsed arguments
local function parse_args(args)
  local result = {
    format = nil,
    line = false,
    range = false,
    all = false,
    separator = " ",
    root_marker = nil,
  }

  local parts = vim.split(args, "%s+")
  local i = 1

  while i <= #parts do
    local part = parts[i]

    if part == "--line" then
      result.line = true
    elseif part == "--range" then
      result.range = true
    elseif part == "--all" then
      result.all = true
    elseif part:match("^--separator=") then
      result.separator = utils.parse_separator(part:sub(13)) -- Remove "--separator="
    elseif part == "--separator" and i < #parts then
      i = i + 1
      result.separator = utils.parse_separator(parts[i])
    elseif part:match("^--root=") then
      result.root_marker = part:sub(8) -- Remove "--root="
    elseif part == "--root" and i < #parts then
      i = i + 1
      result.root_marker = parts[i]
    elseif not result.format and not part:match("^--") then
      result.format = part
    end

    i = i + 1
  end

  -- Default format if none specified
  if not result.format then
    result.format = "relative"
  end

  return result
end

---@param format string format type
---@return string vim filename modifier
local function format_to_modifier(format)
  local format_map = {
    relative = ":.",
    absolute = ":p",
    filename = ":t",
    home = ":~",
    root = ":root",
  }

  return format_map[format] or ":."
end

-- Main YankFilePath command
vim.api.nvim_create_user_command("YankFilePath", function(opts)
  local args = parse_args(opts.args or "")
  local modifier = format_to_modifier(args.format)

  local success, result = pcall(function()
    if args.all then
      utils.copy_all_buffer_paths(modifier, args.line, args.range, args.separator, args.root_marker)
    else
      local path = utils.format_path(modifier, nil, args.line, args.range, args.root_marker)
      utils.copy_to_clipboard(path)
    end
  end)

  if not success then
    vim.notify("Error: " .. result, vim.log.levels.ERROR)
  end
end, {
  nargs = "*",
  force = true,
  desc = "Copy file path to clipboard with various formats and options",
  complete = function(arg_lead, _cmd_line, _cursor_pos)
    local formats = { "relative", "absolute", "filename", "home", "root" }
    local flags = { "--line", "--range", "--all", "--separator", "--root" }

    -- Simple completion - return all options
    local completions = {}
    vim.list_extend(completions, formats)
    vim.list_extend(completions, flags)

    return vim.tbl_filter(function(item)
      return item:find(arg_lead, 1, true) == 1
    end, completions)
  end,
})

-- Legacy command aliases for backward compatibility
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
  local success, result = pcall(function()
    return utils.format_path(":root")
  end)

  if success then
    utils.copy_to_clipboard(result)
  else
    vim.notify("Error: " .. result, vim.log.levels.ERROR)
  end
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
  local success, result = pcall(function()
    return utils.format_path(":root", nil, true)
  end)

  if success then
    utils.copy_to_clipboard(result)
  else
    vim.notify("Error: " .. result, vim.log.levels.ERROR)
  end
end, { nargs = 0, force = true, desc = "Copy root-relative file path with line number to the clipboard" })

-- Multiple files commands
vim.api.nvim_create_user_command("YankAllRelativeFilePaths", function(opts)
  local separator = opts.args and opts.args ~= "" and utils.parse_separator(opts.args) or " "
  utils.copy_all_buffer_paths(":.", false, false, separator)
end, { nargs = "?", force = true, desc = "Copy all relative file paths to the clipboard" })

vim.api.nvim_create_user_command("YankAllAbsoluteFilePaths", function(opts)
  local separator = opts.args and opts.args ~= "" and utils.parse_separator(opts.args) or " "
  utils.copy_all_buffer_paths(":p", false, false, separator)
end, { nargs = "?", force = true, desc = "Copy all absolute file paths to the clipboard" })

vim.api.nvim_create_user_command("YankAllRelativeFilePathsFromHome", function(opts)
  local separator = opts.args and opts.args ~= "" and utils.parse_separator(opts.args) or " "
  utils.copy_all_buffer_paths(":~", false, false, separator)
end, { nargs = "?", force = true, desc = "Copy all relative file paths from $HOME to the clipboard" })

vim.api.nvim_create_user_command("YankAllFileNames", function(opts)
  local separator = opts.args and opts.args ~= "" and utils.parse_separator(opts.args) or " "
  utils.copy_all_buffer_paths(":t", false, false, separator)
end, { nargs = "?", force = true, desc = "Copy all file names to the clipboard" })

vim.api.nvim_create_user_command("YankAllRootRelativeFilePaths", function(opts)
  local separator = opts.args and opts.args ~= "" and utils.parse_separator(opts.args) or " "
  local success, result = pcall(function()
    utils.copy_all_buffer_paths(":root", false, false, separator)
  end)

  if not success then
    vim.notify("Error: " .. result, vim.log.levels.ERROR)
  end
end, { nargs = "?", force = true, desc = "Copy all root-relative file paths to the clipboard" })
