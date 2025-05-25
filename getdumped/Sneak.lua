local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Create a large second baseplate
local secondBaseplatePosition = Vector3.new(108.033035, -6, -24.9428463)
local secondBaseplate = Instance.new("Part")
secondBaseplate.Size = Vector3.new(1024, 1, 1024)
secondBaseplate.Position = secondBaseplatePosition
secondBaseplate.Anchored = true
secondBaseplate.Name = "SecondBaseplate"
secondBaseplate.BrickColor = BrickColor.new("Medium green")
secondBaseplate.Material = Enum.Material.Grass
secondBaseplate.CanCollide = true
secondBaseplate.Transparency = 1
secondBaseplate.Parent = game.Workspace

-- Smooth surface for the baseplate
secondBaseplate.TopSurface = Enum.SurfaceType.Smooth
secondBaseplate.BottomSurface = Enum.SurfaceType.Smooth

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BaseplateControlGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create a minimal frame for GUI elements
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 100, 0, 100)
frame.Position = UDim2.new(0.9, -50, 0.1, 0)
frame.BackgroundTransparency = 0.2
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Add a UI corner for rounded edges
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Add drop shadow effect
local dropShadow = Instance.new("Frame")
dropShadow.Size = UDim2.new(1, 10, 1, 10)
dropShadow.Position = UDim2.new(0, -5, 0, -5)
dropShadow.BackgroundTransparency = 0.6
dropShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dropShadow.BorderSizePixel = 0
dropShadow.ZIndex = -1
dropShadow.Parent = frame

local dropShadowCorner = Instance.new("UICorner")
dropShadowCorner.CornerRadius = UDim.new(0, 14)
dropShadowCorner.Parent = dropShadow

-- Enable frame drag functionality
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, mousePos, framePos

local function updateInput(input)
    local delta = input.Position - mousePos
    frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateInput(input)
    end
end)

-- Add a close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -25, 0, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(220, 75, 75) -- Red color
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = frame

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(0, 8)
closeButtonCorner.Parent = closeButton

-- Add hover effect to close button
local closeButtonHover = Instance.new("UIStroke")
closeButtonHover.Color = Color3.fromRGB(255, 255, 255)
closeButtonHover.Transparency = 1
closeButtonHover.Thickness = 2
closeButtonHover.Parent = closeButton

closeButton.MouseEnter:Connect(function()
    closeButtonHover.Transparency = 0
    closeButton.BackgroundColor3 = Color3.fromRGB(230, 85, 85) -- Slightly lighter when hovering
end)

closeButton.MouseLeave:Connect(function()
    closeButtonHover.Transparency = 1
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 75, 75) -- Back to original color
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- FIXED BUTTON LAYOUT - Top button should tween down, Bottom button should tween up
local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0, 50, 0, 35)
downButton.Position = UDim2.new(0.5, -25, 0, 10) -- Top position
downButton.Text = "↑"
downButton.BackgroundColor3 = Color3.fromRGB(220, 75, 75) -- Red color
downButton.TextSize = 20
downButton.Font = Enum.Font.GothamBold
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Parent = frame

local downButtonCorner = Instance.new("UICorner")
downButtonCorner.CornerRadius = UDim.new(0, 8)
downButtonCorner.Parent = downButton

-- Add hover effect to downButton
local downButtonHover = Instance.new("UIStroke")
downButtonHover.Color = Color3.fromRGB(255, 255, 255)
downButtonHover.Transparency = 1
downButtonHover.Thickness = 2
downButtonHover.Parent = downButton

downButton.MouseEnter:Connect(function()
    downButtonHover.Transparency = 0
    downButton.BackgroundColor3 = Color3.fromRGB(230, 85, 85) -- Slightly lighter when hovering
end)

downButton.MouseLeave:Connect(function()
    downButtonHover.Transparency = 1
    downButton.BackgroundColor3 = Color3.fromRGB(220, 75, 75) -- Back to original color
end)

local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0, 50, 0, 35)
upButton.Position = UDim2.new(0.5, -25, 0, 55) -- Bottom position
upButton.Text = "↓"
upButton.BackgroundColor3 = Color3.fromRGB(65, 125, 225) -- Blue color
upButton.TextSize = 20
upButton.Font = Enum.Font.GothamBold
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Parent = frame

local upButtonCorner = Instance.new("UICorner")
upButtonCorner.CornerRadius = UDim.new(0, 8)
upButtonCorner.Parent = upButton

-- Add hover effect to upButton
local upButtonHover = Instance.new("UIStroke")
upButtonHover.Color = Color3.fromRGB(255, 255, 255)
upButtonHover.Transparency = 1
upButtonHover.Thickness = 2
upButtonHover.Parent = upButton

upButton.MouseEnter:Connect(function()
    upButtonHover.Transparency = 0
    upButton.BackgroundColor3 = Color3.fromRGB(75, 135, 235) -- Slightly lighter when hovering
end)

upButton.MouseLeave:Connect(function()
    upButtonHover.Transparency = 1
    upButton.BackgroundColor3 = Color3.fromRGB(65, 125, 225) -- Back to original color
end)

-- Variables to control tweening
local isTweening = false
local tweenDuration = 1 -- 1 second for the tween
local noclipConnection = nil

-- Function to calculate the height needed to reach the baseplate
local function getHeightToBaseplate()
    -- Get the Y position of the top of the baseplate
    local baseplateSurfaceY = secondBaseplate.Position.Y + (secondBaseplate.Size.Y / 2)
    
    -- Calculate how far the player's feet should be above the baseplate (slightly above to avoid clipping)
    local feetOffset = 3 -- Offset from the player's HumanoidRootPart to the feet + a small gap
    
    -- Return the target Y position for the player's HumanoidRootPart
    return baseplateSurfaceY + feetOffset
end

-- Enable permanent noclip
local function enablePermanentNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

-- Enable noclip immediately when script runs
enablePermanentNoclip()

-- Function to tween the player up to the baseplate
local function tweenPlayerToBaseplate()
    if isTweening then return end
    
    isTweening = true
    
    -- Save original orientation
    local originalCFrame = humanoidRootPart.CFrame
    local originalLookVector = originalCFrame.LookVector
    
    -- Set PlatformStand to true to prevent jumping during tween
    humanoid.PlatformStand = true
    
    -- Keep X and Z positions the same, but change Y to the calculated baseplate height
    local targetPosition = Vector3.new(
        humanoidRootPart.Position.X,
        getHeightToBaseplate(),
        humanoidRootPart.Position.Z
    )
    
    -- Create a CFrame that preserves the original facing direction
    local targetCFrame = CFrame.new(targetPosition) * CFrame.lookAt(targetPosition, targetPosition + originalLookVector)
    
    -- Create a BodyPosition to handle the movement
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(100000, 100000, 100000) -- Strong enough to move the player
    bodyPosition.Position = targetPosition
    bodyPosition.P = 10000 -- Makes movement more immediate
    bodyPosition.D = 1000 -- Dampening
    bodyPosition.Parent = humanoidRootPart
    
    -- Create a BodyGyro to maintain orientation
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.CFrame = targetCFrame
    bodyGyro.P = 10000
    bodyGyro.D = 1000
    bodyGyro.Parent = humanoidRootPart
    
    -- Remove the BodyPosition and BodyGyro after tweening is complete
    game:GetService("Debris"):AddItem(bodyPosition, tweenDuration + 0.1)
    game:GetService("Debris"):AddItem(bodyGyro, tweenDuration + 0.1)
    
    -- Set a timer to mark tweening as complete
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if (humanoidRootPart.Position - targetPosition).Magnitude < 1 then
            -- Reset state
            isTweening = false
            humanoid.PlatformStand = false
            
            -- Clean up
            if bodyPosition and bodyPosition.Parent then
                bodyPosition:Destroy()
            end
            
            if bodyGyro and bodyGyro.Parent then
                bodyGyro:Destroy()
            end
            
            -- Disconnect this event
            if connection then
                connection:Disconnect()
            end
        end
    end)
end

-- Function to tween the player down to the original ground
local function tweenPlayerToOriginalGround()
    if isTweening then return end
    
    isTweening = true
    
    -- Save original orientation
    local originalCFrame = humanoidRootPart.CFrame
    local originalLookVector = originalCFrame.LookVector
    
    -- Set PlatformStand to true to prevent jumping during tween
    humanoid.PlatformStand = true
    
    -- Calculate the ground level (assuming 0 is the ground, adjust if needed)
    local groundLevel = 0
    local humanoidHeight = 3 -- Approximate height of the humanoid from feet to HumanoidRootPart
    
    -- Target position - same X and Z, but Y at ground level plus humanoid height
    local targetPosition = Vector3.new(
        humanoidRootPart.Position.X,
        groundLevel + humanoidHeight,
        humanoidRootPart.Position.Z
    )
    
    -- Create a CFrame that preserves the original facing direction
    local targetCFrame = CFrame.new(targetPosition) * CFrame.lookAt(targetPosition, targetPosition + originalLookVector)
    
    -- Create a BodyPosition to handle the movement
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyPosition.Position = targetPosition
    bodyPosition.P = 10000
    bodyPosition.D = 1000
    bodyPosition.Parent = humanoidRootPart
    
    -- Create a BodyGyro to maintain orientation
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.CFrame = targetCFrame
    bodyGyro.P = 10000
    bodyGyro.D = 1000
    bodyGyro.Parent = humanoidRootPart
    
    -- Remove the BodyPosition and BodyGyro after tweening is complete
    game:GetService("Debris"):AddItem(bodyPosition, tweenDuration + 0.1)
    game:GetService("Debris"):AddItem(bodyGyro, tweenDuration + 0.1)
    
    -- Set a timer to mark tweening as complete
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if (humanoidRootPart.Position - targetPosition).Magnitude < 1 then
            -- Reset state
            isTweening = false
            humanoid.PlatformStand = false
            
            -- Clean up
            if bodyPosition and bodyPosition.Parent then
                bodyPosition:Destroy()
            end
            
            if bodyGyro and bodyGyro.Parent then
                bodyGyro:Destroy()
            end
            
            -- Disconnect this event
            if connection then
                connection:Disconnect()
            end
        end
    end)
end

-- IMPORTANT: Connect buttons to the CORRECT functions
-- Up arrow button (the bottom button) connects to tweenPlayerToBaseplate (move UP)
upButton.MouseButton1Click:Connect(tweenPlayerToBaseplate)

-- Down arrow button (the top button) connects to tweenPlayerToOriginalGround (move DOWN)
downButton.MouseButton1Click:Connect(tweenPlayerToOriginalGround)

-- Handle player respawn by reconnecting to the new character
player.CharacterAdded:Connect(function(newCharacter)
    -- Cancel any ongoing tween
    if isTweening then
        isTweening = false
    end
    
    -- Update character references
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    -- Re-enable noclip for the new character
    enablePermanentNoclip()
end)
