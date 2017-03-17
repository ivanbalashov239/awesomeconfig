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
	local mytextcalendar = awful.widget.textclock( lain.util.markup(widgets.clockgf, widgets.space3 .. "%a %d %b"))

	local calendarwidget = widgetcreator(
	{ 
		image = beautiful.widget_cal,
		textboxes = {mytextcalendar}
	})

	lain.widgets.calendar:attach(calendarwidget, 
	{ 
		font_size = 13,
		cal       = "/usr/bin/cal -m "
	}
	)

	return calendarwidget
end

return setmetatable(calendarwidget, {__call = function(_,...) return worker(...) end})
