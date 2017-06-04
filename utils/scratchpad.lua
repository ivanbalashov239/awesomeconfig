local pairs = pairs
local awful = require("awful")
local setmetatable = setmetatable
local capi = {
    mouse = mouse,
    client = client,
    screen = screen
}

local scratchpad = {}
scratchpad.functions = {}
function scratchpad.functions.place_away(c,old)
	c:tags({})
	c.screen = old.screen
	c:geometry(old.geometry)
	c.floating = old.floating
	c:geometry(old.geometry)
	c:tags(old.tags)
end
function scratchpad.functions.hide_client(c,old)
	c:tags({})
	--c.screen = old.screen
	--c:geometry(old.geometry)
	--c.floating = old.floating
	--c:geometry(old.geometry)
	--c:tags(old.tags)
end
function scratchpad.functions.im_geometry(c)
	local screen = c.screen
	local screengeom = screen.workarea
	local geometry = {}

	geometry.width  = screengeom.width * 0.25
	geometry.height = screengeom.height * 1

	geometry.x =  screengeom.x+screengeom.width-geometry.width
	geometry.y =  screengeom.y
	--geometry.y = screengeom.y
	--geometry.x = screengeom.x
	return geometry
	
end
function scratchpad.functions.dropdown_geometry(c)
	local screen = c.screen
	local screengeom = screen.workarea
	local geometry = {}

	geometry.width  = screengeom.width * 1
	geometry.height = screengeom.height * 0.25

	geometry.y = screengeom.y
	geometry.x = screengeom.x
	return geometry
	
end
local function worker(args)
	local args = args or {}
	local hide_on_unfocus = args.hide_on_unfocus or false
	local scratch = {}
	scratch.client = args.client
	local command = args.command
	local hide_client = args.hide or scratchpad.functions.hide_client
	local set_geometry = args.set_geometry or scratchpad.functions.dropdown_geometry
	local old = {}
	local spawn = args.spawn or function(f)
		--local new_geometry = set_geometry(capi.client.focus)
		awful.util.spawn(command,{
			floating = true,
			hidden = true,
			--width = new_geometry.width,
			--height = new_geometry.height,
			--x = new_geometry.x,
			--y = new_geometry.y

		},
		function(c)
			--print("spawn "..command,15)
			local new_geometry = set_geometry(capi.client.focus)
			c:geometry(new_geometry)
			scratch.client = c
			c.hidden = true
			--c:tags({})
			f(c)
			--c:tags({})
			--scratch:hide()
			scratch:show()
			old.tags = {}
		end)
	end
	if not scratch.client then
		--if not command then
			--print("scratchpad should have client or command")
			--return nil
		--end
		--spawn()
		--function(c)
		--if not args.spawn then
		--args.client = c
		--args.spawn  = true
		--worker(args)
		--end
		--end)
	end
	local function on_unfocus()
		scratch:hide()
	end
	--print("scratch.client "..client.name)
	function scratch:show()
		--print("show",10)
		if not scratch.client or not scratch.client.valid then
			spawn(
			function()
				if scratch.client:isvisible() then
					scratch:hide()
				else
					scratch:show()
				end
			end
			)
			return
		else
			local focus = capi.client.focus
			local screen = focus.screen
			local client = scratch.client
			old.geometry = client:geometry()
			old.screen = client.screen
			old.tags = client:tags()
			old.floating = client.floating
			old.hidden = client.hidden
			old.ontop = client.ontop
			local new_geometry = set_geometry(focus)
			client:tags({})
			client.hidden = false
			client.ontop = true
			client.floating = true
			client.screen = focus.screen
			client:geometry(new_geometry)
			client:tags({screen.selected_tag})
			client:geometry(new_geometry)
			capi.client.focus = client
			if hide_on_unfocus then
				client:connect_signal("unfocus",on_unfocus)
			end
		end
	end
	function scratch:hide()
		--print("hide",10)
		if not scratch.client or not scratch.client.valid then
			spawn(
			function()
				if scratch.client:isvisible() then
					scratch:hide()
				else
					scratch:show()
				end
			end
			)
			return
		else
			hide_client(scratch.client,old)
			if hide_on_unfocus then
				scratch.client:disconnect_signal("unfocus",on_unfocus)
			end
		end
	end
	function scratch:toggle()
		if not scratch.client or not scratch.client.valid then
			spawn(
			function()
				if scratch.client:isvisible() then
					scratch:hide()
				else
					scratch:show()
				end
			end
			)
			return
		else
			if scratch.client:isvisible() then
				scratch:hide()
			else
				scratch:show()
			end
		end
	end
	return scratch
end



return setmetatable(scratchpad, { __call = function(_,...) return worker(...) end})
