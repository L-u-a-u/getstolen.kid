-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoiceChatToggleGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Create Container Frame
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, 65, 0, 65)
container.Position = UDim2.new(0.9, -30, 0.7, -30)
container.BackgroundTransparency = 1
container.Parent = screenGui

-- Create the Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Text = "🎤"
toggleButton.Size = UDim2.new(1, -5, 1, -5)
toggleButton.Position = UDim2.new(0, 2.5, 0, 2.5)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleButton.BackgroundTransparency = 0.1
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 28
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = container

-- Add corner radius
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = toggleButton

-- Create keyboard hint label
local keyHint = Instance.new("TextLabel")
keyHint.Name = "KeyHint"
keyHint.Text = "[V]"
keyHint.Size = UDim2.new(0, 30, 0, 20)
keyHint.Position = UDim2.new(0.5, -15, 1, 5)
keyHint.BackgroundTransparency = 1
keyHint.Font = Enum.Font.GothamBold
keyHint.TextSize = 14
keyHint.TextColor3 = Color3.fromRGB(255, 255, 255)
keyHint.Parent = container

-- Only show the GUI for mobile users
if not UserInputService.TouchEnabled then
    screenGui.Enabled = false
end

-- Dragging functionality
local isDragging = false
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local containerSize = container.AbsoluteSize
    
    position = UDim2.new(
        position.X.Scale,
        math.clamp(position.X.Offset, 0, viewportSize.X - containerSize.X),
        position.Y.Scale,
        math.clamp(position.Y.Offset, 0, viewportSize.Y - containerSize.Y)
    )
    
    container.Position = position
end

-- Touch and mouse input handling
container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = container.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

-- Simple hover effect
toggleButton.MouseEnter:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.3), {
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1)
    }):Play()
end)

toggleButton.MouseLeave:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.3), {
        Size = UDim2.new(1, -5, 1, -5),
        Position = UDim2.new(0, 2.5, 0, 2.5)
    }):Play()
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and
       (input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- Voice chat logic
local isRunning = false
local loopTask

local function startVoiceChatLoop()
    isRunning = true
    TweenService:Create(toggleButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    }):Play()
    
    loopTask = coroutine.create(function()
        while isRunning do
            game:GetService("VoiceChatService"):joinVoice()
            wait(3)
        end
    end)
    coroutine.resume(loopTask)
end

local function stopVoiceChatLoop()
    isRunning = false
    TweenService:Create(toggleButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    }):Play()
end

local function toggleVoiceChat()
    if isRunning then
        stopVoiceChatLoop()
    else
        startVoiceChatLoop()
    end
end

-- Connect button click
toggleButton.MouseButton1Click:Connect(toggleVoiceChat)

-- Connect keyboard input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.V then
        toggleVoiceChat()
    end
end)

-- Mobile detection to show/hide keyboard hint
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    keyHint.Visible = false
end
