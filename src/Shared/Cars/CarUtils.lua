local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ✅ Require only CarsData directly (no cyclic dependency)
local CarsData = require(script.Parent.CarsData)

-- ✅ Require badges safely via full folder
local Badges = require(ReplicatedStorage.Shared.Badges)
local BadgeUtils = Badges.BadgeUtils
local BadgesData = Badges.BadgesData
local CarUtils = {}

----------------------------------------------------------------
-- Game Pass Utility
----------------------------------------------------------------
function CarUtils:PlayerHasGamePass(player, gamePassId)
	if not player or not gamePassId then return false end

	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)

	if not success then
		warn("Failed to check Game Pass:", gamePassId, "for", player.Name)
		return false
	end

	return owns
end

----------------------------------------------------------------
-- Requirement Checking
----------------------------------------------------------------
function CarUtils:PlayerMeetsRequirements(playerData, carId)
	local req = CarsData.Requirements[carId]
	if not req then return true end

	if playerData.Level < (req.MinLevel or 0) then return false end
	if playerData.Rebirth < (req.MinRebirth or 0) then return false end

	if req.RequiredAchievements then
		for _, requiredAch in ipairs(req.RequiredAchievements) do
			local hasAch = false
			for _, playerAch in ipairs(playerData.Achievements or {}) do
				if playerAch == requiredAch then
					hasAch = true
					break
				end
			end
			if not hasAch then return false end
		end
	end

	return true
end

----------------------------------------------------------------
-- Eligible Cars
----------------------------------------------------------------
function CarUtils:GetEligibleCars(player, playerData)
	local eligibleCars = {}

	for _, car in ipairs(CarsData.StarterCars) do
		table.insert(eligibleCars, car)
	end

	for _, car in ipairs(CarsData.RebirthCars) do
		if self:PlayerMeetsRequirements(playerData, car.Id) then
			table.insert(eligibleCars, car)
		end
	end

	for _, car in ipairs(CarsData.GamePassCars) do
		if self:PlayerHasGamePass(player, car.GamePassId) then
			table.insert(eligibleCars, car)
		end
	end

	return eligibleCars
end

----------------------------------------------------------------
-- Award Car Badge using BadgeUtils
----------------------------------------------------------------
function CarUtils:AwardCarBadge(player, car)
    if car and car.Id then
        local badgeInfo = BadgesData[car.Id]
        if badgeInfo and badgeInfo.BadgeId then
            BadgeUtils:TryAwardBadge(player, badgeInfo.BadgeId)
        end
    end
end

return CarUtils
