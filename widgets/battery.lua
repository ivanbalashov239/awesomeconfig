local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")

local batterywidget ={}
batterywidget.shortcuts = {}

local function worker(args)
	local baticon = wibox.widget.imagebox(beautiful.widget_battery)
	local batwidget = lain.widgets.bat({
		battery = "BAT1",
		settings = function()
			if bat_now.status == "Charging" then
				baticon:set_image(beautiful.widget_ac)
			elseif bat_now.perc == "N/A" then
				widget:set_markup("AC")
				baticon:set_image(beautiful.widget_ac)
				return
			elseif tonumber(bat_now.perc) <= 5 then
				baticon:set_image(beautiful.widget_battery_empty)
			elseif tonumber(bat_now.perc) <= 15 then
				baticon:set_image(beautiful.widget_battery_low)
			else
				baticon:set_image(beautiful.widget_battery)
			end
			widget:set_markup(" " .. bat_now.perc .. "% ")
		end
	})
	local batterywidget = widgetcreator(
	{
		widgets = {baticon},
		textboxes = {batwidget}
	})
	local function battery_time_grabber()
		f = io.popen("acpi -b | awk '{print $5}' | awk -F \":\" '{print $1\":\"$2 }'")
		str = f:read()
		f.close()
		if str then
			return str.." remaining"
		else
			return "no battery"
		end
	end
	local battery_notify = nil
	function batwidget:hide()
		if battery_notify ~= nil then
			naughty.destroy(battery_notify)
			battery_notify = nil
		end
	end
	function batwidget:show(t_out)
		batwidget:hide()
		battery_notify = naughty.notify({
			preset = fs_notification_preset,
			text = battery_time_grabber(),
			timeout = t_out,
			screen = mouse.screen
		})
	end
	batterywidget:connect_signal('mouse::enter', function () batwidget:show(0) end)
	batterywidget:connect_signal('mouse::leave', function () batwidget:hide()  end)
	return batterywidget
end

return setmetatable(batterywidget, {__call = function(_,...) return worker(...) end})
