local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")
local read_pipe    = require("lain.helpers").read_pipe

local weatherwidget ={}
weatherwidget.shortcuts = {}

local function worker(args)
	weather_widget = lain.widget.weather({
		APPID = "9a42072650caa7c0145df83667e701f5",
		city_id = "519690",
		settings = function()
			--for i,k in pairs(weather_now["main"])do
			--print(i)
			----print(k)
			----f = function(s)
			----if not (type(s) == "table") then
			----print(s)
			----else
			----for a,b in pairs(s)do
			----print(a)
			----f(b)
			----end
			----end
			----end
			----f(k)
			--end
			----print(weather_now["main"]["temp_max"])
			----print(weather_now["main"]["temp_min"])
			--print(weather_now["main"]["temp"])
			local wn = weather_now["main"]
			--local tmin =wn["temp_min"]--math.floor()
			--local tmax =wn["temp_max"]--math.floor()
			local temp =math.floor(wn["temp"])
			weather_widget.widget:set_markup(temp.."°C")
		end,
		notification_text_fun = function(wn)
			--local day = string.gsub(read_pipe(string.format(date_cmd, wn["dt"])), "\n", "")
			--local day = string.gsub(read_pipe(string.format("date -u -d @%d +'%%A %%d'", -- customize date cmd here
			--wn["dt"])), "\n", "")
			local day = os.date("%a %d", wn["dt"])

			local tmin = math.floor(wn["temp"]["min"])
			local tmax = math.floor(wn["temp"]["max"])
			local desc = wn["weather"][1]["description"]
			return string.format("<span font='Terminus bold 18'><b>%s</b>: %s, %d°C - %d°C </span>", day, desc, tmin, tmax)
		end,
	})

	--weatherbuttons = awful.util.table.join(awful.button({ }, 1,
	--function () run_or_kill(htop_weather, { role = "HTOP_CPU" }, {x = mouse.coords().x, y = mouse.coords().y+2}) end))

	--tmp_widget = lain.widgets.temp({
	--tempfile = "/sys/class/hwmon/hwmon2/temp2_input",
	--settings = function()
	--widget:set_markup(space3 .. coretemp_now .. "°C" .. markup.font("Tamsyn 4", " "))
	--end
	--})

	local weatherwidget = widgetcreator(
	{
		--image = weather_widget.icon,
		--text = "CPU",
		textboxes = {weather_widget.widget},
		widgets = {weather_widget.icon},
	})

	--weatherwidget:buttons(weatherbuttons)
	weather_widget.attach(weatherwidget)


	return weatherwidget
end

return setmetatable(weatherwidget, {__call = function(_,...) return worker(...) end})
