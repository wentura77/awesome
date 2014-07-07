local wibox         = require("wibox")
local beautiful     = require("beautiful")
local awful         = require("awful")
local vicious       = require("vicious")
local naughty       = require("naughty")
local blingbling    = require("blingbling")
local screen        = screen
local client        = client
local mouse         = mouse

local configpath    = awful.util.getdir("config")
--local actionless = require("actionless")
--local widgets = actionless.widgets
--local custom_tasklist = actionless.tasklist
--local rpic = widgets.random_pic

local toolbar = {}
function toolbar.init(status)
local modkey        = status.modkey

-- {{{ Wibox
-- Create a textclock widget
mytextclock         = awful.widget.textclock()
-------------------------------------------------------------------------------------------
-- Виджет использования процессора
-------------------------------------------------------------------------------------------
    cpuicon             = wibox.widget.imagebox()
    cpuicon:set_image(configpath .. "/themes/default/widgets/cpu.png")
    cpu=blingbling.line_graph.new()
    cpu:set_font_size(12)
    cpu:set_height(22)
    cpu:set_width(60)
    cpu:set_show_text(true)
    cpu:set_label("$percent %")
    cpu:set_graph_color(beautiful.graph_color)
    cpu:set_graph_line_color(beautiful.graph_line_color)
    cpu:set_text_color(beautiful.text_color)
    cpu:set_text_background_color(beautiful.background_text_color)
    cpu:set_h_margin(2)
    vicious.register(cpu, vicious.widgets.cpu, '$1',1)
-------------------------------------------------------------------------------------------
-- Виджет виджет загрузки сети
-------------------------------------------------------------------------------------------
    netwidget = blingbling.net({interface = "wlan0", show_text = true})
    --blingbling.popups.netstat(netwidget, { title_color = beautiful.notify_font_color_1, established_color= beautiful.notify_font_color_3, listen_color=beautiful.notify_font_color_2})
    --netwidget:set_ippopup()
    --netwidget:set_text(true)
    --netwidget:set_v_margin(3)
-------------------------------------------------------------------------------------------
-- Виджет заряда батареи
-------------------------------------------------------------------------------------------
    baticon0 = wibox.widget.imagebox()
    baticon0:set_image(beautiful.widget_batfull)
    baticon1 = wibox.widget.imagebox()
    baticon1:set_image(beautiful.widget_batfull)
    battext             = wibox.widget.textbox("battext")
    battext1            = wibox.widget.textbox("battext")

function battery_status_text(widget, args)
    local perc = args[2]
    if perc < 6 then
        baticon0:set_image(beautiful.widget_batempty)
        return '<span color="red">' .. perc .. '%</span>'
    elseif perc < 35 then
        baticon0:set_image(beautiful.widget_batlow)
        return '<span color="red">' .. perc .. '%</span>'
    elseif perc < 80 then
        baticon0:set_image(beautiful.widget_batmed)
        return '<span color="yellow">' .. perc .. '%</span>'
    end
        baticon0:set_image(beautiful.widget_batfull)
    return '<span color="#8EAE6E">' .. perc .. '%</span>'
end
vicious.register(battext, vicious.widgets.bat, battery_status_text, 120, "BAT0")
vicious.register(battext1, vicious.widgets.bat, battery_status_text, 120, "BAT1")

-------------------------------------------------------------------------------------------
-- Виджет использования памяти
-------------------------------------------------------------------------------------------
    memwidget = blingbling.line_graph.new()
    memwidget:set_font_size(12)
    memwidget:set_height(18)
    memwidget:set_width(60)
    memwidget:set_show_text(true)
    memwidget:set_label("$percent %")
    memwidget:set_background_color("#00000000")
    memwidget:set_graph_color(beautiful.graph_color)
    memwidget:set_graph_line_color(beautiful.graph_line_color)
    memwidget:set_text_color(beautiful.text_color)
    memwidget:set_text_background_color(beautiful.background_text_color)
    memwidget:set_h_margin(2)
    --vicious.register(memwidget, vicious.widgets.mem, "$1", 5)

    memicon = wibox.widget.imagebox()
    --memicon:set_image(beautiful.widget_memfull)
    memicon:set_image(configpath .. "/themes/default/widgets/ram.png")
    vicious.register(memwidget, vicious.widgets.mem, function(widget, args)
        mem_procent  = args[1]
        mem_used = args[2]
        mem_total   = args[3]
        mem_free   = args[4]
        return args[1]
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
-- Виджет виджет звуковой индикации
-------------------------------------------------------------------------------------------
    my_volume=blingbling.volume.new()
    my_volume:set_height(18)
    my_volume:set_v_margin(1)
    my_volume:set_width(20)
    my_volume:update_master()
    my_volume:set_master_control()
    my_volume:set_bar(true)
    my_volume:set_graph_color(beautiful.graph_line_color)
-------------------------------------------------------------------------------------------
-- Виджет переключения клавиатуры
-------------------------------------------------------------------------------------------
    kbdwidget = wibox.widget.textbox(" Eng ")
    kbdwidget.border_width = 1
    kbdwidget.border_color = beautiful.fg_normal
    kbdwidget:set_text(" Eng ")
    kbdstrings = {[0] = " Eng ", 
              [1] = " Рус "}
    dbus.request_name("session", "ru.gentoo.kbdd")
    dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
    dbus.connect_signal("ru.gentoo.kbdd", function(...)
        local data = {...}
        local layout = data[2]
        kbdwidget:set_markup(kbdstrings[layout])
    end)
-------------------------------------------------------------------------------------------
-- Виджет виджет использования файловой системы
-------------------------------------------------------------------------------------------
    diskicon = wibox.widget.imagebox()
    diskicon:set_image(beautiful.widget_disk)

    home_fs_usage=blingbling.value_text_box({height = 18, width = 40, v_margin = 3})
    home_fs_usage:set_text_background_color(beautiful.widget_background)
    home_fs_usage:set_values_text_color(colors_stops)
    --home_fs_usage:set_font_size(8)
    home_fs_usage:set_background_color("#00000000")
    home_fs_usage:set_label("home: $percent %")
    vicious.register(home_fs_usage, vicious.widgets.fs, "${/home used_p}", 120 )
-------------------------------------------------------------------------------------------
-- Create a wibox for each screen and add it
-------------------------------------------------------------------------------------------
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
                                            if status.menu.instance then
                                                status.menu.instance:hide()
                                                status.menu.instance = nil
                                            else
                                                status.menu.instance = awful.menu.clients({
                                                theme = {width=screen[mouse.screen].workarea.width}
                                                --coords = {x=18, y=18}})
                                              --if instance then
                                              --    instance:hide()
                                              --   instance = nil
                                              --else
                                              --    instance = awful.menu.clients({
                                              --        theme = { width = 250 }
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
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(status.widgets.launcher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(cpuicon)
    right_layout:add(cpu)
    --right_layout:add(cpuwidget)
    --right_layout:add(batwidget)
    right_layout:add(diskicon)
    right_layout:add(home_fs_usage)
    right_layout:add(baticon0)
    right_layout:add(battext)
    right_layout:add(baticon1)
    right_layout:add(battext1)
    --right_layout:add(batwidget1)
    right_layout:add(memicon)
    right_layout:add(memwidget)
    right_layout:add(netwidget)
    right_layout:add(my_volume)
    right_layout:add(mytextclock)
    right_layout:add(kbdwidget)
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
