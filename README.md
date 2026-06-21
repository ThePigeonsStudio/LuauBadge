# LuauBadge

A customizable badge notification system for Roblox.

## Features

- Custom badge notifications
- Custom sounds
- Custom colors
- Client/server architecture
- Written in strict Luau

## Installation

Model - https://create.roblox.com/store/asset/89760836946458/Badge

1. Download LuauBadge.
2. Place BadgeGUI inside ReplicatedStorage.
3. Require the module.
4. Call BadgeClient:initClient().
5. Create badges using BadgeServer.new().

## Example

```lua
local Badge = require(path.To.LuauBadge)

local WelcomeBadge = Badge.server.new({
    badgeName = "Welcome",
    badgeID = 123456,
    badgeActive = true
})

WelcomeBadge:award(player)
