local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create the ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChatLoggerGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Create the main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Add smooth corner radius
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Add subtle drop shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://7912134082"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.Parent = MainFrame

-- Create gradient title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
})
TitleGradient.Parent = TitleBar

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Create title text with icon
local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Size = UDim2.new(0, 16, 0, 16)
TitleIcon.Position = UDim2.new(0, 12, 0, 9)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = "rbxassetid://3926307971"
TitleIcon.ImageRectOffset = Vector2.new(564, 564)
TitleIcon.ImageRectSize = Vector2.new(36, 36)
TitleIcon.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -150, 1, 0)
TitleText.Position = UDim2.new(0, 35, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Chat Logs"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Standardmäßig sollen AKADMINABCDEFGH()-Nachrichten ausgeblendet sein.
local showAKAdmin = false

-- Toggle-Button zum Ein-/Ausblenden von AKADMINABCDEFGH()-Nachrichten 
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Position = UDim2.new(0.5, -50, 0, 5)  -- Mittig im Titelbalken
ToggleButton.Size = UDim2.new(0, 100, 0, 25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "Show AKAdmin"  -- Da die Nachrichten ausgeblendet sind
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 12
ToggleButton.Parent = TitleBar

local ToggleButtonCorner = Instance.new("UICorner")
ToggleButtonCorner.CornerRadius = UDim.new(0, 6)
ToggleButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    showAKAdmin = not showAKAdmin
    if showAKAdmin then
        ToggleButton.Text = "Hide AKAdmin"
    else
        ToggleButton.Text = "Show AKAdmin"
    end
    for _, messageFrame in ipairs(ScrollFrame:GetChildren()) do
        if messageFrame:IsA("Frame") and messageFrame.Name == "AKAdminMessage" then
            messageFrame.Visible = showAKAdmin
        end
    end
end)

-- Create minimize/maximize button
local MinMaxButton = Instance.new("ImageButton")
MinMaxButton.Name = "MinMaxButton"
MinMaxButton.Size = UDim2.new(0, 25, 0, 25)
MinMaxButton.Position = UDim2.new(1, -60, 0, 5)
MinMaxButton.BackgroundTransparency = 1
MinMaxButton.Image = "rbxassetid://3926307971"
MinMaxButton.ImageRectOffset = Vector2.new(404, 284)
MinMaxButton.ImageRectSize = Vector2.new(36, 36)
MinMaxButton.Parent = TitleBar

-- Create close button
local CloseButton = Instance.new("ImageButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Image = "rbxassetid://3926305904"
CloseButton.ImageRectOffset = Vector2.new(284, 4)
CloseButton.ImageRectSize = Vector2.new(24, 24)
CloseButton.Parent = TitleBar

-- Create scroll frame for chat logs
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -16, 1, -45)
ScrollFrame.Position = UDim2.new(0, 8, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ScrollFrame.ScrollBarImageTransparency = 0.5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

-- Padding für den ScrollFrame
local ScrollPadding = Instance.new("UIPadding")
ScrollPadding.PaddingTop = UDim.new(0, 5)
ScrollPadding.PaddingBottom = UDim.new(0, 5)
ScrollPadding.Parent = ScrollFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = ScrollFrame

-- Funktion zum Erstellen eines Chat-Nachrichten-Frames
local function CreateChatMessage(player, message)
    local MessageFrame = Instance.new("Frame")
    MessageFrame.Size = UDim2.new(1, -8, 0, 45)
    MessageFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MessageFrame.BorderSizePixel = 0

    local MessageGradient = Instance.new("UIGradient")
    MessageGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
    })
    MessageGradient.Parent = MessageFrame

    local MessageCorner = Instance.new("UICorner")
    MessageCorner.CornerRadius = UDim.new(0, 6)
    MessageCorner.Parent = MessageFrame

    -- Player Icon
    local PlayerIcon = Instance.new("ImageLabel")
    PlayerIcon.Size = UDim2.new(0, 25, 0, 25)
    PlayerIcon.Position = UDim2.new(0, 8, 0, 10)
    PlayerIcon.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    PlayerIcon.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = PlayerIcon
    PlayerIcon.Parent = MessageFrame

    local PlayerName = Instance.new("TextLabel")
    PlayerName.Size = UDim2.new(1, -130, 0, 20)
    PlayerName.Position = UDim2.new(0, 40, 0, 3)
    PlayerName.BackgroundTransparency = 1
    PlayerName.Text = player.Name
    PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayerName.TextSize = 13
    PlayerName.Font = Enum.Font.GothamBold
    PlayerName.TextXAlignment = Enum.TextXAlignment.Left
    PlayerName.Parent = MessageFrame

    local MessageText = Instance.new("TextLabel")
    MessageText.Size = UDim2.new(1, -130, 0, 20)
    MessageText.Position = UDim2.new(0, 40, 0, 22)
    MessageText.BackgroundTransparency = 1
    MessageText.Text = message
    MessageText.TextColor3 = Color3.fromRGB(200, 200, 200)
    MessageText.TextSize = 12
    MessageText.Font = Enum.Font.Gotham
    MessageText.TextXAlignment = Enum.TextXAlignment.Left
    MessageText.TextWrapped = true
    MessageText.Parent = MessageFrame

    local CopyButton = Instance.new("ImageButton")
    CopyButton.Size = UDim2.new(0, 25, 0, 25)
    CopyButton.Position = UDim2.new(1, -33, 0, 10)
    CopyButton.BackgroundTransparency = 1
    CopyButton.Image = "rbxassetid://3926305904"
    CopyButton.ImageRectOffset = Vector2.new(164, 404)
    CopyButton.ImageRectSize = Vector2.new(36, 36)
    CopyButton.ImageTransparency = 0.4
    CopyButton.Parent = MessageFrame

    CopyButton.MouseEnter:Connect(function()
        TweenService:Create(CopyButton, TweenInfo.new(0.2), {
            ImageTransparency = 0
        }):Play()
    end)

    CopyButton.MouseLeave:Connect(function()
        TweenService:Create(CopyButton, TweenInfo.new(0.2), {
            ImageTransparency = 0.4
        }):Play()
    end)

    CopyButton.MouseButton1Click:Connect(function()
        setclipboard(message)
        local OriginalOffset = CopyButton.ImageRectOffset
        CopyButton.ImageRectOffset = Vector2.new(804, 4) -- Checkmark icon
        wait(1)
        CopyButton.ImageRectOffset = OriginalOffset
    end)

    if message == "AKADMINABCDEFGH()" then
        MessageFrame.Name = "AKAdminMessage"
        MessageFrame.Visible = showAKAdmin   -- Standardmäßig ausgeblendet
    end

    return MessageFrame
end

-- Dragging-Funktionalität für alle Geräte
local function EnableDragging(gui, handle)
    local dragging, dragInput, dragStart, startPos

    local function UpdateInput(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        gui.Position = newPosition
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            UpdateInput(input)
        end
    end)
end

EnableDragging(MainFrame, TitleBar)

-- Minimize/Maximize-Funktionalität
local minimized = false
MinMaxButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 300, 0, 35) or UDim2.new(0, 300, 0, 400)
    local targetClipsDescendants = minimized

    if minimized then
        Corner.Parent = nil
    else
        Corner.Parent = MainFrame
    end

    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = targetSize
    }):Play()

    MainFrame.ClipsDescendants = targetClipsDescendants
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Chat-Ereignis: Nachrichten mit "#" werden nicht angezeigt.
Players.PlayerChatted:Connect(function(chatType, player, message)
    if string.find(message, "#") then
        return
    end

    local chatMessage = CreateChatMessage(player, message)
    chatMessage.Parent = ScrollFrame

    local contentSize = ListLayout.AbsoluteContentSize
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)

    -- Automatisches Runterscrollen aktivieren, wenn der ScrollFrame bereits am unteren Rand ist.
    local canvasY = ScrollFrame.CanvasSize.Y.Offset
    local windowY = ScrollFrame.AbsoluteWindowSize.Y
    local currentY = ScrollFrame.CanvasPosition.Y
    local tolerance = 10

    if currentY >= (canvasY - windowY - tolerance) then
        TweenService:Create(ScrollFrame, TweenInfo.new(0.3), {
            CanvasPosition = Vector2.new(0, contentSize.Y)
        }):Play()
    end
end)

local function onPlayerAdded(player)
    if player == Players.LocalPlayer then
        ScreenGui.Parent = player.PlayerGui
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
