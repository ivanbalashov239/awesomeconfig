local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local apw 	 = require("apw/widget")

local pulsewidget ={}
pulsewidget.shortcuts = {}

local function worker(args)
	local pulse_widgets = apw({
		container = false,
		mixer1 = function () 
			run_or_kill("veromix", { class = "veromix" }, {x = mouse.coords().x, y = mouse.coords().y, funcafter = apw.update, screen=mouse.screen}) 
		end,
		mixer2 =  function () 
			run_or_kill("pavucontrol", { class = "Pavucontrol" }, {x = mouse.coords().x, y = mouse.coords().y, funcafter = apw.update, screen=mouse.screen}) 
		end
	})
	local pulsewidget = widgetcreator(
	{
		widgets = {pulse_widgets["progressbar"]},
		textboxes = {pulse_widgets["textbox"]}
	})
	apw:setbuttons(pulsewidget)
	return pulsewidget
end

return setmetatable(pulsewidget, {__call = function(_,...) return worker(...) end})
