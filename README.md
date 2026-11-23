<p align="center">
  <img src="[https://your-banner-url-here.png](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/optimized/5X/0/a/7/f/0a7f0fd1d2d34cb2bc6d7fef2f2daba2a12aa482_2_690x279.png)" width="900">
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

# 📚 Navigation

- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Creating a Badge](#-creating-a-badge)
- [Awarding a Badge](#-awarding-a-badge)
- [Documentation](#-documentation)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

# ✨ Features

- ✅ Written in `--!strict`
- 🎖️ Custom badge notifications
- 🎨 Fully customizable colours
- 📝 Custom titles & descriptions
- 🖼️ Custom icons
- 🔊 Optional sounds
- ✔️ Badge ownership checking
- 📦 Lightweight
- 🔓 MIT Licensed

---

# 📥 Installation

Clone the repository or install the Roblox model.

Place:

Badge Module

BadgeGUI

into your game.

---

# 🚀 Quick Start

## Client

```lua
local Badge = require(path.To.Badge)

Badge.client:initClient()
```

## Server

```lua
local Badge = require(path.To.Badge)

Badge.server:init()
```

---

# 🎖️ Creating a Badge

```lua
local WelcomeBadge = Badge.server.new({
    badgeName = "Welcome",
    badgeID = 123456789,
    badgeActive = true
})
```

---

# 🏆 Awarding a Badge

```lua
WelcomeBadge:award(player, guiProperties, soundProperties)
```

---

# 📖 Documentation

Documentation coming soon

---

# 🛣️ Roadmap

- More animations
- Simpler setup
- Additional customization
- Better API
- Controller haptics
- More examples

---

# 🤝 Contributing

Contributions, issues and feature requests are welcome.

---

# 📄 License

Released under the MIT License.