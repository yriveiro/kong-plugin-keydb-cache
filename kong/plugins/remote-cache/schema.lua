local typedefs = require('kong.db.schema.typedefs')

local PLUGIN_NAME = 'remote-cache'

---@class PluginSchema
---@field public name string Name of Kong plugin.
local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer }, -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    {
      config = {
        -- The 'config' record is the custom part of the plugin schema
        type = 'record',
        fields = {
          {
            debug = {
              description = 'Enable debug mode.',
              default = false,
              type = 'boolean',
            },
          },
          {
            cache = {
              description = 'Configurations to define the behavior of the plugin.',
              type = 'record',
              fields = {
                {
                  methods = {
                    description = 'List of methods the remote cache will take in consideration to cache.',
                    default = { 'GET' },
                    elements = typedefs.http_method,
                    type = 'array',
                  },
                },
                {
                  status = {
                    description = 'List of status codes the remote cache will take in consideration to cache.',
                    default = { 200, 301, 404 },
                    elements = { type = 'integer', between = { 100, 900 } },
                    type = 'array',
                  },
                },
                {
                  ttl = {
                    description = 'If no cache control directive is set, the max time in seconds before the entry is garbage collected.',
                    default = 30,
                    type = 'integer',
                  },
                },
                {
                  strategy = {
                    description = 'Cache strategy, valid values are `cache-control` or `custom`.',
                    type = 'string',
                    default = 'cache-control',
                    one_of = {
                      'cache-control',
                      'custom',
                    },
                  },
                },
                {
                  cache_key = {
                    description = 'Configurations that will modify the cache key generated.',
                    type = 'record',
                    fields = {
                      {
                        vary_headers = {
                          elements = typedefs.header_name,
                          required = false,
                          type = 'array',
                        },
                      },
                      {
                        vary_query_params = {
                          elements = { type = 'string' },
                          required = false,
                          type = 'array',
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          {
            provider = {
              description = 'Remote Cache backend.',
              type = 'record',
              fields = {
                {
                  backend = {
                    description = 'Backend provider.',
                    default = 'keydb',
                    required = true,
                    type = 'string',
                    one_of = {
                      'keydb',
                    },
                  },
                },
                {
                  hosts = {
                    description = 'List of host for the defined provider.',
                    elements = typedefs.host_with_optional_port,
                    len_min = 1,
                    required = true,
                    type = 'array',
                  },
                },
              },
            },
          },
        },
        entity_checks = {},
      },
    },
  },
}

return schema
