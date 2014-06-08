local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local vicious = require("vicious")

local screen = screen
local client = client
local mouse = mouse

--local actionless = require("actionless")
--local widgets = actionless.widgets
--local custom_tasklist = actionless.tasklist
--local rpic = widgets.random_pic


local toolbar = {}


function toolbar.init(status)
local modkey = status.modkey

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

--cpuicon = awful.widget.imagebox()
--cpuicon.image = image(beautiful.widget_cpu)
cpuwidget = awful.widget.graph()
-- Свойства графика
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 0,10 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, {1, "#AECF96" }}})
-- Регистрация виджета
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

--Battery Widget
batt = wibox.widget.textbox()
vicious.register(batt, vicious.widgets.bat, "Batt: $2% Rem: $3", 61, "BAT1")

batwidget = awful.widget.progressbar()
  batwidget:set_width(8)
  batwidget:set_height(10)
  batwidget:set_vertical(true)
  batwidget:set_background_color("#494B4F")
  batwidget:set_border_color(nil)
  batwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 10 }, stops = { { 0, "#AECF96" }, { 0.5, "#88A175" }, { 1, "#FF5656" }}})
  vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT1")
  --vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT1")
-- Инициализация виджета
memwidget = awful.widget.progressbar()
-- Свойства индикатора
memwidget:set_width(8)
memwidget:set_height(10)
memwidget:set_vertical(true)
memwidget:set_background_color("#494B4F")
memwidget:set_border_color(nil)
memwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 0,10 }, stops = { {1, "#AECF96"}, {0.5, "#88A175"}, 
                    {0, "#FF5656"}}})
-- Регистрация виджета
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)
-- Create a wibox for each screen and add it
local mywibox = {}
mypromptbox = {}
local mylayoutbox = {}
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
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
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(status.layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(status.layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(status.layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(status.layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(status.widgets.launcher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    --right_layout:add(cpuicon)
    right_layout:add(batwidget)
    right_layout:add(batt)
    right_layout:add(cpuwidget)
    right_layout:add(memwidget)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

end
-- }}}

end
return toolbar
