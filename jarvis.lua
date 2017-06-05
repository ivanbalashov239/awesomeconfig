local widgets = require("widgets")
local awful = require("awful")

local config = {}
config.widgets = {}
--config.widgets.battery = widgets.battery()
--config.cpu_tmpfile = "/sys/class/hwmon/hwmon0/temp1_input"
	
config.widgets.mail = awful.widget.only_on_screen (widgets.mail(),"primary")
config.wired_interface = "enp5s0"
config.wireless_interface="wlp0s18f2u3"
config.autostart = {}
config.autostart.execute = {
	"pkill dropbox",
	"xset s off",
	"xset -dpms",
	--"dropbox &",
}
local browser       = "firefox"
config.autostart.run_once = {
	browser,
	"udiskie --tray &",
	--"nm-applet",
	--"pa-applet",
	"qbittorrent --style=gtk+",
	"redshiftgui",
	--"indicator-kdeconnect",
	"dropbox",
	--"thunderbird",
	--"parcellite",
	"pidgin",
}
return config
