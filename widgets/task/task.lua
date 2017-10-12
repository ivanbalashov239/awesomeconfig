local module_path = (...):match ("(.+/)[^/]+$") or ""
local icons_dir    = require("lain.helpers").icons_dir.."cal/white/"
local awful = require("awful")
--local taskwidget = require("widgets.taskwidget")
local widgetcreator = require("widgets")
local widgets = widgetcreator
local json	= require("json")
local naughty = require("naughty")

local function todec(num)
	if num < 10 then
		return "0"..num
	end
	return num
end
local function totime(str)
	local time = tonumber(str)/100
	local hours = math.floor(time/100)+3
	local minutes = math.floor(time%100)
	return {hours = hours, minutes = minutes }
end
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
	if str and type(str) == "string" then
		local sep, fields = "T", {}
		local pattern = string.format("([^%s]+)", sep)
		str:gsub(pattern, function(c) fields[#fields+1] = c end)
		local date = tonumber(fields[1])
		local year = math.floor(date/10000)
		local month = math.floor((date%10000)/100)
		local day = math.floor(date%100)
		local result =  {month=month,year=year,day=day}
		if fields[2] then
			local time = totime(fields[2]:sub(1,-2))
			result.hours = time.hours
			result.minutes = time.minutes
		end
		str = result
	end
	function str:plus(a,c)
		local c = c or 1
		local d = {}
		for i,k in pairs(str) do
			if a[i] then
				d[i]=k+c*a[i]
			end
		end
		return d
	end
	function str:minus(a)
		return str:plus(a,-1)
	end
	function str:greater(b)
		local function print_date(a,t)
			local t = t or 15
			local h  = ":"
			print(a.hours..h..a.minutes,t)
		end
		if str and b then
			--print_date(str)
			if type(b) == "string" then
				b = todate(b)
			end
			--print_date(b)
			if str.year > b.year then 
			elseif str.year == b.year and str.month > b.month then
			elseif str.year == b.year and str.month == b.month and str.day > b.day then
			elseif str.year == b.year and str.month == b.month and str.day == b.day and str.hours > b.hours then
			elseif str.year == b.year and str.month == b.month and str.day == b.day and str.hours == b.hours and str.minutes > b.minutes then
			else
				return false
			end
			return true
		end
	end
	function str:equal(b)
		if str and b then
			if str.year == b.year and str.month == b.month and str.day == b.day and str.hours == b.hours and str.minutes == b.minutes then
				return true
			end
		end
		return false
	end
	return str
end
local function now()
	return todate({
		year = tonumber(os.date("%Y")),
		month = tonumber(os.date("%m")),
		day = tonumber(os.date("%d")),
		hours = tonumber(os.date("%H")),
		minutes = tonumber(os.date("%M")),
	})
end
local function today()
	return todate({
		year = tonumber(os.date("%Y")),
		month = tonumber(os.date("%m")),
		day = tonumber(os.date("%d")),
		hours = 0,
		minutes = 0,
	})
end


local function worker(data,args)
	local task ={}

	function task:is_now()
		local min1 = now()
		local plus1 = now()
		min1.minutes = min1.minutes - 1
		plus1.minutes = plus1.minutes + 1
		--print("is_now")
		--print(min1.minutes)
		--print(plus1.minutes)
		--print(task.due.minutes)
		if task.due and task.due:greater(min1) and plus1:greater(task.due) then
			return true
		end
		return false
	end
	function task:is_due()
		if task.due and not task:is_waiting() and task.due:greater(today()) and (task.due:greater(now()) or task.due:equal(now())) then
			return true
		end
		return false
	end
	function task:is_overdue()
		if task.due and not task:is_waiting() and now():greater(task.due) then
			return true
		end
		return false
	end
	function task:is_waiting()
		if task.status == "waiting" then
			return true
		end
		return false
	end
	function task:say()
		local lang = "en"
		--if string.match(task.description,"[a-zA-Z0-9)(+-'´\",.!? ]*") == task.description then
		if #string.match(task.description,"[а-яА-Я]*")>0 then
			lang ="ru"
		end
		awful.spawn.with_shell("~/scripts/saytext.sh '"..lang.."' '"..task.description:gsub("'","´").."' fast &")
	end
	function task:is_completed()
		if task.status == "completed" then
			return true
		end
		return false
	end
	function task:is_started()
		if task.start then
			return true
		end
		return false
	end
	function task:hide()
		if task.notif_id then
			--local notif_id = task.notif_id
			--n = naughty.getById(notif_id)
			res = naughty.destroy(task.notif_id)
			if res then
				--print("remove "..task.notif_id,10)
				--task.notif_id = nil
				--task.notif_id = {id=99999999}
			end
		end
	end
	function task:show(timeout,args)
		local args = args or {} 
		local color = args.color or "white"
		local title = args.title
		local description = task.description or ""
		local tags = task.tags or {}
		for i,k in ipairs(tags) do
			if k:sub(1,1) ~= "#" then
				tags[i] = "#"..k
			end
		end
		--if task.project then
		--table.insert(tags,task.project)
		--end
		tags = table.concat(tags,", ")
		if task.project then
			--table.insert(tags,task.project)
			tags = task.project..", "..tags
		end
		--local today = tonumber(os.date('%d'))
		local notify_icon = nil

		--local title = description
		if task:is_overdue() then
			color = widgets.critical
		end
		local strings={}
		if #description > 1 then
			description = description:sub(1,1):upper()..description:sub(2,-1)
		end
		if task.id then
			description = task.id.." "..description
		end
		if title then
			--description = title:upper().." "..description
			table.insert(strings,tofont(title:upper(),22,true,nil,color))
		end
		table.insert(strings,tofont(description,20,true,nil,color))
		table.insert(strings,tofont(tags,15,true,nil,color))
		if task.due then
			local date = todate(task.due)
			table.insert(strings,tofont(date.day.."."..date.month.."."..date.year,10))
			local today = date.day
			notify_icon = icons_dir .. today .. ".png"
			if date.hours and date.minutes then
				table.insert(strings,tofont(todec(date.hours)..":"..todec(date.minutes)))
			end
		end
		--print(table.concat(strings,"\n"))
		--local notif_id = taskwidget.reminders_ids[task.uuid]
		--if notif_id then
		--naughty.destroy(task.notif_id)
		--end
		--local id = nil
		--if task["notif_id"] then
			--print(description,10)
			--print("task.notif_id"..task.notif_id,10)
			--id = task.notif_id
			----task:hide()
		--end
		--print(id,10)
		--task:hide()
		local notif_id = naughty.notify({
			--		text = string.format('<span font_desc="%s" color="%s">%s</span>', "freemono bold 10", "#eeeeee", tasks),
			--text = decodeAnsiColor(tasks),
			--title  = title and "<span font='Terminus bold 20'>"..title.."</span>" or nil,
			--title = title,
			--text  = "<span color='"..widgets.fg.."'>"..dues.." </span>"
			--title = 
			--text  = "<span font='Cantarel bold 15' color='white'>"..text.."</span>",
			text = table.concat(strings,"\n"),
			timeout = timeout or 0,
			--height = not notify_icon and 100 or nil,
			width = mouse.screen.geometry.width/4,
			screen = screennum,
			bg = theme.bg_focus,
			--fg = color,
			--icon = '/usr/share/icons/Faenza/apps/96/x-office-calendar.png',
			icon = notify_icon,
			--icon_size = not notify_icon and 50 or nil,
			--		width = 600,
			run = function()
				task:say()
			end,
			--actions = {
				--DONE = function()
					--print("test")
					----task:say()
				--end,
				--START = function()
					--print("start")
				--end,
			--},
			replaces_id = task.notif_id and task.notif_id.id
		})
		task.notif_id = notif_id
		--print("set "..task.notif_id,10)
		--task['notif_id']=notif_id
		return notif_id
	end
	if not data then
		return nil
	end
	local args = args or {}
	--local uuids = args.uuids or {}
	--print(type(data))
	if type(data) == "string" then
		data = json.decode(data)
	end
	for i,k in pairs(data) do
		--print(i)
		task[i] = k
	end
	--print("creating task "..data.uuid)
	--if not task.id and task.uuid and taskwidget.uuids[task.uuid] then
	--task.id = taskwidget.tasks[task.uuid]
	--end
	--if task.description then
		--print("_"..task.description.."_",5)
		--if string.sub(task.description,1,1) == " " then
			--print("task "..task.id)
			--task.description = string.sub(task.description,2,task.description:len())
		--end
	--end
	if task.depends and type(task.depends) == "string" then
		local deps = {}
		for w in (task.depends .. ","):gmatch("([^,]*),") do 
			--local item = uuids[w]
			table.insert(deps,w)
		end
		task.depends = deps
	end
	if task.due and type(task.due) == "string" then
		task._due_string = task.due
		task.due = todate(task.due)
	end
	if task.wait and type(task.wait) == "string" then
		task._wait_string = task.wait
		task.wait = todate(task.wait)
	end
	--print(type(task))
	return task
end

return setmetatable({}, {__call = function(_,...) return worker(...) end})
