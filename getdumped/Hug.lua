local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ANIMATION_IDS = {
    R6 = {
        "rbxassetid://225975820",
        "rbxassetid://283545583"
    },
    R15 = {
        "rbxassetid://6082224617",
        "rbxassetid://4940563117"
    }
}

local State = {
    isHugging = false,
    animations = {},
    defaultGravity = workspace.Gravity
}

local function setupAnimations()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local animationIds = humanoid.RigType == Enum.HumanoidRigType.R15 and ANIMATION_IDS.R15 or ANIMATION_IDS.R6
    
    for _, anim in pairs(State.animations) do
        if anim.AnimationTrack then
            anim.AnimationTrack:Stop()
            anim.AnimationTrack:Destroy()
        end
    end
    
    State.animations = {}
    
    for _, id in ipairs(animationIds) do
        local animation = Instance.new("Animation")
        animation.AnimationId = id
        local animationTrack = humanoid:LoadAnimation(animation)
        
        -- Add TimePosition changed callback for R15
        if humanoid.RigType == Enum.HumanoidRigType.R15 then
            animationTrack.TimePosition = 0
            task.delay(0.3, function()
                if animationTrack.IsPlaying then
                    animationTrack:AdjustSpeed(0)
                end
            end)
        end
        
        table.insert(State.animations, {
            Animation = animation,
            AnimationTrack = animationTrack
        })
    end
end

local function findNearestPlayer()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local nearestPlayer = nil
    local minDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetCharacter = player.Character
            if targetCharacter then
                local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        nearestPlayer = player
                    end
                end
            end
        end
    end
    
    return nearestPlayer
end

local function attachToTarget(rootPart, targetRootPart)
    local attachment = Instance.new("Attachment")
    attachment.Parent = rootPart
    
    local targetAttachment = Instance.new("Attachment")
    targetAttachment.CFrame = CFrame.new(0, 0, 1)
    targetAttachment.Parent = targetRootPart
    
    local alignPosition = Instance.new("AlignPosition")
    alignPosition.Attachment0 = attachment
    alignPosition.Attachment1 = targetAttachment
    alignPosition.MaxForce = 100000
    alignPosition.MaxVelocity = 500
    alignPosition.Responsiveness = 200
    alignPosition.Parent = rootPart
    
    local alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Attachment0 = attachment
    alignOrientation.Attachment1 = targetAttachment
    alignOrientation.MaxTorque = 100000
    alignOrientation.Responsiveness = 200
    alignOrientation.Parent = rootPart
end

local function cleanupAttachments()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, child in ipairs(rootPart:GetChildren()) do
        if child:IsA("Attachment") or child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
            child:Destroy()
        end
    end
end

local function toggleHug()
    State.isHugging = not State.isHugging
    
    if State.isHugging then
        workspace.Gravity = 0
        local target = findNearestPlayer()
        
        if target and target.Character then
            local character = LocalPlayer.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local targetRootPart = target.Character:FindFirstChild("HumanoidRootPart")
                
                if rootPart and targetRootPart then
                    setupAnimations()
                    for _, anim in pairs(State.animations) do
                        if anim.AnimationTrack then
                            anim.AnimationTrack:Play()
                        end
                    end
                    attachToTarget(rootPart, targetRootPart)
                end
            end
        end
    else
        workspace.Gravity = State.defaultGravity
        for _, anim in pairs(State.animations) do
            if anim.AnimationTrack then
                anim.AnimationTrack:Stop()
                anim.AnimationTrack:AdjustSpeed(1) -- Reset animation speed
            end
        end
        cleanupAttachments()
    end
end

local function setupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
            toggleHug()
        end
    end)
    
    if UserInputService.TouchEnabled then
        local screenGui = Instance.new("ScreenGui")
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 999
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 60, 0, 60)
        button.Position = UDim2.new(0.95, -70, 0.2, 0)
        button.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
        button.Text = "🤗"
        button.TextSize = 30
        button.Font = Enum.Font.GothamBold
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.AutoButtonColor = false
        button.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = button
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 182, 193)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 192, 203))
        })
        gradient.Rotation = 45
        gradient.Parent = button
        
        local function createTween(properties)
            return TweenService:Create(button, TweenInfo.new(0.3), properties)
        end
        
        button.MouseButton1Click:Connect(toggleHug)
        button.MouseEnter:Connect(function()
            createTween({Size = UDim2.new(0, 66, 0, 66)}):Play()
        end)
        button.MouseLeave:Connect(function()
            createTween({Size = UDim2.new(0, 60, 0, 60)}):Play()
        end)
    end
end

setupInput()
