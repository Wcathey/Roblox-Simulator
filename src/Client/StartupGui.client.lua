-- src/Client/StartupGui.client.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Real check for new player via RemoteFunction
local isNewPlayer = false
local success, result = pcall(function()
	local remote = ReplicatedStorage:WaitForChild("NewPlayerCheck")
	return remote:InvokeServer()
end)
if success and result then
	isNewPlayer = true
end

-- Require the cars dataset (make sure this module exists at ReplicatedStorage.Shared.CarsData)
local CarsData = require(ReplicatedStorage.Shared.Cars.CarsData)
local StarterCarSelectedEvent = ReplicatedStorage:WaitForChild("StarterCarSelected")

-- === CREATE LOADING SCREEN ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StartupGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BackgroundTransparency = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🚗 Street Race Simulator 🚦"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 56
titleLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.Position = UDim2.new(0, 0, 0.3, 0)
titleLabel.TextScaled = true
titleLabel.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Text = "Loading..."
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 28
subtitle.TextColor3 = Color3.fromRGB(240, 240, 240)
subtitle.BackgroundTransparency = 1
subtitle.Size = UDim2.new(1, 0, 0.1, 0)
subtitle.Position = UDim2.new(0, 0, 0.5, 0)
subtitle.TextScaled = true
subtitle.Parent = mainFrame

function createCarSelectionPopup()
	local carGui = Instance.new("ScreenGui")
	carGui.Name = "CarSelectionPopup"
	carGui.Parent = playerGui
	carGui.ResetOnSpawn = false
	carGui.IgnoreGuiInset = false

	local popup = Instance.new("Frame")
	popup.Size = UDim2.new(0.6, 0, 0.6, 0)
	popup.Position = UDim2.new(0.2, 0, 0.2, 0)
	popup.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	popup.BorderSizePixel = 0
	popup.Parent = carGui

	local popupCorner = Instance.new("UICorner")
	popupCorner.CornerRadius = UDim.new(0, 15)
	popupCorner.Parent = popup

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "Select Your Starter Car"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Parent = popup

	local buttonWidth = 0.25
	local buttonHeight = 0.4
	local spacing = 0.05

	for i, car in ipairs(CarsData.StarterCars) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(buttonWidth, 0, buttonHeight, 0)
		button.Position = UDim2.new(spacing + (buttonWidth + spacing) * (i - 1), 0, 0.25, 0)
		button.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Font = Enum.Font.GothamBold
		button.TextScaled = true
		button.Text = car.Name
		button.Parent = popup

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button

		button.MouseButton1Click:Connect(function()
			print("Selected car:", car.Name)
			StarterCarSelectedEvent:FireServer(car.Id) -- send car Id to server
			carGui:Destroy()
		end)
	end
end

-- === WELCOME POPUP GUI ===
local function createWelcomePopup()
	local welcomeGui = Instance.new("ScreenGui")
	welcomeGui.Name = "WelcomePopup"
	welcomeGui.Parent = playerGui
	welcomeGui.ResetOnSpawn = false
	welcomeGui.IgnoreGuiInset = false

	local popup = Instance.new("Frame")
	popup.Size = UDim2.new(0.5, 0, 0.5, 0)
	popup.Position = UDim2.new(0.25, 0, 0.25, 0)
	popup.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	popup.BorderSizePixel = 0
	popup.Parent = welcomeGui

	local popupCorner = Instance.new("UICorner")
	popupCorner.CornerRadius = UDim.new(0, 12)
	popupCorner.Parent = popup

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0.2, 0)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "🏁 Welcome to Street Race Simulator"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Parent = popup

	local body = Instance.new("TextLabel")
	body.Size = UDim2.new(1, -20, 0.6, -60)
	body.Position = UDim2.new(0, 10, 0.25, 0)
	body.BackgroundTransparency = 1
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.Text = "Race to earn coins. Upgrade your car. Dominate the streets!"
	body.TextColor3 = Color3.fromRGB(200, 200, 200)
	body.Font = Enum.Font.Gotham
	body.TextScaled = true
	body.Parent = popup

	local continue = Instance.new("TextButton")
	continue.Size = UDim2.new(0.5, 0, 0.15, 0)
	continue.Position = UDim2.new(0.25, 0, 0.8, 0)
	continue.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
	continue.Text = "Continue"
	continue.TextColor3 = Color3.new(1, 1, 1)
	continue.Font = Enum.Font.GothamBold
	continue.TextScaled = true
	continue.Parent = popup

	local continueCorner = Instance.new("UICorner")
	continueCorner.CornerRadius = UDim.new(0, 8)
	continueCorner.Parent = continue

	continue.MouseButton1Click:Connect(function()
		welcomeGui:Destroy()
		createCarSelectionPopup()
	end)

	-- Allow clicking outside to close
	popup.Active = true
	popup.Draggable = true
	welcomeGui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not popup:IsDescendantOf(input.Target) then
			welcomeGui:Destroy()
		end
	end)
end

-- === STARTER CAR SELECTION POPUP GUI ===


-- === HELP ICON (Always Visible) ===
local function createHelpIcon()
	local helpGui = Instance.new("ScreenGui")
	helpGui.Name = "HelpIcon"
	helpGui.Parent = playerGui
	helpGui.ResetOnSpawn = false

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 120, 0, 40)
	button.Position = UDim2.new(1, -130, 1, -50)
	button.AnchorPoint = Vector2.new(0, 1)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.Text = "❓ Help"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.Parent = helpGui

	local helpCorner = Instance.new("UICorner")
	helpCorner.CornerRadius = UDim.new(0, 10)
	helpCorner.Parent = button

	button.MouseButton1Click:Connect(createWelcomePopup)
end

-- === Fade out loading screen ===
task.delay(3, function()
	local tween = TweenService:Create(mainFrame, TweenInfo.new(1.5), {
		BackgroundTransparency = 1
	})
	tween:Play()

	for _, child in ipairs(mainFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			TweenService:Create(child, TweenInfo.new(1.5), {
				TextTransparency = 1
			}):Play()
		end
	end

	tween.Completed:Connect(function()
		screenGui:Destroy()
		createHelpIcon()
		if isNewPlayer then
			createWelcomePopup()
		end
	end)
end)
