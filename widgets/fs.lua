local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local vicious = require("vicious")
local awful = require("awful")
local naughty = require("naughty")

local fswidget ={}
fswidget.shortcuts = {}

local function worker(args)
	local args = {}
	local disk_type = args.disk_type or "SSD"
	--local fs_widget = wibox.widget.textbox()
	--vicious.register(fs_widget, vicious.widgets.fs, widgets.vspace1 .. "${/ avail_gb}GB" .. widgets.vspace1, 2)
	local fs_widget = lain.widget.fs({
		notification_preset = {
			font = widgets.font,
			fg   = widgets.fg,
			bg   = widgets.bg
		},
		settings  = function()
			--local home_used = tonumber(fs_info["/home used_p"]) or 0
			widget:set_text(fs_now.used .. "%")
		end,
		showpopup = "off"
	})
	local fswidget = widgetcreator(
	{
		--image = beautiful.widget_fs,
		text = disk_type,
		textboxes = {fs_widget.widget}
	})
	fswidget:connect_signal('mouse::enter', function () lain.widget.fs.show(0) end)
	fswidget:connect_signal('mouse::leave', function () lain.widget.fs.hide() end)
	--local fsnotification = nil
	--function fswidget:hide()
		--if fsnotification ~= nil then
			--naughty.destroy(fsnotification)
			--fsnotification = nil
		--end
	--end

	--function fswidget:show(t_out)
		--fswidget:hide()

		--fsnotification = naughty.notify({
			--preset = fs_notification_preset,
			--text = text_grabber(),
			--timeout = t_out,
			--screen = mouse.screen,
		--})
	--end
	--function text_grabber()
		--f = io.popen("df -H")
		--text = f:read()
		--f:close()
		--f = io.popen("df -H | grep -i '^/dev/' ")
		--for line in f:lines() do
			--text = text.."\n"..line
		--end
		--f:close()
		--return text
	--end
	--fswidget:connect_signal('mouse::enter', function () fswidget:show(0) end)
	--fswidget:connect_signal('mouse::leave', function () fswidget:hide()  end)
	return fswidget
end

return setmetatable(fswidget, {__call = function(_,...) return worker(...) end})
