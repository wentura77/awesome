local awful = require("awful")
local screen = screen
local awesome = awesome
local menubar = require("menubar")
local beautiful = require("beautiful")

-- Load Debian menu entries
require("debian.menu")
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
  { "Debian", debian.menu.Debian_menu.Debian },
  { "kill compositor", "killall compton" },
  { "start compositor", status.cmds.compositor },
  { "open terminal", status.cmds.terminal }
}})
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

status.widgets.launcher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = status.menu.mainmenu
})


-- Menubar configuration
menubar.utils.terminal = status.cmds.terminal
-- }}}

end
return menus
