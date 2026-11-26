--!strict

local BadgeServer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Scythe = require(ReplicatedStorage.Packages.Sycthe)
local scope = Scythe.scope()

local awardBadge: RemoteEvent

BadgeServer.__index = BadgeServer

export type BadgeServer = typeof(BadgeServer) & {
	player: Player,
	delay: number,
	badgeProperties: {
		badgeName: string,
		badgeID: number,
		badgeActive: boolean,
	},
	guiProperties: {
		textTitle: {
			text: string,
			textColor: Color3,
			textFont: Enum.Font,
		},
		textDescription: {
			text: string,
			textColor: Color3,
			textFont: Enum.Font,
		},
		ImageContent: number,
		BackgroundColor3: Color3,
	},
	soundProperties: {
		isEnabled: boolean,
		sound: Sound?,
	},
}

--[[
-- Validates that the BadgeGUI exists under the Badge module.
-- Call this once at startup before awarding any badges.
]]
function BadgeServer:init()
	assert(script.Parent.BadgeGUI, "Gui is missing!")
	awardBadge = Instance.new("RemoteEvent")
	awardBadge.Parent = script.Parent
	awardBadge.Name = "awardBadge"

	Scythe.add(scope, awardBadge)
end

local BadgeService = game:GetService("BadgeService")

--[[
Creates a new badge object with the given properties.
badgeProperties:
  badgeID (number)     - The Roblox badge asset ID to award.
  badgeActive (boolean) - Whether the badge is currently active.
]]
function BadgeServer.new(badgeProperties: {
	badgeID: number,
	badgeActive: boolean,
})
	local self = setmetatable({}, BadgeServer)

	self.badgeProperties = badgeProperties

	return self
end

--[[
Awards this badge to the given player and shows a slide-in notification on their screen.

Parameters:
  player (Player) - The player to award the badge to.
  delay (number) - The delay in seconds before awarding the badge.

  guiProperties - Controls the notification appearance:
    textTitle.text (string)        - Title text shown on the notification.
    textTitle.textColor (Color3)   - Title text color.
    textTitle.textFont (Enum.Font) - Title font.
    textDescription.text (string)        - Description text shown below the title.
    textDescription.textColor (Color3)   - Description text color.
    textDescription.textFont (Enum.Font) - Description font.
    ImageContent (number)      - Image asset ID for the badge icon.
    BackgroundColor3 (Color3)  - Background 
	
	color of the notification frame.

  soundProperties - Controls the notification sound:
    isEnabled (boolean) - Whether to play a sound when the notification appears.
    sound (Sound)
]]
function BadgeServer:award(
	player: Player,
	delay: number?,
	guiProperties: {
		textTitle: {
			text: string,
			textColor: Color3,
			textFont: Enum.Font,
		},
		textDescription: {
			text: string,
			textColor: Color3,
			textFont: Enum.Font,
		},
		ImageContent: number,
		BackgroundColor3: Color3,
	}?,
	soundProperties: {
		isEnabled: boolean,
		sound: Sound?,
	}?
)
	if self.badgeProperties.badgeActive == false then
		warn("Cannot award badge ", self.badgeProperties.badgeName, "because it is not active!")
		return
	end

	local hasBadge = false
	local badgeCheckSuccess, badgeCheckErr = pcall(function()
		hasBadge = BadgeService:UserHasBadgeAsync(player.UserId, self.badgeProperties.badgeID)
	end)

	if not badgeCheckSuccess then
		warn("Failed to check badge status: " .. tostring(badgeCheckErr))
		return
	end

	if hasBadge then
		warn(
			"Cannot award badge ",
			self.badgeProperties.badgeName,
			"because the player",
			player.Name,
			"already has it!"
		)
		return
	end

	-- Award the badge (skip in Studio)
	if game:GetService("RunService"):IsStudio() then
		warn("Cannot award badge in studio")
	else
		local success, err = pcall(function()
			BadgeService:AwardBadgeAsync(player.UserId, self.badgeProperties.badgeID)
		end)

		if not success then
			warn(err)
			return
		end

		print("Awarded badge: ", self.badgeProperties.badgeName, " to :", player.Name)
	end

	if delay then
		task.wait(delay)
	end

	awardBadge:FireClient(player, guiProperties, soundProperties)
end

return BadgeServer
