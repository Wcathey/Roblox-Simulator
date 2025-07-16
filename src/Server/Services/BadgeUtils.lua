local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgesData = require(ReplicatedStorage.Shared.Badges.BadgesData)

local BadgeUtils = {}

-- Awards a badge if the player doesn't already have it
function BadgeUtils:AwardCarBadge(player, carId)
	if not player or not carId then return end

	local badgeInfo = BadgesData[carId]
	if not badgeInfo then
		warn("No badge configured for car:", carId)
		return
	end

	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, badgeInfo.BadgeId)
	end)

	if not success then
		warn("Failed to check badge:", badgeInfo.BadgeId, "for player:", player.Name)
		return
	end

	if not hasBadge then
		local awardSuccess, awardErr = pcall(function()
			BadgeService:AwardBadge(player.UserId, badgeInfo.BadgeId)
		end)

		if awardSuccess then
			print(string.format("Awarded badge [%s] (%d) to %s", badgeInfo.Name, badgeInfo.BadgeId, player.Name))
		else
			warn("Failed to award badge:", badgeInfo.BadgeId, awardErr)
		end
	end
end

return BadgeUtils
