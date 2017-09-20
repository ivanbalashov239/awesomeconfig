-- newtag .lua
-- fork of revelation
-- that:{
--
-- Library that implements Expose like behavior.
--
-- @author Perry Hargrave resixian@gmail.com
-- @author Espen Wiborg espenhw@grumblesmurf.org
-- @author Julien Danjou julien@danjou.info
-- @auther Quan Guo guotsuan@gmail.com
--
-- @copyright 2008 Espen Wiborg, Julien Danjou
--}
--this is Library implements Expose like menu to choose clients for new tag and create it
--with check for other tags for this combination of tags
--@copyright 2015 Ivan Balashov ivan.d.balashov@gmail.com


local beautiful    = require("beautiful")
local wibox        = require("wibox")
local awful        = require('awful')
local aw_rules     = require('awful.rules')
local pairs        = pairs
local setmetatable = setmetatable
local naughty      = require("naughty")
local table        = table
local tostring     = tostring
local widgets = require("widgets")
local capi         = {
    tag            = tag,
    client         = client,
    keygrabber     = keygrabber,
    mousegrabber   = mousegrabber,
    mouse          = mouse,
    screen         = screen
}

local modal_sc ={}
modal_sc.notification = nil

modal_sc.hints = "htnsaoeuidjkbmpgclzvw123456789"--[]{}=&*+()!#" --"jkluiopyhnmfdsatgvcewqzx1234567890"
function modal_sc.hide()
	if modal_sc.notification then
		naughty.destroy(modal_sc.notification)
		modal_sc.notification = nil
	end
end

local function worker(args)
    local args = args or {}
    local on_end = args.on_end or function() end
    local name = args.name
    local hints = args.hints or modal_sc.hints
    local actions_def = args.actions or {}
    local actions = {}
    local symbol = args.symbol or ":"
    local font = args.font or "Dejavu sans mono bold"
    local fontsize = args.fontsize or 15
    local function gethint()
	    if (#hints == 0) then
		    return false
	    end
	    local hint = hints:sub(1,1)
	    hints=string.gsub(hints,hint,"")
	    if actions[hint] then
		    return gethint()
	    else
		    return hint
	    end
    end
    local description = ""
    local descs = {}
    if name then
	    table.insert(descs,name)
    end
    for i,k in pairs(actions_def) do
	    local func
	    local hint
	    local desc
	    func = function()
		    if k.func then
			    k.func()
		    end
		    if k.modal then
			    if not k.name then
				    k["name"]=k.desc
			    end
			    k["back"] = args
			    worker(k)()
		    end
	    end
	    if type(k) == "table" then
		    --print(k.hint, 5)
		    hint = k.hint or gethint()
		    --print(hint, 5)
		    desc = k.desc or ""
	    elseif(type(k)=="function")then
		    func = k
		    hint = i
		    desc = ""
		    hints=string.gsub(hints,hint,"")
	    end
	    if hint and func and desc then
		    actions[hint:lower()]=func
		    descs[hint:lower()]=desc
		    table.insert(descs,hint:upper()..symbol..desc)
	    end
    end
    local i = 0
    description = table.concat(descs,"\n")
    if #actions_def > 0 then
	    --for _,desc in pairs(descs) do
	    --i = i + 0
	    --description = description..desc
	    --if not i == count then
	    --description = description.."\n"
	    --end
	    --end
	    --show notification
	    local function show(text, timeout)
		    modal_sc.hide()
		    local text =text or description
		    text ='<span font="'..font..' '..fontsize..'">'..text.." \n </span>"
		    modal_sc.notification = naughty.notify({
			    preset = naughty.config.presets.critical,
			    bg = beautiful.bg_normal,
			    text = text,
			    timeout = timeout or 0,
			    screen = mouse.screen or 1,
			    position = "top_left",
		    })
	    end

	    return function()
		    show()
		    local return_layout = widgets.kbdd.temporary_eng()
		    capi.keygrabber.run(function (mod, key, event)
			    --print(mod)
			    --print(key)
			    --print(event)
			    if key == " " then
				    key = "Space"
			    end
			    local keyPressed = false

			    if event == "release" then return true end
			    if key == "ISO_Level3_Shift" then
				    --print("altgr")
				    --print(mod)
				    return true
			    end
			    if key== "Escape" then
				    modal_sc.hide()
				    keygrabber.stop()
				    --return_layout()
				    on_end()
				    return_layout()
				    return
			    end
			    if key== "BackSpace" then
				    --print("backspace",10)
				    modal_sc.hide()
				    keygrabber.stop()
				    return_layout()
				    --return_layout()
				    if args.back then
					    worker(args.back)()
				    else
					    on_end()
				    end
				    return true
			    end

			    if awful.util.table.hasitem(mod, "Shift") then
				    if keyPressed then
					    keyPressed = false
				    end
			    end
			    if actions[key:lower()] then
				    modal_sc.hide()
				    keygrabber.stop()
				    return_layout()
				    actions[key:lower()]()
				    on_end()
				    --show result modal_sc.notification
				    --show(key:upper(), 2)
			    --else
				    --keygrabber.stop()
				    --return_layout()
				    --on_end()
			    end
			    --hide modal_sc.notification

		    end)
	    end
    else
	    return function()end
    end
end
return setmetatable(modal_sc, {__call = function(_,...) return worker(...) end})
