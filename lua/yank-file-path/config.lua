-- Default configuration
local default_config = {
  root_markers = { ".git" },
  enable_default_mappings = true,
}

-- Current configuration (starts with defaults)
local config = vim.deepcopy(default_config)

---@param user_config table|nil user configuration options
local function setup(user_config)
  if user_config then
    local new_config = vim.tbl_deep_extend("force", default_config, user_config)
    -- Clear existing config and copy new values to maintain reference
    for k in pairs(config) do
      config[k] = nil
    end
    for k, v in pairs(new_config) do
      config[k] = v
    end
  else
    -- Reset to defaults
    for k in pairs(config) do
      config[k] = nil
    end
    for k, v in pairs(default_config) do
      config[k] = v
    end
  end
end

---@param markers string[] list of root markers to search for
local function set_root_markers(markers)
  config.root_markers = markers
end

return {
  config = config,
  default_config = default_config,
  setup = setup,
  set_root_markers = set_root_markers,
}
