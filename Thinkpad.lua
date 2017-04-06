local widgets = require("widgets")

local config = {}
config.widgets = {}
config.widgets.battery = widgets.battery()
config.cpu_tmpfile = "/sys/class/hwmon/hwmon0/temp1_input"
return config
