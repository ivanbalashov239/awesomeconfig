local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")

local tasklist ={}
tasklist.shortcuts = {}

local function worker(args)
	local args = args or {}
	local screen = args.screen or 1
	-- | Tasklist | --

	local function matchrules(rules, exclude)
		-- Only print client on the same screen as this widget
		local exclude = exclude or false
		return function(c, screen)
			if c.screen ~= screen then return false end
			-- Include sticky client too
			if c.sticky then return false end
			local ctags = c:tags()
			for _,rule in pairs(rules) do
				if awful.rules.match(c, rule) then return not exclude end
			end
			return exclude
		end
	end

	mytasklist         = {}
	mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
			if not c:isvisible() then
				awful.tag.viewonly(c:tags()[1])
			end
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, function ()
		if instance then
			intance:hide()
			instance = nil
		else
			instance = awful.menu.clients({
				theme = { width = 250 }
			})
		end
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end))
    	return awful.widget.tasklist(screen, matchrules({{class = "Pidgin"},{class="TelegramDesktop"}}, false), mytasklist.buttons)

end

return setmetatable(tasklist, {__call = function(_,...) return worker(...) end})
