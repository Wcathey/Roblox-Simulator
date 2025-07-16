-- ServerScriptService/RemoteHandlers/RarityPercentagesHandler.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDisplayService = require(script.Parent.Parent.Services.ItemDisplayService)
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")

local rarityRemote = Instance.new("RemoteFunction")
rarityRemote.Name = "GetRarityPercentages"
rarityRemote.Parent = RemoteFunctions

rarityRemote.OnServerInvoke = function()
	return ItemDisplayService:GetRarityPercentages()
end
