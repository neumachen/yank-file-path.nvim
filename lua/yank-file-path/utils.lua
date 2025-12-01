local config_module = require("yank-file-path.config")

---@param start_path string starting directory path
---@param root_marker string|nil specific root marker to search for (defaults to first in config)
---@return string|nil root directory path or nil if not found
local function find_root_dir(start_path, root_marker)
  local path = start_path
  if vim.fn.isdirectory(path) == 0 then
    path = vim.fn.fnamemodify(path, ":h")
  end

  local marker = root_marker or config_module.config.root_markers[1]

  while path ~= "/" and path ~= "" do
    local marker_path = path .. "/" .. marker
    if vim.fn.filereadable(marker_path) == 1 or vim.fn.isdirectory(marker_path) == 1 then
      return path
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
---@param include_range boolean|nil whether to include line range
---@param root_marker string|nil specific root marker to search for
---@return string
---see: https://vim-jp.org/vimdoc-ja/cmdline.html#filename-modifiers
local function format_path(mods, buf_path, include_line, include_range, root_marker)
  local path = buf_path or vim.fn.expand("%")
  local formatted_path

  if mods == ":root" then
    local root_dir = find_root_dir(path, root_marker)
    if root_dir then
      local root_relative = vim.fn.substitute(vim.fn.resolve(path), "^" .. vim.fn.escape(root_dir, "\\") .. "/", "", "")
      formatted_path = root_relative
    else
      local marker = root_marker or config_module.config.root_markers[1]
      error("Root directory not found. No '" .. marker .. "' marker found in any parent directory.")
    end
  else
    formatted_path = vim.fn.fnamemodify(path, mods)
  end

  if include_range then
    -- Get visual selection range if in visual mode, otherwise use current line
    local start_line, end_line
    if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
      start_line = vim.fn.line("'<")
      end_line = vim.fn.line("'>")
    else
      start_line = vim.fn.line(".")
      end_line = start_line
    end

    if start_line == end_line then
      return formatted_path .. ":" .. start_line
    else
      return formatted_path .. ":" .. start_line .. "-" .. end_line
    end
  elseif include_line then
    local line_number = vim.fn.line(".")
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
---@param include_line boolean|nil whether to include line number
---@param include_range boolean|nil whether to include line range
---@param root_marker string|nil specific root marker to search for
---@return string[]
local function get_all_buffer_paths(mods, include_line, include_range, root_marker)
  local paths = {}
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
      local path = format_path(mods, vim.api.nvim_buf_get_name(buf), include_line, include_range, root_marker)
      table.insert(paths, path)
    end
  end

  return paths
end

---@param mods string filename-modifiers
---@param include_line boolean|nil whether to include line number
---@param include_range boolean|nil whether to include line range
---@param separator string separator to use between paths
---@param root_marker string|nil specific root marker to search for
local function copy_all_buffer_paths(mods, include_line, include_range, separator, root_marker)
  local paths = get_all_buffer_paths(mods, include_line, include_range, root_marker)

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
