--!strict

local BadgeClient = {}

BadgeClient.__index = BadgeClient

export type BadgeClient = typeof(BadgeClient) & {
	player : Player
}

-- Initializes the badge system on the client.
-- Disables Roblox's default badge notifications so the custom BadgeGUI
-- Should be called once from a Client Script when the player joins.
function BadgeClient:initClient()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

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
