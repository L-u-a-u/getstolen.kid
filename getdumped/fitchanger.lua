local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ModifyUsername_upvr = ReplicatedStorage:WaitForChild("ModifyUsername")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MAIN_COLOR = Color3.fromRGB(41, 53, 68)
local SECONDARY_COLOR = Color3.fromRGB(52, 152, 219)
local BUTTON_COLOR = Color3.fromRGB(46, 204, 113)
local TEXT_COLOR = Color3.fromRGB(236, 240, 241)
local SAVED_FILE = "saved_usernames.txt"
local KEYBIND_FILE = "username_keybinds.txt"

local function createRoundedCornerUI(parent)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = parent
    return uiCorner
end

local function createStroke(parent, color, thickness)
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = color or Color3.fromRGB(255, 255, 255)
    uiStroke.Thickness = thickness or 1
    uiStroke.Parent = parent
    return uiStroke
end

local function saveUsername(username)
    if not pcall(function() readfile(SAVED_FILE) end) then
        writefile(SAVED_FILE, username)
    else
        local existing = readfile(SAVED_FILE)
        if not string.find(existing, username.."\n") and not string.find(existing, "^"..username.."$") then
            writefile(SAVED_FILE, existing.."\n"..username)
        end
    end
end

local function deleteUsername(username)
    if pcall(function() readfile(SAVED_FILE) end) then
        local content = readfile(SAVED_FILE)
        local usernames = {}
        
        for name in string.gmatch(content, "[^\n]+") do
            if name ~= username then
                table.insert(usernames, name)
            end
        end
        
        local newContent = table.concat(usernames, "\n")
        writefile(SAVED_FILE, newContent)
        
        if pcall(function() readfile(KEYBIND_FILE) end) then
            local keybindContent = readfile(KEYBIND_FILE)
            local lines = {}
            
            for line in string.gmatch(keybindContent, "[^\n]+") do
                local storedUsername = line:match("^(.-):")
                if storedUsername ~= username then
                    table.insert(lines, line)
                end
            end
            
            writefile(KEYBIND_FILE, table.concat(lines, "\n"))
        end
    end
end

local function loadUsernames()
    if pcall(function() readfile(SAVED_FILE) end) then
        local content = readfile(SAVED_FILE)
        local usernames = {}
        
        for username in string.gmatch(content, "[^\n]+") do
            if username and username ~= "" then
                table.insert(usernames, username)
            end
        end
        
        return usernames
    else
        return {}
    end
end

local function saveKeybind(username, keyCode)
    local content = ""
    if pcall(function() content = readfile(KEYBIND_FILE) end) then
        local lines = {}
        for line in string.gmatch(content, "[^\n]+") do
            local storedUsername = line:match("^(.-):")
            if storedUsername ~= username then
                table.insert(lines, line)
            end
        end
        content = table.concat(lines, "\n")
        if #content > 0 then content = content .. "\n" end
    end
    
    content = content .. username .. ":" .. tostring(keyCode.Value)
    writefile(KEYBIND_FILE, content)
end

local function getKeybindForUsername(username)
    if pcall(function() readfile(KEYBIND_FILE) end) then
        local content = readfile(KEYBIND_FILE)
        
        for line in string.gmatch(content, "[^\n]+") do
            local storedUsername, keyCodeValue = line:match("^(.-):(%d+)$")
            if storedUsername == username then
                return tonumber(keyCodeValue)
            end
        end
    end
    return nil
end

local function loadKeybinds()
    local keybinds = {}
    if pcall(function() readfile(KEYBIND_FILE) end) then
        local content = readfile(KEYBIND_FILE)
        
        for line in string.gmatch(content, "[^\n]+") do
            local username, keyCodeValue = line:match("^(.-):(%d+)$")
            if username and keyCodeValue then
                keybinds[tonumber(keyCodeValue)] = username
            end
        end
    end
    return keybinds
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UsernameModifierGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0.5, -160, 0.5, -200)
frame.Active = true
frame.Draggable = true
frame.BackgroundColor3 = MAIN_COLOR
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.ZIndex = 2
frame.Parent = screenGui
createRoundedCornerUI(frame)

local originalFrameSize = frame.Size
local originalFramePosition = frame.Position
local isMinimized = false

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, MAIN_COLOR),
    ColorSequenceKeypoint.new(1, MAIN_COLOR:Lerp(Color3.new(0, 0, 0), 0.3))
})
gradient.Rotation = 45
gradient.Parent = frame

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = SECONDARY_COLOR
header.BorderSizePixel = 0
header.ZIndex = 3
header.Parent = frame

local headerCorner = createRoundedCornerUI(header)
headerCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Fit Changer"
title.TextColor3 = TEXT_COLOR
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 4
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -70, 0, 6)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = TEXT_COLOR
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 24
minimizeBtn.ZIndex = 4
minimizeBtn.Parent = header
createRoundedCornerUI(minimizeBtn)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = TEXT_COLOR
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.ZIndex = 4
closeBtn.Parent = header
createRoundedCornerUI(closeBtn)

local inputLabel = Instance.new("TextLabel")
inputLabel.Name = "InputLabel"
inputLabel.Size = UDim2.new(1, -30, 0, 20)
inputLabel.Position = UDim2.new(0, 15, 0, 50)
inputLabel.BackgroundTransparency = 1
inputLabel.Text = "Enter Username:"
inputLabel.TextColor3 = TEXT_COLOR
inputLabel.Font = Enum.Font.Gotham
inputLabel.TextSize = 14
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.ZIndex = 3
inputLabel.Parent = frame

local inputBox = Instance.new("TextBox")
inputBox.Name = "UsernameInput"
inputBox.Size = UDim2.new(1, -30, 0, 36)
inputBox.Position = UDim2.new(0, 15, 0, 75)
inputBox.PlaceholderText = "Username"
inputBox.Text = ""
inputBox.ClearTextOnFocus = false
inputBox.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
inputBox.TextColor3 = TEXT_COLOR
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 16
inputBox.ZIndex = 3
inputBox.Parent = frame
createRoundedCornerUI(inputBox)

local modifyBtn = Instance.new("TextButton")
modifyBtn.Name = "ModifyButton"
modifyBtn.Size = UDim2.new(0.5, -22, 0, 36)
modifyBtn.Position = UDim2.new(0, 15, 0, 125)
modifyBtn.BackgroundColor3 = BUTTON_COLOR
modifyBtn.BorderSizePixel = 0
modifyBtn.Text = "Change Outfit"
modifyBtn.TextColor3 = TEXT_COLOR
modifyBtn.Font = Enum.Font.GothamBold
modifyBtn.TextSize = 16
modifyBtn.ZIndex = 3
modifyBtn.Parent = frame
createRoundedCornerUI(modifyBtn)

local useOwnBtn = Instance.new("TextButton")
useOwnBtn.Name = "UseOwnButton"
useOwnBtn.Size = UDim2.new(0.5, -22, 0, 36)
useOwnBtn.Position = UDim2.new(0.5, 7, 0, 125)
useOwnBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
useOwnBtn.BorderSizePixel = 0
useOwnBtn.Text = "Use My Name"
useOwnBtn.TextColor3 = TEXT_COLOR
useOwnBtn.Font = Enum.Font.GothamBold
useOwnBtn.TextSize = 16
useOwnBtn.ZIndex = 3
useOwnBtn.Parent = frame
createRoundedCornerUI(useOwnBtn)

local saveBtn = Instance.new("TextButton")
saveBtn.Name = "SaveButton"
saveBtn.Size = UDim2.new(1, -30, 0, 36)
saveBtn.Position = UDim2.new(0, 15, 0, 175)
saveBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219) 
saveBtn.BorderSizePixel = 0
saveBtn.Text = "Save Username"
saveBtn.TextColor3 = TEXT_COLOR
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 16
saveBtn.ZIndex = 3
saveBtn.Parent = frame
createRoundedCornerUI(saveBtn)

local savedLabel = Instance.new("TextLabel")
savedLabel.Name = "SavedLabel"
savedLabel.Size = UDim2.new(1, -30, 0, 20)
savedLabel.Position = UDim2.new(0, 15, 0, 225)
savedLabel.BackgroundTransparency = 1
savedLabel.Text = "Saved Usernames:"
savedLabel.TextColor3 = TEXT_COLOR
savedLabel.Font = Enum.Font.GothamBold
savedLabel.TextSize = 14
savedLabel.TextXAlignment = Enum.TextXAlignment.Left
savedLabel.ZIndex = 3
savedLabel.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "SavedUsernames"
scrollFrame.Size = UDim2.new(1, -30, 0, 140)
scrollFrame.Position = UDim2.new(0, 15, 0, 245)
scrollFrame.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
scrollFrame.BackgroundTransparency = 0
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ZIndex = 3
scrollFrame.Parent = frame
createRoundedCornerUI(scrollFrame)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

local keybindModal = Instance.new("Frame")
keybindModal.Name = "KeybindModal"
keybindModal.Size = UDim2.new(0, 250, 0, 120)
keybindModal.Position = UDim2.new(0.5, -125, 0.5, -60)
keybindModal.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
keybindModal.BorderSizePixel = 0
keybindModal.Visible = false
keybindModal.ZIndex = 10
keybindModal.Parent = screenGui
createRoundedCornerUI(keybindModal)

local modalBlocker = Instance.new("Frame")
modalBlocker.Name = "ModalBlocker"
modalBlocker.Size = UDim2.new(1, 0, 1, 0)
modalBlocker.Position = UDim2.new(0, 0, 0, 0)
modalBlocker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
modalBlocker.BackgroundTransparency = 0.5
modalBlocker.BorderSizePixel = 0
modalBlocker.Visible = false
modalBlocker.ZIndex = 9
modalBlocker.Parent = screenGui

local keybindTitle = Instance.new("TextLabel")
keybindTitle.Name = "KeybindTitle"
keybindTitle.Size = UDim2.new(1, 0, 0, 30)
keybindTitle.Position = UDim2.new(0, 0, 0, 0)
keybindTitle.BackgroundColor3 = SECONDARY_COLOR
keybindTitle.Text = "Set Keybind"
keybindTitle.TextColor3 = TEXT_COLOR
keybindTitle.Font = Enum.Font.GothamBold
keybindTitle.TextSize = 16
keybindTitle.ZIndex = 11
keybindTitle.Parent = keybindModal
createRoundedCornerUI(keybindTitle)

local keybindInstructions = Instance.new("TextLabel")
keybindInstructions.Name = "KeybindInstructions"
keybindInstructions.Size = UDim2.new(1, -20, 0, 40)
keybindInstructions.Position = UDim2.new(0, 10, 0, 40)
keybindInstructions.BackgroundTransparency = 1
keybindInstructions.Text = "Press any key to set as keybind..."
keybindInstructions.TextColor3 = TEXT_COLOR
keybindInstructions.Font = Enum.Font.Gotham
keybindInstructions.TextSize = 14
keybindInstructions.TextWrapped = true
keybindInstructions.ZIndex = 11
keybindInstructions.Parent = keybindModal

local cancelKeybindBtn = Instance.new("TextButton")
cancelKeybindBtn.Name = "CancelKeybindButton"
cancelKeybindBtn.Size = UDim2.new(1, -20, 0, 30)
cancelKeybindBtn.Position = UDim2.new(0, 10, 0, 80)
cancelKeybindBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
cancelKeybindBtn.BorderSizePixel = 0
cancelKeybindBtn.Text = "Cancel"
cancelKeybindBtn.TextColor3 = TEXT_COLOR
cancelKeybindBtn.Font = Enum.Font.GothamBold
cancelKeybindBtn.TextSize = 14
cancelKeybindBtn.ZIndex = 11
cancelKeybindBtn.Parent = keybindModal
createRoundedCornerUI(cancelKeybindBtn)

local function showNotification(message, color)
    local notification = Instance.new("TextLabel")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, -30, 0, 30)
    notification.Position = UDim2.new(0, 15, 1, -40)
    notification.BackgroundColor3 = color or Color3.fromRGB(46, 204, 113)
    notification.Text = message
    notification.TextColor3 = TEXT_COLOR
    notification.Font = Enum.Font.GothamBold
    notification.TextSize = 14
    notification.ZIndex = 5
    notification.Parent = frame
    createRoundedCornerUI(notification)
    
    delay(2, function()
        for i = 1, 10 do
            notification.BackgroundTransparency = i/10
            notification.TextTransparency = i/10
            wait(0.05)
        end
        notification:Destroy()
    end)
end

local currentKeybindUsername = nil
local function showKeybindModal(username)
    currentKeybindUsername = username
    keybindTitle.Text = "Set Keybind for: " .. username
    keybindModal.Visible = true
    modalBlocker.Visible = true
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            saveKeybind(username, input.KeyCode)
            keybindModal.Visible = false
            modalBlocker.Visible = false
            showNotification("Keybind set for " .. username .. ": " .. input.KeyCode.Name, Color3.fromRGB(52, 152, 219))
            connection:Disconnect()
            updateSavedUsernamesList()
        end
    end)
    
    local cancelConn
    cancelConn = cancelKeybindBtn.MouseButton1Click:Connect(function()
        keybindModal.Visible = false
        modalBlocker.Visible = false
        connection:Disconnect()
        cancelConn:Disconnect()
    end)
end

local function updateSavedUsernamesList()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local usernames = loadUsernames()
    
    for i, username in ipairs(usernames) do
        local usernameContainer = Instance.new("Frame")
        usernameContainer.Name = "UsernameContainer_" .. i
        usernameContainer.Size = UDim2.new(1, -10, 0, 30)
        usernameContainer.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
        usernameContainer.BorderSizePixel = 0
        usernameContainer.LayoutOrder = i
        usernameContainer.ZIndex = 4
        usernameContainer.Parent = scrollFrame
        createRoundedCornerUI(usernameContainer)
        
        local usernameLabel = Instance.new("TextLabel")
        usernameLabel.Name = "UsernameLabel"
        usernameLabel.Size = UDim2.new(0.45, -5, 1, 0)
        usernameLabel.Position = UDim2.new(0, 5, 0, 0)
        usernameLabel.BackgroundTransparency = 1
        usernameLabel.Text = username
        usernameLabel.TextColor3 = TEXT_COLOR
        usernameLabel.Font = Enum.Font.Gotham
        usernameLabel.TextSize = 14
        usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
        usernameLabel.ZIndex = 5
        usernameLabel.Parent = usernameContainer
        
        local keyCodeValue = getKeybindForUsername(username)
        local keybindText = "Set Key"
        
        if keyCodeValue then
            for _, enum in pairs(Enum.KeyCode:GetEnumItems()) do
                if enum.Value == keyCodeValue then
                    keybindText = enum.Name
                    break
                end
            end
        end
        
        local keybindButton = Instance.new("TextButton")
        keybindButton.Name = "KeybindButton"
        keybindButton.Size = UDim2.new(0.25, -5, 1, -6)
        keybindButton.Position = UDim2.new(0.45, 0, 0, 3)
        keybindButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
        keybindButton.BorderSizePixel = 0
        keybindButton.Text = keybindText
        keybindButton.TextColor3 = TEXT_COLOR
        keybindButton.Font = Enum.Font.Gotham
        keybindButton.TextSize = 12
        keybindButton.ZIndex = 5
        keybindButton.Parent = usernameContainer
        createRoundedCornerUI(keybindButton)
        
        local deleteButton = Instance.new("TextButton")
        deleteButton.Name = "DeleteButton"
        deleteButton.Size = UDim2.new(0.25, -5, 1, -6)
        deleteButton.Position = UDim2.new(0.7, 0, 0, 3)
        deleteButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        deleteButton.BorderSizePixel = 0
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = TEXT_COLOR
        deleteButton.Font = Enum.Font.Gotham
        deleteButton.TextSize = 12
        deleteButton.ZIndex = 5
        deleteButton.Parent = usernameContainer
        createRoundedCornerUI(deleteButton)
        
        usernameContainer.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                inputBox.Text = username
            end
        end)
        
        keybindButton.MouseButton1Click:Connect(function()
            showKeybindModal(username)
        end)
        
        deleteButton.MouseButton1Click:Connect(function()
            deleteUsername(username)
            updateSavedUsernamesList()
            showNotification("Deleted username: " .. username, Color3.fromRGB(231, 76, 60))
        end)
        
        usernameContainer.MouseEnter:Connect(function()
            TweenService:Create(usernameContainer, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(52, 73, 94):Lerp(Color3.new(1, 1, 1), 0.1)
            }):Play()
        end)
        
        usernameContainer.MouseLeave:Connect(function()
            TweenService:Create(usernameContainer, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(52, 73, 94)
            }):Play()
        end)
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
end

minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        TweenService:Create(frame, TweenInfo.new(0.3), {
            Size = originalFrameSize,
            Position = originalFramePosition
        }):Play()
        
        for _, child in pairs(frame:GetChildren()) do
            if child.Name ~= "Header" and child:IsA("GuiObject") then
                child.Visible = true
            end
        end
        
        minimizeBtn.Text = "−"
    else
        TweenService:Create(frame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 320, 0, 40),
            Position = UDim2.new(0.5, -160, 0, 0)
        }):Play()
        
        for _, child in pairs(frame:GetChildren()) do
            if child.Name ~= "Header" and child:IsA("GuiObject") then
                child.Visible = false
            end
        end
        
        minimizeBtn.Text = "+"
    end
    
    isMinimized = not isMinimized
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

modifyBtn.MouseButton1Click:Connect(function()
    local newUsername = inputBox.Text
    if newUsername == nil or newUsername == "" then
        showNotification("Please enter a valid username", Color3.fromRGB(231, 76, 60))
        return
    end
    
    ModifyUsername_upvr:FireServer(newUsername)
    showNotification("Outfit changed to " .. newUsername)
end)

useOwnBtn.MouseButton1Click:Connect(function()
    local myUsername = player.Name
    inputBox.Text = myUsername
    showNotification("Set to your username: " .. myUsername)
end)

saveBtn.MouseButton1Click:Connect(function()
    local newUsername = inputBox.Text
    if newUsername == nil or newUsername == "" then
        showNotification("Please enter a valid username", Color3.fromRGB(231, 76, 60))
        return
    end
    
    pcall(function()
        saveUsername(newUsername)
        updateSavedUsernamesList()
        showNotification("Username saved successfully")
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Return and inputBox:IsFocused() then
        ModifyUsername_upvr:FireServer(inputBox.Text)
        showNotification("Outfit changed to " .. inputBox.Text)
    else
        local keybinds = loadKeybinds()
        local username = keybinds[input.KeyCode.Value]
        
        if username then
            ModifyUsername_upvr:FireServer(username)
            showNotification("Outfit changed to " .. username .. " (Keybind: " .. input.KeyCode.Name .. ")")
        end
    end
end)

for _, button in pairs({modifyBtn, useOwnBtn, saveBtn, minimizeBtn}) do
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.2)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        local originalColor
        if button.Name == "ModifyButton" then
            originalColor = BUTTON_COLOR
        elseif button.Name == "UseOwnButton" then
            originalColor = Color3.fromRGB(142, 68, 173)
        elseif button.Name == "MinimizeButton" then
            originalColor = Color3.fromRGB(241, 196, 15)
        else
            originalColor = Color3.fromRGB(52, 152, 219)
        end
        
        TweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
end

updateSavedUsernamesList()
