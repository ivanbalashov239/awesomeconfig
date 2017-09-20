local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
local net_widgets = require("net_widgets")

local netwidget ={}
netwidget.shortcuts = {}

local function worker(args)
	local args = args or {}
	local wired_interface = args.wired_interface or "enp5s0"
	local wireless_interface = args.wireless_interface or "wlp3s0"
	local wifitextlayout = wibox.layout.fixed.horizontal()
	local backtext = wibox.container.constraint()
	local net_wireless = net_widgets.wireless({
		interface=wireless_interface, 
		widget = false, 
		indent = 0, 
		timeout = 10,
		settings = function(args)
			if args.connected then
				backtext:set_widget(wifitextlayout)
			else
				backtext:reset()
			end
		end
	}) --, widget=wibox.layout.fixed.horizontal()})
	--if hostname == "jarvis" then
		--interface = "enp5s0"
	--else -- hostname == "Thinkpad" then
		--interface = "enp2s0"
	--end
	local net_wired = net_widgets.indicator({
		interfaces  = {wired_interface},
		timeout     = 25,
	})
	wifitextlayout:add(widgets.display_l)
	local background = wibox.container.background()
	background:set_widget(net_wireless.textbox)
	background:set_bgimage(beautiful.widget_display)
	wifitextlayout:add(background)
	wifitextlayout:add(widgets.display_r)

	local netwidget = widgetcreator(
	{
		widgets = {net_wired,net_wireless.imagebox,backtext},
		--text = "RAM",
		--textboxes = {net_wireless.textbox}
	})
	net_widgets.wireless:attach(netwidget)  --,{
	--onclick = run_or_kill(wifi_menu, { role = "WIFI_MENU" }, {x = mouse.coords().x, y = mouse.coords().y+2})})
	--net_widgetdl = wibox.widget.textbox()
	--net_widgetul = lain.widgets.net({
	--settings = function()
	--widget:set_markup(markup.font("Tamsyn 1", "  ") .. net_now.sent)
	--net_widgetdl:set_markup(markup.font("Tamsyn 1", " ") .. net_now.received .. markup.font("Tamsyn 1", " "))
	--end
	--})

	--widget_netdl = wibox.widget.imagebox()
	--widget_netdl:set_image(beautiful.widget_netdl)
	--netwidgetdl = wibox.widget.background()
	--netwidgetdl:set_widget(net_widgetdl)
	--netwidgetdl:set_bgimage(beautiful.widget_display)

	--widget_netul = wibox.widget.imagebox()
	--widget_netul:set_image(beautiful.widget_netul)
	--netwidgetul = wibox.widget.background()
	--netwidgetul:set_widget(net_widgetul)
	--netwidgetul:set_bgimage(beautiful.widget_display)
	return netwidget
end

return setmetatable(netwidget, {__call = function(_,...) return worker(...) end})
