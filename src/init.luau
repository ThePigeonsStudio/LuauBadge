--!strict

local badgeModule = script:FindFirstChild("Badge")
if badgeModule == nil then
	local shared = script:FindFirstChild("shared")
	if shared then
		badgeModule = shared:FindFirstChild("Badge")
	end
end

assert(badgeModule and badgeModule:IsA("ModuleScript"), "LuauBadge: Badge module is missing")

return require(badgeModule)