local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local apw 	 = require("apw/widget")

local pulsewidget ={}
pulsewidget.shortcuts = {}

local function worker(args)
	local args = args or {}
	local cmd = args.cmd or "pacmd list-sinks | grep -i 'index: 1' -A 65 | sed -n -e '/base volume/d' -e '/volume:/p' -e '/muted:/p' -e '/device\\.string/p' -e '/index/p' -e '/device.string/p'"
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

return setmetatable(pulsewidget, {__call = function(_,...) return worker(...) end})
