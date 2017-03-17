require("naughty")
require("taskwarrior")

---------------------------------
-- taskwarrior duetasks widget
---------------------------------
taskswidget = widget({type = "textbox"})
taskswidget.text = get_duetask();

-- TODO integrate 'taskswidget' into wibox

-- go through due tasks on mouse clicks
taskswidget:buttons(awful.util.table.join(
	awful.button({ }, 1, function() taskswidget.text = next_duetask() end),
	awful.button({ }, 3, function() taskswidget.text = prev_duetask() end)))

---------------------------------
-- taskwarrior notification widget
---------------------------------

add_notification()

-- TODO set a key to toggle the notification
-- awful.key({ }, "#111", function () toggle_notification() end),

