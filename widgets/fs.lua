local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local vicious = require("vicious")
local awful = require("awful")
local naughty = require("naughty")
local path = require("path")
local modal_sc = require("modal_sc")      

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
				--print("updating files")
				--local f = {}
				--for line in output:lines() do
				----text = text.."\n"..line
				--table.insert(f,line)
				--end
				fswidget.files = split(output,"\n")
				--print("finish update files")
			end
		})
		--files_watch.update()
	end
	local disk_type = args.disk_type or "SSD"
	--local fs_widget = wibox.widget.textbox()
	--vicious.register(fs_widget, vicious.widgets.fs, widgets.vspace1 .. "${/ avail_gb}GB" .. widgets.vspace1, 2)
	local fs_widget = lain.widget.fs({
		notification_preset = {
			font = "Terminus 15",
			fg   = widgets.fg,
			bg   = widgets.bg
		},
		settings  = function()
			--print(output)
			--local home_used = tonumber(fs_info["/home used_p"]) or 0
			--widget:set_text(fs_now.used .. "%")
			widgets.set_markup(widget,fs_now.available_gb .. "GB")
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
	local directory = args.dir or os.getenv("HOME").."/Downloads"
	local launcher = args.launcher or "mpv"
	local exts  = args.exts or {"avi","mkv","mp4","mpeg","webm"}
	local function file(pname)
		local f = {}
		local pname = pname
		--print(pname)
		if pname and  path.exists(pname)then
			f.path = pname
			f.name = pname:match( "([^/]+)$" ) or ""
			if path.isdir(pname) then
				local actions = {}
				--for i,k in pairs(path.lsdir(pname)) do
				--print("_"..pname.."_")
				pcall(path.each,path.ensure_dir_end(pname), function(P)
					--print(pname)
					if not (P == pname ) then
						--print(P)
						table.insert(actions,file(P).action)
					end
				end,
				{
					param = "f";
					delay = true;
					--recurse = true;
				})
				table.sort(actions,
				function (a,b)
					if a and b and a.desc and b.desc then
						return a.desc < b.desc
					end
					return false
				end)
				f.action = {
					modal = true,
					desc = f.name,
					actions = actions
				}
			elseif f.name and f.path then
				local ext = path.extension(pname)
				for _,v in pairs(exts) do
					if ext  == "."..v then
						f.action = {
							desc = f.name,
							func = function()
								awful.spawn({launcher,f.path})
							end
						}

						break
					end
				end
			end
		end
		return f
	end
	local function file_exists(file)
		local f = io.open(file, "rb")
		if f then f:close() end
		return f ~= nil
	end
	--path.each(path.ensure_dir_end("/tmp"),
	--function(P)
		--print(P)
	--end,
	--{
		--param = "f";
		--delay = true;
		----recurse = true;
	--})
	awful.spawn.easy_async({"python","/home/ivn/scripts/open_recent_files.py",directory},function(output,err)
		local actions = {}
		local names = {}
		local seen_lines = {}
		local function last_seen()
			local length = 25
			local actions = {}
			local cmd =HOME..'/scripts/last_seen_to_list.py' 
			local file = assert(io.popen(cmd, 'r'))
			local out = file:read('*all')
			file:close()
			for _,l in pairs(split(out,"\n")) do
				l = split(l," ;; ")
				local name = l[2]
				local value = l[1]
				table.insert(actions,{
					desc = name,
					func = function()
						awful.spawn({launcher,value})
					end
				})
			end
			return actions

		end
		table.insert(actions,{
			hint = "Space",
			desc = "last seen",
			modal = true,
			actions = last_seen()
		})
		for i,k in pairs(split(output,"\n"))do
			local f = file(k)
			if f.action then
				table.insert(actions,f.action)
			end
		end
		modal_sc({
			name = "media files menu",
			actions = actions,

		})()
	end)
end

return setmetatable(fswidget, {__call = function(_,...) return worker(...) end})
