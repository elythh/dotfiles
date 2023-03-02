local bling = require("bling")
local playerctl = bling.signal.playerctl.lib()

local prev = wibox.widget {
  align = 'center',
  font = beautiful.icofont,
  text = '\u{f048}',
  widget = wibox.widget.textbox,
}

local next = wibox.widget {
  align = 'center',
  font = beautiful.icofont,
  markup = '\u{f051}',
  widget = wibox.widget.textbox,
}

local play = wibox.widget {
  align = 'center',
  font = beautiful.icofont,
  markup = '\u{f04b}',
  widget = wibox.widget.textbox
}

play:buttons(gears.table.join(
  awful.button({}, 1, function() playerctl:play_pause() end)))

next:buttons(gears.table.join(
  awful.button({}, 1, function() playerctl:next() end)))

prev:buttons(gears.table.join(
  awful.button({}, 1, function() playerctl:previous() end)))

local position = wibox.widget {
  forced_height    = dpi(3),
  shape            = help.rrect(beautiful.br),
  color            = beautiful.pri,
  background_color = beautiful.fg2 .. '4D',
  forced_width     = dpi(175),
  widget           = wibox.widget.progressbar,
}

local art = wibox.widget {
  image = beautiful.theme_dir .. "player.png",
  resize = true,
  opacity = 0.25,
  forced_width = beautiful.dashboard_width / 2,
  widget = wibox.widget.imagebox
}

local name = wibox.widget {
  markup = '<b>Nothing Playing</b>',
  align = 'center',
  valign = 'center',
  forced_height = dpi(15),
  widget = wibox.widget.textbox
}

local artist_name = wibox.widget {
  markup = 'None',
  align = 'center',
  valign = 'center',
  forced_height = dpi(20),
  widget = wibox.widget.textbox
}

local player = wibox.widget {
  {
    art,
    {
      {
        widget = wibox.widget.textbox,
      },
      bg = {
        type = "linear",
        from = { 0, 0 },
        to = { 120, 0 },
        stops = { { 0, beautiful.bg2 .. "00" }, { 1, beautiful.bg2 .. "FF" } }
      },
      widget = wibox.container.background,
    },
    {
      {
        name,
        artist_name,
        position,
        {
          prev,
          play,
          next,
          layout = wibox.layout.flex.horizontal
        },
        spacing = dpi(10),
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(20),
      widget = wibox.container.margin,
    },
    layout = wibox.layout.stack,
  },
  forced_height = dpi(124),
  shape = help.rrect(beautiful.br),
  bg = beautiful.bg2,
  widget = wibox.container.background,
}

playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
  if new then
    art.image = beautiful.wall
  end
  art:set_image(gears.surface.load_uncached(album_path))
  name:set_markup_silently(help.fg("<b>" .. title .. "</b>", beautiful.pri, "normal"))
  artist_name:set_markup_silently(artist)
end)

playerctl:connect_signal("playback_status", function(_, playing, _)
  if playing then
    play:set_markup_silently(help.fg("\u{f04c}", beautiful.pri, "normal"))
    position.color = beautiful.pri
  else
    play:set_markup_silently("\u{f04b}")
    position.color = beautiful.fg
  end
end)

playerctl:connect_signal("position", function(_, a, b, _)
  position.value = a
  position.max_value = b
end)

return player
