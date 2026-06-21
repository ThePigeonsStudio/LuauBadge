--!strict

local server = require(script.BadgeServer)
local client = require(script.BadgeClient)

export type Server = server.BadgeServer
export type Client = client.BadgeClient

return {
	server = server,
	client = client,
}
