local ItemsData = require(script.Parent.ItemsData)

local ItemUtils = {}

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

return ItemUtils
