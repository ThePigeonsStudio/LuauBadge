
--!strict

local RunService = game:GetService("RunService")

local server = if RunService:IsServer() then require(script.Parent.BadgeServer) else nil
local client = if RunService:IsClient() then require(script.Parent.BadgeClient) else nil

export type Server = typeof(require(script.Parent.BadgeServer))
export type Client = typeof(require(script.Parent.BadgeClient))
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

return {
	server = server,
	client = client,
}