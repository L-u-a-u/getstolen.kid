local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Create the main invisible baseplate with infinite size
local function createBaseplate()
    local baseplate = Instance.new("Part")
    baseplate.Name = "InvisibleBaseplate"
    baseplate.Size = Vector3.new(math.huge, 1, math.huge)
    baseplate.Position = Vector3.new(0, 0, 0)
    baseplate.Transparency = 1
    baseplate.Anchored = true
    baseplate.CanCollide = true
    baseplate.Material = Enum.Material.Neon
    baseplate.Color = Color3.fromRGB(70, 200, 255)
    baseplate.Parent = workspace
    return baseplate
end

local baseplate = createBaseplate()

-- Create a ScreenGui with protection settings
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AirwalkGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

-- Enhanced button creation function with hover effects
local function createButton(parent, text, position, size, shape, initialColor, textColor)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = initialColor
    button.TextColor3 = textColor
    button.Font = Enum.Font.GothamBlack
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = parent

    -- Add gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, initialColor),
        ColorSequenceKeypoint.new(1, initialColor:Lerp(Color3.new(1, 1, 1), 0.2))
    })
    gradient.Parent = button

    -- Add glow effect
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.2, 0, 1.2, 0)
    glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://131658112"
    glow.ImageColor3 = initialColor
    glow.ImageTransparency = 0.8
    glow.ZIndex = button.ZIndex - 1
    glow.Parent = button

    -- Rounded corners or circular shape
    local corner = Instance.new("UICorner")
    if shape == "circle" then
        corner.CornerRadius = UDim.new(1, 0)
    else
        corner.CornerRadius = UDim.new(0, 12)
    end
    corner.Parent = button

    -- Hover effects
    local function onHover()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = initialColor:Lerp(Color3.new(1, 1, 1), 0.2)
        }):Play()
        game:GetService("TweenService"):Create(glow, TweenInfo.new(0.3), {
            ImageTransparency = 0.6
        }):Play()
    end

    local function onUnhover()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = initialColor
        }):Play()
        game:GetService("TweenService"):Create(glow, TweenInfo.new(0.3), {
            ImageTransparency = 0.8
        }):Play()
    end

    button.MouseEnter:Connect(onHover)
    button.MouseLeave:Connect(onUnhover)

    return button
end

-- Create container for buttons
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0, 250, 0, 50)
buttonContainer.Position = UDim2.new(1, -260, 1, -60)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = screenGui

-- Create buttons with new layout
local toggleButton = createButton(buttonContainer, "On", UDim2.new(0, 0, 0, 0), UDim2.new(0, 40, 0, 40), "circle", Color3.fromRGB(0, 255, 0), Color3.fromRGB(255, 255, 255))
local upButton = createButton(buttonContainer, "▲", UDim2.new(0, 50, 0, 0), UDim2.new(0, 40, 0, 40), "circle", Color3.fromRGB(100, 100, 100), Color3.fromRGB(255, 255, 255))
local downButton = createButton(buttonContainer, "▼", UDim2.new(0, 100, 0, 0), UDim2.new(0, 40, 0, 40), "circle", Color3.fromRGB(100, 100, 100), Color3.fromRGB(255, 255, 255))
local resetButton = createButton(buttonContainer, "R", UDim2.new(0, 150, 0, 0), UDim2.new(0, 40, 0, 40), "circle", Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 255, 255))
local visibilityButton = createButton(buttonContainer, "👁", UDim2.new(0, 200, 0, 0), UDim2.new(0, 40, 0, 40), "circle", Color3.fromRGB(147, 112, 219), Color3.fromRGB(255, 255, 255))

local airwalking = true
local isVisible = false
local isMovingUp = false
local isMovingDown = false

-- Function to reset baseplate position
local function resetBaseplate()
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            baseplate.Position = Vector3.new(
                humanoidRootPart.Position.X,
                baseplate.Position.Y,
                humanoidRootPart.Position.Z
            )
        end
    end
end

-- Function to save player from falling
local function saveFallingPlayer()
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            baseplate.Position = Vector3.new(
                humanoidRootPart.Position.X,
                humanoidRootPart.Position.Y - 5,
                humanoidRootPart.Position.Z
            )
        end
    end
end

-- Function to toggle visibility with enhanced visuals
local function toggleVisibility()
    isVisible = not isVisible
    baseplate.Transparency = isVisible and 0.3 or 1
    
    if isVisible then
        baseplate.Material = Enum.Material.Neon
    else
        baseplate.Material = Enum.Material.SmoothPlastic
    end
end

-- Function to toggle airwalk state
local function toggleAirwalk()
    airwalking = not airwalking
    if airwalking then
        toggleButton.Text = "On"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        if not baseplate:IsDescendantOf(workspace) then
            baseplate = createBaseplate()
        end
    else
        toggleButton.Text = "Off"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        baseplate:Destroy()
    end
end

-- Continuous movement function
RunService.Heartbeat:Connect(function()
    if isMovingUp then
        baseplate.Position = baseplate.Position + Vector3.new(0, 0.5, 0)
    elseif isMovingDown then
        baseplate.Position = baseplate.Position - Vector3.new(0, 0.5, 0)
    end
end)

-- Connect button events
toggleButton.MouseButton1Click:Connect(toggleAirwalk)
resetButton.MouseButton1Click:Connect(saveFallingPlayer)
visibilityButton.MouseButton1Click:Connect(toggleVisibility)

-- Handle continuous movement
upButton.MouseButton1Down:Connect(function() isMovingUp = true end)
upButton.MouseButton1Up:Connect(function() isMovingUp = false end)
upButton.MouseLeave:Connect(function() isMovingUp = false end)

downButton.MouseButton1Down:Connect(function() isMovingDown = true end)
downButton.MouseButton1Up:Connect(function() isMovingDown = false end)
downButton.MouseLeave:Connect(function() isMovingDown = false end)

-- Smooth platform following
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if character and airwalking then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            baseplate.Position = Vector3.new(
                humanoidRootPart.Position.X,
                baseplate.Position.Y,
                humanoidRootPart.Position.Z
            )
        end
    end
end)

-- Initialize
resetBaseplate()

-- Connect to character spawn
player.CharacterAdded:Connect(function(character)
    wait(0.5)
    resetBaseplate()
end)

-- Protection against GUI removal
screenGui.DescendantRemoving:Connect(function(descendant)
    if descendant == buttonContainer then
        buttonContainer.Parent = screenGui
    end
end)
