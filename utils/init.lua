--local beautiful = require("beautiful")
--local wibox = require("wibox")
local lain = require("lain")
local wrequire     = require("lain.helpers").wrequire
local setmetatable = setmetatable
local utils = { _NAME = "utils" }

local function worker(args)
end

return setmetatable(utils, {__index = wrequire, __call = function(_,...) return worker(...) end})
