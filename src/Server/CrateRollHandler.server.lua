-- CrateRollServer.server.lua
-- This script goes in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Services (using script.Parent since this is in ServerScriptService)
local PlayerDataService = require(script.Parent.Services.PlayerDataService)

-- Shared Modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Items = require(Shared.Items)
local Crates = require(Shared.Crates)

-- Extract from modules
local ItemsData = Items.ItemsData
local ItemUtils = Items.ItemUtils
local CratesData = Crates.CratesData
local CrateUtils = Crates.CrateUtils

-- Remote Events
local SingleRollBillboardButton = ReplicatedStorage:WaitForChild("SingleRollBillboardButton")
local TripleRollBillboardButton = ReplicatedStorage:WaitForChild("TripleRollBillboardButton")
local AutoRollBillboardButton = ReplicatedStorage:WaitForChild("AutoRollBillboardButton")
local ShowRollResult = ReplicatedStorage:WaitForChild("ShowRollResult")

-- Configuration
local CRATE_DISTANCE = 20 -- Maximum distance to interact with crate
local CURRENT_CRATE_ID = "spawn_area_crate" -- Using the spawn area crate

-- Auto roll settings
local AUTO_ROLL_DELAY = 2 -- Seconds between auto rolls

-- Player states
local playerCooldowns = {}
local autoRollConnections = {}

-- Get the crate model (adjust path as needed)
local crateModel = workspace:WaitForChild("Crate")

-- Get current crate data
local function getCurrentCrate()
    for _, crate in ipairs(CratesData) do
        if crate.id == CURRENT_CRATE_ID then
            return crate
        end
    end
    return CratesData[1] -- Fallback to first crate
end

-- Initialize CrateUtils server functions
CrateUtils._serverFunctions = {
    getPlayerCrateInventory = function(player)
        local playerData = PlayerDataService:GetData(player)
        return playerData and playerData.CrateInventory or {}
    end,

    removeItemFromInventory = function(player, itemName)
        local playerData = PlayerDataService:GetData(player)
        if not playerData or not playerData.CrateInventory then return false end

        for i, item in ipairs(playerData.CrateInventory) do
            if item.name == itemName then
                -- Decrease quantity or remove entirely
                if item.quantity and item.quantity > 1 then
                    item.quantity = item.quantity - 1
                else
                    table.remove(playerData.CrateInventory, i)
                end
                PlayerDataService:UpdateData(player, "CrateInventory", playerData.CrateInventory)
                return true
            end
        end
        return false
    end
}

-- Helper function to get weighted random rarity
local function getRandomRarity()
    -- Build weighted selection using ItemUtils rarity weights
    local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exotic"}
    local totalWeight = 0
    local weights = {}

    for _, rarity in ipairs(rarities) do
        local weight = ItemUtils.getRarityWeight(rarity)
        weights[rarity] = weight
        totalWeight = totalWeight + weight
    end

    local random = math.random() * totalWeight
    local currentWeight = 0

    for _, rarity in ipairs(rarities) do
        currentWeight = currentWeight + weights[rarity]
        if random <= currentWeight then
            return rarity
        end
    end

    return "Common" -- Fallback
end

-- Function to get random item based on rarity
local function getRandomItemByRarity(rarity)
    local itemsOfRarity = ItemUtils.getItemsByRarity(rarity)

    if #itemsOfRarity > 0 then
        return itemsOfRarity[math.random(1, #itemsOfRarity)]
    else
        -- Fallback to any random item
        return ItemUtils.getRandomItem(false) -- Not weighted since we already selected rarity
    end
end

-- Function to check if player is near crate
local function isPlayerNearCrate(player)
    local character = player.Character
    if not character then return false end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    local cratePrimaryPart = crateModel.PrimaryPart or crateModel:FindFirstChild("Base") or crateModel:FindFirstChildOfClass("BasePart")
    if not cratePrimaryPart then
        warn("Crate has no primary part!")
        return false
    end

    local distance = (humanoidRootPart.Position - cratePrimaryPart.Position).Magnitude
    return distance <= CRATE_DISTANCE
end

-- Function to add item to player's crate inventory
local function addItemToInventory(player, item)
    local playerData = PlayerDataService:GetData(player)
    if not playerData then return false end

    -- Initialize CrateInventory if it doesn't exist
    if not playerData.CrateInventory then
        PlayerDataService:UpdateData(player, "CrateInventory", {})
        playerData = PlayerDataService:GetData(player) -- Refresh data
    end

    -- Add item to crate inventory
    local crateItem = {
        name = item.name,
        rarity = item.rarity,
        image = item.image,
        obtainedAt = os.time(),
        quantity = 1
    }

    -- Check if item already exists and increase quantity
    local found = false
    for i, invItem in ipairs(playerData.CrateInventory) do
        if invItem.name == crateItem.name then
            invItem.quantity = (invItem.quantity or 1) + 1
            found = true
            break
        end
    end

    if not found then
        table.insert(playerData.CrateInventory, crateItem)
    end

    PlayerDataService:UpdateData(player, "CrateInventory", playerData.CrateInventory)
    return true
end

-- Function to perform a roll
local function performRoll(player, rollCount, cost)
    -- Check if player is on cooldown
    if playerCooldowns[player] and tick() - playerCooldowns[player] < 0.5 then
        return false, "Please wait before rolling again!"
    end

    -- Check if player is near crate
    if not isPlayerNearCrate(player) then
        return false, "You're too far from the crate!"
    end

    -- Get player data
    local playerData = PlayerDataService:GetData(player)
    if not playerData then
        return false, "Failed to load player data!"
    end

    -- Check if player has enough cash
    if playerData.Cash < cost then
        return false, "Not enough cash! Need $" .. cost .. "."
    end

    -- Deduct cash (negative amount to reduce)
    PlayerDataService:GiveCash(player, -cost)

    -- Roll items using ItemUtils
    local rolledItems = {}
    for i = 1, rollCount do
        -- Method 1: Use manual rarity selection then get item
        local rarity = getRandomRarity()
        local item = getRandomItemByRarity(rarity)

        -- Alternative Method 2: Use ItemUtils weighted random directly
        -- local item = ItemUtils.getRandomItem(true) -- true for weighted

        if item then
            -- Get full item data using ItemUtils
            local fullItemData = ItemUtils.getItemByName(item.name) or item

            table.insert(rolledItems, {
                name = fullItemData.name,
                rarity = fullItemData.rarity,
                image = fullItemData.image
            })

            -- Add item to player's crate inventory
            addItemToInventory(player, fullItemData)

            print(player.Name .. " received: " .. fullItemData.name .. " (" .. fullItemData.rarity .. ")")
        end
    end

    -- Set cooldown
    playerCooldowns[player] = tick()

    return true, rolledItems
end

-- Handle single roll
SingleRollBillboardButton.OnServerEvent:Connect(function(player)
    print(player.Name .. " requested single roll")

    local crateData = getCurrentCrate()
    local cost = crateData.cost.single

    local success, result = performRoll(player, 1, cost)

    if success then
        ShowRollResult:FireClient(player, "single", result)
    else
        -- Show error message to player
        warn("Roll failed for " .. player.Name .. ": " .. result)
    end
end)

-- Handle triple roll
TripleRollBillboardButton.OnServerEvent:Connect(function(player)
    print(player.Name .. " requested triple roll")

    local crateData = getCurrentCrate()
    local cost = crateData.cost.triple

    local success, result = performRoll(player, 3, cost)

    if success then
        ShowRollResult:FireClient(player, "triple", result)
    else
        -- Show error message to player
        warn("Roll failed for " .. player.Name .. ": " .. result)
    end
end)

-- Handle auto roll
AutoRollBillboardButton.OnServerEvent:Connect(function(player, enable)
    print(player.Name .. " toggled auto roll:", enable)

    if enable then
        -- Start auto rolling
        if autoRollConnections[player] then
            autoRollConnections[player]:Disconnect()
        end

        local crateData = getCurrentCrate()
        local cost = crateData.cost.single -- Auto roll uses single roll cost

        -- Create auto roll loop
        autoRollConnections[player] = task.spawn(function()
            while player.Parent and autoRollConnections[player] do
                local success, result = performRoll(player, 1, cost)

                if success then
                    ShowRollResult:FireClient(player, "single", result)
                    task.wait(AUTO_ROLL_DELAY)
                else
                    -- Stop auto rolling on error
                    print("Auto roll stopped for " .. player.Name .. ": " .. result)
                    autoRollConnections[player] = nil
                    ShowRollResult:FireClient(player, "autoStopped", {})
                    break
                end
            end
        end)
    else
        -- Stop auto rolling
        if autoRollConnections[player] then
            task.cancel(autoRollConnections[player])
            autoRollConnections[player] = nil
            ShowRollResult:FireClient(player, "autoStopped", {})
        end
    end
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    playerCooldowns[player] = nil

    if autoRollConnections[player] then
        task.cancel(autoRollConnections[player])
        autoRollConnections[player] = nil
    end
end)

-- Optional: Periodic distance check to stop auto-roll if player moves away
RunService.Heartbeat:Connect(function()
    for player, connection in pairs(autoRollConnections) do
        if connection and not isPlayerNearCrate(player) then
            task.cancel(connection)
            autoRollConnections[player] = nil
            ShowRollResult:FireClient(player, "autoStopped", {})
            print("Auto roll stopped for " .. player.Name .. " - too far from crate")
        end
    end
end)

-- Debug: Print available items and rarities
print("Available rarities and items:")
for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exotic"}) do
    local items = ItemUtils.getItemsByRarity(rarity)
    print(rarity .. ": " .. #items .. " items")
end

print("Crate Roll Server initialized - Using ItemsData and ItemUtils")
