-- Server/CrateService.server.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ItemUtils = require(ReplicatedStorage.Shared.Items.ItemUtils)

-- Ensure RemoteEvents exist in ReplicatedStorage
local RollRequest = ReplicatedStorage:WaitForChild("RollRequest")
local RollResult = ReplicatedStorage:WaitForChild("RollResult")

local AutoRollCancel = ReplicatedStorage:FindFirstChild("AutoRollCancel")
if not AutoRollCancel then
    AutoRollCancel = Instance.new("RemoteEvent")
    AutoRollCancel.Name = "AutoRollCancel"
    AutoRollCancel.Parent = ReplicatedStorage
end

local COOLDOWN_TIME = 1
local rollCooldown = {}
local autoRolling = {}

-- Handle auto-roll cancel from client
AutoRollCancel.OnServerEvent:Connect(function(player)
    autoRolling[player.UserId] = false
end)

-- Core roll logic: get a random item
local function rollItem()
    return ItemUtils.getRandomItem(true)
end

-- Handle roll requests from clients
RollRequest.OnServerEvent:Connect(function(player, rollType)
    if not player or not player:IsA("Player") then
        return
    end

    local uid = player.UserId
    local now = tick()

    if rollType == "single" or not rollType then
        if rollCooldown[uid] and now - rollCooldown[uid] < COOLDOWN_TIME then
            return
        end

        rollCooldown[uid] = now
        local item = rollItem()
        RollResult:FireClient(player, item)

    elseif rollType == "x3" then
        if rollCooldown[uid] and now - rollCooldown[uid] < COOLDOWN_TIME then
            return
        end

        rollCooldown[uid] = now
        for _ = 1, 3 do
            local item = rollItem()
            RollResult:FireClient(player, item)
            task.wait(0.2)
        end

    elseif rollType == "auto" then
        if autoRolling[uid] then
            return
        end

        autoRolling[uid] = true
        while autoRolling[uid] do
            if rollCooldown[uid] and tick() - rollCooldown[uid] < COOLDOWN_TIME then
                task.wait(0.1)
            else
                rollCooldown[uid] = tick()
                local item = rollItem()
                RollResult:FireClient(player, item)
                task.wait(0.5) -- pacing delay
            end
        end
    end
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    local uid = player.UserId
    rollCooldown[uid] = nil
    autoRolling[uid] = nil
end)
