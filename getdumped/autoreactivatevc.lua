-- Only auto reactivate when moderated
game:GetService("VoiceChatInternal").LocalPlayerModerated:Connect(function()
task.wait(1)
game:GetService("VoiceChatService"):joinVoice()
end)

local player = game:GetService("Players").LocalPlayer
local tweenService = game:GetService("TweenService")
-- Function to create and display a notification
local function createNotification()
    -- Create GUI objects
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AKAdminNotification"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 10
    screenGui.Parent = player.PlayerGui
    
    -- Main notification frame
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40) -- Dark background
    notificationFrame.BorderSizePixel = 0
    notificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    notificationFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    notificationFrame.Size = UDim2.new(0, 300, 0, 130)
    notificationFrame.Parent = screenGui
    
    -- Apply corner radius to make it look modern
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 8)
    cornerRadius.Parent = notificationFrame
    
    -- Size constraint to prevent the notification from being too large on big screens
    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MaxSize = Vector2.new(350, 160)
    sizeConstraint.MinSize = Vector2.new(250, 110)
    sizeConstraint.Parent = notificationFrame
    
    -- Apply padding for internal content
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = notificationFrame
    
    -- Header text
    local headerText = Instance.new("TextLabel")
    headerText.Name = "HeaderText"
    headerText.BackgroundTransparency = 1
    headerText.Font = Enum.Font.GothamBold
    headerText.TextColor3 = Color3.fromRGB(240, 240, 240) -- Light text
    headerText.TextSize = 24
    headerText.Text = "AK Admin"
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Position = UDim2.new(0, 0, 0, 0)
    headerText.Size = UDim2.new(1, 0, 0, 28)
    headerText.Parent = notificationFrame
    
    -- Colorful accent line under the header
    local accentLine = Instance.new("Frame")
    accentLine.Name = "AccentLine"
    accentLine.BackgroundColor3 = Color3.fromRGB(204, 153, 255) -- Light purple accent
    accentLine.BorderSizePixel = 0
    accentLine.Position = UDim2.new(0, 0, 0, 32)
    accentLine.Size = UDim2.new(0.4, 0, 0, 2)
    accentLine.Parent = notificationFrame
    
    -- Message text
    local messageText = Instance.new("TextLabel")
    messageText.Name = "MessageText"
    messageText.BackgroundTransparency = 1
    messageText.Font = Enum.Font.Gotham
    messageText.TextColor3 = Color3.fromRGB(200, 200, 200) -- Slightly darker than header for hierarchy
    messageText.TextSize = 16
    messageText.TextWrapped = true
    messageText.Text = "Auto reactivate VC enabled!"
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.Position = UDim2.new(0, 0, 0, 45)
    messageText.Size = UDim2.new(1, 0, 0, 60)
    messageText.Parent = notificationFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeButton.TextSize = 14
    closeButton.Text = "X"
    closeButton.Position = UDim2.new(1, -20, 0, 0)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Parent = notificationFrame
    
    -- Animation: make the notification appear with a subtle animation
    notificationFrame.Position = UDim2.new(0.5, 0, 0.4, 0) -- Start position slightly higher
    notificationFrame.BackgroundTransparency = 1
    headerText.TextTransparency = 1
    accentLine.BackgroundTransparency = 1
    messageText.TextTransparency = 1
    closeButton.TextTransparency = 1
    
    -- Create a table of properties to tween
    local tweenInfo = TweenInfo.new(
        0.5, -- Duration
        Enum.EasingStyle.Quad, -- Easing style
        Enum.EasingDirection.Out -- Easing direction
    )
    
    -- Create tweens for each element
    local frameTween = tweenService:Create(notificationFrame, tweenInfo, {
        Position = UDim2.new(0.5, 0, 0.5, 0), -- Move to center
        BackgroundTransparency = 0
    })
    
    local headerTween = tweenService:Create(headerText, tweenInfo, {
        TextTransparency = 0
    })
    
    local accentTween = tweenService:Create(accentLine, tweenInfo, {
        BackgroundTransparency = 0
    })
    
    local messageTween = tweenService:Create(messageText, tweenInfo, {
        TextTransparency = 0
    })
    
    local closeTween = tweenService:Create(closeButton, tweenInfo, {
        TextTransparency = 0
    })
    
    -- Play the tweens in sequence
    frameTween:Play()
    wait(0.1)
    headerTween:Play()
    wait(0.1)
    accentTween:Play()
    wait(0.1)
    messageTween:Play()
    wait(0.1)
    closeTween:Play()
    
    -- Function to close/dismiss the notification
    local function closeNotification()
        -- Fade out animation
        local closeTweenInfo = TweenInfo.new(
            0.4, -- Duration
            Enum.EasingStyle.Quad, -- Easing style
            Enum.EasingDirection.In -- Easing direction
        )
        
        local frameCloseTween = tweenService:Create(notificationFrame, closeTweenInfo, {
            Position = UDim2.new(0.5, 0, 0.4, 0), -- Move up slightly
            BackgroundTransparency = 1
        })
        
        local headerCloseTween = tweenService:Create(headerText, closeTweenInfo, {
            TextTransparency = 1
        })
        
        local accentCloseTween = tweenService:Create(accentLine, closeTweenInfo, {
            BackgroundTransparency = 1
        })
        
        local messageCloseTween = tweenService:Create(messageText, closeTweenInfo, {
            TextTransparency = 1
        })
        
        local closeButtonTween = tweenService:Create(closeButton, closeTweenInfo, {
            TextTransparency = 1
        })
        
        -- Play close animations
        frameCloseTween:Play()
        headerCloseTween:Play()
        accentCloseTween:Play()
        messageCloseTween:Play()
        closeButtonTween:Play()
        
        -- Wait for animation to complete then remove
        wait(0.4)
        screenGui:Destroy()
    end
    
    -- Connect close button click event
    closeButton.MouseButton1Click:Connect(function()
        closeNotification()
    end)
    
    -- Auto-close after 5 seconds
    wait(5)
    closeNotification()
end
createNotification()
