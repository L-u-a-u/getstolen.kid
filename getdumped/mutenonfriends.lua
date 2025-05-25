-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MuteToggleGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create the main button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.9, -25, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- off state: red
ToggleButton.BackgroundTransparency = 0.5  -- increased transparency
ToggleButton.Text = "🎤"  -- microphone emoji
ToggleButton.TextSize = 25
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui

-- Make it circular
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleButton

-- Get TweenService for animations
local TweenService = game:GetService("TweenService")

local exceptions = {
    "Xeni_He7",
    "YournothimbuddyXD",
    "BloxiAstra"
}

local isMuted = false

local function isException(playerName)
    for _, name in pairs(exceptions) do
        if name == playerName then
            return true
        end
    end
    return false
end

-- Function to update mute status
local function updateMute()
    if isMuted then
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            local audio = v:FindFirstChild("AudioDeviceInput")
            if audio then
                if not v:IsFriendsWith(game.Players.LocalPlayer.UserId) and not isException(v.Name) and v.Name ~= game.Players.LocalPlayer.Name then
                    audio.Muted = true
                end
            end
        end
    else
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            local audio = v:FindFirstChild("AudioDeviceInput")
            if audio then
                audio.Muted = false
            end
        end
    end
end

-- Drag functionality for all devices
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Toggle function with tween animation
ToggleButton.MouseButton1Click:Connect(function()
    isMuted = not isMuted

    -- Tween animation: spin the button 360°
    local tweenInfo = TweenInfo.new(
        0.5, -- duration
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,   -- no repeats
        false,
        0
    )
    local goal = {Rotation = ToggleButton.Rotation + 360}
    local tween = TweenService:Create(ToggleButton, tweenInfo, goal)
    tween:Play()

    -- Update visual state: green if active, red if not
    if isMuted then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end

    updateMute()
end)

-- Update mute when new players join (only if mute is active)
game:GetService("Players").PlayerAdded:Connect(function(player)
    wait(1) -- Wait for AudioDeviceInput to load
    if isMuted then
        local audio = player:FindFirstChild("AudioDeviceInput")
        if audio then
            if not player:IsFriendsWith(game.Players.LocalPlayer.UserId) and not isException(player.Name) and player.Name ~= game.Players.LocalPlayer.Name then
                audio.Muted = true
            end
        end
    end
end)
