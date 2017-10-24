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

	return widget
end

return setmetatable(calendarwidget, {__call = function(_,...) return worker(...) end})
