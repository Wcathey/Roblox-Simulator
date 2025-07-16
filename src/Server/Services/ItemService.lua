local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsData = require(ReplicatedStorage.Shared.Items.ItemsData)

local ItemService = {}

local RARITY_WEIGHTS = {
	Common = 50,
	Uncommon = 30,
	Rare = 15,
	Epic = 4,
	Legendary = 1,
	Mythic = 0.5,
	Exotic = 0.2,
}

function ItemService.getRarityWeight(rarity)
	return RARITY_WEIGHTS[rarity] or 0
end

function ItemService.getRandomItem(weighted)
	if not weighted then
		return ItemsData[math.random(1, #ItemsData)]
	end

	local pool = {}
	for _, item in ipairs(ItemsData) do
		local weight = ItemService.getRarityWeight(item.rarity)
		if weight > 0 then
			for _ = 1, math.floor(weight * 10) do
				table.insert(pool, item)
			end
		end
	end

	if #pool == 0 then
		warn("Item pool is empty or weight misconfigured.")
		return nil
	end

	return pool[math.random(1, #pool)]
end

return ItemService
