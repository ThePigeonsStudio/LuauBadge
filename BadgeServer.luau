--!strict

local BadgeServer = {}

BadgeServer.__index = BadgeServer

export type BadgeServer = typeof(BadgeServer) & {
	player : Player,
	badgeProperties : {
		badgeName : string,
		badgeID : number,
		badgeActive : boolean
	},
	guiProperties : {
		textTitle : {
			text : string,
			textColor : Color3,
			textFont : Enum.Font
		},
		textDescription  : {
			text : string,
			textColor : Color3,
			textFont : Enum.Font
		},
		ImageContent : number,
		BackgroundColor3 : Color3,
	},
	soundProperties : {
		isEnabled : boolean,
		sound : Sound
	}
}


-- Validates that the BadgeGUI exists under the Badge module.
-- Call this once at startup before awarding any badges.
function BadgeServer:init()
	assert(script.Parent.BadgeGUI, "Gui is missing!")
end

local BadgeService = game:GetService("BadgeService")
local TweenService = game:GetService("TweenService")

-- Creates a new badge object with the given properties.
-- badgeProperties:
--   badgeID (number)     - The Roblox badge asset ID to award.
--   badgeActive (boolean) - Whether the badge is currently active. 
function BadgeServer.new(badgeProperties: {
	badgeID : number,
	badgeActive : boolean
	})
	
	local self = setmetatable({}, BadgeServer)

	self.badgeProperties = badgeProperties

	return self
end

-- Awards this badge to the given player and shows a slide-in notification on their screen.
--
-- Parameters:
--   player (Player) - The player to award the badge to.
--
--   guiProperties - Controls the notification appearance:
--     textTitle.text (string)        - Title text shown on the notification.
--     textTitle.textColor (Color3)   - Title text color.
--     textTitle.textFont (Enum.Font) - Title font.
--     textDescription.text (string)        - Description text shown below the title.
--     textDescription.textColor (Color3)   - Description text color.
--     textDescription.textFont (Enum.Font) - Description font.
--     ImageContent (number)      - Image asset ID for the badge icon.
--     BackgroundColor3 (Color3)  - Background color of the notification frame.
--
--   soundProperties - Controls the notification sound:
--     isEnabled (boolean) - Whether to play a sound when the notification appears.
--     sound (Sound)       - The Sound instance to play.
function BadgeServer:award(
	player : Player,
	guiProperties : {
		textTitle : {
			text : string,
			textColor : Color3,
			textFont : Enum.Font
		},
		textDescription  : {
			text : string,
			textColor : Color3,
			textFont : Enum.Font
		},
		ImageContent : number,
		BackgroundColor3 : Color3,
	},
	soundProperties : {
		isEnabled : boolean,
		sound : Sound
	}
)
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	local ui = playerGui and playerGui:FindFirstChild("BadgeGUI")
	if not ui then
		local badgeGUI = script.Parent:FindFirstChild("BadgeGUI")
		if badgeGUI then
			ui = badgeGUI:Clone()
			ui.Parent = playerGui
			ui.frame.Visible = false
		end
	end
	if not ui then
		warn("Could not find or clone BadgeGUI for player", player.Name)
		return
	end


	if self.badgeProperties.badgeActive == false then
		warn("Cannot award badge " , self.badgeProperties.badgeName , "because it is not active!")
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
		warn("Cannot award badge " , self.badgeProperties.badgeName , "because the player", player.Name, "already has it!")
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

		print("Awarded badge: " , self.badgeProperties.badgeName , " to :" , player.Name)
	end

	-- Set GUI content
	ui.frame.textframes.TextTitle.Text = guiProperties.textTitle.text
	ui.frame.textframes.TextTitle.TextColor3 = guiProperties.textTitle.textColor
	ui.frame.textframes.TextTitle.FontFace = Font.fromEnum(guiProperties.textTitle.textFont)

	ui.frame.textframes.TextDescription.Text = guiProperties.textDescription.text
	ui.frame.textframes.TextDescription.TextColor3 = guiProperties.textDescription.textColor
	ui.frame.textframes.TextDescription.FontFace = Font.fromEnum(guiProperties.textDescription.textFont)

	ui.frame.BackgroundColor3 = guiProperties.BackgroundColor3
	ui.frame.ImageLabel.Image = "rbxassetid://" .. guiProperties.ImageContent

	if soundProperties.isEnabled == true then
		soundProperties.sound:Play()
	end

	local restPosition = UDim2.new(0.85, 0, 0.17, 0)
	local offScreenPosition = UDim2.new(1.15, 0, 0.17, 0)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	ui.frame.Position = offScreenPosition
	ui.frame.Visible = true
	local tweenIn = TweenService:Create(ui.frame, tweenInfo, {Position = restPosition})
	tweenIn:Play()
	tweenIn.Completed:Wait()

	task.wait(3)

	local tweenOut = TweenService:Create(ui.frame, tweenInfo, {Position = offScreenPosition})
	tweenOut:Play()
	tweenOut.Completed:Wait()

	-- Clean up
	ui.frame.Visible = false
end

return BadgeServer
