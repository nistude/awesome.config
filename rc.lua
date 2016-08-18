-- Standard awesome library
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Theme handling library
local beautiful = require("beautiful")

-- Widget library
local vicious = require("vicious")
local wibox = require("wibox")

-- Notifications
local naughty = require("naughty")

naughty.config.presets.low.timeout = 10
naughty.config.presets.normal.timeout = 10
naughty.config.presets.critical.timeout = 10
naughty.config.defaults.screen  = mouse.screen

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

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

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- battery widget
has_battery0 = awful.util.file_readable("/sys/class/power_supply/BAT0")
batbar0 = awful.widget.progressbar()
batbar0:set_vertical(true):set_ticks(true)
batbar0:set_height(18):set_width(10):set_ticks_size(2)
batbar0:set_background_color(beautiful.fg_off_widget)
batbar0:set_color({
  type = "linear", from = { 0, 0 }, to = { 0, 18 },
  stops = {
    { 0, beautiful.fg_end_widget, },
    { 0.5, beautiful.fg_center_widget, },
    { 1, beautiful.fg_widget }
  }
})
vicious.register(batbar0, vicious.widgets.bat, "$2", 60, "BAT0")

batwidget0 = wibox.widget.textbox()
vicious.register(batwidget0, vicious.widgets.bat, "$1/$3 ", 60, "BAT0")

has_battery1 = awful.util.file_readable("/sys/class/power_supply/BAT1")
batbar1 = awful.widget.progressbar()
batbar1:set_vertical(true):set_ticks(true)
batbar1:set_height(18):set_width(10):set_ticks_size(2)
batbar1:set_background_color(beautiful.fg_off_widget)
batbar1:set_color({
  type = "linear", from = { 0, 0 }, to = { 0, 18 },
  stops = {
    { 0, beautiful.fg_end_widget, },
    { 0.5, beautiful.fg_center_widget, },
    { 1, beautiful.fg_widget }
  }
})
vicious.register(batbar1, vicious.widgets.bat, "$2", 60, "BAT1")

batwidget1 = wibox.widget.textbox()
vicious.register(batwidget1, vicious.widgets.bat, "$1/$3 ", 60, "BAT1")
-- cpu widget
cpugraph = awful.widget.graph()
cpugraph:set_width(40):set_height(18)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_color({
  type = "linear", from = { 0, 0 }, to = { 0, 18 },
  stops = {
    { 0, beautiful.fg_end_widget },
    { 0.5, beautiful.fg_center_widget },
    { 1, beautiful.fg_widget }
  }
})
vicious.register(cpugraph, vicious.widgets.cpu, "$1", 1)
cpugraph_mirrored = wibox.layout.mirror(cpugraph, { vertical = true })

-- disk I/O widget
diskgraph = awful.widget.graph()
diskgraph:set_width(40):set_height(18)
diskgraph:set_background_color(beautiful.fg_off_widget)
diskgraph:set_color(beautiful.fg_end_widget)
vicious.register(diskgraph, vicious.widgets.dio, "${sda total_kb}", 1)
diskgraph_mirrored = wibox.layout.mirror(diskgraph, { vertical = true })

-- memory usage widget
membar = awful.widget.progressbar()
membar:set_vertical(true):set_ticks(true)
membar:set_height(18):set_width(10):set_ticks_size(2)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_color({
  type = "linear", from = { 0, 0 }, to = { 0, 10 },
  stops = {
    { 0, beautiful.fg_end_widget },
    { 0.5, beautiful.fg_center_widget },
    { 1, beautiful.fg_widget }
  }
})
vicious.register(membar, vicious.widgets.mem, "$1", 10)

-- network usage widget
netwidget_down = wibox.widget.textbox()
vicious.register(netwidget_down, vicious.widgets.net, '${eth0 down_kb}/${wlan0 down_kb}')
downicon = wibox.widget.imagebox()
downicon:set_image(beautiful.widget_net_down)

netwidget_up = wibox.widget.textbox()
vicious.register(netwidget_up, vicious.widgets.net, '${eth0 up_kb}/${wlan0 up_kb}')
upicon = wibox.widget.imagebox()
upicon:set_image(beautiful.widget_net_up)

-- Volume widget
volumecfg = {}
volumecfg.cardid  = 0
volumecfg.channel = "Master"

volumecfg.widget = wibox.widget.textbox()

volumecfg_t = awful.tooltip({ objects = { volumecfg.widget }})
volumecfg_t:set_text("Volume")

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
  volumecfg.widget:set_text(volume)
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

volumecfg.update()

-- weather widget
weatherwidget = wibox.widget.textbox()
vicious.register(weatherwidget, vicious.widgets.weather, "${sky} ${tempc}°C", 1800, "EDDM")

-- Create a separator
separator = wibox.widget.textbox()
separator:set_text(" :: ")

-- Create a textclock widget
mytextclock = awful.widget.textclock("%a %b %d %H:%M:%S ", 1)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
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
    mypromptbox[s] = awful.widget.prompt()

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 24 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(separator)
    right_layout:add(netwidget_down)
    right_layout:add(downicon)
    right_layout:add(netwidget_up)
    right_layout:add(upicon)
    right_layout:add(separator)
    right_layout:add(diskgraph_mirrored)
    right_layout:add(separator)
    right_layout:add(cpugraph_mirrored)
    right_layout:add(separator)
    right_layout:add(membar)
    if has_battery0 then
        right_layout:add(separator)
        right_layout:add(batwidget0)
        right_layout:add(batbar0)
    end
    if has_battery1 then
        right_layout:add(separator)
        right_layout:add(batwidget1)
        right_layout:add(batbar1)
    end
    right_layout:add(separator)
    right_layout:add(volumecfg.widget)
    right_layout:add(separator)
    right_layout:add(weatherwidget)
    right_layout:add(separator)
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
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
    awful.key({ modkey,           }, "Return", function () awful.util.spawn_with_shell(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "q", awesome.quit),

    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "/",     function () mypromptbox[mouse.screen]:run() end),

    -- Custom
    awful.key({ modkey }, "F12",
    	function ()
            -- Setup terminal on current tag
	    awful.util.spawn_with_shell("roxterm -T mutt@work -e mutt")
	    awful.util.spawn_with_shell("roxterm -T mutt@home -e ssh -t nst.homeunix.net mutt")
	    awful.util.spawn_with_shell("pidgin")

	    -- Rule sets tag
	    awful.util.spawn_with_shell("google-chrome")
	end),
    awful.key({}, "XF86AudioMute", function () volumecfg.toggle() end),
    awful.key({}, "XF86AudioLowerVolume", function () volumecfg.down() end),
    awful.key({}, "XF86AudioRaiseVolume", function () volumecfg.up() end),
    awful.key({ modkey }, "l", function () lock_screen() end),
    awful.key({}, "XF86ScreenSaver", function () lock_screen() end),
    awful.key({}, "XF86Sleep", function () suspend() end),
    awful.key({}, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end),
    awful.key({}, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end),
    --awful.key({}, "XF86Suspend", function () hibernate() end),
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
    { rule = { class = "Firefox" }, properties = { tag = tags[1][4] } },
    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "Mysql-workbench-bin" }, properties = { floating = true } },
    { rule = { class = "Unison" }, properties = { floating = true } },
    { rule = { class = "VirtualBox" }, properties = { floating = true } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
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
    elseif not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count change
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Start some additional GNOME applets
os.execute("xsettingsd &")
os.execute("pgrep nm-applet > /dev/null || nm-applet &")
os.execute("gnome-screensaver &")
os.execute("gtk-redshift -l 48.13:11.54 &")
awful.util.spawn_with_shell("/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
awful.util.spawn_with_shell("gnome-keyring-daemon")
awful.util.spawn_with_shell("update-notifier")
