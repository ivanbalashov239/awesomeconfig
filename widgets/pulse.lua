local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local apw 	 = require("apw/widget")

local pulsewidget ={}
pulsewidget.shortcuts = {}

local function worker(args)
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
		settings = function()
			--print("pulse")
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

return setmetatable(pulsewidget, {__call = function(_,...) return worker(...) end})
