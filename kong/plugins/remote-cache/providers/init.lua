local keydb = require('kong.plugins.remote-cache.providers.keydb')

---@class Provider
local M = {}

local constructor = {
  keydb = function(config)
    local instance = keydb:new()

    instance:setup(config)
    return instance
  end,
}

constructor.__index = function()
  return nil
end

-- Creates a new instance of a provider.
--
---@param config table
---@return Provider|nil
function M:new(config)
  local class = constructor[config.provider.backend]

  if not class then
    return nil
  end

  return class(config)
end

return M
