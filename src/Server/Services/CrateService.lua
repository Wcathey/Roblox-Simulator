local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- 🔧 Ensure RemoteFunctions folder exists
local RemoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
if not RemoteFunctions then
	RemoteFunctions = Instance.new("Folder")
	RemoteFunctions.Name = "RemoteFunctions"
	RemoteFunctions.Parent = ReplicatedStorage
end

-- 🔧 Helper to create or get a RemoteFunction
local function getOrCreateRemoteFunction(name)
	local rf = RemoteFunctions:FindFirstChild(name)
	if not rf then
		rf = Instance.new("RemoteFunction")
		rf.Name = name
		rf.Parent = RemoteFunctions
	end
	return rf
end

local RollSingle = getOrCreateRemoteFunction("RollSingle")
local RollTriple = getOrCreateRemoteFunction("RollTriple")
local RollAuto = getOrCreateRemoteFunction("RollAuto")

-- 🔁 Dependencies
local CratesData = require(ReplicatedStorage.Shared.Crates.CratesData)
local PlayerDataService = require(script.Parent.PlayerDataService)

local CrateService = {}
local activeAutoRolls = {}

--------------------------------------------------------
-- 🔍 Get crate by ID
--------------------------------------------------------
function CrateService:GetCrateById(crateId)
	print("[CrateService] Looking for crate:", crateId)
	for _, crate in ipairs(CratesData) do
		print("Checking crate:", crate.id)
		if crate.id == crateId then
			print("✅ Crate matched:", crate.id)
			return crate
		end
	end
	warn("❌ Crate not found:", crateId)
	return nil, "Crate not found: " .. crateId
end

--------------------------------------------------------
-- 🎲 Weighted rarity roll
--------------------------------------------------------
local function getRandomRarity(weights)
	if typeof(weights) ~= "table" then
		warn("⚠️ Invalid weights table")
		return "Common"
	end

	local totalWeight = 0
	for _, weight in pairs(weights) do
		totalWeight += weight
	end

	if totalWeight == 0 then
		warn("⚠️ Rarity weights total 0")
		return "Common"
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for rarity, weight in pairs(weights) do
		cumulative += weight
		if roll <= cumulative then
			print("🎲 Rarity rolled:", rarity)
			return rarity
		end
	end

	return "Common"
end

--------------------------------------------------------
-- 🎁 Get a random item from crate
--------------------------------------------------------
function CrateService:GetRandomItemFromCrate(crate)
	if typeof(crate) ~= "table" then
		warn("❌ Invalid crate passed to GetRandomItemFromCrate")
		return nil, "Invalid crate"
	end

	print("[CrateService] Rolling from crate:", crate.name)

	local rarity = getRandomRarity(crate.rarityWeights)
	local pool = {}

	for _, item in ipairs(crate.items) do
		if item.rarity == rarity then
			table.insert(pool, item)
		end
	end

	print("🎯 Items in pool for rarity", rarity, ":", #pool)

	if #pool == 0 then
		return nil, "No items of rarity: " .. rarity
	end

	local chosen = pool[math.random(1, #pool)]
	print("🎁 Selected item:", chosen.name, "of rarity:", chosen.rarity)
	return chosen
end

--------------------------------------------------------
-- 📦 Add item to player's inventory
--------------------------------------------------------
function CrateService:AddItemToInventory(player, item)
	local profile = PlayerDataService:Get(player)
	if not profile then
		warn("❌ No profile found for", player.Name)
		return false, "No profile"
	end

	profile.Data.CrateInventory = profile.Data.CrateInventory or {}
	table.insert(profile.Data.CrateInventory, item)

	print("✅", player.Name, "received item:", item.name)
	return true
end

--------------------------------------------------------
-- 🔄 SINGLE ROLL
--------------------------------------------------------
RollSingle.OnServerInvoke = function(player, crateId)
	print("[SERVER] RollSingle called by", player.Name, "with crate:", crateId)

	local crate, err = CrateService:GetCrateById(crateId)
	if not crate then return nil, err end

	local item, rollErr = CrateService:GetRandomItemFromCrate(crate)
	if not item then
		warn("❌ Single roll failed:", rollErr)
		return nil, rollErr
	end

	local success, saveErr = CrateService:AddItemToInventory(player, item)
	if not success then return nil, saveErr end

	return item
end

--------------------------------------------------------
-- 🔁 TRIPLE ROLL
--------------------------------------------------------
RollTriple.OnServerInvoke = function(player, crateId)
	print("[SERVER] RollTriple called by", player.Name, "with crate:", crateId)

	local crate, err = CrateService:GetCrateById(crateId)
	if not crate then return nil, err end

	local results = {}
	for i = 1, 3 do
		local item = CrateService:GetRandomItemFromCrate(crate)
		if item then
			CrateService:AddItemToInventory(player, item)
			table.insert(results, item)
		end
	end

	if #results == 0 then
		return nil, "No items rolled"
	end

	return results
end

--------------------------------------------------------
-- 🔁 AUTO ROLL
--------------------------------------------------------
RollAuto.OnServerInvoke = function(player, crateId, duration)
	print("[SERVER] RollAuto called by", player.Name, "crate:", crateId, "duration:", duration)

	-- Cancel existing session
	if activeAutoRolls[player.UserId] then
		activeAutoRolls[player.UserId].active = false
	end

	local crate, err = CrateService:GetCrateById(crateId)
	if not crate then return nil, err end

	local session = { active = true }
	activeAutoRolls[player.UserId] = session

	local start = os.clock()
	local results = {}

	while os.clock() - start < duration do
		if not session.active then
			print("🛑 Auto roll manually cancelled for", player.Name)
			break
		end

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local crateModel = Workspace:FindFirstChild(crateId)

		if root and crateModel and crateModel:IsA("Model") and crateModel.PrimaryPart then
			local dist = (crateModel.PrimaryPart.Position - root.Position).Magnitude
			if dist > 30 then
				print("📏 Auto roll stopped, too far from crate")
				break
			end
		end

		local item = CrateService:GetRandomItemFromCrate(crate)
		if item then
			CrateService:AddItemToInventory(player, item)
			table.insert(results, item)
		end

		task.wait(1)
	end

	activeAutoRolls[player.UserId] = nil

	if #results == 0 then
		return nil, "No items rolled"
	end

	return results
end

--------------------------------------------------------
-- 🧹 Cleanup on Player Leave
--------------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
	if activeAutoRolls[player.UserId] then
		activeAutoRolls[player.UserId].active = false
		activeAutoRolls[player.UserId] = nil
		print("🧹 Cleaned up auto roll session for:", player.Name)
	end
end)

return CrateService
