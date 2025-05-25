--// Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------
-- Create ScreenGui
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChatSpyGui"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------
-- Main Frame (draggable)
------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 140)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -70)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Rounded corners for mainFrame
local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 10)
mainFrameCorner.Parent = mainFrame

------------------------------------------------------------
-- Title Bar
------------------------------------------------------------
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Rounded corners for TitleBar (top only)
local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 10)
titleBarCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Chat Spy"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Parent = titleBar

------------------------------------------------------------
-- Minimize Button
------------------------------------------------------------
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 1, 0)
minimizeButton.Position = UDim2.new(1, -60, 0, 0)
minimizeButton.Text = "_"
minimizeButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 18
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 5)
minimizeCorner.Parent = minimizeButton

------------------------------------------------------------
-- Close Button
------------------------------------------------------------
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

------------------------------------------------------------
-- Control Frame (contains textbox, labels, buttons)
------------------------------------------------------------
local controlFrame = Instance.new("Frame")
controlFrame.Name = "ControlFrame"
controlFrame.Size = UDim2.new(1, 0, 1, -30)
controlFrame.Position = UDim2.new(0, 0, 0, 30)
controlFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
controlFrame.BorderSizePixel = 0
controlFrame.Parent = mainFrame

-- Rounded corners for controlFrame
local controlFrameCorner = Instance.new("UICorner")
controlFrameCorner.CornerRadius = UDim.new(0, 10)
controlFrameCorner.Parent = controlFrame

------------------------------------------------------------
-- "Player to spy" Label
------------------------------------------------------------
local playerLabel = Instance.new("TextLabel")
playerLabel.Name = "PlayerLabel"
playerLabel.Size = UDim2.new(1, -10, 0, 20)
playerLabel.Position = UDim2.new(0, 5, 0, 5)
playerLabel.BackgroundTransparency = 1
playerLabel.Text = "Player to spy"
playerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerLabel.Font = Enum.Font.SourceSans
playerLabel.TextSize = 16
playerLabel.Parent = controlFrame

------------------------------------------------------------
-- TextBox for entering a player's name
------------------------------------------------------------
local playerTextbox = Instance.new("TextBox")
playerTextbox.Name = "PlayerTextbox"
playerTextbox.Size = UDim2.new(1, -10, 0, 30)
playerTextbox.Position = UDim2.new(0, 5, 0, 30)
playerTextbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
playerTextbox.Text = ""
playerTextbox.ClearTextOnFocus = true
playerTextbox.PlaceholderText = "e.g. Builderman or * for all"
playerTextbox.TextColor3 = Color3.fromRGB(0, 0, 0)
playerTextbox.Font = Enum.Font.SourceSans
playerTextbox.TextSize = 16
playerTextbox.Parent = controlFrame

local textboxCorner = Instance.new("UICorner")
textboxCorner.CornerRadius = UDim.new(0, 5)
textboxCorner.Parent = playerTextbox

------------------------------------------------------------
-- "Start Spying" Button
------------------------------------------------------------
local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Size = UDim2.new(0, 100, 0, 30)
startButton.Position = UDim2.new(0, 5, 0, 65)
startButton.Text = "Start Spying"
startButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.SourceSansBold
startButton.TextSize = 16
startButton.BorderSizePixel = 0
startButton.Parent = controlFrame

local startButtonCorner = Instance.new("UICorner")
startButtonCorner.CornerRadius = UDim.new(0, 5)
startButtonCorner.Parent = startButton

------------------------------------------------------------
-- "Stop All Spying" Button
------------------------------------------------------------
local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0, 100, 0, 30)
stopButton.Position = UDim2.new(0, 110, 0, 65)
stopButton.Text = "Stop All Spying"
stopButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.SourceSansBold
stopButton.TextSize = 16
stopButton.BorderSizePixel = 0
stopButton.Parent = controlFrame

local stopButtonCorner = Instance.new("UICorner")
stopButtonCorner.CornerRadius = UDim.new(0, 5)
stopButtonCorner.Parent = stopButton

------------------------------------------------------------
-- Improved Private Message Detection
------------------------------------------------------------
local function isPrivateMessage(message)
    -- Convert message to lowercase for case-insensitive comparison
    local lowercaseMessage = message:lower()

    -- Check for common private message prefixes
    local privateCommandPrefixes = {
        "/w ", "/whisper ",
        "/e ", "/emote ",
        "/t ", "/team ",
        "/pm ", "/m ", "/message ",
        "/private ", "/p "
    }

    for _, prefix in ipairs(privateCommandPrefixes) do
        if lowercaseMessage:sub(1, #prefix) == prefix then
            return true
        end
    end

    return false
end

------------------------------------------------------------
-- Chat Spying Logic using Chat System Messages (with pcalls)
------------------------------------------------------------
-- Function to send system messages (supports both new and old chat systems)
-- Optional third parameter: messageColor (a Color3). Defaults to white.
local function sendChatSpyMessage(player, message, messageColor)
    messageColor = messageColor or Color3.fromRGB(255, 255, 255)
    -- Convert Color3 to RGB values (0-255)
    local r = math.floor(messageColor.R * 255)
    local g = math.floor(messageColor.G * 255)
    local b = math.floor(messageColor.B * 255)

    -- Format the message: player's name in red (bold) and message in the specified color (bold)
    local playerName = string.format("<font color='rgb(255,0,0)'><b>%s</b></font>", player.Name)
    local fullMessage = string.format("%s: <font color='rgb(%d,%d,%d)'><b>%s</b></font>", playerName, r, g, b, message)

    if TextChatService.TextChannels then -- New chat system
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            pcall(function()
                channel:DisplaySystemMessage(fullMessage)
            end)
            return
        end
    end

    -- Fallback to old chat system
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = player.Name .. ": " .. message,
            Color = messageColor,
            Font = Enum.Font.SourceSansBold,
            TextSize = 24 -- Large text
        })
    end)
end

-- Tables to store spying connections and spied players
local chatConnections = {}
local spiedPlayers = {}
-- Boolean to keep track of toggle state (false = off, true = enabled)
local checkPrivateChat = false -- Default to false, so private chat is not spied on by default

-- Function called when a spied player chats
local function onPlayerChatted(player, msg)
    -- When the Private Chat toggle is off, skip private messages
    if not checkPrivateChat and isPrivateMessage(msg) then
        return
    end
    sendChatSpyMessage(player, msg)  -- Default color (white)
end

-- Function to start spying on a player (or players matching the query)
-- If query is not '*' (wildcard), only the first matching player is spied on.
local function startSpying(query)
    if query and query ~= "" then
        if query == "*" then
            -- Wildcard: spy on all players
            for _, player in ipairs(Players:GetPlayers()) do
                if not spiedPlayers[player.UserId] then
                    local conn = player.Chatted:Connect(function(msg)
                        onPlayerChatted(player, msg)
                    end)
                    chatConnections[player.UserId] = conn
                    spiedPlayers[player.UserId] = player
                    sendChatSpyMessage(player, "Started spying on this player.", Color3.fromRGB(0, 255, 0))
                end
            end
        else
            -- Only take the first matching player (first hit)
            for _, player in ipairs(Players:GetPlayers()) do
                local lowerQuery = string.lower(query)
                local nameMatch = string.find(string.lower(player.Name), lowerQuery)
                local displayNameMatch = string.find(string.lower(player.DisplayName), lowerQuery)
                if nameMatch or displayNameMatch then
                    if not spiedPlayers[player.UserId] then
                        local conn = player.Chatted:Connect(function(msg)
                            onPlayerChatted(player, msg)
                        end)
                        chatConnections[player.UserId] = conn
                        spiedPlayers[player.UserId] = player
                        sendChatSpyMessage(player, "Started spying on this player.", Color3.fromRGB(0, 255, 0))
                    end
                    break  -- Stop after the first match
                end
            end
        end
        playerTextbox.Text = "" -- Clear the textbox after starting
    end
end

-- Function to stop all spying
local function stopSpying()
    for userId, conn in pairs(chatConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    chatConnections = {}
    spiedPlayers = {}
    pcall(function()
        sendChatSpyMessage(LocalPlayer, "Stopped spying on all targets.", Color3.fromRGB(0, 255, 0))
    end)
end

------------------------------------------------------------
-- GUI Button Events
------------------------------------------------------------
startButton.MouseButton1Click:Connect(function()
    local query = playerTextbox.Text
    startSpying(query)
end)

stopButton.MouseButton1Click:Connect(function()
    stopSpying()
end)

--// Title Bar Buttons Functionality
-- Close the GUI
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimize/Restore the GUI
local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        controlFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
    else
        controlFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 300, 0, 140)
    end
end)
