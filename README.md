# nvim-config

[![License](https://img.shields.io/github/license/nvim-contrib/nvim-config)](LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.9%2B-blueviolet?logo=neovim&logoColor=white)](https://neovim.io)

Opinionated [AstroNvim](https://astronvim.com) plugin configuration specs for the `nvim-contrib` org. These are [lazy.nvim](https://github.com/folke/lazy.nvim) import modules — not standalone plugins.

## Specs

| Module | Description |
|--------|-------------|
| `nvim-config.lang.nvim-go` | Go — [neotest](https://github.com/nvim-neotest/neotest) with [neotest-ginkgo](https://github.com/nvim-contrib/neotest-ginkgo) adapter and coverage integration |
| `nvim-config.lang.nvim-rust` | Rust — neotest with [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) adapter and `cargo-llvm-cov` coverage |
| `nvim-config.test.nvim-coverage` | [nvim-coverage](https://github.com/nvim-contrib/nvim-coverage) — signs, keymaps, neotest consumer |

## Installation

Import the specs you need in your AstroNvim `lazy_setup`:

```lua
require("lazy").setup({
  -- AstroNvim base
  { "AstroNvim/AstroNvim", import = "astronvim.plugins" },

  -- nvim-contrib config specs
  { import = "nvim-config.lang.nvim-go" },
  { import = "nvim-config.lang.nvim-rust" },
  { import = "nvim-config.test.nvim-coverage" },
})
```

The repo must be on your Lua `runtimepath` — either clone it into your Neovim config or add it as a lazy.nvim dev plugin:

```lua
{
  "nvim-contrib/nvim-config",
  import = "nvim-config.lang.nvim-go",
},
```

## License

[MIT](LICENSE)
