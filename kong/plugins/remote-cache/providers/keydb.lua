-- KeyDB is a drop-in replacement for Redis, we can use the same driver to
-- talk with the server.
local require = require

local redis = require('resty.redis')

---@class KeyDB
local M = {}

local kerr = kong.log.err

---@class KeyDB
---@param o table|nil
function M:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:setup(_)
  local srv, err = redis:new()

  if not srv then
    kerr('failed to instantiate keydb:', err)
    return nil
  end

  srv:set_timeouts(1000, 1000, 1000) -- 1 sec

  self.srv = srv

  return true
end

-- Connect to keydb server
--
function M:connect()
  local conn, err = self.srv:connect('keydb-01', 6379)

  if not conn then
    kerr('failed to open connection with KeyDB server ' .. err)
    return false
  end

  self.conn = conn

  return true
end

function M:close(...)
  local ok, err = self.srv:set_keepalive(...)

  if not ok then
    kerr('error closing connection: ' .. err)
    return false
  end

  return true
end

-- Set a key value in a remote cache.
--
---@param key string
---@param payload table
---@param ttl? integer
---@return boolean
function M:set(key, payload, ttl)
  ttl = ttl or 0

  local ok, err

  ok = self:connect()

  if not ok then
    return false
  end

  ok = self.srv:set(key, payload)

  if not ok then
    kerr('failed to set cache on KeyDB server ' .. err)
    return false
  end

  self.srv:expire(key, ttl)

  self:close()

  return true
end

function M:get(key)
  local res, ok, err

  ok, err = self:connect()

  if not ok then
    return nil, err
  end

  res, err = self.srv:get(key)

  if not res then
    kerr('failed to get key from cache: ' .. err)
    return nil
  end

  self:close()

  if res == kong.null then
    return nil
  end

  return res
end

return M
