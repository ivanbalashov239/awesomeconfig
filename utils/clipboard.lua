local setmetatable = setmetatable
local os = os
local awful = require("awful")
local gears = require("gears")
local modal_sc = require("modal_sc")      
local utils = require("utils")
local timer = gears.timer

local clipboard = {}
--cliboard.current = 
clipboard.history = {}
clipboard.map = {}
clipboard.size = 25
local function resort()
	table.sort(clipboard.history,function(a,b)
		local ma = clipboard.map[a]
		local mb = clipboard.map[b]
		if ma and mb then
			return  ma > mb
		elseif ma then
			return true
		else
			return false
		end
	end)
	if #(clipboard.history) > clipboard.size then
		local history = {}
		local map = {}
		for i=1,clipboard.size do
			local k = clipboard.history[i]
			history[i] = k
			map[k] = clipboard.map[k]
		end
		clipboard.history = history
		clipboard.map = map
	end
end
local function insert(new)
	if new and not (new == "") then
		if not clipboard.map[new] then
			table.insert(clipboard.history,new)
			resort()
		end
		clipboard.map[new] = os.time()
		clipboard.last = new
	end
end
clipboard.timer = timer({ timeout = 0.5 })
clipboard.timer:connect_signal("timeout", function()
	awful.spawn.easy_async({"xclip","-selection","clipboard","-o","-rmlastnl"},function(output,err)
		if output then
			--local output = string.gsub(output,"\n\n$","\n")
			if clipboard.current then
				if clipboard.current == output and not (clipboard.last == output) then
					insert(output)
				end
			end
			clipboard.current = output
		end

	end)
end)
function clipboard.start_polling()
	if clipboard.timer.data.source_id == nil then
		clipboard.timer:start()
	end
end
function clipboard.stop_polling()
	if clipboard.timer.data.source_id ~= nil then
		clipboard.timer:stop()
	end
end
clipboard.start_polling()
local function worker(args)
	local args = args or {}
end
function clipboard.menu(args)
	local args = args or {}
	local cut = args.cut or 80
	local dots = args.dots or true
	local modal = args.modal or false
	local action = args.action or function(clip)
		local clip = string.gsub(clip,'"','\\"')
		awful.spawn.with_shell("echo \""..clip.."\" | xclip -selection clipboard")
	end
	local actions = {}
	resort()
	local history = clipboard.history
	--for i=0,#history-1 do
		--local k = history[#history-i]
	for i,k in ipairs(history) do
		if modal then
			table.insert(actions,{
				desc = utils.to_n(k,cut,dots,true).."\n",
				modal = true,
				actions = action,
			})
		else
			table.insert(actions,{
				desc = utils.to_n(k,cut,dots,true).."\n",
				func = function()
					action(k)
				end
			})
		end
	end
	modal_sc({
		name = "Clipboard menu",
		actions = actions,

	})()
end
return setmetatable(clipboard, { __call = function(_,...) return worker(...) end})
