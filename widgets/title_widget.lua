local widgetcreator = require("widgets")
local widgets = widgetcreator
local wibox = require("wibox")
local titlewidget ={}

local function worker(args)
	local args = args or {}
	if titlewidget.widget then
		return titlewidget.widget
	else
		--local layout = wibox.layout.flex.horizontal()
		local title = wibox.widget.textbox()
		--layout:set_left(wibox.layout.fixed.horizontal())
		--layout:set_right(wibox.layout.fixed.horizontal())
		--layout:set_right(title)
		--layout:add(title)
		title.align = "center"
		local title_widget = widgetcreator(
		{
			--image = beautiful.widget_mem,
			--text = "CPU",
			--textboxes = {layout}
			textboxes = {title}
		})
		
		client.connect_signal("focus",function(c)
			local name = c.name or c.class
			--local str = "https://thisisarandomsite.com/some_dir/src/blah/blah/7fd34a0945b036685bbd6cc2583a5c30.jpg"
			--print(name:match( "(http*)" ))
			name  = name:gsub("https?://[^ ]*","")
			if not name:lower():match(c.class:lower()) then
				name = name.." — "..c.class
			end

			title:set_text(name)
		end)
		client.connect_signal("property::name",function(c)
			if c == client.focus then
				local name = c.name or c.class
				--local str = "https://thisisarandomsite.com/some_dir/src/blah/blah/7fd34a0945b036685bbd6cc2583a5c30.jpg"
				--print(name:match( "(http*)" ))
				name  = name:gsub("https?://[^ ]*","")
				if not name:lower():match(c.class:lower()) then
					name = name.." — "..c.class
				end

				title:set_text(name)
			end
		end)
		titlewidget.widget = title_widget
		return title_widget
	end
end
return setmetatable(titlewidget, {__call = function(_,...) return worker(...) end})
