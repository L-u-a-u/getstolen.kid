-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Configuration

-- Body parts to potentially offset and sync (All enabled by default)
local bodyParts = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
    "HumanoidRootPart" -- Used as reference, not part of the visible snake
}

-- Snake Configuration: Order of body parts in the snake
-- HumanoidRootPart is implicitly the leader, the snake starts visually with Head
local snakeOrder = {
    "Head",
    "UpperTorso",
    "LowerTorso",
    "LeftUpperArm",
    "LeftLowerArm",
    "LeftHand",
    "RightUpperArm",
    "RightLowerArm",
    "RightHand",
    "LeftUpperLeg",
    "LeftLowerLeg",
    "LeftFoot",
    "RightUpperLeg",
    "RightLowerLeg",
    "RightFoot"
}

-- Snake Configuration
local snakeDistance = 1.0       -- Default Abstand zwischen den Teilen (Studs)
local snakeSmoothing = 0.1      -- FIXED Glättungsfaktor (0-1, höher = glatter) - No longer user-adjustable

-- Slider Configuration
local MIN_DISTANCE = 0.2
local MAX_DISTANCE = 5.0
-- Removed Smoothing and Vertical sliders/constants

-- Swing mode state (global for access in all functions)
swingEnabled = true

-- State variables
local ghostEnabled = false
local originalCharacter
local ghostClone
local originalCFrame
local originalAnimateScript
local updateConnection
local renderStepConnection
local previousPositions = {}
local targetPositions = {}
local lastUpdateTime = 0

-- GUI preservation functions (Unchanged)
local preservedGuis = {}
local function preserveGuis()
    local playerGui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "SnakeReanimationGui" and gui.ResetOnSpawn then
                table.insert(preservedGuis, gui)
                gui.ResetOnSpawn = false
            end
        end
    end
end
local function restoreGuis()
    for _, gui in ipairs(preservedGuis) do
        if gui and gui.Parent then
            gui.ResetOnSpawn = true
        end
    end
    table.clear(preservedGuis)
end

-- Update Snake Parts (optimized for smooth snake-like movement)
local pathHistory = {}
local maxPathLength = 3000 -- enough for long snakes and delays

local function updateSnakeParts(dt)
    if not ghostEnabled or not originalCharacter or not originalCharacter.Parent or not ghostClone or not ghostClone.Parent then
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        if renderStepConnection then
            renderStepConnection:Disconnect()
            renderStepConnection = nil
        end
        return
    end

    local currentTime = tick()
    local actualDt = currentTime - lastUpdateTime
    lastUpdateTime = currentTime

    local rootPart = ghostClone:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if not targetPositions then targetPositions = {} end
    if not previousPositions then previousPositions = {} end

    -- All parts from snakeOrder are now active
    local activeSnakeParts = snakeOrder

    if #activeSnakeParts == 0 then return end

    local isMoving = rootPart.AssemblyLinearVelocity.Magnitude > 0.1

    -- Path recording for "route-follow" mode
    if not pathHistory then pathHistory = {} end
    table.insert(pathHistory, 1, {pos = rootPart.Position, rot = rootPart.CFrame - rootPart.Position})
    if #pathHistory > maxPathLength then
        table.remove(pathHistory)
    end

    if swingEnabled then
        -- Default "Swing" mode (as before)
        local firstPartName = activeSnakeParts[1]
        local firstPart = originalCharacter:FindFirstChild(firstPartName)

        if firstPart then
            if not targetPositions[firstPartName] then targetPositions[firstPartName] = firstPart.CFrame end
            if not previousPositions[firstPartName] then previousPositions[firstPartName] = firstPart.CFrame end

            if isMoving then
                local targetPosition = rootPart.Position
                local targetRotation = rootPart.CFrame - rootPart.Position
                local targetCFrame = CFrame.new(targetPosition) * targetRotation
                targetPositions[firstPartName] = targetCFrame
            end

            local smoothCFrame = previousPositions[firstPartName]:Lerp(targetPositions[firstPartName], snakeSmoothing)
            firstPart.CFrame = smoothCFrame
            firstPart.AssemblyLinearVelocity = Vector3.zero
            firstPart.AssemblyAngularVelocity = Vector3.zero
            previousPositions[firstPartName] = smoothCFrame

            for i = 2, #activeSnakeParts do
                local partName = activeSnakeParts[i]
                local currentPart = originalCharacter:FindFirstChild(partName)
                local previousPartName = activeSnakeParts[i-1]
                local previousPart = originalCharacter:FindFirstChild(previousPartName)

                if currentPart and previousPart then
                    if not targetPositions[partName] then targetPositions[partName] = currentPart.CFrame end
                    if not previousPositions[partName] then previousPositions[partName] = currentPart.CFrame end

                    if isMoving then
                        local prevPartPos = previousPart.Position
                        local prevPartRot = previousPart.CFrame - previousPart.Position
                        local directionVector

                        if i == 2 then
                            directionVector = (prevPartPos - rootPart.Position).Unit
                        else
                            local beforePreviousPart = originalCharacter:FindFirstChild(activeSnakeParts[i-2])
                            if beforePreviousPart then
                                directionVector = (prevPartPos - beforePreviousPart.Position).Unit
                            else
                                directionVector = prevPartRot.LookVector
                            end
                        end

                        if directionVector.Magnitude < 0.1 then
                            directionVector = prevPartRot.LookVector
                        end

                        local targetPosition = prevPartPos + directionVector * snakeDistance
                        local targetRotation = prevPartRot
                        local targetCFrame = CFrame.new(targetPosition) * targetRotation
                        targetPositions[partName] = targetCFrame
                    end

                    local smoothCFrame = previousPositions[partName]:Lerp(targetPositions[partName], snakeSmoothing)
                    currentPart.CFrame = smoothCFrame
                    currentPart.AssemblyLinearVelocity = Vector3.zero
                    currentPart.AssemblyAngularVelocity = Vector3.zero
                    previousPositions[partName] = smoothCFrame
                end
            end
        end
    else
        -- "Route-follow" mode: all parts follow the exact path of the root, spaced by snakeDistance
        -- Build a cumulative distance array along the path
        local pathLen = #pathHistory
        local cumDist = {}
        cumDist[1] = 0
        for j = 2, pathLen do
            cumDist[j] = cumDist[j-1] + (pathHistory[j-1].pos - pathHistory[j].pos).Magnitude
        end

        for i = 1, #activeSnakeParts do
            local partName = activeSnakeParts[i]
            local currentPart = originalCharacter:FindFirstChild(partName)
            if currentPart then
                -- Each part should be offset by (i-1)*snakeDistance along the path
                local desiredDist = (i-1) * snakeDistance
                -- Find the two path points between which this distance falls
                local idx = nil
                for j = 2, pathLen do
                    if cumDist[j] >= desiredDist then
                        idx = j
                        break
                    end
                end
                if idx and pathHistory[idx] and pathHistory[idx-1] then
                    local d1 = cumDist[idx-1]
                    local d2 = cumDist[idx]
                    local alpha = (desiredDist - d1) / math.max(1e-6, d2 - d1)
                    local pos1 = pathHistory[idx-1].pos
                    local pos2 = pathHistory[idx].pos
                    local rot1 = pathHistory[idx-1].rot
                    local rot2 = pathHistory[idx].rot
                    local interpPos = pos1:Lerp(pos2, alpha)
                    -- For rotation, just use the earlier one for simplicity
                    local interpRot = rot1
                    local targetCFrame = CFrame.new(interpPos) * interpRot
                    if not previousPositions[partName] then previousPositions[partName] = currentPart.CFrame end
                    if not targetPositions[partName] then targetPositions[partName] = currentPart.CFrame end
                    targetPositions[partName] = targetCFrame
                    local smoothCFrame = previousPositions[partName]:Lerp(targetPositions[partName], snakeSmoothing)
                    currentPart.CFrame = smoothCFrame
                    currentPart.AssemblyLinearVelocity = Vector3.zero
                    currentPart.AssemblyAngularVelocity = Vector3.zero
                    previousPositions[partName] = smoothCFrame
                else
                    -- Not enough path history, space out at current root position
                    local rootCFrame = rootPart.CFrame
                    local offset = rootCFrame.LookVector * (-(i-1) * snakeDistance)
                    local spacedCFrame = rootCFrame + offset
                    currentPart.CFrame = spacedCFrame
                    previousPositions[partName] = spacedCFrame
                end
            end
        end
    end
end

-- Toggle ghost mode (Unchanged Core Logic, just initialization/cleanup references fixed)
local function setGhostEnabled(newState)
    ghostEnabled = newState

    if ghostEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        if originalCharacter or ghostClone then return end -- Already enabled

        originalCharacter = char
        originalCFrame = root.CFrame
        char.Archivable = true
        ghostClone = char:Clone()
        char.Archivable = false
        ghostClone.Name = originalCharacter.Name .. "_clone"
        local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
        if ghostHumanoid then
            ghostHumanoid.DisplayName = originalCharacter.Name .. "_clone"
            ghostHumanoid:ChangeState(Enum.HumanoidStateType.Physics) -- Ensures it follows physics
        end
        if not ghostClone.PrimaryPart then
            local hrp = ghostClone:FindFirstChild("HumanoidRootPart")
            if hrp then ghostClone.PrimaryPart = hrp else warn("Clone HRP not found!") end
        end
        for _, part in ipairs(ghostClone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1; part.CanCollide = false; part.Anchored = false; part.CanQuery = false
            elseif part:IsA("Decal") then part.Transparency = 1
            elseif part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then handle.Transparency = 1; handle.CanCollide = false; handle.CanQuery = false end
            end
        end
        local animate = originalCharacter:FindFirstChild("Animate")
        if animate then originalAnimateScript = animate; originalAnimateScript.Disabled = true; originalAnimateScript.Parent = ghostClone end
        preserveGuis()
        ghostClone.Parent = Workspace
        LocalPlayer.Character = ghostClone
        if ghostHumanoid then Workspace.CurrentCamera.CameraSubject = ghostHumanoid end
        restoreGuis()
        if originalAnimateScript and originalAnimateScript.Parent == ghostClone then originalAnimateScript.Disabled = false end
        ReplicatedStorage.RagdollEvent:FireServer() -- Assuming this event handles ragdoll physics/state on the server

        -- Initialize positions
        targetPositions = {}
        previousPositions = {}
        lastUpdateTime = tick()

        -- Disconnect existing connections if any
        if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
        if renderStepConnection then renderStepConnection:Disconnect(); renderStepConnection = nil end

        -- Use Heartbeat for physics-related updates
        updateConnection = RunService.Heartbeat:Connect(updateSnakeParts)
        -- RenderStepped connection removed as Heartbeat should suffice and simplifies logic

    else -- Disabling
        if not originalCharacter or not ghostClone then return end -- Already disabled or in weird state
        if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
        if renderStepConnection then renderStepConnection:Disconnect(); renderStepConnection = nil end -- Just in case

        ReplicatedStorage.UnragdollEvent:FireServer() -- Assuming this reverses the server-side ragdoll state

        local targetCFrame = originalCFrame
        local ghostPrimary = ghostClone.PrimaryPart
        if ghostPrimary then targetCFrame = ghostPrimary.CFrame else warn("Clone PrimaryPart not found for CFrame!") end

        local animate = ghostClone:FindFirstChild("Animate")
        if animate then animate.Disabled = true; animate.Parent = originalCharacter end -- Move Animate script back

        ghostClone:Destroy(); ghostClone = nil -- Destroy the clone

        if originalCharacter and originalCharacter.Parent then
            local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
            local origHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")

            if origRoot then
                 origRoot.CFrame = targetCFrame -- Restore position
                 origRoot.AssemblyLinearVelocity = Vector3.zero -- Stop movement
                 origRoot.AssemblyAngularVelocity = Vector3.zero
            end
            preserveGuis()
            LocalPlayer.Character = originalCharacter -- Assign control back
            if origHumanoid then
                 Workspace.CurrentCamera.CameraSubject = origHumanoid -- Restore camera
                 origHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp) -- Trigger get up animation
            end
            restoreGuis()
            if animate and animate.Parent == originalCharacter then task.wait(0.1); animate.Disabled = false end -- Re-enable Animate script
        else
            print("Original character lost during disable.")
        end
        originalCharacter = nil; originalAnimateScript = nil
    end
end

-- Create GUI (Modified for black theme with transparency)
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SnakeReanimationGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame (Smaller)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 140) -- Reduced Height
    frame.Position = UDim2.new(0.5, -130, 0.1, 0) -- Centered
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Darker black theme
    frame.BackgroundTransparency = 0.5-- Slight transparency
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.Active = true -- Allows detecting input within frame bounds
    frame.Draggable = false -- Dragging handled by title bar

    -- Add UIStroke to main frame
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(80, 80, 80)
    frameStroke.Thickness = 1
    frameStroke.Parent = frame

    -- Title bar for dragging the window
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Slightly lighter dark gray
    titleBar.BackgroundTransparency = 0.4 -- Slight transparency
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    titleBar.Active = true -- Make sure title bar can capture input

    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -35, 1, 0) -- Leave space for close button
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Snake Reanimation"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Drag functionality for the title bar
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragging = false
        end
    end)

    -- Use UserInputService.InputChanged for smoother dragging updates
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    -- Enable/Disable Button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0.5, 0, 0, 40) -- Position below title bar
    button.AnchorPoint = Vector2.new(0.5, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 100, 30) -- Dark green for "Enable"
    button.Text = "Enable Snake Reanimation"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button

    -- Add UIStroke to enable/disable button
    

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -5, 0.5, 0) -- Top right of title bar
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton

    -- Add UIStroke to close button
    

    -- Slider Helper Function (Mobile Friendly)
    local function createSlider(parent, yPosition, labelText, minValue, maxValue, defaultValue, valueChangedCallback)
        local sliderY = yPosition
        local sliderHeight = 20
        local knobSize = 16
        local currentValue = defaultValue

        -- Container for the entire slider
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Size = UDim2.new(1, -20, 0, sliderHeight)
        sliderContainer.Position = UDim2.new(0, 10, 0, sliderY) -- Use X=10 for padding
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.Parent = parent

        -- Label
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 60, 1, 0) -- Use full height
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText .. ":"
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = sliderContainer

        -- Value Display
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 40, 1, 0) -- Use full height
        valueLabel.Position = UDim2.new(1, 0, 0, 0)
        valueLabel.AnchorPoint = Vector2.new(1, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = string.format("%.2f", defaultValue) -- Format to 2 decimals
        valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.TextYAlignment = Enum.TextYAlignment.Center
        valueLabel.Parent = sliderContainer

        -- Slider Track
        local sliderTrack = Instance.new("Frame")
        sliderTrack.Size = UDim2.new(1, -110, 0, 4) -- Width relative to container minus labels/padding
        sliderTrack.Position = UDim2.new(0, 65, 0.5, 0) -- Position after label + padding
        sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
        sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        sliderTrack.BorderSizePixel = 0
        sliderTrack.Parent = sliderContainer
        sliderTrack.Active = true -- Enable input detection

        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0, 2)
        trackCorner.Parent = sliderTrack

        -- Slider Knob
        local sliderKnob = Instance.new("Frame")
        sliderKnob.Size = UDim2.new(0, knobSize, 0, knobSize)
        sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5) -- Center anchor for positioning
        sliderKnob.BackgroundColor3 = Color3.fromRGB(180, 180, 180) -- Light gray for contrast
        sliderKnob.BorderSizePixel = 0
        sliderKnob.ZIndex = 2
        sliderKnob.Parent = sliderContainer
        sliderKnob.Active = true -- Enable input detection

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(0, knobSize/2)
        knobCorner.Parent = sliderKnob

        -- Add UIStroke to slider knob
        
        -- Function to update knob position based on value
        local function updateKnobPosition()
            local ratio = (currentValue - minValue) / (maxValue - minValue)
            local trackWidth = sliderTrack.AbsoluteSize.X
            local knobX = sliderTrack.Position.X.Offset + ratio * trackWidth
            sliderKnob.Position = UDim2.new(0, knobX, 0.5, 0)
        end

        -- Initialize knob position
        task.defer(updateKnobPosition) -- Defer ensures AbsoluteSize is calculated
        sliderTrack:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateKnobPosition) -- Update if size changes

        -- Slider Functionality
        local isDraggingSlider = false
        local sliderDragInput = nil

        local function updateValueFromInput(inputPos)
            local trackStart = sliderTrack.AbsolutePosition.X
            local trackWidth = sliderTrack.AbsoluteSize.X
            local trackEnd = trackStart + trackWidth

            if trackWidth <= 0 then return end -- Avoid division by zero

            local clampedX = math.clamp(inputPos.X, trackStart, trackEnd)
            local relativeX = clampedX - trackStart
            local ratio = relativeX / trackWidth

            currentValue = minValue + ratio * (maxValue - minValue)
            currentValue = math.floor(currentValue * 100 + 0.5) / 100 -- Round to 2 decimal places

            valueLabel.Text = string.format("%.2f", currentValue)
            updateKnobPosition() -- Update knob based on the new value

            if valueChangedCallback then
                valueChangedCallback(currentValue)
            end
        end

        -- Combined Input Handler for Track and Knob
        local function handleInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingSlider = true
                sliderDragInput = input -- Store the input object
                updateValueFromInput(input.Position) -- Update value immediately on click/tap
            end
        end

        sliderKnob.InputBegan:Connect(handleInputBegan)
        sliderTrack.InputBegan:Connect(handleInputBegan)

        -- Use UserInputService for global tracking of movement and release
        UserInputService.InputChanged:Connect(function(input)
            if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateValueFromInput(input.Position)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                isDraggingSlider = false
                sliderDragInput = nil
            end
        end)

        -- Function to update the slider from outside (e.g., loading settings)
        local function updateSliderExternally(newValue)
            currentValue = math.clamp(newValue, minValue, maxValue)
            valueLabel.Text = string.format("%.2f", currentValue)
            updateKnobPosition()
        end

        return updateSliderExternally -- Return the function to update externally if needed
    end

    -- Create Slider for Snake Distance ONLY
    local distanceSlider = createSlider(frame, 80, "Distance", MIN_DISTANCE, MAX_DISTANCE, snakeDistance, function(value)
        snakeDistance = value
    end)

    -- Swing Toggle Button
    local swingButton = Instance.new("TextButton")
    swingButton.Size = UDim2.new(1, -20, 0, 28)
    swingButton.Position = UDim2.new(0, 10, 0, 110)
    swingButton.BackgroundColor3 = Color3.fromRGB(30, 60, 100) -- Dark blue for "ON"
    swingButton.Text = "Swing: ON"
    swingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    swingButton.Font = Enum.Font.GothamBold
    swingButton.TextSize = 14
    swingButton.Parent = frame

    local swingCorner = Instance.new("UICorner")
    swingCorner.CornerRadius = UDim.new(0, 8)
    swingCorner.Parent = swingButton

    -- Add UIStroke to swing button
    
    local function updateSwingButton()
        swingButton.Text = swingEnabled and "Swing: ON" or "Swing: OFF"
        swingButton.BackgroundColor3 = swingEnabled and Color3.fromRGB(30, 60, 100) or Color3.fromRGB(60, 60, 60)
    end

    swingButton.MouseButton1Click:Connect(function()
        swingEnabled = not swingEnabled
        updateSwingButton()
    end)
    updateSwingButton()

    -- Button Event Handlers
    button.MouseButton1Click:Connect(function()
        local newState = not ghostEnabled
        setGhostEnabled(newState)
        button.BackgroundColor3 = newState and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(30, 100, 30)
        button.Text = newState and "Disable Snake Reanimation" or "Enable Snake Reanimation"
    end)

    closeButton.MouseButton1Click:Connect(function()
        -- Ensure disabled before destroying GUI
        if ghostEnabled then
            setGhostEnabled(false)
            button.BackgroundColor3 = Color3.fromRGB(30, 100, 30) -- Reset button state visually
            button.Text = "Enable Snake Reanimation"
        end
        screenGui:Destroy()
    end)

    screenGui.Parent = LocalPlayer:FindFirstChildWhichIsA("PlayerGui") or Players.PlayerGui -- Add to PlayerGui
    return screenGui
end

-- Initialisiere das Script
local gui = createGui()

-- Cleanup beim Beenden
local screenGui = gui -- Reference the created GUI
local function cleanup()
    print("Cleaning up Snake Reanimation script...")
    if ghostEnabled then
        setGhostEnabled(false) -- Attempt to disable the effect
    end
    if screenGui and screenGui.Parent then
        screenGui:Destroy() -- Destroy the GUI
    end
    -- Disconnect RunService connections if they might still exist somehow
    if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
    if renderStepConnection then renderStepConnection:Disconnect(); renderStepConnection = nil end
end

-- Connect cleanup to script removal
script.Destroying:Connect(cleanup)

-- Optional: Connect cleanup if the character resets (might be redundant with ResetOnSpawn=false)
if LocalPlayer.Character then
    LocalPlayer.Character.Destroying:Connect(function()
        if ghostEnabled then
            -- If the character is destroyed while active, we might need immediate cleanup
            if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
            if renderStepConnection then renderStepConnection:Disconnect(); renderStepConnection = nil end
            if ghostClone then ghostClone:Destroy(); ghostClone = nil end
            originalCharacter = nil -- Prevent trying to re-enable on a destroyed character
            ghostEnabled = false
            if gui then -- Reset button state if GUI still exists
                local button = gui:FindFirstChild("Frame", true):FindFirstChild("TextButton", true)
                if button then
                     button.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
                     button.Text = "Enable Snake Reanimation"
                end
            end
        end
    end)
end
