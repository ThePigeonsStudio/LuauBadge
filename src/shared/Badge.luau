--!strict

local server = require(script.BadgeServer)
local client = require(script.BadgeClient)

export type Server = typeof(server)
export type Client = typeof(client)
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
	},
	textDescription: {
		text: string?,
		textColor: Color3?,
		textFont: Enum.Font?,
	},
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