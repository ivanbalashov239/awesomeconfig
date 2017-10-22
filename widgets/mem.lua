local widgetcreator = require("widgets")
local widgets = widgetcreator
local utils = require("utils")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
local rork = require("rork")      
local run_or_raise = rork.run_or_raise
local run_or_kill = rork.run_or_kill

local memwidget ={}
memwidget.shortcuts = {}

local function worker(args)
	local args = args or {}


	local membuttons = awful.util.table.join(awful.button({ }, 1,
	function () run_or_kill(htop_mem, { role = "HTOP_MEM" }, {x = mouse.coords().x, y = mouse.coords().y+2}) end))


	local memp_widget = wibox.widget.textbox()
	local mem_widget = lain.widget.mem({
		timeout = 15,
		settings = function()
			local perc = math.ceil(mem_now.used/mem_now.total*100, 0, 3)
			--memp_widget:set_markup(widgets.space3 .. perc .. "%" .. lain.util.markup.font("Tamsyn 4", " "))
			--widget:set_markup(widgets.space3 .. mem_now.used .. "MB" .. lain.util.markup.font("Tamsyn 4", " "))
			widgets.set_markup(memp_widget,utils.to_n(perc .. "%",4))
			widgets.set_markup(widget,utils.to_n(mem_now.used .. "MB",7))
		end
	})
	--local memwidget = wibox.widget.background()
	--memwidget:set_widget(mem_widget)
	--memwidget:set_bgimage(beautiful.widget_display)
	local memwidget = widgetcreator(
	{
		--image = beautiful.widget_mem,
		text = "RAM",
		textboxes = {mem_widget.widget, memp_widget}
	})
	memwidget:buttons(membuttons)
	return memwidget
end

return setmetatable(memwidget, {__call = function(_,...) return worker(...) end})
