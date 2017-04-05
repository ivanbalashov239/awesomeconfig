local awful     = require("awful")
local client    = client
local keygrabber= keygrabber
local naughty   = require("naughty")
local pairs     = pairs
local beautiful = require("beautiful")
local wibox     = require("wibox")



local hintsetter = { mt = {} ,
charorder = "jkluiopyhnmfdsatgvcewqzx1234567890",
used = {},
tag_used = {},
windows = {},
}

function debuginfo( message )
	nid = naughty.notify({ text = message, timeout = 10 })
end
function show_notif(string)
	local text ='<span font="Cantarel 50">'..string.."</span>"
	destroy_notif()
	hintsetter.notif = naughty.notify({
		text = text,
		timeout = 2,
		screen = mouse.screen or 2,
		position = "top_left",
	})
end
function destroy_notif()
	if hintsetter.notif then
		naughty.destroy(hintsetter.notif)
	end
end

-- Create the wiboxes, but don't show them
function hintsetter.init(args)
	local args = args or {}
	if args.charorder then
		hintsetter.charorder = args.charorder
	end
	for i = 1, #hintsetter.charorder do
		local ch = hintsetter.charorder:sub(i,i)
		hintsetter.used[ch] = false
	end
	hintsetter.keygrabber = keygrabber


	client.connect_signal("manage", function(c) 
		if c.class then
			local ch = hintsetter:hint_by_string(c.class):upper()
			hintsetter.windows[c.window] = ch
			c.hint = ch
		end
		return true
	end)
	client.connect_signal("unmanage", function(c) 
		if hintsetter.windows[c.window] then
			hintsetter.used[hintsetter.windows[c.window]:lower()] = nil
			hintsetter.windows[c.window] = nil
		end
		return true
	end)
	--client.connect_signal("tagged",
	--function(c,t)
		--if c.hint and #(t:clients()) == 1 then
			--if t.hint then
				--hintsetter.tag_used[t.hint]= nil
			--end
			--t.hint = hintsetter:hint_tag(c.hint)
			--hintsetter.tag_used[t.hint]= t
		--end
	--end)
	awful.tag.attached_connect_signal(nil,"property::activated",function(tag)
		if tag and tag.activated then
			if not tag.hint then
				local ch = hintsetter:hint_tag(tag.name)
				tag.hint = ch
			else
				hintsetter.tag_used[tag.hint] = tag
			end
		elseif tag then
			hintsetter.tag_used[tag.hint] = nil
		end
	end)
end

function hintsetter:hint_by_string(str)
	str = str:lower()
	for k = 1 , #str do
		char = str:sub(k,k)
		if not hintsetter.used[char] then
			--print("by_class "..char)
			hintsetter.used[char] = true
			return char
		end
	end

	for i = 1, #hintsetter.charorder do
		local ch = hintsetter.charorder:sub(i,i)
		--print("from order: "..ch)
		if not hintsetter.used[ch] then
			hintsetter.used[ch] = true
			return ch
		end
	end
	return "_"
end
function hintsetter:hint_tag(str)
	local str = str or ""
	str = str:lower()
	for k = 1 , #str do
		local char = str:sub(k,k)
		if not hintsetter.tag_used[char] then
			--print("by_class "..char)
			hintsetter.tag_used[char] = true
			return char
		end
	end

	for i = 1, #hintsetter.charorder do
		local ch = hintsetter.charorder:sub(i,i)
		--print("from order: "..ch)
		if not hintsetter.tag_used[ch] then
			hintsetter.tag_used[ch] = true
			return ch
		end
	end
	return "_"
end

function hintsetter.mt:__call(...)
	return new(...)
end

return setmetatable(hintsetter, hintsetter.mt)
