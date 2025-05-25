local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local INVISIBLE_CHAR = "\u{001E}"
local NEWLINE = "\u{000D}"
local PRESET_FILE_NAME = "drawing_presets.json"

-- Create a table to store presets
local presets = {}

local function chatMessage(str)
    str = tostring(str)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.TextChannels.RBXGeneral:SendAsync(str)
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
    end
end

local function createButton(text, parent, size, position, backgroundColor)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = backgroundColor or Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.AutoButtonColor = true
    button.Parent = parent

    -- Create rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    -- Add hover effect
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = backgroundColor and backgroundColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2) or Color3.fromRGB(80, 80, 80)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = originalColor
        }):Play()
    end)

    return button
end

local function addShadow(frame)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://297774371"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = frame
end

local drawingGui = nil
local selectedEmoji = "❓"
local interfaceEnabled = false -- Keep track of the UI state
local savedGrid = {}  -- Table to store the grid between sessions
local actionBound = false -- Prevent double binding of ContextAction
local drawing = false


-- Function to save presets to a file
local function savePresetsToFile()
	local success, errorMessage = pcall(function()
		local jsonString = HttpService:JSONEncode(presets)
		writefile(PRESET_FILE_NAME, jsonString)
	end)
    if not success then
        warn("Error saving presets:", errorMessage)
    end
end

-- Function to load presets from a file
local function loadPresetsFromFile()
    local success, fileContent = pcall(function()
        return readfile(PRESET_FILE_NAME)
    end)
	
    if success and fileContent then
        local decodeSuccess, decodedData = pcall(function()
            return HttpService:JSONDecode(fileContent)
        end)
        
        if decodeSuccess and decodedData then
            presets = decodedData
        else
            warn("Error decoding presets: ", decodedData)
        end
    else
        warn("Error loading or reading the file:", fileContent)
    end
end

local function createDrawingInterface()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DrawingInterface"
	gui.DisplayOrder = 2 -- Ensure it's on top
    gui.ResetOnSpawn = false -- Prevent reset on respawn
    gui.Parent = CoreGui

    local isTouchEnabled = UserInputService.TouchEnabled

    -- Determine scale based on platform
    local mainFrameScale = isTouchEnabled and 0.7 or 1
	
	local baseWidth = 300
	local baseHeight = 490
	local baseX = -150
	local baseY = -245

	
	local scaledWidth = baseWidth * mainFrameScale
	local scaledHeight = baseHeight * mainFrameScale
	local scaledX = baseX * mainFrameScale
	local scaledY = baseY * mainFrameScale


    local mainFrame = Instance.new("Frame")

    -- Main frame (matches dark theme in image)
    mainFrame.Size = UDim2.new(0, scaledWidth, 0, scaledHeight)  -- Increased height
    mainFrame.Position = UDim2.new(0.5, scaledX, 0.5, scaledY)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    -- Add rounded corners to main frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10 * mainFrameScale)
    corner.Parent = mainFrame

    addShadow(mainFrame)

     -- Title bar
    local titleBarHeight = 30 * mainFrameScale
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    -- Add rounded corners to title bar
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10 * mainFrameScale)
    titleCorner.Parent = titleBar


     -- Title text
    local titleTextOffset = 10 * mainFrameScale
    local titleText = Instance.new("TextLabel")
    titleText.Text = "Drawing Interface"
    titleText.Size = UDim2.new(1, -40 * mainFrameScale, 1, 0)
    titleText.Position = UDim2.new(0, titleTextOffset, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.Gotham
    titleText.TextSize = 14 * mainFrameScale
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Close button (red X in corner)
    local closeButtonSize = 30 * mainFrameScale
    local closeButtonOffset = -30 * mainFrameScale
    local closeButton = createButton("X", titleBar, UDim2.new(0, closeButtonSize, 0, closeButtonSize), UDim2.new(1, closeButtonOffset, 0, 0), Color3.fromRGB(220, 50, 50))
    closeButton.MouseButton1Click:Connect(function()
        gui.Enabled = false
        interfaceEnabled = false
    end)

    -- Grid setup
    local GRID_SIZE = 7
    local CELL_SIZE = 35 * mainFrameScale
    local grid = {}
    local cells = {}
	
	local gridOffsetX = -(GRID_SIZE * CELL_SIZE) / 2
	local gridOffsetY = 40 * mainFrameScale

    local gridFrame = Instance.new("Frame")
    gridFrame.Size = UDim2.new(0, GRID_SIZE * CELL_SIZE, 0, GRID_SIZE * CELL_SIZE)
    gridFrame.Position = UDim2.new(0.5, gridOffsetX, 0, gridOffsetY)  -- Positioned below title
    gridFrame.BackgroundTransparency = 1
    gridFrame.Parent = mainFrame
	
	local function updateCell(cell, i, j)
        grid[i][j] = selectedEmoji
        cell.Text = selectedEmoji
        -- Add subtle animation
        local scaleUp = TweenService:Create(cell, TweenInfo.new(0.1), {Size = UDim2.new(0, CELL_SIZE, 0, CELL_SIZE)})
        local scaleDown = TweenService:Create(cell, TweenInfo.new(0.1), {Size = UDim2.new(0, CELL_SIZE - 2 * mainFrameScale, 0, CELL_SIZE - 2 * mainFrameScale)})
        scaleUp:Play()
        scaleUp.Completed:Connect(function()
            scaleDown:Play()
        end)
	end
    -- Create grid cells
    for i = 1, GRID_SIZE do
        grid[i] = {}
        cells[i] = {}
        for j = 1, GRID_SIZE do
			local cellOffsetX = (j - 1) * CELL_SIZE + 1 * mainFrameScale
			local cellOffsetY = (i - 1) * CELL_SIZE + 1 * mainFrameScale
            local cell = createButton("", gridFrame, UDim2.new(0, CELL_SIZE - 2 * mainFrameScale, 0, CELL_SIZE - 2 * mainFrameScale), UDim2.new(0, cellOffsetX, 0, cellOffsetY), Color3.fromRGB(45, 45, 45))
            cell.Font = Enum.Font.Gotham
            cell.TextSize = 20 * mainFrameScale
            cell.Text = ""

            grid[i][j] = ""
			cells[i][j] = cell
			
			cell.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					drawing = true
					updateCell(cell, i, j)
				end
			end)
			cell.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					if drawing then
						updateCell(cell, i, j)
					end
				end
			end)
			cell.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					drawing = false
				end
			end)
        end
    end
	

    -- Load saved grid
    if #savedGrid > 0 then
        for x = 1, GRID_SIZE do
            for y = 1, GRID_SIZE do
                grid[x][y] = savedGrid[x][y]
                gridFrame:GetChildren()[(x - 1) * GRID_SIZE + y].Text = savedGrid[x][y]
            end
        end
    end

    -- Emoji selector (with scrolling)
	local emojiScrollFrameHeight = 40 * mainFrameScale
	local emojiScrollFrameOffsetY = 295 * mainFrameScale

    local emojiScrollFrame = Instance.new("ScrollingFrame")
    emojiScrollFrame.Size = UDim2.new(0.95, 0, 0, emojiScrollFrameHeight)
    emojiScrollFrame.Position = UDim2.new(0.025, 0, 0, emojiScrollFrameOffsetY)  -- Positioned below grid
    emojiScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    emojiScrollFrame.BorderSizePixel = 0
    emojiScrollFrame.ScrollBarThickness = 4 * mainFrameScale
    emojiScrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
    emojiScrollFrame.Parent = mainFrame

    local emojiScrollFrameCorner = Instance.new("UICorner")
    emojiScrollFrameCorner.CornerRadius = UDim.new(0, 4 * mainFrameScale)
    emojiScrollFrameCorner.Parent = emojiScrollFrame
	
    local emojis = {"","⬜", "⬛", "🔲", "🔳", "🏮", "🔴", "🔵", "💜", "🤎", "❤️", "💛", "💚", "💙", "💖", "🧡", "🌸", "🌺", "🌻", "🌼", "🌷", "🌹", "📕", "📙", "📒", "📗", "📘", "📔", "📚", "📖", "❓", "❗", "💯", "🔥", "⭐", "✨", "🌙", "🌞", "☁️", "🌈", "🍕", "🍔", "🍟", "🍦", "🍩", "🍪", "☕", "🍺", "🍷", "🍸", "⚽", "🏀", "🏈", "⚾", "🎾", "🎮", "🎧", "🎵", "🎸", "🎻", "🎺", "🎷", "🎤", "🎨", "📷", "💡", "💻", "📱", "⏰", "🔒", "🔑", "🎁", "🎈", "🎉", "🎀", "📌", "📍", "🗺️", "✂️", "✏️", "✒️", "📝", "📖", "🔒", "🔔", "📞", "🛒", "💰", "💳", "💎", "🔨", "🔧", "🧰", "🧱", "🧲", "🧪", "🔬", "🔭", "🚑", "🚒", "🚓", "🚕", "🚗", "🚌", "🚲", "🚂", "✈️", "🚢", "🚀", "🛸", "🗿", "🚧", "🚦", "🛑", "🚫", "✅", "❌", "❓", "❗", "💯", "🔥", "⭐", "✨", "🌙", "🌞", "☁️", "🌈", "🍕", "🍔", "🍟", "🍦", "🍩", "🍪", "☕", "🍺", "🍷", "🍸", "⚽", "🏀", "🏈", "⚾", "🎾", "🎮", "🎧", "🎵", "🎸", "🎻", "🎺", "🎷", "🎤", "🎨", "📷", "💡", "💻", "📱", "⏰", "🔒", "🔑", "🎁", "🎈", "🎉", "🎀", "📌", "📍", "🗺️", "✂️", "✏️", "✒️", "📝", "📖", "🔒", "🔔", "📞", "🛒", "💰", "💳", "💎", "🔨", "🔧", "🧰", "🧱", "🧲", "🧪", "🔬", "🔭", "🚑", "🚒", "🚓", "🚕", "🚗", "🚌", "🚲", "🚂", "✈️", "🚢", "🚀", "🛸", "🗿", "🚧", "🚦", "🛑", "🚫", "✅", "❌"}
    local emojiButtons = {}

    -- Calculate total width needed for emoji buttons
    local totalWidth = #emojis * 35 * mainFrameScale
    emojiScrollFrame.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
	
    for i, emoji in ipairs(emojis) do
		local emojiButtonOffsetX = (i - 1) * 35 * mainFrameScale + 5 * mainFrameScale
        local emojiButton = createButton(emoji, emojiScrollFrame, UDim2.new(0, 30 * mainFrameScale, 0, 30 * mainFrameScale), UDim2.new(0, emojiButtonOffsetX, 0, 5 * mainFrameScale), Color3.fromRGB(60, 60, 60))
        emojiButton.Font = Enum.Font.Gotham
        emojiButton.TextSize = 20 * mainFrameScale
        
        table.insert(emojiButtons, emojiButton)

        emojiButton.MouseButton1Click:Connect(function()
            selectedEmoji = emoji
            for _, btn in ipairs(emojiButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
            emojiButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        end)
    end

    -- Preset section
	local presetFrameHeight = 125 * mainFrameScale
    local presetFrameOffsetY = 340 * mainFrameScale
    local presetFrame = Instance.new("Frame")
    presetFrame.Size = UDim2.new(0.95, 0, 0, presetFrameHeight)
    presetFrame.Position = UDim2.new(0.025, 0, 0, presetFrameOffsetY)
    presetFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    presetFrame.BorderSizePixel = 0
    presetFrame.Parent = mainFrame

    local presetFrameCorner = Instance.new("UICorner")
    presetFrameCorner.CornerRadius = UDim.new(0, 6 * mainFrameScale)
    presetFrameCorner.Parent = presetFrame

    -- Preset input
	local presetInputHeight = 30 * mainFrameScale
	local presetInputOffsetY = 10 * mainFrameScale
	
    local presetInput = Instance.new("TextBox")
    presetInput.Size = UDim2.new(0.7, 0, 0, presetInputHeight)
    presetInput.Position = UDim2.new(0.025, 0, 0, presetInputOffsetY)
    presetInput.PlaceholderText = "Enter preset name..."
    presetInput.Text = ""
    presetInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    presetInput.BorderSizePixel = 0
    presetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    presetInput.Font = Enum.Font.Gotham
    presetInput.TextSize = 14 * mainFrameScale
    presetInput.Parent = presetFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4 * mainFrameScale)
    inputCorner.Parent = presetInput

    local savePresetButtonSize = 30 * mainFrameScale
    local savePresetButtonOffsetY = 10 * mainFrameScale
    local savePresetButton = createButton("Save", presetFrame, UDim2.new(0.225, 0, 0, savePresetButtonSize), UDim2.new(0.75, 0, 0, savePresetButtonOffsetY), Color3.fromRGB(70, 170, 70))
	
	-- Preset list
	local presetListHeight = 80 * mainFrameScale
	local presetListOffsetY = 45 * mainFrameScale
    local presetList = Instance.new("ScrollingFrame")
    presetList.Size = UDim2.new(0.95, 0, 0, presetListHeight)
    presetList.Position = UDim2.new(0.025, 0, 0, presetListOffsetY)
    presetList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    presetList.BorderSizePixel = 0
    presetList.ScrollBarThickness = 4 * mainFrameScale
    presetList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    presetList.ScrollBarImageTransparency = 0.5
    presetList.Parent = presetFrame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4 * mainFrameScale)
    listCorner.Parent = presetList

    local function updatePresetList()
        for _, child in ipairs(presetList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local yOffset = 5 * mainFrameScale
        for i, presetData in ipairs(presets) do
            local name = presetData.name
            local preset = presetData.grid
            local presetButtonHeight = 25 * mainFrameScale
            local presetButton = createButton(name, presetList, UDim2.new(0.9, 0, 0, presetButtonHeight), UDim2.new(0.05, 0, 0, yOffset))

            -- Load preset
            presetButton.MouseButton1Click:Connect(function()
                for x = 1, GRID_SIZE do
                    for y = 1, GRID_SIZE do
                        grid[x][y] = preset[x][y]
                         gridFrame:GetChildren()[(x - 1) * GRID_SIZE + y].Text = preset[x][y]
                    end
                end
            end)
			
            -- Delete button
            local deleteButtonSize = 20 * mainFrameScale
            local deleteButtonOffsetX = -25 * mainFrameScale
            local deleteButtonOffsetY = 2 * mainFrameScale
            local deleteButton = createButton("X", presetButton, UDim2.new(0, deleteButtonSize, 0, deleteButtonSize), UDim2.new(1, deleteButtonOffsetX, 0, deleteButtonOffsetY), Color3.fromRGB(200, 50, 50))
            deleteButton.TextSize = 12 * mainFrameScale
            deleteButton.MouseButton1Click:Connect(function()
                table.remove(presets, i)
                updatePresetList()
                savePresetsToFile()
            end)

            yOffset = yOffset + 30 * mainFrameScale
        end

        presetList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
		
    savePresetButton.MouseButton1Click:Connect(function()
        local name = presetInput.Text
        if name ~= "" then
            local currentGrid = {}
            for x = 1, GRID_SIZE do
                currentGrid[x] = {}
                for y = 1, GRID_SIZE do
                    currentGrid[x][y] = grid[x][y]
                end
            end

            table.insert(presets, {name = name, grid = currentGrid})
            savePresetsToFile()
            presetInput.Text = ""
            updatePresetList()
        end
    end)

    -- Action buttons at bottom
	local actionButtonsHeight = 35 * mainFrameScale
	local actionButtonsOffsetY = 455 * mainFrameScale
	
    local actionButtons = Instance.new("Frame")
    actionButtons.Size = UDim2.new(0.95, 0, 0, actionButtonsHeight)
    actionButtons.Position = UDim2.new(0.025, 0, 0, actionButtonsOffsetY) -- Lowered action buttons
    actionButtons.BackgroundTransparency = 1
    actionButtons.Parent = mainFrame

    local sendButton = createButton("Send", actionButtons, UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(70, 170, 70))
    sendButton.MouseButton1Click:Connect(function()
        local art = ""
        for x = 1, GRID_SIZE do
            for y = 1, GRID_SIZE do
                art = art .. (grid[x][y] ~= "" and grid[x][y] or "⬜")
            end
            if x < GRID_SIZE then
                art = art .. NEWLINE
            end
        end
        chatMessage(INVISIBLE_CHAR .. string.rep(NEWLINE, 8) .. art)
    end)

    local clearButton = createButton("Clear", actionButtons, UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(170, 70, 70))
    clearButton.MouseButton1Click:Connect(function()
        for x = 1, GRID_SIZE do
            for y = 1, GRID_SIZE do
                grid[x][y] = ""
                gridFrame:GetChildren()[(x - 1) * GRID_SIZE + y].Text = ""
            end
        end
    end)

    -- Make the interface draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(mainFrame, tweenInfo, {Position = position}):Play()
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
	
	-- Save grid before the interface is disabled or reset
	gui.DescendantRemoving:Connect(function(descendant)
		if descendant == gui then
			savedGrid = {}
			for x = 1, GRID_SIZE do
				savedGrid[x] = {}
				for y = 1, GRID_SIZE do
					savedGrid[x][y] = grid[x][y]
				end
			end
		end
	end)


    -- Call updatePresetList here after the presetList has been created so it will render the list
    updatePresetList()

    return gui
end

-- Load the presets at the beginning
loadPresetsFromFile()

-- Initialize the GUI immediately when the script runs
drawingGui = createDrawingInterface()
drawingGui.Enabled = true
interfaceEnabled = true


-- Function to toggle the UI
local function toggleInterface()
    interfaceEnabled = not interfaceEnabled
    drawingGui.Enabled = interfaceEnabled
end


-- Bind the toggle action to a keypress (e.g., 'E' key)
local function actionToggle(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        toggleInterface()
    end
end

if not actionBound then
    ContextActionService:BindAction("ToggleDrawingUI", actionToggle, true, Enum.KeyCode.E)
    actionBound = true
end
