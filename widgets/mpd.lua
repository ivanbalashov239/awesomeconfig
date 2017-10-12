local widgetcreator = require("widgets")
local widgets = widgetcreator
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local helpers      = lain.helpers
local awful = require("awful")
local utf8 	 = require("utf8_simple")
local timer = require("gears").timer
local naughty    = require("naughty")

local mpdwidget ={}
mpdwidget.shortcuts = {}
function mpdwidget.skip()
	lain.helpers.async('python3 /home/ivn/scripts/rate_current_mpd_song.py get rating', function(f)
		local cur_rate = f
		if tonumber(cur_rate) then
			cur_rate = math.floor(cur_rate)
		else
			cur_rate = nil
		end
		if cur_rate then
			if cur_rate > 1 and cur_rate < 6 then
				mpdwidget.next()
			elseif cur_rate == 1 and skip_unrated then
				mpdwidget.next()
			end
		elseif mpdwidget.skip_unrated then
			--os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 1")
			mpdwidget.next()
		end
	end)
end
local function worker(args)
	local args = args or {}
	local host = args.host
	-- | MPD | --

	--prev_icon = wibox.widget.imagebox()
	--prev_icon:set_image(beautiful.mpd_prev)
	--next_icon = wibox.widget.imagebox()
	--next_icon:set_image(beautiful.mpd_nex)
	--stop_icon = wibox.widget.imagebox()
	--stop_icon:set_image(beautiful.mpd_stop)
	--pause_icon = wibox.widget.imagebox()
	--pause_icon:set_image(beautiful.mpd_pause)
	--play_pause_icon = wibox.widget.imagebox()
	--play_pause_icon:set_image(beautiful.mpd_play)
	--local mpd_sepl = wibox.widget.imagebox()
	--mpd_sepl:set_image(beautiful.mpd_sepl)
	--local mpd_sepr = wibox.widget.imagebox()
	--mpd_sepr:set_image(beautiful.mpd_sepr)
	local mpd_skip_timer = timer({timeout=0.5})
	mpd_skip_timer:connect_signal("timeout",mpdwidget.skip)
	--mpd_skip_timer:start()
	mpdwidget.mpdwidget = wibox.widget.textbox()

	local widget = lain.widget.mpd({
		--notify = "off",
		host = host,
		settings = function ()
			mpdwidget.mpdwidget.state = mpd_now.state
			if mpd_now.state == "play" then
				--print(mpd_now.title)
				--mpd_skip_timer:emit_signal("timeout")
				mpdwidget.skip()
				widget:set_markup(" Title loading ")
				mpd_now.artist = string.gsub(mpd_now.artist,"&quot;","'")
				mpd_now.title = string.gsub(mpd_now.title,"&quot;","'")
				mpd_now.artist = string.gsub(mpd_now.artist,"&amp;","and")
				mpd_now.title = string.gsub(mpd_now.title,"&amp;","and")
				mpd_now.artist = string.gsub(mpd_now.artist,"&apos;","'")
				mpd_now.title = string.gsub(mpd_now.title,"&apos;","'")
				mpd_now.artist = mpd_now.artist:upper():gsub("&.-;", string.lower)
				mpd_now.title = mpd_now.title:upper():gsub("&.-;", string.lower)
				artistsub = utf8.sub(mpd_now.artist:upper():gsub("&.-;", string.lower), 0, 7)
				titlesub = utf8.sub(mpd_now.title:upper():gsub("&.-;", string.lower), 0, 12)
				local nowplayingtext = mpd_now.artist .. "—" .. mpd_now.title
				local nowplayingsub = artistsub.. "—" ..titlesub
				local nowplaying = nowplayingsub
				if mpdwidget.mpdwidget.scrolling then
					nowplaying = nowplayingtext
				end
				--print(nowplaying)
				--mpdwidget.mpdwidget.nowplaying = nowplayingtext
				--local nowtext = lain.util.markup.font("Tamsyn 3", " ")
				--.. lain.util.markup.font("tamsyn "..widgets.text_size,nowplaying)
				--.. lain.util.markup.font("Tamsyn 2", " ")

				--nowplayingtext = mpd_now.artist.." "..mpd_now.title
				--nowplayingtext = utf8.sub(nowplayingtext, 0, 35)
				--nowplayingtext = string.reverse(nowplayingtext)
				--print(nowplayingtext)
				--widget:set_markup(nowtext)
				widgets.set_markup(widget,nowplaying)

				--play_pause_icon:set_image(beautiful.mpd_pause)
				--mpd_sepl:set_image(beautiful.mpd_sepl)
				--mpd_sepr:set_image(beautiful.mpd_sepr)
			elseif mpd_now.state == "pause" then
				widgets.set_markup(widget,"MPD PAUSED")
				--widget:set_markup( lain.util.markup.font("Tamsyn 4", "") ..
				--markup.font("Tamsyn 9", "MPD PAUSED") ..
				--markup.font("Tamsyn 10", ""))
				--play_pause_icon:set_image(beautiful.mpd_play)
				--mpd_sepl:set_image(beautiful.mpd_sepl)
				--mpd_sepr:set_image(beautiful.mpd_sepr)
				--else
				--mpdwidget.mpdwidget:set_text("")
				----play_pause_icon:set_image(beautiful.mpd_play)
				--mpd_sepl:set_image(nil)
				--mpd_sepr:set_image(nil)
			end
		end
	})
	mpdwidget.mpdwidget = widget
	mpdwidget.update = widget.update
	mpdwidget.mpdwidget.state = ""
	--print(mpdwidget.mpdwidget.state)



	local scroll = wibox.widget {
		layout = wibox.container.scroll.horizontal,
		max_size = 200,
		--extra_space = 100,
		expand = true,
		step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
		speed = 50,
		widget.widget,
	}
	musicwidget = widgetcreator(
	{
		textboxes = {scroll}
	})
	musicwidget:buttons(awful.util.table.join(
	awful.button({ }, 12, function () run_once("cantata") end),
	awful.button({ }, 2, function () run_once("cantata") end),
	awful.button({ }, 3, function () mpdwidget.seek_forward()  end),
	awful.button({ }, 1, function () mpdwidget.seek_backward() end),
	awful.button({"Ctrl" }, 1, function () mpdwidget.prev() end),
	awful.button({"Ctrl" }, 3, function () mpdwidget.play_pause() end),
	awful.button({"Ctrl" }, 2, function () mpdwidget.next() end)
	))
	scroll:pause()

	musicwidget:connect_signal("mouse::enter",
	function () 
		scroll:continue()
		widget.scrolling = true
		helpers.set_map("current mpd track", "")
		widget.update()
	end)
	musicwidget:connect_signal("mouse::leave",
	function () 
		scroll:reset_scrolling()
		scroll:pause()
		widget.scrolling = false
		widget.update()
		if widget and widget.id then
			naughty.destroy(naughty.getById(widget.id),true)
		end
	end)
	return musicwidget
end
function mpdwidget.prev()
	awful.spawn.with_shell("mpc prev & ")
	mpdwidget.update()
end
function mpdwidget.next()
	awful.spawn.with_shell("mpc next & ")
	mpdwidget.update()
end
function mpdwidget.stop()
	--play_pause_icon:set_image(beautiful.play)
	awful.spawn.with_shell("mpc stop & ")
	mpdwidget.update()
end
function mpdwidget.play_pause()
	awful.spawn.with_shell("mpc toggle & ")
	mpdwidget.update()
end
function mpdwidget.play()
	awful.spawn.with_shell("mpc play & ")
	mpdwidget.update()
end
function mpdwidget.pause()
	awful.spawn.with_shell("mpc pause & ")
	mpdwidget.update()
end
function mpdwidget.seek_forward()
	awful.spawn.with_shell("mpc seek +00:00:10 &")
	mpdwidget.update()
end
function mpdwidget.seek_backward()
	awful.spawn.with_shell("mpc seek -00:00:10 &")
	mpdwidget.update()
end
function mpdwidget.mpriscontrol(str)
	--local command = "dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.bomi /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."
	local command = "mpris2controller "
	if str == "play" then
		command = command.."Play"
	elseif str == "pause" then
		command = command.."Pause"
	elseif str == "next" then
		command = command.."Next"
	elseif str == "prev" then
		command = command.."Prev"
	elseif str == "play_pause" then
		command = command.."PlayPause"
	end
	command = command.." &"
	os.execute(command)
	--awful.spawn.with_shell(command)
end
mpdwidget.lastmpdstatus = "N/A"
function mpdwidget.playif()
	if mpdwidget.lastmpdstatus and mpdwidget.lastmpdstatus == "play" then
		mpdwidget.play()
	end
end
function mpdwidget.pauseif()
	mpdwidget.lastmpdstatus = mpdwidget.mpdwidget.state
	mpdwidget.pause()
end

return setmetatable(mpdwidget, {__call = function(_,...) return worker(...) end})
