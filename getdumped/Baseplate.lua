-- Initialize services and variables
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Create or get folder for baseplates
local baseplateFolder = Workspace:FindFirstChild("InfiniteBaseplates")
if not baseplateFolder then
    baseplateFolder = Instance.new("Folder")
    baseplateFolder.Name = "InfiniteBaseplates"
    baseplateFolder.Parent = Workspace
end

-- Define baseplate size and spacing
local baseplateSize = 2000  -- Each baseplate is 2000x2000 studs
local baseplateSpacing = 0  -- No gap between baseplates

-- Table to keep track of created baseplates by grid key (e.g. "X,Z")
local baseplateGrid = {}

-- Selected color (default grey)
local selectedColor = Color3.fromRGB(128, 128, 128)

-- Variables for freezing and restoring the avatar
local frozen = false
local originalAnchoredStates = {}  -- Table to store each BasePart's original Anchored state

-- Function to create a baseplate at a specific position with a transparent smooth look
local function addGrassBaseplate(position)
    local key = tostring(position.X) .. "," .. tostring(position.Z)
    if baseplateGrid[key] then return end

    print("Creating baseplate at position: " .. tostring(position))
    local grassBaseplate = Instance.new("Part")
    grassBaseplate.Name = "GrassBaseplate"
    grassBaseplate.Size = Vector3.new(baseplateSize, 0.05, baseplateSize)
    grassBaseplate.Anchored = true
    grassBaseplate.Material = Enum.Material.SmoothPlastic
    grassBaseplate.Color = selectedColor
    grassBaseplate.Position = position
    grassBaseplate.Transparency = 0.5
    grassBaseplate.CanCollide = true
    grassBaseplate.Parent = baseplateFolder
    
    baseplateGrid[key] = grassBaseplate
end

-- Function to create a grid of baseplates around the player
local function createBaseplatesAroundPlayer()
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local playerPosition = character.HumanoidRootPart.Position
    local sizeMultiplier = baseplateSize + baseplateSpacing
    
    for x = -1, 1 do
        for z = -1, 1 do
            local posX = math.floor(playerPosition.X / sizeMultiplier) * sizeMultiplier + (x * sizeMultiplier)
            local posZ = math.floor(playerPosition.Z / sizeMultiplier) * sizeMultiplier + (z * sizeMultiplier)
            local position = Vector3.new(posX, 0, posZ)
            addGrassBaseplate(position)
        end
    end
end

-- Function to freeze the entire avatar by anchoring all BaseParts
local function freezeAvatar()
    local character = Player.Character
    if character then
        originalAnchoredStates = {}  -- Reset the table
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(originalAnchoredStates, {part = part, wasAnchored = part.Anchored})
                part.Anchored = true
            end
        end
        frozen = true
    end
end

-- Function to unfreeze the avatar by restoring each BasePart's original anchored state
local function unfreezeAvatar()
    for _, info in ipairs(originalAnchoredStates) do
        if info.part and info.part.Parent then
            info.part.Anchored = info.wasAnchored
        end
    end
    frozen = false
end

-- Function to create a professional color selection GUI
local function createColorSelectionGUI()
    -- Remove any existing GUIs first
    for _, gui in ipairs(Player.PlayerGui:GetChildren()) do
        if gui.Name == "BaseplateColorGUI" then
            gui:Destroy()
        end
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BaseplateColorGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player.PlayerGui
    
    local backgroundBlur = Instance.new("Frame")
    backgroundBlur.Name = "BackgroundBlur"
    backgroundBlur.Size = UDim2.new(1, 0, 1, 0)
    backgroundBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundBlur.BackgroundTransparency = 0.5
    backgroundBlur.BorderSizePixel = 0
    backgroundBlur.ZIndex = 10
    backgroundBlur.Parent = ScreenGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "ColorSelectionFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 430)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -215)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 11
    
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = mainFrame
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.ZIndex = 10
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = mainFrame
    
    mainFrame.Parent = ScreenGui
    
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.Size = UDim2.new(1, 0, 0, 60)
    titleContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleContainer.BorderSizePixel = 0
    titleContainer.ZIndex = 12
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleContainer
    
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Size = UDim2.new(1, 0, 0.5, 0)
    bottomFrame.Position = UDim2.new(0, 0, 0.5, 0)
    bottomFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bottomFrame.BorderSizePixel = 0
    bottomFrame.ZIndex = 11
    bottomFrame.Parent = titleContainer
    
    titleContainer.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Baseplate Color Selection"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleContainer
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 20)
    subtitle.Position = UDim2.new(0, 20, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Choose a color for your infinite baseplate"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.Gotham
    subtitle.ZIndex = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = mainFrame
    
    local colors = {
        {name = "Slate Grey", color = Color3.fromRGB(128, 128, 128)},
        {name = "Forest Green", color = Color3.fromRGB(34, 139, 34)},
        {name = "Royal Blue", color = Color3.fromRGB(65, 105, 225)},
        {name = "Crimson Red", color = Color3.fromRGB(220, 20, 60)},
        {name = "Golden Yellow", color = Color3.fromRGB(255, 215, 0)},
        {name = "Deep Purple", color = Color3.fromRGB(128, 0, 128)},
        {name = "Sunset Orange", color = Color3.fromRGB(255, 94, 77)},
        {name = "Emerald Green", color = Color3.fromRGB(80, 200, 120)},
        {name = "Electric Purple", color = Color3.fromRGB(191, 0, 255)},
        {name = "Aqua Blue", color = Color3.fromRGB(0, 255, 255)}
    }
    
    local colorContainer = Instance.new("Frame")
    colorContainer.Name = "ColorContainer"
    colorContainer.Size = UDim2.new(1, -40, 0, 270)
    colorContainer.Position = UDim2.new(0, 20, 0, 100)
    colorContainer.BackgroundTransparency = 1
    colorContainer.ZIndex = 12
    colorContainer.Parent = mainFrame
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.333, -10, 0, 60)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = colorContainer
    
    local confirmButton
    
    for i, colorInfo in ipairs(colors) do
        local button = Instance.new("Frame")
        button.Name = colorInfo.name
        button.BackgroundColor3 = colorInfo.color
        button.BorderSizePixel = 0
        button.ZIndex = 13
        button.LayoutOrder = i
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0.5, 0)
        label.BackgroundTransparency = 0.6
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Text = colorInfo.name
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.ZIndex = 14
        local labelCorner = Instance.new("UICorner")
        labelCorner.CornerRadius = UDim.new(0, 4)
        labelCorner.Parent = label
        label.Parent = button
        
        local clickDetector = Instance.new("TextButton")
        clickDetector.Size = UDim2.new(1, 0, 1, 0)
        clickDetector.BackgroundTransparency = 1
        clickDetector.Text = ""
        clickDetector.ZIndex = 15
        clickDetector.Parent = button
        
        local selectionIndicator = Instance.new("Frame")
        selectionIndicator.Name = "SelectionIndicator"
        selectionIndicator.Size = UDim2.new(1, 4, 1, 4)
        selectionIndicator.Position = UDim2.new(0, -2, 0, -2)
        selectionIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        selectionIndicator.BorderSizePixel = 0
        selectionIndicator.ZIndex = 12
        selectionIndicator.Visible = false
        local selectionCorner = Instance.new("UICorner")
        selectionCorner.CornerRadius = UDim.new(0, 8)
        selectionCorner.Parent = selectionIndicator
        selectionIndicator.Parent = button
        
        clickDetector.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 5)}):Play()
        end)
        
        clickDetector.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        end)
        
        clickDetector.MouseButton1Click:Connect(function()
            for _, otherButton in ipairs(colorContainer:GetChildren()) do
                if otherButton:IsA("Frame") and otherButton:FindFirstChild("SelectionIndicator") then
                    otherButton.SelectionIndicator.Visible = false
                end
            end
            selectionIndicator.Visible = true
            selectedColor = colorInfo.color
            
            if confirmButton then
                local confirmTween = TweenService:Create(confirmButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(46, 204, 113)})
                confirmTween:Play()
            end
        end)
        
        button.Parent = colorContainer
        
        if colorInfo.color == selectedColor then
            selectionIndicator.Visible = true
        end
    end
    
    confirmButton = Instance.new("TextButton")
    confirmButton.Name = "ConfirmButton"
    confirmButton.Size = UDim2.new(0, 200, 0, 40)
    confirmButton.Position = UDim2.new(0.5, -100, 1, -60)
    confirmButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    confirmButton.BorderSizePixel = 0
    confirmButton.Text = "Confirm Selection"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.TextSize = 16
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.ZIndex = 13
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 8)
    confirmCorner.Parent = confirmButton
    
    confirmButton.MouseEnter:Connect(function()
        TweenService:Create(confirmButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 210, 0, 45), Position = UDim2.new(0.5, -105, 1, -62)}):Play()
    end)
    
    confirmButton.MouseLeave:Connect(function()
        TweenService:Create(confirmButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 40), Position = UDim2.new(0.5, -100, 1, -60)}):Play()
    end)
    
    confirmButton.MouseButton1Click:Connect(function()
        -- Freeze the avatar by anchoring all its BaseParts
        freezeAvatar()
        
        -- Animate GUI fade out and closing
        local fadeOutTween = TweenService:Create(backgroundBlur, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        fadeOutTween:Play()
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -200, 1.5, 0)}):Play()
        
        -- Remove all existing baseplates and reset grid
        for _, part in ipairs(baseplateFolder:GetChildren()) do
            if part.Name == "GrassBaseplate" then
                part:Destroy()
            end
        end
        baseplateGrid = {}
        
        -- Start generating new baseplates with the selected color
        spawn(function()
            wait(0.5)
            ScreenGui:Destroy()
            spawn(function() 
                while wait(1) do
                    createBaseplatesAroundPlayer()
                end
            end)
            
            -- Wait until a new baseplate with the selected color appears, then unfreeze the avatar
            spawn(function()
                while true do
                    wait(0.1)
                    local found = false
                    for _, baseplate in ipairs(baseplateFolder:GetChildren()) do
                        if baseplate.Name == "GrassBaseplate" and baseplate.Color == selectedColor then
                            found = true
                            break
                        end
                    end
                    if found then break end
                end
                unfreezeAvatar()
            end)
        end)
    end)
    
    confirmButton.Parent = mainFrame
    
    -- Animate GUI opening
    mainFrame.Position = UDim2.new(0.5, -200, -0.5, 0)
    backgroundBlur.BackgroundTransparency = 1
    TweenService:Create(backgroundBlur, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -200, 0.5, -215)}):Play()
end

-- Always show the color selection GUI on execution
createColorSelectionGUI()
