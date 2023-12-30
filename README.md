<!--toc:start-->

- [Kong plugin template](#kong-plugin-template)
- [Naming and versioning conventions](#naming-and-versioning-conventions)
  - [Example](#example)
  <!--toc:end-->

[![Unix build](https://img.shields.io/github/actions/workflow/status/Kong/kong-plugin/test.yml?branch=master&label=Test&logo=linux)](https://github.com/Kong/kong-plugin/actions/workflows/test.yml)
[![Luacheck](https://github.com/Kong/kong-plugin/workflows/Lint/badge.svg)](https://github.com/Kong/kong-plugin/actions/workflows/lint.yml)

# Kong plugin template

This repository contains a very simple Kong plugin template to get you
up and running quickly for developing your own plugins.

This template was designed to work with the
[`kong-pongo`](https://github.com/Kong/kong-pongo) and
[`kong-vagrant`](https://github.com/Kong/kong-vagrant) development environments.

Please check out those repos `README` files for usage instructions. For a complete
walkthrough check [this blogpost on the Kong website](https://konghq.com/blog/custom-lua-plugin-kong-gateway).

# Naming and versioning conventions

There are a number "named" components and related versions. These are the conventions:

- _Kong plugin name_: This is the name of the plugin as it is shown in the Kong
  Manager GUI, and the name used in the file system. A plugin named `my-cool-plugin`
  would have a `handler.lua` file at `./kong/plugins/my-cool-plugin/handler.lua`.

- _Kong plugin version_: This is the version of the plugin code, expressed in
  `x.y.z` format (using Semantic Versioning is recommended). This version should
  be set in the `handler.lua` file as the `VERSION` property on the plugin table.

- _LuaRocks package name_: This is the name used in the LuaRocks eco system.
  By convention this is `kong-plugin-[KongPluginName]`. This name is used
  for the `rockspec` file, both in the filename as well as in the contents
  (LuaRocks requires that they match).

- _LuaRocks package version_: This is the version of the package, and by convention
  it should be identical to the _Kong plugin version_. As with the _LuaRocks package
  name_ the version is used in the `rockspec` file, both in the filename as well
  as in the contents (LuaRocks requires that they match).

- _LuaRocks rockspec revision_: This is the revision of the rockspec, and it only
  changes if the rockspec is updated. So when the source code remains the same,
  but build instructions change for example. When there is a new _LuaRocks package
  version_ the _LuaRocks rockspec revision_ is reset to `1`. As with the _LuaRocks
  package name_ the revision is used in the `rockspec` file, both in the filename
  as well as in the contents (LuaRocks requires that they match).

- _LuaRocks rockspec name_: this is the filename of the rockspec. This is the file
  that contains the meta-data and build instructions for the LuaRocks package.
  The filename is `[package name]-[package version]-[package revision].rockspec`.

## Example

- _Kong plugin name_: `my-cool-plugin`

- _Kong plugin version_: `1.4.2` (set in the `VERSION` field inside `handler.lua`)

This results in:

- _LuaRocks package name_: `kong-plugin-my-cool-plugin`

- _LuaRocks package version_: `1.4.2`

- _LuaRocks rockspec revision_: `1`

- _rockspec file_: `kong-plugin-my-cool-plugin-1.4.2-1.rockspec`

- File _`handler.lua`_ is located at: `./kong/plugins/my-cool-plugin/handler.lua` (and similar for the other plugin files)
