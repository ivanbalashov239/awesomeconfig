local naughty    = require("notifybar.naughty")
local wibox      = require("wibox")
local bar = wibox.layout.fixed.horizontal()
local oldnotify = naughty.notify
local olddestroy = naughty.destroy
local function notify(args)
	local item = oldnotify(args)
	if bar then
		bar:add(item.layout)
	end
	print("added ")
	return item
end
local function destroy(notification)
	local result = olddestroy(notification)
	if result then
	end
	return result
end
naughty.notify = notify
naughty.bar = bar
--naughty.destroy = destroy

return naughty
