local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")

local kbddwidget ={}
kbddwidget.shortcuts = {}
function kbddwidget.set_ru()
	local command = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.set_layout uint32:1"
	--print("ALT_L")
	os.execute(command)
end
function kbddwidget.set_en()
	local command = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.set_layout uint32:0"
	--print("ALTGR")
	os.execute(command)
end

local function worker(args)
	local kbddnotify = nil
	local kbdstrings = 
	{
		[0] = "EN",
		[1] = "RU" 
	}
	local kbdtext = wibox.widget.textbox(kbdstrings[0])
	dbus.request_name("session", "ru.gentoo.kbdd")
	dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
	dbus.connect_signal("ru.gentoo.kbdd", function(...)
		local data = {...}
		local layout = data[2]
		kbdtext:set_markup(kbdstrings[layout])
		local text ='<span font="Cantarel 50">'..kbdstrings[layout].."</span>"
		naughty.destroy(kbddnotify)
		kbddnotify = naughty.notify({
			text = text,
			--icon = "/home/ivn/Загрузки/KFaenzafordark/apps/48/time-admin2.png",
			timeout = 2,
			screen = mouse.screen or 2,
			position = "bottom_right",
		})
	end
	)
	--local kbdtext = awful.widget.keyboardlayout()
	local switch_kbd_layout ="dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.prev_layout"

	local kbdwidget = widgetcreator(
	{
		textboxes = {kbdtext}
	})
	kbdwidget:buttons(awful.util.table.join(
	--awful.button({ }, 12, function () run_once("cantata --style gtk+") end),
	--awful.button({ }, 2, function () run_once("cantata --style gtk+") end),
	--awful.button({ }, 3, function () mpd_seek_forward()  end),
	awful.button({ }, 1, function () os.execute(switch_kbd_layout) end)
	--awful.button({"Ctrl" }, 1, function () mpd_prev() end),
	--awful.button({"Ctrl" }, 3, function () mpd_play_pause() end),
	--awful.button({"Ctrl" }, 2, function () mpd_next() end)
	))
	return kbdwidget
end

return setmetatable(kbddwidget, {__call = function(_,...) return worker(...) end})
