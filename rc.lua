local gears      = require("gears")
local awful      = require("awful")
awful.rules      = require("awful.rules")
--                   require("awful.autofocus")
                  require("sharetags")
local APW = require("apw/widget")
local wibox      = require("wibox")
local beautiful  = require("beautiful")
local vicious    = require("vicious")
local naughty    = require("naughty")
local lain       = require("lain")
local drop       = require("scratchdrop")
local cyclefocus = require('cyclefocus')
local revelation = require("revelation")      
local quake 	 = require("quake")
local scratch	 = require("scratch")
local utf8 	 = require("utf8_simple")


-- | Theme | --

local theme = "pro-gotham"

beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/theme.lua")


revelation.init()
-- | Error handling | --

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- | Fix's | --

   --APWTimer = timer({ timeout = 1 }) -- set update interval in s
   --APWTimer:connect_signal("timeout", APW.Update)
  -- APWTimer:start()

-- Disable cursor animation:

local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end

-- change notify defaults

--naughty.config.defaults({
  --                      screen = client.focus and client.focus.screen or 1
    --                })


-- Java GUI's fix:

awful.util.spawn_with_shell("wmname LG3D")

-- | Variable definitions | --

local home   = os.getenv("HOME")
local exec   = function (s) oldspawn(s, false) end
local shexec = awful.util.spawn_with_shell

modkey        = "Mod4"
altkey        = "Mod1"
terminal      = "termite"
dropdownterm  = "termite -r DROPDOWN"
tmux          = "termite -e tmux"
termax        = "termite --geometry 1680x1034+0+22"
htop_cpu      = "termite -e 'htop -s PERCENT_CPU' -r HTOP_CPU"
htop_mem      = "termite -e 'htop -s PERCENT_MEM' -r HTOP_MEM"
rootterm      = "sudo -i termite"
ncmpcpp       = "urxvt -geometry 254x60+80+60 -e ncmpcpp"
newsbeuter    = "urxvt -g 210x50+50+50 -e newsbeuter"
browser       = "firefox"
filemanager   = "spacefm"
xautolock     = "xautolock -locker slimlock -nowlocker slimlock -time 5 &"
configuration = termax .. ' -e "vim -O $HOME/.config/awesome/rc.lua $HOME/.config/awesome/themes/' ..theme.. '/theme.lua"'

-- | Table of layouts | --

local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating
}

-- | Wallpaper | --

if beautiful.wallpaper then
    for s = 1, screen.count() do
        -- gears.wallpaper.tiled(beautiful.wallpaper, s)
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- | Tags | --

tags = {}
for s = 1, screen.count() do
    tags[s] = awful.tag({ "TERM", "CODE", "IM", "MAIL", "WEB" }, s, layouts[1])
end

for s = 1, screen.count() do 
--  tags[s] = awful.tag(tags.names, s, tags.layout)
  awful.tag.setncol(3, tags[s][3])                         -- эта и следующая строчка нужна для Pidgin
  awful.tag.setproperty(tags[s][3], "mwfact", 0.15)        -- здесь мы устанавливаем ширину списка контактов в 20% от ширины экрана
end


-- | Menu | --

menu_main = {
  { "lock",    "xautolock -locknow"       },
  { "suspend", "systemctl suspend" },
  { "poweroff",  "systemctl poweroff"},
  { "restart",   awesome.restart     },
  { "reboot",    "reboot"       },
  { "quit",      awesome.quit        }}

mainmenu = awful.menu({ items = {
  { " awesome",       menu_main   },
  { " file manager",  filemanager },
  { " root terminal", rootterm    },
  { " user terminal", terminal    }}})

-- | Markup | --

markup = lain.util.markup

space3 = markup.font("Terminus 3", " ")
space2 = markup.font("Terminus 2", " ")
vspace1 = '<span font="Terminus 3"> </span>'
vspace2 = '<span font="Terminus 3">  </span>'
clockgf = beautiful.clockgf

-- | Widgets | --

spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr4px = wibox.widget.imagebox()
spr4px:set_image(beautiful.spr4px)
spr5px = wibox.widget.imagebox()
spr5px:set_image(beautiful.spr5px)

widget_display = wibox.widget.imagebox()
widget_display:set_image(beautiful.widget_display)
widget_display_r = wibox.widget.imagebox()
widget_display_r:set_image(beautiful.widget_display_r)
widget_display_l = wibox.widget.imagebox()
widget_display_l:set_image(beautiful.widget_display_l)
widget_display_c = wibox.widget.imagebox()
widget_display_c:set_image(beautiful.widget_display_c)

-- | MPD | --

prev_icon = wibox.widget.imagebox()
prev_icon:set_image(beautiful.mpd_prev)
next_icon = wibox.widget.imagebox()
next_icon:set_image(beautiful.mpd_nex)
stop_icon = wibox.widget.imagebox()
stop_icon:set_image(beautiful.mpd_stop)
pause_icon = wibox.widget.imagebox()
pause_icon:set_image(beautiful.mpd_pause)
play_pause_icon = wibox.widget.imagebox()
play_pause_icon:set_image(beautiful.mpd_play)
mpd_sepl = wibox.widget.imagebox()
mpd_sepl:set_image(beautiful.mpd_sepl)
mpd_sepr = wibox.widget.imagebox()
mpd_sepr:set_image(beautiful.mpd_sepr)

mpdwidget = lain.widgets.mpd({
    settings = function ()
        if mpd_now.state == "play" then
	    widget:set_markup(" Title loading ")
            mpd_now.artist = mpd_now.artist:upper():gsub("&.-;", string.lower)
            mpd_now.title = mpd_now.title:upper():gsub("&.-;", string.lower)
--	    nowplayingtext = markup.font("Tamsyn 3", " ")
--                              .. markup.font("Tamsyn 7",
--                              mpd_now.artist
--                              .. " - " ..
--                              mpd_now.title
--                              .. markup.font("Tamsyn 2", " "))
            nowplayingtext = mpd_now.artist.." "..mpd_now.title
	    nowplayingtext = utf8.sub(nowplayingtext, 0, 35)
	    --nowplayingtext = string.reverse(nowplayingtext)
	    --print(nowplayingtext)
            widget:set_markup(nowplayingtext)
	    
            play_pause_icon:set_image(beautiful.mpd_pause)
            mpd_sepl:set_image(beautiful.mpd_sepl)
            mpd_sepr:set_image(beautiful.mpd_sepr)
        elseif mpd_now.state == "pause" then
            widget:set_markup(markup.font("Tamsyn 4", "") ..
                              markup.font("Tamsyn 7", "MPD PAUSED") ..
                              markup.font("Tamsyn 10", ""))
            play_pause_icon:set_image(beautiful.mpd_play)
            mpd_sepl:set_image(beautiful.mpd_sepl)
            mpd_sepr:set_image(beautiful.mpd_sepr)
        else
            widget:set_markup("")
            play_pause_icon:set_image(beautiful.mpd_play)
            mpd_sepl:set_image(nil)
            mpd_sepr:set_image(nil)
        end
    end
})

function mpd_prev()
    awful.util.spawn_with_shell("mpc prev & ")
    mpdwidget.update()
end
function mpd_next()
    awful.util.spawn_with_shell("mpc next & ")
    mpdwidget.update()
end
function mpd_stop()
    play_pause_icon:set_image(beautiful.play)
    awful.util.spawn_with_shell("mpc stop & ")
    mpdwidget.update()
end
function mpd_play_pause()
    awful.util.spawn_with_shell("mpc toggle & ")
    mpdwidget.update()
end
function mpd_play()
    awful.util.spawn_with_shell("mpc play & ")
    mpdwidget.update()
end
function mpd_pause()
    awful.util.spawn_with_shell("mpc pause & ")
    mpdwidget.update()
end
musicwidget = wibox.widget.background()
musicwidget:set_widget(mpdwidget)
musicwidget:set_bgimage(beautiful.widget_display)
musicwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(cantata) end)))

prev_icon:buttons(awful.util.table.join(awful.button({}, 1,
function () 
	mpd_prev() 
end)))
next_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
	mpd_next()
end)))
stop_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
	mpd_stop()
end)))
play_pause_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
	mpd_play_pause()
end)))

-- Pusleaudio controll --

pulseBar = APW
pulseBox = pulseBar.getTextBox()
pulsewidget = wibox.widget.background()
pulsewidget:set_widget(pulseBox)
pulsewidget:set_bgimage(beautiful.widget_display)


-- Keyboard map indicator and changer
	kbdtext = wibox.widget.textbox("en")
	kbdwidget = wibox.widget.background(kbdtext, "#0E1318")
	kbdstrings = {[0] = "en",
		      [1] = "ru" 
	      	      }
	dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function(...)
local data = {...}
local layout = data[2]
kbdtext:set_markup(kbdstrings[layout])
end
)
kbdwidget:set_bgimage(beautiful.widget_display)

-- -- {{{ Menu
-- freedesktop.utils.terminal = terminal
-- menu_items = freedesktop.menu.new()
-- myawesomemenu = {
--    { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
--    { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
--    { "edit theme", editor_cmd .. " " .. awful.util.getdir("config") .. "/themes/cesious/theme.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
--    { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
--    { "quit", "oblogout", freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
-- }
-- table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
-- table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })
-- mymainmenu = awful.menu({ items = menu_items, theme = { width = 150 } })
-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- | Mail | --

mail_widget = wibox.widget.textbox()
vicious.register(mail_widget, vicious.widgets.gmail, vspace1 .. "${count}" .. vspace1, 1200)

widget_mail = wibox.widget.imagebox()
widget_mail:set_image(beautiful.widget_mail)
mailwidget = wibox.widget.background()
mailwidget:set_widget(mail_widget)
mailwidget:set_bgimage(beautiful.widget_display)

-- | CPU / TMP | --

cpu_widget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(space3 .. cpu_now.usage .. "%" .. markup.font("Tamsyn 4", " "))
    end
})

cpubuttons = awful.util.table.join(awful.button({ }, 1,
function () run_or_kill(htop_cpu, { role = "HTOP_CPU" }) end))

widget_cpu = wibox.widget.imagebox()
widget_cpu:set_image(beautiful.widget_cpu)
cpuwidget = wibox.widget.background()
cpuwidget:set_widget(cpu_widget)
cpuwidget:set_bgimage(beautiful.widget_display)


 tmp_widget = wibox.widget.textbox()
 vicious.register(tmp_widget, vicious.widgets.thermal, vspace1 .. "$1°C" .. vspace1, 9, "thermal_zone0")

 widget_tmp = wibox.widget.imagebox()
 widget_tmp:set_image(beautiful.widget_tmp)
 tmpwidget = wibox.widget.background()
 tmpwidget:set_widget(tmp_widget)
 tmpwidget:set_bgimage(beautiful.widget_display)

 tmpwidget:buttons(cpubuttons)
 widget_cpu:buttons(cpubuttons)
 cpuwidget:buttons(cpubuttons)

-- | MEM | --


membuttons = awful.util.table.join(awful.button({ }, 1,
function () run_or_kill(htop_mem, { role = "HTOP_MEM" }) end))

mem_widget = lain.widgets.mem({
    settings = function()
        widget:set_markup(space3 .. mem_now.used .. "MB" .. markup.font("Tamsyn 4", " "))
    end
})

widget_mem = wibox.widget.imagebox()
widget_mem:set_image(beautiful.widget_mem)
memwidget = wibox.widget.background()
memwidget:set_widget(mem_widget)
memwidget:set_bgimage(beautiful.widget_display)

memp_widget = lain.widgets.mem({
    settings = function()
        widget:set_markup(space3 .. math.ceil(mem_now.used/mem_now.total*100, 0, 3) .. "%" .. markup.font("Tamsyn 4", " "))
    end
})

mempwidget = wibox.widget.background()
mempwidget:set_widget(memp_widget)
mempwidget:set_bgimage(beautiful.widget_display)

 memp_widget:buttons(membuttons)
 widget_mem:buttons(membuttons)
 memwidget:buttons(membuttons)

-- | FS | --

fs_widget = wibox.widget.textbox()
vicious.register(fs_widget, vicious.widgets.fs, vspace1 .. "${/ avail_gb}GB" .. vspace1, 2)

widget_fs = wibox.widget.imagebox()
widget_fs:set_image(beautiful.widget_fs)
fswidget = wibox.widget.background()
fswidget:set_widget(fs_widget)
fswidget:set_bgimage(beautiful.widget_display)

-- | NET | --

net_widgetdl = wibox.widget.textbox()
net_widgetul = lain.widgets.net({
    settings = function()
        widget:set_markup(markup.font("Tamsyn 1", "  ") .. net_now.sent)
        net_widgetdl:set_markup(markup.font("Tamsyn 1", " ") .. net_now.received .. markup.font("Tamsyn 1", " "))
    end
})

widget_netdl = wibox.widget.imagebox()
widget_netdl:set_image(beautiful.widget_netdl)
netwidgetdl = wibox.widget.background()
netwidgetdl:set_widget(net_widgetdl)
netwidgetdl:set_bgimage(beautiful.widget_display)

widget_netul = wibox.widget.imagebox()
widget_netul:set_image(beautiful.widget_netul)
netwidgetul = wibox.widget.background()
netwidgetul:set_widget(net_widgetul)
netwidgetul:set_bgimage(beautiful.widget_display)


-- | Weather | --


-- | Clock / Calendar | --

mytextclock    = awful.widget.textclock(markup(clockgf, space3 .. "%H:%M" .. markup.font("Tamsyn 3", " ")))
mytextcalendar = awful.widget.textclock(markup(clockgf, space3 .. "%a %d %b"))

widget_clock = wibox.widget.imagebox()
widget_clock:set_image(beautiful.widget_clock)

clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_display)


widget_calendar = wibox.widget.imagebox()
widget_calendar:set_image(beautiful.widget_cal)

calendarwidget = wibox.widget.background()
calendarwidget:set_widget(mytextcalendar)
calendarwidget:set_bgimage(beautiful.widget_display)

--local index = 1
--local loop_widgets = { mytextclock, mytextcalendar }
--local loop_widgets_icons = { beautiful.widget_clock, beautiful.widget_cal }

--clockwidget:buttons(awful.util.table.join(awful.button({}, 1,
--    function ()
--        index = index % #loop_widgets + 1
--        clockwidget:set_widget(loop_widgets[index])
--        widget_clock:set_image(loop_widgets_icons[index])
--    end)))

-- | Taglist | --

mytaglist         = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext() end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev() end)
                    )

-- | Tasklist | --

mytasklist         = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- | PANEL | --

mywibox           = {}
mypromptbox       = {}
mylayoutbox       = {}

for s = 1, screen.count() do
   
    mypromptbox[s] = awful.widget.prompt()
    
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- mytaglist[s] = sharedtags.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    mywibox[s] = awful.wibox({ position = "top", screen = s, height = "22" })

    local left_layout = wibox.layout.fixed.horizontal()
    
    --left_layout:add(mylauncher)
    left_layout:add(spr5px)
    left_layout:add(mytaglist[s])
    left_layout:add(spr5px)

    local centr_layout = wibox.layout.fixed.horizontal()
    centr_layout:add(mytasklist[s])
    

    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(spr)
        right_layout:add(spr5px)
        right_layout:add(mypromptbox[s])
        right_layout:add(wibox.widget.systray())
        right_layout:add(spr5px)
    end

    
    
    right_layout:add(spr)

    right_layout:add(widget_display_l)

    right_layout:add(kbdwidget)

    right_layout:add(widget_display_r)


--    right_layout:add(spr)

--    right_layout:add(spr)

    right_layout:add(mpd_sepl)
    right_layout:add(musicwidget)
    right_layout:add(mpd_sepr)
    right_layout:add(prev_icon)
    right_layout:add(spr)
    right_layout:add(stop_icon)
    right_layout:add(spr)
    right_layout:add(play_pause_icon)
    right_layout:add(spr)
    right_layout:add(next_icon)

    --right_layout:add(spr)

    -- right_layout:add(widget_mail)
    --right_layout:add(widget_display_l)
    --right_layout:add(mailwidget)
    --right_layout:add(widget_display_r)
    --right_layout:add(spr5px)



    right_layout:add(spr)
    right_layout:add(pulseBar) 
    right_layout:add(widget_display_l)
    right_layout:add(pulsewidget) 
    right_layout:add(widget_display_r)
    right_layout:add(spr)

    right_layout:add(widget_cpu)
    right_layout:add(widget_display_l)
    right_layout:add(cpuwidget)
    --right_layout:add(widget_display_r)
    right_layout:add(widget_display_c)
    right_layout:add(tmpwidget)
    right_layout:add(widget_tmp)
    right_layout:add(widget_display_r)
    right_layout:add(spr5px)

    right_layout:add(spr)

    right_layout:add(widget_mem)
    right_layout:add(widget_display_l)
    right_layout:add(memwidget)
    right_layout:add(widget_display_c)
    right_layout:add(mempwidget)
    right_layout:add(widget_display_r)
    right_layout:add(spr5px)

    right_layout:add(spr)

    right_layout:add(widget_fs)
    right_layout:add(widget_display_l)
    right_layout:add(fswidget)
    right_layout:add(widget_display_r)
    right_layout:add(spr5px)

    --right_layout:add(spr)

    --right_layout:add(widget_netdl)
    --right_layout:add(widget_display_l)
    --right_layout:add(netwidgetdl)
    --right_layout:add(widget_display_c)
    --right_layout:add(netwidgetul)
    --right_layout:add(widget_display_r)
    --right_layout:add(widget_netul)

    right_layout:add(spr)

    right_layout:add(widget_calendar)
    right_layout:add(widget_display_l)
    right_layout:add(calendarwidget)
    right_layout:add(widget_display_r)
    right_layout:add(spr5px)

    right_layout:add(spr)
    right_layout:add(widget_clock)
    right_layout:add(widget_display_l)
    right_layout:add(clockwidget)
    right_layout:add(widget_display_r)
    right_layout:add(spr5px)

    right_layout:add(spr)

    right_layout:add(mylayoutbox[s])

    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(centr_layout)
    layout:set_right(right_layout)

    mywibox[s]:set_bg(beautiful.panel)

    mywibox[s]:set_widget(layout)
end

-- | Mouse bindings | --

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({modkey, }, 4, awful.tag.viewnext),
    awful.button({modkey, }, 5, awful.tag.viewprev)
))

-- | Key bindings | --

globalkeys = awful.util.table.join(

    awful.key({ modkey, "Control"  }, "h", 
		function ()
			mpd_prev()
		end),
    awful.key({ modkey, "Control" }, "c", 
		function ()
			mpd_stop()
		end),
    awful.key({ modkey, "Control" }, "r", 
		function ()
			mpd_play_pause()
		end),
    awful.key({ modkey, "Control" }, "s", 
		function ()
			mpd_next()
		end),
    awful.key({ modkey, "Control" }, "n",  APW.Up),
    awful.key({ modkey, "Control" }, "t",  APW.Down),
    awful.key({ modkey,   }, "Home", 
		function ()
			mpd_prev()
		end),
    awful.key({ modkey,  }, "End", 
		function ()
			mpd_stop()
		end),
    awful.key({ modkey,  }, "Insert", 
		function ()
			mpd_play_pause()
		end),
    awful.key({ modkey,  }, "Delete", 
		function ()
			mpd_next()
		end),


    awful.key({ modkey,           }, "w",      function () mainmenu:show() end),
    --awful.key({ modkey,           }, "Escape", function () exec("/usr/local/sbin/zaprat --toggle") end),
    awful.key({ modkey            }, "r",      function () mypromptbox[mouse.screen]:run() end),
    awful.key({ altkey,           }, "t",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey,           }, "n",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),


    -- Tag browsing
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Non-empty tag browsing
    awful.key({ modkey }, "j", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ modkey }, "k", function () lain.util.tag_view_nonempty(1) end),
    
    awful.key({ modkey, "Shift" }, "j",   awful.tag.viewprev       ),
    awful.key({ modkey, "Shift" }, "k",  awful.tag.viewnext       ),




-- By direction client focus
    awful.key({ modkey }, "t",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "n",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "s",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- awful.key({ modkey,           }, "Tab",
    --     function ()
    --         awful.client.focus.history.previous()
    --         if client.focus then
    --             client.focus:raise()
    --         end
    --     end),
    awful.key({ modkey,         }, "Tab", function(c)
            cyclefocus.cycle(1, {modifier="Super_L"})
    end),
    awful.key({ modkey, "Shift" }, "Tab", function(c)
            cyclefocus.cycle(-1, {modifier="Super_L"})
    end),
    awful.key({ modkey, "Control" }, "Delete",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),
    awful.key({ modkey,           }, "Return", function () exec(terminal) end),
    awful.key({ modkey, "Control" }, "Return", function () exec(rootterm) end),
    --awful.key({ modkey,           }, "t",      function () exec(tmux) end),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1) end),
    --awful.key({ modkey            }, "a",      function () shexec(configuration) end),
    awful.key({ modkey,    }, "a",  revelation),
    --awful.key({ modkey,           }, "u",      function () exec("urxvt -geometry 254x60+80+60") end),
    --awful.key({ modkey,           }, "s",      function () exec(filemanager) end),
    awful.key({ modkey            }, "g",      function () exec("gvim") end),
    awful.key({ modkey            }, "Print",  function () exec("screengrab") end),
    awful.key({ modkey, "Control" }, "p",      function () exec("screengrab --region") end),
    awful.key({ modkey, "Shift"   }, "Print",  function () exec("screengrab --active") end),
    awful.key({ modkey            }, "c",      function () exec("firefox") end),
    awful.key({ modkey            }, "8",      function () exec("chromium") end),
    awful.key({ modkey            }, "9",      function () exec("dwb") end),
    awful.key({ modkey            }, "0",      function () exec("thunderbird") end),
    --awful.key({ modkey            }, "'",      function () exec("leafpad") end),
    --awful.key({ modkey            }, "\\",     function () exec("sublime_text") end),
    awful.key({ modkey            }, "$",      function () exec("gcolor2") end),
    awful.key({ modkey            }, "`",      function () exec("xwinmosaic") end),
    awful.key({ }, "XF86AudioRaiseVolume",  APW.Up),
    awful.key({ }, "XF86AudioLowerVolume",  APW.Down),
    awful.key({ }, "XF86AudioMute",         APW.ToggleMute),
    awful.key({ }, "XF86Sleep",         function () exec("systemctl suspend") end),
    awful.key({ }, "XF86Explorer",      function () exec("systemctl suspend") end),
    --awful.key({ modkey, "Control" }, "m",      function () shexec(ncmpcpp) end),
    --awful.key({ modkey, "Control" }, "f",      function () shexec(newsbeuter) end),
-- Dropdown terminal
   --awful.key({ modkey,	          }, "i",      function () drop(terminal) end), 
   awful.key({ modkey,	          }, "u",      function () scratch.drop(dropdownterm) end), 
   --awful.key({ modkey,	          }, "u",      function () drop(terminal) end), 
   awful.key({ modkey, "Control"  }, "x",      function () exec("/home/ivn/scripts/trackpoint/trackpointkeys.sh switch &") end)

--{ awful.key({ modkey, }, "k", function () quake.toggle({ terminal = "termite",
--			name = "QuakeTermite",
--			height = 0.5,
--			skip_taskbar = true,
--			ontop = true })
--	end)
-- awful.key({ modkey            }, "Pause",  function () exec("VirtualBox --startvm 'a8d5ac56-b0d2-4f7f-85be-20666d2f46df'") end)
    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run({ prompt = "Run Lua code: " },
    --               mypromptbox[mouse.screen].widget,
    --               awful.util.eval, nil,
    --               awful.util.getdir("cache") .. "/history_eval")
    --           end)
    )

clientkeys = awful.util.table.join(
    awful.key({ modkey            }, "Next",   function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey            }, "Prior",  function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey            }, "Down",   function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey            }, "Up",     function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey            }, "Left",   function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey            }, "Right",  function () awful.client.moveresize( 20,   0,   0,   0) end),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
        end),
    awful.key({ modkey,           }, "x",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    awful.button({ modkey, "Control" }, 4, APW.UP),
    awful.button({ modkey, "Control" }, 5, APW.DOWN))

awful.menu.menu_keys = {
    up    = { "n", "Up" },
    down  = { "t", "Down" },
    exec  = { "l", "Return", "Space" },
    enter = { "s", "Right" },
    back  = { "h", "Left" },
    close = { "q", "Escape" }
}

root.keys(globalkeys)

-- | Rules | --

awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     -- size_hints_honor = false,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },

    --{ rule = { class = "Exe"}, properties = {floating = true} },
    { rule = { class = "Plugin-container" },
    		properties = { floating = true} },
    { rule = { class = "gcolor2" },
      properties = { floating = true } },
    { rule = { class = "xmag" },
      properties = { floating = true } },

    { rule = { class = "veromix" },
      properties = { floating = true } },

    { rule = { name = "Громкость" },
      properties = { floating = true } },

    { rule = { role = "HTOP_CPU" },
      properties = { floating = true } },
    { rule = { role = "HTOP_MEM" },
      properties = { floating = true } },

    { rule = { class = "gvim" },
      properties = { tag = tags[2] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[4] } }, 
    { rule = { class = "Gvim"},
         properties = { tag = tags[1][2] } },
    { rule = { class = "Firefox"},
         properties = { tag = tags[1][5] } },
    { rule = { class = "Pidgin", role = "buddy_list"},
         properties = { tag = tags[1][3] } },
    { rule = { class = "Pidgin", role = "conversation"},
         properties = { tag = tags[1][3]}, callback = awful.client.setslave },
   
}

-- | Signals | --


    


local fullscreened_clients = {}

local function remove_client(tabl, c)
    local index = awful.util.table.hasitem(tabl, c)
    if index then
        table.remove(tabl, index)
        if #tabl == 0 then
            awful.util.spawn("xset s on")
            awful.util.spawn("xset -dpms")
              run_once(xautolock)
	      naughty.resume()
        end             
    end
end

client.connect_signal("property::fullscreen",
    function(c)
        if c.fullscreen then
            table.insert(fullscreened_clients, c)
	    if (c.class == "VirtualBox") then
	    else
            	if #fullscreened_clients == 1 then
              	  awful.util.spawn("xset s off")
              	  awful.util.spawn("xset -dpms")
              		naughty.suspend()
			mpd_pause()
			os.execute("pkill xautolock")
            	end
    	    end
        else
            remove_client(fullscreened_clients, c)
        end
    end)
    
client.connect_signal("unmanage",
    function(c)
        if c.fullscreen then
            remove_client(fullscreened_clients, c)
        end
    end)

client.connect_signal("manage", function (c, startup)
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "dialog") then  --{ c.type == "normal" or 
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) 
	c.border_color = beautiful.border_focus 
	if awful.rules.match(c, {class = "Firefox"}) then  os.execute("/home/ivn/scripts/trackpoint/trackpointkeys.sh browsermode &")
                                           end
end)
client.connect_signal("unfocus", function(c) 
	c.border_color = beautiful.border_normal 
	if awful.rules.match(c, {class = "Firefox"}) then  os.execute("/home/ivn/scripts/trackpoint/trackpointkeys.sh switch &")
	end
end)


client.connect_signal("unfocus", function(c) 
	if awful.rules.match(c, {class = "veromix"}) then  
		c:kill()
		APW.Update()
        end

end)
client.connect_signal("unfocus", function(c) 
	if awful.rules.match(c, {class = "Pavucontrol"}) then  
		c:kill()
		APW.Update()
        end

end)
client.connect_signal("manage", function(c) 
	if awful.rules.match(c, {class = "veromix"}) then  
		awful.placement.under_mouse(c)
		c:geometry( {y = 22 } )
        end

end)
client.connect_signal("manage", function(c) 
	if awful.rules.match(c, {class = "Pavucontrol"}) then  
		awful.placement.under_mouse(c)
		c:geometry( {y = 22 } )
        end

end)

client.connect_signal("unfocus", function(c) 
	if awful.rules.match(c, {role = "HTOP_CPU"}) then  
		c:kill()
        end

end)
client.connect_signal("manage", function(c) 
	if awful.rules.match(c, {role = "HTOP_CPU"}) then  
		awful.placement.under_mouse(c)
		c:geometry( {y = 22 } )
        end
end)
client.connect_signal("unfocus", function(c) 
	if awful.rules.match(c, {role = "HTOP_MEM"}) then  
		c:kill()
        end

end)
client.connect_signal("manage", function(c) 
	if awful.rules.match(c, {role = "HTOP_MEM"}) then  
		awful.placement.under_mouse(c)
		c:geometry( {y = 22 } )
        end
end)
-- | run or kill | --

function run_or_kill(cmd, properties)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0
   for i, c in pairs(clients) do
      --make an array of matched clients
      if match(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if #ctags == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      else
         -- Otherwise, pop to first tag client is visible on
         awful.tag.viewonly(ctags[1])
      end
      -- And then kill the client
      c:kill()
      return
   end
   awful.util.spawn(cmd)
end

-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v and not table2[k]:find(v) then
         return false
      end
   end
   return true
end

-- | run_once | --

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- | Autostart | --

os.execute("pkill compton")
os.execute("pkill xcape")
--os.execute("setxkbmap 'my(dvp),my(rus)' &")
os.execute("xkbcomp $HOME/.config/xkb/my $DISPLAY &")
-- os.execute("xrandr --output HDMI1 --mode 1920x1080 --left-of LVDS1 --output LVDS1 --auto --pos 0x500")
os.execute("/home/ivn/scripts/trackpoint/trackpointkeys.sh normalmode &")
os.execute("xset s off")
run_once("linconnect-server &")
run_once("kbdd")
run_once("mpd /home/ivn/.config/mpd/mpd.conf")
run_once("dropboxd")
run_once("nm-applet")
--run_once("pa-applet")
run_once("qbittorrent")
run_once("redshiftgui")
run_once("thunderbird")
os.execute('xcape -t 1000 -e "Control_L=Tab;ISO_Level3_Shift=Multi_key"' )
-- run_once("parcellite")
run_once("pidgin")
run_once("compton --config /home/ivn/.config/compton.conf -b &")
run_once(xautolock)



naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Awesme start correct, though...",
		     bg = beautiful.bg_normal,
                     text = awesome.startup_errors,
	     	     timeout = 2,
		     position = "top_left"
	     }) 
