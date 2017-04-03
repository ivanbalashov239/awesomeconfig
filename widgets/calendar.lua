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
	local mytextcalendar = wibox.widget.textclock( lain.util.markup(widgets.clockgf, widgets.space3 .. "%a %d %b"))

	local calendarwidget = widgetcreator(
	{ 
		image = beautiful.widget_cal,
		textboxes = {mytextcalendar}
	})

	--lain.widget.calendar({
		--attach_to = {calendarwidget},
		--notification_preset = {
			--font = widgets.font,
			--fg   = widgets.fg,
			--bg   = widgets.bg
		--}
	--})
	lain.widget.calendar.attach(calendarwidget)

	return calendarwidget
end

return setmetatable(calendarwidget, {__call = function(_,...) return worker(...) end})
