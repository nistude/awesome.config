-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")

-- Widget library
require("vicious")

-- Scratchpad
require("scratch")

-- Notifications
require("naughty")

naughty.config.default_preset.timeout = 10
naughty.config.default_preset.screen  = mouse.screen

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/sturm/.config/awesome/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator --color-scheme=Hemisu"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    settings = {
        { layout = { layouts[6], layouts[6], layouts[6], layouts[6] } },
        { layout = { layouts[6], layouts[6], layouts[6], layouts[6] } }
    }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4 }, s, tags.settings[s].layout)
end

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- battery widget
has_battery = awful.util.file_readable("/sys/class/power_supply/BAT0")
batbar = awful.widget.progressbar()
batbar:set_vertical(true):set_ticks(true)
batbar:set_height(18):set_width(10):set_ticks_size(2)
batbar:set_background_color(beautiful.fg_off_widget)
batbar:set_gradient_colors({
  beautiful.fg_end_widget,
  beautiful.fg_center_widget,
  beautiful.fg_widget
})
vicious.register(batbar, vicious.widgets.bat, "$2", 60, "BAT0")

batwidget = widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat, "$1/$3 ", 60, "BAT0")

-- cpu widget
cpugraph = awful.widget.graph()
cpugraph:set_width(40):set_height(18)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_gradient_angle(0):set_gradient_colors({
    beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
})
vicious.register(cpugraph, vicious.widgets.cpu, "$1", 1)

-- disk I/O widget
diskgraph = awful.widget.graph()
diskgraph:set_width(40):set_height(18)
diskgraph:set_background_color(beautiful.fg_off_widget)
diskgraph:set_gradient_angle(0):set_color(beautiful.fg_end_widget)
vicious.register(diskgraph, vicious.widgets.dio, "${sda total_kb}", 1)

-- memory usage widget
membar = awful.widget.progressbar()
membar:set_vertical(true):set_ticks(true)
membar:set_height(18):set_width(10):set_ticks_size(2)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_gradient_colors({
    beautiful.fg_widget,
    beautiful.fg_center_widget,
    beautiful.fg_end_widget
})
vicious.register(membar, vicious.widgets.mem, "$1", 10)

-- network usage widget
netwidget_down = widget({ type = "textbox" })
vicious.register(netwidget_down, vicious.widgets.net, '${eth0 down_kb}/${wlan0 down_kb}')
downicon = widget({ type = "imagebox" })
downicon.image = image(beautiful.widget_net_down)

netwidget_up = widget({ type = "textbox" })
vicious.register(netwidget_up, vicious.widgets.net, '${eth0 up_kb}/${wlan0 up_kb}')
upicon = widget({ type = "imagebox" })
upicon.image = image(beautiful.widget_net_up)

-- pomodoro timer widget
pomodoro = {}
-- tweak these values in seconds to your liking
pomodoro.pause_duration = 300
pomodoro.work_duration = 1500

pomodoro.pause_title = "Pause finished."
pomodoro.pause_text = "Get back to work!"
pomodoro.work_title = "Pomodoro finished."
pomodoro.work_text = "Time for a pause!"
pomodoro.working = true
pomodoro.left = pomodoro.work_duration
pomodoro.widget = widget({ type = "textbox" })
pomodoro.timer = timer { timeout = 1 }

function pomodoro:start()
	pomodoro.last_time = os.time()
	pomodoro.timer:start()
end

function pomodoro:stop()
	pomodoro.timer:stop()
end

function pomodoro:reset()
	pomodoro.timer:stop()
	pomodoro.left = pomodoro.work_duration
	pomodoro:settime(pomodoro.work_duration)
end

function pomodoro:settime(t)
  if t >= 3600 then -- more than one hour!
    t = os.date("%X", t-3600)
  else
    t = os.date("%M:%S", t)
  end
  self.widget.text = string.format("Pomodoro: <b>%s</b>", t)
end

function pomodoro:notify(title, text, duration, working)
  naughty.notify {
    bg = "#ff0000",
    fg = "#ffffff",
    font = "Verdana 20",
    screen = mouse.screen,
    title = title,
    text  = text,
    timeout = 10,
    icon = "/usr/share/app-install/icons/_usr_share_pixmaps_tomatoes_icon.png"
  }

  pomodoro.left = duration
  pomodoro:settime(duration)
  pomodoro.working = working
end

pomodoro:settime(pomodoro.work_duration)

pomodoro.widget:buttons(
  awful.util.table.join(
    awful.button({ }, 1, function() pomodoro:start() end),
    awful.button({ }, 2, function() pomodoro:stop() end),
    awful.button({ }, 3, function() pomodoro:reset() end)
))

pomodoro.timer:add_signal("timeout", function()
  local now = os.time()
  pomodoro.left = pomodoro.left - (now - pomodoro.last_time)
  pomodoro.last_time = now

  if pomodoro.left > 0 then
    pomodoro:settime(pomodoro.left)
  else
    if pomodoro.working then
      pomodoro:notify(pomodoro.work_title, pomodoro.work_text,
	pomodoro.pause_duration, false)
    else
      pomodoro:notify(pomodoro.pause_title, pomodoro.pause_text,
        pomodoro.work_duration, true)
    end
    pomodoro.timer:stop()
  end
end)

-- Volume widget

volumecfg = {}

local fd = io.popen("hostname")
local hostname = fd:read()
fd:close()
if hostname == "desktop" then
  volumecfg.cardid  = 1
  volumecfg.channel = "PCM"
else
  volumecfg.cardid  = 0
  volumecfg.channel = "Master"
end

volumecfg.widget = widget({ type = "textbox", name = "volumecfg.widget", align = "right" })

volumecfg_t = awful.tooltip({ objects = { volumecfg.widget },})
volumecfg_t:set_text("Volume")

-- command must start with a space!
volumecfg.mixercommand = function (command)
  local fd = io.popen("amixer -c " .. volumecfg.cardid .. command)
  local status = fd:read("*all")
  fd:close()

  local volume = string.match(status, "(%d?%d?%d)%%")
  volume = string.format("% 3d", volume)
  status = string.match(status, "%[(o[^%]]*)%]")
  if string.find(status, "on", 1, true) then
    volume = volume .. "%"
  else
    volume = volume .. "M"
  end
  volumecfg.widget.text = volume
end
volumecfg.update = function ()
  volumecfg.mixercommand(" sget " .. volumecfg.channel)
end
volumecfg.up = function ()
  volumecfg.mixercommand(" sset " .. volumecfg.channel .. " 1%+ unmute")
end
volumecfg.down = function ()
  volumecfg.mixercommand(" sset " .. volumecfg.channel .. " 1%-")
end
volumecfg.toggle = function ()
  volumecfg.mixercommand(" sset " .. volumecfg.channel .. " toggle")
end
volumecfg.widget:buttons(
  awful.util.table.join(
    awful.button({ }, 4, function () volumecfg.up() end),
    awful.button({ }, 5, function () volumecfg.down() end),
    awful.button({ }, 1, function () volumecfg.toggle() end)
))
volumecfg.update()

-- weather widget
weatherwidget = widget({ type = "textbox" })
vicious.register(weatherwidget, vicious.widgets.weather, "${sky} ${tempc}°C", 1800, "EDDM")

-- Create a separator
separator = widget({ type = "textbox" })
separator.text = " :: "

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, "%a %b %d %H:%M:%S ", 1)

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
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

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
 	separator, weatherwidget,
	separator, pomodoro.widget,
        separator, volumecfg.widget,
        has_battery and separator,
        has_battery and batbar.widget,
        has_battery and batwidget,
 	separator, membar.widget,
 	separator, cpugraph.widget,
 	separator, diskgraph.widget,
 	separator, upicon, netwidget_up, downicon, netwidget_down,
	separator,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

function lock_screen()
  os.execute("gnome-screensaver-command --lock && sleep 5")
end

function suspend()
  lock_screen()
  os.execute("sudo pm-suspend")
end

function hibernate()
  lock_screen()
  os.execute("sudo pm-hibernate")
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),

    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "Tab", function () awful.screen.focus_relative( 1) end),

    -- Layout manipulation
    awful.key({ modkey,           }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey,           }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,           }, "l", function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h", function () awful.tag.incmwfact(-0.05)    end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "q", awesome.quit),

    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "/",     function () mypromptbox[mouse.screen]:run() end),

    -- Custom
    awful.key({ modkey }, "F9", function () pomodoro:start() end),
    awful.key({ modkey }, "F10", function () pomodoro:stop() end),
    awful.key({ modkey }, "F11", function () pomodoro:reset() end),

    awful.key({ modkey }, "F12",
    	function ()
            -- Setup terminal on current tag
	    awful.util.spawn("roxterm -T mutt@work -e mutt")
	    awful.util.spawn("roxterm -T mutt@home -e ssh -t nst.homeunix.net mutt")
	    awful.util.spawn("pidgin")

	    -- Rule sets tag
	    awful.util.spawn("google-chrome")
	end),
    awful.key({ modkey }, "b", function () scratch.drop(terminal .. " -e vim /home/sturm/braindump", nil, nil, 0.5) end),
    -- awful.key({ modkey }, "l", function () scratch.drop(terminal .. " -e vim /home/sturm/logbuch", nil, nil, 0.5) end),
    awful.key({}, "XF86AudioMute", function () volumecfg.toggle() end),
    awful.key({}, "XF86AudioLowerVolume", function () volumecfg.down() end),
    awful.key({}, "XF86AudioRaiseVolume", function () volumecfg.up() end),
    awful.key({}, "XF86ScreenSaver", function () lock_screen() end),
    awful.key({}, "XF86Sleep", function () suspend() end),
    awful.key({}, "XF86Suspend", function () hibernate() end),
    awful.key({}, "#156", function () os.execute("gksudo -- shutdown -h now") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- bind key numbers to tags
-- we use keycodes to make it work on any keyboard layout
-- tags 1..4 are located on screen 1
-- tags 5..8 are located on screen 2
for i = 1, 4 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function ()
	    local screen = 1
            if tags[screen][i] then
                awful.tag.viewonly(tags[screen][i])
            end
        end),
	awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
	    end
	end)
    )
end
for i = 1, 4 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 4 + 9, function ()
            local screen = 2
            if tags[screen][i] then
                awful.tag.viewonly(tags[screen][i])
            end
        end),
	awful.key({ modkey, "Shift" }, "#" .. i + 4 + 9, function ()
	    if client.focus and tags[client.focus.screen][i] then
		awful.client.movetotag(tags[client.focus.screen][i])
	    end
	end)
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    -- get window class with xprop
    { rule = { class = "Evince" }, properties = { floating = true } },
    { rule = { class = "Firefox" }, properties = { tag = tags[1][3] } },
    { rule = { class = "Google-chrome" }, properties = { tag = tags[1][2] } },
    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "Mysql-workbench-bin" }, properties = { floating = true } },
    { rule = { class = "Opera" }, properties = { tag = tags[1][3] } },
    { rule = { class = "Unison" }, properties = { floating = true } },
    { rule = { class = "VirtualBox" }, properties = { floating = true } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Start some additional GNOME applets
os.execute("xsettingsd &")
os.execute("pgrep nm-applet > /dev/null || nm-applet &")
os.execute("gnome-screensaver &")
awful.util.spawn("/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
awful.util.spawn("gnome-keyring-daemon")
awful.util.spawn("update-notifier")
