local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")  -- (if you need tweens later; not used here)
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer

-------------------------------------------------
-- Core Notification: Display Trip Action Instructions
-------------------------------------------------
StarterGui:SetCore("SendNotification", {
    Title = "Trip Action Instructions",
    Text = "Press T on PC or tap the button on mobile to trip!",
    Duration = 5
})

-------------------------------------------------
-- Trip Function: Changes state and sets velocity to simulate a trip.
-------------------------------------------------
local function trip()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local hum = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if hum and root then
        hum:ChangeState(0)
        root.Velocity = root.CFrame.LookVector * 35
    end
end

-------------------------------------------------
-- PC Users: Bind the T key to trigger the trip.
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        trip()
    end
end)

-------------------------------------------------
-- Mobile Users: Create a GUI button if touch is enabled.
-------------------------------------------------
if UserInputService.TouchEnabled then
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Create a ScreenGui to hold the button.
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TripGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    -- Create the Trip button.
    local TripButton = Instance.new("TextButton")
    TripButton.Name = "TripButton"
    TripButton.Size = UDim2.new(0, 60, 0, 60)
    -- The position is adjusted to 0.78 on the X-axis to move it slightly to the right.
    TripButton.Position = UDim2.new(0.78, 0, 0.7, 0)
    TripButton.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
    TripButton.BackgroundTransparency = 0.3
    TripButton.Text = "🚀"
    TripButton.TextSize = 28
    TripButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TripButton.Parent = ScreenGui

    -- Make the button round.
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = TripButton

    -- Bind the trip action to the button click.
    TripButton.MouseButton1Click:Connect(trip)
end
