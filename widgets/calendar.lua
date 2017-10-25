local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")

local calendarwidget ={}
calendarwidget.shortcuts = {}

local function worker(args)
	local mytextcalendar = wibox.widget.textclock( lain.util.markup(widgets.clockgf, widgets.set_markup(nil,"%a %d %b")))

	local widget = widgetcreator(
	{ 
		image = beautiful.widget_cal,
		textboxes = {mytextcalendar}
	})
	calendarwidget.widget = widget
	widgets.task:attach_calendar(widget,{
			--cal = "/bin/bash -c 'stty rows 100 cols 40; /bin/task calendar'",
			--attach_to = {clockwidget,widgets.calendar.widget},
			notification_preset = {
				font = "Terminus bold 20",
				fg   = widgets.fg,
				bg   = widgets.bg
			}
		})

	return widget
end

return setmetatable(calendarwidget, {__call = function(_,...) return worker(...) end})
