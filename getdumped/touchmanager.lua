-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Create GUI Elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProfessionalTouchGUI"
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
titleText.Text = "TouchInterest Manager"
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
searchBox.PlaceholderText = "Search TouchInterests..."
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham
searchBox.Parent = searchBar


-- Scroll Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -135)
scrollFrame.Position = UDim2.new(0, 10, 0, 130)
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
local function createTouchButton(partName, part)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    buttonFrame.BorderSizePixel = 0

    local buttonUICorner = Instance.new("UICorner")
    buttonUICorner.CornerRadius = UDim.new(0, 8)
    buttonUICorner.Parent = buttonFrame

    -- Part Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -100, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = partName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = buttonFrame

    -- Touch Button
    local touchButton = Instance.new("TextButton")
    touchButton.Size = UDim2.new(0, 80, 0, 30)
    touchButton.Position = UDim2.new(1, -90, 0.5, -15)
    touchButton.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    touchButton.BorderSizePixel = 0
    touchButton.Text = "Touch"
    touchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    touchButton.TextSize = 14
    touchButton.Font = Enum.Font.GothamBold
    touchButton.Parent = buttonFrame

    local touchUICorner = Instance.new("UICorner")
    touchUICorner.CornerRadius = UDim.new(0, 6)
    touchUICorner.Parent = touchButton

    -- Hover Effect
    local function updateButtonColor(isHovered)
        local targetColor = isHovered and Color3.fromRGB(96, 165, 250) or Color3.fromRGB(59, 130, 246)
        local tweenInfo = TweenInfo.new(0.2)
        local tween = TweenService:Create(touchButton, tweenInfo, {BackgroundColor3 = targetColor})
        tween:Play()
    end

    touchButton.MouseEnter:Connect(function()
        updateButtonColor(true)
    end)

    touchButton.MouseLeave:Connect(function()
        updateButtonColor(false)
    end)

    -- Simulate Touch
    touchButton.MouseButton1Click:Connect(function()
        local touchInterest = part:FindFirstChild("TouchInterest")
        if touchInterest then
            firetouchinterest(part, player.Character.HumanoidRootPart, 0)
            wait()
            firetouchinterest(part, player.Character.HumanoidRootPart, 1)
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

-- Load TouchInterests
local function loadTouchInterests()
    for _, object in pairs(workspace:GetDescendants()) do
        if object:FindFirstChild("TouchInterest") then
            local button = createTouchButton(object.Name, object)
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


-- Delete All Button
local deleteAllButton = Instance.new("TextButton")
deleteAllButton.Size = UDim2.new(1, -20, 0, 30)
deleteAllButton.Position = UDim2.new(0, 10, 0, 90)
deleteAllButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69) -- Reddish color
deleteAllButton.BorderSizePixel = 0
deleteAllButton.Text = "Delete All TouchInterests"
deleteAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteAllButton.TextSize = 14
deleteAllButton.Font = Enum.Font.GothamBold
deleteAllButton.Parent = mainFrame

local deleteAllUICorner = Instance.new("UICorner")
deleteAllUICorner.CornerRadius = UDim.new(0, 6)
deleteAllUICorner.Parent = deleteAllButton

local function updateDeleteButtonColor(isHovered)
    local targetColor = isHovered and Color3.fromRGB(244, 67, 54) or Color3.fromRGB(220, 53, 69)
    local tweenInfo = TweenInfo.new(0.2)
    local tween = TweenService:Create(deleteAllButton, tweenInfo, {BackgroundColor3 = targetColor})
    tween:Play()
end

deleteAllButton.MouseEnter:Connect(function()
    updateDeleteButtonColor(true)
end)

deleteAllButton.MouseLeave:Connect(function()
    updateDeleteButtonColor(false)
end)


-- Delete All Button Logic
deleteAllButton.MouseButton1Click:Connect(function()
	local allDescendants = workspace:GetDescendants()
	for i = 1, #allDescendants do
        local object = allDescendants[i]
        if object then
			if object:IsA("BasePart") then
				local touchInterest = object:FindFirstChild("TouchInterest")
				if touchInterest then
					touchInterest:Destroy()
				end
                -- Delete also any BasePart that has a name that could be associated with player touch
                local objectNameLower = string.lower(object.Name)
                if string.match(objectNameLower, "touch") or string.match(objectNameLower, "trigger") or string.match(objectNameLower, "area")
                    or string.match(objectNameLower, "damage") or string.match(objectNameLower, "kill") or string.match(objectNameLower, "lava") or string.match(objectNameLower, "acid") then
                   object:Destroy()
                end

            elseif object:IsA("Script") or object:IsA("LocalScript") then
                object:Destroy()
            elseif object:IsA("Fire") or object:IsA("Explosion") or object:IsA("Part") and object.Material == Enum.Material.ForceField then
                --remove any instances that could directly damage you
                object:Destroy()
            end
        end
    end
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end)


-- Initialize
loadTouchInterests()
updateCanvasSize()
