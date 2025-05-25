-- Professional Error Notification System
-- Optimized for Roblox Studio
-- Place in StarterPlayerScripts

local NotificationSystem = {}

-- Services
local Players = game:GetService("Players")
local LogService = game:GetService("LogService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

-- Constants
local NOTIFICATION_CONFIG = {
    FRIEND_REQUEST_POSITION = UDim2.new(0.5, 0, 0.08, 0),
    ANIMATION_DURATION = 0.65,
    DISPLAY_DURATION = 12,
    MAX_QUEUE_SIZE = 5,
    SPACING = UDim2.new(0, 0, 0.12, 0),
    MAX_WIDTH = UDim2.new(0.7, 0, 0, 0),
    MIN_WIDTH = UDim2.new(0.35, 0, 0, 0)
}

local THEME = {
    BACKGROUND = Color3.fromRGB(40, 44, 52),
    ACCENT = Color3.fromRGB(65, 105, 225),
    ERROR = Color3.fromRGB(220, 53, 69),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
    BUTTON_HOVER = Color3.fromRGB(45, 45, 50),
    SHADOW = Color3.fromRGB(0, 0, 0)
}

-- Local Variables
local player = Players.LocalPlayer
local notificationQueue = {}
local activeNotifications = {}
local screenGui
local soundEffects = {}
local errorDebounceTable = {}

-- Utility Functions
local function CreateDropShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://7131316275"
    shadow.ImageColor3 = THEME.SHADOW
    shadow.ImageTransparency = 0.5
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 15, 1, 15)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- Initialize Sound Effects
local function InitializeSounds()
    soundEffects.show = Instance.new("Sound")
    soundEffects.show.SoundId = "rbxassetid://6518811702"
    soundEffects.show.Volume = 0.3

    soundEffects.hide = Instance.new("Sound")
    soundEffects.hide.SoundId = "rbxassetid://6518811702"
    soundEffects.hide.Volume = 0.2
    soundEffects.hide.PlaybackSpeed = 0.8

    for _, sound in pairs(soundEffects) do
        sound.Parent = screenGui
    end
end

-- Create Professional GUI Components
local function CreateNotificationFrame()
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = NOTIFICATION_CONFIG.MIN_WIDTH + UDim2.new(0, 0, 0, 130)
    notificationFrame.Position = UDim2.new(0.5, 0.08, 0, 0)
    notificationFrame.AnchorPoint = Vector2.new(0.5, 0)
    notificationFrame.BackgroundColor3 = THEME.BACKGROUND
    notificationFrame.BorderSizePixel = 0
    notificationFrame.ZIndex = 10

    -- Add modern rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notificationFrame

    -- Add gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.BACKGROUND),
        ColorSequenceKeypoint.new(1, THEME.BACKGROUND:Lerp(Color3.new(1, 1, 1), 0.05))
    })
    gradient.Rotation = 45
    gradient.Parent = notificationFrame

    -- Add professional stroke effect
    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.ACCENT
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = notificationFrame

    -- Add drop shadow
    CreateDropShadow(notificationFrame)

    return notificationFrame
end

local function CreateContentComponents(parent)
    -- Error Icon
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30) -- Fixed size
    iconLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = "rbxassetid://11401835376"
    iconLabel.ImageColor3 = THEME.ERROR
    iconLabel.Parent = parent

    -- Title with custom font
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.85, 0, 0.2, 0)
    titleLabel.Position = UDim2.new(0.1, 0, 0.02, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = THEME.TEXT_PRIMARY
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "Runtime Error Detected"
    titleLabel.Parent = parent

    -- Message with automatic text scaling
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(0.9, 0, 0, 70) -- Initial height for message
    messageLabel.Position = UDim2.new(0.05, 0, 0.3, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextColor3 = THEME.TEXT_SECONDARY
    messageLabel.TextSize = 14
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = parent

    return titleLabel, messageLabel
end

local function CreateInteractiveButtons(parent, messageLabel)
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.9, 0, 0.2, 0)
    buttonContainer.Position = UDim2.new(0.05, 0, 0.8, 0)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = parent

    -- Modern Copy Button
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    copyButton.Position = UDim2.new(0, 0, 0, 0)
    copyButton.BackgroundColor3 = THEME.BACKGROUND:Lerp(Color3.new(1, 1, 1), 0.1)
    copyButton.Text = "Copy Details"
    copyButton.TextColor3 = THEME.TEXT_PRIMARY
    copyButton.Font = Enum.Font.GothamBold
    copyButton.TextSize = 14
    copyButton.AutoButtonColor = false
    copyButton.Parent = buttonContainer

    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 8)
    copyCorner.Parent = copyButton

    local copyStroke = Instance.new("UIStroke")
    copyStroke.Color = THEME.ACCENT
    copyStroke.Thickness = 1.5
    copyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    copyStroke.Parent = copyButton

    -- Dismiss Button
    local dismissButton = Instance.new("TextButton")
    dismissButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    dismissButton.Position = UDim2.new(0.5, 0, 0, 0)
    dismissButton.BackgroundColor3 = THEME.ACCENT
    dismissButton.Text = "Dismiss"
    dismissButton.TextColor3 = THEME.TEXT_PRIMARY
    dismissButton.Font = Enum.Font.GothamBold
    dismissButton.TextSize = 14
    dismissButton.AutoButtonColor = false
    dismissButton.Parent = buttonContainer

    local dismissCorner = Instance.new("UICorner")
    dismissCorner.CornerRadius = UDim.new(0, 8)
    dismissCorner.Parent = dismissButton

    -- Button functionality
    copyButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(messageLabel.Text)
            -- Show copy confirmation effect
            local originalText = copyButton.Text
            copyButton.Text = "Copied!"
            task.delay(1, function()
                copyButton.Text = originalText
            end)
        end
    end)

    dismissButton.MouseButton1Click:Connect(function()
        NotificationSystem.DismissNotification(parent)
    end)

    return copyButton, dismissButton
end

-- Notification System Functions
local function InitializeNotificationSystem()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnhancedErrorNotifier"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Handle DisplayOrder to ensure notifications appear on top
    screenGui.DisplayOrder = 999

    -- Parent to PlayerGui
    screenGui.Parent = game.CoreGui
    -- Initialize sound effects
    InitializeSounds()
end

local function CreateNotification(errorMessage, stackTrace)
    local notificationFrame = CreateNotificationFrame()

    notificationFrame.Parent = screenGui

    local title, messageLabel = CreateContentComponents(notificationFrame)
    messageLabel.Text = errorMessage .. "\n" .. stackTrace

    -- Calculate dimensions based on the text content
    local textSize = TextService:GetTextSize(
        messageLabel.Text,
        messageLabel.TextSize,
        messageLabel.Font,
        Vector2.new(1000, math.huge)
    )

    local adjustedHeight = textSize.Y + 100 -- Includes space for buttons and padding
    local adjustedWidth = math.min(textSize.X + 60, workspace.CurrentCamera.ViewportSize.X * 0.7) -- Adapt to viewport size

    notificationFrame.Size = UDim2.new(
        0, adjustedWidth,
        0, adjustedHeight
    )

    CreateInteractiveButtons(notificationFrame, messageLabel)

    return notificationFrame
end

function NotificationSystem.ShowNotification(errorMessage, stackTrace)
    -- Ensure notifications don't spam
    local currentTime = tick()
    if errorDebounceTable[errorMessage] and currentTime - errorDebounceTable[errorMessage] < NOTIFICATION_CONFIG.DISPLAY_DURATION then
        return
    end

    errorDebounceTable[errorMessage] = currentTime

    if #activeNotifications >= NOTIFICATION_CONFIG.MAX_QUEUE_SIZE then
        NotificationSystem.DismissNotification(activeNotifications[1])
    end

    local notificationFrame = CreateNotification(errorMessage, stackTrace)
    table.insert(activeNotifications, notificationFrame)

    -- Position and animate notification
    notificationFrame.Position = NOTIFICATION_CONFIG.FRIEND_REQUEST_POSITION +
        UDim2.new(0, 0, -0.5, 0)

    soundEffects.show:Play()

    -- Smooth entrance animation
    local tweenInfo = TweenInfo.new(
        NOTIFICATION_CONFIG.ANIMATION_DURATION,
        Enum.EasingStyle.Elastic,
        Enum.EasingDirection.Out
    )

    TweenService:Create(notificationFrame, tweenInfo, {
        Position = NOTIFICATION_CONFIG.FRIEND_REQUEST_POSITION
    }):Play()

    -- Auto-dismiss after the delay
    task.delay(NOTIFICATION_CONFIG.DISPLAY_DURATION, function()
        if table.find(activeNotifications, notificationFrame) then
            NotificationSystem.DismissNotification(notificationFrame)
        end
    end)

    -- Update positions of other active notifications
    task.defer(NotificationSystem.UpdateNotificationPositions)
end

function NotificationSystem.DismissNotification(notificationFrame)
    local index = table.find(activeNotifications, notificationFrame)
    if not index then return end

    table.remove(activeNotifications, index)
    soundEffects.hide:Play()

    -- Smooth exit animation
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(notificationFrame, tweenInfo, {
        Position = notificationFrame.Position + UDim2.new(0, 0, -0.5, 0),
        BackgroundTransparency = 1,
        Transparency = 1
    })

    tween.Completed:Connect(function()
        notificationFrame:Destroy()
    end)

    tween:Play()

    -- Update positions of remaining notifications
    task.defer(NotificationSystem.UpdateNotificationPositions)
end

function NotificationSystem.UpdateNotificationPositions()
    for i, notificationFrame in ipairs(activeNotifications) do
        local targetPosition = NOTIFICATION_CONFIG.FRIEND_REQUEST_POSITION + UDim2.new(0, 0, NOTIFICATION_CONFIG.SPACING.Y.Scale * (i - 1), NOTIFICATION_CONFIG.SPACING.Y.Offset * (i - 1))

        -- Ensure the position update is error-free
        pcall(function()
            TweenService:Create(notificationFrame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                { Position = targetPosition }
            ):Play()
        end)
    end
end

-- Initialize the system
InitializeNotificationSystem()

-- Connect to LogService
LogService.MessageOut:Connect(function(message, messageType)
    if messageType == Enum.MessageType.MessageError then
        -- Extract stack trace from message
        local stackTrace = string.match(message, "\nStack Begin\n(.-)\nStack End")
        if not stackTrace then stackTrace = "No stack trace available" end

        local errorMessage = message:gsub("\nStack Begin\n(.-)\nStack End", "")

        NotificationSystem.ShowNotification(errorMessage, stackTrace)
    end
end)

return NotificationSystem
