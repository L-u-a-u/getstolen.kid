local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

-- Initialize services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Customizable prefix and suffix characters (Set them here!)
local prefixCharacter = ""  -- **CHANGE THIS to your desired prefix character**
local suffixCharacter = ""  -- **CHANGE THIS to your desired suffix character**

------------------------------------------------------------------
-- Replacement Table

-- Method 1 (Primary) with normal C/c. motherfบcker fบck ⴖigger I'llrареthefบckoutofyou fบckthisِsِhit
local letters = {
    ["A"] = "А", ["a"] = "ล",
    ["B"] = "B", ["b"] = "b",
    ["C"] = "C", ["c"] = "c",  -- C/c set to normal.
    ["D"] = "D", ["d"] = "d",
    ["E"] = "Е", ["e"] = "e",
    ["F"] = "ꜰ", ["f"] = "f",
    ["G"] = "G", ["g"] = "g",
    ["H"] = "H", ["h"] = "һ",
    ["I"] = "Ι", ["i"] = "i",
    ["J"] = "J", ["j"] = "ј",
    ["K"] = "K", ["k"] = "k",
    ["L"] = "L", ["l"] = "ӏ",
    ["M"] = "M", ["m"] = "m",
    ["N"] = "ⴖ", ["n"] = "ⴖ",
    ["O"] = "O", ["o"] = "o",
    ["P"] = "Р", ["p"] = "p",
    ["Q"] = "Q", ["q"] = "q",
    ["R"] = "R", ["r"] = "r",
    ["S"] = "sِ", ["s"] = "sِ",
    ["T"] = "T", ["t"] = "t",
    ["U"] = "U", ["u"] = "บ",  -- U remains normal.
    ["V"] = "V", ["v"] = "v",
    ["W"] = "W", ["w"] = "w",
    ["X"] = "X", ["x"] = "x",
    ["Y"] = "Y", ["y"] = "y",
    ["Z"] = "Z", ["z"] = "z",
    [" "] = "  "
}

------------------------------------------------------------------
-- Utility Functions

local function replace(str, find_str, replace_str)
    local escaped_find_str = find_str:gsub("[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
    return str:gsub(escaped_find_str, replace_str)
end

local function filter(message, tableToUse, prefix, suffix)
    local convertedMessage = message
    for letter, replacement in pairs(tableToUse) do
        convertedMessage = replace(convertedMessage, letter, replacement)
    end
    return prefix .. convertedMessage .. suffix
end

local function showNotification(title, text)
    Notification:Notify(
        {Title = title, Description = text},
        {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 3, Type = "default"}
    )
end

------------------------------------------------------------------
-- Create Main GUI

local GUI = Instance.new("ScreenGui")
GUI.Name = "ProfessionalChatBypass"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 120)
MainFrame.Position = UDim2.new(1, -290, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Changed to black
MainFrame.BackgroundTransparency = 0.3 -- Set transparency to 0.7 (1 - 0.7 = 0.3)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = GUI

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Image = "rbxassetid://6014257812"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.3 -- Shadow darker
Shadow.Parent = MainFrame

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- Darker black for title bar
TitleBar.BackgroundTransparency = 0.3 -- Set transparency to 0.7
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)), -- Darker gradient
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))    -- Pure black
})
TitleGradient.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 28, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Text = "AK CHAT BYPASSER"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -27, 0, 3)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Darker red
CloseButton.BackgroundTransparency = 0.3 -- Set transparency to 0.7
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -54, 0, 3)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 0) -- Darker yellow
MinimizeButton.BackgroundTransparency = 0.3 -- Set transparency to 0.7
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

local InputBox = Instance.new("TextBox")
InputBox.Name = "InputBox"
InputBox.Size = UDim2.new(1, -20, 0, 30)
InputBox.Position = UDim2.new(0, 10, 0, 40)
InputBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Darker input box
InputBox.BackgroundTransparency = 0.3 -- Set transparency to 0.7
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
InputBox.PlaceholderText = "Enter message..."
InputBox.TextSize = 14
InputBox.Font = Enum.Font.Gotham
InputBox.ClearTextOnFocus = true
InputBox.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 4)
InputCorner.Parent = InputBox

local SendButton = Instance.new("TextButton")
SendButton.Name = "SendButton"
SendButton.Size = UDim2.new(0, 180, 0, 26)
SendButton.Position = UDim2.new(0.5, -90, 1, -36)
SendButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark gray for button
SendButton.BackgroundTransparency = 0.3 -- Set transparency to 0.7
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.Text = "Send"
SendButton.TextSize = 14
SendButton.Font = Enum.Font.GothamBold
SendButton.Parent = MainFrame

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 4)
SendCorner.Parent = SendButton

local StatusIndicator = Instance.new("Frame")
StatusIndicator.Name = "StatusIndicator"
StatusIndicator.Size = UDim2.new(0, 6, 0, 6)
StatusIndicator.Position = UDim2.new(0, 12, 0, 12)
StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Darker green
StatusIndicator.BackgroundTransparency = 0.3 -- Set transparency to 0.7
StatusIndicator.Parent = TitleBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusIndicator

------------------------------------------------------------------
-- Utility function for button effects

local function createButtonEffect(button)
    local originalColor = button.BackgroundColor3
    local originalTransparency = button.BackgroundTransparency

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor:Lerp(Color3.fromRGB(50, 50, 50), 0.3),
            BackgroundTransparency = originalTransparency * 0.8
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor,
            BackgroundTransparency = originalTransparency
        }):Play()
    end)

    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = originalTransparency * 0.5
        }):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = originalColor,
            BackgroundTransparency = originalTransparency
        }):Play()
    end)
end

------------------------------------------------------------------
-- Draggable Frame Functionality

local function enableDragging(frame, handle)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            TweenService:Create(frame, tweenInfo, {Position = targetPos}):Play()
        end
    end)
end

------------------------------------------------------------------
-- Minimize Functionality

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 120)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    TweenService:Create(MainFrame, tweenInfo, {Size = targetSize}):Play()
    TweenService:Create(Shadow, tweenInfo, {Size = UDim2.new(1, 30, targetSize.Y.Scale, targetSize.Y.Offset + 30)}):Play()

    InputBox.Visible = not minimized
    SendButton.Visible = not minimized
end)

------------------------------------------------------------------
-- Chat Send Function

local function sendChat(msg)
    local converted = filter(msg, letters, prefixCharacter, suffixCharacter)
    local filteredMessage = game:GetService("Chat"):FilterStringForBroadcast(converted, LocalPlayer)
    
    if filteredMessage ~= converted then
        showNotification("Message Tagged", "Message was filtered - nothing sent")
        InputBox.Text = ""
        return  -- Exit the function without sending
    end

    if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
        ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents").SayMessageRequest:FireServer(converted, "All")
    else
        TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(converted)
    end
    InputBox.Text = ""
end

local function processText()
    local inputText = InputBox.Text
    if inputText ~= "" then
       sendChat(inputText)
    end
end

SendButton.MouseButton1Click:Connect(processText)
InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        processText()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local fadeOut = TweenService:Create(MainFrame, tweenInfo, {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)
    })

    fadeOut.Completed:Connect(function()
        GUI:Destroy()
    end)
    fadeOut:Play()
end)

------------------------------------------------------------------
-- Apply Button Effects

createButtonEffect(SendButton)
createButtonEffect(CloseButton)
createButtonEffect(MinimizeButton)

------------------------------------------------------------------
-- Enable Dragging

enableDragging(MainFrame, TitleBar)

------------------------------------------------------------------
-- Input Box Focus Effects

InputBox.Focused:Connect(function()
    TweenService:Create(InputBox, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 0.2 -- Make slightly more opaque when focused
    }):Play()
end)

InputBox.FocusLost:Connect(function()
    TweenService:Create(InputBox, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = 0.3 -- Back to original transparency
    }):Play()
end)

------------------------------------------------------------------
-- Startup Animation

MainFrame.BackgroundTransparency = 1
Shadow.ImageTransparency = 1
TitleBar.BackgroundTransparency = 1
Title.TextTransparency = 1
CloseButton.BackgroundTransparency = 1
MinimizeButton.BackgroundTransparency = 1
InputBox.BackgroundTransparency = 1
SendButton.BackgroundTransparency = 1
StatusIndicator.BackgroundTransparency = 1

local function fadeIn(duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, tweenInfo, {BackgroundTransparency = 0.3}):Play() -- Set to 0.7 transparency
    TweenService:Create(Shadow, tweenInfo, {ImageTransparency = 0.3}):Play()
    TweenService:Create(TitleBar, tweenInfo, {BackgroundTransparency = 0.3}):Play() -- Set to 0.7 transparency
    TweenService:Create(Title, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(CloseButton, tweenInfo, {BackgroundTransparency = 0.3}):Play() -- Set to 0.7 transparency
    TweenService:Create(MinimizeButton, tweenInfo, {BackgroundTransparency = 0.3}):Play() -- Set to 0.7 transparency
    TweenService:Create(InputBox, tweenInfo, {BackgroundTransparency = 0.3}):Play() -- Set to 0.7 transparency
    TweenService:Create(SendButton, tweenInfo, {BackgroundTransparency = 0.3}):Play() -- Set to 0.7 transparency
    TweenService:Create(StatusIndicator, tweenInfo, {BackgroundTransparency = 0.3}):Play() -- Set to 0.7 transparency
end

local function adjustFramePosition()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local frameSize = MainFrame.AbsoluteSize

    if MainFrame.AbsolutePosition.X + frameSize.X > viewportSize.X then
        MainFrame.Position = UDim2.new(1, -frameSize.X - 10, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)
    end

    if MainFrame.AbsolutePosition.Y + frameSize.Y > viewportSize.Y then
        MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1, -frameSize.Y - 10)
    end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adjustFramePosition)
adjustFramePosition()
fadeIn(0.5)

------------------------------------------------------------------
-- Status Indicator Pulse Animation

spawn(function()
    while wait(1) do
        if not GUI:IsDescendantOf(game:GetService("CoreGui")) then break end
        TweenService:Create(StatusIndicator, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundColor3 = Color3.fromRGB(0, 150, 0),
            BackgroundTransparency = 0.5
        }):Play()
        wait(1)
        TweenService:Create(StatusIndicator, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundColor3 = Color3.fromRGB(0, 150, 0),
            BackgroundTransparency = 0.3
        }):Play()
    end
end)

showNotification("Chat Interface", "Ready to use!")

------------------------------------------------------------------
-- Keyboard Shortcut (Ctrl + M to Minimize)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.M and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        MinimizeButton.MouseButton1Click:Fire()
    end
end)
