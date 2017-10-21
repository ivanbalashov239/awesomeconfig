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
local utils = require("utils")

local fswidget ={}
fswidget.shortcuts = {}
fswidget.automount_stop_cmd = "pkill udiskie"
fswidget.automount_cmd ="bash -c \""..fswidget.automount_stop_cmd..";".."udiskie -q -0 -a -T".."\""
fswidget.noautomount_cmd ="bash -c \""..fswidget.automount_stop_cmd..";".."udiskie -q -0 -A -T".."\""
function fswidget.start_automount()
	--awful.spawn(fswidget.automount_stop_cmd)
	awful.spawn(fswidget.automount_cmd)
	fswidget.automount = true
end
function fswidget.stop_automount()
	--awful.spawn(fswidget.automount_stop_cmd)
	awful.spawn(fswidget.noautomount_cmd)
	fswidget.automount = false
end

local function worker(args)
	local args = args or {}
	local automount = args.automount or false
	print(automount)
	fswidget.automount = automount
	if automount then
		print("Automount")
		fswidget.start_automount()
	else
		fswidget.stop_automount()
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
			for _,l in pairs(utils.split(out,"\n")) do
				l = utils.split(l," ;; ")
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
		for i,k in pairs(utils.split(output,"\n"))do
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
function fswidget.mounts_menu(args)
	local args = args or {}
	local separator = args.separator or ";;"
	local filter = args.filter or function(device)
		--return true
		if not device.HintSystem then
			return true
		elseif #(device.MountPoints)==0 then
			return true
		else
			for _,m in pairs(device.MountPoints)do
				if m:find("^/run/media/ivn/") then
					return true
				end
			end
			return false
		end
	end
	--local directory = args.dir or os.getenv("HOME").."/Downloads"
	local fm = args.fm or "pcmanfm-qt"
	local exts  = args.exts or {"avi","mkv","mp4","mpeg","webm"}
	local function clean(str)
		return string.gsub(string.gsub(str,"'$",""),"^'","")
	end
	local function du_to_devices(output)
		local devices = {}
		local output = utils.split(output,"\n")
		local names = {}
		for i,k in pairs(output) do
			if k ~= "" then
				--print(k)
				local str = utils.split(k,separator)
				if i == 1 then
					names = str
				else
					local device = {}
					for k,data in pairs(str)do
						local name = names[k]
						local data = data
						--print(name)
						--print(data)
						if name == "Use%" then
							name = "Use"
						end
						if data == "---" then
							data = false
						end
						if data == "True" then
							data = true
						end
						if data ~= nil then
							device[name] = data
						end
						--print(name)
						--print(data)
						--print(name.." "..tostring(data))
					end
					devices[device.Filesystem]=device
					--table.insert(devices,device)
				end
			end
		end
		return devices
	end
	local function output_to_devices(output)
		local devices = {}
		local output = utils.split(output,"\n")
		local names = {}
		for i,k in pairs(output) do
			if k ~= "" then
				local str = utils.split(k,separator)
				if i == 1 then
					names = str
				else
					local device = {}
					for k,data in pairs(str)do
						local name = names[k]
						local data = data
						if data == "---" then
							data = false
						end
						if data == "True" then
							data = true
						end
						if k == 8 then
							--device[name] = {}
							local mounts = {}
							if not(data=="[]") then
								--print(data)
								local array = string.sub(data,2,#data-1)
								array = utils.split(array,", ")
								for i,k in pairs(array) do
									mounts[i]=clean(k)
								end
							end
							device[name] = mounts
						else
							if data ~= nil then
								device[name] = data
							end
							--print(name)
							--print(data)
							--print(name.." "..tostring(data))
						end
					end
					function device:actions()
						local actions = {}
						if #(device.MountPoints)>0 then
							table.insert(actions,{
									hint = "u",
									desc = "unmount",
									func = function()
										awful.spawn("udcli umount "..device.Device)
									end,
								})
						else
							table.insert(actions,{
									hint = "m",
									desc = "mount",
									func = function()
										awful.spawn("udcli mount "..device.Device)
									end,
								})
						end
						table.insert(actions,{
								hint = "p",
								desc = "unPower",
								func = function()
									awful.spawn("udisksctl power-off -b "..device.Device)
								end,
							})
						return actions
					end
					table.insert(devices,device)
				end
			end
		end
		return devices
	end
	awful.spawn.easy_async({"udcli","list","-s="..separator},function(output,err)
		local actions = {}
		local names = {}
		local seen_lines = {}
		local devices = output_to_devices(output)
		--awful.spawn.easy_async({"bash -c \"df -H | sed 's/\\s\\s*/"..separator.."/g'".." \""},function(output,err)
		local output, err = io.popen("/usr/bin/env bash -c \"df -H | sed 's/\\s\\s*/"..separator.."/g'".." \"")
		local du = ""
		if output then
			du = output:read("*all")
			output:close()
		end
		output = du
		du = du_to_devices(output)
		for i,device in pairs(devices) do
			local d = du[device.Device]
			if d then
				--print("from_du")
				device.Size = d.Size
				device.Used = d.Used
				device.Use = d.Use
				devices[i] = device
			else
				device.Size = ""
				device.Used = ""
				device.Use = ""
				devices[i] = device
			end
		end
		local to_n = utils.to_n
		for i,device in pairs(devices) do
			if filter(device) then
				local mounts = nil
				for _,m in pairs(device.MountPoints)do
					if mounts then
						mounts = mounts.."\n"..to_n("",49).."|"..m
					else
						mounts = m
					end
				end
				mounts = mounts or ""
				local desc = to_n(device.Device,10).."|"..to_n(device.IdType,10).."|"..to_n(device.IdLabel,10).."|"..to_n(device.Size,4).."|"..to_n(device.Used,4).."|"..to_n(device.Use,4).."|"..to_n(mounts)
				--oldprint(desc)
				table.insert(actions,{
						desc = desc,
						modal = true,
						actions = device:actions()
					})
			end
		end

		if not fswidget.automount then
			table.insert(actions,{
					hint = "a",
					desc = "Enable automount",
					func = function()
						fswidget.start_automount()
					end
				})
		else
			table.insert(actions,{
					hint = "a",
					desc = "Disable automount",
					func = function()
						fswidget.stop_automount()
					end
				})
		end
		modal_sc({
				name = "mounts menu".."\n  "..to_n("Device",10).."|"..to_n("FS",10).."|"..to_n("Label",10).."|"..to_n("Size",4).."|"..to_n("Used",4).."|"..to_n("Use%",4).."|"..to_n("Mount Points",15),
				actions = actions,

			})()
		--end)
	end)
end

return setmetatable(fswidget, {__call = function(_,...) return worker(...) end})
