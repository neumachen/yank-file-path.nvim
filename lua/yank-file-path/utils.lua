local config_module = require("yank-file-path.config")

---@param start_path string starting directory path
---@return string|nil root directory path or nil if not found
local function find_root_dir(start_path)
  local path = start_path
  if vim.fn.isdirectory(path) == 0 then
    path = vim.fn.fnamemodify(path, ":h")
  end

  while path ~= "/" and path ~= "" do
    for _, marker in ipairs(config_module.config.root_markers) do
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
---@param include_line boolean|nil whether to include line number
---@return string
---see: https://vim-jp.org/vimdoc-ja/cmdline.html#filename-modifiers
local function format_path(mods, buf_path, include_line)
  local path = buf_path or vim.fn.expand("%")
  local formatted_path

  if mods == ":root" then
    local root_dir = find_root_dir(path)
    if root_dir then
      local root_relative = vim.fn.substitute(vim.fn.resolve(path), "^" .. vim.fn.escape(root_dir, "\\") .. "/", "", "")
      formatted_path = root_relative
    else
      -- Fallback to relative path if no root found
      formatted_path = vim.fn.fnamemodify(path, ":.")
    end
  else
    formatted_path = vim.fn.fnamemodify(path, mods)
  end

  if include_line then
    local line_number = vim.fn.line('.')
    return formatted_path .. ":" .. line_number
  else
    return formatted_path
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

return {
  find_root_dir = find_root_dir,
  format_path = format_path,
  copy_to_clipboard = copy_to_clipboard,
  parse_separator = parse_separator,
  get_all_buffer_paths = get_all_buffer_paths,
  copy_all_buffer_paths = copy_all_buffer_paths,
}
