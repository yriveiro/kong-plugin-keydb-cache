local headers = require('kong.plugins.remote-cache.utils.http.headers')

local debug = kong.log.debug
local get_headers = kong.response.get_headers
local max = math.max
local parse_http_time = ngx.parse_http_time
local time = ngx.time
local tostring = tostring
local type = type

---@class HTTTP
local M = {}

-- Check if cache control directives allows to cache the request.
--
---@param cache_control string Content of the cache-control header directive.
---@param message_type string
---@return boolean
function M:no_cache(cache_control, message_type)
  if cache_control then
    if headers:has_directive(cache_control, 'no-store|no-cache', true) then
      debug('bypass force by no-store|no-cache directive')
      return true
    end

    if message_type == 'response' then
      if headers:has_directive(cache_control, 'private|(must|proxy)-revalidate', true) then
        debug('bypass force by private|(must|proxy)-revalidate directive')
        return true
      end
    end

    local max_age = headers:directive_value(cache_control, 'max-age', true)

    if max_age ~= nil and max_age == 0 then
      debug('max-age is set to 0, revalidate')
      return true
    end
  end

  return false
end

-- Check if the client want the request only if comes from the cache.
--
---@param cache_control string Content of the cache-control header directive.
---@return boolean
function M:only_if_cached(cache_control)
  return headers:has_directive(cache_control, 'only-if-cached', true)
end

function M:stale(cache_control, age, ttl)
  if cache_control then
    if headers:has_directive(cache_control, 'max-age', true) then
      local max_age = headers:directive_value(cache_control, 'max-age', true)

      if max_age and (time() - age) > max_age then
        return true
      end
    end

    if headers:has_directive(cache_control, 'max-stale', true) then
      local max_stale = headers:directive_value(cache_control, 'max-stale', true)

      if max_stale and (time() - age - ttl) > max_stale then
        return true
      end
    end

    if headers:has_directive(cache_control, 'min-fresh', true) then
      local min_fresh = headers:directive_value(cache_control, 'min-fresh', true)

      if min_fresh and (time() - age) - ttl < min_fresh then
        return true
      end
    end
  end

  if ttl <= 0 then
    return true
  end

  return false
end

-- Retrieves the TTL for the response, it use the cache_control *max-age* and
-- *s-maxage* directives first. I none is present will try to fallback to the
-- *Expire* header, if multiple entries of *Expire* are pass, the last one wings.
--
---@param cache_control string Content of the cache-control header directive.
---@return integer ttl value in seconds.
function M:ttl(cache_control)
  local ttl = 0

  if cache_control then
    ttl = headers:directive_value(cache_control, 'max-age', true) or 0

    -- If s-maxage directive exits, overwrite max-age
    if headers:has_directive(cache_control, 's-maxage', true) then
      ttl = headers:directive_value(cache_control, 's-maxage', true)
    end
  end

  -- If not max age directive found, use expires header if exits.
  local expires = get_headers()['expires']

  if expires then
    -- Last expire from the table wins
    if type(expires) == 'table' then
      expires = expires[#expires]
    end

    local timestamp = parse_http_time(tostring(expires))

    if timestamp then
      ttl = timestamp - time()
    end
  end

  return max(ttl, 0)
end

return M
