local widgetcreator = require("widgets")
local widgets = widgetcreator
local utils = require("utils")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
local rork = require("rork")      
local run_or_raise = rork.run_or_raise
local run_or_kill = rork.run_or_kill

local cpu_tmpwidget ={}
cpu_tmpwidget.shortcuts = {}

local function worker(args)
	local args = args or {}
	local tempfile = args.tempfile or "/sys/class/hwmon/hwmon2/temp2_input"

	local cpu_widget = lain.widget.cpu({
		settings = function()
			--widget:set_markup(widgets.space3 .. cpu_now.usage .. "%" .. lain.util.markup.font("Tamsyn 4", " "))
			widgets.set_markup(widget,utils.to_n(cpu_now.usage .. "%",4))
		end
	})

	local cpubuttons = awful.util.table.join(awful.button({ }, 1,
	function () run_or_kill(htop_cpu, { role = "HTOP_CPU" }, {x = mouse.coords().x, y = mouse.coords().y+2}) end))

	local tmp_widget = lain.widget.temp({
		tempfile = tempfile,
		settings = function()
			--widget:set_markup(widgets.space3 .. coretemp_now .. "°C" .. lain.util.markup.font("Tamsyn 4", " "))
			widgets.set_markup(widget,utils.to_n(coretemp_now .. "°C",6))
		end
	})

	local cpuwidget = widgetcreator(
	{
		--image = beautiful.widget_mem,
		text = "CPU",
		textboxes = {cpu_widget.widget, tmp_widget.widget}
	})

	cpuwidget:buttons(cpubuttons)
	return cpuwidget
end
function cpu_tmpwidget.menu()
end

return setmetatable(cpu_tmpwidget, {__call = function(_,...) return worker(...) end})
