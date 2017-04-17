local module_path = (...):match ("(.+/)[^/]+$") or ""
local icons_dir    = require("lain.helpers").icons_dir.."cal/white/"
local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful         = require("awful")
local shell        = require("awful.util").shell
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
--local task = require("task")
local timer = require("gears").timer
local json	= require("json")
local modal_sc = require("modal_sc")
local task = require("taskwidget.task")

local taskwidget ={}
taskwidget.shortcuts = {}
taskwidget.tasks = {}
taskwidget.due = {}
taskwidget.overdue = {}
taskwidget.waiting = {}
taskwidget.uuids = {}
taskwidget.reminders_ids = {}
taskwidget.reminders = {}
taskwidget.afterupdate = {}
dbus.request_name("session", "org.naquadah.awesome.task")
dbus.add_match("session", "interface='org.naquadah.awesome.task',member='taskUpdate'")
dbus.connect_signal("org.naquadah.awesome.task",
function(...)
	local args = {...}
	local method_name = args[2]
	--print(method_name)
	local task = nil
	local timeout = nil
	local uuid = nil
	local title = nil
	if method_name == "show_task" then
		uuid = args[3]
		timeout = args[4]
	elseif method_name == "delete" or method_name == "command:delete" then
		uuid = args[3]
		--task = taskwidget.task_from_json(args[3])
		timeout = args[4]
		title = "Deleted\n"
		--taskwidget.tasks[id] = nil
		taskwidget.tasks[uuid] = nil
	elseif method_name == "add" or method_name == "command:add" then
		--task = taskwidget.task_from_json(args[3])
		uuid = args[3]
		timeout = args[4]
		title = "Added\n"
		--taskwidget.tasks[task.id] = task
	elseif method_name == "modify" or method_name == "command:modify" then
		--task = taskwidget.task_from_json(args[3])
		uuid = args[3]
		timeout = args[4]
		title = "Modified\n"
		--print(timeout)
		--print(task.id)
		--if task.id then
			--taskwidget.tasks[task.id] = task
		--else
			--task = nil
		--end
	end
	table.insert(taskwidget.afterupdate,function() taskwidget.tasks[uuid]:show()end)
	taskwidget.watch.update()
	--print(type(task))
	--taskwidget.update_tasks(taskwidget.tasks)
	--taskwidget.watch.updatewidget(taskwidget.watch.widget)
end
)

local function table_size(tab)
	local n = 0
	for i,k in pairs(tab) do
		n = n + 1
	end
	return n
end
local function prompt(str)
	--task:show(0)
	awful.prompt.run({ prompt = "Task: ", text=str or "", },
	mouse.screen.mypromptbox.widget,
	--task.promptbox[mouse.screen].widget,
	function (result)
		--task:hide()
		if result then
			--os.execute("task "..result)
			awful.util.spawn_with_shell("task "..result)
			return true
		end
		return false
	end,
	--awful.completion.shell,
	nil,
	awful.util.getdir("cache") .. "/task_history",
	nil)
end
function taskwidget.update_tasks(tasks)
	if tasks then
		--taskwidget.tasks = {}
		--taskwidget.due = {}
		--taskwidget.overdue = {}
		--taskwidget.waiting = {}
		--taskwidget.started = {}
		--taskwidget.completed = {}
		--local after = {}
		local updated = {}
		for i,t in pairs(tasks) do
			--task = taskwidget.task_from_json(task)
			t = task(t)
			local oldtask = taskwidget.tasks[t.uuid]
			if not t.id and oldtask.id then
				t.id = oldtask.id
			end
			--tasks[i] = t
			updated[t.uuid] = true
			taskwidget.tasks[t.uuid] = t
		end
		for i,t in pairs(taskwidget.tasks) do
			if not updated[t.uuid] then
				taskwidget.tasks[i] = nil
			end
		end
	end
end
function taskwidget:get_tasks()
	return taskwidget.tasks
end
function taskwidget.modal_menu(args)
	taskwidget.watch.update()
	local args = args or {}
	local tasks = args.tasks or taskwidget:get_tasks()
	local waiting = args.waiting or false

	--pr(tasks[9])
	local actions = {}
	table.insert(actions,{
		hint="a",
		desc=" ADD",
		--actions = task.modal_actions(item),
		--func = task.modal_actions(item,modal_sc),
		func = function()
			--mouse.screen.mypromptbox(" add ") 
			prompt(" add ")
		end,
	})
	local task_ids = {}
	local function add_item(item,level,last)
		local level = level or 0
		--print(i)
		if level > 0 or not task_ids[item.id] then
			local description = ""
			if level > 0 and not last then
				description = string.rep(" ",level-1).."⊢"
			elseif last then
				description = string.rep(" ",level-1).."∟"
				--description = string.rep(" ",level)
			end
			if item:is_started() then
				description = "►"..description
			else
				description = " "..description
			end
			local tags = ""
			if item["tags"] then
				tags = table.concat(item["tags"],",")
			end
			local due = ""
			if item.due then
				local date_time = todate(item.due)
				local date = todec(date_time.day).."."..todec(date_time.month).."."..todec(date_time.year)
				local time = " "..todec(date_time.hours)..":"..todec(date_time.minutes)
				due = "|"..date..time
			end
			local color = "white"
			if item:is_waiting() or item:is_overdue() then
				color = widgets.critical
			end

			table.insert(actions,{
				desc="<span color='"..color.."'>"..description..item.id..string.rep(" ",(2-math.floor(tonumber(item.id)/10)))..item["description"].."|"..tags..due.."</span>",
			--text  = "<span color='"..widgets.fg.."'>"..dues.." </span>".."<span color='"..widgets.critical.."'>"..overdues.."</span>"
				modal = true,
				actions = taskwidget.modal_actions(item),
				id = level == 0 and item.id
				--func = task.modal_actions(item,modal_sc),
				--func = function()
				--end,
			})
			if item.depends then
				local number = 0
				for _,id  in ipairs(item.depends) do 
					number = number + 1
					local task = taskwidget.tasks[id]
					task_ids[task.id] = true
					for i,k in ipairs(actions) do
						if task.id == k.id then
							table.remove(actions,i)
						end
					end
					add_item(task, level + 1, number == #(item.depends))
				end
			end
		end
	end
	for i,item in pairs(tasks) do
		local skip = false
		if not waiting then
			if taskwidget.waiting[item.id] then
				skip = true
			end
		end
		if not skip then
			add_item(item)
		end
	end
	modal_sc({
		--font="Terminus bold ",
		name="taskwarrior",
		actions=actions,
	})()
end
function taskwidget.modal_actions(item)
	--print("actions")
	--print(task["description"])
	local actions = {}
	if item:is_started() then
		table.insert(actions,{
			hint = "s",
			desc = "STOP",
			func = function()
				awful.util.spawn_with_shell("task "..item.id.." stop")
			end,
		})
	else
		table.insert(actions,{
			hint = "s",
			desc = "START",
			func = function()
				awful.util.spawn_with_shell("task "..item.id.." start")
			end,
		})
	end
	table.insert(actions,{
		hint = "m",
		desc = "MODIFY",
		func = function() 
			prompt(" "..item.id.." modify ") 
		end,
	})
	table.insert(actions,{
		hint = "c",
		desc = "ADD CHILD",
		func = function() 
			prompt(" add depends:"..item.id.." ") 
		end,
	})
	table.insert(actions,{
		hint = "p",
		desc = "ADD PARENT",
		func = function() prompt("add blocks:"..item.id.." ") 
		end,
	})
	table.insert(actions,{
		hint = "d",
		desc = "DONE",
		func = function()
			--os.execute("task "..task.id.." done")
			awful.util.spawn_with_shell("task "..item.id.." done")
		end,
	})
	table.insert(actions,{
		hint = "r",
		desc = "REMOVE",
		modal = true,
		actions = {
			{
				desc="YES",
				hint = "y",
				func = function()
					--os.execute("task "..task.id.." done")
					awful.util.spawn_with_shell("echo 'yes' | task "..item.id.." delete")
					taskwidget.tasks[item.id] = nil
				end,
			},

		}
	})
	if item.due then
		table.insert(actions,{
			hint = "w",
			desc = "SNOOZE",
			modal = true,
			actions = {
				{
					desc="15M",
					func = function()
						os.execute("task "..item.id.." modify wait:now+15M")
						--awful.util.spawn_with_shell("echo 'yes' | task "..task.id.." delete")
					end,
				},
				{
					desc="30M",
					func = function()
						os.execute("task "..item.id.." modify wait:now+30M")
						--awful.util.spawn_with_shell("echo 'yes' | task "..task.id.." delete")
					end,
				},
				{
					desc="1H",
					func = function()
						os.execute("task "..item.id.." modify wait:now+1h")
						--awful.util.spawn_with_shell("echo 'yes' | task "..task.id.." delete")
					end,
				},
				{
					desc="2H",
					func = function()
						os.execute("task "..task.id.." modify wait:now+2h")
						--awful.util.spawn_with_shell("echo 'yes' | task "..task.id.." delete")
					end,
				},
				{
					desc="5H",
					func = function()
						os.execute("task "..item.id.." modify wait:now+5h")
						--awful.util.spawn_with_shell("echo 'yes' | item "..item.id.." delete")
					end,
				},

			}
		})
	end
	return actions
end
function taskwidget.remind()
	if taskwidget.reminders.overdue.data.source_id == nil then
		taskwidget.reminders.overdue:start()
	end
	if taskwidget.reminders.due.data.source_id == nil then
		taskwidget.reminders.due:start()
	end
end
local function worker(args)
	local args = args or {}
	local cmd = args.cmd or "task status:pending or status:waiting export"
	local ICON_DIR      = awful.util.getdir("config").."/"..module_path.."/task/"
	local font          = args.font or beautiful.font
	local onclick       = args.onclick
	--due 		= args.due or task.due
	local settings	= args.settings
	taskwidget.imagebox = taskwidget.imagebox or args.imagebox or wibox.widget.imagebox()
	local images	= args.images or {def="tasksmall.png"}
	taskwidget.imagebox:set_image(ICON_DIR..images.def)
	local timeout	= args.timeout or 300

	taskwidget.reminders.overdue = timer({ timeout = 600 })
	taskwidget.reminders.overdue:connect_signal("timeout",function()
		local n = 0
		for i,task in pairs(taskwidget.tasks) do
			if task:is_overdue() then
				n = n + 1
				taskwidget.show_task(task,15)
			end
		end
		if n == 0 then
			taskwidget.reminders.due:stop()
		end
	end)
	taskwidget.reminders.due = timer({ timeout = 30 })
	taskwidget.reminders.due:connect_signal("timeout",function()
		local n = 0
		for i,task in pairs(taskwidget.tasks) do
			n = n + 1
			if task:is_due() then
				if task:is_now() then
					taskwidget.show_task(task,15)
				end
			end
		end
		if n == 0 then
			taskwidget.reminders.due:stop()
		end
	end)
	--task({
	--due="overdue",
		--timeout=1000,
	--})
	taskwidget.watch = lain.widget.watch({
		timeout = timeout,
		stoppable = true,
		cmd = { awful.util.shell, "-c", cmd },
		settings = function()
			taskwidget.update_tasks(json.decode(output))
			taskwidget.remind()
			taskwidget.watch.updatewidget(widget)
			for i,k in pairs(taskwidget.afterupdate)do
				if type(k) == "function" then
					k()
				end
			end
			taskwidget.afterupdate = {}
		end
	})
	taskwidget.watch.updatewidget = function(widget)
		local text = ""
		--local dues = table_size(taskwidget.due)
		--local overdues = table_size(taskwidget.overdue)
		local dues = 0
		local overdues = 0
		for i,k in pairs(taskwidget.tasks) do
			if k:is_due() then
				dues = dues + 1
			end
			if k:is_overdue() then
				overdues = overdues + 1
			end
		end
		if overdues > 0 then
			text  = "<span color='"..widgets.fg.."'>"..dues.." </span>".."<span color='"..widgets.critical.."'>"..overdues.."</span>"
			--text = dues.." ".."#bd6873"
		else 
			text  = "<span color='"..widgets.fg.."'>"..dues.." </span>"
		end
		widget:set_markup(text)
		--tb:set_markup('<span font="Terminus 10" weight="bold">'..textlabel..'</span>')
		--widget:set_text(table_size(taskwidget.due))
	end
	local widget = widgetcreator(
	{
		--image = "/home/ivn/.config/awesome/task/tasksmall.png"
		widgets = {taskwidget.imagebox},
		--text = "TASK",
		textboxes = {taskwidget.watch.widget}
	})
	--duetask_notification=nil
	--due_notif_destroy= function ()
		--if duetask_notification then
			--naughty.destroy(duetask_notification)
			--duetask_notification = nil
			----taskwidget:disconnect_signal('mouse::leave',due_notif_destroy)
		--end
	--end
	--due_notif_show = function()
		--duetask_notification = naughty.notify({
			----preset = fs_notification_preset,
			--text = task.get_duetask(),
			--timeout = 0,
			--screen = mouse.screen,
		--})
	--end
	--taskwidget:attach(widget,
	--{
		--onclick1=function()
			--if duetask_notification == nil then
				--due_notif_show()
			--else
				--due_notif_destroy()
			--end
			--taskwidget:connect_signal('mouse::leave',
			--function ()
				--local timer = timer({ timeout = 5 })
				--timer:connect_signal("timeout", function ()
					--due_notif_destroy()
					--timer:stop()
				--end)
				--timer:start()
			--end)
		--end,
		--onclick2=function()
			--task.prev_duetask()
			--due_notif_destroy()
			--due_notif_show()
		--end,
		--onclick3=function()
			--task.next_duetask()
			--due_notif_destroy()
			--due_notif_show()
		--end,
	--})
	return widget
end


return setmetatable(taskwidget, {__call = function(_,...) return worker(...) end})
