--!strict

local BadgeServer = {}

BadgeServer.__index = BadgeServer

export type BadgeServer = typeof(BadgeServer) & {
	player: Player?,
	_badgeGUI: ScreenGui?,
	badgeProperties: {
		badgeName: string?,
		badgeID: number,
		badgeActive: boolean?,
	},
	guiProperties: {
		textTitle: {
			text: string?,
			textColor: Color3?,
			textFont: Enum.Font?,
		},
		textDescription: {
			text: string?,
			textColor: Color3?,
			textFont: Enum.Font?,
		},
		ImageContent: number?,
		BackgroundColor3: Color3?,
	},
	soundProperties: {
		isEnabled: boolean?,
		sound: Sound?,
	}
}


local BadgeService = game:GetService("BadgeService")
local TweenService = game:GetService("TweenService")
local activeAwards: {[Player]: boolean} = {}

game:GetService("Players").PlayerRemoving:Connect(function(player)
	activeAwards[player] = nil
end)

local function findBadgeGuiTemplate(): ScreenGui?
	local directLocations: { Instance } = {
		script,
		script.Parent,
		game:GetService("StarterGui"),
		game:GetService("ReplicatedStorage"),
		game:GetService("Workspace"),
	}

	for _, location in directLocations do
		local template = location:FindFirstChild("BadgeGUI", true)
		if template and template:IsA("ScreenGui") then
			return template
		end
	end

	return nil
end

local function getFrame(ui: ScreenGui): Frame?
	local frame = ui:FindFirstChild("frame", true)
	return if frame and frame:IsA("Frame") then frame else nil
end

-- Validates configuration and optionally selects a BadgeGUI template.
function BadgeServer:init(badgeGUI: ScreenGui?)
	if badgeGUI then
		if not badgeGUI:IsA("ScreenGui") then
			warn("LuauBadge: BadgeGUI must be a ScreenGui")
			return false
		end
		self._badgeGUI = badgeGUI
		return true
	end

	local template = findBadgeGuiTemplate()
	if template then
		self._badgeGUI = template
		return true
	end

	warn("LuauBadge: BadgeGUI is missing. Pass a ScreenGui to init or place it in StarterGui/ReplicatedStorage")
	return false
end

-- Creates a new badge object with the given properties.
function BadgeServer.new(badgeProperties: {
	badgeName: string?,
	badgeID: number,
	badgeActive: boolean?,
})
	assert(type(badgeProperties) == "table", "LuauBadge: badgeProperties must be a table")
	assert(type(badgeProperties.badgeID) == "number", "LuauBadge: badgeID must be a number")
	assert(badgeProperties.badgeID > 0, "LuauBadge: badgeID must be greater than zero")

	local self = setmetatable({}, BadgeServer)

	self.badgeProperties = {
		badgeName = badgeProperties.badgeName or "Badge",
		badgeID = badgeProperties.badgeID,
		badgeActive = if badgeProperties.badgeActive == nil then true else badgeProperties.badgeActive,
	}

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
			text : string?,
			textColor : Color3?,
			textFont : Enum.Font?
		},
		textDescription  : {
			text : string?,
			textColor : Color3?,
			textFont : Enum.Font?
		},
		ImageContent : number?,
		BackgroundColor3 : Color3?,
	}?,
	soundProperties : {
		isEnabled : boolean?,
		sound : Sound?
	}?
)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("LuauBadge: award() requires a valid Player")
		return false
	end

	if activeAwards[player] then
		warn("LuauBadge: Badge notification is already active for", player.Name)
		return false
	end
	activeAwards[player] = true

	local released = false
	local function release()
		if not released then
			released = true
			activeAwards[player] = nil
		end
	end

	if player.Parent == nil then
		warn("LuauBadge: Cannot award a badge to a player who has left")
		release()
		return false
	end

	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		warn("LuauBadge: PlayerGui is not available for", player.Name)
		release()
		return false
	end

	local ui = playerGui and playerGui:FindFirstChild("BadgeGUI")
	if not ui then
		local badgeGUI = self._badgeGUI
		if not badgeGUI then
			badgeGUI = findBadgeGuiTemplate()
		end
		if badgeGUI and badgeGUI:IsA("ScreenGui") then
			ui = badgeGUI:Clone()
			ui.Parent = playerGui
			local frame = getFrame(ui)
			if frame then
				frame.Visible = false
			end
		end
	end
	if not ui or not ui:IsA("ScreenGui") then
		warn("LuauBadge: Could not find or clone BadgeGUI for player", player.Name)
		release()
		return false
	end

	local frame = getFrame(ui)
	if not frame then
		warn("LuauBadge: BadgeGUI does not contain a Frame named 'frame'")
		release()
		return false
	end

	if self.badgeProperties.badgeActive == false then
		warn("LuauBadge: Cannot award badge", self.badgeProperties.badgeName, "because it is not active")
		release()
		return false
	end

	local hasBadge = false
	local badgeCheckSuccess, badgeCheckErr = pcall(function()
		hasBadge = BadgeService:UserHasBadgeAsync(player.UserId, self.badgeProperties.badgeID)
	end)

	if not badgeCheckSuccess then
		warn("LuauBadge: Failed to check badge status:", tostring(badgeCheckErr))
		release()
		return false
	end

	if hasBadge then
		warn("LuauBadge: Cannot award badge", self.badgeProperties.badgeName, "because", player.Name, "already has it")
		release()
		return false
	end

	-- Award the badge (skip in Studio)
	if game:GetService("RunService"):IsStudio() then
		warn("LuauBadge: AwardBadgeAsync is skipped in Studio")
	else
		local success, err = pcall(function()
			BadgeService:AwardBadgeAsync(player.UserId, self.badgeProperties.badgeID)
		end)

		if not success then
			warn("LuauBadge: Failed to award badge:", tostring(err))
			release()
			return false
		end

		print("LuauBadge: Awarded", self.badgeProperties.badgeName, "to", player.Name)
	end

	-- Set GUI content
	guiProperties = guiProperties or {
		textTitle = {},
		textDescription = {},
	}
	soundProperties = soundProperties or {}

	local textFrames = frame:FindFirstChild("textframes", true)
	if textFrames then
		local title = textFrames:FindFirstChild("TextTitle")
		if title and title:IsA("TextLabel") then
			local titleProperties = guiProperties.textTitle
			if titleProperties then
				title.Text = titleProperties.text or title.Text
				title.TextColor3 = titleProperties.textColor or title.TextColor3
				title.FontFace = Font.fromEnum(titleProperties.textFont or Enum.Font.Gotham)
			end
		end

		local description = textFrames:FindFirstChild("TextDescription")
		if description and description:IsA("TextLabel") then
			local descriptionProperties = guiProperties.textDescription
			if descriptionProperties then
				description.Text = descriptionProperties.text or description.Text
				description.TextColor3 = descriptionProperties.textColor or description.TextColor3
				description.FontFace = Font.fromEnum(descriptionProperties.textFont or Enum.Font.Gotham)
			end
		end
	end

	frame.BackgroundColor3 = guiProperties.BackgroundColor3 or frame.BackgroundColor3
	local image = frame:FindFirstChild("ImageLabel", true)
	if image and image:IsA("ImageLabel") and guiProperties.ImageContent then
		image.Image = "rbxassetid://" .. tostring(guiProperties.ImageContent)
	end

	if soundProperties.isEnabled == true and soundProperties.sound then
		pcall(function()
			soundProperties.sound:Play()
		end)
	end

	local restPosition = UDim2.new(0.85, 0, 0.17, 0)
	local offScreenPosition = UDim2.new(1.15, 0, 0.17, 0)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	frame.Position = offScreenPosition
	frame.Visible = true
	local tweenIn = TweenService:Create(frame, tweenInfo, {Position = restPosition})
	tweenIn:Play()
	tweenIn.Completed:Wait()

	task.wait(3)

	local tweenOut = TweenService:Create(frame, tweenInfo, {Position = offScreenPosition})
	tweenOut:Play()
	tweenOut.Completed:Wait()

	-- Clean up
	frame.Visible = false
	release()
	return true
end

return BadgeServer