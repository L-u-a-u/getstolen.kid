local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local targetHead = nil
local targetPlayer = nil

local FOLLOW_DISTANCE = -0.7
local HEIGHT_OFFSET = 0.8
local MOVEMENT_SPEED = 0.8 -- Same as original
local THRUST_SPEED = 0.8 -- Same as original 
local THRUST_DISTANCE = 1.9 -- Same as original

-- Animation timing constants
local THRUST_FORWARD_TIME = 0.1 -- Fast like original
local THRUST_BACKWARD_TIME = 0.1 -- Fast like original
local ANIMATION_SMOOTHNESS = 60 -- Higher value = smoother animation

-- Walking detection thresholds - we'll keep these for reference but won't use them to change behavior
local WALKING_DETECTION_THRESHOLD = 0.3 -- Minimum distance to consider as walking
local POSITION_HISTORY_SIZE = 5 -- Increased for better detection
local CHECK_INTERVAL = 0.1 -- Time between walk checks in seconds

-- Variables for tracking target walking
local targetPositionHistory = {}
local targetIsWalking = false
local lastWalkCheckTime = 0

getgenv().facefuckactive = false

-- Enhanced function to completely disable all animations
local function disableAllAnimations(character)
    if not character then return end
    
    -- Disable main Animate script
    local animate = character:FindFirstChild("Animate")
    if animate then
        animate.Disabled = true
        
        -- Disable all animation tracks
        for _, child in ipairs(animate:GetChildren()) do
            if child:IsA("StringValue") then
                child.Value = ""
            end
        end
    end
    
    -- Get Humanoid and stop all current animations
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- Stop existing animations
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
            track:Destroy()
        end
        
        -- Disable default animations
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        
        -- Force idle animation state
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
    
    -- Disable individual animation controllers
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("LocalScript") and child.Name:match("Controller") then
            child.Disabled = true
        end
    end
    
    -- Set gravity to 0 to prevent falling animation
    workspace.Gravity = 0
end

-- Function to restore animations
local function enableAllAnimations(character)
    if not character then return end
    
    local animate = character:FindFirstChild("Animate")
    if animate then
        animate.Disabled = false
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    -- Re-enable animation controllers
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("LocalScript") and child.Name:match("Controller") then
            child.Disabled = false
        end
    end
    
    workspace.Gravity = 192.2
end

-- Function to check if target is walking by analyzing position history
-- We'll still use this to track walking state, but won't change behavior based on it
local function updateTargetWalkingState(head)
    if #targetPositionHistory < POSITION_HISTORY_SIZE then
        table.insert(targetPositionHistory, head.Position)
        return false
    end
    
    -- Shift history and add new position
    table.remove(targetPositionHistory, 1)
    table.insert(targetPositionHistory, head.Position)
    
    -- Calculate total movement distance over time window
    local movementDistance = 0
    for i = 1, #targetPositionHistory - 1 do
        local segment = (targetPositionHistory[i+1] - targetPositionHistory[i]).Magnitude
        movementDistance = movementDistance + segment
    end
    
    -- Check if movement exceeds threshold
    return movementDistance > WALKING_DETECTION_THRESHOLD
end

-- Function to track player respawn and handle retargeting
local function setupCharacterTracking()
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
        
        if getgenv().facefuckactive then
            disableAllAnimations(newCharacter)
            targetHead = findNearestPlayer()
            if targetHead then
                -- Reset tracking variables when retargeting
                targetPositionHistory = {}
                targetIsWalking = false
                task.spawn(function()
                    faceBang(targetHead)
                end)
            else
                print("No nearby player found!")
            end
        end
    end)
end

-- Function to find the nearest player
local function findNearestPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        return targetPlayer.Character.Head
    end

    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local distance = (HumanoidRootPart.Position - head.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestPlayer = head
                    targetPlayer = player
                end
            end
        end
    end

    if targetPlayer then
        targetPlayer.CharacterAdded:Connect(function(newCharacter)
            if getgenv().facefuckactive then
                local head = newCharacter:WaitForChild("Head")
                targetHead = head
                -- Reset tracking variables when character respawns
                targetPositionHistory = {}
                targetIsWalking = false
                faceBang(head)
            end
        end)
    end

    return nearestPlayer
end

-- Continuous animation prevention
local function setupAnimationPrevention()
    RunService.Heartbeat:Connect(function()
        if getgenv().facefuckactive and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                -- Stop any new animations that might play
                for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
                
                -- Maintain physics state
                humanoid.PlatformStand = true
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end
    end)
end

-- Improved easing functions for smoother animation
local function easeInOutSine(t)
    return -(math.cos(math.pi * t) - 1) / 2
end

local function easeInOutQuad(t)
    return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2)^2 / 2
end

-- Enhanced lerp function with easing
local function smoothLerp(start, target, alpha, easingFunc)
    local easedAlpha = easingFunc(alpha)
    return start:Lerp(target, easedAlpha)
end

-- Enhanced fast teleport for distant targets
local function fastTeleportIfDistant(currentPosition, targetPosition)
    local distance = (currentPosition.Position - targetPosition.Position).Magnitude
    
    -- If really far away, teleport closer
    if distance > 15 then
        return targetPosition * CFrame.new(0, 0, 3), true
    end
    
    return targetPosition, false
end

-- Function to get a smoothed target position to reduce jitter
local function getSmoothedTargetPosition(head)
    -- Calculate average position from history
    if #targetPositionHistory < 3 then
        return head.CFrame
    end
    
    -- Use more recent positions with higher weight
    local weightedPosition = head.Position * 0.6
    weightedPosition = weightedPosition + targetPositionHistory[#targetPositionHistory] * 0.25
    weightedPosition = weightedPosition + targetPositionHistory[#targetPositionHistory-1] * 0.15
    
    -- Create a CFrame with the averaged position but use the current rotation
    return CFrame.new(weightedPosition) * (head.CFrame - head.CFrame.Position)
end

-- Modified function for smoother thrusting animation
local function faceBang(head)
    local lastUpdate = tick()
    targetPositionHistory = {}
    targetIsWalking = false
    
    while getgenv().facefuckactive do
        if not head or not head:IsDescendantOf(workspace) then
            if targetPlayer and targetPlayer.Character then
                head = targetPlayer.Character:WaitForChild("Head")
                targetHead = head
                -- Reset tracking variables when retargeting
                targetPositionHistory = {}
                targetIsWalking = false
            else
                print("Target lost! Retargeting...")
                head = findNearestPlayer()
                if not head then
                    print("No nearby player found!")
                    task.wait(1)
                    continue
                end
            end
        end

        disableAllAnimations(LocalPlayer.Character)

        local distanceToTarget = (head.Position - HumanoidRootPart.Position).Magnitude
        local isTooFar = distanceToTarget > 10 -- Only teleport when really far
        local currentTime = tick()
        local deltaTime = currentTime - lastUpdate
        lastUpdate = currentTime
        
        -- Update walking state
        if currentTime - lastWalkCheckTime >= CHECK_INTERVAL then
            targetIsWalking = updateTargetWalkingState(head)
            lastWalkCheckTime = currentTime
        end

        -- Handle teleporting if too far away
        if isTooFar then
            local approachCFrame = head.CFrame * CFrame.new(0, HEIGHT_OFFSET, FOLLOW_DISTANCE + 1) * CFrame.Angles(0, math.rad(180), 0)
            HumanoidRootPart.CFrame = approachCFrame
            RunService.RenderStepped:Wait()
            continue
        end
        
        -- Get a smoothed target position to reduce jitter
        local smoothedHeadCFrame = getSmoothedTargetPosition(head)
        
        -- Get the base position that follows the target
        local basePosition = smoothedHeadCFrame * CFrame.new(0, HEIGHT_OFFSET, FOLLOW_DISTANCE) * CFrame.Angles(0, math.rad(180), 0)
        
        -- Perform the thrust animation from the current position
        local thrustPosition = smoothedHeadCFrame * CFrame.new(0, HEIGHT_OFFSET, FOLLOW_DISTANCE - THRUST_DISTANCE) * CFrame.Angles(0, math.rad(180), 0)
        
        -- Thrust forward with improved smoothing but faster
        local thrustStartTime = tick()
        local thrustDuration = THRUST_FORWARD_TIME
        while (tick() - thrustStartTime) < thrustDuration and getgenv().facefuckactive do
            -- Update for target movement
            smoothedHeadCFrame = getSmoothedTargetPosition(head)
            basePosition = smoothedHeadCFrame * CFrame.new(0, HEIGHT_OFFSET, FOLLOW_DISTANCE) * CFrame.Angles(0, math.rad(180), 0)
            thrustPosition = smoothedHeadCFrame * CFrame.new(0, HEIGHT_OFFSET, FOLLOW_DISTANCE - THRUST_DISTANCE) * CFrame.Angles(0, math.rad(180), 0)
            
            local progress = math.min((tick() - thrustStartTime) / thrustDuration, 1)
            
            -- Use easing function for smoother motion
            local currentThrust = smoothLerp(basePosition, thrustPosition, progress, easeInOutSine)
            HumanoidRootPart.CFrame = currentThrust
            
            -- Use RenderStepped for faster updates
            RunService.RenderStepped:Wait()
        end
        
        -- Remove pause to maintain original speed
        
        -- Thrust backward with improved smoothing but faster
        local returnStartTime = tick()
        local returnDuration = THRUST_BACKWARD_TIME
        while (tick() - returnStartTime) < returnDuration and getgenv().facefuckactive do
            -- Update for target movement
            smoothedHeadCFrame = getSmoothedTargetPosition(head)
            basePosition = smoothedHeadCFrame * CFrame.new(0, HEIGHT_OFFSET, FOLLOW_DISTANCE) * CFrame.Angles(0, math.rad(180), 0)
            thrustPosition = smoothedHeadCFrame * CFrame.new(0, HEIGHT_OFFSET, FOLLOW_DISTANCE - THRUST_DISTANCE) * CFrame.Angles(0, math.rad(180), 0)
            
            local progress = math.min((tick() - returnStartTime) / returnDuration, 1)
            
            -- Use easing function for smoother motion
            local currentReturn = smoothLerp(thrustPosition, basePosition, progress, easeInOutSine)
            HumanoidRootPart.CFrame = currentReturn
            
            -- Use RenderStepped for faster updates
            RunService.RenderStepped:Wait()
        end
    end

    enableAllAnimations(LocalPlayer.Character)
end

-- Function to toggle movement
local function toggleMovement()
    if not getgenv().facefuckactive then
        targetPlayer = nil
        targetHead = findNearestPlayer()
        
        if targetHead then
            getgenv().facefuckactive = true
            disableAllAnimations(LocalPlayer.Character)
            -- Reset tracking variables
            targetPositionHistory = {}
            targetIsWalking = false
            lastWalkCheckTime = tick()
            task.spawn(function()
                faceBang(targetHead)
            end)
        else
            print("No nearby player found!")
        end
    else
        getgenv().facefuckactive = false
        targetPlayer = nil
        targetHead = nil
        enableAllAnimations(LocalPlayer.Character)
    end
end

-- Enhanced function to create a modern GUI button
local function createMobileGUI()
    -- Create GUI for both mobile and PC users
    if PlayerGui:FindFirstChild("FaceBangGui") then
        PlayerGui.FaceBangGui:Destroy()
    end

    -- Create main ScreenGui
    local screengui = Instance.new("ScreenGui")
    screengui.Name = "FaceBangGui"
    screengui.ResetOnSpawn = false
    screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screengui.Parent = PlayerGui

    -- Create main container
    local shadowcontainer = Instance.new("Frame")
    shadowcontainer.Name = "ShadowContainer"
    shadowcontainer.Size = UDim2.new(0, 60, 0, 60)
    shadowcontainer.Position = UDim2.new(0.95, -30, 0.05, 30)
    shadowcontainer.BackgroundTransparency = 1
    shadowcontainer.Parent = screengui

    -- Create main button container
    local container = Instance.new("Frame")
    container.Name = "ButtonContainer"
    container.Size = UDim2.new(0, 56, 0, 56)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    container.BorderSizePixel = 0
    container.ZIndex = 2
    container.Parent = shadowcontainer

    -- Add corner radius to container
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0.3, 0)
    containerCorner.Parent = container

    -- Add gradient to container
    local containerGradient = Instance.new("UIGradient")
    containerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 75)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 50))
    })
    containerGradient.Rotation = 45
    containerGradient.Parent = container

    -- Add stroke to container for better visibility
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(70, 70, 85)
    containerStroke.Thickness = 1
    containerStroke.Parent = container
    
    -- Create button
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0.85, 0, 0.85, 0)
    button.Position = UDim2.new(0.5, 0, 0.5, 0)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.TextColor3 = Color3.fromRGB(230, 230, 250)
    button.Text = "F"
    button.TextSize = 22
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.ZIndex = 3
    button.AutoButtonColor = false
    button.Parent = container

    -- Add corner radius to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.3, 0)
    buttonCorner.Parent = button

    -- Add gradient to button
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 90))
    })
    containerGradient.Rotation = 45
    buttonGradient.Parent = button

    -- Add stroke to button
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(100, 100, 150)
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button

    -- Create status indicator
    local statusContainer = Instance.new("Frame")
    statusContainer.Name = "StatusContainer"
    statusContainer.Size = UDim2.new(0, 18, 0, 18)
    statusContainer.Position = UDim2.new(0.9, 0, 0.1, 0)
    statusContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    statusContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    statusContainer.BorderSizePixel = 0
    statusContainer.ZIndex = 4
    statusContainer.Parent = container

    -- Add corner radius to status container
    local statusContainerCorner = Instance.new("UICorner")
    statusContainerCorner.CornerRadius = UDim.new(1, 0)
    statusContainerCorner.Parent = statusContainer

    -- Add stroke to status container
    local statusContainerStroke = Instance.new("UIStroke")
    statusContainerStroke.Color = Color3.fromRGB(40, 40, 40)
    statusContainerStroke.Thickness = 1
    statusContainerStroke.Parent = statusContainer

    -- Create status indicator light
    local status = Instance.new("Frame")
    status.Name = "StatusLight"
    status.Size = UDim2.new(0.7, 0, 0.7, 0)
    status.Position = UDim2.new(0.5, 0, 0.5, 0)
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    status.BorderSizePixel = 0
    status.ZIndex = 5
    status.Parent = statusContainer

    -- Add corner radius to status light
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = status

    -- Add tooltip with hotkey info (appears on hover)
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 120, 0, 30)
    tooltip.Position = UDim2.new(0, -130, 0.5, 0)
    tooltip.AnchorPoint = Vector2.new(0, 0.5)
    tooltip.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tooltip.BorderSizePixel = 0
    tooltip.ZIndex = 10
    tooltip.Visible = false
    tooltip.Parent = container

    -- Add corner radius to tooltip
    local tooltipCorner = Instance.new("UICorner")
    tooltipCorner.CornerRadius = UDim.new(0.2, 0)
    tooltipCorner.Parent = tooltip

    -- Add tooltip text
    local tooltipText = Instance.new("TextLabel")
    tooltipText.Name = "TooltipText"
    tooltipText.Size = UDim2.new(1, -10, 1, 0)
    tooltipText.Position = UDim2.new(0.5, 0, 0.5, 0)
    tooltipText.AnchorPoint = Vector2.new(0.5, 0.5)
    tooltipText.BackgroundTransparency = 1
    tooltipText.TextColor3 = Color3.fromRGB(230, 230, 250)
    tooltipText.Text = "Hotkey: Z"
    tooltipText.TextSize = 14
    tooltipText.Font = Enum.Font.Gotham
    tooltipText.ZIndex = 11
    tooltipText.Parent = tooltip

    -- Add tooltip pointer
    local tooltipPointer = Instance.new("Frame")
    tooltipPointer.Name = "Pointer"
    tooltipPointer.Size = UDim2.new(0, 10, 0, 10)
    tooltipPointer.Position = UDim2.new(1, 0, 0.5, 0)
    tooltipPointer.AnchorPoint = Vector2.new(0.5, 0.5)
    tooltipPointer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tooltipPointer.BorderSizePixel = 0
    tooltipPointer.Rotation = 45
    tooltipPointer.ZIndex = 10
    tooltipPointer.Parent = tooltip

    -- Create hovering animation effect
    local floatingSequence = {
        TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        UDim2.new(0.95, -30, 0.05, 35)  -- Slightly higher position
    }
    
    local floatingTween = TweenService:Create(
        shadowcontainer,
        floatingSequence[1],
        {Position = floatingSequence[2]}
    )
    floatingTween:Play()

    -- Button hover effects
    button.MouseEnter:Connect(function()
        -- Show tooltip
        tooltip.Visible = true
        
        -- Button glow effect
        TweenService:Create(
            button,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(90, 90, 130)}
        ):Play()
        
        TweenService:Create(
            buttonGradient, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Offset = Vector2.new(0, -0.1)}
        ):Play()
    end)

    button.MouseLeave:Connect(function()
        -- Hide tooltip
        tooltip.Visible = false
        
        -- Restore button appearance
        TweenService:Create(
            button,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}
        ):Play()
        
        TweenService:Create(
            buttonGradient, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Offset = Vector2.new(0, 0)}
        ):Play()
    end)

    -- Button press effects
    button.MouseButton1Down:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.8, 0, 0.8, 0)}
        ):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.85, 0, 0.85, 0)}
        ):Play()
    end)

    -- Toggle functionality
    button.MouseButton1Click:Connect(function()
        toggleMovement()
        
        -- Update status light color with animation
        local targetColor = getgenv().facefuckactive and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
        
        -- Animate status indicator
        TweenService:Create(
            status,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = targetColor}
        ):Play()
        
        -- Pulse animation when activated
        if getgenv().facefuckactive then
            -- Create pulse effect
            local statusPulse = TweenService:Create(
                status,
                TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {BackgroundTransparency = 0.3}
            )
            statusPulse:Play()
        else
            -- Stop pulsing when deactivated
            TweenService:Create(
                status,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = 0}
            ):Play()
        end
        
        -- Button press animation
        TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.85, 0, 0.85, 0)}
        ):Play()
    end)
    
    -- Dragable functionality for the button
    local dragStart
    local startPos
    local dragging = false
    
    shadowcontainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = shadowcontainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            shadowcontainer.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Create ripple effect for button click
    local function createRipple(x, y)
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Position = UDim2.new(0, x, 0, y)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 2
        ripple.Parent = button
        
        local rippleCorner = Instance.newBridged("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        
        -- Animate ripple
        TweenService:Create(
            ripple,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, maxSize, 0, maxSize),
                BackgroundTransparency = 1
            }
        ):Play()
        
        -- Remove after animation
        task.delay(0.5, function()
            ripple:Destroy()
        end)
    end
    
    button.MouseButton1Down:Connect(function(x, y)
        local buttonPosition = button.AbsolutePosition
        local relativeX = x - buttonPosition.X
        local relativeY = y - buttonPosition.Y
        createRipple(relativeX, relativeY)
    end)
    
    -- Initialize status indicator
    if getgenv().facefuckactive then
        status.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        
        -- Create active pulse animation
        local statusPulse = TweenService:Create(
            status,
            TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.3}
        )
        statusPulse:Play()
    end
    
    -- Add notification for feedback
    local function showNotification(message, duration)
        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.Size = UDim2.new(0, 200, 0, 40)
        notification.Position = UDim2.new(0.5, 0, 0.8, 0)
        notification.AnchorPoint = Vector2.new(0.5, 0.5)
        notification.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        notification.BorderSizePixel = 0
        notification.ZIndex = 20
        notification.Parent = screengui
        
        local notificationCorner = Instance.new("UICorner")
        notificationCorner.CornerRadius = UDim.new(0.2, 0)
        notificationCorner.Parent = notification
        
        local notificationText = Instance.new("TextLabel")
        notificationText.Size = UDim2.new(1, -20, 1, 0)
        notificationText.Position = UDim2.new(0.5, 0, 0.5, 0)
        notificationText.AnchorPoint = Vector2.new(0.5, 0.5)
        notificationText.BackgroundTransparency = 1
        notificationText.TextColor3 = Color3.fromRGB(230, 230, 250)
        notificationText.Text = message
        notificationText.TextSize = 16
        notificationText.Font = Enum.Font.Gotham
        notificationText.ZIndex = 21
        notificationText.Parent = notification
        
        -- Animate in
        notification.Size = UDim2.new(0, 0, 0, 0)
        notification.BackgroundTransparency = 1
        notificationText.TextTransparency = 1
        
        TweenService:Create(
            notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 200, 0, 40),
                BackgroundTransparency = 0
            }
        ):Play()
        
        TweenService:Create(
            notificationText,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {TextTransparency = 0}
        ):Play()
        
        -- Animate out and destroy
        task.delay(duration or 2, function()
            TweenService:Create(
                notification,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1
                }
            ):Play()
            
            TweenService:Create(
                notificationText,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {TextTransparency = 1}
            ):Play()
            
            task.delay(0.3, function()
                notification:Destroy()
            end)
        end)
    end
    
    -- Display welcome notification
    showNotification("Press Z or click button to toggle", 3)
end

-- Add keybind for PC users
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Z then
        toggleMovement()
        -- Update mobile GUI status if it exists
        local gui = PlayerGui:FindFirstChild("FaceBangGui")
        if gui then
            local statusContainer = gui.ShadowContainer.ButtonContainer:FindFirstChild("StatusContainer")
            if statusContainer then
                local status = statusContainer:FindFirstChild("StatusLight")
                
                local targetColor = getgenv().facefuckactive and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
                
                TweenService:Create(
                    status,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = targetColor}
                ):Play()
                
                if getgenv().facefuckactive then
                    -- Wipe any existing tweens
                    for _, descendant in ipairs(statusContainer:GetDescendants()) do
                        if descendant:IsA("Frame") or descendant:IsA("ImageLabel") then
                            TweenService:Create(
                                descendant,
                                TweenInfo.new(0),
                                {BackgroundTransparency = descendant.BackgroundTransparency}
                            ):Play()
                        end
                    end
                    -- Create active pulse animation
                    local statusPulse = TweenService:Create(
                        status,
                        TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                        {BackgroundTransparency = 0.3}
                    )
                    statusPulse:Play()
                else
                    -- Wipe any existing tweens
                    for _, descendant in ipairs(statusContainer:GetDescendants()) do
                        if descendant:IsA("Frame") or descendant:IsA("ImageLabel") then
                            TweenService:Create(
                                descendant,
                                TweenInfo.new(0),
                                {BackgroundTransparency = descendant.BackgroundTransparency}
                            ):Play()
                        end
                    end
                    TweenService:Create(
                        status,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundTransparency = 0}
                    ):Play()
                end
            end
        end
    end
end)

-- Initialize everything
setupCharacterTracking()
setupAnimationPrevention()
createMobileGUI()
