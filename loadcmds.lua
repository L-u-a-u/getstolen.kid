local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not _G.cmds then
    _G.cmds = {}
end

local existingGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AKAdminNotifications")
if existingGui then
    existingGui:Destroy()
end

local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "AKAdminNotifications"
NotificationGui.ResetOnSpawn = false
NotificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function createNotification(title, text, duration, suggestion, suggestionCallback, offset)
    -- Create main notification frame
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 280, 0, 100) -- Smaller size
    notification.Position = UDim2.new(1, 50, 0.02 + (offset or 0), 0)
    notification.BackgroundColor3 = Color3.fromRGB(10, 10, 12) -- Dark black
    notification.BackgroundTransparency = 0.15 -- Slight transparency
    notification.BorderSizePixel = 0
    notification.Parent = NotificationGui
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12) -- More rounded corners
    corner.Parent = notification
    
    -- Add subtle gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 18)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 12))
    })
    gradient.Rotation = 135
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.25)
    })
    gradient.Parent = notification
    
    -- Create inner container with stroke
    local innerContainer = Instance.new("Frame")
    innerContainer.Size = UDim2.new(1, -8, 1, -8)
    innerContainer.Position = UDim2.new(0, 4, 0, 4)
    innerContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    innerContainer.BackgroundTransparency = 0.5
    innerContainer.BorderSizePixel = 0
    innerContainer.Parent = notification
    
    -- Add rounded corners to inner container
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 8)
    innerCorner.Parent = innerContainer
    
    -- Add subtle glow
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(30, 30, 35)
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = notification
    
    -- Light purple accent line
    local titleAccent = Instance.new("Frame")
    titleAccent.Size = UDim2.new(0, 3, 0, 18)
    titleAccent.Position = UDim2.new(0, 12, 0, 10)
    titleAccent.BackgroundColor3 = Color3.fromRGB(190, 130, 255) -- Light purple
    titleAccent.BorderSizePixel = 0
    titleAccent.Parent = innerContainer
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = titleAccent
    
    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -48, 0, 18)
    titleLabel.Position = UDim2.new(0, 22, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = innerContainer
    
    -- Message label
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -24, 0, 40)
    messageLabel.Position = UDim2.new(0, 12, 0, 34)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    messageLabel.TextSize = 13
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Text = text
    messageLabel.Parent = innerContainer
    
    -- Create container for progress bar
    local progressContainer = Instance.new("Frame")
    progressContainer.Name = "ProgressContainer"
    progressContainer.Size = UDim2.new(1, -8, 0, 3)
    progressContainer.Position = UDim2.new(0, 4, 1, -7)
    progressContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    progressContainer.BackgroundTransparency = 0.7
    progressContainer.BorderSizePixel = 0
    progressContainer.ClipsDescendants = true
    progressContainer.Parent = notification
    
    -- Add rounded corners to progress container
    local progressContainerCorner = Instance.new("UICorner")
    progressContainerCorner.CornerRadius = UDim.new(0, 2)
    progressContainerCorner.Parent = progressContainer
    
    -- Create actual progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.Position = UDim2.new(0, 0, 0, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(190, 130, 255) -- Light purple
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressContainer
    
    -- Add rounded corners to progress bar
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(0, 2)
    progressBarCorner.Parent = progressBar
    
    -- Add subtle glow to progress bar
    local progressGlow = Instance.new("UIGradient")
    progressGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 120, 255))
    })
    progressGlow.Rotation = 90
    progressGlow.Parent = progressBar
    
    if suggestion then
        -- For suggestion notifications, move the title and text up a bit
        titleLabel.Position = UDim2.new(0, 22, 0, 6)  -- Moved up from 10 to 6
        titleAccent.Position = UDim2.new(0, 12, 0, 6)  -- Also move the accent line up
        messageLabel.Position = UDim2.new(0, 12, 0, 28)  -- Moved up from 34 to 28
        
        -- Button container with more polish
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -24, 0, 22)
        buttonContainer.Position = UDim2.new(0, 12, 1, -32)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = innerContainer
        
        -- Yes button
        local yesButton = Instance.new("TextButton")
        yesButton.Size = UDim2.new(0.48, 0, 1, 0)
        yesButton.Position = UDim2.new(0, 0, 0, 0)
        yesButton.BackgroundColor3 = Color3.fromRGB(190, 130, 255) -- Light purple
        yesButton.BackgroundTransparency = 0.2
        yesButton.Text = "Yes"
        yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesButton.Font = Enum.Font.GothamBold
        yesButton.TextSize = 12
        yesButton.AutoButtonColor = false
        yesButton.Parent = buttonContainer
        
        local yesCorner = Instance.new("UICorner")
        yesCorner.CornerRadius = UDim.new(0, 6)
        yesCorner.Parent = yesButton
        
        -- Yes button stroke
        local yesStroke = Instance.new("UIStroke")
        yesStroke.Color = Color3.fromRGB(190, 130, 255)
        yesStroke.Thickness = 1
        yesStroke.Transparency = 0.2
        yesStroke.Parent = yesButton
        
        -- No button
        local noButton = Instance.new("TextButton")
        noButton.Size = UDim2.new(0.48, 0, 1, 0)
        noButton.Position = UDim2.new(0.52, 0, 0, 0)
        noButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        noButton.BackgroundTransparency = 0.3
        noButton.Text = "No"
        noButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        noButton.Font = Enum.Font.GothamBold
        noButton.TextSize = 12
        noButton.AutoButtonColor = false
        noButton.Parent = buttonContainer
        
        local noCorner = Instance.new("UICorner")
        noCorner.CornerRadius = UDim.new(0, 6)
        noCorner.Parent = noButton
        
        -- No button stroke
        local noStroke = Instance.new("UIStroke")
        noStroke.Color = Color3.fromRGB(50, 50, 60)
        noStroke.Thickness = 1
        noStroke.Transparency = 0.2
        noStroke.Parent = noButton
        
        -- Enhanced hover effects
        local function createHoverEffect(button, defaultColor, hoverColor, defaultTransparency, hoverTransparency)
            button.MouseEnter:Connect(function()
                TweenService:Create(button, 
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad), 
                    {BackgroundColor3 = hoverColor, BackgroundTransparency = hoverTransparency}
                ):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, 
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad), 
                    {BackgroundColor3 = defaultColor, BackgroundTransparency = defaultTransparency}
                ):Play()
            end)
        end
        
        createHoverEffect(yesButton, 
            Color3.fromRGB(190, 130, 255), 
            Color3.fromRGB(210, 150, 255),
            0.2,
            0.1
        )
        
        createHoverEffect(noButton, 
            Color3.fromRGB(30, 30, 35), 
            Color3.fromRGB(40, 40, 45),
            0.3,
            0.2
        )
        
        yesButton.MouseButton1Click:Connect(function()
            if suggestionCallback then
                suggestionCallback(true)
            end
            notification:Destroy()
        end)
        
        noButton.MouseButton1Click:Connect(function()
            if suggestionCallback then
                suggestionCallback(false)
            end
            notification:Destroy()
        end)
    end
    
    -- Slide in animation
    local slideTween = TweenService:Create(notification,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -300, 0.02 + (offset or 0), 0)}
    )
    slideTween:Play()
    
    -- Progress bar animation
    local progressTween = TweenService:Create(progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 1, 0)}
    )
    progressTween:Play()
    
    -- Slide out animation
    task.delay(duration, function()
        local slideOutTween = TweenService:Create(notification,
            TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 50, 0.02 + (offset or 0), 0)}
        )
        slideOutTween:Play()
        
        slideOutTween.Completed:Wait()
        notification:Destroy()
    end)
end

local function suggestClosestCommand(input)
    if not input then return nil end
    local closestCommand = nil
    local highestScore = -math.huge
    
    if _G.cmds[input] then
        return input
    end
    
    for cmd in pairs(_G.cmds) do
        local score = 0
        local inputLower = input:lower()
        local cmdLower = cmd:lower()
        local inputLen = #inputLower
        local cmdLen = #cmdLower
        
        if inputLower == cmdLower then
            return cmd
        end
        
        if cmdLower:sub(1, inputLen) == inputLower then
            score = score + 25
        end

        local function levenshteinDistance(s1, s2)
            local len1 = #s1
            local len2 = #s2
            local d = {}
            
            for i = 0, len1 do d[i] = {[0] = i} end
            for j = 0, len2 do d[0][j] = j end
            
            for j = 1, len2 do
                for i = 1, len1 do
                    local cost = (s1:sub(i,i) == s2:sub(j,j)) and 0 or 1
                    d[i][j] = math.min(
                        d[i-1][j] + 1,
                        d[i][j-1] + 1,
                        d[i-1][j-1] + cost
                    )
                end
            end
            
            return d[len1][len2]
        end
        
        local distance = levenshteinDistance(inputLower, cmdLower)
        score = score - (distance * 5)

        local lengthDiff = math.abs(inputLen - cmdLen)
        score = score - (lengthDiff * 2)

        local lastFoundIndex = 0
        local consecutiveMatches = 0
        for i = 1, inputLen do
            local char = inputLower:sub(i,i)
            local found = cmdLower:find(char, lastFoundIndex+1)
            if found then
                score = score + (2 - (found - i) * 0.5)
                if found == lastFoundIndex + 1 then
                    consecutiveMatches = consecutiveMatches + 1
                    score = score + (consecutiveMatches * 2)
                else
                    consecutiveMatches = 0
                end
                lastFoundIndex = found
            end
        end

        local commonPrefix = 0
        for i = 1, math.min(inputLen, cmdLen) do
            if inputLower:sub(i, i) == cmdLower:sub(i,i) then
                commonPrefix = commonPrefix + 1
            else
                break
            end
        end
        score = score + (commonPrefix * 4)

        if score > highestScore then
            highestScore = score
            closestCommand = cmd
        end
    end
    
    return highestScore > 10 and closestCommand or nil
end

local function executeCommand(command)
    if _G.cmds[command] then
        createNotification(
            "Success",
            "Executed command: " .. command,
            3,
            false,
            nil,
            0
        )
    else
        local suggestion = suggestClosestCommand(command)
        if suggestion then
            createNotification(
                "Command Suggestion",
                "Did you mean: " .. suggestion .. "?",
                10,
                true,
                function(accepted)
                    if accepted then
                        if _G.cmds[suggestion] then
                            local success, errorMessage = pcall(function()
                                loadstring(game:HttpGet(_G.cmds[suggestion]))()
                            end)
                            if success then
                                createNotification(
                                    "Success",
                                    "Executed command: " .. suggestion,
                                    3,
                                    false,
                                    nil,
                                    0
                                )
                            else
                                createNotification(
                                    "Error",
                                    "Failed to execute command: " .. suggestion,
                                    5,
                                    false,
                                    nil,
                                    0
                                )
                            end
                        end
                    end
                end,
                0
            )
        end
    end
end

local function loadCommandBar()
    loadstring(game:HttpGet("https://ichfickdeinemutta.pages.dev/Cmdsbar.lua", true))()
end

task.wait(1)

local function showNotificationsSequentially()
    local welcomeMessage = function()
        createNotification(
            "AK ADMIN",
            "click  AK ACTIVE to see available commands. Commands are also useable in chat. F6 for the CMDBAR",
            10,
            false,
            nil,
            0
        )
    end
    
    welcomeMessage()
    loadCommandBar()
end

showNotificationsSequentially()

local lastInput = ""

LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1, 1) == "!" then
        local command = msg:sub(2):lower():gsub("^%s*", ""):gsub("%s*$", "")
        executeCommand("!" .. command)
        lastInput = command
        return
    end
end)

local function updateSuggestion(input)
    if input == "" then return end
    local suggestion = suggestClosestCommand("!" .. input)
    if suggestion then
         for _, child in pairs(NotificationGui:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "ProgressBar" then
                child:Destroy()
            end
        end
        createNotification(
            "Command Suggestion",
            "Did you mean: " .. suggestion .. "?",
            10,
            true,
            function(accepted)
                if accepted then
                    if _G.cmds[suggestion] then
                        local success, errorMessage = pcall(function()
                            loadstring(game:HttpGet(_G.cmds[suggestion]))()
                        end)
                        if success then
                            createNotification(
                                "Success",
                                "Executed command: " .. suggestion,
                                3,
                                false,
                                nil,
                                0
                            )
                        else
                            createNotification(
                                "Error",
                                "Failed to execute command: " .. suggestion,
                                5,
                                false,
                                nil,
                                0
                            )
                        end
                    end
                end
            end,
             0
        )
    else
        for _, child in pairs(NotificationGui:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "ProgressBar" then
                child:Destroy()
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    if not character then return end
    local chatBox = LocalPlayer.PlayerGui:WaitForChild("Chat"):WaitForChild("Frame"):WaitForChild("ChatBar")
    local textBox = chatBox:WaitForChild("Box")
    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        local currentText = textBox.Text
        if currentText:sub(1,1) == "!" then
            local input = currentText:sub(2):lower()
            if input ~= lastInput then
                updateSuggestion(input)
                lastInput = input
            end
        end
    end)
end)
