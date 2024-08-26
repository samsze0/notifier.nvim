local lang_utils = require("utils.lang")
local tbl_utils = require("utils.table")
local opts_utils = require("utils.opts")
local str_utils = require("utils.string")
local utils = require("notifier.utils")
local NotificationPopupStack = require("notifier.popup-stack")
local config = require("notifier.config")

local popup_stack = NotificationPopupStack.new()

local M = {}

---@alias Notification { message: string, level: number, time: number }
---@type Notification[]
local notifications = {}

---@alias NotificationSubscriber fun(noti?: Notification)
---@type NotificationSubscriber[]
local subscribers = {}

-- Subscribe to notifications
--
---@param callback NotificationSubscriber
M.subscribe = function(callback) table.insert(subscribers, callback) end

---@return Notification[]
M.all = function() return notifications end

---@return Notification?
M.latest = function() return notifications[1] end

-- Clear all notifications
M.clear = function() notifications = {} end

---@param opts? NotifierOptions
function M.setup(opts)
  config.value = opts_utils.deep_extend(config.value, opts)
  ---@cast config NotifierOptions

  vim.error = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.ERROR) end
  vim.warn = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.WARN) end
  vim.info = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.INFO) end
  vim.debug = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.DEBUG) end
  vim.trace = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.TRACE) end

  vim.notify = function(msg, level) ---@diagnostic disable-line: duplicate-set-field
    level = level or vim.log.levels.OFF

    local t = type(msg)
    if t == "nil" then
      msg = "nil"
    elseif t ~= "string" then
      msg = vim.inspect(msg)
    end

    local t = os.time()
    local n = {
      message = msg,
      level = level,
      time = t,
    }
    table.insert(notifications, 1, n)

    popup_stack:push(n)

    for _, sub in ipairs(subscribers) do
      vim.schedule(function() sub(n) end)
    end
  end
end

return M
