---@meta This file is here to ensure intellisente pick Kong clases.
---@
local ngx = ngx
assert(ngx.get_phase() == 'timer', 'This must never be loaded by kong, this is just for development experience!')

local ctx = require('kong.pdk.ctx')
local ip = require('kong.pdk.ip')
local log = require('kong.pdk.log')
local nginx = require('kong.pdk.nginx')
local node = require('kong.pdk.node')
local plugin = require('kong.pdk.plugin')
local req = require('kong.pdk.request')
local resp = require('kong.pdk.response')
local router = require('kong.pdk.router')
local service = require('kong.pdk.service')
local service_request = require('kong.pdk.service.request')
local service_response = require('kong.pdk.service.response')
local spec = require('kong.spec.helpers')
local tracing = require('kong.pdk.tracing')
local typedefs = require('kong.db.schema.typedefs')
local utils = require('kong.tools.utils')
local vault = require('kong.pdk.vault')

local kong = {}

kong.ctx = ctx.new()
kong.db.schema.typedefs = typedefs.new()
kong.ip = ip.new()
kong.log = log.new()
kong.nginx = nginx.new()
kong.node = node.new()
kong.plugin = plugin.new()
kong.request = req.new()
kong.response = resp.new()
kong.router = router.new()
kong.service = service.new()
kong.service.request = service_request.new()
kong.service.response = service_response.new()
kong.spec.helpers = spec
kong.table = table
kong.tools.utils = utils
kong.tracing = tracing.new()
kong.vault = vault.new()

_G.kong = kong

return kong
