-- ResponsiveItemGrid.client.lua
-- Automatically adjusts grid layout based on number of items

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get the Items module
local Items = require(ReplicatedStorage.Shared.Items)
local ItemsData = Items.ItemsData
local ItemUtils = Items.ItemUtils

-- Get the GUI elements
local crateRollGui = playerGui:WaitForChild("CrateRollGui")
local mainFrame = crateRollGui:WaitForChild("MainFrame")
local itemListFrame = mainFrame:WaitForChild("ItemListFrame")
local buttonFrame = mainFrame:WaitForChild("ButtonFrame")

-- Clear everything in ItemListFrame
for _, child in pairs(itemListFrame:GetChildren()) do
    child:Destroy()
end

-- Set ItemListFrame to fill MainFrame but leave room for buttons
itemListFrame.Position = UDim2.new(0, 0, 0, 0)
itemListFrame.Size = UDim2.new(1, 0, 1, -buttonFrame.AbsoluteSize.Y - 10)

-- Make MainFrame background match
mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
itemListFrame.BackgroundTransparency = 1

-- Calculate optimal grid layout based on item count
local function calculateOptimalGrid()
    local itemCount = #ItemsData
    local aspectRatio = itemListFrame.AbsoluteSize.X / itemListFrame.AbsoluteSize.Y

    -- Target cell aspect ratio (width/height)
    local targetCellAspectRatio = 0.75

    -- Find optimal columns and rows
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

    -- Calculate cell size with padding
    local paddingScale = 0.02 -- 2% padding
    local cellWidth = (1 - paddingScale * (bestColumns + 1)) / bestColumns
    local cellHeight = (1 - paddingScale * (bestRows + 1)) / bestRows

    -- Ensure minimum readable size
    cellWidth = math.max(cellWidth, 0.1) -- Minimum 10% width
    cellHeight = math.max(cellHeight, 0.15) -- Minimum 15% height

    return cellWidth, cellHeight, bestColumns, bestRows
end

-- Get optimal layout
local cellWidth, cellHeight, columns, rows = calculateOptimalGrid()

print(string.format("Grid Layout: %d items in %dx%d grid (%.1f%% x %.1f%% cells)",
    #ItemsData, columns, rows, cellWidth * 100, cellHeight * 100))

-- Create UIGridLayout with calculated sizes
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.new(0.02, 0, 0.02, 0) -- 2% padding
gridLayout.CellSize = UDim2.new(cellWidth, 0, cellHeight, 0)
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.SortOrder = Enum.SortOrder.Name
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
gridLayout.Parent = itemListFrame

-- Add edge padding
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0.01, 0)
padding.PaddingRight = UDim.new(0.01, 0)
padding.PaddingTop = UDim.new(0.01, 0)
padding.PaddingBottom = UDim.new(0.01, 0)
padding.Parent = itemListFrame

-- Create the item card template
local itemCardTemplate = Instance.new("Frame")
itemCardTemplate.Name = "ItemCardTemplate"
itemCardTemplate.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
itemCardTemplate.BorderSizePixel = 2
itemCardTemplate.Visible = false

-- Add UICorner for rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.06, 0)
corner.Parent = itemCardTemplate

-- Create ItemImage (scales with cell size)
local itemImage = Instance.new("ImageLabel")
itemImage.Name = "ItemImage"
itemImage.Size = UDim2.new(0.9, 0, 0.6, 0)
itemImage.Position = UDim2.new(0.05, 0, 0.05, 0)
itemImage.BackgroundTransparency = 1
itemImage.ScaleType = Enum.ScaleType.Fit
itemImage.Parent = itemCardTemplate

-- Create RarityLabel
local rarityLabel = Instance.new("TextLabel")
rarityLabel.Name = "RarityLabel"
rarityLabel.Size = UDim2.new(0.95, 0, 0.15, 0)
rarityLabel.Position = UDim2.new(0.025, 0, 0.67, 0)
rarityLabel.BackgroundTransparency = 1
rarityLabel.Text = "Rarity"
rarityLabel.TextScaled = true
rarityLabel.Font = Enum.Font.SourceSansBold
rarityLabel.Parent = itemCardTemplate

-- Create PercentageLabel
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

-- Add subtle gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
    ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
}
gradient.Rotation = 90
gradient.Parent = itemCardTemplate

-- Parent template to ItemListFrame
itemCardTemplate.Parent = itemListFrame

-- Configure scrolling if needed
if itemListFrame:IsA("ScrollingFrame") then
    -- Calculate if scrolling is needed
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

-- Rarity colors
local rarityColors = {
    Common = Color3.fromRGB(176, 176, 176),
    Uncommon = Color3.fromRGB(30, 255, 0),
    Rare = Color3.fromRGB(0, 112, 221),
    Epic = Color3.fromRGB(163, 53, 238),
    Legendary = Color3.fromRGB(255, 128, 0),
    Mythic = Color3.fromRGB(255, 0, 0),
    Exotic = Color3.fromRGB(255, 255, 0)
}

-- Get rarity percentages
local function getRarityPercentage(rarity)
    local weight = ItemUtils.getRarityWeight(rarity)
    local totalWeight = 0

    for _, item in ipairs(ItemsData) do
        totalWeight = totalWeight + ItemUtils.getRarityWeight(item.rarity)
    end

    local percentage = (weight / totalWeight) * 100
    return string.format("%.2f%%", percentage)
end

-- Create item cards
print("Creating responsive item grid...")
for i, itemData in ipairs(ItemsData) do
    local itemCard = itemCardTemplate:Clone()
    itemCard.Name = string.format("%03d_%s", i, itemData.name:gsub(" ", "_"))
    itemCard.Visible = true
    itemCard.BorderColor3 = rarityColors[itemData.rarity] or Color3.new(0.3, 0.3, 0.3)

    -- Darker background for higher rarities
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

    -- Set image
    local img = itemCard:FindFirstChild("ItemImage")
    if img then
        img.Image = itemData.image
    end

    -- Set rarity text
    local rarity = itemCard:FindFirstChild("RarityLabel")
    if rarity then
        rarity.Text = itemData.rarity
        rarity.TextColor3 = rarityColors[itemData.rarity] or Color3.new(1, 1, 1)
    end

    -- Set percentage
    local percent = itemCard:FindFirstChild("PercentageLabel")
    if percent then
        percent.Text = getRarityPercentage(itemData.rarity)
    end

    -- Add hover effect
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

-- Function to refresh layout when window resizes
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

-- Optional: Update on window resize
itemListFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshLayout)

-- Make sure ButtonFrame stays on top
buttonFrame.ZIndex = 2

print("Responsive grid created with", #ItemsData, "items")
