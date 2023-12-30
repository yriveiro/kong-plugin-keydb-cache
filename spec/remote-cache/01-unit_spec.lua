local PLUGIN_NAME = 'remote-cache'

-- helper function to validate data against a schema
local function v(config)
  local validate_entity = require('spec.helpers').validate_plugin_config_schema
  local schema = require('kong.plugins.' .. PLUGIN_NAME .. '.schema')
  return validate_entity(config, schema)
end

describe(PLUGIN_NAME .. ': (schema)', function()
  it('accepts a minimal config', function()
    local entity, err = v({
      provider = {
        backend = 'keydb',
        hosts = { 'keydb-01:443' },
      },
    })

    assert.is_nil(err) ---@diagnostic disable-line
    assert.is_truthy(entity) ---@diagnostic disable-line
  end)

  it('parses default config', function()
    local entity, err = v({
      debug = true,
      cache = {
        ttl = 100,
      },
      provider = {
        backend = 'keydb',
        hosts = { 'keydb-01', 'keydb-02' },
      },
    })

    -- require('pl.pretty').dump(entity)

    assert.is_nil(err) ---@diagnostic disable-line
    assert.is_truthy(entity) ---@diagnostic disable-line
  end)
end)
