local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Function to show a CoreGui notification
local function showNotification()
    StarterGui:SetCore("SendNotification", {
        Title = "Teleport Instructions",
        Text = "Press 'F' to teleport to your mouse position.",
        Duration = 5 -- Notification duration in seconds
    })
end

-- Function to safely get the player's character
local function safeGetCharacter()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    return character, humanoidRootPart
end

-- Function to teleport to the mouse position
local function teleportToMouse()
    local character, humanoidRootPart = safeGetCharacter()
    if humanoidRootPart then
        local mousePosition = Mouse.Hit.Position
        humanoidRootPart.CFrame = CFrame.new(mousePosition + Vector3.new(0, 3, 0))
    end
end

-- Input listener for teleportation
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        teleportToMouse()
    end
end)

-- Show the notification when the script runs
showNotification()
