# notifier.nvim

A neovim plugin that provides an implementation for `vim.notify`

## Usage

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "samsze0/notifier.nvim",
    config = function()
        require("notifier").setup({})
    end,
    dependencies = {
        "samsze0/utils.nvim"
    }
}
```

```lua
vim.info("Some string")
vim.warn("Some list", { 1, 2, 3 })
vim.error("Some table", { first = 1, second = 2, third = 3})

local notifier = require("notifier")

print(vim.inspect(notifier.all())) -- Print all notifications
-- Or
vim.info(notifier.all())
```

```lua
```

## License

MIT