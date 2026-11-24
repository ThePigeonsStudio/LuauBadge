--!strict

local BadgeClient = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

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

	local create = Vide.create

	local function app(parent: PlayerGui): ScreenGui
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
				BackgroundColor3 = Color3.new(0.1921568661928177, 0.1921568661928177, 0.1921568661928177),
				BackgroundTransparency = 0.15000000596046449,
				BorderSizePixel = 1,
				BorderColor3 = Color3.new(0.10588235408067703, 0.16470588743686676, 0.2078431397676468),
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
						Text = "Badge Title",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 18,
						TextScaled = true,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						FontFace = Font.new(
							"rbxasset://fonts/families/GothamSSm.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
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
						Text = "Badge description goes here.",
						TextColor3 = Color3.new(0.8500000238418579, 0.8500000238418579, 0.8500000238418579),
						TextSize = 13,
						TextScaled = true,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Top,
						FontFace = Font.new(
							"rbxasset://fonts/families/GothamSSm.json",
							Enum.FontWeight.Regular,
							Enum.FontStyle.Normal
						),
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

	app(playerGui)

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
