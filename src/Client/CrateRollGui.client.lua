local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")

local crateRollGui = playerGui:WaitForChild("CrateRollGui")
local mainFrame = crateRollGui:WaitForChild("MainFrame")
local buttonFrame = mainFrame:WaitForChild("ButtonFrame")

local singleRollButton = buttonFrame:WaitForChild("RollButton")
local tripleRollButton = buttonFrame:WaitForChild("Roll3Button")
local autoRollButton = buttonFrame:WaitForChild("AutoRollButton")

-- 🔁 Get crateId dynamically when needed
local function getCrateId()
	local adorneePart = crateRollGui.Adornee
	if not adorneePart then
		warn("⚠️ Adornee is nil.")
		return nil
	end

	local crateModel = adorneePart:FindFirstAncestorWhichIsA("Model")
	if not crateModel then
		warn("⚠️ No crate model found from adornee.")
		return nil
	end

	local crateId = crateModel:GetAttribute("CrateId")
	if not crateId then
		warn("⚠️ CrateId attribute missing from model.")
		return nil
	end

	return crateId
end

-- 🧾 Show popup
local function showRollResults(items)
	if typeof(items) ~= "table"
	then items = { items }
end

	local popupGui = Instance.new("ScreenGui")
	popupGui.Name = "RollResultsPopup"
	popupGui.ResetOnSpawn = false
	popupGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.4, 0, 0.4, 0)
	frame.Position = UDim2.new(0.3, 0, 0.3, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.Parent = popupGui

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "🎉 You received:"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Parent = frame

	for i, item in ipairs(items) do
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -20, 0, 30)
		label.Position = UDim2.new(0, 10, 0, 50 + (i - 1) * 35)
		label.BackgroundTransparency = 1
		label.Text = item.name or "Unknown Item"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.Gotham
		label.TextScaled = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = frame
	end

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0.3, 0, 0.15, 0)
	close.Position = UDim2.new(0.35, 0, 0.8, 0)
	close.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
	close.Text = "Close"
	close.TextColor3 = Color3.new(1, 1, 1)
	close.Font = Enum.Font.GothamBold
	close.TextScaled = true
	close.Parent = frame
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

	close.MouseButton1Click:Connect(function()
		popupGui:Destroy()
	end)
end

-- 🔘 Button hooks
singleRollButton.MouseButton1Click:Connect(function()
	local crateId = getCrateId()
	if not crateId then return end

	local success, result = pcall(function()
		return RemoteFunctions.RollSingle:InvokeServer(crateId)
	end)

	if success and result then
		showRollResults(result)
	else
		warn("❌ Single roll failed:", result)
	end
end)

tripleRollButton.MouseButton1Click:Connect(function()
	local crateId = getCrateId()
	if not crateId then return end

	local success, result = pcall(function()
		return RemoteFunctions.RollTriple:InvokeServer(crateId)
	end)

	if success and result then
		showRollResults(result)
	else
		warn("❌ Triple roll failed:", result)
	end
end)

autoRollButton.MouseButton1Click:Connect(function()
	local crateId = getCrateId()
	if not crateId then return end

	local duration = 10
	local success, result = pcall(function()
		return RemoteFunctions.RollAuto:InvokeServer(crateId, duration)
	end)

	if success and result then
		showRollResults(result)
	else
		warn("❌ Auto roll failed:", result)
	end
end)
