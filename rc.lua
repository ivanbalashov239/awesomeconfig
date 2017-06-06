-- | Theme | --

local theme = "pro-dark"
local beautiful  = require("beautiful")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/theme.lua")

local config = require("config")
local gears      = require("gears")
local awful      = require("awful")
--awful.rules      = require("awful.rules")
                   require("awful.autofocus")
--                   require("sharetags")
local hintsetter  = require("hintsetter")
hintsetter.init({
charorder = "aoeuidhtnspyfgcrlqjkxbwvz1234567890"
})
local hints 	 = require("hints")
hints.init()
--local tyrannical = require("tyrannical")
local sharedtags = require("sharedtags")
--local apw 	 = require("apw/widget")
local wibox      = require("wibox")
local naughty    = require("naughty") --"notifybar")
local hidetray	 = require("hidetray")
--local systray	 = require("systray")
local lain       = require("lain")
local read_pipe    = require("lain.helpers").read_pipe
--local cyclefocus = require('cyclefocus')
local rork = require("rork")      
local run_or_raise = rork.run_or_raise
local run_or_kill = rork.run_or_kill
local modal_sc = require("modal_sc")      

local widgets = require("widgets")
local json = require('cjson')

--local timew = require("client_timew")
--timew()

-- freedesktop.org
local freedesktop = {}
freedesktop.menu = require('freedesktop.menu')
freedesktop.utils = require('freedesktop.utils')
lain.helpers     = require("lain.helpers")
--local menubar = require("menubar")
--menubar.terminal = "termite"
--menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/", "/usr/local/share/applications", "~/.local/share/applications" }
--local appsuspender = require("appsuspender")
--local im = require("im")
local scratchpad = require("utils.scratchpad")
--local task = require("task")
local capi = {
    mouse = mouse,
    client = client,
    screen = screen
    }

timer = gears.timer

oldprint = print
function print(s,t)
	if not s then
		s = "nill"
	end
	if type(s) == "table" then
		s = table.concat(s,"\n")
	end
	oldprint(s)
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = tostring(s),
		bg = beautiful.bg_normal,
		text = awesome.startup_errors,
		timeout=t,
		position = "top_left"
	}) 
end
os.execute('/home/ivn/scripts/run_slimlock_onstart.sh startup &')





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
	if err == "attempt to concatenate a userdata value" then return end

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- | Fix's | --

   --apwTimer = timer({ timeout = 1 }) -- set update interval in s
   --apwTimer:connect_signal("timeout", apw.Update)
  -- apwTimer:start()

-- Disable cursor animation:

local oldspawn = awful.spawn
--awful.spawn = function (s)
    --oldspawn(s, false)
--end

-- change notify defaults

--naughty.config.defaults({
  --                      screen = client.focus and client.focus.screen or 1
    --                })


-- Java GUI's fix:

awful.spawn.with_shell("wmname Sawfish") --LG3D")

-- | Variable definitions | --

local home   = os.getenv("HOME")
local exec   = function (s) oldspawn(s, false) end
local shexec = awful.spawn.with_shell


modkey        = "Mod4"
altgr        = "Mod5"
altkey        = "Mod1"

-- table of apps and they classes
apps = {}
terminal      = "termite"
--menubar.utils.terminal = terminal -- Set the terminal for applications that require it
--menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/", "/usr/local/share/applications", "~/.local/share/applications" }
tmux          = "termite -e tmux"
termax        = "termite --geometry 1680x1034+0+22"
htop_cpu      = "termite -e 'htop -s PERCENT_CPU' -r HTOP_CPU"
htop_mem      = "termite -e 'htop -s PERCENT_MEM' -r HTOP_MEM"
mutt	      = "uxterm -fs 12 -e 'mutt -F" -- -class MAIL 
--wifi_menu     = "termite -e 'sudo wifi-menu' -r WIFI_MENU"
rootterm      = "sudo -i termite"
ncmpcpp       = "urxvt -geometry 254x60+80+60 -e ncmpcpp"
newsbeuter    = "urxvt -g 210x50+50+50 -e newsbeuter"
browser       = "firefox"
filemanager   = "spacefm"
locker = '/home/ivn/scripts/run_slimlock_onstart.sh'
xautolock     = "xautolock -locker '"..locker.."' -nowlocker '"..locker.."' -time 10 &"
locknow       = "xautolock -locknow &"
--configuration = termax .. ' -e "vim -O $HOME/.config/awesome/rc.lua $HOME/.config/awesome/themes/' ..theme.. '/theme.lua"'
lastpidgin = nil

-- | Table of layouts | --

awful.layout.layouts = {
    --awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
    awful.layout.suit.max
}

-- | Wallpaper | --

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
screen.connect_signal("property::geometry", set_wallpaper)
--if beautiful.wallpaper then
    --for s = 1, screen.count() do
        ---- gears.wallpaper.tiled(beautiful.wallpaper, s)
        --gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    --end
--end

-- | Tags | --
--tagnames = { "all", "im"}
local tags = sharedtags({
    { name = "all",
    layout      = awful.layout.suit.max,
    hint = "a",
    },
    { name = "im",
    layout = awful.layout.layouts[1],
    hidden	    = true,
    master_width_factor      = 0.15,
    hint = "i",
    },
    --{ name = "misc", layout = awful.layout.layouts[2] },
    --{ name = "chat", screen = 2, layout = awful.layout.layouts[2] },
    --{ layout = awful.layout.layouts[2] },
    --{ screen = 2, layout = awful.layout.layouts[2] }
})
tags["im"].hidden = true
tags["im"].master_width_factor = 0.15
tags["all"].hint = "a"
tags["im"].hint = "i"
widgets.taglist.tags = tags
local im = scratchpad({
	set_geometry = scratchpad.functions.im_geometry,
	--hide  = scratchpad.functions.place_away,
	hide  = function(c,old)
		c:tags({})
		c.screen = old.screen
		c:geometry(old.geometry)
		c.floating = false
		c:geometry(old.geometry)
		c:tags({tags["im"]})
	end,
	hide_on_unfocus = true,
	--spawn = function(f)
		----local new_geometry = set_geometry(capi.client.focus)
		--awful.util.spawn("env QT_IM_MODULE=xim telegram-desktop",{
			----floating = true,
			----hidden = true,
			----width = new_geometry.width,
			----height = new_geometry.height,
			----x = new_geometry.x,
			----y = new_geometry.y

		--},
		--function(c)
			----print("spawn "..command,15)
			----local new_geometry = set_geometry(capi.client.focus)
			----c:geometry(new_geometry)
			--im.client = c
			----c.hidden = true
			----c:tags({})
			--f(c)
			----c:tags({})
			----scratch:hide()
			----scratch:show()
			----old.tags = {}
		--end)
	--end

})
--tyrannical.tags = {
    --{
	--name        = tagnames[1], --"Others",                 -- Call the tag "Term"
	--init        = true,                   -- Load the tag on startup
	--exclusive   = true,                   -- Refuse any other type of clients (by classes)
	--screen      = {1,2},                  -- Create this tag on screen 1 and screen 2
	--fallback    = true,
	--layout      = awful.layout.suit.max,
	----hide 	    = true,
	----instance    = {"dev", "ops"},         -- Accept the following instances. This takes precedence over 'class'
	--class       = { --Accept the following classes, refuse everything else (because of "exclusive=true")
	    --"xterm" , "urxvt" , "aterm","URxvt","XTerm","konsole","terminator","gnome-terminal", "Termite", "Firefox", "Gvim"
	--}
    --} ,
    --{
	--name        = tagnames[2],
	--init        = true, 	
	--exclusive   = true,               
	--screen	    = 1,                    
	--hide	    = true,
	--ncol	    = 3,
	--mwfact      = 0.15,
	--exclusive   = true,
	--layout      = awful.layout.suit.tile,
	--no_focus_stealing_in = true,
	
	--class = {
		--"Psi", "psi", "skype", "xchat", "choqok", "hotot", "qwit", "Pidgin","telegram-desktop","TelegramDesktop"
	--}
    --} ,
    ------{
        ------name        = "Internet",
        ------init        = true,
        ------exclusive   = true,
      --------icon        = "~net.png",                 -- Use this icon for the tag (uncomment with a real path)
        ------screen      = screen.count()>1 and 2 or 1,-- Setup on screen 2 if there is more than 1 screen, else on screen 1
        ------layout      = awful.layout.suit.max,      -- Use the max layout
        ------class = {
            ------"Opera"         , "Firefox"        , "Rekonq"    , "Dillo"        , "Arora",
            ------"Chromium"      , "nightly"        , "minefield"     }
    ------} ,
    ----{
	----name = tagnames[3],
	----init        = false,
	----exclusive   = true,
	----screen      = 1,
	----layout      = awful.layout.suit.floating,
	----exec_once   = {"dolphin"}, --When the tag is accessed for the first time, execute this command
	----class  = {
	    ----"Idea", "jetbrains-idea-ce", "sun-awt-X11-XFramePeer"
	----}
    ----} ,
    ----{
	----name = tagnames[3],
	----init        = false,
	----exclusive   = true,
	----screen      = {1,2},
	----layout      = awful.layout.suit.tile                          ,
	----class ={ 
	    ----"Firefox", "gvim", "Gvim"
	    ----}
    ----},
    ----{
        ----name        = "Doc",
        ----init        = false, -- This tag wont be created at startup, but will be when one of the
                             ------ client in the "class" section will start. It will be created on
                             ------ the client startup screen
        ------exclusive   = true,
	----fallback = true,
        ----layout      = awful.layout.suit.tile,
        ----class       = {
            ----"Assistant"     , "Okular"         , "Evince"    , "EPDFviewer"   , "xpdf",
            ----"Xpdf"          ,                                        }
    ----} ,
--}

---- Ignore the tag "exclusive" property for the following clients (matched by classes)
--tyrannical.properties.intrusive = {
    --"ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"               ,
    --"feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color"    ,
    --"kcolorchooser" , "plasmoidviewer" , "Xephyr"    , "kruler"       , "plasmaengineexplorer", "veromix"
--}

---- Ignore the tiled layout for the matching clients
--tyrannical.properties.floating = {
    --"MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    --"xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    --"yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    --"New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" 
--}

---- Make the matching clients (by classes) on top of the default layout
--tyrannical.properties.ontop = {
    --"Xephyr"       , "ksnapshot"       , "kruler"
--}

---- Force the matching clients (by classes) to be centered on the screen on init
--tyrannical.properties.centered = {
    --"kcalc"
--}

----tyrannical.settings.block_children_focus_stealing = true --Block popups ()
--tyrannical.settings.group_children = true --Force popups/dialogs to have the same tags as the parent client

    --{ rule = { class = "Plugin-container" },
                    --properties = { floating = true} },
    --{ rule = { class = "gcolor2" },
      --properties = { floating = true } },
    --{ rule = { class = "xmag" },
      --properties = { floating = true } },

    --{ rule = { class = "veromix" },
      --properties = { floating = true } },

    --{ rule = { name = "Громкость" },
      --properties = { floating = true } },

    --{ rule = { class = "Vlc" },
      --properties = { floating = true } },
    --{ rule = { role = "HTOP_CPU" },
      --properties = { floating = true } },
    --{ rule = { role = "HTOP_MEM" },
      --properties = { floating = true } },

    --{ rule = { class = "gvim" },
      --properties = { tag = tags[1][2], switchtotag = true}},
    --{ rule = { class = "Thunderbird" },
      --properties = { tag = tags[4] } }, 
    --{ rule = { class = "Gvim"},
         --properties = { tag = tags[1][2], switchtotag = true}},
    --{ rule = { class = "Firefox"},
         --properties = { tag = tags[1][5], switchtotag = true}},
    --{ rule = { class = "Pidgin", role = "buddy_list"},
         --properties = { tag = tags[1][3] } },
    --{ rule = { class = "Pidgin", role = "conversation"},
         --properties = { tag = tags[1][3]}, callback = awful.client.setslave },
--tags = {}
--for s = 1, screen.count() do
    --tags[s] = awful.tag({ "TERM", "CODE", "IM", "MAIL", "WEB" }, s, layouts[1])
--end

--for s = 1, screen.count() do 
----  tags[s] = awful.tag(tags.names, s, tags.layout)
  --awful.tag.setncol(3, tags[s][3]) 			   -- эта и следующая строчка нужна для Pidgin
  --awful.tag.setproperty(tags[s][3], "mwfact", 0.15)        -- здесь мы устанавливаем ширину списка контактов в 20% от ширины экрана
--end
-- {{{ Menu
--freedesktop.utils.terminal = terminal
--menu_items = freedesktop.menu.new()
--myawesomemenu = {
--{ "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
--{ "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
--{ "quit", "oblogout", freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
--}
--table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
--table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })
--mymainmenu = awful.menu({ items = menu_items, theme = { width = 150 } })
--mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
---- }}}

-- | Menu | --

menu_main = {
  { "lock",    locknow       },
  { "turn screen off",   "xset dpms force suspend"},
  { "suspend", "systemctl suspend" },
  { "poweroff",  "systemctl poweroff"},
  { "restart",   awesome.restart     },
  { "reboot",    "reboot"       },
  { "quit",      awesome.quit        }}


  mainmenu = awful.menu({ items = {
	  { " awesome",       menu_main   },
	  { " file manager",  filemanager },
	  { " root terminal", rootterm    },
	  --{ " launcher", 	menu_items    },
	  { " user terminal", terminal    }}})

	  -- | Markup | --

	  markup = lain.util.markup



--musicwidget =    config.musicwidget
mpdwidget =      config.mpdwidget
--pulsewidget =    config.pulsewidget
--kbdwidget =      config.kbdwidget
--mailwidget =     config.mailwidget
--cpuwidget =      config.cpuwidget
--memwidget =      config.memwidget
--fswidget =       config.fswidget
--taskwidget =     config.taskwidget
--netwidget =      config.netwidget
--weatherwidget =  config.weatherwidget
--clockwidget  =   config.clockwidget
--calendarwidget = config.calendarwidget

-- | Tasklist | --

myiconlist         = {}
myiconlist.buttons = awful.util.table.join(
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
                     awful.button({ }, 12, function (c)
			     			c:kill()
                                          end),
                     awful.button({ }, 2, function (c)
			     			c:kill()
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

-- | Tasklist | --

local function matchrules(rules, exclude)
    -- Only print client on the same screen as this widget
    local exclude = exclude or false
    return function(c, screen)
    	if c.screen ~= screen then return false end
    	-- Include sticky client too
    	if c.sticky then return false end
    	local ctags = c:tags()
	for _,rule in pairs(rules) do
		if awful.rules.match(c, rule) then return not exclude end
	end
    	return exclude
    end
end

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
mynotifybar = {}
--tray = hidetray({revers = true})
--text = wibox.widget.textbox("0")
hidetray({
		    --container = wibox.layout.fixed.horizontal()
	    })
--systray:attachtext(text)
--hidetray:show(1)
--hidetray.hidetimer:start()

awful.screen.connect_for_each_screen(function(s)
--for s = 1, screen.count() do
	--if s == 1 then
	--end
	--
    set_wallpaper(s)
    --awful.tag.viewonly(awful.tag.gettags(s)[1])
   
    s.mypromptbox = awful.widget.prompt()
    --mypromptbox[s] = awful.widget.prompt()
    
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    --s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons,{}, taglist_update)

    --s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons, {}, taglist_update)
    -- Create a tasklist widget
    --s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    --print(type(widgets.taglist({
	    --screen = s
    --})))
    s.mytaglist= widgets.taglist({
	    tags = tags,
	    screen=s
    })

    -- mytaglist[s] = sharedtags.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    s.mytasklist = awful.widget.tasklist(s, matchrules({{class = "Pidgin"},{class="TelegramDesktop"}}, false), mytasklist.buttons)
    --s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.alltags, mytasklist.buttons)
    --s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.alltags, mytasklist.buttons)
    --s.mytasklist= widgets.tasklist({
	    --screen=s
    --})

    --myiconlist[s] = awful.widget.tasklist(s, matchrules({class = "Pidgin"}, true),  myiconlist.buttons, {tasklist_only_icon=true}, tasklist_update, fixed.horizontal())

    --tasklist.new(screen, filter, buttons, style, update_function, base_widget)
    --mywibox[s] = awful.wibox({ position = "top", screen = s, height = "22" })
    s.mywibox = awful.wibar({ position = "top", screen = s, height = "22", bgimage = beautiful.panel})

    -- Add widgets to the wibox
    --if s == 2 then
    --local sidebar = wibox.layout.align.vertical()
    --mynotifybar = awful.wibox({position = "right", screen = s, width = "250"})
    --if naughty.stack then
    --mynotifybar:set_widget(naughty.stack)
    --end
    --end
    local left_layout = wibox.layout.fixed.horizontal()

    for i,k in pairs(config.panel.left) do
	    left_layout:add(k)
    end
    --left_layout:add(mylauncher)
    --left_layout:add(spr5px)
    --left_layout:add(myiconlist[s])
    --left_layout:add(spr5px)
    --left_layout:add(s.mytaglist)
    --left_layout:add(spr5px)

    local centr_layout = wibox.layout.fixed.horizontal()
    for i,k in pairs(config.panel.middle) do
	    centr_layout:add(k)
    end

    --centr_layout:add(s.mytasklist)


    local right_layout = wibox.layout.fixed.horizontal()
    --hidetray:attach({ wibox = mywibox[s], screen = s})
    --local cont = widgetcreator(
    --{
	    --widgets = {spr5px,mypromptbox[s], text, tray[s]}
    --})
    --right_layout:add(cont)
    for i,k in pairs(config.panel.right) do
	    right_layout:add(k)
    end
    --right_layout:add(kbdwidget)
    --right_layout:add(musicwidget)
    --right_layout:add(taskwidget)
    --right_layout:add(weatherwidget)
    --right_layout:add(netwidget)
    --right_layout:add(pulsewidget) 
    --if s == 1 then
	    --right_layout:add(cpuwidget)
	    --right_layout:add(mailwidget)
	    --right_layout:add(memwidget)
	    --right_layout:add(fswidget)
	    --if hostname == "Thinkpad" then
		    --right_layout:add(batterywidget)
	    --end
    --end
    --right_layout:add(calendarwidget)
    --right_layout:add(clockwidget)
    --right_layout:add(spr)
    --right_layout:add(s.mylayoutbox)
    --local layout = wibox.layout.align.horizontal()
    --layout:set_left(left_layout)
    --if s == 1 then
	    --layout:set_middle(centr_layout)
    --end
    --layout:set_right(right_layout)

    --mywibox[s]:set_bg(beautiful.panel)

    --mywibox[s]:set_widget(layout)
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            s.mytaglist,
        },
	s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            s.mypromptbox,
            --mykeyboardlayout,
	    --wibox.widget.systray(),
	    widgets({
		    textboxes = {hidetray.textbox}
	    }),
	    hidetray.tray,
	    right_layout,
            --mytextclock,
            s.mylayoutbox,
        },
    }
    hidetray:attach({
	    wibox = s.mywibox,
	    screen = s
    })
end)
--task.promptbox=mypromptbox

-- | Mouse bindings | --

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({modkey, }, 4, awful.tag.viewnext),
    awful.button({modkey, }, 5, awful.tag.viewprev)
))
-- | Key bindings | --
dbus.request_name("session", "org.naquadah.awesome.dusi")
dbus.add_match("session", "interface='org.naquadah.awesome.dusi',member='dusi'")
dbus.connect_signal("org.naquadah.awesome.dusi",
function(...)
	local args = {...}
	local method_name = args[2]
	--print(args[3])
	if method_name == "dusi" then
		print("dusi")
		dusi_notify(args[3],args[4])
	end
end
)
function dusi_notify(text,mode)
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
	if text then
		if mode == 0 then
			os.execute('curl --data \'{"id":"twxpzl4s","text":"'..text..'"}\' http://api.dusi.mobi/remote')
		else
			local answer = read_pipe('curl --data \'{"id":"twxpzl4s","text":"'..text..'"}\' http://api.dusi.mobi/remote?reply=true')
			--print(answer,35)
			local status, err= pcall(function() answer=json.decode(answer)end)
			--print(err)
			if status then
				if answer.text then
					text = answer.text
				elseif answer.cancel then
					text = "Отмена"
				else
					text = "нет текста"
				end
				awful.spawn.with_shell("~/scripts/saytext.sh 'ru' '"..text.."' fast &")
				naughty.notify({
					text = tofont(text,25,true),
					timeout=5,
					icon="/home/ivn/scripts/dusi_small.png"
				})
				if answer.modal then
					awful.spawn("/home/ivn/scripts/dusi_zenity.sh reply")
				end
			end
		end
	end
	widgets.kbdd.set_en()
end
function translator(text_tr)
	--print(text_tr)
	--local text_tr = read_pipe('cat /tmp/translate')
	--local text_tr = lain.helpers.first_line("/tmp/translate")
	--print("-"..text_tr.."-"..#text_tr,2)
	if text_tr and #text_tr > 0 then
		--print(text_tr)
		local lang ="ru:en"
		--print(string.match(text,"[a-zA-Z0-9,.!? ]*"))
		if string.match(text_tr,"[a-zA-Z0-9,.!? ]*") ==text_tr then
			lang ="en:ru"
			awful.spawn.with_shell("~/scripts/saytext.sh 'en' '"..text_tr.."' fast &")
		end
		local handle = io.popen("trans -no-ansi "..lang.." '"..text_tr.."'")
		local translation = handle:read("*a")
		--print(translation)
		handle:close()
		local t ='<span font="Cantarel 18">'..translation.."</span>"
		local timenotify = naughty.notify({
			title = "",
			text = t,
			--icon = "/home/ivn/Загрузки/KFaenzafordark/apps/48/time-admin2.png",
			timeout = 10,
			screen = mouse.screen or 1
		})
		--return true
		--end, nil,
		awful.spawn.with_shell("echo '"..text_tr.."' >> "..awful.util.getdir("cache") .. "/history_translate")
	end
end

globalkeys = awful.util.table.join(config.globalkeys,

    awful.key({ modkey, "Control"  }, "h", 
		function ()
			if mpdwidget.state == "play" then
				widgets.mpd.prev()
			else
				widgets.mpd.mpriscontrol("prev")
			end
		end),
    awful.key({ modkey, "Control" }, "space", 
    function ()
	    --print(#tags)
	    --for i,k in pairs(tags) do
		    --print(k.name)
	    --end
	    widgets.mpd.mpriscontrol("play_pause")
    end),
    awful.key({ modkey, "Control" }, "r", 
    function ()
	    if not mpdwidget.state == "play" then
		    widgets.mpd.mpriscontrol("pause")
	    --else
		    --widgets.mpd.mpriscontrol("play")
	    end
	    widgets.mpd.play_pause()
    end),
    awful.key({ modkey }, "F1", 
    function()
	    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 2")
	    --mpd_next()
    end),
    awful.key({ altgr }, "c", 
    function()
	    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 2")
	    --mpd_next()
    end),
    awful.key({ altgr }, "r", 
    function()
	    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 6")
	    widgets.mpd.next()
    end),
    awful.key({ modkey, altgr }, "r", 
    function()
	    local cur_rate = read_pipe('python3 /home/ivn/scripts/rate_current_mpd_song.py get rating')
	    if tonumber(cur_rate) then
		    cur_rate = math.floor(cur_rate/2)
	    else
		    cur_rate = 0
	    end
	    local star = '★'
	    local unstar = '☆'
	    local rate = star:rep(cur_rate)..unstar:rep(5-cur_rate)

	    modal_sc({
		    name="Rate current song "..rate,
		    actions ={
			    {
				    hint="0",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 0")
				    end,
				    desc = "☆☆☆☆☆"
			    },
			    {
				    hint="1",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 2")
				    end,
				    desc = "★☆☆☆☆"
			    },
			    {
				    hint="2",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 4")
				    end,
				    desc = "★★☆☆☆"
			    },
			    {
				    hint="3",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 6")
				    end,
				    desc = "★★★☆☆"
			    },
			    {
				    hint="4",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 8")
				    end,
				    desc = "★★★★☆"
			    },
			    {
				    hint="5",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 10")
				    end,
				    desc = "★★★★★"
			    },

		    }
	    }
	    )()
    end),
    awful.key({ modkey, "Control", "Shift" }, "h", 
    function ()
	    widgets.mpd.seek_backward()
    end),
    awful.key({ modkey, "Control", "Shift" }, "s", 
    function ()
	    widgets.mpd.seek_forward()
    end),
    awful.key({ modkey, "Control" }, "s", 
    function ()
	    if mpdwidget.state == "play" then
		    widgets.mpd.next()
	    else
		    widgets.mpd.mpriscontrol("next")
	    end
    end),
    awful.key({ modkey,   }, "Home", 
    function ()
	    widgets.mpd.prev()
    end),
    awful.key({ modkey,  }, "End", 
    function ()
	    widgets.mpd.stop()
    end),
    awful.key({ modkey,  }, "Insert", 
    function ()
	    widgets.mpd.play_pause()
    end),
    awful.key({ modkey,  }, "Delete", 
    function ()
	    widgets.mpd.next()
    end),


    awful.key({ modkey,           }, "/",      function () 
	    hidetray:show(mouse.screen) 
	    hidetray.hidetimer:start()
    end),
    awful.key({ modkey 		  }, "r",
    function ()
	    awful.prompt.run({ prompt = "Run: ", },
	    mouse.screen.mypromptbox.widget,
	    function (com)
		    local result = awful.spawn(com)
		    if type(result) == "string" then
			    mouse.screen.mypromptbox.widget:set_text(result)
		    end
		    return true
	    end,
	    awful.completion.shell,
	    awful.util.getdir("cache") .. "/history")
    end),
    awful.key({ modkey, altgr           }, "d",   function ()  
	    local s = (capi.mouse.screen + 1) % (#capi.screen + 1)
	    if s == 0 then
		    s = 1
	    end
	    local screen = capi.screen[s]
	    local screengeom = screen.workarea
	    moveMouse(math.floor(screengeom.x + screengeom.width / 2), math.floor(screengeom.y + screengeom.height / 2))                    
    end),
	    awful.key({ modkey,           }, "Return", function () exec(terminal) end),
	    awful.key({ modkey, "Control" }, "Return", 
	    function () 
		    os.execute(locknow)
		    widgets.mpd.mpriscontrol("pause")
	    end),
	    awful.key({ modkey,           }, "space",
	    function ()
		    --hintsetter:focus({modal_sc = modal_sc}) 
		    widgets.taglist.focus()
	    end),
	    awful.key({ modkey,    }, "i",
	    function()
		    im:toggle()
	    end),
	    awful.key({ modkey, "Control" }, "i", 
	    function ()
		    local tag = tags["im"]
		    awful.tag.viewonly(tag)
		    hints.focus(1)
	    end),
	    awful.key({ modkey, "Shift" }, "b",  
	    function () 
		    --hintsetter:newtag({
		    widgets.taglist.newtag({
			    screen = capi.mouse.screen,
		    })
		    --newtag({
		    --rule={class="Pidgin"}, 
		    --is_excluded=true,
		    --screen = {capi.mouse.screen}
		    --}) 
	    end),
	    awful.key({ modkey,    }, "b",  
	    function () 
		    --hintsetter:newtag({
		    widgets.taglist.newtag({
			    screen = capi.mouse.screen,
			    only = true,
		    })
		    --newtag({
		    --rule={class="Pidgin"}, 
		    --is_excluded=true,
		    --screen = {capi.mouse.screen}
		    --}) 
	    end),
	    awful.key({ modkey            }, "@",      function ()
		    widgets.taglist.togglefromtag()
	    end),
	    awful.key({ modkey            }, "x",      function ()
		    local cf = client.focus
		    local t = awful.screen.focused().selected_tag
		    if not t then return end
		    --print(t.name)
		    if t == tags["all"] or t.hidden then

			    --print(t.name)
			    return
		    else
			    --t.volatile = true
			    --print("volatile "..tostring(tag.volatile))
			    local clients = t:clients()
			    for _,c in pairs(clients)do
				    if #(c:tags()) == 1 then
					    c:tags({tags["all"]})
				    end
			    end
			    --t:clients({})
			    --print(t.name)
			    --t:delete()
			    t:delete({fallback_tag=tags["all"], force=true})
			    client.focus = cf
			    client.focus:tags()[1]:view_only()
			    client.focus = cf
			    --tags["all"]:view_only()
			    --local tag = awful.tag.selected()
			    --local tag = mouse.screen.selected_tag
			    --local clients = tag:clients()
			    --for i,c in pairs(clients) do
			    --local tags = c:tags()
			    --if #tags==1 then
			    --c:tags({tags[1]})
			    --end
			    --end
			    ----awful.tag.delete()--tag,awful.tag.gettags(tag.screen or 1)[1])
			    ----tag:delete(tags[1])
			    --tag:delete()
			    --print(t.name..' deleted')
		    end
	    end),
	    awful.key({ modkey,  }, "Left",     function() brightnessdec() end),
	    awful.key({ modkey,  }, "Right",    function() brightnessinc() end),
	    awful.key({ modkey,altgr  }, "h",   function() brightnessdec() end),
	    awful.key({ modkey,altgr  }, "s",   function() brightnessinc() end),
	    awful.key({ altgr  }, "Alt_L",   widgets.kbdd.set_ru),
	    awful.key({ altkey  }, "ISO_Level3_Shift",   widgets.kbdd.set_en)
	    )

	    clientkeys = awful.util.table.join(config.clientkeys,
	    awful.key({ modkey,           }, "d",      function (c) 
		    --awful.client.movetoscreen(c)
		    sharedtags.viewonly(o,screen.selected)
		    client.focus = c
		    c:raise()
	    end),
	    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
	    awful.key({ modkey,           }, "-",
	    function (c)
		    c.minimized = not c.minimized
	    end)
	    --,
	    --awful.key({ modkey,           }, "m",
	    --function (c)
	    --c.maximized_horizontal = not c.maximized_horizontal
	    --c.maximized_vertical   = not c.maximized_vertical
	    --end)
	    )


	    clientbuttons = awful.util.table.join(config.clientbuttons,
	    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	    awful.button({ modkey }, 1, awful.mouse.client.move),
	    awful.button({ modkey }, 3, awful.mouse.client.resize)
	    --awful.button({ modkey, "Control" }, 4, apw.up),
	    --awful.button({ modkey, "Control" }, 5, apw.down)
	    )

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
	    local function concat_rules(tables)
		   local result = {}
		   for i,k in pairs(tables) do
			   for a,b in pairs(k) do
				   if b then
					   table.insert(result,b)
				   end
			   end
		   end
		   return result
	   end

	    --awful.rules.rules = awful.util.table.join(config.rules,
	    awful.rules.rules = concat_rules({config.rules,{
		    { rule = { },
		    properties = { border_width = beautiful.border_width,
		    --tag = tags["all"],
		    border_color = beautiful.border_normal,
		    focus = awful.client.focus.filter,
		    size_hints_honor = false,
		    raise = true,
		    keys = clientkeys,
		    buttons = clientbuttons },
		    callback = function(c)
			    local thistags = c:tags()
			    if #thistags == 0 then
				    c:tags({tags["all"]})
			    end
		    end
	    },
	    { rule = { class = "Pidgin", role = "conversation"},
	    callback = function(c)
		    if not (c.name == "Dusi") then
			    c:connect_signal("unfocus",function(c)
				    im.lastpidgin = c
			    end)
		    end
	    end
    },
    { rule = { class = "TelegramDesktop"},
    properties = { tag = tags["im"], ontop = true},
    callback = function(c)
	    --im.lastpidgin = c
	    im.client = c
	    local telegramtimer = timer({ timeout = 5 })
	    local function escape()
		    if telegramtimer.data.source_id ~= nil then
			    telegramtimer:stop()
		    end
		    telegramtimer = timer({ timeout = 5 })
		    telegramtimer:connect_signal("timeout", function ()
			    os.execute("xdotool key --clearmodifiers --window "..c.window.." Escape")
			    os.execute("xdotool key --clearmodifiers --window "..c.window.." Escape")
			    telegramtimer:stop()
		    end)
		    telegramtimer:start()
	    end
	    c:connect_signal("unfocus",function(c)
		    im.lastpidgin = c
		    escape()
	    end)
	    c:connect_signal("focus",function(c)
		    if telegramtimer.data.source_id ~= nil then
			    telegramtimer:stop()
		    end
	    end)
	    awful.client.setslave(c)
	    local function urgent(c)
		    for word in c.name:gmatch("%(.*%)") do
			    c.urgent = true
			    return
		    end
		    c.urgent = false
	    end
	    c:connect_signal("property::name",urgent)
	    c:connect_signal("focus",urgent)
	    c:connect_signal("unfocus",urgent)
	    c.urgent = false
    end
    },
    { rule = { class = "Pidgin", role = "buddy_list"},
    properties = { tag = tags["im"], switchtotag = false, no_autofocus = true }},
    { rule = { class = "Pidgin", role = "conversation"},
    properties = { tag = tags["im"], switchtotag = false, no_autofocus = true },
    callback = awful.client.setslave },
    {rule = {role = "DROPDOWN"}, 
    properties = {opacity = 0.8},
    callback = function(c)
	    awesome.connect_signal("exit",function()
		    c:kill()
	    end)
    end},
	{ rule = { class = "bomi"},
	properties = { opacity = 0.8, switchtotag = false, no_autofocus = true, floating = true, ontop = true, sticky = false  },
	callback = function(c)

		local function set_geometry(c,s)
			--c.screen = s
			--print("set geometry")
			local scrgeom = c.screen.workarea
			local clgeom  = {}
			if scrgeom.height < scrgeom.width then
				clgeom  = {
					width = scrgeom.width/5,
					height = scrgeom.height/5,
				  	x = scrgeom.x + scrgeom.width - scrgeom.width/5,
					y = scrgeom.y + scrgeom.height - scrgeom.height/5,
				}
			else
				clgeom  = {
					width = scrgeom.height/5,
					height = scrgeom.width/5,
				  	x = scrgeom.x + scrgeom.width - scrgeom.height/5,
					y = scrgeom.y + scrgeom.height - scrgeom.width/5,
				}
			end
			if c.fullscreen then
				oldgeom = clgeom
			else
				oldgeom = clgeom
				c:geometry(clgeom)
			end
		end
		set_geometry(c)
		local function geomfunc()
			set_geometry(c)
		end
		capi.screen.connect_signal("property::workarea",geomfunc)
		--c:connect_signal("request::geometry",set_geometry)
		--local scrgeom = capi.screen[capi.mouse.screen].geometry
		--local clgeom  = c:geometry({width = scrgeom.width/5, height = scrgeom.height/5})
		--local clgeom  = c:geometry({x = scrgeom.x + scrgeom.width - clgeom.width, y = scrgeom.y + scrgeom.height - clgeom.height}) 
		local oldgeom = nil
		c:connect_signal("tagged",function(c,t)
			if t then
				if #(t:clients()) == 1 then
					c.opacity = 1
					c.floating = false 
					c.ontop = false
					c.sticky = false
					oldgeom = c:geometry()
				end
			end
		end)
		c:connect_signal("untagged",function(c,t)
			if t then
				if #(t:clients()) == 0 then
					c.opacity = 0.8
					c.floating = true
				c.ontop = false
					--c.ontop = true
					c.sticky = true
					c:geometry(oldgeom)
					oldgeom = nil
				end
			end
		end)
		c:connect_signal("property::fullscreen",function(c)
			if c.fullscreen then
				c.opacity = 1
				c.floating = false 
				c.ontop = false
				--c.sticky = false
				oldgeom = c:geometry()
			else
				c.opacity = 0.8
				c.floating = true
				c.ontop = false
				--c.ontop = true
				c.sticky = true
				c:geometry(oldgeom)
				oldgeom = nil
			end
		end)
		dbus.request_name("session", "org.mpris.MediaPlayer2")
		dbus.add_match("session", "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'")
		local function bomi_state(...)
			local data = {...}
			--for i,k in pairs(data[3]) do
			--print(i)
			--if type(k) == "string" then
			--print(k)
			--end
			--end
			--print(data[3].Metadata)
			local state = data[3].PlaybackStatus
			if c then
				c.state = state
				if state == "Playing" then
					widgets.mpd.pauseif()
				elseif state == "Paused" then
					widgets.mpd.playif()
				end
			else
				dbus.disconnect_signal("org.freedesktop.DBus.Properties", bomi_state)
			end
			--for i,str in pairs(data) do
			--print(i.." "..tostring(str))
			--if type(str) == "table" then
			--for k,n in pairs(str) do
			--print(k.." "..tostring(n))
			--end
			--end
			--end
		end
		dbus.connect_signal("org.freedesktop.DBus.Properties", bomi_state)
		local function focus(cl)
			local cur_screen = cl.screen
			local cur_tag = cur_screen.selected_tag
			c:tags({cur_tag})
			--c.ontop = true
		end
		capi.client.connect_signal("focus",focus)
		c:connect_signal("unmanage",
		function(c)
			widgets.mpd.playif()
			capi.screen.disconnect_signal("property::workarea",geomfunc)
			capi.client.disconnect_signal("focus",focus)
			dbus.disconnect_signal("org.freedesktop.DBus.Properties", bomi_state)
		end)
	end
}
}}
)

-- | Signals | --

local function timemute()
	awful.spawn.with_shell("rm /tmp/timemute>/dev/null || touch /tmp/timemute")
end




--dbus.request_name("session", "org.mpris.MediaPlayer2")
--dbus.add_match("session", "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'")
--dbus.connect_signal("org.freedesktop.DBus.Properties", function(...)
	--local data = {...}
	----for i,k in pairs(data[3]) do
		----print(i)
		----if type(k) == "string" then
			----print(k)
		----end
	----end
	----print(data[3].Metadata)
	--local status = data[3].PlaybackStatus
	--if status == "Playing" then
		--pauseif()
	--elseif status == "Paused" then
		--playif()
	--end
	----for i,str in pairs(data) do
	----print(i.." "..tostring(str))
	----if type(str) == "table" then
	----for k,n in pairs(str) do
	----print(k.." "..tostring(n))
	----end
	----end
	----end
--end
--)

local function checkclass(class)
	local table = {"Virtualbox","Bomi"}
	for i,n in pairs(table) do
		if n == class then
			return false
		end
	end
	return true
end
local fullscreened_clients = {}

local function remove_client(tabl, c)
	local index = awful.util.table.hasitem(tabl, c)
	if index then
		table.remove(tabl, index)
		if #tabl == 0 then
			awful.spawn("xset s off")
			awful.spawn("xset -dpms")
			os.execute("xautolock -enable")

			if checkclass(c.class) then
				timemute()
				widgets.mpd.playif()
			end
		end             
	end
end

	client.connect_signal("property::fullscreen",
	function(c)
		if c.fullscreen then
			table.insert(fullscreened_clients, c)
			if #fullscreened_clients == 1 then
				awful.spawn("xset s off")
				awful.spawn("xset -dpms")
				--naughty.suspend()
				os.execute("xautolock -disable")
				if checkclass(c.class) then
					widgets.mpd.pauseif()
					timemute()
				end
			end
		else
			remove_client(fullscreened_clients, c)
		end
	end)

	--client.connect_signal("untagged",
	--function(c,t)
		----for i,t in pairs(c.tags(c)) do
		--local del = true
		--for _,n in pairs(tags) do
			--if t.name == n.name then
				--del = false
			--end
		--end
		--if del and #(t:clients()) < 2 then
			--t:delete()
		--end
		----end

	--end)
	client.connect_signal("unmanage",
	function(c)
		if c.fullscreen then
			remove_client(fullscreened_clients, c)
		end
		--print("check tags")
		for i,t in pairs(c.tags(c)) do
			--print(i.." "..t.name)
			del = true
			for _,n in pairs(tags) do
				if t.name == n.name then
					del = false
				end
			end
			--print(del)
			if del and #t:clients() < 2 then
				awful.tag.delete(t)
			end
		end

	end)

	tags["im"]:connect_signal("tagged",function(t,c)
		if not (c.class ==  "TelegramDesktop" or c.class == "Pidgin" )then
			local tags= c:tags()
			for i,k in ipairs(tags) do
				if k == tags["im"] then
					table.remove(tags,i)
				end
			end
			c:tags(tags)
		end
	end)
	tags["all"]:connect_signal("tagged", function (t,c)
		if c and c.type == "normal" and not c.floating and not c.fullscreen then
			--print(c.floating)
			--print(c.sticky)
			local tags = c:tags()
			for i,k in ipairs(tags)do
				if not (k.name == "all") and #(k:clients()) == 1 or k == tags["im"] then
					return
				end
			end
			local tag = awful.tag.add(c.class, { volatile = true, 
			--selected = true,
			layout = awful.layout.suit.max,
			screen = c.screen})
			tag:clients({c})
			tag:view_only()
			capi.client.focus = c
			tag:connect_signal("tagged",function(t,cl)
				if cl and cl.type == "normal" and not cl.floating and not cl.fullscreen then
					--print(cl)
					--print(cl.class)
					--tag:clients({c})
					cl:tags({tags["all"]})
				end
			end)
			tag:connect_signal("untagged",function(t,cl)
				if cl.type == "normal" then
					local i = 0
					for _,k in pairs(t:clients()) do
						if k and k.type == "normal" and not k.floating and not k.fullscreen then
							i = i+1
						end
					end
					if i == 0 then
						for _,k in pairs(t:clients()) do
							k:tags({tags["all"]})
						end
						t:delete()
					end
				end
			end)
			local clients = t:clients()
			for i,k in ipairs(clients)do
				if k == c then
					table.remove(clients,i)
				end
			end
			t:clients(clients)
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

	unfocusable = {
		{
			class="com-eteks-sweethome3d-SweetHome3DBootstrap"
		},
		{
			class="x-sweethome3d"
		}, 
		{
			class="sun-awt-X11-XFramePeer"
		},
		{
			class="Firefox",
			type="utility"
		}
	}
	mousetimer = timer({ timeout = 0.1 })
	function moveMouse(x_co, y_co)
		if mousetimer.data.source_id ~= nil then
			mousetimer:stop()
		end
		mousetimer = timer({ timeout = 0.1 })
		mousetimer:connect_signal("timeout", function ()
			mouse.coords({ x=x_co, y=y_co })
			mousetimer:stop()
		end)
		mousetimer:start()
	end
	client.connect_signal("focus", function(c) 
		local screengeom = capi.screen[mouse.screen].workarea
		for _,s in pairs(unfocusable) do
			local continue=true
			for name,value in pairs(s) do
				if not (c[name] == value) then
					continue=false
					--else
					--print({name,value})
				end
			end
			--if c.class == s then
			if continue then
				return
			end
		end
		if mouse.coords().y > screengeom.y then
			if not (c == mouse.object_under_pointer()) then
				geom=c.geometry(c)
				if c.class=="TelegramDesktop" then
					x=geom.x+math.modf(geom.width/2)--+1
					y=geom.y+math.modf(geom.height/30)--+1
				else
					x=geom.x+math.modf(geom.width/2)--+1
					y=geom.y+math.modf(geom.height/2)--+1
				end

				moveMouse(x,y)
				--client.foucs = c
			end
		end
	end)

	keysmode = "normalmode"
	trackpointnotify = nil
	browserclients = {"Firefox", "Thunderbird", "Vivaldi-snapshot", "Palemoon", "Chromium","Google-chrome","google-chrome", "Blender"}
	normalclients = {}
	commandclients = {}
	client.connect_signal("manage", function(c) 
		--if  not c.maximized_horizontal then
		--c.border_color = beautiful.border_focus 
		--end
		local mode = "normalmode"
		for _,s in pairs(browserclients) do
			if c.class == s then
				mode = "browsermode"
			end
		end
		for _,s in pairs(normalclients) do
			if c.class == s then
				mode = "normalmode"
			end
		end
		for _,s in pairs(commandclients) do
			if c.class == s then
				mode = "commandmode"
			end
		end
		c:connect_signal("focus", function(cl)
			if mode ~= keysmode then
				keysmode = mode
				os.execute("/home/ivn/scripts/trackpoint/trackpointkeys.sh "..keysmode.." &")
				naughty.destroy(trackpointnotify, true)
				trackpointnotify = naughty.notify({
					title = "TrackPoint Keys",
					text = keysmode,
					icon = "/home/ivn/scripts/trackpoint/"..keysmode..".png",
					timeout = 2,
					screen = mouse.screen or 1
				})
			end
		end)
	end)

	--client.connect_signal("manage", function(c) 
		--taglist = tags
		--tag = taglist[1]
		--for i,t in pairs(c.tags(c)) do
			--if t == taglist[2] then
				----print(t.name)
				--return true
			--end
			--if t == tag then
				--return true
			--end
		--end
		--awful.client.toggletag(tag,c)
		--return true
	--end)
	--client.connect_signal("unfocus", function(c) 
	--c.border_color = beautiful.border_normal 
	----	if awful.rules.match(c, {class = "Firefox"}) then  	end
	--end)


	--client.connect_signal("unfocus", function(c) 
	--if awful.rules.match(c, {class = "veromix"}) then  
	--c:kill()
	--apw.Update()
	--end

	--end)
	--client.connect_signal("unfocus", function(c) 
	--if awful.rules.match(c, {class = "Pavucontrol"}) then  
	--c:kill()
	--apw.Update()
	--end

	--end)
	--client.connect_signal("manage", function(c) 
	--if awful.rules.match(c, {class = "veromix"}) then  
	--awful.placement.under_mouse(c)
	--c:geometry( {y = 22 } )
	--end

	--end)

	--client.connect_signal("unfocus", function(c) 
	--if awful.rules.match(c, {role = "HTOP_CPU"}) then  
	--c:kill()
	--end

	--end)
	--client.connect_signal("manage", function(c) 
	--if awful.rules.match(c, {role = "HTOP_CPU"}) then  
	--awful.placement.under_mouse(c)
	--c:geometry( {y = 22 } )
	--end
	--end)
	--client.connect_signal("unfocus", function(c) 
	--if awful.rules.match(c, {role = "HTOP_MEM"}) then  
	--c:kill()
	--end

	--end)
	--client.connect_signal("manage", function(c) 
	--if awful.rules.match(c, {role = "HTOP_MEM"}) then  
	--awful.placement.under_mouse(c)
	--c:geometry( {y = 22 } )
	--end
	--end)
	--tag.connect_signal("property::selected", function(t)
		--if t.name == tagnames[2] and not t.selected and #awful.tag.selectedlist() == 0 then
			--awful.tag.viewonly(tags[1])
		--end
	--end)

	function brightnessdec() 
		for i,k in pairs(screen[mouse.screen].outputs) do
			if (i == "HDMI1") or (i == "HDMI-0")  then
				local sh = io.popen("xrandr --verbose | grep -A 5 -i HDMI | grep -i brightness | cut -f2 -d ' '")
				if sh == nil then
					return false
				end
				local br = tonumber(sh:read("*a"))
				sh.close()
				if br < 0 then
					br = 0
				end
				br = br - 0.05
				if br < 0 then
					br = 0
				end
				if br > 1 then
					br = 1
				end
				os.execute("xrandr --output "..i.." --brightness "..br)
				--naughty.notify({title = i})
			elseif (i == "LVDS1") or (i == "LVDS") then
				--naughty.notify({title = i})
				exec("xbacklight -dec 10")
			end
		end
	end
	function brightnessinc() 
		for i,k in pairs(screen[mouse.screen].outputs) do
			if (i == "HDMI1") or (i == "HDMI-0")  then
				local sh = io.popen("xrandr --verbose | grep -A 5 -i HDMI | grep -i brightness | cut -f2 -d ' '")
				if sh == nil then
					return false
				end
				local br = tonumber(sh:read("*a"))
				sh.close()
				if br < 0 then
					br = 0
				end
				br = br + 0.05
				if br < 0 then
					br = 0
				end
				if br > 1 then
					br = 1
				end
				os.execute("xrandr --output "..i.." --brightness "..br)
			elseif (i == "LVDS1") or (i == "LVDS") then
				--naughty.notify({title = i})
				exec("xbacklight -inc 10")
			end
		end
	end
	-- | run_once | --

	function run_once(cmd)
		if type(cmd) == "timer" then
			cmd:start()
			return
		elseif type(cmd) == "function" then
			cmd()
			return
		elseif type(cmd) == "table" then
			return
		end
		findme = cmd
		firstspace = cmd:find(" ")
		if firstspace then
			findme = cmd:sub(0, firstspace-1)
		end
		awful.spawn.with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
	end

	-- | Autostart | --

	for i,k in pairs(config.autostart.execute) do
		os.execute(k)
	end
	for i,k in pairs(config.autostart.run_once) do
		run_once(k)
	end

	--autostarttimer:stop()
	local notif = naughty.notify({ preset = naughty.config.presets.critical,
	title = "Awesme start correct, though...",
	bg = beautiful.bg_normal,
	text = awesome.startup_errors,
	timeout = 2,
	position = "top_left"})
	--end)
	--autostarttimer:start()
