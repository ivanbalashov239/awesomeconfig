local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
local net_widgets = require("net_widgets")
local modal_sc = require("modal_sc")      
local utils = require("utils")

local netwidget ={}
netwidget.shortcuts = {}
local function prompt(args)
	local args = args or {}
	local text = args.text or ""
	local prompt=args.prompt or ""
	local action = args.action or function(text)end
	--task:show(0)
	awful.prompt.run({
		prompt = prompt,
		text=text,
		exe_callback = action,
		--history_path = awful.util.getdir("cache") .. "/task_history",
	},
	mouse.screen.mypromptbox.widget
	--task.promptbox[mouse.screen].widget,
	)
end
local function output_to_ssids(output)
	local ssids = {}
	local output = utils.split(output,"\n")
	for _,k in pairs(output) do
		--print(k,5)
		local ssid = {}
		local str = utils.split(k,":")
		local i = 1
		if #str==8 and str[1] == "*" then
			ssid.active = true
			--i = 1
			--print(k)
		else
			ssid.active = false
		end
		ssid.name = str[1+i] or ""
		ssid.mode = str[2+i] or ""
		ssid.chan = str[3+i] or ""
		ssid.rate = str[4+i] or ""
		ssid.signal = str[5+i] or "0"
		ssid.bars = str[6+i] or "___"
		ssid.security=str[7+i] or "none"
		ssid.actions = function()
			local actions = {
			}
			if ssid.active then
				table.insert(actions,{
					hint = "d",
					desc = "disconnect",
					func = function()
						os.execute("nmcli dev disconnect wlp3s0")
					end,
				})
			else
				table.insert(actions,{
					hint = "c",
					desc = "connect",
					func = function()
						awful.spawn.easy_async({"nmcli","connection","up",ssid.name or " "},function(stdout, stderr, reason, exit_code)
							if not (exit_code == 0) then
								prompt({
									prompt = "Password: ",
									action = function(password)
										awful.spawn.easy_async({"/bin/nmcli","device wifi connect",ssid.name,"password",password},function(output,err)
											print(err or output,5)
										end)
									end,
								})
							else
								print(stdout,5)
							end
						end)
					end,
				})
			end
			return actions
		end
		if ssid.chan == "" then
		else
			table.insert(ssids,ssid)
		end
	end
	return ssids
end
local function get_desc(active,name,chan,signal,bars,security)
	local to_n = utils.to_n
	return to_n(active,2)..""..to_n(name,10).." | "..to_n(chan,2).." | "..to_n(signal,3).."|"..bars.."|"..to_n(security,11)
end

function netwidget.menu(args)
	local args = args or {}
	awful.spawn.easy_async({"nmcli","-t","dev","wifi"},function(output,err)
		--print(err)
		local actions = {}
		local ssids = output_to_ssids(output)
		local n = 0
		local others = {}
		for _,ssid in ipairs(ssids) do
			local active = " "
			if ssid.active then
				active = "*"
			end
			local desc = get_desc(active,ssid.name,ssid.chan,ssid.signal,ssid.bars,ssid.security)
			--print(desc,5)
			--print(desc,5)
			local action = {
				desc =desc,
				modal = true,
				actions = ssid.actions()
			}
			n = n + 1
			if n>5 then
				table.insert(others,action)
			else
				table.insert(actions,action)
			end
		end
		table.insert(actions,{
			hint = "o",
			desc = "Others",
			modal = true,
			actions = others,
		})
		table.insert(actions,{
			hint = "e",
			desc = "Connection Editor",
			func = function()
				awful.spawn("nm-connection-editor")
				
			end,
		})
		modal_sc({
			name = "NetworkManager menu",
			actions = actions,
		})()
	end)
end
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
	local menu = netwidget.menu

	local netwidget = widgetcreator(
	{
		widgets = {net_wired,net_wireless.imagebox,backtext},
		--text = "RAM",
		--textboxes = {net_wireless.textbox}
	})
	net_widgets.wireless:attach(netwidget)  --,{
	local buttons = awful.util.table.join(awful.button({ }, 1,menu
	))
	netwidget:buttons(buttons)
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
