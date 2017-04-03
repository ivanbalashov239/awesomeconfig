local awful     = require("awful")
local client    = client
local keygrabber= keygrabber
local naughty   = require("naughty")
local pairs     = pairs
local beautiful = require("beautiful")
local wibox     = require("wibox")



local hintsetter = { mt = {} ,
charorder = "aoeuidhtnspyfgcrlqjkxbwvz1234567890",  --"jkluiopyhnmfdsatgvcewqzx1234567890"
used = {},
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
function hintsetter.init()
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
	--hintsize = 60
	--local fontcolor = beautiful.fg_normal
	--local letterbox = {}
	--for i = 1, #charorder do
	--local char = charorder:sub(i,i) --hintbox[char] = wibox({fg=beautiful.fg_normal, bg=beautiful.bg_focus, border_color=beautiful.border_focus, border_width=beautiful.border_width})
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
--function focus(tag)
	--if tag then
		--local hintindex = {} -- Table of visible clients with the hint letter as the keys
		--local clientlist = tag:clients()
		--for i,thisclient in pairs(clientlist) do -- Move wiboxes to center of visible windows and populate hintindex
			--local char = hintsetter.windows[thisclient.window]
			--hintindex[char:lower()] = thisclient
		--end
		--keygrabber.run( function(mod,key,event)
			--if event == "release" then return true end
			--keygrabber.stop()
			--show_notif(key:upper())
			--if hintindex[key] then 
				--client.focus = hintindex[key]
				--hintindex[key]:raise()
				--destroy_notif()
			--end 
		--end)
	--end
--end
function focus(cl,tag)
	client.focus = cl
	cl:raise()
	--awful.tag.viewonly(tag)
	tag:view_only()
	client.focus = cl
	cl:raise()
end
function choosetag(cl)
	local taglist = cl:tags()
	if #taglist >= 2 then
		local hintindex = {} 
		--debuginfo("more then 1 tag")
		local i = 0
		for _,thistag in pairs(taglist) do -- Move wiboxes to center of visible hintsetter.windows and populate hintindex
			if not (thistag.name == "IM") then
				i = i + 1
				local char = hintsetter.charorder:sub(i,i)
				hintindex[char] = thistag
			end
		end
		keygrabber.run( function(mod,key,event)
			if event == "release" then return true end
			if hintindex[key:lower()] then 
				keygrabber.stop()
				show_notif(key:upper())
				tag = hintindex[key]
				--debuginfo(tag.name)
				focus(cl,tag)
			else
				show_notif("Not "..key:upper())
				--debuginfo(hintindex[key:lower()])
			end 
		end)
	else
		--debuginfo("1 tag")
		--debuginfo(taglist[1].name)
		focus(cl,taglist[1])
	end
end

function hintsetter:focus(args)
	local args = args or {}
	local modal_sc = args.modal_sc or nil
	local rule = args.rule or {}
	local is_excluded = args.is_excluded or false
	local screen = args.screen or mouse.screen
	local hintindex = {} -- Table of visible clients with the hint letter as the keys
	--local taglist = awful.tag.gettags(screen)
	local taglist = screen.tags
	local clientlist = awful.client.visible(screen)
	local hintindex = {} -- Table of visible clients with the hint letter as the keys
	--local taglist = awful.tag.gettags(screen)
	local ind = 0
	local tagindex = {}
	for i,thistag in pairs(taglist) do
		if not (thistag.name == "IM") then
			ind = ind + 1
			tagindex[thistag] = hintsetter.charorder:sub(ind,ind)
		end
		for k,thisclient in pairs(thistag:clients()) do
			table.insert(clientlist,thisclient)
			--if hintsetter.windows[thisclient.window] then
				--hintindex[hintsetter.windows[thisclient.window]:lower()] = thisclient
			--end
		end
	end
	for i,thisclient in pairs(clientlist) do -- Move wiboxes to center of visible windows and populate hintindex
		local char = hintsetter.windows[thisclient.window]
		if char then
			hintindex[char:lower()] = thisclient
		end
		--debuginfo(thisclient.class)
	end
	--debuginfo(hintindex)
	if modal_sc then
		actions = {}
		for i, cl in pairs(hintindex) do
			tags = {}
			for _, tag in pairs(cl:tags()) do
				local hint = tagindex[tag]
				if hint then
					table.insert(tags,
						{
							hint = hint,
							func = function()
								focus(cl,tag)
							end
						}
					)
				end
			end
			if #tags > 1 then
				table.insert(actions,{
					modal = true,
					hint = hintsetter.windows[cl.window],
					desc = cl.class.." | "..cl.name,
					actions = tags
				})
			else
				table.insert(actions,{
					hint = i,
					desc = cl.class.." | "..cl.name,
					func = function()
						focus(cl,cl:tags()[1])
					end
				})
			end
		end
		modal_sc({
			name = "Choose client",
			actions = actions
		})()
	else
		keygrabber.run( function(mod,key,event)
			if event == "release" then return true end
			keygrabber.stop()
			show_notif(key:upper())
			--debuginfo(hintindex[key])
			if hintindex[key] then 
				--debuginfo("correct window")
				choosetag(hintindex[key])
				destroy_notif()
			else
				destroy_notif()
				show_notif("Not "..key:upper())
			end 
		end)
	end
end
function hintsetter:newtag(args)
	local args = args or {}
	local screen = args.screen or screen
	local hintindex = {}
	local marked = ""
	local only = args.only or false
	local clientlist = {}
	local taglist = screen.tags
	for i,thistag in pairs(taglist) do
		for k,thisclient in pairs(thistag:clients()) do
			table.insert(clientlist,thisclient)
			if hintsetter.windows[thisclient.window] then
				hintindex[hintsetter.windows[thisclient.window]:lower()] = thisclient
			end
		end
	end
	hintsetter.keygrabber.run( function(mod,key,event)
		if event == "release" then return true end
		show_notif(key:upper())
		if hintindex[key] then
			if marked:find(key) then
				marked = marked:gsub(key,"")
			else
				marked = marked..key
			end
				show_notif(marked:upper())
		elseif key == "Return" then
			local clients = {}
			for i = 1, #marked do
				local ch = marked:sub(i,i)
				table.insert(clients, hintindex[ch])
			end
			hintsetter.createresult(clients, screen,only)
		elseif key == "Escape" then
			hintsetter.createresult({})
		end 
	end)
end
local function match (table1, table2)
   for k, v in pairs(table1) do
	   local bool = false
	   for i,t in pairs(table2) do
		   if v == t then
			   bool = true
		   end
	   end
	   if not bool then return false end
   end
   return true
end
function hintsetter.createresult(mark, screen,only)
	hintsetter.keygrabber.stop()
	destroy_notif()
	local markedclients = mark or {}


	local newtable = {}
	if #markedclients < 2 then
		return false
	end
	n = 1
	for i,t in pairs(markedclients) do
		newtable[n]=t
		n = n + 1
	end
	for i,t in pairs(screen.tags) do
		if i > 1 then
			clients = t.clients(t)
			if (#clients == #newtable) then
				if match(newtable,clients) then
					--awful.tag.viewonly(t)
					t:view_only()
					return false
				end
			end
		end
	end
	local tagname = ""
	local tag = awful.tag.add(tagname, { volatile = true, 
	selected = true,
	layout = awful.layout.suit.tile,
	screen = screen})

	--awful.tag.viewonly(tag)
	tag:view_only()

	local name = ""

	for i,j in pairs(markedclients) do
		--awful.client.toggletag(tag,j)
		j:toggle_tag(tag)
		j.maximized_horizontal = false --not c.maximized_horizontal
		j.maximized_vertical   = false --not c.maximized_vertical
		name = name .. j.name:sub(0,2)
		if only then
			hintsetter:togglefromtag({
				client = j,
				delete = true,
			})
		end
	end
	tag.name = name

end
local function match_clients(rule, clients)
    local mfc = rule.any and newtag.match.any or newtag.match.exact
    local mf = is_excluded and function(c,rule) return not mfc(c,rule) end or mfc 
    local k,v, flt
    for _, c in pairs(clients) do
        if mf(c, rule) then
            -- Store geometry before setting their tags
            clientData[c] = {}
            if awful.client.floating.get(c) then 
                clientData[c]["geometry"] = c:geometry()
                flt = awful.client.property.get(c, "floating") 
                if flt ~= nil then 
                    clientData[c]["floating"] = flt
                    awful.client.property.set(c, "floating", false) 
                end

            end

            for k,v in pairs(newtag.property_to_watch) do
                clientData[c][k] = c[k]
                c[k] = v
                
            end
            --awful.client.toggletag(t, c)
	    c:toggle_tag(t)
        end
    end
    return clients
end

function hintsetter:togglefromtag(args)
	local args = args or {}
	local delete = args.delete or false
	--local tag = tag or awful.tag.selected(mouse.screen or 1)
	--local firsttag = args.tag or awful.tag.gettags(mouse.screen or 1)[1]
	local firsttag = args.tag or mouse.screen.tags[1]
	local cl = args.client or client.focus
	local cl_tags = cl:tags()
	local clients = firsttag:clients()
	if #cl_tags > 1 then
		for i,c in pairs(clients) do
			if c == cl then
				clients[i]=nil
				firsttag:clients(clients)
				return
			end
		end
	end
	if not delete then
		table.insert(clients,cl)
		firsttag:clients(clients)
	end
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

function hintsetter.mt:__call(...)
	return new(...)
end

return setmetatable(hintsetter, hintsetter.mt)
