local NuiPopup = require("nui.popup")
local NuiEvent = require("nui.utils.autocmd").event
local opts_utils = require("utils.opts")
local oop_utils = require("utils.oop")
local NotificationPopup = require("notifier.popup")

-- vim.schedule(function()
--   local lines = vim.split(msg, "\n")
--   local cols = tbl_utils.max(lines, {
--     fn = function(_, line) return string.len(line) end,
--   })
--   vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

--   popup:update_layout({
--     size = {
--       width = math.min(math.floor(vim.o.columns * 0.3), cols),
--       height = math.min(math.floor(vim.o.lines * 0.8), #lines),
--     },
--   })
--   popup:show()

--   vim.wo[popup.winid].winhighlight = ("Normal:Notifier%s"):format(
--     utils.log_level_to_str(level)
--   )

--   if timer:is_active() then
--     local ok, err = timer:stop()
--     assert(ok, err)
--   end
--   local ok, err = timer:start(
--     config.duration[level] or config.duration.default,
--     0,
--     vim.schedule_wrap(function() popup:hide() end)
--   )
--   assert(ok, err)
-- end)

---@class NotificationPopupStack
---@field _popups NotificationPopup[]
local NotificationPopupStack = oop_utils.new_class()

---@class NotificationPopupStack.constructor.opts
---@field nui_popup_opts? nui_popup_options

---@param opts NotificationPopupStack.constructor.opts
---@return NotificationPopupStack
function NotificationPopupStack.new(opts)
  opts = opts or {}

  local obj = {
    _popups = {},
  }
  setmetatable(obj, NotificationPopupStack)
  ---@cast obj NotificationPopupStack

  return obj
end

---@param notification Notification
function NotificationPopupStack:push(notification)
  local popup = NotificationPopup.new({})
  table.insert(self._popups, popup)
end

function NotificationPopupStack:clear() self._popups = {} end

function NotificationPopupStack:_render()
  for _, popup in ipairs(self._popups) do
    -- TODO
  end
end

return NotificationPopupStack
