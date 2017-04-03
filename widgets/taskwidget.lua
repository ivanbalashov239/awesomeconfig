local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
local task = require("task")
local timer = require("gears").timer

local taskwidget ={}
taskwidget.shortcuts = {}

local function worker(args)

	task({
		due="overdue",
		timeout=1000,
	})
	taskwidget = widgetcreator(
	{
		--image = "/home/ivn/.config/awesome/task/tasksmall.png"
		widgets = {task.imagebox},
		--text = "TASK",
		textboxes = {task.textbox}
	})
	duetask_notification=nil
	due_notif_destroy= function ()
		if duetask_notification then
			naughty.destroy(duetask_notification)
			duetask_notification = nil
			--taskwidget:disconnect_signal('mouse::leave',due_notif_destroy)
		end
	end
	due_notif_show = function()
		duetask_notification = naughty.notify({
			--preset = fs_notification_preset,
			text = task.get_duetask(),
			timeout = 0,
			screen = mouse.screen,
		})
	end
	task:attach(taskwidget,
	{
		onclick1=function()
			if duetask_notification == nil then
				due_notif_show()
			else
				due_notif_destroy()
			end
			taskwidget:connect_signal('mouse::leave',
			function ()
				local timer = timer({ timeout = 5 })
				timer:connect_signal("timeout", function ()
					due_notif_destroy()
					timer:stop()
				end)
				timer:start()
			end)
		end,
		onclick2=function()
			task.prev_duetask()
			due_notif_destroy()
			due_notif_show()
		end,
		onclick3=function()
			task.next_duetask()
			due_notif_destroy()
			due_notif_show()
		end,
	})
	return taskwidget
end

return setmetatable(taskwidget, {__call = function(_,...) return worker(...) end})
