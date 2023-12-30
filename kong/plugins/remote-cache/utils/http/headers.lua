local require = require

local tbl = require('kong.plugins.remote-cache.utils.types.tbl')

---@class HeadersUtils
---@field public hbh_headers table
local M = {}

local clone = table.clone
local concat = table.concat
local ipairs = ipairs
local tonumber = tonumber
local type = type

-- List of hop-by-hop headers
local hbh_headers = {
  'connection',
  'content-length',
  'keep-alive',
  'proxy-authenticate',
  'proxy-authorization',
  'proxy-connection',
  'te',
  'trailers',
  'transfer-encoding',
  'upgrade',
}

-- Check if the directive is present on the Request header.
--
---@param input string|table
---@param directive string
---@param bare? boolean directives without =value part like Public or Private directive
---@return boolean
function M:has_directive(input, directive, bare)
  if type(input) == 'table' then
    input = concat(input, ', ')
  end

  -- NOTE: for the guy from the future remember :)
  --
  -- [[ ... ]] > used to create long strings that can span multiple lines.
  -- (?: ... ) > non-capturing group. It groups the included patterns but does not capture the matched text for back-referencing.
  -- \s*       > matches any whitespace character whit zero or more occurrences.
  -- |         > alternation operator, old school OR operation.
  -- ,?        > match zero or more comma.
  -- (?:$|=|,) > non-capturing group that match the end of the line or the = sign.

  local pattern = [[(?:\s*|,?)(]] .. directive .. [[)\s*(?:$|=|,)]]

  bare = bare or false

  if bare then
    pattern = [[(?:\s*|,?)(]] .. directive .. [[)\s*(?:$|,)]]
  end

  return ngx.re.find(input, pattern, 'ioj') ~= nil
end

-- Get the value of a non bare directive.
--
---@param input string|table
---@param directive string
---@param numeric? boolean
---@return any|nil
function M:directive_value(input, directive, numeric)
  if M:has_directive(input, directive) then
    if type(input) == 'table' then
      input = concat(input, ', ')
    end

    local pattern = directive .. [[="?([a-z0-9_~!#%&/',`\$\*\+\-\|\^\.]+)"?]]

    numeric = numeric or false

    if numeric then
      pattern = directive .. [[="?(\d+)"?]]
    end

    local value = ngx.re.match(input, pattern, 'ioj')

    if value ~= nil then
      if numeric then
        return tonumber(value[1])
      end

      return value[1]
    end
  end

  return nil
end

-- Filter all hop by hop headers and all the headers pass in the custom list.
--
---@see https://datatracker.ietf.org/doc/html/rfc2616#page-92
---@see https://datatracker.ietf.org/doc/html/rfc9110#name-connection
--
---@param input table
---@param custom_filter_list? table<string>
---@return table
function M:filter_headers(input, custom_filter_list)
  local to_filter = tbl:merge_string_list(clone(hbh_headers), custom_filter_list or {})

  for _, h in ipairs(to_filter) do
    input[h] = nil
  end

  return input
end

return M
