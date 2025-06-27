local config_module = require("yank-file-path.config")
local utils = require("yank-file-path.utils")

-- Load commands
require("yank-file-path.commands")

-- Export public API
local M = {
  setup = config_module.setup,
  set_root_markers = config_module.set_root_markers,
}

-- Export functions for testing
if vim.env.NVIM_TEST_MODE then
  M.format_path = utils.format_path
  M.parse_separator = utils.parse_separator
  M.get_all_buffer_paths = utils.get_all_buffer_paths
  M.copy_to_clipboard = utils.copy_to_clipboard
  M.copy_all_buffer_paths = utils.copy_all_buffer_paths
  M.find_root_dir = utils.find_root_dir
  M.config = config_module.config
  M.default_config = config_module.default_config
end

return M
