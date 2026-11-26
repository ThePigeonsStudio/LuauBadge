--!strict

local BadgeClient = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Charm = require(ReplicatedStorage.Packages.Charm)

local TweenService = game:GetService("TweenService")

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

local defaultGuiValues: GuiValues = {
	textTitle = {
		text = "Badge Awarded!",
		textColor = Color3.new(1, 1, 1),
		textFont = Enum.Font.GothamBold,
	},
	textDescription = {
		text = "Badge description goes here.",
		textColor = Color3.new(0.85, 0.85, 0.85),
		textFont = Enum.Font.Gotham,
	},
	ImageContent = 123437274034733,
	BackgroundColor3 = Color3.new(0.1921568661928177, 0.1921568661928177, 0.1921568661928177),
}

local defaultGuiProps = {
	textTitle = {
		text = Charm.atom(defaultGuiValues.textTitle.text),
		textColor = Charm.atom(defaultGuiValues.textTitle.textColor),
		textFont = Charm.atom(defaultGuiValues.textTitle.textFont),
	},
	textDescription = {
		text = Charm.atom(defaultGuiValues.textDescription.text),
		textColor = Charm.atom(defaultGuiValues.textDescription.textColor),
		textFont = Charm.atom(defaultGuiValues.textDescription.textFont),
	},
	ImageContent = Charm.atom(defaultGuiValues.ImageContent),
	BackgroundColor3 = Charm.atom(defaultGuiValues.BackgroundColor3),
}

type GuiSources = {
	textTitle: {
		text: () -> string,
		textColor: () -> Color3,
		textFont: () -> Enum.Font,
	},
	textDescription: {
		text: () -> string,
		textColor: () -> Color3,
		textFont: () -> Enum.Font,
	},
	ImageContent: () -> number,
	BackgroundColor3: () -> Color3,
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

local function bindAtom<T>(atom: Charm.Atom<T>): () -> T
	local source = Vide.source(atom())
	Vide.cleanup(Charm.subscribe(atom, function(value)
		source(value)
	end))

	return source
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

	local function app(parent: PlayerGui, props: GuiSources): ScreenGui
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
					Image = function()
						local imageContent = props.ImageContent()
						return if imageContent > 0 then "rbxassetid://" .. tostring(imageContent) else ""
					end,
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
						FontFace = function()
							return Font.fromEnum(props.textTitle.textFont())
						end,
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
						FontFace = function()
							return Font.fromEnum(props.textDescription.textFont())
						end,
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

	local destroyGui, ui = Vide.root(function()
		return app(playerGui, {
			textTitle = {
				text = bindAtom(defaultGuiProps.textTitle.text),
				textColor = bindAtom(defaultGuiProps.textTitle.textColor),
				textFont = bindAtom(defaultGuiProps.textTitle.textFont),
			},
			textDescription = {
				text = bindAtom(defaultGuiProps.textDescription.text),
				textColor = bindAtom(defaultGuiProps.textDescription.textColor),
				textFont = bindAtom(defaultGuiProps.textDescription.textFont),
			},
			ImageContent = bindAtom(defaultGuiProps.ImageContent),
			BackgroundColor3 = bindAtom(defaultGuiProps.BackgroundColor3),
		})
	end)
	ui.Destroying:Once(destroyGui)
	local frame = ui:WaitForChild("frame") :: Frame

	awardBadge.OnClientEvent:Connect(function(
		guiProperties: GuiProperties?,
		soundProperties: { isEnabled: boolean?, sound: Sound? }?
	)
		local titleProperties = if guiProperties then guiProperties.textTitle else nil
		local descriptionProperties = if guiProperties then guiProperties.textDescription else nil

		Charm.batch(function()
			defaultGuiProps.textTitle.text(withDefault(
				if titleProperties then titleProperties.text else nil,
				defaultGuiValues.textTitle.text
			))
			defaultGuiProps.textTitle.textColor(withDefault(
				if titleProperties then titleProperties.textColor else nil,
				defaultGuiValues.textTitle.textColor
			))
			defaultGuiProps.textTitle.textFont(withDefault(
				if titleProperties then titleProperties.textFont else nil,
				defaultGuiValues.textTitle.textFont
			))
			defaultGuiProps.textDescription.text(withDefault(
				if descriptionProperties then descriptionProperties.text else nil,
				defaultGuiValues.textDescription.text
			))
			defaultGuiProps.textDescription.textColor(withDefault(
				if descriptionProperties then descriptionProperties.textColor else nil,
				defaultGuiValues.textDescription.textColor
			))
			defaultGuiProps.textDescription.textFont(withDefault(
				if descriptionProperties then descriptionProperties.textFont else nil,
				defaultGuiValues.textDescription.textFont
			))
			defaultGuiProps.ImageContent(withDefault(
				if guiProperties then guiProperties.ImageContent else nil,
				defaultGuiValues.ImageContent
			))
			defaultGuiProps.BackgroundColor3(withDefault(
				if guiProperties then guiProperties.BackgroundColor3 else nil,
				defaultGuiValues.BackgroundColor3
			))
		end)

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

		if soundProperties and soundProperties.isEnabled and soundProperties.sound then
			soundProperties.sound:Play()
		end

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
