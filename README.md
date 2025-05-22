# mason-registry-lock

A Neovim plugin that provides deterministic package installation for Mason by locking the mason-registry to a specific release.

## Why?

Mason fetches packages from the latest mason-registry, which can lead to:

- Non-deterministic builds across different environments
- Breaking changes when new registry versions are released
- Difficulty reproducing issues in specific environments

This plugin solves these problems by allowing you to lock mason-registry to a specific release, similar to how package managers like npm use lockfiles.

## How it works

The plugin overrides Mason's default registry source to use a specific tagged release from the mason-registry repository. Each commit in this repository corresponds to a specific mason-registry release, allowing your package manager (like lazy.nvim) to pin the exact version.

## Installation

### With lazy.nvim

```lua
{
  'williamboman/mason.nvim',
  config = true,
  dependencies = {
    { 'kahlstrm/mason-registry-lock' },
  },
  opts = function()
    local registry_lock = require 'mason-registry-lock'
    return {
      registries = {
        registry_lock.registry_release,
      },
    }
  end,
}
```

### With other package managers

For other package managers, ensure you:

1. Install this plugin and pin it to a specific commit
2. Configure Mason to use the locked registry:

```lua
require("mason").setup({
  registries = {
    require("mason-registry-lock").registry_release,
  },
})
```

## Auto update with `mason-tool-installer`

If you are using [`mason-tool-installer`](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim),
you can enable `auto_update`:

```lua
      -- include all tools/LSPs in this ensure_installed, other plugins such as mason-lspconfig don't support `auto_update`
      require('mason-tool-installer').setup { ensure_installed = ensure_installed, auto_update = true }
```

This way after updating package manager lock file, Mason will update all plugins to match the new registry version.

