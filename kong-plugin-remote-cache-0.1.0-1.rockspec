---@diagnostic disable lowercase-global
local plugin_name = 'remote-cache'
local package_name = 'kong-plugin-' .. plugin_name
local package_version = '0.1.0'
local rockspec_revision = '1'
local package_import_prefix = 'kong.plugins.' .. plugin_name
local package_path_prefix = 'kong/plugins/' .. plugin_name

local github_account_name = 'yriveiro'
local github_repo_name = 'kong-plugin-remote-cache'
local git_checkout = package_version == 'dev' and 'main' or package_version

package = package_name
version = package_version .. '-' .. rockspec_revision
supported_platforms = { 'linux', 'macosx' }
source = {
  url = 'git+https://github.com/' .. github_account_name .. '/' .. github_repo_name .. '.git',
  branch = git_checkout,
}

description = {
  summary = 'Kong is a scalable and customizable API Management Layer built on top of Nginx.',
  homepage = 'https://' .. github_account_name .. '.github.io/' .. github_repo_name,
  license = 'Apache 2.0',
}

dependencies = {}

build = {
  type = 'builtin',
  modules = {
    [package_import_prefix .. '.cache'] = package_path_prefix .. '/cache.lua',
    [package_import_prefix .. '.constants'] = package_path_prefix .. '/constants.lua',
    [package_import_prefix .. '.handler'] = package_path_prefix .. '/handler.lua',
    [package_import_prefix .. '.phases/access'] = package_path_prefix .. '/phases/access.lua',
    [package_import_prefix .. '.phases/body_filter'] = package_path_prefix .. '/phases/body_filter.lua',
    [package_import_prefix .. '.phases/header_filter'] = package_path_prefix .. '/phases/header_filter.lua',
    [package_import_prefix .. '.providers'] = package_path_prefix .. '/providers/init.lua',
    [package_import_prefix .. '.providers.keydb'] = package_path_prefix .. '/providers/keydb.lua',
    [package_import_prefix .. '.schema'] = package_path_prefix .. '/schema.lua',
    [package_import_prefix .. '.utils.http'] = package_path_prefix .. '/utils/http/init.lua',
    [package_import_prefix .. '.utils.http.headers'] = package_path_prefix .. '/utils/http/headers.lua',
    [package_import_prefix .. '.utils.json'] = package_path_prefix .. '/utils/json.lua',
    [package_import_prefix .. '.utils.types.string'] = package_path_prefix .. '/utils/types/string.lua',
    [package_import_prefix .. '.utils.types.tbl'] = package_path_prefix .. '/utils/types/tbl.lua',
  },
}
