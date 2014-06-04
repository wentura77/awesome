local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local capi = { screen = screen }

--local helpers = require("actionless.helpers")

local layouts = {}


function layouts.init(status)
-- Table of layouts to cover with awful.layout.inc, order matters.
status.layouts = {
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.floating,
    --awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle
}
awful.layout.layouts = status.layouts
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, capi.screen.count() do
    gears.wallpaper.tiled(beautiful.wallpaper, s)
  end
else if beautiful.wallpaper_cmd then
  helpers.run_once(beautiful.wallpaper_cmd)
end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
status.tags = {}
for s = 1, capi.screen.count() do
  -- Each screen has its own tag table.
  status.tags[s] = awful.tag(
    { '1:TERM', '2:RDP', '3:WEB', '4:EDIT', 5, 6, 7, 8, 9, 0 },
    s, awful.layout.layouts[1])
end
-- }}}

end
return layouts
