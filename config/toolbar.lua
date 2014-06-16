local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local vicious = require("vicious")
local naughty = require("naughty")

local screen = screen
local client = client
local mouse = mouse

local configpath = awful.util.getdir("config")
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

-------------------------------------------------------------------------------------------
-- Виджет использования процессора
-------------------------------------------------------------------------------------------
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(configpath .. "/themes/default/widgets/cpu.png")
cpuwidget = awful.widget.graph()
-- Свойства графика
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 0,10 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, {1, "#AECF96" }}})
-- Регистрация виджета
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

-------------------------------------------------------------------------------------------
-- Виджет заряда батареи
-------------------------------------------------------------------------------------------
batt = wibox.widget.textbox()
vicious.register(batt, vicious.widgets.bat, "Batt: $2% Rem: $3", 61, "BAT0")

battext = wibox.widget.textbox("battext")
battext1 = wibox.widget.textbox("battext")
function battery_status_text(widget, args)
    local perc = args[2]
    if perc < 15 then
        return '<span color="red">' .. perc .. '%</span>'
    elseif perc < 50 then
        return '<span color="yellow">' .. perc .. '%</span>'
    end
    return '<span color="#8EAE6E">' .. perc .. '%</span>'
end
vicious.register(battext, vicious.widgets.bat, battery_status_text, 120, "BAT0")
vicious.register(battext1, vicious.widgets.bat, battery_status_text, 120, "BAT1")

-- Icon
baticon = wibox.widget.imagebox()
--baticon:set_image(beautiful.widget_batfull)
baticon:set_image(configpath .. "/themes/default/widgets/bat.png")


-------------------------------------------------------------------------------------------
-- Виджет использования памяти
-------------------------------------------------------------------------------------------
memicon = wibox.widget.imagebox()
--memicon:set_image(beautiful.widget_memfull)
memicon:set_image(configpath .. "/themes/default/widgets/ram.png")
-- Регистрация виджета
memwidget = wibox.widget.textbox("battext")
vicious.register(memwidget, vicious.widgets.mem, function(widget, args)
  mem_procent  = args[1]
  mem_used = args[2]
  mem_total   = args[3]
  mem_free   = args[4]
  return args[1] .. "%"
end, nil, 13)
--Всплывающее меню
function popup_mem()
  naughty.notify { 
      title = "Использование памяти", 
      text = "Занято      : ".. mem_used .."Mb\nСвободно    : " .. mem_free .. "Mb\nВсего       : " .. mem_total .. "Mb", 
      timeout = 5, 
      hover_timeout = 0.5 }
end
memicon:buttons(awful.util.table.join(awful.button({ }, 1, popup_mem)))
memwidget:buttons(awful.util.table.join(awful.button({ }, 1, popup_mem)))
-------------------------------------------------------------------------------------------
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
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)
    --right_layout:add(batwidget)
    right_layout:add(baticon)
    right_layout:add(battext)
    right_layout:add(baticon)
    right_layout:add(battext1)
    --right_layout:add(batwidget1)
    right_layout:add(memicon)
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
