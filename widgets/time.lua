local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")

local timewidget ={}
timewidget.shortcuts = {}

local function worker(args)
	dbus.request_name("session", "org.naquadah.awesome.time")
	dbus.add_match("session", "interface='org.naquadah.awesome.time',member='saytime'")
	dbus.connect_signal("org.naquadah.awesome.time",
	function(...)
		local args = {...}
		--local method_name = args[2]
		--if method_name == "show_task" then
		--task:show_task(args[3],args[4])
		--end
		saytime()
	end
	)
	local timenotify = nil
	function saytime()
		awful.util.spawn_with_shell("/home/ivn/scripts/say_time.sh")
		time = os.date("%H:%M")
		time ='<span font="Cantarel 50">'..time.."</span>"
		naughty.destroy(timenotify)
		timenotify = naughty.notify({
			text = time,
			--icon = "/home/ivn/Загрузки/KFaenzafordark/apps/48/time-admin2.png",
			timeout = 2,
			screen = mouse.screen or 1
		})

	end
	dbus.request_name("session", "org.naquadah.awesome.say")
	dbus.add_match("session", "interface='org.naquadah.awesome.say',member='say'")
	dbus.connect_signal("org.naquadah.awesome.say",
	function(...)
		local args = {...}
		local method_name = args[2]
		if method_name == "say" then
			say(args[3])
		end
	end
	)
	function say(text)
		local lang ="ru"
		if string.match(text,"[a-zA-Z0-9,.!? ]*") ==text then
			lang ="en"
		end
		awful.util.spawn_with_shell("/home/ivn/scripts/saytext.sh  '"..lang.."' '"..text.."' fast >>/dev/null &")
	end

	mytextclockbuttons = awful.util.table.join(
	awful.button({ }, 2,saytime),
	awful.button({ }, 12,saytime)
	)

	mytextclock    = wibox.widget.textclock( lain.util.markup(widgets.clockgf, widgets.space3 .. "%H:%M" .. lain.util.markup.font("Tamsyn 3", " ")), 15)
	--mytextcalendar = awful.widget.textclock( lain.util.markup(widgets.clockgf, widgets.space3 .. "%a %d %b"))

	clockwidget = widgetcreator(
	{
		image = beautiful.widget_clock,
		textboxes = {mytextclock}
	})


	--calendarwidget = widgetcreator(
	--{ 
		--image = beautiful.widget_cal,
		--textboxes = {mytextcalendar}
	--})

	--print(type(clockwidget))
	--clockwidget:connect_signal("mouse::enter",function()print("mouse entered") end)
	lain.widget.calendar({
		attach_to = {clockwidget},
		notification_preset = {
			font = widgets.font,
			fg   = widgets.fg,
			bg   = widgets.bg
		}
	})
	--lain.widget.calendar.attach(clockwidget)
	--lain.widget.calendar:attach(calendarwidget, 
	--{ 
		--font_size = 13,
		--cal       = "/usr/bin/cal -m "
	--}
	--)
	--calendarwidget:buttons(mytextclockbuttons)
	clockwidget:buttons(mytextclockbuttons)

	return clockwidget
end

return setmetatable(timewidget, {__call = function(_,...) return worker(...) end})
