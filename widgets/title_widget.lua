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
		local scroll = wibox.widget {
			layout = wibox.container.scroll.horizontal,
			--max_size = 200,
			--extra_space = 100,
			--expand = true,
			step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
			speed = 50,
			title,
		}
		--scroll:pause()
		local title_widget = widgetcreator(
		{
			--image = beautiful.widget_mem,
			--text = "CPU",
			--textboxes = {layout}
			textboxes = {scroll}
		})
		local function set_title(c)
			if c then
				local name = c.name or c.class or ""
				local class = c.class or ""
				--local str = "https://thisisarandomsite.com/some_dir/src/blah/blah/7fd34a0945b036685bbd6cc2583a5c30.jpg"
				--print(name:match( "(http*)" ))
				name  = name:gsub("https?://[^ ]*","")
				if not name:lower():match(class:lower()) then
					name = name.." — "..c.class
				end

				--title:set_text(name)
				widgets.set_markup(title,name)
			end
		end
		
		client.connect_signal("focus",set_title)
		client.connect_signal("property::name",set_title)
		titlewidget.widget = title_widget

		--title_widget:connect_signal("mouse::enter",
		--function () 
			--scroll:continue()
		--end)
		--title_widget:connect_signal("mouse::leave",
		--function () 
			--scroll:pause()
			--scroll:reset_scrolling()
		--end)
		return title_widget
	end
end
return setmetatable(titlewidget, {__call = function(_,...) return worker(...) end})
