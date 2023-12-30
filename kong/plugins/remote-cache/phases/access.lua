-- INFO: Lua has faster access for local variables.
--
---@see http://lua-users.org/wiki/OptimisingUsingLocalVariables
--
local require = require

local cache = require('kong.plugins.remote-cache.cache')
local const = require('kong.plugins.remote-cache.constants')
local http = require('kong.plugins.remote-cache.utils.http')
local json = require('kong.plugins.remote-cache.utils.json')

---@class AccessPhase
local M = {}

local concat = table.concat
local exit = kong.response.exit
local floor = math.floor
local get_headers = kong.request.get_headers
local resp = kong.response
local set_header = kong.response.set_header
local time = ngx.time
local type = type

--Set the status of the response as a Miss.
--
---@package
---@param cache_key string The missed cache key of the response.
local function miss(cache_key)
  local ctx = kong.ctx.plugin

  ctx.cache_key = cache_key
  ctx.cache_status = const.CACHE_STATUS.MISS

  resp.set_headers({
    [const.HEADERS.CACHE_STATUS] = ctx.cache_status,
    [const.HEADERS.CACHE_KEY] = ctx.cache_key,
  })
end

--Set the status of the response as Bypass.
--
---@package
local function bypass()
  local ctx = kong.ctx.plugin

  ctx.cache_status = const.CACHE_STATUS.BYPASS
  ctx.cacheable = false

  set_header(const.HEADERS.CACHE_STATUS, ctx.cache_status)
end

---@param config table Remote Cache plugin configurations
function M.execute(config)
  ---@type Cache
  local c = cache:new(config)
  local cache_control = get_headers()['cache_control']
  local ctx = kong.ctx.plugin

  -- Validate against the plugin configurations this request match cache rules.
  if not c:config_allows_cache(config, 'request') then
    bypass()
    return
  end

  -- Check is request is cacheable.
  if cache_control then
    if type(cache_control) == 'table' then
      cache_control = concat(cache_control, ', ')
    end

    if http:no_cache(cache_control, 'request') then
      bypass()
      return
    end
  end

  -- We are cleared from cache control directives and plugin configurations rules
  -- disalowing cache.
  ctx.cache_key = c:cache_key()
  ctx.cacheable = true
  set_header(const.HEADERS.CACHE_KEY, ctx.cache_key)

  -- Now that we are sure we will need to perform a call to the remove cache
  -- we can initialize the remote provider.
  c:connect()
  -- Fetch from remote cache provider
  local payload = c:get(ctx.cache_key)

  -- respect only-if-cached cache control directive.
  if payload == nil then
    if cache_control and http:only_if_cached(cache_control) then
      miss(ctx.cache_key)

      return exit(const.STATUS_CODE.HTTP_GATEWAY_TIMEOUT)
    end
  end

  local response_cache = json:decode(payload) ---@diagnostic disable-line

  if not response_cache then
    miss(ctx.cache_key)
    return
  end

  if response_cache and http:stale(cache_control, response_cache.timestamp, response_cache.ttl) then
    miss(ctx.cache_key)
    return
  end

  -- we have a response cached, serve it
  ctx.cache_status = const.CACHE_STATUS.HIT

  -- Notify Kong that this response was produced by and upstream and not by a
  -- Kong plugin.
  ---@see https://github.com/Kong/kong/commit/acecd6a77fd66369954ffd033b884d7bde04aa12
  local nctx = ngx.ctx
  nctx.KONG_PROXIED = true

  set_header(const.HEADERS.CACHE_STATUS, ctx.cache_status)
  set_header(const.HEADERS.AGE, floor(time() - response_cache.timestamp))
  exit(const.STATUS_CODE.HTTP_OK, response_cache.body, response_cache.headers)
end

return M
