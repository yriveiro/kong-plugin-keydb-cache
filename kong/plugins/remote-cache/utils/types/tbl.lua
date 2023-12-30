---@class TableUtil
local M = {}

-- Check if an element is a member of a given list.
-- This function allows to pass a custom compare function.
--
---@param tbl table
---@param element string
---@param cmp? function
---@return boolean
function M:member(tbl, element, cmp)
  local _cmp = cmp or function(e, v)
    return e == v
  end

  for _, v in ipairs(tbl) do
    if _cmp(element, v) then
      return true
    end
  end

  return false
end

-- Same purpose than table.insert but this one allows key instead of position.
--
---@param src any
---@param key string
---@param element any
function M:insert(src, key, element)
  src[key] = element
end

-- Returns a new table, recursively copied from the one given, retaining
-- metatable assignment.
--
---@see https://lua-users.org/wiki/CopyTable
---@param orig table
---@return table
function M:deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[M:deepcopy(orig_key)] = M:deepcopy(orig_value)
    end
    setmetatable(copy, M:deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

-- Merge the list of string in one.
--
---@vararg ... table<string>
---@return table<string>
function M:merge_string_list(...)
  local m = {}

  for _, tbl in ipairs({ ... }) do
    for _, v in ipairs(tbl) do
      if not M:member(m, v) then
        table.insert(m, v)
      end
    end
  end

  return m
end

-- Cycle an iterable indefinitely.
--
---@param iterable table<any>
---@return any
function M:cycle(iterable)
  local index = 0
  local length = #iterable

  return function()
    index = index + 1
    if index > length then
      index = 1
    end
    return iterable[index]
  end
end

return M
