-- ServerScriptService/Services/AwardBadgeHandler.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeUtils = require(script.Parent.Parent.Services.BadgeUtils)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local awardBadgeEvent = RemoteEvents:WaitForChild("AwardBadgeRequest")

awardBadgeEvent.OnServerEvent:Connect(function(player, carId)
	if typeof(carId) ~= "string" then
		warn("Invalid carId from player:", player.Name)
		return
	end

	BadgeUtils:AwardCarBadge(player, carId)
end)
