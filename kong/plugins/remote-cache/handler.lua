local access = require('kong.plugins.remote-cache.phases.access')
local body_filter = require('kong.plugins.remote-cache.phases.body_filter')
local header_filter = require('kong.plugins.remote-cache.phases.header_filter')

-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.

---@class RemoteCache
---@field private PRIORITY integer set the plugin priority, which determines plugin execution order
---@field private VERSION string version in X.Y.Z format. Check hybrid-mode compatibility requirements.
local RemoteCache = {
  PRIORITY = 1000,
  VERSION = '0.1',
}

-- runs in the 'access_by_lua_block'
--
---@param config PluginSchema
function RemoteCache:access(config)
  access.execute(config)
end

-- runs in the 'header_filter_by_lua_block'
--
---@param config PluginSchema
function RemoteCache:header_filter(config)
  header_filter.execute(config)
end

-- runs in the 'body_filter_by_lua_block'
--
---@param config PluginSchema
function RemoteCache:body_filter(config)
  body_filter.execute(config)
end

return RemoteCache
