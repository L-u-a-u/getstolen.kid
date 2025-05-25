local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local THEME = {
    BACKGROUND = Color3.fromRGB(15, 15, 20),
    SECONDARY = Color3.fromRGB(25, 25, 35),
    ACCENT = Color3.fromRGB(65, 135, 245),
    ACCENT_HOVER = Color3.fromRGB(85, 155, 255),
    TEXT = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(180, 180, 190),
    SHADOW = Color3.fromRGB(0, 0, 0),
    SUCCESS = Color3.fromRGB(72, 199, 142),
    ERROR = Color3.fromRGB(245, 75, 75)
}

local CONFIG = {
    GUI_WIDTH = 300,
    GUI_HEIGHT = 400,
    ENTRY_HEIGHT = 50,
    CORNER_RADIUS = 6,
    TWEEN_SPEED = 0.2
}

local function createTween(instance, properties, duration)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration or CONFIG.TWEEN_SPEED, Enum.EasingStyle.Quad),
        properties
    ):Play()
end

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://7912134082"
    shadow.ImageColor3 = THEME.SHADOW
    shadow.ImageTransparency = 0.4
    shadow.Size = UDim2.new(1, 16, 1, 16)
    shadow.Position = UDim2.new(0, -8, 0, -8)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
end

-- GUI Creation
local gui = Instance.new("ScreenGui")
gui.Name = "PremiumAnimationLogger"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, CONFIG.GUI_HEIGHT)
frame.Position = UDim2.new(1, -CONFIG.GUI_WIDTH - 20, 0.5, -CONFIG.GUI_HEIGHT/2)
frame.BackgroundColor3 = THEME.BACKGROUND
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
createShadow(frame)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = THEME.SECONDARY
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)

local title = Instance.new("TextLabel")
title.Text = "Animation Logger"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = THEME.TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Control Buttons
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0, 80, 1, 0)
buttonContainer.Position = UDim2.new(1, -80, 0, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = titleBar

local function createButton(properties)
    local button = Instance.new("TextButton")
    for prop, value in pairs(properties) do
        button[prop] = value
    end
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
    return button
end

local clearButton = createButton({
    Text = "Clear",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    Size = UDim2.new(0, 45, 0, 24),
    Position = UDim2.new(0, 0, 0.5, -12),
    BackgroundColor3 = THEME.ACCENT,
    TextColor3 = THEME.TEXT,
    AutoButtonColor = false,
    Parent = buttonContainer
})

local closeButton = createButton({
    Text = "×",
    Font = Enum.Font.GothamMedium,
    TextSize = 20,
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -29, 0.5, -12),
    BackgroundColor3 = THEME.ERROR,
    TextColor3 = THEME.TEXT,
    AutoButtonColor = false,
    Parent = buttonContainer
})

-- Scrolling Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Position = UDim2.new(0, 8, 0, 48)
scrollFrame.Size = UDim2.new(1, -16, 1, -56)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = THEME.ACCENT
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

-- Animation Tracking
local loggedAnimations = {}

local function createLogEntry(track)
    local animId = track.Animation.AnimationId
    if loggedAnimations[animId] then return end
    loggedAnimations[animId] = true
    
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, 0, 0, CONFIG.ENTRY_HEIGHT)
    entry.BackgroundColor3 = THEME.SECONDARY
    entry.BackgroundTransparency = 1
    entry.Parent = scrollFrame
    
    Instance.new("UICorner", entry).CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
    
    local animName = Instance.new("TextLabel")
    animName.Text = track.Animation.Name or "Unnamed Animation"
    animName.Font = Enum.Font.GothamBold
    animName.TextSize = 14
    animName.Size = UDim2.new(1, -65, 0, 20)
    animName.Position = UDim2.new(0, 12, 0, 8)
    animName.BackgroundTransparency = 1
    animName.TextColor3 = THEME.TEXT
    animName.TextXAlignment = Enum.TextXAlignment.Left
    animName.Parent = entry
    
    local idLabel = Instance.new("TextLabel")
    idLabel.Text = animId:match("rbxassetid://(.+)") or animId
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 12
    idLabel.Size = UDim2.new(1, -65, 0, 16)
    idLabel.Position = UDim2.new(0, 12, 1, -24)
    idLabel.BackgroundTransparency = 1
    idLabel.TextColor3 = THEME.TEXT_SECONDARY
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Parent = entry
    
    local copyButton = createButton({
        Text = "Copy",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(0, 45, 0, 24),
        Position = UDim2.new(1, -55, 0.5, -12),
        BackgroundColor3 = THEME.ACCENT,
        TextColor3 = THEME.TEXT,
        BackgroundTransparency = 1,
        Parent = entry
    })
    
    -- Animations
    createTween(entry, {BackgroundTransparency = 0})
    createTween(copyButton, {BackgroundTransparency = 0.2})
    
    -- Button Events
    copyButton.MouseEnter:Connect(function()
        createTween(copyButton, {BackgroundColor3 = THEME.ACCENT_HOVER})
    end)
    
    copyButton.MouseLeave:Connect(function()
        createTween(copyButton, {BackgroundColor3 = THEME.ACCENT})
    end)
    
    copyButton.MouseButton1Click:Connect(function()
        setclipboard(animId:match("%d+"))
        createTween(copyButton, {BackgroundColor3 = THEME.SUCCESS})
        task.wait(0.5)
        createTween(copyButton, {BackgroundColor3 = THEME.ACCENT})
    end)
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Character Hook
local function hookCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    animator.AnimationPlayed:Connect(createLogEntry)
end

-- Initialize
local player = Players.LocalPlayer
if player.Character then hookCharacter(player.Character) end
player.CharacterAdded:Connect(hookCharacter)

-- Dragging System
local dragging, dragStart, startPos, dragInput

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        createTween(frame, {
            Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        }, 0.1)
    end
end)

-- Button Events
clearButton.MouseButton1Click:Connect(function()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            createTween(child, {BackgroundTransparency = 1})
            task.delay(0.2, function() child:Destroy() end)
        end
    end
    loggedAnimations = {}
end)

closeButton.MouseButton1Click:Connect(function()
    createTween(frame, {Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, 0)}, 0.3)
    task.wait(0.3)
    gui:Destroy()
end)

-- Initialize GUI
gui.Parent = player:WaitForChild("PlayerGui")
frame.Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, 0)
createTween(frame, {Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, CONFIG.GUI_HEIGHT)}, 0.3)

