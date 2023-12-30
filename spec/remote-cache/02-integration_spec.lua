local helpers = require('spec.helpers')

local PLUGIN_NAME = 'remote-cache'

for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ': (access) [#' .. strategy .. ']', function()
    local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })
    local prefix = '/tmp'
    local client
    --
    lazy_setup(function()
      local service = bp.services:insert({
        name = 'echo-service',
        host = 'httpbin.org',
      })

      bp.routes:insert({
        hosts = { 'httpbin.org' },
        paths = { '/test' },
        service = { id = service.id },
      })

      bp.plugins:insert({
        name = PLUGIN_NAME,
        service = { id = service.id },
        config = {
          debug = true,
          cache = {
            ttl = 100,
          },
          provider = {
            backend = 'keydb',
            hosts = { 'keydb-01', 'keydb-02' },
          },
        },
      })

      -- start kong
      assert(helpers.start_kong({
        prefix = prefix,
        database = strategy,
        plugins = 'bundled,' .. PLUGIN_NAME,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(prefix, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then
        client:close()
      end
    end)

    describe('default route', function()
      it('/', function()
        local r = client:get('/test', {
          headers = {
            host = 'httpbin.org',
          },
        })

        require('pl.pretty').dump(r)
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the header
        -- local header_value = assert.request(r).has.header('hello-world')
        -- validate the value of that header
        -- assert.equal('this is on a request', header_value)
      end)
    end)
  end)
end
