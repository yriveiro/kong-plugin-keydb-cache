local require = require

local cache = require('kong.plugins.remote-cache.cache')
local const = require('kong.plugins.remote-cache.constants')
local header = require('kong.plugins.remote-cache.utils.http.headers')
local http = require('kong.plugins.remote-cache.utils.http')

---@class HeaderFilterPhase
local M = {}

local get_headers = kong.response.get_headers
local set_header = kong.response.set_header
local type = type

local concat = table.concat

--Set the status of the response as Bypass.
--
---@package
local function bypass()
  local ctx = kong.ctx.plugin

  ctx.cache_status = const.CACHE_STATUS.BYPASS
  ctx.cacheable = false

  set_header(const.HEADERS.CACHE_STATUS, ctx.cache_status)
end

---@param config table Plugin configuration
function M.execute(config)
  local c = cache:new(config)
  local cache_control = get_headers()['cache_control']
  local ctx = kong.ctx.plugin

  -- Any response is cacheable from the beginning.
  ctx.cacheable = true

  -- Validate against the plugin configurations this response match cache rules.
  if not c:config_allows_cache(config, 'response') then
    bypass()
    return
  end

  if config.cache.strategy == const.STRATEGY.CACHE_CONTROL then
    -- Check is response is cacheable.
    if cache_control then
      if type(cache_control) == 'table' then
        cache_control = concat(cache_control, ', ')
      end

      if http:no_cache(cache_control, 'response') then
        bypass()
        return
      end
    end
  end

  if config.cache.strategy == const.STRATEGY.EXPIRED then
  end

  if config.cache.strategy == const.STRATEGY.TTL then
  end

  -- Calculate ttl for body_filter phase inject it on cache provider set operation.
  -- if the TTL from cache control is zero, use the configured fallback.
  local ttl = http:ttl(cache_control)

  ctx.ttl = ttl > 0 and ttl or config.cache.ttl
  ctx.response_headers = header:filter_headers(get_headers(), { const.HEADERS.CACHE_STATUS })
end

return M
