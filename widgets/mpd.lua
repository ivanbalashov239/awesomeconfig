local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local utf8 	 = require("utf8_simple")
local read_pipe    = require("lain.helpers").read_pipe

local mpdwidget ={}
mpdwidget.shortcuts = {}

local function worker(args)
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
	local mpd_sepl = wibox.widget.imagebox()
	mpd_sepl:set_image(beautiful.mpd_sepl)
	local mpd_sepr = wibox.widget.imagebox()
	mpd_sepr:set_image(beautiful.mpd_sepr)
	local mpd_skip_timer = timer({timeout=0.5})
	mpd_skip_timer:connect_signal("timeout", function ()
		local cur_rate = read_pipe('python3 /home/ivn/scripts/rate_current_mpd_song.py get rating')
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
		elseif skip_unrated then
			--os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 1")
			mpdwidget.next()
		end
	end)
	--mpd_skip_timer:start()

	local widget = lain.widgets.mpd({
		--notify = "off",
		settings = function ()
			mpdwidget.mpdwidget.state = mpd_now.state
			if mpd_now.state == "play" then
				--print(mpd_now.title)
				mpd_skip_timer:emit_signal("timeout")
				mpdwidget.mpdwidget:set_markup(" Title loading ")
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
				nowplayingtext = mpd_now.artist .. "-" .. mpd_now.title .. " "
				mpdwidget.mpdwidget.nowplaying = nowplayingtext
				nowtext = markup.font("Tamsyn 3", " ")
				.. markup.font("tamsyn 7",
				artistsub
				.. "—" ..
				titlesub)
				.. markup.font("Tamsyn 2", " ")

				--nowplayingtext = mpd_now.artist.." "..mpd_now.title
				--nowplayingtext = utf8.sub(nowplayingtext, 0, 35)
				--nowplayingtext = string.reverse(nowplayingtext)
				--print(nowplayingtext)
				mpdwidget.mpdwidget:set_markup(nowtext)

				--play_pause_icon:set_image(beautiful.mpd_pause)
				mpd_sepl:set_image(beautiful.mpd_sepl)
				mpd_sepr:set_image(beautiful.mpd_sepr)
			elseif mpd_now.state == "pause" then
				mpdwidget.mpdwidget:set_markup(markup.font("Tamsyn 4", "") ..
				markup.font("Tamsyn 7", "MPD PAUSED") ..
				markup.font("Tamsyn 10", ""))
				--play_pause_icon:set_image(beautiful.mpd_play)
				mpd_sepl:set_image(beautiful.mpd_sepl)
				mpd_sepr:set_image(beautiful.mpd_sepr)
			else
				mpdwidget.mpdwidget:set_markup("")
				--play_pause_icon:set_image(beautiful.mpd_play)
				mpd_sepl:set_image(nil)
				mpd_sepr:set_image(nil)
			end
		end
	})
	mpdwidget.update = widget.update
	mpdwidget.mpdwidget = widget
	mpdwidget.mpdwidget.state = ""
	print(mpdwidget.mpdwidget.state)
	widget.nextchar = function()
		if mpd_now.state == "play" then
			--widget.nowplaying = "123456789abcdefghijklmnoprst"
			text = mpdwidget.mpdwidget.nowplaying.."|"
			--text = string.gsub(widget.nowplaying,"&apos;","'")
			mpdlength = utf8.len(text)
			startpos = math.fmod(widget.startpos, mpdlength)
			if startpos == 0 then startpos = mpdlength end
			length   = widget.length or 20
			--print("start:"..startpos)
			--print("length:"..length)
			--print("mpdlength:"..mpdlength)
			nowtext = text
			--print(mpdlength)
			--print(length)
			if not (mpdlength < length) then
				if ((startpos + length - 1) > mpdlength) then
					--print("problem")
					nowtext = utf8.sub(text, startpos) .. utf8.sub(text,1, math.abs(mpdlength-startpos+1-length))
				else
					nowtext = utf8.sub(text, startpos, startpos+length-1)
				end
			end
			--for k,v in pairs(widget) do
			--print(k)
			--end
			widget.startpos = startpos + 1
			widget.widget:set_markup(markup.font("Tamsyn 7", nowtext))
			--print(nowtext)
		end
	end



	musicwidget = widgetcreator(
	{
		textboxes = {widget}
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
	local runinglinetimer = timer({ timeout = 0.2 })
	runinglinetimer:connect_signal("timeout", function ()
		widget.nextchar()
	end)

	musicwidget:connect_signal("mouse::enter",
	function () 
		if lain.helpers.timer_table["mpd"] then
			lain.helpers.timer_table["mpd"]:stop()
		end
		widget.length = 20
		widget.startpos = 1
		runinglinetimer:start()
	end)
	musicwidget:connect_signal("mouse::leave",
	function () 
		runinglinetimer:stop()
		widget.update()
		if lain.helpers.timer_table["mpd"] then
			lain.helpers.timer_table["mpd"]:start()
		end
	end)

	--prev_icon:buttons(awful.util.table.join(
	--awful.button({}, 1, function () mpd_prev() end),
	--awful.button({ }, 4, function () mpd_seek_forward()  end),
	--awful.button({ }, 5, function () mpd_seek_backward() end),
	--awful.button({ }, 3, function () mpd_seek_backward() end)

	--))
	--next_icon:buttons(awful.util.table.join(
	--awful.button({}, 1, function () mpd_next() end),
	--awful.button({ }, 3, function () mpd_seek_forward()  end),
	--awful.button({ }, 4, function () mpd_seek_forward()  end),
	--awful.button({ }, 5, function () mpd_seek_backward() end)

	--))
	--stop_icon:buttons(awful.util.table.join(
	--awful.button({}, 1, function () mpd_stop() end),
	--awful.button({ }, 4, function () mpd_seek_forward()  end),
	--awful.button({ }, 5, function () mpd_seek_backward() end)

	--))
	--play_pause_icon:buttons(awful.util.table.join(
	--awful.button({}, 1, function () mpd_play_pause() end),
	--awful.button({ }, 4, function () mpd_seek_forward()  end),
	--awful.button({ }, 5, function () mpd_seek_backward() end)

	--))
	return musicwidget
end
function mpdwidget.prev()
	awful.util.spawn_with_shell("mpc prev & ")
	mpdwidget.update()
end
function mpdwidget.next()
	awful.util.spawn_with_shell("mpc next & ")
	mpdwidget.update()
end
function mpdwidget.stop()
	--play_pause_icon:set_image(beautiful.play)
	awful.util.spawn_with_shell("mpc stop & ")
	mpdwidget.update()
end
function mpdwidget.play_pause()
	awful.util.spawn_with_shell("mpc toggle & ")
	mpdwidget.update()
end
function mpdwidget.play()
	awful.util.spawn_with_shell("mpc play & ")
	mpdwidget.update()
end
function mpdwidget.pause()
	awful.util.spawn_with_shell("mpc pause & ")
	mpdwidget.update()
end
function mpdwidget.seek_forward()
	awful.util.spawn_with_shell("mpc seek +00:00:10 &")
	mpdwidget.update()
end
function mpdwidget.seek_backward()
	awful.util.spawn_with_shell("mpc seek -00:00:10 &")
	mpdwidget.update()
end

return setmetatable(mpdwidget, {__call = function(_,...) return worker(...) end})
