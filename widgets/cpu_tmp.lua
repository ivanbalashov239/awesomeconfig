local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")

local cpu_tmpwidget ={}
cpu_tmpwidget.shortcuts = {}

local function worker(args)

	local cpu_widget = lain.widgets.cpu({
		settings = function()
			widget:set_markup(widgets.space3 .. cpu_now.usage .. "%" .. lain.util.markup.font("Tamsyn 4", " "))
		end
	})

	local cpubuttons = awful.util.table.join(awful.button({ }, 1,
	function () run_or_kill(htop_cpu, { role = "HTOP_CPU" }, {x = mouse.coords().x, y = mouse.coords().y+2}) end))

	local tmp_widget = lain.widgets.temp({
		tempfile = "/sys/class/hwmon/hwmon2/temp2_input",
		settings = function()
			widget:set_markup(widgets.space3 .. coretemp_now .. "°C" .. lain.util.markup.font("Tamsyn 4", " "))
		end
	})

	local cpuwidget = widgetcreator(
	{
		--image = beautiful.widget_mem,
		text = "CPU",
		textboxes = {cpu_widget, tmp_widget}
	})

	cpuwidget:buttons(cpubuttons)
	return cpuwidget
end

return setmetatable(cpu_tmpwidget, {__call = function(_,...) return worker(...) end})
