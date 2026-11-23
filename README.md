<p align="center">
  <img src="https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/optimized/5X/0/a/7/f/0a7f0fd1d2d34cb2bc6d7fef2f2daba2a12aa482_2_690x279.png" width="900">
</p>

<h1 align="center">Badge+</h1>

<p align="center">
A customizable badge notification system for Roblox.
<br>
Create beautiful badge notifications while still awarding official Roblox badges.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg"></a>
  <img src="https://img.shields.io/badge/Luau---!strict-blue">
  <img src="https://img.shields.io/badge/Open%20Source-Yes-brightgreen">
</p>

---

# Features

- Written in `--!strict`
- Custom badge notifications
- Customizable colours
- Custom titles and descriptions
- Custom icons
- Optional sounds
- Badge ownership checking
- Lightweight
- MIT licensed

# Installation

Add the Wally package to `wally.toml`:

```toml
[dependencies]
Luaubadge = "thepigeonsstudio/luaubadge@0.1.0"
```

Run `wally install`, then require the package from the location Wally generates:

```lua
local Badge = require(game:GetService("ReplicatedStorage").Packages.Luaubadge)
```

The repository entry point is `src/init.luau`, which loads
`src/shared/Badge.luau`.

# Quick Start

## Client

Initialize the client in a `LocalScript`:

```lua
local Badge = require(game:GetService("ReplicatedStorage").Packages.Luaubadge)

Badge.client:initClient()
```

## Server

Initialize the server in a `ServerScript`:

```lua
local Badge = require(game:GetService("ReplicatedStorage").Packages.Luaubadge)

Badge.server:init()
```

`Badge.server` is server-only and `Badge.client` is client-only.

# GUI Setup

Place a `ScreenGui` named `BadgeGUI` in `StarterGui`, `ReplicatedStorage`, or
`Workspace`. The template can also be passed explicitly:

```lua
local Badge = require(game:GetService("ReplicatedStorage").Packages.Luaubadge)
local template = game:GetService("StarterGui"):FindFirstChild("BadgeGUI")

Badge.server:init(template)
```

The template must contain a `Frame` named `frame`. LuauBadge clones the template
into a player's `PlayerGui` when necessary and preserves the existing slide-in
notification animation.

# Creating a Badge

```lua
local WelcomeBadge = Badge.server.new({
	badgeName = "Welcome",
	badgeID = 123456789,
	badgeActive = true,
})
```

`badgeID` must be a positive integer badge ID created for the experience.
`badgeName` defaults to `"Badge"` and `badgeActive` defaults to `true`.

# Awarding a Badge

```lua
WelcomeBadge:award(player, {
	textTitle = {
		text = "Badge awarded",
		textColor = Color3.fromRGB(255, 255, 255),
		textFont = Enum.Font.GothamBold,
	},
	textDescription = {
		text = "Welcome to the game!",
	},
	ImageContent = 123456789,
	BackgroundColor3 = Color3.fromRGB(35, 35, 35),
}, {
	isEnabled = true,
	sound = script.NotificationSound,
})
```

All GUI and sound customization fields are optional. Omitted fields retain the
template's existing values.

# BadgeService Behavior

On a live server, LuauBadge checks ownership with `UserHasBadgeAsync`, then calls
`AwardBadgeAsync`. An award returns `true` only after BadgeService confirms it.
BadgeService failures and badges already owned by the player return `false`.

In Roblox Studio, `AwardBadgeAsync` is intentionally skipped so notifications
can be tested without changing live badge ownership. Studio mode emits a warning
and does not represent the notification as a live badge award.

# Public API

```lua
Badge.server:init(badgeGUI?) -- server only
Badge.server.new(badgeProperties)
badge:award(player, guiProperties?, soundProperties?) -- server only

Badge.client:initClient() -- client only
```

# Common Errors

- **BadgeGUI is missing:** Pass a `ScreenGui` to `init()` or place a template
  named `BadgeGUI` in `StarterGui`, `ReplicatedStorage`, or `Workspace`.
- **The template has no frame named `frame`:** Add a direct or descendant
  `Frame` named `frame` to the `BadgeGUI` template.
- **badgeID is invalid:** Use a positive integer badge ID.
- **The notification is already active:** The player is limited to one active
  LuauBadge notification at a time.
- **BadgeService calls fail:** Verify experience configuration, badge
  permissions, badge ownership, and the badge ID.

# Contributing

Contributions, issues, and feature requests are welcome.

# License

Released under the MIT License.
