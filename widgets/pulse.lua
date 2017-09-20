local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local gears      = require("gears")
local timer = gears.timer
--local apw 	 = require("apw/widget")
local modal_sc = require("modal_sc")      

local pulsewidget ={}
pulsewidget.shortcuts = {}
local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function worker(args)
	local args = args or {}
	local default_sink = "ponymix defaults | grep -i 'sink ' | awk '{printf $2}' | sed 's/:$//'"
	local cmd = args.cmd or 'index="$('..default_sink..')"  ;'..'pacmd list-sinks | grep -i "index: $index" -A 65 | sed -n -e "/base volume/d" -e "/volume:/p" -e "/muted:/p" -e "/device\\.string/p" -e "/index/p" -e "/device.string/p"'
	local scallback  = function()
	end
	--local pulse_widgets = apw({
	--container = false,
	--mixer1 = function () 
	--run_or_kill("veromix", { class = "veromix" }, {x = mouse.coords().x, y = mouse.coords().y, funcafter = apw.update, screen=mouse.screen}) 
	--end,
	--mixer2 =  function () 
	--run_or_kill("pavucontrol", { class = "Pavucontrol" }, {x = mouse.coords().x, y = mouse.coords().y, funcafter = apw.update, screen=mouse.screen}) 
	--end
	--})
	pulseaudio = lain.widget.pulseaudio({
		--cmd = "pacmd list-sinks | grep -i 'index: 1' -A 65 | sed -n -e '/base volume/d' -e '/volume:/p' -e '/muted:/p' -e '/device\\.string/p' -e '/index/p' -e '/device.string/p'",
		cmd = cmd,
		settings = function()
			if volume_now.left ~= "N/A" and volume_now.right ~= "N/A" then
				if volume_now.left == volume_now.right then
					vlevel = volume_now.left .. "%"
				else
					vlevel = volume_now.left .. "-" .. volume_now.right .. "% | " .. pulseaudio.sink
				end
			else
				vlevel = "N/A"
			end
			local markup = beautiful.fg_normal
			if volume_now.muted == "yes" then
				--vlevel = vlevel .. " M"
				markup = "#cc0000"
			end

			widget:set_markup(lain.util.markup(markup, vlevel))
		end
	})
	pulsebar = lain.widget.pulsebar({
		cmd = cmd,
		height = 25,
		width = 10,
		settings = function()
			if volume_now.left ~= "N/A" and volume_now.right ~= "N/A" then
				vlevel = (volume_now.left + volume_now.right) /2/150
				--if volume_now.left == volume_now.right then
					--vlevel = volume_now.left .. "%"
				--else
					--vlevel = volume_now.left .. "-" .. volume_now.right .. "% | " .. pulseaudio.sink
				--end
			else
				vlevel = 0
			end
			local markup = beautiful.fg_normal
			if volume_now.muted == "yes" then
				--vlevel = vlevel .. " M"
				markup = "#cc0000"
			end
			pulsebar.bar:set_value(vlevel)
			pulsebar.bar.color=markup
			pulsebar.bar.background_color = beautiful.panel_color

			--widget:set_markup(lain.util.markup(markup, vlevel))
		end
	})
	pulsewidget.pulse = pulseaudio
	pulsewidget.update = function()
		pulseaudio.update()
		pulsebar.update()
	end
	local pulsewidget = widgetcreator(
	{
		widgets = {
			wibox.widget {
				pulsebar.bar,
				forced_height    = 25,
				forced_width     = 10,
				direction     = 'east',
				layout        = wibox.container.rotate,
			}},
		textboxes = {pulseaudio.widget}
		--widgets = {pulse_widgets["progressbar"]},
		--textboxes = {pulse_widgets["textbox"]}
	})
	--apw:setbuttons(pulsewidget)
	return pulsewidget
end

function pulsewidget.up()
	awful.spawn(string.format("pactl set-sink-volume %d +10%%", pulsewidget.pulse.device))
	pulsewidget.update()
end
function pulsewidget.down()
	 awful.spawn(string.format("pactl set-sink-volume %d -10%%", pulsewidget.pulse.device))
         pulsewidget.update()
end
function pulsewidget.togglemute()
	os.execute(string.format("pactl set-sink-mute %d toggle", pulsewidget.pulse.device))
	pulsewidget.update()
end
function pulsewidget.menu()
	--print("pulse menu",10)
	local sinks_cmd = "ponymix list | grep -i 'sink ' -A 2 "
	local clients_cmd = "ponymix list | grep -i 'sink-input' -A 2 "
	--sinks = split(f:read(),"\n")
	--sinks = f:lines()
	local sinks = {}
	awful.spawn.easy_async({awful.util.shell,"-c",sinks_cmd},function(output,err,reason,exitcode)
		local i = 0
		--sinks = {}
		local cur_sink = nil
		for _,k in pairs(split(output,"\n")) do
			if i == 3 then
				i = 0
			end
			if  not (k == "") then
				if i == 0 then
					local sink = {}
					local words = split(k," ")
					sink.name = words[3]
					sink.index = tonumber(words[2]:sub(1, -2))
					cur_sink = sink.index
					local cmd = "ponymix --sink -d "..sink.index.." "
					function sink:mute()
						if sink.muted then
							os.execute(cmd.."unmute")
						else
							os.execute(cmd.."mute")
						end
						pulsewidget.update()
					end
					function sink:inc(number)
						local number = number or 15
						os.execute(cmd.."increase "..number)
						pulsewidget.update()
					end
					function sink:dec()
						local number = number or 15
						os.execute(cmd.."decrease "..number)
						pulsewidget.update()
					end
					function sink:default()
						os.execute(cmd.."set-default")
						pulsewidget.update()
					end
					sinks[sink.index] = sink
				elseif i == 1 then
					sinks[cur_sink].description = k
				elseif i == 2 then
					local words = split(k," ")
					sinks[cur_sink].volume = tonumber(words[5]:sub(1,-2))
					if words[6] then
						sinks[cur_sink].muted = true
					else
						sinks[cur_sink].muted = false
					end
				end
			end
			i = i + 1
		end
	end)
	local clients = {}
	awful.spawn.easy_async({awful.util.shell,"-c",clients_cmd},function(output,err,reason,exitcode)
		local i = 0
		--sinks = {}
		local cur_client = nil
		for _,k in pairs(split(output,"\n")) do
			if i == 3 then
				i = 0
			end
			if  not (k == "") then
				if i == 0 then
					local client = {}
					local words = split(k," ")
					--client.name = words[3]
					client.index = tonumber(words[2]:sub(1, -2))
					cur_client = client.index
					local cmd = "ponymix --sink-input -d "..client.index.." "
					function client:mute()
						if client.muted then
							os.execute(cmd.."unmute")
						else
							os.execute(cmd.."mute")
						end
					end
					function client:move(where)
						local where = where or 1
						os.execute(cmd.."move "..where)
					end
					function client:inc(number)
						local number = number or 15
						os.execute(cmd.."increase "..number)
					end
					function client:dec()
						local number = number or 15
						os.execute(cmd.."decrease "..number)
					end
					clients[client.index] = client
				elseif i == 1 then
					clients[cur_client].name = k
				elseif i == 2 then
					local words = split(k," ")
					clients[cur_client].volume = tonumber(words[5]:sub(1,-2))
					if words[6] then
						clients[cur_client].muted = true
					else
						clients[cur_client].muted = false
					end
					local client = clients[cur_client]
					--print(client.name.." "..tostring(client.muted))
				end
			end
			i = i + 1
		end
	end)
	local function sink_actions(sink)
		local mute = nil
		if sink.muted then
			mute = {
				hint = "m",
				func = function()
					sink:mute()
				end,
				desc = "unmute",
			}

		else
			mute = {
				hint = "m",
				func = function()
					sink:mute()
				end,
				desc = "mute",
			}
		end
		return {
			mute,
			{
				hint = "t",
				desc = "decrease volume",
				func = function()
					sink:inc()
				end,
			},
			{
				hint = "n",
				desc = "increase volume",
				func = function()
					sink:dec()
				end,
			},
			{
				hint = "d",
				desc = "set default",
				func = function()
					sink:default()
				end,
			},

		}
	end
	local function client_actions(client)
		local mute = nil
		local move = {}
		if client.muted then
			mute = {
				hint = "m",
				func = function()
					client:mute()
				end,
				desc = "unmute",
			}

		else
			mute = {
				hint = "m",
				func = function()
					client:mute()
				end,
				desc = "mute",
			}
		end
		for i,k in pairs(sinks) do
			table.insert(move,{
				func = function()
					client:move(k.index)
				end,
				desc = k.name.." "..tostring(k.index),
			})
		end
		return {
			{
				hint = "d",
				--func = function()
				--end,
				modal = true,
				desc = "move",
				actions = move
			},
			mute,
			{
				hint = "t",
				desc = "decrease volume",
				func = function()
					client:inc()
				end,
			},
			{
				hint = "n",
				desc = "increase volume",
				func = function()
					clinet:dec()
				end,
			},

		}
	end
	local timer = timer({
		timeout = 0.1
	})
	timer:connect_signal("timeout",function()
		timer:stop()
		local clients_modal = {}
		for _,cl in pairs(clients) do
			local muted = ""
			if cl.muted then
				muted = "muted"
			end
			table.insert(clients_modal,{
				desc = cl.name.." "..cl.volume.." "..muted,
				modal = true,
				actions = client_actions(cl)
			})
		end
		local sinks_modal = {}
		local sinks_n = 0
		for _,cl in pairs(sinks) do
			sinks_n = sinks_n + 1
			--print(cl.description)
			local muted = ""
			if cl.muted then
				muted = "muted"
			end
			local current = "  "
			if tonumber(pulsewidget.pulse.device) == cl.index then
				current = "* "
			end
			table.insert(sinks_modal,{
				desc = current..cl.description.." "..cl.volume.." "..muted,
				modal = true,
				actions = sink_actions(cl)
			})
		end
		local actions = {
			{
				modal = true,
				hint = "c",
				desc = "clients",
				actions = clients_modal,
			},
			{
				modal = true,
				hint = "d",
				desc = "outputs",
				actions = sinks_modal,
			},
			{
				--modal = true,
				hint = "m",
				desc = "mute",
				--actions = sinks_modal,
				func = function()
					pulsewidget.togglemute()
				end,
			},
		}
		if sinks_n == 2 then
			table.insert(actions,{
					hint = "s",
					desc = "switch",
					--actions = sinks_modal,
					func = function()
						for _,cl in pairs(sinks) do
							if not (tonumber(pulsewidget.pulse.device) == cl.index )then
								cl:default()
								for _,c in pairs(clients) do
									c:move(cl.index)
								end
								return
							end
						end

					end,
			})
		end
		modal_sc({
			name = "pulse",
			actions = actions
		})()
		pulsewidget.update()
	end)
	timer:start()
	--modal_sc({
	--actions = {
	--{
	--modal = true,
	--hint = "o",
	--desc = "DVI OFF",
	--actions={
	--{
	--hint = "f",
	--func = function()
	--os.execute("xrandr --output DVI-D-0 --off")
	--end,
	--desc = "DVI-off"
	--},
	--{
	--hint = "o",
	--func = function()
	--os.execute(scripts.."HDMI-normal-DVI-off.sh")
	--end,
	--desc = "HDMI-normal-DVI-off"
	--},
	--{
	--hint = "l",
	--func = function()
	--os.execute(scripts.."HDMI-left-DVI-off.sh")
	--end,
	--desc = "HDMI-left-DVI-off"
	--},
	--{
	--hint = "Enter",
	--func = function()
	--os.execute("xrandr --output DVI-D-0 --off")
	--end,
	--desc = ""
	--},
	--},
	--},
end

return setmetatable(pulsewidget, {__call = function(_,...) return worker(...) end})
