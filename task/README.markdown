These lua scripts can be used to integrate taskwarrior into the awesome window manager.

#Features
There are two types of widget you can use, namely a naughty based list of all your tasks tagged with +todo (tasklist widget) and a textbox based widget that displays overdue tasks (duetasks widget). The `screenshot.png` shows both widgets in use.

#Installation
First of all, you need to compile taskwarrior with lua support by running the configure script with `--with-lua`.

## Configure taskwarrior
Copy the file `awesome.lua` into `~/.task/` and add the lines from `append_to_taskrc` to your `.taskrc`.

## Configure awesome
Copy the remaining lua files into `~/.config/awesome` and modify your rc.lua as the file `rc_example.lua` proposes. 

You might also want to customize the taskwarrior report that will be used for the tasklist widget by editing `task.lua`.

#Contribution
Feel free to contribute to this project.

#Links
[http://www.taskwarrior.org](http://www.taskwarrior.org)

[http://awesome.naquadah.org](http://awesome.naquadah.org)
