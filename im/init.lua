local awful     = require("awful")
local capi = {
    mouse = mouse,
    client = client,
    screen = screen
    }
local im = { mt = {} }
local function getcl(c)
	local tag = awful.tag.gettags(1)[2]
	--if imclient then
	----moveback(imclient)
	--imclient:emit_signal("unfocus")
	--imclient = c
	----capi.client.focus = c
	--end
	--local keys = awful.util.table.join(
	--awful.key({          }, "Escape",      function (c) 
		--c:emit_signal("unfocus")
		--imclient = nil
		--im()
	--end)
	--awful.key({modkey,           }, "i",      function (c) 
		--c:emit_signal("unfocus")
		--imclient = nil
		--im()
	--end),
	--awful.key({altgr,           }, "u",      function (c) 
		--c:emit_signal("unfocus")
	--end)
	--,
	--awful.key({ }, "Escape",      function (c) 
	--c:emit_signal("unfocus")
	--end)
	--)
	local prop = {}
	--prop.keys = c:keys()
	--c:keys(keys)
	prop.screen = c.screen
	--prop.tags = c:tags()
	prop.opacity = c.opacity
	prop.ontop = c.ontop
	prop.sticky = false
	prop.urgent = false
	prop.floating = c.floating
	awful.client.floating.set(c,true)
	c.ontop = true
	prop.opacity = c.opacity
	c.opacity = 0.7
	local oldgeom = c:geometry()
	local screen = capi.mouse.screen
	awful.client.movetoscreen(c,screen)
	c:tags(awful.tag.selectedlist(screen))
	local screengeom = capi.screen[screen].workarea
	local clgeom = {}
	clgeom.width = screengeom.width/4
	clgeom.x =  screengeom.x+screengeom.width-clgeom.width
	clgeom.y =  screengeom.y --+20
	clgeom.height = screengeom.height
	clgeom = c:geometry(clgeom)
	clgeom.x =  screengeom.x+screengeom.width-clgeom.width
	c:geometry(clgeom)
	capi.client.focus = c
	local function moveback(cl)
		cl.hidden = false
		--print(c.name)
		cl:tags({})
		cl.opacity = prop.opacity
		cl.ontop = prop.ontop
		cl.sticky = prop.sticky
		cl.urgent = prop.urgent
		--if prop.keys then
			--cl:keys(prop.keys)
		--end
		awful.client.floating.set(cl,prop.floating)
		--for i,k in ipairs(prop) do
		--cl[i] = k
		--end
		--cl.opacity = 1
		--awful.client.movetoscreen(cl,prop.screen)

		--cl:tags({tag})
		awful.client.movetotag(tag,cl)
		awful.client.floating.set(cl,prop.floating)
		cl:geometry(oldgeom)
		cl:disconnect_signal("unfocus", moveback)
		--imclient = nil
	end
	c:connect_signal("unfocus", moveback)


end
function im.getcl(c)
	getcl(c)
end
local function get_im()
	local tag = awful.tag.gettags(1)[2]
	if im.lastpidgin and im.lastpidgin.valid then
		if im.lastpidgin.urgent then
			if awful.tag.selected() == tag then
				capi.client.focus = im.lastpidgin
			else
				getcl(im.lastpidgin)
			end
			return true
		end
	end
		
	for i,cl in pairs(tag:clients()) do
		if cl.urgent then
			if awful.tag.selected() == tag then
				capi.client.focus = cl
			else
				getcl(cl)
			end
			return true
		end
	end
	if im.lastpidgin and im.lastpidgin.valid then
		if awful.tag.selected() == tag then
			capi.client.focus = im.lastpidgin
		else
			getcl(im.lastpidgin)
		end
	else
		awful.tag.viewonly(tag)
		hints.focus(1)
	end
	return false
end

function im.mt:__call(...)
	return get_im(...)
end

return setmetatable(im, im.mt)
