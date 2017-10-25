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


	local mytextclock    = wibox.widget.textclock( lain.util.markup(widgets.clockgf, widgets.set_markup(nil,"%H:%M")), 15)

	local clockwidget = widgetcreator(
		{
			image = beautiful.widget_clock,
			textboxes = {mytextclock}
		})

	widgets.task:attach_calendar(clockwidget,{
			--cal = "/bin/bash -c 'stty rows 100 cols 40; /bin/task calendar'",
			--attach_to = {clockwidget,widgets.calendar.widget},
			notification_preset = {
				font = "Terminus bold 20",
				fg   = widgets.fg,
				bg   = widgets.bg
			}
		})
	local mytextclockbuttons = awful.util.table.join(clockwidget:buttons(),
		awful.button({ }, 2,saytime),
		awful.button({ }, 12,saytime)
		)
	clockwidget:buttons(mytextclockbuttons)

	return clockwidget
end

return setmetatable(timewidget, {__call = function(_,...) return worker(...) end})
