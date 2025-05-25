local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/0x"))()
local window = library:Window("Chat Interface")

local INVISIBLE_CHAR = "\u{001E}"
local NEWLINE = "\u{000D}"

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

local function createDrawingInterface()
    local gui = Instance.new("ScreenGui")
    local mainFrame = Instance.new("Frame")

    -- Main frame (matches dark theme in image)
    mainFrame.Size = UDim2.new(0, 300, 0, 490)  -- Increased height
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -245)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    -- Add rounded corners to main frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    addShadow(mainFrame)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    -- Add rounded corners to title bar
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Text = "Drawing Interface"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.Gotham
    titleText.TextSize = 14
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Close button (red X in corner)
    local closeButton = createButton("X", titleBar, UDim2.new(0, 30, 0, 30), UDim2.new(1, -30, 0, 0), Color3.fromRGB(220, 50, 50))
    closeButton.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    -- Grid setup
    local GRID_SIZE = 7
    local CELL_SIZE = 35
    local grid = {}

    local gridFrame = Instance.new("Frame")
    gridFrame.Size = UDim2.new(0, GRID_SIZE * CELL_SIZE, 0, GRID_SIZE * CELL_SIZE)
    gridFrame.Position = UDim2.new(0.5, -(GRID_SIZE * CELL_SIZE)/2, 0, 40)  -- Positioned below title
    gridFrame.BackgroundTransparency = 1
    gridFrame.Parent = mainFrame

    -- Create grid cells
    for i = 1, GRID_SIZE do
        grid[i] = {}
        for j = 1, GRID_SIZE do
            local cell = Instance.new("TextButton")
            cell.Size = UDim2.new(0, CELL_SIZE - 2, 0, CELL_SIZE - 2)
            cell.Position = UDim2.new(0, (j-1) * CELL_SIZE + 1, 0, (i-1) * CELL_SIZE + 1)
            cell.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            cell.BorderSizePixel = 0
            cell.Text = ""
            cell.Font = Enum.Font.Gotham
            cell.TextSize = 20
            cell.Parent = gridFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = cell

            grid[i][j] = ""

            cell.MouseButton1Down:Connect(function()
                grid[i][j] = selectedEmoji
                cell.Text = selectedEmoji
				-- Add subtle animation
				local scaleUp = TweenService:Create(cell, TweenInfo.new(0.1), {Size = UDim2.new(0, CELL_SIZE, 0, CELL_SIZE)})
				local scaleDown = TweenService:Create(cell, TweenInfo.new(0.1), {Size = UDim2.new(0, CELL_SIZE - 2, 0, CELL_SIZE - 2)})
				scaleUp:Play()
				scaleUp.Completed:Connect(function()
					scaleDown:Play()
				end)
            end)
        end
    end

    -- Emoji selector (with scrolling)
    local emojiScrollFrame = Instance.new("ScrollingFrame")
    emojiScrollFrame.Size = UDim2.new(0.95, 0, 0, 40)
    emojiScrollFrame.Position = UDim2.new(0.025, 0, 0, 295)  -- Positioned below grid
    emojiScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    emojiScrollFrame.BorderSizePixel = 0
    emojiScrollFrame.ScrollBarThickness = 4
    emojiScrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
    emojiScrollFrame.Parent = mainFrame

	    local emojiScrollFrameCorner = Instance.new("UICorner")
		emojiScrollFrameCorner.CornerRadius = UDim.new(0, 4)
        emojiScrollFrameCorner.Parent = emojiScrollFrame

    local emojis = {"⬜", "🏮", "🔴", "📕", "📙", "📒", "📗", "🔵", "📘", "💜", "🤎", "⬛",  "🔲", "🔳"}
	local emojiButtons = {}

    -- Calculate total width needed for emoji buttons
    local totalWidth = #emojis * 35  -- 30px button + 5px spacing
    emojiScrollFrame.CanvasSize = UDim2.new(0, totalWidth, 0, 0)

    for i, emoji in ipairs(emojis) do
        local emojiButton = Instance.new("TextButton")
        emojiButton.Text = emoji
        emojiButton.Size = UDim2.new(0, 30, 0, 30)
        emojiButton.Position = UDim2.new(0, (i-1) * 35 + 5, 0, 5)
        emojiButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        emojiButton.BorderSizePixel = 0
        emojiButton.Font = Enum.Font.Gotham
        emojiButton.TextSize = 20
        emojiButton.Parent = emojiScrollFrame

		local emojiCorner = Instance.new("UICorner")
        emojiCorner.CornerRadius = UDim.new(0, 4)
        emojiCorner.Parent = emojiButton

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
    local presetFrame = Instance.new("Frame")
    presetFrame.Size = UDim2.new(0.95, 0, 0, 125) -- Increased frame size
	presetFrame.Position = UDim2.new(0.025, 0, 0, 340)
    presetFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    presetFrame.BorderSizePixel = 0
	presetFrame.Parent = mainFrame

	local presetFrameCorner = Instance.new("UICorner")
	presetFrameCorner.CornerRadius = UDim.new(0, 6)
	presetFrameCorner.Parent = presetFrame

	-- Preset input
    local presetInput = Instance.new("TextBox")
    presetInput.Size = UDim2.new(0.7, 0, 0, 30)
    presetInput.Position = UDim2.new(0.025, 0, 0, 10)
    presetInput.PlaceholderText = "Enter preset name..."
	presetInput.Text = ""
    presetInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    presetInput.BorderSizePixel = 0
    presetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    presetInput.Font = Enum.Font.Gotham
    presetInput.TextSize = 14
    presetInput.Parent = presetFrame

	local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = presetInput

    local savePresetButton = createButton("Save Preset", presetFrame, UDim2.new(0.225, 0, 0, 30), UDim2.new(0.75, 0, 0, 10), Color3.fromRGB(70, 170, 70))

	-- Preset list
    local presetList = Instance.new("ScrollingFrame")
    presetList.Size = UDim2.new(0.95, 0, 0, 80) -- Increased height
    presetList.Position = UDim2.new(0.025, 0, 0, 45) -- Adjusted position to fit inside presetFrame
    presetList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    presetList.BorderSizePixel = 0
    presetList.ScrollBarThickness = 4
	presetList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	presetList.ScrollBarImageTransparency = 0.5
    presetList.Parent = presetFrame

	local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = presetList

	local function updatePresetList()
        for _, child in ipairs(presetList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

		local yOffset = 5
		for i, presetData in ipairs(presets) do
			local name = presetData.name
			local preset = presetData.grid
            local presetButton = createButton(name, presetList, UDim2.new(0.9, 0, 0, 25), UDim2.new(0.05, 0, 0, yOffset))

            -- Load preset
            presetButton.MouseButton1Click:Connect(function()
                for i = 1, GRID_SIZE do
                    for j = 1, GRID_SIZE do
                        grid[i][j] = preset[i][j]
                        gridFrame:GetChildren()[(i - 1) * GRID_SIZE + j].Text = preset[i][j]
                    end
                end
            end)

            -- Delete button
            local deleteButton = createButton("X", presetButton, UDim2.new(0, 20, 0, 20), UDim2.new(1, -25, 0, 2), Color3.fromRGB(200, 50, 50))
			deleteButton.TextSize = 12

            deleteButton.MouseButton1Click:Connect(function()
				table.remove(presets, i)
                updatePresetList()
            end)

            yOffset = yOffset + 30
        end

		presetList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end

	savePresetButton.MouseButton1Click:Connect(function()
		local name = presetInput.Text
        if name ~= "" then
            local currentGrid = {}
            for i = 1, GRID_SIZE do
                currentGrid[i] = {}
                for j = 1, GRID_SIZE do
                    currentGrid[i][j] = grid[i][j]
                end
            end

			table.insert(presets, {name = name, grid = currentGrid})
            presetInput.Text = ""
            updatePresetList()
        end
    end)

    -- Action buttons at bottom
    local actionButtons = Instance.new("Frame")
    actionButtons.Size = UDim2.new(0.95, 0, 0, 35)
    actionButtons.Position = UDim2.new(0.025, 0, 0, 455) -- Lowered action buttons
    actionButtons.BackgroundTransparency = 1
    actionButtons.Parent = mainFrame

    local sendButton = createButton("Send", actionButtons, UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(70, 170, 70))
    sendButton.MouseButton1Click:Connect(function()
        local art = ""
        for i = 1, GRID_SIZE do
            for j = 1, GRID_SIZE do
                art = art .. (grid[i][j] ~= "" and grid[i][j] or "⬜")
            end
            if i < GRID_SIZE then
                art = art .. NEWLINE
            end
        end
        chatMessage(INVISIBLE_CHAR .. string.rep(NEWLINE, 1) .. art)
    end)

    local clearButton = createButton("Clear", actionButtons, UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(170, 70, 70))
    clearButton.MouseButton1Click:Connect(function()
        for i = 1, GRID_SIZE do
            for j = 1, GRID_SIZE do
                grid[i][j] = ""
                gridFrame:GetChildren()[(i - 1) * GRID_SIZE + j].Text = ""
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

    return gui
end

-- Initialize the GUI immediately when the script runs
drawingGui = createDrawingInterface()
drawingGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
drawingGui.Enabled = false

-- Main interface buttons
window:Button("ROBLOX Join", function()
    chatMessage(INVISIBLE_CHAR .. string.rep(NEWLINE, 80) .. "[Server]: Roblox has joined the game.")
end)

window:Button("Server Chat Clear", function()
    chatMessage(INVISIBLE_CHAR .. string.rep(NEWLINE, 100) .. "[Server]: Chat cleared.")
end)

window:Button("Custom Drawing", function()
    drawingGui.Enabled = not drawingGui.Enabled
end)
window:Button("Swastika", function()
    chatMessage(INVISIBLE_CHAR..string.rep(NEWLINE, 40).. "⬜⬜⬜⬜⬜⬜⬜"..NEWLINE.."⬜⬛⬜⬛⬛⬛⬜"..NEWLINE.."⬜⬛⬜⬛⬜⬜⬜"..NEWLINE.."⬜⬛⬛⬛⬛⬛⬜"..NEWLINE.."⬜⬜⬜⬛⬜⬛⬜"..NEWLINE.."⬜⬛⬛⬛⬜⬛⬜"..NEWLINE.."⬜⬜⬜⬜⬜⬜⬜")
end)
window:Button("Penis", function()
    chatMessage(NEWLINE.. "⬜⬜⬜⬜⬜⬜⬜⬜"..NEWLINE.."⬜⬜⬜⬛⬛⬜⬜⬜"..NEWLINE.."⬜⬜⬜⬛⬛⬜⬜⬜"..NEWLINE.."⬜⬜⬜⬛⬛⬜⬜⬜"..NEWLINE.."⬜⬜⬜⬛⬛⬜⬜⬜"..NEWLINE.."⬜⬛⬛⬛⬛⬛⬛⬜"..NEWLINE.."⬜⬛⬛⬜⬜⬛⬛⬜"..NEWLINE.."⬜⬜⬜⬜⬜⬜⬜⬜")
end)
local upArrow = INVISIBLE_CHAR..NEWLINE..
"⬜⬜⬜⬜⬜⬜" .. NEWLINE ..
"⬜⬜⬛⬛⬜⬜" .. NEWLINE ..
"⬜⬛⬛⬛⬛⬜" .. NEWLINE ..
"⬛⬛⬛⬛⬛⬛" .. NEWLINE ..
"⬜⬜⬛⬛⬜⬜" .. NEWLINE ..
"⬜⬜⬛⬛⬜⬜" .. NEWLINE ..
"⬜⬜⬛⬛⬜⬜" .. NEWLINE ..
"⬜⬜⬜⬜⬜⬜"

-- Down Arrow
local downArrow = INVISIBLE_CHAR..NEWLINE..
"⬜⬜⬜⬜⬜⬜" .. NEWLINE ..
"⬜⬜⬛⬛⬜⬜" .. NEWLINE ..
"⬜⬜⬛⬛⬜⬜" .. NEWLINE ..
"⬜⬜⬛⬛⬜⬜" .. NEWLINE ..
"⬛⬛⬛⬛⬛⬛" .. NEWLINE ..
"⬜⬛⬛⬛⬛⬜" .. NEWLINE ..
"⬜⬜⬛⬛⬜⬜" .. NEWLINE ..
"⬜⬜⬜⬜⬜⬜"

window:Button("Heart", function()
    local heart = INVISIBLE_CHAR ..
      NEWLINE ..
        "⬜⬛⬛⬜⬛⬛⬜" .. NEWLINE ..
        "⬛⬛⬛⬛⬛⬛⬛" .. NEWLINE ..
        "⬛⬛⬛⬛⬛⬛⬛" .. NEWLINE ..
        "⬜⬛⬛⬛⬛⬛⬜" .. NEWLINE ..
        "⬜⬜⬛⬛⬛⬜⬜" .. NEWLINE ..
        "⬜⬜⬜⬛⬜⬜⬜"
    chatMessage(heart)
end)

window:Button("Up Arrow", function()
    chatMessage(upArrow)
end)

window:Button("Down Arrow", function()
    chatMessage(downArrow)
end)
window:Button("Fake Error", function()
    chatMessage(INVISIBLE_CHAR .. string.rep(NEWLINE, 50) .. "[Server]: ERROR - Connection Lost. Retrying...")
end)

window:Button("Player Banned", function()
local rdmnumber = math.random(1,#game.Players:GetChildren())

for i,player in pairs(game.Players:GetChildren()) do
if rdmnumber == i then
getgenv().player = player.DisplayName
break
end
end
    chatMessage(INVISIBLE_CHAR .. string.rep(NEWLINE, 60) .. "[Server]: Player '"..getgenv().player.."' has been permanently banned.")
end)

window:Button("GG", function()
    chatMessage(INVISIBLE_CHAR .. string.rep(NEWLINE, 30) .. "[Server]: GG! Well played everyone.")
end)

window:Button("Victory", function()
    chatMessage(INVISIBLE_CHAR .. string.rep(NEWLINE, 50) .. "[Server]: Congratulations! Your team has won the round.")
end)

-- Cleanup
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if drawingGui then
        drawingGui.Enabled = false
    end
end)
