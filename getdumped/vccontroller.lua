--[[
    Player Radius Audio Control Script
    Allows players to control who they can hear based on proximity
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    DEFAULT_RADIUS = 50,
    MIN_RADIUS = 5,
    MAX_RADIUS = 500,
    PRESET_VALUES = {10, 25, 50, 100, 200},
    COLOR = {
        MAIN_BG = Color3.fromRGB(40, 45, 60),
        SECONDARY_BG = Color3.fromRGB(60, 65, 80),
        ACCENT = Color3.fromRGB(0, 132, 255),
        TEXT = Color3.fromRGB(240, 240, 240),
        ERROR = Color3.fromRGB(255, 80, 80),
        SUCCESS = Color3.fromRGB(80, 230, 80),
        HIGHLIGHT_IN_RANGE = Color3.fromRGB(80, 200, 120),
        HIGHLIGHT_OUT_RANGE = Color3.fromRGB(200, 80, 80)
    }
}

-- State Variables
local state = {
    radiusEnabled = false,
    currentRadius = CONFIG.DEFAULT_RADIUS,
    isDragging = false,
    showingVisualRadius = false,
    visualRadiusPart = nil
}

-- Utility Functions
local Utility = {}

function Utility.getCharacterRoot(character)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
end

function Utility.createButtonAnimation(button)
    local originalColor = button.BackgroundColor3
    local originalSize = button.Size
    local hoverColor = Color3.new(
        math.min(originalColor.R + 0.1, 1),
        math.min(originalColor.G + 0.1, 1),
        math.min(originalColor.B + 0.1, 1)
    )
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.95, 
                            originalSize.Y.Scale, originalSize.Y.Offset * 0.95)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = originalSize
        }):Play()
    end)
end

function Utility.showNotification(parent, message, messageType)
    local notifColor = messageType == "error" and CONFIG.COLOR.ERROR or CONFIG.COLOR.SUCCESS
    
    local notification = Instance.new("TextLabel")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 200, 0, 30)
    notification.Position = UDim2.new(0.5, -100, 0, -40)
    notification.BackgroundColor3 = notifColor
    notification.TextColor3 = CONFIG.COLOR.TEXT
    notification.TextSize = 14
    notification.Font = Enum.Font.GothamSemibold
    notification.Text = message
    notification.TextWrapped = true
    notification.BackgroundTransparency = 0.2
    notification.AnchorPoint = Vector2.new(0.5, 0)
    notification.Parent = parent
    
    local notifUICorner = Instance.new("UICorner")
    notifUICorner.CornerRadius = UDim.new(0, 6)
    notifUICorner.Parent = notification
    
    TweenService:Create(notification, TweenInfo.new(0.5), {
        Position = UDim2.new(0.5, -100, 0, 10)
    }):Play()
    
    delay(3, function()
        local fadeTween = TweenService:Create(notification, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Ensure the local character is loaded
if not LocalPlayer.Character or not Utility.getCharacterRoot(LocalPlayer.Character) then
    LocalPlayer.CharacterAdded:Wait()
end

-- Visual Radius Functions
local VisualRadius = {}

function VisualRadius.create()
    if state.visualRadiusPart then
        state.visualRadiusPart:Destroy()
    end
    
    local part = Instance.new("Part")
    part.Name = "RadiusVisualization"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.8
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new("Cyan")
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(state.currentRadius * 2, state.currentRadius * 2, state.currentRadius * 2)
    
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "RadiusLabel"
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 36)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 24
    textLabel.Text = "Radius: " .. state.currentRadius
    textLabel.Parent = surfaceGui
    
    part.Parent = workspace
    state.visualRadiusPart = part
    state.showingVisualRadius = true
end

function VisualRadius.update()
    if not state.showingVisualRadius or not state.visualRadiusPart then return end
    
    local character = LocalPlayer.Character
    local rootPart = Utility.getCharacterRoot(character)
    if rootPart then
        state.visualRadiusPart.Position = rootPart.Position
    end
    
    if state.visualRadiusPart.Size.X ~= state.currentRadius * 2 then
        state.visualRadiusPart.Size = Vector3.new(
            state.currentRadius * 2, 
            state.currentRadius * 2, 
            state.currentRadius * 2
        )
        
        local label = state.visualRadiusPart:FindFirstChild("RadiusLabel")
        if label and label:IsA("SurfaceGui") then
            local textLabel = label:FindFirstChildOfClass("TextLabel")
            if textLabel then
                textLabel.Text = "Radius: " .. state.currentRadius
            end
        end
    end
end

function VisualRadius.toggle()
    if state.showingVisualRadius then
        if state.visualRadiusPart then
            state.visualRadiusPart:Destroy()
            state.visualRadiusPart = nil
        end
        state.showingVisualRadius = false
    else
        VisualRadius.create()
    end
    return state.showingVisualRadius
end

-- Highlight Functions
local HighlightManager = {}

function HighlightManager.addHighlight(character, inRange)
    if not character then return end
    
    local hl = character:FindFirstChild("RadiusHighlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "RadiusHighlight"
        hl.Parent = character
    end
    
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 0
    
    if inRange then
        hl.FillColor = CONFIG.COLOR.HIGHLIGHT_IN_RANGE
        hl.OutlineColor = CONFIG.COLOR.HIGHLIGHT_IN_RANGE
    else
        hl.FillColor = CONFIG.COLOR.HIGHLIGHT_OUT_RANGE
        hl.OutlineColor = CONFIG.COLOR.HIGHLIGHT_OUT_RANGE
    end
end

function HighlightManager.removeHighlight(character)
    if not character then return end
    
    local hl = character:FindFirstChild("RadiusHighlight")
    if hl then
        hl:Destroy()
    end
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RadiusControlGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.BackgroundColor3 = CONFIG.COLOR.MAIN_BG
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = CONFIG.COLOR.ACCENT
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleBarBottom = Instance.new("Frame")
TitleBarBottom.Name = "TitleBarBottom"
TitleBarBottom.Size = UDim2.new(1, 0, 0, 10)
TitleBarBottom.Position = UDim2.new(0, 0, 1, -10)
TitleBarBottom.BackgroundColor3 = CONFIG.COLOR.ACCENT
TitleBarBottom.BorderSizePixel = 0
TitleBarBottom.ZIndex = 0
TitleBarBottom.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Radius Audio Controller"
TitleLabel.TextColor3 = CONFIG.COLOR.TEXT
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = CONFIG.COLOR.ERROR
CloseButton.Text = "×"
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = CONFIG.COLOR.TEXT
CloseButton.Parent = TitleBar

local CloseUICorner = Instance.new("UICorner")
CloseUICorner.CornerRadius = UDim.new(0, 6)
CloseUICorner.Parent = CloseButton

-- Main content
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Radius control section
local RadiusControlFrame = Instance.new("Frame")
RadiusControlFrame.Name = "RadiusControlFrame"
RadiusControlFrame.Size = UDim2.new(1, 0, 0, 80)
RadiusControlFrame.BackgroundTransparency = 1
RadiusControlFrame.Parent = ContentFrame

local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Name = "RadiusLabel"
RadiusLabel.Size = UDim2.new(0, 100, 0, 25)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.Text = "Radius:"
RadiusLabel.TextColor3 = CONFIG.COLOR.TEXT
RadiusLabel.TextSize = 14
RadiusLabel.Font = Enum.Font.GothamSemibold
RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
RadiusLabel.Parent = RadiusControlFrame

local RadiusInput = Instance.new("TextBox")
RadiusInput.Name = "RadiusInput"
RadiusInput.Size = UDim2.new(0, 100, 0, 30)
RadiusInput.Position = UDim2.new(0, 0, 0, 25)
RadiusInput.BackgroundColor3 = CONFIG.COLOR.SECONDARY_BG
RadiusInput.Text = tostring(state.currentRadius)
RadiusInput.TextColor3 = CONFIG.COLOR.TEXT
RadiusInput.PlaceholderText = "Enter radius..."
RadiusInput.TextSize = 14
RadiusInput.Font = Enum.Font.Gotham
RadiusInput.ClearTextOnFocus = false
RadiusInput.Parent = RadiusControlFrame

local RadiusInputCorner = Instance.new("UICorner")
RadiusInputCorner.CornerRadius = UDim.new(0, 6)
RadiusInputCorner.Parent = RadiusInput

local PresetFrame = Instance.new("Frame")
PresetFrame.Name = "PresetFrame"
PresetFrame.Size = UDim2.new(0, 170, 0, 60)
PresetFrame.Position = UDim2.new(1, -170, 0, 0)
PresetFrame.BackgroundTransparency = 1
PresetFrame.Parent = RadiusControlFrame

local PresetLabel = Instance.new("TextLabel")
PresetLabel.Name = "PresetLabel"
PresetLabel.Size = UDim2.new(1, 0, 0, 20)
PresetLabel.BackgroundTransparency = 1
PresetLabel.Text = "Preset Values:"
PresetLabel.TextColor3 = CONFIG.COLOR.TEXT
PresetLabel.TextSize = 14
PresetLabel.Font = Enum.Font.GothamSemibold
PresetLabel.TextXAlignment = Enum.TextXAlignment.Left
PresetLabel.Parent = PresetFrame

local PresetButtonsFrame = Instance.new("Frame")
PresetButtonsFrame.Name = "PresetButtonsFrame"
PresetButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
PresetButtonsFrame.Position = UDim2.new(0, 0, 0, 25)
PresetButtonsFrame.BackgroundTransparency = 1
PresetButtonsFrame.Parent = PresetFrame

local buttonWidth = 30
local padding = 5
for i, value in ipairs(CONFIG.PRESET_VALUES) do
    local PresetButton = Instance.new("TextButton")
    PresetButton.Name = "Preset_" .. value
    PresetButton.Size = UDim2.new(0, buttonWidth, 0, buttonWidth)
    PresetButton.Position = UDim2.new(0, (i-1) * (buttonWidth + padding), 0, 0)
    PresetButton.BackgroundColor3 = CONFIG.COLOR.SECONDARY_BG
    PresetButton.Text = tostring(value)
    PresetButton.TextColor3 = CONFIG.COLOR.TEXT
    PresetButton.TextSize = 12
    PresetButton.Font = Enum.Font.GothamSemibold
    PresetButton.Parent = PresetButtonsFrame
    
    local PresetButtonCorner = Instance.new("UICorner")
    PresetButtonCorner.CornerRadius = UDim.new(0, 4)
    PresetButtonCorner.Parent = PresetButton
    
    Utility.createButtonAnimation(PresetButton)
    
    PresetButton.MouseButton1Click:Connect(function()
        state.currentRadius = value
        RadiusInput.Text = tostring(value)
    end)
end

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Name = "ControlsFrame"
ControlsFrame.Size = UDim2.new(1, 0, 0, 85)
ControlsFrame.Position = UDim2.new(0, 0, 0, 90)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Parent = ContentFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 140, 0, 35)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundColor3 = CONFIG.COLOR.SECONDARY_BG
ToggleButton.Text = "Enable Radius Audio"
ToggleButton.TextColor3 = CONFIG.COLOR.TEXT
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Parent = ControlsFrame

local ToggleUICorner = Instance.new("UICorner")
ToggleUICorner.CornerRadius = UDim.new(0, 6)
ToggleUICorner.Parent = ToggleButton

local VisualizeButton = Instance.new("TextButton")
VisualizeButton.Name = "VisualizeButton"
VisualizeButton.Size = UDim2.new(0, 140, 0, 35)
VisualizeButton.Position = UDim2.new(1, -140, 0, 0)
VisualizeButton.BackgroundColor3 = CONFIG.COLOR.SECONDARY_BG
VisualizeButton.Text = "Show Radius Sphere"
VisualizeButton.TextColor3 = CONFIG.COLOR.TEXT
VisualizeButton.TextSize = 14
VisualizeButton.Font = Enum.Font.GothamSemibold
VisualizeButton.Parent = ControlsFrame

local VisualizeUICorner = Instance.new("UICorner")
VisualizeUICorner.CornerRadius = UDim.new(0, 6)
VisualizeUICorner.Parent = VisualizeButton

local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(1, 0, 0, 35)
StatusFrame.Position = UDim2.new(0, 0, 0, 45)
StatusFrame.BackgroundColor3 = CONFIG.COLOR.SECONDARY_BG
StatusFrame.Parent = ControlsFrame

local StatusUICorner = Instance.new("UICorner")
StatusUICorner.CornerRadius = UDim.new(0, 6)
StatusUICorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -10, 1, 0)
StatusLabel.Position = UDim2.new(0, 5, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Disabled"
StatusLabel.TextColor3 = CONFIG.COLOR.TEXT
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFrame

Utility.createButtonAnimation(ToggleButton)
Utility.createButtonAnimation(VisualizeButton)
Utility.createButtonAnimation(CloseButton)

-- GUI Functionality

ToggleButton.MouseButton1Click:Connect(function()
    state.radiusEnabled = not state.radiusEnabled
    
    if state.radiusEnabled then
        ToggleButton.Text = "Disable Radius Audio"
        ToggleButton.BackgroundColor3 = CONFIG.COLOR.SUCCESS
        StatusLabel.Text = "Status: Enabled - Radius: " .. state.currentRadius
    else
        ToggleButton.Text = "Enable Radius Audio"
        ToggleButton.BackgroundColor3 = CONFIG.COLOR.SECONDARY_BG
        StatusLabel.Text = "Status: Disabled"
        
        for _, player in pairs(Players:GetPlayers()) do
            local audio = player:FindFirstChild("AudioDeviceInput")
            if audio then
                audio.Muted = false
            end
            if player.Character then
                HighlightManager.removeHighlight(player.Character)
            end
        end
    end
end)

VisualizeButton.MouseButton1Click:Connect(function()
    local isShowing = VisualRadius.toggle()
    
    if isShowing then
        VisualizeButton.Text = "Hide Radius Sphere"
        VisualizeButton.BackgroundColor3 = CONFIG.COLOR.ACCENT
    else
        VisualizeButton.Text = "Show Radius Sphere"
        VisualizeButton.BackgroundColor3 = CONFIG.COLOR.SECONDARY_BG
    end
end)

RadiusInput.FocusLost:Connect(function(enterPressed)
    local num = tonumber(RadiusInput.Text)
    if num then
        if num < CONFIG.MIN_RADIUS then
            num = CONFIG.MIN_RADIUS
            Utility.showNotification(ScreenGui, "Minimum radius is " .. CONFIG.MIN_RADIUS, "error")
        elseif num > CONFIG.MAX_RADIUS then
            num = CONFIG.MAX_RADIUS
            Utility.showNotification(ScreenGui, "Maximum radius is " .. CONFIG.MAX_RADIUS, "error")
        end
        
        state.currentRadius = num
        RadiusInput.Text = tostring(num)
        
        if state.radiusEnabled then
            StatusLabel.Text = "Status: Enabled - Radius: " .. state.currentRadius
        end
        
        Utility.showNotification(ScreenGui, "Radius set to " .. num, "success")
    else
        RadiusInput.Text = tostring(state.currentRadius)
        Utility.showNotification(ScreenGui, "Please enter a valid number", "error")
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    state.radiusEnabled = false
    
    for _, player in pairs(Players:GetPlayers()) do
        local audio = player:FindFirstChild("AudioDeviceInput")
        if audio then
            audio.Muted = false
        end
        if player.Character then
            HighlightManager.removeHighlight(player.Character)
        end
    end
    
    if state.visualRadiusPart then
        state.visualRadiusPart:Destroy()
    end
    
    ScreenGui:Destroy()
end)

-- Drag & Drop functionality (supports all devices)
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        state.isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                state.isDragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if state.isDragging and input == dragInput then
        updateDrag(input)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F4 then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Helper function to update a new player's character
local function onCharacterAdded(player, character)
    character:WaitForChild("HumanoidRootPart")
    if state.radiusEnabled and LocalPlayer.Character then
        local localRoot = Utility.getCharacterRoot(LocalPlayer.Character)
        local targetRoot = Utility.getCharacterRoot(character)
        if localRoot and targetRoot then
            local distance = (targetRoot.Position - localRoot.Position).Magnitude
            local inRange = distance <= state.currentRadius
            local audio = player:FindFirstChild("AudioDeviceInput")
            if audio then
                audio.Muted = not inRange
            end
            HighlightManager.addHighlight(character, inRange)
        end
    end
end

-- Handle new players joining
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end)

-- Main update loop
RunService.Heartbeat:Connect(function()
    if state.radiusEnabled and LocalPlayer.Character then
        local localRoot = Utility.getCharacterRoot(LocalPlayer.Character)
        if not localRoot then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetRoot = Utility.getCharacterRoot(player.Character)
                if targetRoot then
                    local distance = (targetRoot.Position - localRoot.Position).Magnitude
                    local inRange = distance <= state.currentRadius
                    
                    local audio = player:FindFirstChild("AudioDeviceInput")
                    if audio then
                        audio.Muted = not inRange
                    end
                    
                    if state.radiusEnabled then
                        HighlightManager.addHighlight(player.Character, inRange)
                    end
                end
            end
        end
    end
    VisualRadius.update()
end)

Utility.showNotification(ScreenGui, "Radius Audio Controller loaded", "success")
