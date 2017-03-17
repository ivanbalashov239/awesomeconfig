require("mylib")
require("ansiDecode")

local tasklist = nil
local duetasks = nil
-- max number of tasks in duetasks widget
local duepointer = 4
-- set the screen on which the tasklist will be displayed
local screennum = 1
if screen.count() < screennum then
	screennum = 1
end

-- helper functions
function explode(separator, str)
	local pos, arr = 0, {}
	for st, sp in function() return string.find(str, separator, pos, true) end do
		table.insert(arr, string.sub(str,pos,st-1))
		pos = sp + 1
	end
	table.insert(arr,string.sub(str,pos))
	return arr
end


-- tasklist widget (required naughty)
function remove_tasklist()
  if tasklist ~= nil then
		naughty.destroy(tasklist)
		tasklist = nil
  end
end

function toggle_tasklist()
	if tasklist ~= nil then
		remove_tasklist()
	else
		add_tasklist()
	end
end

function add_tasklist()
	remove_tasklist()
	local tasks = awful.util.pread("task rc.echo.command=no rc._forcecolor=yes rc.blanklines=false rc.hooks=off ls +todo")
	tasklist = naughty.notify({
--		text = string.format('<span font_desc="%s" color="%s">%s</span>', "freemono bold 10", "#eeeeee", tasks),
		text = decodeAnsiColor(tasks),
		timeout = 0,
		screen = screennum,
		bg = theme.bg_focus,
--		width = 600,
	})
end

function refresh_tasklists(widget)
	if tasklist ~= nil then
		add_tasklist()
	end

	refresh_duetasks()
	widget.text = get_duetask()
end

-- duetasks widget
function refresh_duetasks()
	local tasks = awful.util.pread("task overdue")
	duetasks = explode("\n", tasks)
   if #duetasks >= 4 then
			duepointer = 4
	else
		duetasks = {""}
		duepointer = 1
	end
end

function get_duetask()
	if duetasks == nil then
		refresh_duetasks()
	end

	return string.format('<span color="%s"> %s </span>', "#ff3333", duetasks[duepointer])
end

function next_duetask()
	duepointer = duepointer + 1
	if duepointer > #duetasks-3 then
		duepointer = 4
	end

	return get_duetask()
end

function prev_duetask()
	duepointer = duepointer - 1
	if duepointer < 4 then
		duepointer = #duetasks-3
	end

	return get_duetask()
end
