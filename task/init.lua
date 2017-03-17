--require("mylib")
local module_path = (...):match ("(.+/)[^/]+$") or ""
local icons_dir    = require("lain.helpers").icons_dir.."cal/white/"
local read_pipe = require("lain.helpers").read_pipe
local ansiDecode = require("task.ansiDecode")
local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local json	= require("json")
dbus.request_name("session", "org.naquadah.awesome.task")
dbus.add_match("session", "interface='org.naquadah.awesome.task',member='taskUpdate'")
dbus.connect_signal("org.naquadah.awesome.task",
function(...)
	local args = {...}
	local method_name = args[2]
	if method_name == "show_task" then
		task:show_task(args[3],args[4])
	end
end
)
--method call time=1476341518.943228 sender=:1.11719 -> destination=org.naquadah.awesome.awful serial=2 path=/; interface=org.naquadah.awesome.awful.Remote; member=Eval
--
--dbus.request_name("session", "org.awesomewm.test")

---- Yup, we had a bug that made the following not work
--dbus.connect_signal("org.awesomewm.test", dbus_callback)
--dbus.disconnect_signal("org.awesomewm.test", dbus_callback)
--dbus.connect_signal("org.awesomewm.test", dbus_callback)

--for _=1, 2 do
    --awful.spawn({
        --"dbus-send",
        --"--dest=org.awesomewm.test",
        --"--type=method_call",
        --"/",
        --"org.awesomewm.test.Ping",
        --"string:foo"
    --})
--end

task = {}

local notification = nil
local duetasks = nil
local duetasks_ids = {}
local reminders = {}
local reminders_ids = {}
-- max number of tasks in duetasks widget
local duepointer = 1
-- set the screen on which the notification will be displayed
local screennum = 1
if screen.count() < screennum then
	screennum = 1
end
task.due="overdue"
local function worker(args)
    local args = args or {}

    local connected = false

    -- Settings
    local ICON_DIR      = awful.util.getdir("config").."/"..module_path.."/task/"
    local font          = args.font or beautiful.font
    local onclick       = args.onclick
    task.due 		= args.due or task.due
    local widget 	= args.widget or nil --args.widget == nil and wibox.layout.fixed.horizontal() or args.widget == false and nil or args.widget
    local indent 	= args.indent or 3
    local settings	= args.settings
    local task_icon	= args.imagebox or wibox.widget.imagebox()
    local task_text	= args.textbox or wibox.widget.textbox()
    local images	= args.images or {def="tasksmall.png"}
    local timeout	= args.timeout or false

    
    task_icon:set_image(ICON_DIR..images.def)
    task_text:set_text("N/A")
    local signal_level = 0
    task["imagebox"]	= task_icon
    task["textbox"]	= task_text
    function task:set_text(text)
	    task_text:set_text(text)
    end
    function task:set_image(image)
	    task_icon:set_image(image)
    end
    task.refresh_duetasks()
    if timeout then
	    local timer = timer({ timeout = timeout })
	    timer:connect_signal("timeout", function ()
		    task.refresh_duetasks()
	    end)
	    timer:start()
    end
    --task:set_text(#duetasks or 0)
    if widget then
	    widget:add(task_icon)
	    widget:add(task_text)
	    return widget
    end
end


-- helper functions
function task.explode(separator, str)
	local pos, arr = 0, {}
	for st, sp in function() return string.find(str, separator, pos, true) end do
		table.insert(arr, string.sub(str,pos,st-1))
		pos = sp + 1
	end
	table.insert(arr,string.sub(str,pos))
	return arr
end


function task.refresh_notifications()
	--if notification ~= nil then
		task:show(5)
	--end
	--print("refresh")


	task.refresh_duetasks()
end
function task.start_reminders()
	--task.stop_reminders()
	for i,k in pairs(duetasks_ids) do
		--table.insert(reminders,timer)
		if not reminders[k] then 
			local timer = timer({ timeout = timeout or 50 })
			--print("added "..k)
			reminders[k]=timer
			reminders[k]:connect_signal("timeout", function ()
				local item = read_pipe("task "..k.." export"):sub(2,-3)
				--print(item)
				local item = json.decode(item) or {}
				if item["status"] == "waiting" then
					return
				end
				task:show_task(item,10)
			end)
			reminders[k]:start()
		end
	end
	for i,t in pairs(reminders) do
		local old = true
		for _,k in pairs(duetasks_ids) do
			if k==i then
				old=false
			end
		end
		if old then
			--print("deleted "..i)
			t:stop()
			reminders[i]=nil
		--else
			--local item = read_pipe("task "..k.." export"):sub(2,-3)
			--local timer = timer({ timeout = timeout or 50 })
			----table.insert(reminders,timer)
			--reminders[k]=timer
			--reminders[k]:connect_signal("timeout", function ()
				--task:show_task(item,10)
			--end)
			--reminders[k]:start()
		end
	end
end
function task.stop_reminders()
	--print("delete reminders")
	for i,k in pairs(reminders) do
		k:stop()
		reminders[i]=nil
	end
end

-- duetasks widget
function task.refresh_duetasks()
	local tasks = awful.util.pread("task "..task.due.." | sed '/./!d;1d;2d;3d;$d'")
	duetasks = task.explode("\n", tasks)
	duetasks_ids = {}
	for i,k in pairs(duetasks) do
		if k == ""then
			duetasks[i]=nil
		else
			local item = task.explode(" ",k)
			--print(item[1])
			if item[1] and not (item[1] == "") and item[1]:gmatch('%d+')then
				table.insert(duetasks_ids,item[1])
				--duetasks_ids[item[1]]=item
			end
		end
	end
	task:set_text(#duetasks_ids)
	task.start_reminders()
	--print(#duetasks)
	--if #duetasks >= 4 then
		--duepointer = 4
	--else
		----duetasks = {""}
		--duepointer = 1
	--end
	--print(duetasks[duepointer])
end

function task.get_duetask()
	if duetasks == nil then
		task.refresh_duetasks()
	end
	--print(string.format('<span color="%s"> %s </span>', "#ff3333", duetasks[duepointer]))
	return string.format('<span font="terminus 20" color="%s"> %s </span>', "#ff3333", duetasks[duepointer])
end

function task.next_duetask()
	duepointer = duepointer + 1
	if duepointer > #duetasks then
		duepointer = 1
	end

	return task.get_duetask()
end

function task.prev_duetask()
	duepointer = duepointer - 1
	if duepointer < 1 then
		duepointer = #duetasks
	end

	return task.get_duetask()
end

function task:toggle()
	if not task:hide() then
		task:show()
	end
end
function task:update(t_out,cmd)
	local timer = timer({ timeout = 0.1 })
	timer:connect_signal("timeout", function ()
		task:show(t_out,cmd)
		timer:stop()
	end)
	timer:start()

end
function task:show_task_async(item,timeout)
	local timer = timer({ timeout = 0.1 })
	timer:connect_signal("timeout", function ()
		task:show_task(item,timeout)
		timer:stop()
	end)
	timer:start()
end
function task:show_task(item,timeout)
	task.refresh_duetasks()
	local function tofont(str,size,bold,font,color)
		local bold = bold
		if bold then
			bold = "bold"
		else
			bold = ""
		end
		local size = size or 15
		local font = font or "Cantarel"
		local color = color or "white"
		local text  = "<span font='"..font.." "..bold.." "..size.."' color='"..color.."'>"..str.."</span>"
		return text
	end
	local function todate(str)
		local date = tonumber(str)
		local year = math.floor(date/10000)
		local month = math.floor((date%10000)/100)
		local day = math.floor(date%100)
		return day.."."..month.."."..year,{month=month,year=year,day=day}
	end
	local function todec(num)
		if num < 10 then
			return "0"..num
		end
		return num
	end
	local function totime(str)
		local time = tonumber(str)/100
		local hours = todec(math.floor(time/100)+3)
		local minutes = todec(math.floor(time%100))
		return hours..":"..minutes
	end
	--print(item)
	if type(item) == "string" then
		item = json.decode(item) or {}
	end

	local description = item.description or ""
	local tags = item.tags or {}
	tags = table.concat(tags,",")
	--local today = tonumber(os.date('%d'))
	local notify_icon = nil

	--local title = description
	local strings={}
	if #description > 1 then
		description = description:sub(1,1):upper()..description:sub(2,-1)
	end
	if item["id"] then
		description = item["id"].." "..description
	end
	table.insert(strings,tofont(description,20,true))
	table.insert(strings,tofont(tags,15,true))
	if item["due"] then
		local sep, fields = "T", {}
		local pattern = string.format("([^%s]+)", sep)
		item["due"]:gsub(pattern, function(c) fields[#fields+1] = c end)
		local date, datet= todate(fields[1])
		table.insert(strings,tofont(date,10))
		local today = datet.day
		notify_icon = icons_dir .. today .. ".png"
		if fields[2] then
			table.insert(strings,tofont(totime(fields[2]:sub(1,-2))))
		end
	end

	local notif_id = naughty.notify({
		--		text = string.format('<span font_desc="%s" color="%s">%s</span>', "freemono bold 10", "#eeeeee", tasks),
		--text = decodeAnsiColor(tasks),
		--title  = "<span font='Terminus bold 20'>"..title.."</span>",
		--text  = "<span font='Cantarel bold 15' color='white'>"..text.."</span>",
		text = table.concat(strings,"\n"),
		timeout = timeout or 0,
		height = not notify_icon and 100 or nil,
		screen = screennum,
		bg = theme.bg_focus,
		--icon = '/usr/share/icons/Faenza/apps/96/x-office-calendar.png',
		icon = notify_icon,
		--icon_size = not notify_icon and 50 or nil,
		--		width = 600,
		replace_id = reminders_ids[item.id]
	})
	if item.id then
		reminders_ids[item.id] = notif_id
	end
	return notif_id
end

function task:show(t_out,cmd)
	local t_out = t_out or 0
	local cmd = cmd or "task rc.echo.command=no rc._forcecolor=yes rc.blanklines=false rc.hooks=off next"
	task:hide()
	task.refresh_duetasks()
	local tasks = read_pipe(cmd)
	notification = naughty.notify({
		--		text = string.format('<span font_desc="%s" color="%s">%s</span>', "freemono bold 10", "#eeeeee", tasks),
		text = decodeAnsiColor(tasks),
		timeout = t_out,
		screen = screennum,
		bg = theme.bg_focus,
		icon = '/usr/share/icons/Faenza/apps/96/x-office-calendar.png',
		--icon_size = "128",
		--		width = 600,
	})
end
function task:hide()
	if notification ~= nil then
		local res = naughty.destroy(notification)
		notification = nil
		return res
	end
	return false
end

function task:attach(widget, args)
	local args = args or {}
	local onclick1 = args.onclick1
	local onclick2 = args.onclick2
	local onclick3 = args.onclick3
	-- Bind onclick event function
	buttons = {}
	if onclick1 then
		buttons = awful.util.table.join(buttons,
		awful.button({}, 1, onclick1)
		)
	end
	if onclick2 then
		buttons = awful.util.table.join(buttons,
		awful.button({}, 2, onclick2)
		)
	end
	if onclick2 then
		buttons = awful.util.table.join(buttons,
		awful.button({}, 12, onclick2)
		)
	end
	if onclick3 then
		buttons = awful.util.table.join(buttons,
		awful.button({}, 3, onclick3)
		)
	end
	widget:buttons(buttons)
	local notif_ids = {}
	widget:connect_signal('mouse::enter', function () 
		--task:show(0) 
		for i,k in pairs(duetasks_ids) do
			if k and tonumber(k)>0 then 
				local item = read_pipe("task "..tonumber(k).." export"):sub(2,-3)
				table.insert(notif_ids,task:show_task(item,0))
			end
		end
	end)
	widget:connect_signal('mouse::leave', function () 
		--task:hide() 
		for i,k in pairs(notif_ids) do
			local res = naughty.destroy(k)
		end
	end)
end
function pr(item)
	for i,k in pairs(item) do
		if type(k) == "table"then
			print(i)
			pr(k)
		else
			print(i.." "..k)
		end

	end
end
function task.done_modify(modal_sc)
	local function todate(str)
		local date = tonumber(str)
		local year = math.floor(date/10000)
		local month = math.floor((date%10000)/100)
		local day = math.floor(date%100)
		return day.."."..month.."."..year,{month=month,year=year,day=day}
	end
	local function todec(num)
		if num < 10 then
			return "0"..num
		end
		return num
	end
	local function totime(str)
		local time = tonumber(str)/100
		local hours = todec(math.floor(time/100)+3)
		local minutes = todec(math.floor(time%100))
		return hours..":"..minutes
	end
	return function()
		local tasks = read_pipe("task next | sed '/./!d;1d;2d;3d;$d' | awk '{print $1}' | grep '[0-9]'"):gsub("\n"," ")
		task_ids = {}
		local cmd = "task "..tasks.." export"
		local tasks = json.decode(read_pipe(cmd))

		--pr(tasks[9])
		local actions = {}
		table.insert(actions,{
			hint="a",
			desc=" ADD",
			--actions = task.modal_actions(item),
			--func = task.modal_actions(item,modal_sc),
			func = function()
				task.prompt(" add ") 
			end,
		})
		for i,item in pairs(tasks) do
			--print(i)
			local description = ""
			if item["start"] then
				description = "►"..description
			else
				description = " "..description
			end
			local tags = ""
			if item["tags"] then
				tags = table.concat(item["tags"],",")
			end
			local due = ""
			if item["due"] then
				local sep, fields = "T", {}
				local pattern = string.format("([^%s]+)", sep)
				item["due"]:gsub(pattern, function(c) fields[#fields+1] = c end)
				local date, datet= todate(fields[1])
				--table.insert(strings,tofont(date,10))
				local today = datet.day
				--notify_icon = icons_dir .. today .. ".png"
				local time =""
				if fields[2] then
					--print(fields[2])
					time = "|"..totime(fields[2]:sub(1,-2))
				end
				--print({date,today,time})
				due = "|"..date..time
			end

			table.insert(actions,{
				desc=description..item.id.." "..item["description"].."|"..tags..due,
				modal = true,
				actions = task.modal_actions(item),
				--func = task.modal_actions(item,modal_sc),
				--func = function()
				--end,
			})
		end
		modal_sc({
			--font="Terminus bold ",
			name="taskwarrior",
			actions=actions,
		})()
	end
	--return function()
	--end
end
function task.modal_actions(item,modal_sc)
	--print("actions")
	--print(task["description"])
	local actions = {}
	if item["start"] then
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
			task.prompt(" "..item.id.." modify ") 
		end,
	})
	table.insert(actions,{
		hint = "c",
		desc = "ADD CHILD",
		func = function() 
			task.prompt(" add depends:"..item.id.." ") 
		end,
	})
	table.insert(actions,{
		hint = "p",
		desc = "ADD PARENT",
		func = function() task.prompt("add blocks:"..item.id.." ") 
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
					desc="30M",
					func = function()
						os.execute("task "..item.id.." modify wait:now+30m")
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
	if modal_sc then
		--return modal_sc({
		--actions = actions,
		--})
	else
		return actions
	end
end
function task.prompt(str)
	task:show(0)
	awful.prompt.run({ prompt = "Task: ", text=str or "", },
	task.promptbox[mouse.screen].widget,
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
	nil,
	function()
		task:show(5)
	end)
end

return setmetatable(task, {__call = function(_,...) return worker(...) end})
