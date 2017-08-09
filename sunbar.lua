local beautiful = require("beautiful")
local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local http = require("socket.http")
local json = require("json/json")                           -- json package in ~/.config/awesome/json/ 
local os = require("os")

local localsettings = require("lib.sunbar.localsettings")   -- sunbar located in ~/.config/awesome/lib 
local city = localsettings.city
local wu_api_key = localsettings.wu_api_key

-- Set up timeouts for each process
local sun_get = timer({ timeout = 1200 })
local sun_calculate = timer({ timeout = 60 })
local resp

function get_current_path()
   local path = debug.getinfo(2, "S").source:sub(2)
   return path:match("(.*/)")
end

local current_path = get_current_path()

local sunrise_icon = wibox.widget {
      image = current_path .. "icons/sunrise.png",
      widget = wibox.widget.imagebox,
}

local sunset_icon = wibox.widget {
      image = current_path .. "icons/sunset.png",
      widget = wibox.widget.imagebox,
}

local sunbar = wibox.widget {
                  max_value     = 1,
                  value         = 0.5,
                  forced_width  = 100,                      -- changes the width (in pixels?) of the bar
                  paddings      = 0,
                  border_width  = 0.5,
                  border_color  = beautiful.border_color,
                  widget        = wibox.widget.progressbar,
                  color         = "#a2ffa2",                -- color of progress bar
                  background_color = "#3a3a3a",             -- background of progress bar
                  shape         = gears.shape.rounded_bar,
                  clip          = true,
                  margins       = {
                     top = 10,                              -- adjust the height of the bar
                     bottom = 10,
                  },
                  set_value = function(self, value)
                     self.value = value
                  end
}

sunbar_widget = wibox.widget {
   sunrise_icon,
   sunbar,
   sunset_icon,
   layout = wibox.layout.align.horizontal,
}

-- fetch the sunrise/sunset data for your location
sun_get:connect_signal("timeout", function ()
                                local resp_json = http.request("https://api.wunderground.com/api/" .. wu_api_key .. "/astronomy/q/" .. city .. ".json")
                                if (resp_json ~= nil) then
                                   resp = json.decode(resp_json)
                                   sunrise_hour = resp.sun_phase.sunrise.hour
                                   sunrise_minute = resp.sun_phase.sunrise.minute
                                   sunset_hour = resp.sun_phase.sunset.hour
                                   sunset_minute = resp.sun_phase.sunset.minute
                                end
end)

sun_get:start()
sun_get:emit_signal("timeout")

-- recalculate the data using the system time
sun_calculate:connect_signal("timeout", function ()
                                sunrise = os.time{min=sunrise_minute, hour=sunrise_hour, sec=0, day=1, month=1, year=1970}
                                sunset = os.time{min=sunset_minute, hour=sunset_hour, sec=0, day=1, month=1, year=1970}
                                curr = os.date('*t')
                                current = os.time{min=curr.min, hour=curr.hour, sec=0, day=1, month=1, year=1970}
                                day_length = os.difftime(sunset, sunrise)
                                day_position = os.difftime(current, sunrise)
                                day_value = day_position/day_length
                                sunbar.value = day_value
end)

sun_calculate:start()
sun_calculate:emit_signal("timeout")

-- Tell me the time via popup on mouse hover
local notification
sunbar_widget:connect_signal("mouse::enter", function()
                                percentage = ("%.2g"):format(day_value*100)
                             notification = naughty.notify{
                                text =
                                   '<big>' .. os.date('%H:%M') .. '</big> (' .. percentage .. '%)<br>' ..
                                   '<b>Sunrise:</b> ' .. sunrise_hour .. ':' .. sunrise_minute .. '<br>' ..
                                   '<b>Sunset:</b> ' .. sunset_hour .. ':' .. sunset_minute,
                                timeout = 5,
                                hover_timeout = 10,
                                -- width = 150,
                                position = center
                             }
end)
sunbar_widget:connect_signal("mouse::leave", function()
                                naughty.destroy(notification)
end)
