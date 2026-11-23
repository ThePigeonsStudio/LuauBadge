--!strict

local BadgeServer = {}

BadgeServer.__index = BadgeServer

export type BadgeName = string
export type BadgeId = number
export type BadgeProperties = {
	badgeName: string?,
	badgeID: number,
	badgeActive: boolean?,
}
export type GuiProperties = {
	textTitle: {
		text: string?,
		textColor: Color3?,
		textFont: Enum.Font?,
	}?,
	textDescription: {
		text: string?,
		textColor: Color3?,
		textFont: Enum.Font?,
	}?,
	ImageContent: number?,
	BackgroundColor3: Color3?,
}
export type SoundProperties = {
	isEnabled: boolean?,
	sound: Sound?,
}

export type BadgeServer = typeof(BadgeServer) & {
	player: Player?,
	_badgeGUI: ScreenGui?,
	badgeProperties: BadgeProperties,
	guiProperties: GuiProperties?,
	soundProperties: SoundProperties?,
}


local BadgeService = game:GetService("BadgeService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

type AwardOperation = {
	cancelled: boolean,
	tween: Tween?,
}

local activeAwards: {[Player]: AwardOperation} = {}
local selectedBadgeGUI: ScreenGui? = nil

Players.PlayerRemoving:Connect(function(player)
	local operation = activeAwards[player]
	if operation then
		operation.cancelled = true
		if operation.tween then
			pcall(function()
				operation.tween:Cancel()
			end)
		end
	end
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

local function getSelectedBadgeGui(): ScreenGui?
	if selectedBadgeGUI then
		return selectedBadgeGUI
	end

	selectedBadgeGUI = findBadgeGuiTemplate()
	return selectedBadgeGUI
end

local function isValidBadgeId(badgeId: number): boolean
	return badgeId > 0 and badgeId % 1 == 0 and badgeId <= 0x7FFFFFFFFFFFFFFF
end

local function waitForTween(tween: Tween, operation: AwardOperation): boolean
	operation.tween = tween
	local completed = false
	local connection = tween.Completed:Once(function()
		completed = true
	end)

	while not completed and not operation.cancelled do
		task.wait()
	end

	connection:Disconnect()
	operation.tween = nil
	return completed and not operation.cancelled
end

local function waitForNotification(operation: AwardOperation, duration: number): boolean
	local deadline = os.clock() + duration
	while os.clock() < deadline do
		if operation.cancelled then
			return false
		end
		task.wait(math.min(0.1, deadline - os.clock()))
	end
	return not operation.cancelled
end

-- Validates configuration and optionally selects a BadgeGUI template.
function BadgeServer:init(badgeGUI: ScreenGui?)
	if badgeGUI then
		if typeof(badgeGUI) ~= "Instance" or not badgeGUI:IsA("ScreenGui") then
			warn("LuauBadge: BadgeGUI must be a ScreenGui")
			return false
		end
		selectedBadgeGUI = badgeGUI
		return true
	end

	local template = getSelectedBadgeGui()
	if template then
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
	assert(isValidBadgeId(badgeProperties.badgeID), "LuauBadge: badgeID must be a positive integer")

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
	guiProperties : GuiProperties?,
	soundProperties : SoundProperties?
)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("LuauBadge: award() requires a valid Player")
		return false
	end

	if activeAwards[player] then
		warn("LuauBadge: Badge notification is already active for", player.Name)
		return false
	end
	local operation: AwardOperation = {cancelled = false, tween = nil}
	activeAwards[player] = operation

	local released = false
	local function release()
		if not released then
			released = true
			if activeAwards[player] == operation then
				activeAwards[player] = nil
			end
		end
	end

	local notificationFrame: Frame? = nil
	local success, result = xpcall(function(): boolean
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
			local badgeGUI = getSelectedBadgeGui()
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
		notificationFrame = frame

		if self.badgeProperties.badgeActive == false then
			warn("LuauBadge: Cannot award badge", self.badgeProperties.badgeName, "because it is not active")
			release()
			return false
		end
		if not isValidBadgeId(self.badgeProperties.badgeID) then
			warn("LuauBadge: Cannot award badge because badgeID is invalid")
			release()
			return false
		end

		local badgeCheckSuccess, badgeCheckResult = pcall(function(): (boolean)
			return BadgeService:UserHasBadgeAsync(player.UserId, self.badgeProperties.badgeID)
		end)

		if not badgeCheckSuccess then
			warn("LuauBadge: Failed to check badge status:", tostring(badgeCheckResult))
			release()
			return false
		end
		if operation.cancelled or player.Parent == nil then
			release()
			return false
		end
		if typeof(badgeCheckResult) ~= "boolean" then
			warn("LuauBadge: Failed to check badge status: BadgeService returned an invalid result")
			release()
			return false
		end
		local hasBadge = badgeCheckResult

		if hasBadge then
			warn("LuauBadge: Cannot award badge", self.badgeProperties.badgeName, "because", player.Name, "already has it")
			release()
			return false
		end

		-- Award the badge. Studio skips BadgeService and is clearly marked as simulated.
		if RunService:IsStudio() then
			warn("LuauBadge: Studio test mode - BadgeService is skipped; no Roblox badge will be awarded")
		else
			local awardSuccess, awardResult = pcall(function()
				return BadgeService:AwardBadgeAsync(player.UserId, self.badgeProperties.badgeID)
			end)

			if not awardSuccess then
				warn("LuauBadge: Failed to award badge:", tostring(awardResult))
				release()
				return false
			end
			if operation.cancelled or player.Parent == nil then
				release()
				return false
			end

			if awardResult ~= true then
				warn("LuauBadge: BadgeService did not award badge", self.badgeProperties.badgeName)
				release()
				return false
			end

			print("LuauBadge: Awarded", self.badgeProperties.badgeName, "to", player.Name)
		end
		if operation.cancelled or player.Parent == nil then
			release()
			return false
		end

		-- Set GUI content
		guiProperties = guiProperties or {}
		soundProperties = soundProperties or {}

		local textFrames = frame:FindFirstChild("textframes", true)
		if textFrames then
			local title = textFrames:FindFirstChild("TextTitle")
			if title and title:IsA("TextLabel") then
				local titleProperties = guiProperties.textTitle
				if titleProperties then
					if type(titleProperties.text) == "string" then
						title.Text = titleProperties.text
					end
					if typeof(titleProperties.textColor) == "Color3" then
						title.TextColor3 = titleProperties.textColor
					end
					if typeof(titleProperties.textFont) == "EnumItem" then
						title.FontFace = Font.fromEnum(titleProperties.textFont)
					end
				end
			end

			local description = textFrames:FindFirstChild("TextDescription")
			if description and description:IsA("TextLabel") then
				local descriptionProperties = guiProperties.textDescription
				if descriptionProperties then
					if type(descriptionProperties.text) == "string" then
						description.Text = descriptionProperties.text
					end
					if typeof(descriptionProperties.textColor) == "Color3" then
						description.TextColor3 = descriptionProperties.textColor
					end
					if typeof(descriptionProperties.textFont) == "EnumItem" then
						description.FontFace = Font.fromEnum(descriptionProperties.textFont)
					end
				end
			end
		end

		if typeof(guiProperties.BackgroundColor3) == "Color3" then
			frame.BackgroundColor3 = guiProperties.BackgroundColor3
		end
		local image = frame:FindFirstChild("ImageLabel", true)
		if image and image:IsA("ImageLabel") then
			if type(guiProperties.ImageContent) == "number" and guiProperties.ImageContent >= 0 then
				image.Image = "rbxassetid://" .. tostring(math.floor(guiProperties.ImageContent))
			end
		end

		if soundProperties.isEnabled == true and typeof(soundProperties.sound) == "Instance" and soundProperties.sound:IsA("Sound") then
			pcall(function()
				soundProperties.sound:Play()
			end)
		end

		local restPosition = UDim2.new(0.85, 0, 0.17, 0)
		local offScreenPosition = UDim2.new(1.15, 0, 0.17, 0)
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		frame.Position = offScreenPosition
		frame.Visible = true
		local tweenInSuccess, tweenIn = pcall(function()
			return TweenService:Create(frame, tweenInfo, {Position = restPosition})
		end)
		if not tweenInSuccess then
			warn("LuauBadge: Failed to create notification tween:", tostring(tweenIn))
			frame.Visible = false
			release()
			return false
		end
		local tweenInPlaySuccess, tweenInPlayError = pcall(function()
			tweenIn:Play()
		end)
		if not tweenInPlaySuccess then
			warn("LuauBadge: Failed to play notification tween:", tostring(tweenInPlayError))
			frame.Visible = false
			release()
			return false
		end
		if not waitForTween(tweenIn, operation) then
			frame.Visible = false
			release()
			return false
		end

		if not waitForNotification(operation, 3) then
			frame.Visible = false
			release()
			return false
		end

		local tweenOutSuccess, tweenOut = pcall(function()
			return TweenService:Create(frame, tweenInfo, {Position = offScreenPosition})
		end)
		if not tweenOutSuccess then
			warn("LuauBadge: Failed to create notification tween:", tostring(tweenOut))
			frame.Visible = false
			release()
			return false
		end
		local tweenOutPlaySuccess, tweenOutPlayError = pcall(function()
			tweenOut:Play()
		end)
		if not tweenOutPlaySuccess then
			warn("LuauBadge: Failed to play notification tween:", tostring(tweenOutPlayError))
			frame.Visible = false
			release()
			return false
		end
		if not waitForTween(tweenOut, operation) then
			frame.Visible = false
			release()
			return false
		end

		-- Clean up
		frame.Visible = false
		release()
		return true
	end, debug.traceback)

	if not success then
		warn("LuauBadge: Unexpected error while awarding badge:", tostring(result))
		operation.cancelled = true
		if operation.tween then
			pcall(function()
				operation.tween:Cancel()
			end)
		end
		if notificationFrame and notificationFrame.Parent then
			pcall(function()
				notificationFrame.Visible = false
			end)
		end
		release()
		return false
	end

	release()
	return result
end

return BadgeServer