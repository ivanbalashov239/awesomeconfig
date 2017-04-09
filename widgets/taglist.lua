local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local modal_sc = require("modal_sc")      
local hintsetter  = require("hintsetter")
local naughty = require("naughty")
local fixed 	 = require("wibox.layout.fixed")
local common 	 = require("awful.widget.common")
local sharedtags = require("sharedtags")
local theme = "pro-dark"
--local hintsetter  = require("hintsetter")
local widgets = widgetcreator
local capi = {
	mouse = mouse,
	client = client,
	screen = screen
}

local taglist ={}
taglist.shortcuts = {}
taglist.tags={}
mytaglist         = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
--awful.button({ }, 3, awful.tag.viewtoggle),
--awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, function(t) awful.tag.viewnext() end),
awful.button({ }, 5, function(t) awful.tag.viewprev() end)
)
--awful.tag.attached_connect_signal(nil,"removed",function(tag)
	----print(tag.name)
	----table.remove(taglist.tags,tag)
	----for i,k in pairs(taglist.tags)do
		----print(k.name)
	----end
--end)
awful.tag.attached_connect_signal(nil,"property::activated",function(tag)
	if tag and tag.activated then
		table.insert(taglist.tags,tag)
		--print("add "..tag.index..tostring(tag.volatile))
		--taglist.tags[tag.index] = tag
	elseif tag then
		--print("remove "..tag.name or tag.index)
		--print(tag.index..tostring(tag.volatile))
		for i,k in pairs(taglist.tags)do
			if k == tag then
				table.remove(taglist.tags,i)
				break
			end
		end
		--taglist.tags[tag.index] = nil
	end
	--print(#taglist.tags)
	--for i,k in pairs(taglist.tags) do
	--print(k.name)
	--end
	--print("finish")
end)

function taglist:get_tags()
	return taglist.tags
end
local function check_tag(tag)
	local n = 0
	for _,c in ipairs(tag:clients()) do
		if not c.floating and c.type == "normal" then
			n = n + 1
		end
	end
	return n == 1
end

local function worker(args)
	local args = args or {}
	local screen = args.screen or mouse.screen
	--print(#taglist:get_tags())
	--uf = list_update
	--w = args.base_widget or fixed.horizontal()
	--if args.tags then
	--taglist.tags = args.tags or {}
	--end
	--list_update(w,tags,awful.widget.taglist.taglist_label,screen)
	function list_update(w, buttons, label, data, objects)
		local function matchrules(tag)
			return function(c, screen)
				--if c.sticky then return true end
				--local ctags = c:tags()
				--for _, v in ipairs(ctags) do
				--if v == tag then
				--return true
				--end
				--end
				return false
			end
		end

		local function tagsort(tags)
			local oneclients = {}
			local other = {}
			for i,k in ipairs(tags) do
				if check_tag(k) then
					table.insert(oneclients,k)
				else
					table.insert(other,k)
				end
			end
			local result = {}
			for i,k in ipairs(oneclients) do
				table.insert(result,k)
			end
			for i,k in ipairs(other) do
				table.insert(result,k)
			end
			return result
			--return oneclients, other
		end
		-- update the widgets, creating them if needed
		w:reset()
		--w:add(awful.widget.tasklist(screen))
		--oldprint(type(objects))
		--print(taglist.tags == taglist:get_tags())
		--print("tags "..#taglist.tags)
		--print("get_tags "..#taglist:get_tags())
		local tags = tagsort(taglist:get_tags())
		taglist.tags = tags
		--print(#tags)
		--table.sort(tags,tagsort)
		--print(#tags)
		for i, o in ipairs(tags) do
			--print(o.hint:upper(), 10)
			local myiconlist         = {}
			myiconlist.buttons = awful.util.table.join(
			awful.button({ }, 1, function (c)
				if c == client.focus and c.screen == screen then
					c.minimized = true
				else
					c.minimized = false
					if not c:isvisible() or c.screen ~= screen then
						--awful.tag.viewonly(c:tags()[1])
						sharedtags.viewonly(o,screen)
						o:view_only()
					end
					client.focus = c
					c:raise()
				end
			end),
			awful.button({ }, 12, function (c)
				c:kill()
			end),
			awful.button({ }, 2, function (c)
				c:kill()
			end),
			awful.button({ }, 3, function (c)
				if instance then
					instance:hide()
					instance = nil
				else
					instance = awful.menu.clients({
						theme = { width = 250 }
					})
				end
			end),
			awful.button({ }, 4, function ()
				taglist.nexttag({
					screen = screen
				})
				--awful.client.focus.byidx(1)
				if client.focus then client.focus:raise() end
			end),
			awful.button({ }, 5, function ()
				taglist.prevtag({
					screen = screen
				})
				--awful.client.focus.byidx(-1)
				if client.focus then client.focus:raise() end
			end)
			)

			--print(o.name)
			if not o.hidden and o.activated then
				--break
				local cache = data[o]
				local ib, tb, bgb, m, l
				if cache then
					ib = cache.ib
					tb = cache.tb
					bgb = cache.bgb
					m   = cache.m
					textwidget = cache.textwidget
					textl = cache.textl
				else
					ib = wibox.widget.imagebox()
					tb = wibox.widget.textbox()
					textwidget = widgets({
						textboxes = {tb}
					})
					--textwidget = wibox.container.background()
					--textwidget:set_bgimage(beautiful.widget_display)
					--textwidget:set_widget(tb)
					bgb = wibox.container.background()
					m = wibox.container.margin(tb, 4, 4)
					l = wibox.layout.fixed.horizontal()
					textl = wibox.layout.fixed.horizontal()


					-- All of this is added in a fixed widget
					l:fill_space(true)
					--l:add(m)
					l:add(widgets.spr)
					l:add(widgets.spr)
					--print(o.name)
					l:add(textl)
					--l:add(taglist.tasklist({tag=o, screen = screen, disable_text=true}))
					l:add(awful.widget.tasklist(screen, matchrules(o),  myiconlist.buttons, nil, taglist.get_tasklist_update(o,screen), fixed.horizontal()))
					--l:add(awful.widget.tasklist(screen,matchrules(o)))
					--awful.widget.taglist.filter.all
					l:add(widgets.spr)
					l:add(widgets.spr)
					-- And all of this gets a background
					--title = wibox({fg=beautiful.fg_normal, bg=beautiful.bg_focus, border_color=beautiful.border_focus, border_width=beautiful.border_width})
					--title:set_widget(tb)
					bgb:set_widget(l)
					--w:connect_signal("mouse::enter", function ()
					--title.visible = true
					--title.x = mouse.coords().x 
					--title.y = mouse.coords().y 
					--title.screen = capi.mouse.screen
					--end)
					--w:connect_signal("mouse::leave", function () title.visible = false end)

					--bgb:buttons(common.create_buttons(buttons, o))
					data[o] = {
						ib  = ib,
						tb  = tb,
						bgb = bgb,
						tbm = tbm,
						ibm = ibm,
						textwidget = textwidget,
						textl = textl
					}

				end
				textl:reset()
				if not check_tag(o)then
					textl:add(textwidget)
				end

				local text, bg, bg_image, icon = label(o)
				-- The text might be invalid, so use pcall
				if not pcall(tb.set_markup, tb, text) then
					tb:set_markup("<i>&lt;Invalid text&gt;</i>")
				end
				--bgb:set_bg(bg)
				--if type(bg_image) == "function" then
				--bg_image = bg_image(tb,o,m,objects,i)
				--end
				tb:set_text(o.hint or o.name or "no_hint")
				--bgb:set_bgimage(bg_image)
				ib:set_image(icon)
				if o.name and o.name == "all" and #(o:clients()) == 0 then
				else
					w:add(bgb)
				end

			end
		end

	end
	--return awful.widget.taglist(screen, awful.widget.taglist.filter.all, mytaglist.buttons)
	--local taglist = awful.widget.taglist(screen, awful.widget.taglist.filter.all, mytaglist.buttons, {}, taglist_update)
	return awful.widget.taglist(screen, awful.widget.taglist.filter.all, mytaglist.buttons, {}, list_update)
	--return w
end
function get_clients_by_geometry(tag)
	local clients = tag:clients()
	if tag == taglist.tags["all"] then
		return clients
	end
	table.sort(clients,compare_by_geometry)
	return clients

end
function compare_by_geometry(a,b)
	if a.x == b.x then
		return a.y < b.y
	else
		return a.x < b.x
	end
end
--function list_update(w, objects, label,screen)
function taglist.get_tasklist_update(tag,screen)
	--oldprint(tag)
	--print("gettasklist_update")
	return function (w, buttons, label, data, objects)
		-- update the widgets, creating them if needed
		w:reset()
		local clients =get_clients_by_geometry(tag)
		--print(type(clients))
		--print("update tasklist")
		for i, o in ipairs(clients) do
			--print(o.class)
			local cache = data[o]
			local ib, tb, bgb, m, l, munf, mfoc, background
			if cache then
				ib = cache.ib
				bgb = cache.bgb
				m =  cache.m
				tb = cache.tb
				munf = cache.munf
				mfoc = cache.mfoc
				l = cache.l
				tl = cache.tl
				el = cache.el
				tbl = cache.tbl
			else
				ib = wibox.widget.imagebox()
				bgb = wibox.container.background()
				tb = wibox.widget.textbox()
				m = wibox.container.margin(tb, 0, 0)
				--munf = wibox.container.margin(ib, 0, 0, 0, 5)
				--mfoc = wibox.container.margin(ib, 0, 0, 0, 0)
				l = wibox.layout.fixed.horizontal()
				tl = wibox.layout.fixed.horizontal()
				tbl = wibox.container.constraint()
				munf = wibox.container.margin(l, 0, 0, 0, 5)
				mfoc = wibox.container.margin(l, 0, 0, 0, 0)
				l:add(widgets.display_l)
				local background = wibox.container.background()
				background:set_widget(m)
				background:set_bgimage(beautiful.widget_display)
				-- All of this is added in a fixed widget
				l:fill_space(true)
				--if #(tag:clients()) > 1 then
				tl:add(background)
				--end
				tbl:set_widget(tl)
				l:add(tbl)
				l:add(ib)
				--l:add(munf)


				-- And all of this gets a background
				bgb:set_widget(l)

				bgb:buttons(common.create_buttons(buttons, o))

				data[o] = {
					ib = ib,
					bgb = bgb,
					m = m,
					tb = tb,
					munf   = munf,
					mfoc = mfoc,
					l = l,
					tl = tl,
					el = el,
					tbl = tbl,
				}
			end
			if tag.selected and tag.screen == screen then
				if (o == capi.client.focus) then
					bgb:set_widget(mfoc)
				else
					bgb:set_widget(munf)
				end
			else
				bgb:set_widget(munf)
			end

			local text, bg, bg_image, icon, args = label(o, tb)
			-- The text might be invalid, so use pcall
			--if not pcall(tb.set_markup, tb, text) then
			local textlabel = ""

			--if hintsetter.windows[o.window] then
			if o.hint then
				--tb:set_markup('<span font="Terminus 10" weight="bold">'..hintsetter.windows[o.window]..'</span>')
				textlabel = o.hint
			else
				--tb:set_markup(markup.font("Terminus 4", " ")..'<span font="Terminus 10" weight="bold">'.."_"..'</span>'..markup.font("Terminus 4", " "))
				textlabel ="_"
			end
			--print(textlabel)
			--end
			if o.minimized then
				--background = wibox.widget.background()
				--tbl:set_widget(el)
				--print(o.class.." minimized")
				textlabel = "^"..textlabel
				--else
				--tbl:set_widget(tl)
			end
			tb:set_markup('<span font="Terminus 10" weight="bold">'..textlabel..'</span>')
			if icon == nil then
				icon = os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/icons/konsole.png"
			end
			--bgb:set_bg(bg)
			if type(bg_image) == "function" then
				bg_image = bg_image(tb,o,m,objects,i)
			end
			bgb:set_bgimage(bg_image)
			ib:set_image(icon)
			w:add(bgb)
		end
	end
end
function taglist.bydirection(dir, c, all)
	local sel = c or capi.client.focus
	if sel then
		--local tag = awful.tag.selected(sel.screen)
		local tag = sel.screen.selected_tag
		local id = awful.tag.getidx(tag)
		--if id  == 1 then
		local cltbl = awful.client.visible(sel.screen)
		local geomtbl = {}
		for i,cl in ipairs(cltbl) do
			geomtbl[i] = cl:geometry()
		end

		local target = awful.util.get_rectangle_in_direction(dir, geomtbl, sel:geometry())

		-- If we found a client to focus, then do it.
		if target then
			capi.client.focus = cltbl[target]
		end
		if sel == capi.client.focus and check_tag(tag) then
			--local tag
			local newtag = nil
			if dir == "left" then
				newtag = taglist.prevtag({
					_return = true
				})
			elseif dir == "right" then
				newtag = taglist.nexttag({
					_return = true
				})
			else
				return
			end
			if newtag and  #(newtag:clients()) == 1 then
				sharedtags.viewonly(newtag)
				newtag:view_only()
				return
			end
		end
	end
end
function taglist.global_bydirection(dir, c, all)
	local screen = awful.screen
	local sel = c or capi.client.focus
	local scr = capi.mouse.screen
	local all = all or false
	--print(type(all))
	--print(tostring(all))
	if sel then
		scr = sel.screen
	end
	-- change focus inside the screen
	taglist.bydirection(dir, sel, all)

	-- if focus not changed, we must change screen
	if sel == capi.client.focus then
		screen.focus_bydirection(dir, scr)
		--if scr ~= capi.mouse.screen then
			----local tag = awful.tag.selected(capi.mouse.screen)
			--local tag = capi.mouse.screen.selected_tag
			--local id = awful.tag.getidx(tag)
			--if id  ~= 1 then

				--local cltbl = awful.client.visible(capi.mouse.screen)
				--local geomtbl = {}
				--for i,cl in ipairs(cltbl) do
					--geomtbl[i] = cl:geometry()
				--end
				--local target = awful.util.get_rectangle_in_direction(dir, geomtbl, capi.screen[scr].geometry)

				--if target then
					--capi.client.focus = cltbl[target]
				--end
			--end
		--end
	end
end    	

function taglist.nexttag(args)
	local args = args or {}
	local screen = args.screen or capi.mouse.screen
	local nonempty = args.nonempty or true
	local direction = args.direction or 1
	local current = false
	local _return = args._return or false
	for i,k in ipairs(taglist:get_tags())do
		--print(k.name)
			if current then
				if not k.hidden and ((nonempty and #(k:clients())>0) or not nonempty) then
					--print("switch to "..k.name)
					if _return then
						return k
					else
						sharedtags.viewonly(k,screen)
						k:view_only()
						return
					end
				end
			else
				if k == screen.selected_tag then
					--print(k.name.." current")
					current = true
				end
			end
	end
end
function taglist.prevtag(args)
	local args = args or {}
	local screen = args.screen or capi.mouse.screen
	local nonempty = args.nonempty or true
	local direction = args.direction or 1
	local current = false
	local prevtag = nil
	local _return = args._return or false
	for i,k in ipairs(taglist:get_tags())do
		--print(prevtag and prevtag.name or "nil")
		--print(tostring(i)..tostring(k.name))
		if not current then
			if k == screen.selected_tag then
				--print(k.name.." current")
				current = true
			elseif nonempty and #(k:clients())> 0 and not k.hidden then
				--print("setting prev "..k.name)
				prevtag = k
			end
		end
		--print(prevtag and "prevtag "..prevtag.name or "no prev tag")
		if current then
			--k:view_only()
			if prevtag and not prevtag.hidden and ((nonempty and #(k:clients())>0) or not nonempty ) then
				--print("switching to "..prevtag.name)
				if _return then
					return prevtag
				else
					sharedtags.viewonly(prevtag,screen)
					prevtag:view_only()
				end
				break
			elseif nonempty and #(k:clients())> 0 and not k.hidden then
				--print("setting prev "..k.name)
				prevtag = k
			end
		end
	end
end
function taglist.focus(args)
	local args = args or {}
	--local modal_sc = args.modal_sc or nil
	local rule = args.rule or {}
	local is_excluded = args.is_excluded or false
	local screen = args.screen or mouse.screen
	local hintindex = {} -- Table of visible clients with the hint letter as the keys
	--local taglist = awful.tag.gettags(screen)
	--local taglist = screen.tags
	local clientlist = {}
	local hintindex = {} -- Table of visible clients with the hint letter as the keys
	--local taglist = awful.tag.gettags(screen)
	local ind = 0
	local tagindex = {}
	for i,thistag in pairs(taglist:get_tags()) do
		--if not (thistag.name == "IM") then
			--ind = ind + 1
			--tagindex[thistag] = hintsetter.charorder:sub(ind,ind)
		--end
		for k,thisclient in pairs(thistag:clients()) do
			table.insert(clientlist,thisclient)
			--if hintsetter.windows[thisclient.window] then
				--hintindex[hintsetter.windows[thisclient.window]:lower()] = thisclient
			--end
		end
	end
	for i,thisclient in pairs(clientlist) do -- Move wiboxes to center of visible windows and populate hintindex
		local char = thisclient.hint
		if char then
			hintindex[char:lower()] = thisclient
		end
		--debuginfo(thisclient.class)
	end
	--debuginfo(hintindex)
	local focus = function(cl,tag)
		client.focus = cl
		cl:raise()
		--awful.tag.viewonly(tag)
		sharedtags.viewonly(tag,screen)
		tag:view_only()
		client.focus = cl
		cl:raise()
	end
	actions = {}
	for i, cl in pairs(hintindex) do
		tags = {}
		for _, tag in pairs(cl:tags()) do
			local hint = tag.hint
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
				hint = cl.hint,
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
end
function taglist.newtag(args)
	local args = args or {}
	local screen = args.screen or mouse.screen
	local hintindex = {}
	local marked = ""
	local only = args.only or false
	local clientlist = {}
	--local taglist = screen.tags
	for i,thistag in pairs(taglist:get_tags()) do
		for k,thisclient in pairs(thistag:clients()) do
			table.insert(clientlist,thisclient)
			if thisclient.hint then
				hintindex[thisclient.hint:lower()] = thisclient
			end
		end
	end
	marked = {}
	markedstring = ""
	function newtag()
		actions = {}
		for i,k in pairs(hintindex) do
			--print(k.hint)
			table.insert(actions,{
				hint = i,
				desc = k.class.." | "..k.name,
				func = function()
					if marked[i] then
						marked[i] = nil
						markedstring = markedstring:gsub(i,"")
					else
						marked[i] = k
						markedstring = markedstring..i
					end
					newtag()
				end
			})
		end
		markedclients = {}
		--string = ""
		for i,k in pairs(marked)do
			table.insert(markedclients,k)
			--string = string..i
		end
		table.insert(actions,{
			hint = "Return",
			desc = "create tag",
			func = function()
				if #markedclients < 1 then
					return false
				end
				local tagname = ""
				local tag = awful.tag.add(tagname, { volatile = true, 
				selected = true,
				layout = awful.layout.suit.tile,
				screen = screen})
				tag:clients(markedclients)
				sharedtags.viewonly(tag,screen)
				tag:view_only()
				if #markedclients == 1 then
					local c = markedclients[1]
					if c.hint then
						if tag.hint then
							hintsetter.tag_used[tag.hint]= nil
						end
						tag.hint = hintsetter:hint_tag(c.hint)
						hintsetter.tag_used[tag.hint]= tag
					end
				end
				for i,j in pairs(markedclients) do
					j.maximized_horizontal = false --not c.maximized_horizontal
					j.maximized_vertical   = false --not c.maximized_vertical
					if only then
						local tags = j:tags()
						for i,k in ipairs(tags)do
							if check_tag(k) then
								k:clients({})
							--if k == taglist.tags[1] then
								--table.remove(tags,i)
							end
						end
						j:tags(tags)
					end
				end
			end
		})
		modal_sc({
			name = "Choose client: "..markedstring:upper(),
			actions = actions
		})()
	end
	newtag()
end
function taglist.togglefromtag(client,tag)
	local client = client or capi.client.focus
	local tag = tag or taglist.tags["all"]
	local tags = client:tags()
	for i,k in ipairs(tags)do
		print(k.hint)
		if check_tag(k) then
			print("toggle tag")
			--table.remove(tags,i)
			if #tags ~= 1 then
				--client:tags({tag})
			--else
				k:clients({})
				--client:tags(tags)
			end
			return
		end
	end
	table.insert(tags,tag)
	client:tags(tags)
end

return setmetatable(taglist, {__call = function(_,...) return worker(...) end})
