local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CarsData = require(ReplicatedStorage.Shared.Cars.CarsData)
local CarUtils = require(ReplicatedStorage.Shared.Cars.CarUtils)

local BadgeUtils = require(script.Parent.BadgeUtils)
local BadgesData = require(ReplicatedStorage.Shared.Badges.BadgesData)

local CarService = {}

-- Game pass check
function CarService:PlayerHasGamePass(player, gamePassId)
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

-- Get eligible cars
function CarService:GetEligibleCars(player, playerData)
	local eligibleCars = {}

	for _, car in ipairs(CarsData.StarterCars) do
		table.insert(eligibleCars, car)
	end

	for _, car in ipairs(CarsData.RebirthCars) do
		if CarUtils:PlayerMeetsRequirements(playerData, car.Id) then
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

-- Award badge for car
function CarService:AwardCarBadge(player, carId)
	if carId then
		local badgeInfo = BadgesData[carId]
		if badgeInfo and badgeInfo.BadgeId then
			BadgeUtils:AwardBadgeForCar(player, badgeInfo.BadgeId)
		end
	end
end

return CarService
