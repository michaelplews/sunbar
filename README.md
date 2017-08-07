# Sunbar
A distraction free pseudoclock widget for AwesomeWM.

![Taken at 13:52 in Chicago](./sunbar.png)

## Why? And whats a pseudoclock?
This idea spawned when I was trying to design a distraction free
branch of my dotfiles for working on long writing projects. I found I
would be distracted by the clock in the corner of my screen. I
therefore designed a pseudoclock; an *about-what-time-is-it*
progress bar to show the suns position throughout the day relative to
sunrise and sunset.

## Dependencies
 - lua-socket
 - [json parser for lua](https://github.com/rxi/json.lua) 


```bash
sudo apt-get install lua-socket
git clone git@github.com:rxi/json.lua.git ~/.config/awesome/json
```

## Installation
You can install to your AwesomeWM `lib` path.

```bash
git clone git@github.com:michaelplews/sunbar.git ~/.config/awesome/lib/sunbar
```

## Personalising
The repo comes with `localsettings.lua.sample`, a sample localsettings
file that should include
your [api.wunderground.com](https://api.wunderground.com) api key and
your city/location for sunrise/sunset data. This file must be renames
to `localsettings.lua`, afterwhich it will be ignored by the git
repo. The city/location should be in the form Country/State/City (for 
the US) and simply Country/City for other countries.
