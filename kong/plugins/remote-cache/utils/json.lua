local cjson = require('cjson.safe')

---@class JSONUtil

local M = {}

-- JSON encode object with cjson.safe implementation
--
---@param payload any
---@return string|nil, string|nil
function M:encode(payload)
  if not payload then
    return nil, "encode not possible, 'payload' object is nil"
  end

  local data, err = cjson.encode(payload)
  if not data then
    return nil, err
  end

  return data
end

-- JSON decode string with cjson.safe implementation
--
---@param payload string
---@return table|nil, table|nil
function M:decode(payload)
  local body, err = cjson.decode(payload)

  if not body then
    return nil, err
  end

  return body
end

return M
