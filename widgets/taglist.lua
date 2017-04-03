local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
local fixed 	 = require("wibox.layout.fixed")
local common 	 = require("awful.widget.common")
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
--myiconlist         = {}
--myiconlist.buttons = awful.util.table.join(
--awful.button({ }, 1, function (c)
--if c == client.focus then
--c.minimized = true
--else
--c.minimized = false
--if not c:isvisible() then
--awful.tag.viewonly(c:tags()[1])
--end
--client.focus = c
--c:raise()
--end
--end),
--awful.button({ }, 12, function (c)
--c:kill()
--end),
--awful.button({ }, 2, function (c)
--c:kill()
--end),
--awful.button({ }, 3, function ()
--if instance then
--instance:hide()
--instance = nil
--else
--instance = awful.menu.clients({
--theme = { width = 250 }
--})
--end
--end),
--awful.button({ }, 4, function ()
--awful.client.focus.byidx(1)
--if client.focus then client.focus:raise() end
--end),
--awful.button({ }, 5, function ()
--awful.client.focus.byidx(-1)
--if client.focus then client.focus:raise() end
--end))
--mytaglist         = {}
--mytaglist.buttons = awful.util.table.join(
--awful.button({ }, 1, awful.tag.viewonly),
--awful.button({ modkey }, 1, awful.client.movetotag),
----awful.button({ }, 3, awful.tag.viewtoggle),
----awful.button({ modkey }, 3, awful.client.toggletag),
--awful.button({ }, 4, function(t) awful.tag.viewnext() end),
--awful.button({ }, 5, function(t) awful.tag.viewprev() end)
--)
awful.tag.attached_connect_signal(nil,"removed",function(tag)
	table.remove(taglist.tags,tag)
end)
awful.tag.attached_connect_signal(nil,"property::activated",function(tag)
	if tag then
		table.insert(taglist.tags,tag)
	end
	--print(#taglist.tags)
	--print("added tag")
	--for i,k in pairs(taglist.tags) do
	--print(k.name)
	--end
	--print("finish")
end)

function taglist:get_tags()
	return taglist.tags
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
		-- update the widgets, creating them if needed
		w:reset()
		--w:add(awful.widget.tasklist(screen))
		local number = -1
		--oldprint(type(objects))
		--print(taglist.tags == taglist:get_tags())
		--print("tags "..#taglist.tags)
		--print("get_tags "..#taglist:get_tags())
		for i, o in ipairs(taglist:get_tags()) do

			--print(o.name)
			number = number + 1
			if number ~= 1 then
				--break
				--number = number + 1
				local cache = data[o]
				local ib, tb, bgb, m, l
				if cache then
					ib = cache.ib
					tb = cache.tb
					bgb = cache.bgb
					m   = cache.m
				else
					ib = wibox.widget.imagebox()
					tb = wibox.widget.textbox()
					textwidget = wibox.container.background()
					textwidget:set_bgimage(beautiful.widget_display)
					textwidget:set_widget(tb)
					bgb = wibox.container.background()
					m = wibox.container.margin(tb, 4, 4)
					l = wibox.layout.fixed.horizontal()

					-- All of this is added in a fixed widget
					l:fill_space(true)
					--l:add(m)
					l:add(widgets.spr)
					l:add(widgets.spr)
					--print(o.name)
					--print("number "..number)
					if number > 0 then
						--print("added text label")
						l:add(widgets.display_l)
						l:add(textwidget)
						l:add(widgets.display_r)
					end
					--l:add(taglist.tasklist({tag=o, screen = screen, disable_text=true}))
					l:add(awful.widget.tasklist(screen, matchrules(o),  myiconlist.buttons, nil, taglist.get_tasklist_update(o), fixed.horizontal()))
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
					}
				end

				local text, bg, bg_image, icon = label(o)
				-- The text might be invalid, so use pcall
				if not pcall(tb.set_markup, tb, text) then
					tb:set_markup("<i>&lt;Invalid text&gt;</i>")
				end
				bgb:set_bg(bg)
				if type(bg_image) == "function" then
					bg_image = bg_image(tb,o,m,objects,i)
				end
				tb:set_text(o.hint or o.name or "no_hint")
				bgb:set_bgimage(bg_image)
				ib:set_image(icon)
				w:add(bgb)
			end
		end
	end
	--return awful.widget.taglist(screen, awful.widget.taglist.filter.all, mytaglist.buttons)
	--local taglist = awful.widget.taglist(screen, awful.widget.taglist.filter.all, mytaglist.buttons, {}, taglist_update)
	return awful.widget.taglist(screen, awful.widget.taglist.filter.all, mytaglist.buttons, {}, list_update)
	--return w
end
--function list_update(w, objects, label,screen)
function taglist.get_tasklist_update(tag)
	--oldprint(tag)
	--print("gettasklist_update")
	return function (w, buttons, label, data, objects)
		-- update the widgets, creating them if needed
		w:reset()
		for i, o in ipairs(tag:clients()) do
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
				tl:add(background)
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
			if tag.selected then
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
		if id  == 1 then
			local clientlist = tag:clients()
			local clid = nil
			for i,cl in pairs(clientlist) do
				if cl == sel then
					clid = i
					break
				end
			end
			local number = nil
			if dir == "left" then
				number = -1
			elseif dir == "right" then
				number = 1
			end
			if number then
				clid = clid + number
				while clientlist[clid] do
					if not clientlist[clid].minimized or all then
						if (clid > 0) and (clid <= #clientlist) then
							local target = clientlist[clid]
							-- If we found a client to focus, then do it.
							if target then
								capi.client.focus = target
								break
							end
						end
					end
					clid = clid + number
				end
			end

		else
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
		if scr ~= capi.mouse.screen then
			--local tag = awful.tag.selected(capi.mouse.screen)
			local tag = capi.mouse.screen.selected_tag
			local id = awful.tag.getidx(tag)
			if id  ~= 1 then

				local cltbl = awful.client.visible(capi.mouse.screen)
				local geomtbl = {}
				for i,cl in ipairs(cltbl) do
					geomtbl[i] = cl:geometry()
				end
				local target = awful.util.get_rectangle_in_direction(dir, geomtbl, capi.screen[scr].geometry)

				if target then
					capi.client.focus = cltbl[target]
				end
			end
		end
	end
end    	

return setmetatable(taglist, {__call = function(_,...) return worker(...) end})
