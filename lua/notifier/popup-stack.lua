local NuiPopup = require("nui.popup")
local NuiEvent = require("nui.utils.autocmd").event
local opts_utils = require("utils.opts")
local oop_utils = require("utils.oop")
local tbl_utils = require("utils.table")
local NotificationPopup = require("notifier.popup")
local utils = require("notifier.utils")
local config = require("notifier.config").value

---@class NotificationPopupStack
---@field _popups NotificationPopup[]
local NotificationPopupStack = oop_utils.new_class()

---@class NotificationPopupStack.constructor.opts
---@field nui_popup_opts? nui_popup_options

---@param opts? NotificationPopupStack.constructor.opts
---@return NotificationPopupStack
function NotificationPopupStack.new(opts)
  opts = opts or {}

  error("Not implemented")

  local obj = {
    _popups = {},
  }
  setmetatable(obj, NotificationPopupStack)
  ---@cast obj NotificationPopupStack

  return obj
end

---@param notification Notification
function NotificationPopupStack:push(notification)
  local lines = vim.split(notification.message, "\n")
  local cols = tbl_utils.max(lines, {
    fn = function(_, line) return string.len(line) end,
  })

  local popup = NotificationPopup.new({
    nui_popup_opts = {
      size = {
        width = math.min(math.floor(vim.o.columns * 0.3), cols),
        height = math.min(math.floor(vim.o.lines * 0.8), #lines),
      },
    },
  })
  table.insert(self._popups, popup)

  popup.nui_popup:show()
  vim.wo[popup.nui_popup.winid].winhighlight = ("Normal:Notifier%s"):format(
    utils.log_level_to_str(notification.level)
  )

  local ok, err = popup.timer:start(
    config.duration[notification.level] or config.duration.default,
    0,
    vim.schedule_wrap(function() popup.nui_popup:hide() end)
  )
  assert(ok, err)
end

function NotificationPopupStack:clear()
  for _, popup in ipairs(self._popups) do
    popup.nui_popup:unmount()
  end
  self._popups = {}
end

return NotificationPopupStack
