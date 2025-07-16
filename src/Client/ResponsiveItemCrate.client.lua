local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Items = require(ReplicatedStorage.Shared.Items)
local ItemsData = Items.ItemsData

local rarityRemote = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetRarityPercentages")
local rarityPercentages = rarityRemote:InvokeServer()

local crateRollGui = playerGui:WaitForChild("CrateRollGui")
local mainFrame = crateRollGui:WaitForChild("MainFrame")
local itemListFrame = mainFrame:WaitForChild("ItemListFrame")
local buttonFrame = mainFrame:WaitForChild("ButtonFrame")

for _, child in pairs(itemListFrame:GetChildren()) do
	child:Destroy()
end

itemListFrame.Position = UDim2.new(0, 0, 0, 0)
itemListFrame.Size = UDim2.new(1, 0, 1, -buttonFrame.AbsoluteSize.Y - 10)
mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
itemListFrame.BackgroundTransparency = 1

local function calculateOptimalGrid()
	local itemCount = #ItemsData
	local aspectRatio = itemListFrame.AbsoluteSize.X / itemListFrame.AbsoluteSize.Y
	local targetCellAspectRatio = 0.75
	local bestColumns = 1
	local bestRows = itemCount
	local bestRatio = math.huge

	for columns = 1, math.min(itemCount, 10) do
		local rows = math.ceil(itemCount / columns)
		local cellWidth = 1 / columns
		local cellHeight = 1 / rows
		local cellAspectRatio = (cellWidth * aspectRatio) / cellHeight
		local ratioDiff = math.abs(cellAspectRatio - targetCellAspectRatio)

		if ratioDiff < bestRatio then
			bestRatio = ratioDiff
			bestColumns = columns
			bestRows = rows
		end
	end

	local paddingScale = 0.02
	local cellWidth = (1 - paddingScale * (bestColumns + 1)) / bestColumns
	local cellHeight = (1 - paddingScale * (bestRows + 1)) / bestRows

	cellWidth = math.max(cellWidth, 0.1)
	cellHeight = math.max(cellHeight, 0.15)

	return cellWidth, cellHeight, bestColumns, bestRows
end

local cellWidth, cellHeight, columns, rows = calculateOptimalGrid()

print(string.format("Grid Layout: %d items in %dx%d grid (%.1f%% x %.1f%% cells)", #ItemsData, columns, rows, cellWidth * 100, cellHeight * 100))

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.new(0.02, 0, 0.02, 0)
gridLayout.CellSize = UDim2.new(cellWidth, 0, cellHeight, 0)
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.SortOrder = Enum.SortOrder.Name
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
gridLayout.Parent = itemListFrame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0.01, 0)
padding.PaddingRight = UDim.new(0.01, 0)
padding.PaddingTop = UDim.new(0.01, 0)
padding.PaddingBottom = UDim.new(0.01, 0)
padding.Parent = itemListFrame

local itemCardTemplate = Instance.new("Frame")
itemCardTemplate.Name = "ItemCardTemplate"
itemCardTemplate.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
itemCardTemplate.BorderSizePixel = 2
itemCardTemplate.Visible = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.06, 0)
corner.Parent = itemCardTemplate

local itemImage = Instance.new("ImageLabel")
itemImage.Name = "ItemImage"
itemImage.Size = UDim2.new(0.9, 0, 0.6, 0)
itemImage.Position = UDim2.new(0.05, 0, 0.05, 0)
itemImage.BackgroundTransparency = 1
itemImage.ScaleType = Enum.ScaleType.Fit
itemImage.Parent = itemCardTemplate

local rarityLabel = Instance.new("TextLabel")
rarityLabel.Name = "RarityLabel"
rarityLabel.Size = UDim2.new(0.95, 0, 0.15, 0)
rarityLabel.Position = UDim2.new(0.025, 0, 0.67, 0)
rarityLabel.BackgroundTransparency = 1
rarityLabel.Text = "Rarity"
rarityLabel.TextScaled = true
rarityLabel.Font = Enum.Font.SourceSansBold
rarityLabel.Parent = itemCardTemplate

local percentLabel = Instance.new("TextLabel")
percentLabel.Name = "PercentageLabel"
percentLabel.Size = UDim2.new(0.95, 0, 0.12, 0)
percentLabel.Position = UDim2.new(0.025, 0, 0.84, 0)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0.00%"
percentLabel.TextScaled = true
percentLabel.Font = Enum.Font.SourceSans
percentLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
percentLabel.Parent = itemCardTemplate

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
})
gradient.Rotation = 90
gradient.Parent = itemCardTemplate

itemCardTemplate.Parent = itemListFrame

if itemListFrame:IsA("ScrollingFrame") then
	local totalHeight = rows * (cellHeight + 0.02) + 0.02

	if totalHeight > 1 then
		itemListFrame.ScrollingEnabled = true
		itemListFrame.CanvasSize = UDim2.new(0, 0, totalHeight, 0)
		itemListFrame.ScrollBarThickness = 6
		itemListFrame.ScrollBarImageColor3 = Color3.new(0.3, 0.3, 0.3)
	else
		itemListFrame.ScrollingEnabled = false
		itemListFrame.CanvasSize = UDim2.new(0, 0, 1, 0)
	end
end

local rarityColors = {
	Common = Color3.fromRGB(176, 176, 176),
	Uncommon = Color3.fromRGB(30, 255, 0),
	Rare = Color3.fromRGB(0, 112, 221),
	Epic = Color3.fromRGB(163, 53, 238),
	Legendary = Color3.fromRGB(255, 128, 0),
	Mythic = Color3.fromRGB(255, 0, 0),
	Exotic = Color3.fromRGB(255, 255, 0)
}

local function getRarityPercentage(rarity)
	return rarityPercentages[rarity] or "0.00%"
end

print("Creating responsive item grid...")

for i, itemData in ipairs(ItemsData) do
	local itemCard = itemCardTemplate:Clone()
	itemCard.Name = string.format("%03d_%s", i, itemData.name:gsub(" ", "_"))
	itemCard.Visible = true
	itemCard.BorderColor3 = rarityColors[itemData.rarity] or Color3.new(0.3, 0.3, 0.3)

	local rarityMultiplier = {
		Common = 1,
		Uncommon = 0.95,
		Rare = 0.9,
		Epic = 0.85,
		Legendary = 0.8,
		Mythic = 0.75,
		Exotic = 0.7
	}

	local mult = rarityMultiplier[itemData.rarity] or 1
	itemCard.BackgroundColor3 = Color3.new(0.08 * mult, 0.08 * mult, 0.08 * mult)

	local img = itemCard:FindFirstChild("ItemImage")
	if img then
		img.Image = itemData.image
	end

	local rarity = itemCard:FindFirstChild("RarityLabel")
	if rarity then
		rarity.Text = itemData.rarity
		rarity.TextColor3 = rarityColors[itemData.rarity] or Color3.new(1, 1, 1)
	end

	local percent = itemCard:FindFirstChild("PercentageLabel")
	if percent then
		percent.Text = getRarityPercentage(itemData.rarity)
	end

	itemCard.MouseEnter:Connect(function()
		itemCard.BorderSizePixel = 3
		itemCard.ZIndex = 2
	end)

	itemCard.MouseLeave:Connect(function()
		itemCard.BorderSizePixel = 2
		itemCard.ZIndex = 1
	end)

	itemCard.Parent = itemListFrame
end

local function refreshLayout()
	cellWidth, cellHeight, columns, rows = calculateOptimalGrid()
	gridLayout.CellSize = UDim2.new(cellWidth, 0, cellHeight, 0)

	if itemListFrame:IsA("ScrollingFrame") then
		local totalHeight = rows * (cellHeight + 0.02) + 0.02

		if totalHeight > 1 then
			itemListFrame.ScrollingEnabled = true
			itemListFrame.CanvasSize = UDim2.new(0, 0, totalHeight, 0)
		else
			itemListFrame.ScrollingEnabled = false
			itemListFrame.CanvasSize = UDim2.new(0, 0, 1, 0)
		end
	end
end

itemListFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshLayout)

buttonFrame.ZIndex = 2

print("Responsive grid created with", #ItemsData, "items")
