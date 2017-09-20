---------------------------------------------------------------------------
-- @author Ivan Balashov
-- @copyright 2015 Ivan Balashov
---------------------------------------------------------------------------

--local wbase = require("wibox.widget.base")
local naughty = require("naughty")
--local wconst = require("wibox.layout.constraint")
--local lbase = require("wibox.layout.base")
--local awfwibox = require("awful.wibox")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears      = require("gears")
timer = gears.timer
local systray	 = require("wibox.widget.systray")
local capi = { awesome = awesome }
local setmetatable = setmetatable
local error = error
local abs = math.abs

--- wibox.widget.hidetray
local hidetray = { mt = {} }

hidetray.table = {}

function hidetray:show(s)
    --print("show")
    if hidetray.hidetimer.data.source_id ~= nil then
        hidetray.hidetimer:stop()
    end
    --hidetray.hidetimer:stop()
    hidetray.tray:set_screen(s)
    hidetray.tray.visible = true
    if hidetray.on_show then
        hidetray.on_show(s)
    end
    --for i,k in pairs(hidetray.table) do
        --if not i == s then
            --hidetray:hide(i)
        --else
            ----hidetray.traybufer:set_widget(nil)
            --hidetray.table[s]:set_widget(hidetray.tray)
        --end
    --end
end
function hidetray:hide(s)
    hidetray.tray.visible = false
    if hidetray.on_hide then
        hidetray.on_hide(s)
    end
    --print("hide")
    --hidetray.traybufer:set_widget(hidetray.tray)
    --hidetray.table[s]:reset()
end

function hidetray:attach(args)
    local args = args or {}
    local wib = args.wibox
    local revers = args.revers
    local s = args.screen or screen.primary
    if wib then
        wib:connect_signal('mouse::enter', function () 
            hidetray:show(s)
        end)
        wib:connect_signal('mouse::leave', function ()
            if (mouse.object_under_pointer() and mouse.object_under_pointer().name ) or mouse.screen ~= s then 
                hidetray:hide(s)
            else
                if hidetray.hidetimer.data.source_id == nil then
                    hidetray.hidetimer:start()
                end
            end
        end)
    end
end

local function worker(args)
    local args = args or {}
    --local number = args.number or screen.count()
    --local backgr = args.background or wconst
    local gettimerscreen = args.focusscreen or function() return mouse.screen end
    if not hidetray.textbox then
        hidetray.textbox = wibox.widget.textbox(0)
    end
    --hidetray.traybufer = args.traybufer or awfwibox({ x = -55, y = -55})
    hidetray.hidetimer = timer({ timeout = args.timeout or 5 })
    hidetray.hidetimer:connect_signal("timeout", function ()
        --for s = 1, number do
        hidetray:hide()
        --end
        if hidetray.hidetimer.data.source_id ~= nil then
            hidetray.hidetimer:stop()
        end
    end)
    if not hidetray.tray then
        hidetray.tray = systray(args.revers)
        awesome.connect_signal("systray::update", function()
            local num_entries = awesome.systray()
            hidetray.textbox:set_text(tostring(num_entries))
            --print(num_entries)
            hidetray:show(gettimerscreen())
            if hidetray.hidetimer.data.source_id == nil then
                hidetray.hidetimer:start()
            end
        end)
    end
    if args.container then
        args.container:add(hidetray.textbox)
        args.container:add(hidetray.tray)
    else
        return hidetray
    end
    --return hidetray.table
end

function hidetray.mt:__call(...)
    return worker(...)
end
local function print(s)
naughty.notify({ preset = naughty.config.presets.critical,
                     title = s,
		     bg = beautiful.bg_normal,
                     text = awesome.startup_errors,
		     position = "top_left"
	     }) 
     end

return setmetatable(hidetray, hidetray.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
