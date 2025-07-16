local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cars = require(ReplicatedStorage.Shared.Cars)
local CarsData = Cars.CarsData
local BadgeUtils = require(script.Parent.BadgeUtils)  -- Use BadgeUtils here

local ProfileService = require(game.ServerPackages.ProfileService)

local PlayerDataService = {}

local ProfileTemplate = {
	Cash = 100000,
	Level = 1,
	XP = 0,
	Rebirths = 0,
	LogInTimes = 0,
	Cars = {},
	Garage = {}, -- key: carId, value: {Level = 1, Upgrades = {}}
	CrateInventory = {},
	OwnedDecals = {},
	Stats = {
		RacesWon = 0,
		TotalBounties = 0,
		GarageValue = 0,
		SideQuestsCompleted = 0,
	},
	QuestProgress = {},
	Settings = {
		MusicVolume = 0.5,
		ShowTutorial = true,
	}
}

local Profiles = {}
local ProfileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

-- RemoteFunction: IsNewPlayer
local isNewPlayerRemote = Instance.new("RemoteFunction")
isNewPlayerRemote.Name = "NewPlayerCheck"
isNewPlayerRemote.Parent = ReplicatedStorage.RemoteFunctions

isNewPlayerRemote.OnServerInvoke = function(player)
	local profile = Profiles[player]
	return profile and profile.Data.LogInTimes == 1
end

-- RemoteEvent: StarterCarSelected
local starterCarSelectedEvent = Instance.new("RemoteEvent")
starterCarSelectedEvent.Name = "StarterCarSelected"
starterCarSelectedEvent.Parent = ReplicatedStorage.RemoteEvents

starterCarSelectedEvent.OnServerEvent:Connect(function(player, carId)
	local profile = Profiles[player]
	if not profile then
		warn("PlayerDataService: Profile not found for player", player.Name)
		return
	end

	profile.Data.Garage = profile.Data.Garage or {}

	if profile.Data.Garage[carId] then
		print(player.Name .. " already owns the car '" .. carId .. "'.")
		return
	end

	profile.Data.Garage[carId] = {
		Level = 1,
		Upgrades = {},
	}

	table.insert(profile.Data.Cars, carId)

	print(player.Name .. " added starter car '" .. carId .. "' to their Garage.")

	local carData = nil
	for _, car in ipairs(CarsData.StarterCars) do
		if car.Id == carId then
			carData = car
			break
		end
	end

	if carData then
		BadgeUtils:AwardCarBadge(player, carData.id)
	end
end)


function PlayerDataService:Get(player)
	return Profiles[player]
end

function PlayerDataService:GetData(player)
	local profile = Profiles[player]
	return profile and profile.Data
end

function PlayerDataService:GiveCash(player, amount)
	local profile = Profiles[player]
	if profile then
		profile.Data.Cash += amount
	end
end

function PlayerDataService:UpdateData(player, key, value)
	local profile = Profiles[player]
	if profile then
		profile.Data[key] = value
	end
end

local function onPlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick("Your data was released.")
		end)

		if player:IsDescendantOf(Players) then
			Profiles[player] = profile
			profile.Data.LogInTimes += 1
			print(player.Name .. " has logged in " .. profile.Data.LogInTimes .. " time(s).")
		else
			profile:Release()
		end
	else
		player:Kick("Could not load your data.")
	end
end

local function onPlayerRemoving(player)
	local profile = Profiles[player]
	if profile then
		profile:Release()
	end
end

-- Init existing players
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

return PlayerDataService
