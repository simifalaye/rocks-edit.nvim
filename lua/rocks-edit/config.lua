local internal = require('rocks-edit.internal')

local config = {}

---@type RocksEditConfig
local default_config = {
  sources = { unsynced = true, updates = true },
}

local current_config = vim.deepcopy(default_config)

function config.configure_from_table(tbl)
  current_config = vim.tbl_deep_extend('force', default_config, tbl)
end

function config.configure()
  local toml = internal.get_toml()

  -- Do various checks to see if this table exists

  if toml.edit then
    config.configure_from_table(toml.edit)
  end

  if vim.g.rocks_nvim.edit then
    config.configure_from_table(vim.g.rocks_nvim.edit)
  end
end

function config.get()
  return current_config
end

return config
