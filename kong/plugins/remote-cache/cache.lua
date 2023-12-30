local require = require

local contains = require('kong.tools.utils').table_contains
local provider = require('kong.plugins.remote-cache.providers')

---@class Cache
---@field config PluginSchema Cache configurations
---@field provider Provider|nil The cache provider
local M = {}

local concat = table.concat
local debug = kong.log.debug
local ipairs = ipairs
local kerr = kong.log.kerr
local lower = string.lower
local query_arg = kong.request.get_query_arg
local req = kong.request
local resp = kong.response
local sort = table.sort
local warn = kong.log.warn

-- Append data to the cache key.
--
---@param key string
---@param list table
---@param allowlist table
---@return string
local function append(key, list, allowlist)
  if not allowlist or #allowlist == 0 then
    return key
  end

  local values = {}
  for _, allowed in ipairs(allowlist) do
    local value = list[allowed]

    if value then
      if type(value) == 'table' then
        sort(value)
        value = concat(value, ',')
      end

      values[#values + 1] = allowed .. '=' .. value
    end
  end

  sort(values)

  return key .. ':' .. concat(values, ':')
end

-- New instance of Cache
--
---@param config table Cache configurations.
---@return table
function M:new(config)
  local o = {}
  setmetatable(o, self)

  self.config = config
  self.provider = nil

  self.__index = self

  return o
end

-- Connects the cache with the remote provider.
--
-- As cosockets is disabled in some phases, this method detach the provider from
-- the initialization of the Cache.
--
function M:connect()
  if self.config then
    self.provider = provider:new(self.config)
  end
end

-- Checks if config definitions allows allows this request to be cache.
--
---@param config table
---@param message_type string
---@return boolean
function M:config_allows_cache(config, message_type)
  if not contains({ 'request', 'response' }, message_type) then
    debug('message_type `' .. message_type .. '` not allowed.')
    return false
  end

  if message_type == 'request' then
    local method = req.get_method()

    if not contains(config.cache.methods, method) then
      warn("config doesn't allows cache method: " .. method .. ' for message_type: ' .. message_type)
      return false
    end
  end

  if message_type == 'response' then
    local status = resp.get_status()

    if not contains(config.cache.status, status) then
      warn("config doesn't allows cache status: " .. status .. ' for message_type: ' .. message_type)
      return false
    end
  end

  return true
end

-- Generate the cache key.
--
---@return string
function M:cache_key()
  local key = req.get_host() .. ':' .. req.get_method() .. ':' .. req.get_path()

  if self.config.cache.cache_key.vary_headers then
    key = append(key, req.get_headers(), self.config.cache.cache_key.vary_headers)
  end

  if self.config.cache.cache_key.vary_query_params then
    for _, v in ipairs(self.config.cache.cache_key.vary_query_params) do
      key = key .. ':' .. v .. '=' .. query_arg(v)
    end
  end

  key = lower(key)

  debug("generated cache key: '" .. key .. "'")

  return key
end

-- Get a key from remote cache.
--
---@param key string
---@return string|nil
function M:get(key)
  if not self.provider then
    kerr('no provider initialized')
    return nil
  end

  local data, err = self.provider:get(key)

  if err then
    warn("failed to get key '" .. key .. "'", err)

    return nil
  end

  return data == ngx.null and nil or data
end

-- Set a key from remote cache.
--
---@param key string
---@param payload string
---@param ttl? integer
function M:set(key, payload, ttl)
  if not self.provider then
    kerr('no provider initialized')
    return nil
  end

  return self.provider:et(key, payload, ttl or nil)
end

return M
