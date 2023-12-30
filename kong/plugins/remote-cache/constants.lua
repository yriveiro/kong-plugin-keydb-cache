---@class Constants
local M = {
  HEADERS = {
    CACHE_STATUS = 'x-rm-cache-status',
    CACHE_KEY = 'x-rm-cache-key',
    AGE = 'age',
  },

  STATUS_CODE = {
    HTTP_GATEWAY_TIMEOUT = ngx.HTTP_GATEWAY_TIMEOUT,
    HTTP_OK = ngx.HTTP_OK,
  },

  CACHE_STATUS = {
    HIT = 'Hit',
    MISS = 'Miss',
    BYPASS = 'Bypass',
  },
}

return M
