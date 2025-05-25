-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Create GUI Elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProfessionalRemoteGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:WaitForChild("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add rounded corners
local mainUICorner = Instance.new("UICorner")
mainUICorner.CornerRadius = UDim.new(0, 10)
mainUICorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleUICorner = Instance.new("UICorner")
titleUICorner.CornerRadius = UDim.new(0, 10)
titleUICorner.Parent = titleBar

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Remote Event Manager"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button
local closeButton = Instance.new("ImageButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -32, 0, 8)
closeButton.BackgroundTransparency = 1
closeButton.Image = "rbxassetid://7743878857"
closeButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = titleBar

-- Search Bar
local searchBar = Instance.new("Frame")
searchBar.Size = UDim2.new(1, -20, 0, 35)
searchBar.Position = UDim2.new(0, 10, 0, 50)
searchBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
searchBar.BorderSizePixel = 0
searchBar.Parent = mainFrame

local searchUICorner = Instance.new("UICorner")
searchUICorner.CornerRadius = UDim.new(0, 8)
searchUICorner.Parent = searchBar

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -16, 1, -8)
searchBox.Position = UDim2.new(0, 8, 0, 4)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Search RemoteEvents..."
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham
searchBox.Parent = searchBar

-- Scroll Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -100)
scrollFrame.Position = UDim2.new(0, 10, 0, 95)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.Parent = mainFrame

-- List Layout
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

-- Padding
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)
padding.Parent = scrollFrame

-- Functions
local function createArgumentInput(parent, placeholder)
    local argFrame = Instance.new("Frame")
    argFrame.Size = UDim2.new(1, 0, 0, 30)
    argFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    argFrame.BorderSizePixel = 0
    
    local argUICorner = Instance.new("UICorner")
    argUICorner.CornerRadius = UDim.new(0, 6)
    argUICorner.Parent = argFrame
    
    local argInput = Instance.new("TextBox")
    argInput.Size = UDim2.new(1, -16, 1, -8)
    argInput.Position = UDim2.new(0, 8, 0, 4)
    argInput.BackgroundTransparency = 1
    argInput.Text = ""
    argInput.PlaceholderText = placeholder
    argInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    argInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    argInput.TextSize = 14
    argInput.Font = Enum.Font.Gotham
    argInput.Parent = argFrame
    
    return argFrame, argInput
end

local function createRemoteButton(remoteName)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 110)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    buttonFrame.BorderSizePixel = 0
    
    local buttonUICorner = Instance.new("UICorner")
    buttonUICorner.CornerRadius = UDim.new(0, 8)
    buttonUICorner.Parent = buttonFrame
    
    -- Remote Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 20)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = remoteName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = buttonFrame
    
    -- Argument Container
    local argContainer = Instance.new("Frame")
    argContainer.Size = UDim2.new(1, -20, 0, 60)
    argContainer.Position = UDim2.new(0, 10, 0, 30)
    argContainer.BackgroundTransparency = 1
    argContainer.Parent = buttonFrame
    
    local arg1Frame, arg1Input = createArgumentInput(argContainer, "Enter argument 1...")
    arg1Frame.Size = UDim2.new(1, -90, 0, 30)
    arg1Frame.Parent = argContainer
    
    local arg2Frame, arg2Input = createArgumentInput(argContainer, "Enter argument 2...")
    arg2Frame.Size = UDim2.new(1, -90, 0, 30)
    arg2Frame.Position = UDim2.new(0, 0, 0, 35)
    arg2Frame.Parent = argContainer
    
    -- Fire Button
    local fireButton = Instance.new("TextButton")
    fireButton.Size = UDim2.new(0, 80, 0, 60)
    fireButton.Position = UDim2.new(1, -80, 0, 0)
    fireButton.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    fireButton.BorderSizePixel = 0
    fireButton.Text = "Fire"
    fireButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fireButton.TextSize = 14
    fireButton.Font = Enum.Font.GothamBold
    fireButton.Parent = argContainer
    
    local fireUICorner = Instance.new("UICorner")
    fireUICorner.CornerRadius = UDim.new(0, 6)
    fireUICorner.Parent = fireButton
    
    -- Hover Effect
    local function updateButtonColor(isHovered)
        local targetColor = isHovered and Color3.fromRGB(96, 165, 250) or Color3.fromRGB(59, 130, 246)
        local tweenInfo = TweenInfo.new(0.2)
        local tween = TweenService:Create(fireButton, tweenInfo, {BackgroundColor3 = targetColor})
        tween:Play()
    end
    
    fireButton.MouseEnter:Connect(function()
        updateButtonColor(true)
    end)
    
    fireButton.MouseLeave:Connect(function()
        updateButtonColor(false)
    end)
    
    -- Fire RemoteEvent
    fireButton.MouseButton1Click:Connect(function()
        local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        if remote and remote:IsA("RemoteEvent") then
            local args = {}
            for _, input in ipairs({arg1Input, arg2Input}) do
                local arg = input.Text
                local convertedArg = arg
                if tonumber(arg) then
                    convertedArg = tonumber(arg)
                elseif arg == "true" then
                    convertedArg = true
                elseif arg == "false" then
                    convertedArg = false
                end
                table.insert(args, convertedArg)
            end
            
            pcall(function()
                remote:FireServer(unpack(args))
            end)
        end
    end)
    
    return buttonFrame
end

-- Make GUI draggable
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Search functionality
local function updateSearch()
    local searchText = string.lower(searchBox.Text)
    for _, button in pairs(scrollFrame:GetChildren()) do
        if button:IsA("Frame") then
            local nameLabel = button:FindFirstChild("TextLabel")
            if nameLabel then
                button.Visible = string.find(string.lower(nameLabel.Text), searchText) ~= nil
            end
        end
    end
end

searchBox.Changed:Connect(function(prop)
    if prop == "Text" then
        updateSearch()
    end
end)

-- Load RemoteEvents
local function loadRemoteEvents()
    for _, object in pairs(ReplicatedStorage:GetDescendants()) do
        if object:IsA("RemoteEvent") then
            local button = createRemoteButton(object.Name)
            button.Parent = scrollFrame
        end
    end
end

-- Update ScrollFrame canvas size
local function updateCanvasSize()
    local contentSize = listLayout.AbsoluteContentSize
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 10)
end

scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

-- Monitor for new RemoteEvents
ReplicatedStorage.DescendantAdded:Connect(function(object)
    if object:IsA("RemoteEvent") then
        local button = createRemoteButton(object.Name)
        button.Parent = scrollFrame
        updateCanvasSize()
    end
end)

-- Initialize
loadRemoteEvents()
updateCanvasSize()
