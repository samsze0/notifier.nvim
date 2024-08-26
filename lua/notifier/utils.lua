local lang_utils = require("utils.lang")
local match = lang_utils.match

local M = {}

-- Convert log level to string
--
---@param level number
---@return string
function M.log_level_to_str(level)
  return match(level, {
    [vim.log.levels.ERROR] = "Error",
    [vim.log.levels.WARN] = "Warn",
    [vim.log.levels.INFO] = "Info",
    [vim.log.levels.DEBUG] = "Debug",
    [vim.log.levels.TRACE] = "Trace",
  }, "Unknown")
end

return M
