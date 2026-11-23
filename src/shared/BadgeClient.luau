--!strict

local BadgeClient = {}

BadgeClient.__index = BadgeClient

export type BadgeClient = typeof(BadgeClient) & {
	player: Player?,
	_initialized: boolean?,
}

local initialized = false

-- Initializes the badge system on the client.
-- Disables Roblox's default badge notifications so the custom BadgeGUI
-- Should be called once from a Client Script when the player joins.
function BadgeClient:initClient()
	if game:GetService("RunService"):IsServer() then
		warn("LuauBadge: BadgeClient:initClient() must be called from a LocalScript")
		return false
	end
	if initialized then
		return true
	end

	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	if player == nil then
		warn("LuauBadge: LocalPlayer is not available")
		return false
	end

	for attempt = 1, 10 do
		local success = pcall(function()
			game:GetService("StarterGui"):SetCore("BadgeNotificationsActive", false)
		end)

		if success then
			self.player = player
			initialized = true
			return true
		end

		if attempt < 10 then
			task.wait(0.5)
		end
	end

	warn("LuauBadge: Could not disable Roblox badge notifications")
	return false
end

return BadgeClient