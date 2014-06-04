local awful = require("awful")
local screen = screen
local awesome = awesome
local menubar = require("menubar")
local beautiful = require("beautiful")

local menus = {}


function menus.init(status)

-- {{{ Menu
-- Create a laucher widget and a main menu
local myawesomemenu = {
  { "manual", status.cmds.terminal .. " -e man awesome" },
  { "terminal", status.cmds.terminal },
  { "edit config", status.cmds.editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", awesome.quit }
}

status.menu.mainmenu = awful.menu({items = {
  { "awesome", myawesomemenu, beautiful.awesome_icon },
  { "kill compositor", "killall compton" },
  { "start compositor", status.cmds.compositor },
  { "open terminal", status.cmds.terminal }
}})
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,menu = mymainmenu
   })
status.widgets.launcher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = status.menu.mainmenu
})


-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

end
return menus
