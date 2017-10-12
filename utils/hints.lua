local awful     = require("awful")
local client    = client
local keygrabber= keygrabber
local naughty   = require("naughty")
local pairs     = pairs
local beautiful = require("beautiful")
local wibox     = require("wibox")
local hintsetter = require("hintsetter")
local gears = require("gears")

--module("hints")

hintbox = {} -- Table of letter wiboxes with characters as the keys

function debuginfo( message )
	nid = naughty.notify({ text = message, timeout = 10 })
end

-- Create the wiboxes, but don't show them
function worker()
	--print("init")
	hintbox["started"] = true
	--for i = 1, #hintsetter.charorder do
		--local char = hintsetter.charorder:sub(i,i)
		--hintbox[char] = wibox({fg=beautiful.fg_normal, bg=beautiful.bg_focus, border_color=beautiful.border_focus, border_width=beautiful.border_width})
		--hintbox[char].ontop = true
		--hintbox[char].width = hintsize
		--hintbox[char].height = hintsize
		--letterbox[char] = wibox.widget.textbox()
		--letterbox[char]:set_markup("<span color=\"" .. beautiful.fg_normal .. "\"" .. ">" .. char.upper(char) .. "</span>")
		--letterbox[char]:set_font("dejavu sans mono 40")
		--letterbox[char]:set_align("center")
		--hintbox[char]:set_widget(letterbox[char])
	--end
end
function box(char)
	local hintsize = 60
	local fontcolor = beautiful.fg_normal
	local letterbox = {}
	if not hintbox[char] then
		hintbox[char] = wibox({fg=beautiful.fg_normal, bg=beautiful.bg_focus, border_color=beautiful.border_focus, border_width=beautiful.border_width})
		hintbox[char].ontop = true
		hintbox[char].width = hintsize
		hintbox[char].height = hintsize
		letterbox[char] = wibox.widget.textbox()
		letterbox[char]:set_markup("<span color=\"" .. beautiful.fg_normal .. "\"" .. ">" .. char.upper(char) .. "</span>")
		letterbox[char]:set_font("dejavu sans mono 40")
		letterbox[char]:set_align("center")
		hintbox[char]:set_widget(letterbox[char])
	end
	return hintbox[char]
end

function hintbox.focus(scr)
	if not hintbox["started"] then
		worker()
	end
	local screens = screen
	if scr then
		screens = {scr}
	end
	local hintindex = {} -- Table of visible clients with the hint letter as the keys
	local clientlist ={}
	for s in screens do
		local clients = s.clients
		clientlist = gears.table.join(clientlist,clients)
	end

	if #clientlist == 1 then
		client.focus = clientlist[1]
	else
		for i,thisclient in pairs(clientlist) do -- Move wiboxes to center of visible windows and populate hintindex
			local char = thisclient.hint:lower()
			local charbox = box(char)
			hintindex[char] = thisclient
			local geom = thisclient:geometry()
			hintbox[char].x = geom.x + geom.width/2 - hintsize/2
			hintbox[char].y = geom.y + geom.height/2 - hintsize/2
			hintbox[char].screen = thisclient.screen
			hintbox[char].visible = true
		end
		keygrabber.run( function(mod,key,event)
			if event == "release" then return true end
			keygrabber.stop()
			if hintindex[key] then 
				client.focus = hintindex[key]
				hintindex[key]:raise()
			end 
			for i,j in pairs(hintindex) do
				hintbox[i].visible = false
			end
		end)
	end
end

return setmetatable(hintbox, { __call = function(_,...) return worker(...) end})
