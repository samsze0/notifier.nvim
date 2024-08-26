---@alias NotifierOptions { popup_options?: nui_popup_options, duration?: { default: number, [number]: number } }

---@type NotifierOptions
local default_config = {
  duration = {
    default = 3000,
    [vim.log.levels.ERROR] = 5000,
  },
}

return {
  value = default_config,
}
