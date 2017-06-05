local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local vicious = require("vicious")
local awful = require("awful")
local naughty = require("naughty")
local path = require("path")

local fswidget ={}
fswidget.shortcuts = {}
local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function worker(args)
	local args = args or {}
	local watch = args.watch or false
	local watch_timeout = args.watch_timeout or 600
	local dir = args.dir or  "/home/ivn/Downloads"
	local cmd = "find "..dir.." -type f \\( -name '*.avi' -o -name '*.mkv' \\)"
	--local text = ""
	if watch then
		fswidget.files = {}
		fswidget.dir = dir
		local files_watch = lain.widget.watch({
			timeout = watch_timeout,
			stoppable = true,
			cmd = { awful.util.shell, "-c", cmd },
			settings = function()
				print("updating files")
				--local f = {}
				--for line in output:lines() do
					----text = text.."\n"..line
					--table.insert(f,line)
				--end
				fswidget.files = split(output,"\n")
				print("finish update files")
			end
		})
		--files_watch.update()
	end
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
			--widget:set_text(fs_now.used .. "%")
			widget:set_text(fs_now.available_gb .. "GB")
            --fs_now.available_gb = fs_info[partition .. " avail_gb"] or "N/A"
		end,
		showpopup = "off"
	})
	local fswidget = widgetcreator(
	{
		--image = beautiful.widget_fs,
		text = disk_type,
		textboxes = {fs_widget.widget}
	})
	fswidget:connect_signal('mouse::enter', function () fs_widget.show(0) end)
	fswidget:connect_signal('mouse::leave', function () fs_widget.hide() end)
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

function fswidget.media_files_menu(args)
	local args = args or {}
	local dirs = {}
	local index = 0
	local function file(name,ignore)
		--print(name)
		if name == "" then
			return nil
		end
		index = index + 1
		--oldprint(index)
		local dir = {}
		dir.full = name
		dir.children = {}
		dir.children.dirs = {}
		dir.children.files = {}
		dir.parent = ""
		dir.name = ""
		dir.parent,dir.name = path.splitpath(name)
		local parent = nil
		if dir.name == ".unwanted" then
			return nil
		end
		if not dirs[dir.parent] and not ignore then 
			parent = file(dir.parent)
		else
			parent = dirs[dir.parent]
		end
		if not parent then
			dir.parent = nil
		end
		--table.insert(dir.parent.children,dir)
		if path.isdir(name) then
			--print(dir.name)
			dir._type = "dir" 
			dirs[name] = dir
			if not ignore and parent then
				table.insert(parent.children.dirs,dir)
			end
		else
			dir._type = "file"
			if not ignore and parent then
				table.insert(parent.children.files,dir)
			end
		end
		return dir
	end

	local dir = file(fswidget.dir,true)
	--dirs[fswidget.dir] = dir

	--print(#fswidget.files)
	for _,P in pairs(fswidget.files) do
		--print(P)
		file(P)
	end
	print(#(dir.children.dirs))
	print(#(dir.children.files))
	--for _,d in pairs(dir.children.dirs) do
		--print(d.name)
	--end
	--param = "fm";   -- request full path and mode
	--delay = true;   -- use snapshot of directory
	--recurse = true; -- include subdirs
	--reverse = true; -- subdirs at first 
--})
end

return setmetatable(fswidget, {__call = function(_,...) return worker(...) end})
