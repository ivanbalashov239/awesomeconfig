local setmetatable = setmetatable
local pairs = pairs
local awful = require("awful")
local setmetatable = setmetatable
local fullscreen = {}
local widgets = require("widgets")

local function timemute()
	awful.spawn.with_shell("rm /tmp/timemute>/dev/null || touch /tmp/timemute")
end




--dbus.request_name("session", "org.mpris.MediaPlayer2")
--dbus.add_match("session", "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'")
--dbus.connect_signal("org.freedesktop.DBus.Properties", function(...)
--local data = {...}
----for i,k in pairs(data[3]) do
----print(i)
----if type(k) == "string" then
----print(k)
----end
----end
----print(data[3].Metadata)
--local status = data[3].PlaybackStatus
--if status == "Playing" then
--pauseif()
--elseif status == "Paused" then
--playif()
--end
----for i,str in pairs(data) do
----print(i.." "..tostring(str))
----if type(str) == "table" then
----for k,n in pairs(str) do
----print(k.." "..tostring(n))
----end
----end
----end
--end
--)

local function checkclass(class)
	local table = {"Virtualbox","Bomi"}
	for i,n in pairs(table) do
		if n == class then
			return false
		end
	end
	return true
end
fullscreen.clients = {}

local function remove_client(tabl, c)
	local index = awful.util.table.hasitem(tabl, c)
	if index then
		table.remove(tabl, index)
		if #tabl == 0 then
			awful.spawn("xset s off")
			awful.spawn("xset -dpms")
			--print("xautolock -enable",15)
			--awful.spawn("xautolock -enable")
			--print("not fullscreen",10)
			awful.spawn.easy_async({"/bin/xautolock","-enable"},function(output,err)
				if err and not err == "" then
					print(err)
				end
			end)

			if checkclass(c.class) then
				timemute()
				widgets.mpd.playif()
			end
		end             
	end
end


local function worker(args)
	client.connect_signal("property::fullscreen",
	function(c)
		if c.fullscreen then
			table.insert(fullscreen.clients, c)
			if #fullscreen.clients == 1 then
				awful.spawn("xset s off")
				awful.spawn("xset -dpms")
				--naughty.suspend()
				--print("xautolock -disable",15)
				--awful.spawn("xautolock -disable")
				--print("fullscreen",10)
				awful.spawn.easy_async({"/bin/xautolock","-disable"},function(output,err)
					if err and not err == "" then
						print(err)
					end
				end)
				if checkclass(c.class) then
					widgets.mpd.pauseif()
					timemute()
				end
			end
		else
			remove_client(fullscreen.clients, c)
		end
	end)
	client.connect_signal("unmanage",
	function(c)
		if c.fullscreen then
			remove_client(fullscreen.clients, c)
		end
	end)
end



return setmetatable(fullscreen, { __call = function(_,...) return worker(...) end})
