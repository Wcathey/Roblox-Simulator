local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RollRequest = ReplicatedStorage:WaitForChild("RollRequest")
local RollResult = ReplicatedStorage:WaitForChild("RollResult")
local AutoRollCancel = ReplicatedStorage:FindFirstChild("AutoRollCancel")

local buttons = script.Parent:WaitForChild("MainFrame"):WaitForChild("ButtonFrame")

-- Roll x1
buttons.Roll1Button.MouseButton1Click:Connect(function()
    RollRequest:FireServer("single")
end)

-- Roll x3
buttons.Roll3Button.MouseButton1Click:Connect(function()
    RollRequest:FireServer("x3")
end)

-- Auto Roll (toggle)
local isAutoRolling = false
buttons.AutoRollButton.MouseButton1Click:Connect(function()
    isAutoRolling = not isAutoRolling
    buttons.AutoRollButton.Text = isAutoRolling and "Stop Auto" or "Auto Roll"

    if isAutoRolling then
        RollRequest:FireServer("auto")
    else
        if AutoRollCancel then
            AutoRollCancel:FireServer()
        end
    end
end)

-- Receive roll results from server
RollResult.OnClientEvent:Connect(function(item)
    print("🎁 You got:", item.name)
    -- TODO: Show crate animation, popup, effects here
end)
