local lang_utils = require("utils.lang")
local tbl_utils = require("utils.table")
local opts_utils = require("utils.opts")
local str_utils = require("utils.string")
local NuiPopup = require("nui.popup")

local popup_options = {
  enter = false,
  focusable = true,
  border = {
    style = "none",
    -- vertical, horizontal padding
    padding = { 0, 0 },
  },
  anchor = "NE",
  position = {
    row = 2,
    col = vim.o.columns - 2,
  },
  relative = "editor",
  size = {
    width = 1,
    height = 1,
  },
  zindex = 100,
  buf_options = {
    filetype = "notifier",
  },
  win_options = {
    winblend = 0,
    winhighlight = "Normal:NormalFloat",
    wrap = true,
  },
}

---@type NuiPopup
local popup = nil

local config = {
  popup_options = popup_options,
  duration = {
    default = 3000,
    [vim.log.levels.ERROR] = 5000,
  },
}

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

-- Convert log level to string
--
---@param level number
---@return string
local function log_level_to_str(level)
  return lang_utils.match(level, {
    [vim.log.levels.ERROR] = "Error",
    [vim.log.levels.WARN] = "Warn",
    [vim.log.levels.INFO] = "Info",
    [vim.log.levels.DEBUG] = "Debug",
    [vim.log.levels.TRACE] = "Trace",
  }, "Unknown")
end

---@type uv.uv_timer_t
local timer = nil

vim.notify = function(msg, level) ---@diagnostic disable-line: duplicate-set-field
  if popup == nil or timer == nil then
    error("Notifier is not set up. Call setup() first.")
  end

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

  vim.schedule(function()
    local lines = vim.split(msg, "\n")
    local cols = tbl_utils.max(lines, {
      fn = function(_, line) return string.len(line) end,
    })
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

    popup:update_layout({
      size = {
        width = math.min(math.floor(vim.o.columns * 0.3), cols),
        height = math.min(math.floor(vim.o.lines * 0.8), #lines),
      },
    })
    popup:show()

    vim.wo[popup.winid].winhighlight = ("Normal:Notifier%s"):format(
      log_level_to_str(level)
    )

    if timer:is_active() then
      local ok, err = timer:stop()
      assert(ok, err)
    end
    local ok, err = timer:start(
      config.duration[level] or config.duration.default,
      0,
      vim.schedule_wrap(function() popup:hide() end)
    )
    assert(ok, err)
  end)

  for _, sub in ipairs(subscribers) do
    vim.schedule(function() sub(n) end)
  end
end

---@alias NotifierOptions { popup_options?: nui_popup_options, duration?: { default: number, [number]: number } }
---@param opts? NotifierOptions
function M.setup(opts)
  config = opts_utils.deep_extend(config, opts)
  ---@cast config NotifierOptions

  popup = NuiPopup(config.popup_options)
  popup:mount()
  popup:hide()

  local _timer, err = vim.uv.new_timer()
  assert(_timer, err)
  timer = _timer

  vim.error = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.ERROR) end
  vim.warn = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.WARN) end
  vim.info = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.INFO) end
  vim.debug = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.DEBUG) end
  vim.trace = function(...) vim.notify(str_utils.fmt(...), vim.log.levels.TRACE) end
end

return M
