-- ServerScriptService/Services/ItemDisplayService.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemService = require(script.Parent.ItemService)
local ItemsData = require(ReplicatedStorage.Shared.Items.ItemsData)

local ItemDisplayService = {}

function ItemDisplayService:GetRarityPercentages()
	local totalWeight = 0
	local rarityWeights = {}

	-- Preprocess total weight
	for _, item in ipairs(ItemsData) do
		local weight = ItemService.getRarityWeight(item.rarity)
		rarityWeights[item.rarity] = (rarityWeights[item.rarity] or 0) + weight
		totalWeight += weight
	end

	-- Convert to percentage strings
	local percentages = {}
	for rarity, weight in pairs(rarityWeights) do
		percentages[rarity] = string.format("%.2f%%", (weight / totalWeight) * 100)
	end

	return percentages
end

return ItemDisplayService
