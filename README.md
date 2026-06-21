# Badge+

Badge+ is a customizable badge notification system for Roblox written in strict Luau.

Unlike Roblox's default badge notifications, LuauBadge allows developers to customize the notification's appearance, sounds, text, colours, and icon while still awarding official Roblox badges.

## Features

* Written in strict Luau
* Custom badge notifications
* Custom sounds
* Custom colours
* Custom badge icons
* Badge ownership checking
* Open source
* MIT licensed

## Installation

Model - https://create.roblox.com/store/asset/89760836946458/Badge

1. Download the latest release.
2. Place the Badge+ module into your game.
3. Place `BadgeGUI` inside the module.
4. Initialize the client:

```lua
local Badge = require(path.To.Badge)

Badge.client:initClient()
```

5. Initialize the server:

```lua
local Badge = require(path.To.Badge)

Badge.server:init()
```

## Creating a Badge

```lua
local Badge = require(path.To.Badge)

local WelcomeBadge = Badge.server.new({
	badgeName = "Welcome",
	badgeID = 123456789,
	badgeActive = true
})
```

## Awarding a Badge

```lua
WelcomeBadge:award(player, guiProperties, soundProperties)
```

## Example

```lua
local WelcomeBadge = Badge.server.new({
	badgeName = "Welcome",
	badgeID = 123456789,
	badgeActive = true
})

WelcomeBadge:award(player, guiProperties, soundProperties)
```

## Planned Features

* Easier default configuration
* Additional animations
* More customization options
* Further API improvements

## Feedback

Feedback, bug reports, and suggestions are welcome.
