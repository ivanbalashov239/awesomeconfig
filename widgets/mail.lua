local widgetcreator = require("widgets")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local naughty = require("naughty")

local mailwidget ={}
mailwidget.shortcuts = {}

local function worker(args)
	local ignoremail = {
		"[Gmail].Trash",
		"[Gmail].Spam",
		"[Gmail].All Mail",
		"[Gmail].Drafts",
		"[Gmail].Important",
		"[Gmail].Sent Mail",
		"[Gmail].Starred",
		"[Gmail].Junk",
		"[Gmail].Starred",
		"Drafts",
		"Junk",
		"Notes",
		"Trash",
		"Личные",
		"Путешествие",
		"Работа",
		"Счета",
		"Спам",
		"[Mailbox]",
		"[Mailbox].Later",
		"[Mailbox].To buy",
		"[Mailbox].To Read",
		"[Mailbox].To Watch",
	}
	local function mailnotif(args)
		return naughty.notify({
			title = args.title,
			text = args.text,
			icon = args.icon or "/home/ivn/Загрузки/KFaenzafordark/status/32/mail-queued.png",
			timeout = args.timeout,
			screen = mouse.screen or 1,
			run = args.run,
		})
	end

	local function getmailwidget(args)
		local args = args or {}
		args.total = 0
		args.newmail = ""
		args.mailbox = args.mailbox or ""
		local function run() 
			local cm = mutt.." /home/ivn/.mutt/"..args.mailbox.."'"
			run_or_raise(cm, { class = "UXTerm" }) 
		end
		args.textbox = lain.widgets.maildir({
			mailpath = "/home/ivn/Mail/"..args.mailbox,
			settings = function()
				args.textbox:set_text(total) --newmail)
				args.total = total
				args.newmail = newmail
				if total > 0 then
					args.textbox:show(args.notiftimeout or 10)
					--mailnotif({
					--title = args.mailbox,
					--text = newmail,
					--timeout = args.notiftimeout or 10,
					--})
				end
			end,
			ignore_boxes = ignoremail,
			timeout = args.timertimeout or 30,
		})
		local mail_notify = nil
		function args.textbox:hide()
			if mail_notify ~= nil then
				naughty.destroy(mail_notify)
				mail_notify = nil
			end
		end
		function args.textbox:show(t_out)
			args.textbox:hide()
			mail_notify = mailnotif({
				title = args.mailbox,
				text = args.newmail ~= "" and args.newmail or args.total,
				icon = "/home/ivn/Mail/"..args.mailbox..".png",
				timeout = t_out,
				run = run,
			})
		end
		function args.textbox:attach(widget)
			widget:connect_signal('mouse::enter', function () args.textbox:show(0) end)
			widget:connect_signal('mouse::leave', function () args.textbox:hide()  end)
		end
		local mailbuttons = awful.util.table.join(awful.button({ }, 1,
		run
		))
		args.textbox:buttons(mailbuttons)
		args.textbox:set_text("0")
		local timer = timer({ timeout = 1 })
		timer:connect_signal("timeout", function ()
			if lain.helpers and lain.helpers.timer_table and lain.helpers.timer_table["/home/ivn/Mail/"..args.mailbox] then
				lain.helpers.timer_table["/home/ivn/Mail/"..args.mailbox]:emit_signal("timeout")
				timer:stop()
			end
		end)
		timer:start()
		return args.textbox
	end

	
	local mail_widget3 = getmailwidget({mailbox = "FateGmail", textbox = mail_widget3})
	--local mail_widget2 = getmailwidget({mailbox = "FateYandex", textbox = mail_widget2 }) 
	local mail_widget1 = getmailwidget({mailbox = "Personal", textbox = mail_widget1})
	local mailwidget = widgetcreator({
		text = "MAIL",
		textboxes = {mail_widget1, mail_widget3 }, --2, mail_widget3},
	})
	mail_widget3:attach(mailwidget)
	--mail_widget2:attach(mailwidget)
	mail_widget1:attach(mailwidget)
	mailwidget:buttons(awful.util.table.join(awful.button({ }, 1,
	function ()
		local timer = timer({ timeout = 1 })
		timer:connect_signal("timeout", function ()
			local cm = mutt.." /home/ivn/.mutt/Personal'"
			run_or_raise(cm, { class = "UXTerm" }) 
			timer:stop()
		end)
		timer:start()
	end),
	awful.button({ }, 2,
	function ()
		local timer = timer({ timeout = 1 })
		timer:connect_signal("timeout", function ()
			local cm = mutt.." /home/ivn/.mutt/FateYandex'"
			run_or_raise(cm, { class = "UXTerm" }) 
			timer:stop()
		end)
		timer:start()
	end),
	awful.button({ }, 3,
	function ()
		local timer = timer({ timeout = 1 })
		timer:connect_signal("timeout", function ()
			local cm = mutt.." /home/ivn/.mutt/FateGmail'"
			run_or_raise(cm, { class = "UXTerm" }) 
			timer:stop()
		end)
		timer:start()
	end)
	))
	--wibox.widget.textbox()
	--vicious.register(mail_widget, vicious.widgets.gmail, vspace1 .. "${count}" .. vspace1, 1200)

	--widget_mail = wibox.widget.imagebox()
	--widget_mail:set_image(beautiful.widget_mail)
	--mailwidget = wibox.widget.background()
	--mailwidget:set_widget(mail_widget)
	--mailwidget:set_bgimage(beautiful.widget_display)
	return mailwidget
end

return setmetatable(mailwidget, {__call = function(_,...) return worker(...) end})
