---------------------------------------------------------------------------
-- @author Ivan Balashov
-- @copyright 2016 Ivan Balashov
---------------------------------------------------------------------------

local wbase = require("wibox.widget.base")
local naughty = require("naughty")
local wconst = require("wibox.layout.constraint")
local lbase = require("wibox.layout.base")
local awful = require("awful")
local beautiful = require("beautiful")
local capi = { awesome = awesome }
local setmetatable = setmetatable
local error = error
local abs = math.abs

--- wibox.widget.suspender
local suspender = { mt = {} }

suspender.timers = {}

function suspender:add(args)
    local args = args or {}
    local timeout = args.timeout or 10
    local whitelist = args.whitelist or nil
    local blacklist = args.blacklist or {}
    local unfocus = args.unfocus or false
    local minimize = args.minimize or false
    local invisible = args.invisible or false

    client.connect_signal("manage", function(c)
        if whitelist then
            for i,k in pairs(whitelist) do
                if not c.class == k then
                    return false
                end
            end
        else
            for i,k in pairs(blacklist) do
                if c.class == k then
                    return false
                end
            end
        end
        if minimize then
            c:connect_signal("property::minimized", function(c)
                suspender.suspend(c,timeout)
            end)
        end
        if unfocus then
            c:connect_signal("unfocus", function(c)
                suspender.suspend(c,timeout)
            end)
        end
        if invisible then

        end
        c:connect_signal("focus", function(c)
            suspender.resume(c)
            awful.titlebar.hide(c)
        end)
        c:connect_signal("unmanage", function(c)
            suspender.timers[c.pid]=nil
        end)

        return true
    end)
end

function suspender.resume(c)
    if suspender.timers[c.pid] then
        suspender.timers[c.pid]:stop()
    end
    os.execute("kill -CONT "..math.floor(c.pid))
end

function suspender.suspend(c, timeout)
    suspender.timers[c.pid] = timer({ timeout = timeout })
    if c.pid then
        suspender.timers[c.pid]:connect_signal("timeout", function ()
            --naughty.notify({ preset = naughty.config.presets.critical,
            --title = c.class,
            --text = math.floor(c.pid),
        --}) 
            suspender.timers[c.pid]:stop()
            os.execute("kill -STOP "..math.floor(c.pid))
            awful.titlebar.show(c)
        end)
        suspender.timers[c.pid]:start()
    end
end


function suspender.mt:__call(...)
    return suspender:add(...)
end
local function print(s)
naughty.notify({ preset = naughty.config.presets.critical,
                     title = s,
		     bg = beautiful.bg_normal,
                     text = awesome.startup_errors,
		     position = "top_left"
	     }) 
     end

return setmetatable(suspender, suspender.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
