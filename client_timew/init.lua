--require("mylib")
local module_path = (...):match ("(.+/)[^/]+$") or ""
local read_pipe = require("lain.helpers").read_pipe
--local ansiDecode = require("task.ansiDecode")
local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
client_timew = {}

local function worker(args)
    local args = args or {}

    local connected = false
    local timew = "TIMEWARRIORDB="..awful.util.getdir("config")..module_path.."/.timewarrior timew :quiet "

    -- Settings
    --local ICON_DIR      = awful.util.getdir("config").."/"..module_path.."/client_timew/"
    --local font          = args.font or beautiful.font
    --local onclick       = args.onclick
    --client_timew.due 		= args.due or client_timew.due
    --local widget 	= args.widget or nil --args.widget == nil and wibox.layout.fixed.horizontal() or args.widget == false and nil or args.widget
    --local indent 	= args.indent or 3
    --local settings	= args.settings
    --local client_timew_icon	= args.imagebox or wibox.widget.imagebox()
    --local client_timew_text	= args.textbox or wibox.widget.textbox()
    --local images	= args.images or {def="client_timewsmall.png"}
    --local timeout	= args.timeout or false

    --client.connect_signal("focus", function(c) 
	    --os.execute("timew start software "..c.class)
    --end)
    --client.connect_signal("unfocus", function(c) 
	    --os.execute("timew stop software "..c.class)
    --end)
    client.connect_signal("manage", function(c) 
	    c:connect_signal("focus", function(cl)
		    print(timew.." start "..c.class)
		    os.execute(timew.." start "..c.class)
	    end)
	    c:connect_signal("focus", function(cl)
		    print(timew.." stop "..c.class)
		    os.execute(timew.." stop "..c.class)
	    end)
    end)
end

return setmetatable(client_timew, {__call = function(_,...) return worker(...) end})
