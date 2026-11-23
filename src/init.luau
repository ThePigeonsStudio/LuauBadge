--!strict

local badgeModule = script:FindFirstChild("Badge")
if badgeModule == nil then
	local shared = script:FindFirstChild("shared")
	if shared then
		badgeModule = shared:FindFirstChild("Badge")
	end
end

assert(
	badgeModule ~= nil and badgeModule:IsA("ModuleScript"),
	"LuauBadge: package entry point could not find src/shared/Badge.luau"
)

return require(badgeModule)