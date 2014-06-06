-- localization
os.setlocale(os.getenv("LANG"))
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local menubar = require("menubar")

local config = require("config")
local status = {
  widgets = {},
  menu = {},
  modkey = "Mod4",
  altkey = "Mod1",
  config = {
    wlan_if = 'wlp3s0',
    eth_if = 'enp0s25,'
  },
}
local configpath="/home/"..os.getenv("USER").."/.config/awesome/"

config.notify.init(status)
config.variables.init(status)
--config.autorun.init(status)
config.layouts.init(status)
config.menus.init(status)
config.toolbar.init(status)
config.keys.init(status)
config.rules.init(status)
config.signals.init(status)

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(configpath.."theme.lua")
-- {{{ Naughty presets
local naughty = require("naughty")
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 8
naughty.config.defaults.gap = 1
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "terminus 10"
naughty.config.defaults.icon = nil
naughty.config.defaults.icon_size = 256
naughty.config.defaults.fg = beautiful.fg_tooltip
naughty.config.defaults.bg = beautiful.bg_tooltip
naughty.config.defaults.border_color = beautiful.border_tooltip
naughty.config.defaults.border_width = 2
naughty.config.defaults.hover_timeout = nil
-- -- }}}

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
