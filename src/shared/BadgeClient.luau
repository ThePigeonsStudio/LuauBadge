--!strict

local BadgeClient = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Charm = require(ReplicatedStorage.Packages.Charm)

local TweenService = game:GetService("TweenService")

local defaultGuiProps = {
	textTitle = {
		text = Charm.atom("Badge Awarded!"),
		textColor = Charm.atom(Color3.new(1, 1, 1)),
		textFont = Charm.atom(Enum.Font.GothamBold),
	},
	textDescription = {
		text = Charm.atom("Badge description goes here."),
		textColor = Charm.atom(Color3.new(0.85, 0.85, 0.85)),
		textFont = Charm.atom(Enum.Font.Gotham),
	},
	ImageContent = Charm.atom(123437274034733),
	BackgroundColor3 = Charm.atom(Color3.new(0.1921568661928177, 0.1921568661928177, 0.1921568661928177)),
}

type GuiValues = {
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
}

type GuiProperties = {
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

local function getDefaultGuiValues(): GuiValues
	return {
		textTitle = {
			text = defaultGuiProps.textTitle.text(),
			textColor = defaultGuiProps.textTitle.textColor(),
			textFont = defaultGuiProps.textTitle.textFont(),
		},
		textDescription = {
			text = defaultGuiProps.textDescription.text(),
			textColor = defaultGuiProps.textDescription.textColor(),
			textFont = defaultGuiProps.textDescription.textFont(),
		},
		ImageContent = defaultGuiProps.ImageContent(),
		BackgroundColor3 = defaultGuiProps.BackgroundColor3(),
	}
end

local function withDefault<T>(value: T?, defaultValue: T): T
	return if value == nil then defaultValue else value
end
BadgeClient.__index = BadgeClient

export type BadgeClient = typeof(BadgeClient) & {
	player: Player,
}

--[[
Initializes the badge system on the client.
Disables Roblox's default badge notifications so the custom BadgeGUI.
Should be called once from a Client Script when the player joins.
]]
function BadgeClient:initClient()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player.PlayerGui

	local awardBadge = script.Parent:WaitForChild("awardBadge") :: RemoteEvent

	local create = Vide.create

	local function app(parent: PlayerGui, props: GuiValues): ScreenGui
		return create("ScreenGui")({
			Name = "BadgeGUI",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 9999,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension,
			ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
			ClipToDeviceSafeArea = true,
			Parent = parent,
			create("Frame")({
				Name = "frame",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.828603923, 0, 0.128941, 0),
				Size = UDim2.new(0.301647663, 0, 0.196399361, 0),
				BackgroundColor3 = props.BackgroundColor3,
				BackgroundTransparency = 0.15000000596046449,
				BorderSizePixel = 1,
				BorderColor3 = Color3.fromRGB(24, 38, 48),
				Visible = false,
				create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0, 12),
				}),
				create("UIStroke")({
					Name = "UIStroke",
					Color = Color3.new(0.3499999940395355, 0.3499999940395355, 0.3499999940395355),
					Thickness = 1.2000000476837159,
					Transparency = 0.30000001192092898,
					LineJoinMode = Enum.LineJoinMode.Round,
					StrokeSizingMode = Enum.StrokeSizingMode.FixedSize,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					BorderStrokePosition = Enum.BorderStrokePosition.Outer,
				}),
				create("UIPadding")({
					Name = "UIPadding",
					PaddingTop = UDim.new(0, 12),
					PaddingBottom = UDim.new(0, 12),
					PaddingLeft = UDim.new(0, 14),
					PaddingRight = UDim.new(0, 14),
				}),
				create("ImageLabel")({
					Name = "ImageLabel",
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0.0524556562, 0, 0.495704919, 0),
					Size = UDim2.new(0.228500962, 0, 0.967950404, 0),
					BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
					BackgroundTransparency = 1,
					BorderSizePixel = 1,
					BorderColor3 = Color3.new(0.10588235408067703, 0.16470588743686676, 0.2078431397676468),
					Image = if props.ImageContent > 0 then "rbxassetid://" .. tostring(props.ImageContent) else "",
					ScaleType = Enum.ScaleType.Fit,
					create("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 10),
					}),
				}),
				create("Frame")({
					Name = "textframes",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1.0110445, 0, 0.5, 0),
					Size = UDim2.new(0.59375, 0, 0.658333361, 0),
					BackgroundColor3 = Color3.new(0.6392157077789307, 0.6352941393852234, 0.6470588445663452),
					BackgroundTransparency = 1,
					BorderSizePixel = 1,
					BorderColor3 = Color3.new(0.10588235408067703, 0.16470588743686676, 0.2078431397676468),
					create("UIListLayout")({
						Name = "UIListLayout",
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 6),
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					create("TextLabel")({
						Name = "TextTitle",
						LayoutOrder = 1,
						Position = UDim2.new(0.0720593184, 0, -0.283941031, 0),
						Size = UDim2.new(0.893807292, 0, 0.732723117, 0),
						BackgroundColor3 = Color3.new(0.6392157077789307, 0.6352941393852234, 0.6470588445663452),
						BackgroundTransparency = 1,
						BorderSizePixel = 1,
						BorderColor3 = Color3.new(0.10588235408067703, 0.16470588743686676, 0.2078431397676468),
						Text = props.textTitle.text,
						TextColor3 = props.textTitle.textColor,
						TextSize = 18,
						TextScaled = true,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						FontFace = Font.fromEnum(props.textTitle.textFont),
						create("UITextSizeConstraint")({
							Name = "UITextSizeConstraint",
							MaxTextSize = 50,
							MinTextSize = 1,
						}),
					}),
					create("TextLabel")({
						Name = "TextDescription",
						LayoutOrder = 2,
						Position = UDim2.new(0.0720593184, 0, 0.544305086, 0),
						Size = UDim2.new(0.893807292, 0, 0.739635885, 0),
						BackgroundColor3 = Color3.new(0.6392157077789307, 0.6352941393852234, 0.6470588445663452),
						BackgroundTransparency = 1,
						BorderSizePixel = 1,
						BorderColor3 = Color3.new(0.10588235408067703, 0.16470588743686676, 0.2078431397676468),
						Text = props.textDescription.text,
						TextColor3 = props.textDescription.textColor,
						TextSize = 13,
						TextScaled = true,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Top,
						FontFace = Font.fromEnum(props.textDescription.textFont),
						create("UITextSizeConstraint")({
							Name = "UITextSizeConstraint",
							MaxTextSize = 50,
							MinTextSize = 1,
						}),
					}),
				}),
				create("UIShadow")({
					Name = "UIShadow",
					BlurRadius = Vector2.new(0, 20),
					Color = Color3.new(0, 0, 0),
					Transparency = 0.5,
					ZIndex = -1,
					ShowBehindParent = true,
					Enabled = true,
					Mode = Enum.ApplyShadowMode.Shape,
					Inset = false,
				}),
			}),
		})
	end

	local ui = app(playerGui, getDefaultGuiValues())
	local frame = ui:WaitForChild("frame") :: Frame
	local textframes = frame:WaitForChild("textframes") :: Frame
	local titleLabel = textframes:WaitForChild("TextTitle") :: TextLabel
	local descriptionLabel = textframes:WaitForChild("TextDescription") :: TextLabel
	local imageLabel = frame:WaitForChild("ImageLabel") :: ImageLabel

	awardBadge.OnClientEvent:Connect(function(guiProperties: GuiProperties?)
		local titleProperties = if guiProperties then guiProperties.textTitle else nil
		local descriptionProperties = if guiProperties then guiProperties.textDescription else nil

		titleLabel.Text = withDefault(
			if titleProperties then titleProperties.text else nil,
			defaultGuiProps.textTitle.text()
		)
		titleLabel.TextColor3 = withDefault(
			if titleProperties then titleProperties.textColor else nil,
			defaultGuiProps.textTitle.textColor()
		)
		titleLabel.FontFace = Font.fromEnum(withDefault(
			if titleProperties then titleProperties.textFont else nil,
			defaultGuiProps.textTitle.textFont()
		))

		descriptionLabel.Text = withDefault(
			if descriptionProperties then descriptionProperties.text else nil,
			defaultGuiProps.textDescription.text()
		)
		descriptionLabel.TextColor3 = withDefault(
			if descriptionProperties then descriptionProperties.textColor else nil,
			defaultGuiProps.textDescription.textColor()
		)
		descriptionLabel.FontFace = Font.fromEnum(withDefault(
			if descriptionProperties then descriptionProperties.textFont else nil,
			defaultGuiProps.textDescription.textFont()
		))

		frame.BackgroundColor3 = withDefault(
			if guiProperties then guiProperties.BackgroundColor3 else nil,
			defaultGuiProps.BackgroundColor3()
		)
		local imageContent = withDefault(
			if guiProperties then guiProperties.ImageContent else nil,
			defaultGuiProps.ImageContent()
		)
		imageLabel.Image = "rbxassetid://" .. tostring(imageContent)

		local restPosition = UDim2.new(0.85, 0, 0.17, 0)
		local offScreenPosition = UDim2.new(1.15, 0, 0.17, 0)
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		frame.Position = offScreenPosition
		frame.Visible = true

		local tweenIn = TweenService:Create(frame, tweenInfo, { Position = restPosition })
		tweenIn:Play()
		tweenIn.Completed:Wait()

		task.wait(3)

		local tweenOut = TweenService:Create(frame, tweenInfo, { Position = offScreenPosition })
		tweenOut:Play()
		tweenOut.Completed:Wait()

		frame.Visible = false
	end)

	repeat
		local success = pcall(function()
			game:GetService("StarterGui"):SetCore("BadgeNotificationsActive", false)
		end)

		if not success then
			task.wait(5)
		end
	until success
end

return BadgeClient
