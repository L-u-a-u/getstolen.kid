--[[ 
    Professional FOV Changer GUI Script for Roblox
    ------------------------------------------------
    This script creates a polished, draggable GUI with:
      • A stylish header with a title.
      • A minimize button to collapse/expand the content area.
      • A close button to destroy the GUI.
      • A slider to adjust the Camera's Field of View (FOV) up to 400.
    
    Place this LocalScript in StarterGui or inside a ScreenGui.
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProfessionalFOVChangerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create the main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Rounded corners for main frame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Subtle border using UIStroke
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 60)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Create header (drag area)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = mainFrame

-- Rounded corners for header
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

-- UIGradient for a sleek header look
local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
headerGradient.Parent = header

-- Title label in the header
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FOV Changer"
title.Font = Enum.Font.GothamSemibold
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = header

-- Close button in the header
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BorderSizePixel = 0
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

-- Minimize button in the header
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -60, 0, 2)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 5)
minimizeCorner.Parent = minimizeButton

-- Create content frame for the slider and FOV label (collapsible)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- FOV display label
local fovLabel = Instance.new("TextLabel")
fovLabel.Name = "FOVLabel"
fovLabel.Size = UDim2.new(1, -20, 0, 25)
fovLabel.Position = UDim2.new(0, 10, 0, 10)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: " .. math.floor(camera.FieldOfView)
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 16
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.Parent = contentFrame

-- Slider track frame
local sliderFrame = Instance.new("Frame")
sliderFrame.Name = "SliderFrame"
sliderFrame.Size = UDim2.new(0.9, 0, 0, 20)
sliderFrame.Position = UDim2.new(0.05, 0, 0, 45)
sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = contentFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 10)
sliderCorner.Parent = sliderFrame

-- Slider knob
local sliderKnob = Instance.new("Frame")
sliderKnob.Name = "SliderKnob"
sliderKnob.Size = UDim2.new(0, 14, 1, 0)
sliderKnob.Position = UDim2.new(0, 0, 0, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderFrame

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(0, 10)
knobCorner.Parent = sliderKnob

-- Slider settings: minimum remains at 70, maximum is now set to 400.
local minFOV = 70
local maxFOV = 400

-- Update FOV based on the knob's position relative to the slider track.
local function updateFOV(inputPositionX)
    local sliderAbsolutePos = sliderFrame.AbsolutePosition.X
    local sliderWidth = sliderFrame.AbsoluteSize.X
    local relativePos = math.clamp((inputPositionX - sliderAbsolutePos) / sliderWidth, 0, 1)
    local newFOV = minFOV + (maxFOV - minFOV) * relativePos
    camera.FieldOfView = newFOV
    fovLabel.Text = "FOV: " .. math.floor(newFOV)
    sliderKnob.Position = UDim2.new(relativePos, -sliderKnob.Size.X.Offset/2, 0, 0)
end

-- Slider input events
sliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        updateFOV(input.Position.X)
    end
end)

sliderFrame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
       and input.UserInputState == Enum.UserInputState.Change then
        updateFOV(input.Position.X)
    end
end)

-- Draggable functionality via the header only
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Minimize functionality: toggles the content frame's visibility
local isMinimized = false
local originalSize = mainFrame.Size

minimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.25), {Size = originalSize}):Play()
        contentFrame.Visible = true
        minimizeButton.Text = "-"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.25), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, header.Size.Y.Offset)}):Play()
        contentFrame.Visible = false
        minimizeButton.Text = "+"
    end
    isMinimized = not isMinimized
end)

-- Close functionality: destroys the GUI
closeButton.MouseButton1Click:Connect(function()
    mainFrame:Destroy()
end)
