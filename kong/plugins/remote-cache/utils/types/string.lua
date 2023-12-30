---@class StringUtil
local M = {}

-- Splits a given string into substrings based on a specified delimiter.
--
---@param input string
---@param delimiter string
---@return table
function M:split(input, delimiter)
  local out = {}
  local pos, endpos
  local prev, idx = 0, 0

  repeat
    -- stylua: ignore
    pos, endpos = string.find(input, delimiter, prev, true)

    idx = idx + 1

    if pos then
      out[idx] = string.sub(input, prev, pos - 1)
    else
      if prev <= #input then
        out[idx] = string.sub(input, prev, -1)
      end

      break
    end

    prev = endpos + 1
  until pos == nil

  return out
end

return M
