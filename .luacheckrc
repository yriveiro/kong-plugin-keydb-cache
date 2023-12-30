-- Configuration file for LuaCheck
-- see: https://luacheck.readthedocs.io/en/stable/
--
-- To run do: `luacheck .` from the repo

---@diagnostic disable lowercase-global
std = 'ngx_lua'
unused_args = false
redefined = false
max_line_length = false

globals = {
  '_KONG',
  'describe',
  'it',
  'kong',
  'lazy_each',
  'lazy_setup',
  'lazy_teardown',
  'ngx',
  'ngx.IS_CLI',
  'before_each',
  'after_each',
}

not_globals = {
  'string.len',
  'table.getn',
}

ignore = {
  '6.', -- ignore whitespace warnings
}

include_files = {
  '**/*.lua',
  '*.rockspec',
  '.busted',
  '.luacheckrc',
}

exclude_files = {
  --"spec/fixtures/invalid-module.lua",
  --"spec-old-api/fixtures/invalid-module.lua",
}

files['spec/**/*.lua'] = {
  std = 'ngx_lua+busted',
}
