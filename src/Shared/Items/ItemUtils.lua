local ItemsData = require(script.Parent.ItemsData)

local ItemUtils = {}

-- Optional: control rarity weight
local RARITY_WEIGHTS = {
	Common = 50,
	Uncommon = 30,
	Rare = 15,
	Epic = 4,
	Legendary = 1,
	Mythic = 0.5,
	Exotic = 0.2,
}

function ItemUtils.getItemByName(name)
	for _, item in ipairs(ItemsData) do
		if item.name == name then
			return item
		end
	end
	return nil
end

function ItemUtils.getItemsByRarity(rarity)
	local result = {}
	for _, item in ipairs(ItemsData) do
		if item.rarity == rarity then
			table.insert(result, item)
		end
	end
	return result
end

-- Optional utility: get the weight for a given rarity
function ItemUtils.getRarityWeight(rarity)
	return RARITY_WEIGHTS[rarity] or 0
end

-- Get a random item, optionally weighted by rarity
function ItemUtils.getRandomItem(weighted)
	if not weighted then
		return ItemsData[math.random(1, #ItemsData)]
	end

	-- Build a weighted pool
	local pool = {}
	for _, item in ipairs(ItemsData) do
		local weight = ItemUtils.getRarityWeight(item.rarity)
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

return ItemUtils
