-- Configuration for root markers
local config = {
  root_markers = { ".git", ".hg", ".svn", "package.json", "Cargo.toml", "go.mod", "pyproject.toml", "Makefile" }
}

---@param markers string[] list of root markers to search for
local function set_root_markers(markers)
  config.root_markers = markers
end

---@param start_path string starting directory path
---@return string|nil root directory path or nil if not found
local function find_root_dir(start_path)
  local path = start_path
  if vim.fn.isdirectory(path) == 0 then
    path = vim.fn.fnamemodify(path, ":h")
  end
  
  while path ~= "/" and path ~= "" do
    for _, marker in ipairs(config.root_markers) do
      local marker_path = path .. "/" .. marker
      if vim.fn.filereadable(marker_path) == 1 or vim.fn.isdirectory(marker_path) == 1 then
        return path
      end
    end
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then
      break
    end
    path = parent
  end
  
  return nil
end

---@param mods string filename-modifiers
---@param buf_path string|nil file path (defaults to current buffer)
---@return string
---see: https://vim-jp.org/vimdoc-ja/cmdline.html#filename-modifiers
local function format_path(mods, buf_path)
  local path = buf_path or vim.fn.expand("%")
  
  if mods == ":root" then
    local root_dir = find_root_dir(path)
    if root_dir then
      local relative_path = vim.fn.fnamemodify(path, ":.")
      local root_relative = vim.fn.substitute(vim.fn.resolve(path), "^" .. vim.fn.escape(root_dir, "\\") .. "/", "", "")
      return root_relative
    else
      -- Fallback to relative path if no root found
      return vim.fn.fnamemodify(path, ":.")
    end
  else
    return vim.fn.fnamemodify(path, mods)
  end
end

---@param path string
local function copy_to_clipboard(path)
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end

---@param separator string
---@return string
local function parse_separator(separator)
  if separator == "\\n" then
    return "\n"
  elseif separator == "\\t" then
    return "\t"
  else
    return separator
  end
end

---@param mods string filename-modifiers
---@return string[]
local function get_all_buffer_paths(mods)
  local paths = {}
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
      local path = format_path(mods, vim.api.nvim_buf_get_name(buf))
      table.insert(paths, path)
    end
  end

  return paths
end

---@param mods string filename-modifiers
local function copy_all_buffer_paths(mods, opts)
  local separator = opts.args and opts.args ~= "" and parse_separator(opts.args) or " "
  local paths = get_all_buffer_paths(mods)

  if #paths == 0 then
    vim.notify("No buffers with file paths found", vim.log.levels.WARN)
    return
  end

  local result = table.concat(paths, separator)
  copy_to_clipboard(result)
end

vim.api.nvim_create_user_command("YankRelativeFilePath", function()
  copy_to_clipboard(format_path(":."))
end, { nargs = 0, force = true, desc = "Copy relative file path to the clipboard" })

vim.api.nvim_create_user_command("YankAbsoluteFilePath", function()
  copy_to_clipboard(format_path(":p"))
end, { nargs = 0, force = true, desc = "Copy absolute file path to the clipboard" })

vim.api.nvim_create_user_command("YankRelativeFilePathFromHome", function()
  copy_to_clipboard(format_path(":~"))
end, { nargs = 0, force = true, desc = "Copy relative file path from $HOME to the clipboard" })

vim.api.nvim_create_user_command("YankFileName", function()
  copy_to_clipboard(format_path(":t"))
end, { nargs = 0, force = true, desc = "Copy just the file name to the clipboard" })

vim.api.nvim_create_user_command("YankAllRelativeFilePaths", function(opts)
  copy_all_buffer_paths(":.", opts)
end, { nargs = "?", force = true, desc = "Copy all relative file paths to the clipboard" })

vim.api.nvim_create_user_command("YankAllAbsoluteFilePaths", function(opts)
  copy_all_buffer_paths(":p", opts)
end, { nargs = "?", force = true, desc = "Copy all absolute file paths to the clipboard" })

vim.api.nvim_create_user_command("YankAllRelativeFilePathsFromHome", function(opts)
  copy_all_buffer_paths(":~", opts)
end, { nargs = "?", force = true, desc = "Copy all relative file paths from $HOME to the clipboard" })

vim.api.nvim_create_user_command("YankAllFileNames", function(opts)
  copy_all_buffer_paths(":t", opts)
end, { nargs = "?", force = true, desc = "Copy all file names to the clipboard" })

vim.api.nvim_create_user_command("YankRootRelativeFilePath", function()
  copy_to_clipboard(format_path(":root"))
end, { nargs = 0, force = true, desc = "Copy root-relative file path to the clipboard" })

vim.api.nvim_create_user_command("YankAllRootRelativeFilePaths", function(opts)
  copy_all_buffer_paths(":root", opts)
end, { nargs = "?", force = true, desc = "Copy all root-relative file paths to the clipboard" })

vim.cmd("command! YankFilePath YankRelativeFilePath")

-- Export functions for testing
if vim.env.NVIM_TEST_MODE then
  return {
    format_path = format_path,
    parse_separator = parse_separator,
    get_all_buffer_paths = get_all_buffer_paths,
    copy_to_clipboard = copy_to_clipboard,
    copy_all_buffer_paths = copy_all_buffer_paths,
    find_root_dir = find_root_dir,
    set_root_markers = set_root_markers,
    config = config,
  }
end
