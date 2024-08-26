local NuiPopup = require("nui.popup")
local NuiEvent = require("nui.utils.autocmd").event
local opts_utils = require("utils.opts")
local oop_utils = require("utils.oop")

---@type nui_popup_options
local base_popup_options = {
  enter = false,
  focusable = true,
  border = {
    style = "none",
    -- vertical, horizontal padding
    padding = { 0, 0 },
  },
  anchor = "NE",
  relative = "editor",
  zindex = 100,
  buf_options = {
    filetype = "notifier",
  },
  win_options = {
    winblend = 0,
    winhighlight = "Normal:NormalFloat",
    wrap = true,
  },
  -- position = {
  --   row = 2,
  --   col = vim.o.columns - 2,
  -- },
  -- size = {
  --   width = 1,
  --   height = 1,
  -- },
}

---@class NotificationPopup
---@field nui_popup NuiPopup
---@field timer uv.uv_timer_t
local NotificationPopup = oop_utils.new_class()

---@class NotificationPopup.constructor.opts
---@field nui_popup_opts? nui_popup_options

---@param opts NotificationPopup.constructor.opts
---@return NotificationPopup
function NotificationPopup.new(opts)
  opts = opts or {}

  local nui_popup =
    NuiPopup(opts_utils.deep_extend(base_popup_options, opts.nui_popup_opts))

  local timer = vim.uv.new_timer()
  assert(timer, err)

  local obj = {
    nui_popup = nui_popup,
    timer = timer,
  }
  setmetatable(obj, NotificationPopup)
  ---@cast obj NotificationPopup

  return obj
end

return NotificationPopup
