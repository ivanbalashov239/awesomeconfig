local module_path = (...):match ("(.+/)[^/]+$") or ""
local icons_dir    = require("lain.helpers").icons_dir.."cal/white/"
local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
--local awful         = require("awful")
local shell        = require("awful.util").shell
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
--local task = require("task")
local timer = require("gears").timer
local json	= require("json")
local modal_sc = require("modal_sc")
--local task = require(module_path..".task")
local task = require("widgets.task.task")

local taskwidget ={}
taskwidget.shortcuts = {}
taskwidget.tasks = {}
taskwidget.reminders = {}
taskwidget.afterupdate = {}
taskwidget.notify = true
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
	if uuid then
		local oldtask = taskwidget.tasks[uuid]
		table.insert(taskwidget.afterupdate,function()
			local newtask = taskwidget.tasks[uuid]
			local t = newtask or oldtask
			--print(t.notif_id)
			--print(oldtask.notif_id)
			t.notif_id = oldtask.notif_id
			if t and taskwidget.notify then
				t:show(timeout, {title = title})
			end
		end)
	end
	taskwidget.watch.update()
	--print(type(task))
	--taskwidget.update_tasks(taskwidget.tasks)
	--taskwidget.watch.updatewidget(taskwidget.watch.widget)
end
)
local function taskupdate()
	os.execute('/bin/dbus-send --session --dest=org.naquadah.awesome.task / org.naquadah.awesome.task.taskUpdate string:"update"')
	--print("taskupdate",10)
end
local function todec(num)
	if num < 10 then
		return "0"..num
	end
	return num
end
local function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local function table_size(tab)
	local n = 0
	for i,k in pairs(tab) do
		n = n + 1
	end
	return n
end
local function spawn(...)
	awful.util.spawn_with_shell(...)
	taskwidget.watch.update()
end
local function prompt(str)
	--task:show(0)
	awful.prompt.run({
		prompt = "Task: ",
		text=str or "",
		exe_callback = function (result)
			--task:hide()
			if result then
				--os.execute("task "..result)
				spawn("task "..result)
				return true
			end
			return false
		end,
		history_path = awful.util.getdir("cache") .. "/task_history",
	},
	mouse.screen.mypromptbox.widget
	--task.promptbox[mouse.screen].widget,
	)
end
function taskwidget.update_tasks(tasks)
	--print("update")
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
			--t = taskwidget.task_from_json(t)
			--print(t == "")
			--print(i)
			--print(t)
			if t then
				t = task(t)
				if t and t.uuid then
					local oldtask = taskwidget.tasks[t.uuid]
					if oldtask then
						t.notif_id = oldtask.notif_id
					end
					if oldtask and not t.id and oldtask.id then
						t.id = oldtask.id
					end
					if taskwidget.notify then
						if oldtask and (oldtask.status or t.status) then
							--print("status",5)
							if not oldtask.status or not t.status or not (oldtask.status == t.status) then
								t:show(15)
							end
							if not (oldtask:is_overdue() == t:is_overdue()) then
								t:show(15)
								t:say()
							end
						end
					end
					--tasks[i] = t
					--
					--print(t.uuid)
					--updated[t.uuid] = true
					updated[t.uuid] = t
				end
			end
		end
		taskwidget.tasks = updated
		--print("updated tasks")
		--for i,t in pairs(taskwidget.tasks) do
			--if not updated[t.uuid] then
				--taskwidget.tasks[t.uuid] = nil
			--end
		--end
		if taskwidget.modal then
			taskwidget.modal_menu(taskwidget.modal)
		end
	end
end
function taskwidget:get_tasks()
	return taskwidget.tasks
end
function taskwidget:toggle()
	taskwidget.notify = not taskwidget.notify
	if taskwidget.notify then
		taskwidget.imagebox:set_image(taskwidget.images.def)
	else
		taskwidget.imagebox:set_image(taskwidget.images.red)
	end
end
function taskwidget.modal_menu(args)
	taskwidget.watch.update()
	local args = args or {}
	local tasks = args.tasks or taskwidget:get_tasks()
	local show_projects = args.projects or "yes"
	local ret_actions = args.ret_actions
	local add_preset = args.add_preset or ""
	local filter = args.filter or function(task)
		if task:is_waiting() then
			return false
		end
		if task.due then
			return task:is_due() or task:is_overdue()
		end
		return true
	end

	--pr(tasks[9])
	local actions = {}
	table.insert(actions,{
		hint="a",
		desc=" ADD",
		--actions = task.modal_actions(item),
		--func = task.modal_actions(item,modal_sc),
		func = function()
			--mouse.screen.mypromptbox(" add ") 
			prompt(" add "..add_preset.." ")
		end,
	})
	local notif_desc = ""
	if taskwidget.notify then
		notif_desc = " Disable Notification"
	else
		notif_desc = " Enable Notification"
	end
	table.insert(actions,{
		hint = "@",
		desc = notif_desc,
		--modal = true,
		func = function()
			taskwidget:toggle()
		end,
	})
	local task_ids = {}
	local function add_item(item,level,last)
		if not item then
			return
		end
		local level = level or 0
		--print(item.id,15)
		if level > 0 or not task_ids[item.uuid] then
			--print("added",15)
			local description = ""
			if level > 0 and not last then
				description = string.rep(" ",level-1+2).."⊢"
			elseif last then
				description = string.rep(" ",level-1+2).."∟"
				--description = string.rep(" ",level)
			end
			if item:is_started() then
				description = "►"..description
			else
				description = " "..description
			end
			local tags = ""
			--local tags = task.tags or {}
			if item.tags then
				for i,k in ipairs(item.tags) do
					if k:sub(1,1) ~= "#" then
						item.tags[i] = "#"..k
					end
				end
				tags = table.concat(item["tags"],",")
			end
			local due = ""
			if item.due then
				local date_time = item.due
				local date = todec(date_time.day).."."..todec(date_time.month).."."..todec(date_time.year)
				local time = " "..todec(date_time.hours)..":"..todec(date_time.minutes)
				due = "|"..date..time
			end
			local color = "white"
			if item:is_waiting() then
				color = widgets.task_waiting
			elseif item:is_overdue() then
				color = widgets.critical
			elseif item.due then
				color = widgets.green
			end

			table.insert(actions,{
				desc="<span color='"..color.."'>"..description..item.id..string.rep(" ",(3-math.floor(tostring(item.id):len())))..item["description"].."|"..tags..due.."</span>",
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
					--task_ids[task.uuid] = true
					--if task then
						--task_ids[task.uuid] = true
					--end
					--for i,k in ipairs(actions) do
						--if task.id == k.id then
							--table.remove(actions,i)
						--end
					--end
					add_item(task, level + 1, number == #(item.depends))
				end
			end
		end
	end
	local sorted_tasks = {}
	local projects = {}
	for i,item in pairs(tasks) do
		table.insert(sorted_tasks,item)
		if item.project and show_projects == "yes" then
			if projects[item.project] then
				table.insert(projects[item.project],item)
			else
				projects[item.project] = {item}
			end
			task_ids[item.uuid] = true
		end
		if item.depends then
			--local number = 0
			for _,id  in ipairs(item.depends) do 
				--number = number + 1
				local task = taskwidget.tasks[id]
				if task then
					task_ids[task.uuid] = true
				end
				--for i,k in ipairs(actions) do
					--if task.id == k.id then
						--table.remove(actions,i)
					--end
				--end
				--add_item(task, level + 1, number == #(item.depends))
			end
		end
	end
	table.sort(sorted_tasks,function(a,b)
		--print("sort")
		if a.due and b.due then
			return b.due:greater(a.due)
		elseif a.due and not b.due then
			return true
		elseif not a.due and b.due then
			return false
		else
			if a.id and b.id then
				--print(a.id.." * "..b.id,1)
				return a.id < b.id
			end
			return a.due
		end
		return false
	end)
	for i,item in pairs(sorted_tasks) do
		--print(item.id,15)
		local skip = not filter(item)
		if not skip then
			add_item(item)
		end
	end
	for project, tasks in pairs(projects) do

		local active_tasks = {}
		for _,item in pairs(tasks) do
			local skip = not filter(item)
			if not skip then
				table.insert(active_tasks,item)
			end
		end
		if #active_tasks > 0 then
			local args = args
			args.filter = function(task)
				if task.project and task.project == project then
					return true
				else
					return false
				end
			end
			args.projects = "no"
			args.ret_actions = true
			args.add_preset = "project:"..project
			local acts = taskwidget.modal_menu(args)
			table.insert(actions,{
				desc=firstToUpper(project),
				modal = true,
				actions = acts,

			})
		end
		for _,item in pairs(active_tasks) do
			add_item(item,1)
		end
	end
	if ret_actions then
		return actions
	else
		taskwidget.modal = args
		modal_sc.update({
			--font="Terminus bold ",
			name="taskwarrior",
			actions=actions,
			on_end=function()
				taskwidget.modal=false
				taskwidget.watch.update()
			end,
		})()
	end
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
				spawn("task "..item.id.." stop")
			end,
		})
	else
		table.insert(actions,{
			hint = "s",
			desc = "START",
			func = function()
				spawn("task "..item.id.." start")
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
			prompt("add blocks:"..item.id.." ") 
		end,
	})
	table.insert(actions,{
		hint = "p",
		desc = "ADD PARENT",
		func = function() 
			prompt(" add depends:"..item.id.." ") 
		end,
	})
	table.insert(actions,{
		hint = "d",
		desc = "DONE",
		func = function()
			--spawn("task "..task.id.." done")
			spawn("task uuid:"..item.uuid.." done")
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
					--spawn("task "..task.id.." done")
					spawn("echo 'yes' | task "..item.id.." delete")
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
						spawn("task "..item.id.." modify wait:now+15M")
						--spawn("echo 'yes' | task "..task.id.." delete")
					end,
				},
				{
					desc="30M",
					func = function()
						spawn("task "..item.id.." modify wait:now+30M")
						--spawn("echo 'yes' | task "..task.id.." delete")
					end,
				},
				{
					desc="1H",
					func = function()
						spawn("task "..item.id.." modify wait:now+1h")
						--spawn("echo 'yes' | task "..task.id.." delete")
					end,
				},
				{
					desc="2H",
					func = function()
						spawn("task "..item.id.." modify wait:now+2h")
						--spawn("echo 'yes' | task "..task.id.." delete")
					end,
				},
				{
					desc="5H",
					func = function()
						spawn("task "..item.id.." modify wait:now+5h")
						--spawn("echo 'yes' | item "..item.id.." delete")
					end,
				},
				{
					desc="8H",
					func = function()
						spawn("task "..item.id.." modify wait:now+8h")
						--spawn("echo 'yes' | item "..item.id.." delete")
					end,
				},
				{
					desc="12H",
					func = function()
						spawn("task "..item.id.." modify wait:now+12h")
						--spawn("echo 'yes' | item "..item.id.." delete")
					end,
				},
				{
					desc="1d",
					func = function()
						spawn("task "..item.id.." modify wait:now+24h")
						--spawn("echo 'yes' | item "..item.id.." delete")
					end,
				},
				{
					desc="1.5d",
					func = function()
						spawn("task "..item.id.." modify wait:now+36h")
						--spawn("echo 'yes' | item "..item.id.." delete")
					end,
				},
				{
					desc="2d",
					func = function()
						spawn("task "..item.id.." modify wait:now+48h")
						--spawn("echo 'yes' | item "..item.id.." delete")
					end,
				},

			}
		})
	end
	table.insert(actions,{
		hint = "h",
		desc = "SHOW",
		--modal = true,
		func = function()
			item:show(5)
		end,
	})
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
	local images	= args.images or {def="tasksmall.png",red="tasksmall-red.png"}
	taskwidget.images = {}
	for i,k in pairs(images) do
		taskwidget.images[i]=ICON_DIR..k
	end
	taskwidget.imagebox:set_image(taskwidget.images.def)
	local timeout	= args.timeout or 60

	taskwidget.reminders.overdue = timer({ timeout = 600 })
	taskwidget.reminders.overdue:connect_signal("timeout",function()
		local n = 0
		for i,task in pairs(taskwidget.tasks) do
			if task:is_overdue() then
				n = n + 1
				--taskwidget.show_task(task,15)
				--
				if taskwidget.notify then
					task:show(15)
				end
			end
		end
		if n == 0 then
			taskwidget.reminders.overdue:stop()
		end
	end)
	taskwidget.reminders.due = timer({ timeout = 60 })
	taskwidget.reminders.due:connect_signal("timeout",function()
		--print("due reminder")
		local n = 0
		for i,task in pairs(taskwidget.tasks) do
			n = n + 1
			if task:is_due() then
				--print("due")
				if task:is_now() then
					--taskwidget.show_task(task,15)
					--print("now")
					if taskwidget.notify then
						task:say()
						task:show(15)
						taskwidget.watch.update()
					end
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
			--print("settings")
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
				--print(i.." "..k.description)
				overdues = overdues + 1
			end
		end
		if overdues > 0 then
			text  = "<span color='"..widgets.fg.."'>"..dues.." </span>".."<span color='"..widgets.critical.."'>"..overdues.."</span>"
			--text = dues.." ".."#bd6873"
		else 
			text  = "<span color='"..widgets.fg.."'>"..dues.."</span>"
		end
		--print("module_path "..module_path)
		--print("text widget")
		--widget:set_markup(text)
		widgets.set_markup(widget,text)
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
	widget:connect_signal('mouse::enter', function () 
		--print("show reminders")
		for i,task in pairs(taskwidget.tasks) do
			if task:is_due() or task:is_overdue() then
				--if task:is_now() then
					----taskwidget.show_task(task,15)
					--task:show(15)
				--end
				task:show(0)
			end
		end
	end)
	widget:connect_signal('mouse::leave', function () 
		--print("hide reminders")
		for i,task in pairs(taskwidget.tasks) do
			if task:is_due() or task:is_overdue() then
				task:hide()
			end
		end
	end)
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
