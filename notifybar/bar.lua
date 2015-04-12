local wibox      = require("wibox")
local beautiful  = require("beautiful")
local stack = {}
local layout = wibox.layout.fixed.vertical()

local bar = {}
function bar:add(item)
	stack = table.insert(stack, item)
	layout:add(item)
end

return bar.layout
