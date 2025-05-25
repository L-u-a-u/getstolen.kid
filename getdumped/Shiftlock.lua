-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local shiftLockEnabled = false
local shiftKeyPressed = false

-- Create CoreGui
local function createShiftLockButton()
    -- Create the CoreGui
    local success, err = pcall(function()
        StarterGui:SetCore("TopbarEnabled", true)
    end)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShiftLockGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Create container for better positioning and effects
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 50, 0, 50)
    container.Position = UDim2.new(0.9, 0, 0.7, 0)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    -- Create the main button
    local shiftLockButton = Instance.new("ImageButton")
    shiftLockButton.Size = UDim2.new(1, 0, 1, 0)
    shiftLockButton.Position = UDim2.new(0, 0, 0, 0)
    shiftLockButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    shiftLockButton.AutoButtonColor = false
    shiftLockButton.BorderSizePixel = 0
    shiftLockButton.BackgroundTransparency = 0.1
    shiftLockButton.Parent = container
    
    -- Create gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    })
    gradient.Rotation = 45
    gradient.Parent = shiftLockButton
    
    -- Create rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = shiftLockButton
    
    -- Create stroke for button outline
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = shiftLockButton
    
    -- Create the lock icon
    local lockIcon = Instance.new("ImageLabel")
    lockIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
    lockIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
    lockIcon.Image = "rbxassetid://6031233835"
    lockIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    lockIcon.BackgroundTransparency = 1
    lockIcon.Parent = shiftLockButton
    
    -- Create inner glow
    local innerGlow = Instance.new("ImageLabel")
    innerGlow.Size = UDim2.new(0.9, 0, 0.9, 0)
    innerGlow.Position = UDim2.new(0.05, 0, 0.05, 0)
    innerGlow.Image = "rbxassetid://4950146078"
    innerGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    innerGlow.ImageTransparency = 0.9
    innerGlow.BackgroundTransparency = 1
    innerGlow.ZIndex = -1
    innerGlow.Parent = shiftLockButton
    
    -- Animation configurations
    local clickAnimationInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local spinAnimationInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Function to toggle shift lock with animations
    local function toggleShiftLock()
        shiftLockEnabled = not shiftLockEnabled
        
        -- Spin animation
        local spinTween = TweenService:Create(lockIcon, spinAnimationInfo, {
            Rotation = lockIcon.Rotation + 360
        })
        spinTween:Play()
        
        -- Button effect animations
        local pressColor = shiftLockEnabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
        local glowTransparency = shiftLockEnabled and 0.7 or 0.9
        
        local colorTween = TweenService:Create(shiftLockButton, clickAnimationInfo, {
            BackgroundColor3 = pressColor
        })
        colorTween:Play()
        
        local glowTween = TweenService:Create(innerGlow, clickAnimationInfo, {
            ImageTransparency = glowTransparency
        })
        glowTween:Play()
        
        -- Scale animation
        local scaleDownTween = TweenService:Create(container, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 45, 0, 45)
        })
        scaleDownTween:Play()
        
        wait(0.1)
        
        local scaleUpTween = TweenService:Create(container, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 50, 0, 50)
        })
        scaleUpTween:Play()
    end
    
    -- Hover effects
    shiftLockButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(shiftLockButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        })
        hoverTween:Play()
        
        local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0.6
        })
        strokeTween:Play()
    end)
    
    shiftLockButton.MouseLeave:Connect(function()
        local unhoverTween = TweenService:Create(shiftLockButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1
        })
        unhoverTween:Play()
        
        local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0.8
        })
        strokeTween:Play()
    end)
    
    -- Character rotation function
    local function rotateCharacterToFaceCamera(humanoidRootPart)
        if shiftLockEnabled and humanoidRootPart then
            local cameraLookVector = camera.CFrame.LookVector
            local newDirection = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit
            local targetPosition = humanoidRootPart.Position + newDirection
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, targetPosition)
        end
    end
    
    -- Update camera and character
    local function updateCameraAndCharacter()
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            rotateCharacterToFaceCamera(humanoidRootPart)
        end
    end
    
    -- Connect button click
    shiftLockButton.MouseButton1Click:Connect(toggleShiftLock)
    
    -- Connect keyboard input for PC users
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift and not shiftKeyPressed then
            shiftKeyPressed = true
            toggleShiftLock()
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift then
            shiftKeyPressed = false
        end
    end)
    
    -- Update every frame
    RunService.RenderStepped:Connect(updateCameraAndCharacter)
    
    -- Clean up on removal
    screenGui.Destroying:Connect(function()
        RunService.RenderStepped:Disconnect()
    end)
end

-- Initial creation
createShiftLockButton()

-- Handle character respawning
local function onCharacterAdded()
    shiftLockEnabled = false
    shiftKeyPressed = false
    wait(1)
    createShiftLockButton()
end

player.CharacterAdded:Connect(onCharacterAdded)
