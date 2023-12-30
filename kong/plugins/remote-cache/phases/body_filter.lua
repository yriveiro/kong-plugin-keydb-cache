local require = require

local cache = require('kong.plugins.remote-cache.cache')
local const = require('kong.plugins.remote-cache.constants')
local json = require('kong.plugins.remote-cache.utils.json')

---@class bodyFilterFhase
local M = {}

local get_raw_body = kong.response.get_raw_body
local time = ngx.time
local debug = kong.log.debug
local kerr = kong.log.err
local at = ngx.timer.at

-- NOTE: cosockets is disable in body_filter phase, we need to use ngx.timer.at
-- as a workaround as operations are performed in the context of the timer
-- callback handler.
--
---@async
---@package
---@param config table
---@param cache_key string
---@param response table
local function async_set(config, cache_key, response)
  at(0, function()
    ---@type Cache
    local c = cache:new(config)
    c:connect()

    local payload, err = json:encode(response)

    if not payload then
      kerr('error encoding payload for cache_key: ', cache_key, 'error: ', err)
      return
    end

    c:set(cache_key, payload, response.ttl)
  end)
end

---@param config table
function M.execute(config)
  local ctx = kong.ctx.plugin

  -- Bail out, we already had a HIT.
  if ctx.cache_status and ctx.cache_status == const.CACHE_STATUS.HIT then
    debug('bypass, this request has a fresh cache')
    return
  end

  -- Evaluate if the request meet the conditions to be cached.
  if ctx.cache_status and ctx.cache_status == const.CACHE_STATUS.BYPASS then
    debug('bypass, this request was flagged as not cacheable on previous phases')
    return
  end

  if not ctx.cacheable then
    debug('this request was flagged as not cacheable on previous phases')
    return
  end

  local body = get_raw_body()

  if body then
    local response = {
      body = body,
      body_len = #body,
      headers = ctx.response_headers,
      timestamp = time(),
      ttl = ctx.ttl,
    }

    async_set(config, ctx.cache_key, response)
  end

  debug('buffering response from upstream ...')
end

return M
