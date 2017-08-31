local widgetcreator = require("widgets")
local widgets = widgetcreator
local wibox = require("wibox")
local titlewidget ={}

local function worker(args)
	local args = args or {}
	if titlewidget.widget then
		return titlewidget.widget
	else
		local title = wibox.widget.textbox()
		local title_widget = widgetcreator(
		{
			--image = beautiful.widget_mem,
			--text = "CPU",
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
		titlewidget.widget = title_widget
		return title_widget
	end
end
return setmetatable(titlewidget, {__call = function(_,...) return worker(...) end})
