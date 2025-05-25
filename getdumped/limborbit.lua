-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Configuration

-- Body parts to potentially offset and sync
local bodyParts = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
    "HumanoidRootPart"
}

-- Vertical offsets (ignored for hands when circling)
local partVerticalOffsets = {
    ["Head"] = 0, ["UpperTorso"] = 0, ["LowerTorso"] = 0,
    ["LeftUpperArm"] = 0, ["LeftLowerArm"] = 0, ["LeftHand"] = 0,
    ["RightUpperArm"] = 0, ["RightLowerArm"] = 0, ["RightHand"] = 0,
    ["LeftUpperLeg"] = 0, ["LeftLowerLeg"] = 0, ["LeftFoot"] = 0,
    ["RightUpperLeg"] = 0, ["RightLowerLeg"] = 0, ["RightFoot"] = 0,
    ["HumanoidRootPart"]= 0
}

-- Hand Circling Configuration (Defaults, will be controlled by GUI)
local enableHandCircling = true
local circleRadius = 1.5       -- Default Radius (Studs)
local circleSpeed = 2          -- Default Speed (Radians/sec)
local circleVerticalOffset = 0.5 -- Default Vertical Offset (Studs, Positive = higher)

-- Slider Configuration
local MIN_RADIUS = 0.01 -- Minimum Radius, almost touching the head
local MAX_RADIUS = 100.0  -- Maximum Radius set to 100
local MIN_SPEED = -100.0 -- Minimum Speed set to -100
local MAX_SPEED = 100.0  -- Maximum Speed set to 100
local MIN_HEIGHT = -100.0 -- Minimum Height set to -100
local MAX_HEIGHT = 100.0  -- Maximum Height set to 100


-- State variables
local ghostEnabled = false
local originalCharacter
local ghostClone
local originalCFrame
local originalAnimateScript
local updateConnection
local currentCircleAngle = 0

-- GUI preservation functions (unverändert)
local preservedGuis = {}
local function preserveGuis()
    local playerGui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "LimborbitGui" and gui.ResetOnSpawn then
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

-- Update Ragdolled Parts (unverändert von vorheriger Version)
local function updateRagdolledParts(dt)
    if not ghostEnabled or not originalCharacter or not originalCharacter.Parent or not ghostClone or not ghostClone.Parent then
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        return
    end

    if enableHandCircling then
        currentCircleAngle = (currentCircleAngle + circleSpeed * dt) % (2 * math.pi)
    end

    local originalHead = originalCharacter:FindFirstChild("Head")

    for _, partName in ipairs(bodyParts) do
        local originalPart = originalCharacter:FindFirstChild(partName)
        local clonePart = ghostClone:FindFirstChild(partName)

        if originalPart and clonePart then
            local targetCFrame

            if enableHandCircling and originalHead and (partName == "LeftHand" or partName == "RightHand" or partName == "LeftFoot" or partName == "RightFoot") then
                local headPos = originalHead.Position
                local angleOffset = 0

                -- Winkelversatz für verschiedene Körperteile
                if partName == "LeftHand" then
                    angleOffset = math.pi
                elseif partName == "RightHand" then
                    angleOffset = 0
                elseif partName == "LeftFoot" then
                    angleOffset = math.pi/2 -- 90 Grad versetzt
                elseif partName == "RightFoot" then
                    angleOffset = 3*math.pi/2 -- 270 Grad versetzt
                end

                local partAngle = currentCircleAngle + angleOffset

                local offsetX = circleRadius * math.cos(partAngle)
                local offsetZ = circleRadius * math.sin(partAngle)
                local targetPosition = headPos + Vector3.new(offsetX, circleVerticalOffset, offsetZ)

                local rotation = clonePart.CFrame - clonePart.Position
                targetCFrame = CFrame.new(targetPosition) * rotation
            else
                local verticalOffset = partVerticalOffsets[partName] or 0
                local targetPosition = clonePart.Position + Vector3.new(0, -verticalOffset, 0)
                local rotation = clonePart.CFrame - clonePart.Position
                targetCFrame = CFrame.new(targetPosition) * rotation
            end

            originalPart.CFrame = targetCFrame
            originalPart.AssemblyLinearVelocity = Vector3.zero
            originalPart.AssemblyAngularVelocity = Vector3.zero

        elseif originalPart and partName == "HumanoidRootPart" and ghostClone.PrimaryPart and not clonePart then
             warn("Klon HumanoidRootPart nicht gefunden, benutze Klon PrimaryPart als Referenz für originalen HRP.")
             local verticalOffset = partVerticalOffsets[partName] or 0
             local targetPosition = ghostClone.PrimaryPart.Position + Vector3.new(0, -verticalOffset, 0)
             local rotation = ghostClone.PrimaryPart.CFrame - ghostClone.PrimaryPart.Position
             local targetCFrame = CFrame.new(targetPosition) * rotation
             originalPart.CFrame = targetCFrame
             originalPart.AssemblyLinearVelocity = Vector3.zero
             originalPart.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

-- Toggle ghost mode (unverändert von vorheriger Version)
local function setGhostEnabled(newState)
    ghostEnabled = newState

    if ghostEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        if originalCharacter or ghostClone then return end

        originalCharacter = char
        originalCFrame = root.CFrame
        char.Archivable = true
        ghostClone = char:Clone()
        char.Archivable = false
        ghostClone.Name = originalCharacter.Name .. "_clone"
        local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
        if ghostHumanoid then
            ghostHumanoid.DisplayName = originalCharacter.Name .. "_clone"
            ghostHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
        if not ghostClone.PrimaryPart then
            local hrp = ghostClone:FindFirstChild("HumanoidRootPart")
            if hrp then ghostClone.PrimaryPart = hrp else warn("Klon HRP nicht gefunden!") end
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
        ReplicatedStorage.RagdollEvent:FireServer()
        currentCircleAngle = 0
        if updateConnection then updateConnection:Disconnect() end
        updateConnection = RunService.Heartbeat:Connect(updateRagdolledParts)
    else
        if not originalCharacter or not ghostClone then return end
        if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
        for i = 1, 3 do ReplicatedStorage.UnragdollEvent:FireServer(); task.wait(0.1) end
        local targetCFrame = originalCFrame
        local ghostPrimary = ghostClone.PrimaryPart
        if ghostPrimary then targetCFrame = ghostPrimary.CFrame else warn("Klon PrimaryPart nicht gefunden!") end
        local animate = ghostClone:FindFirstChild("Animate")
        if animate then animate.Disabled = true; animate.Parent = originalCharacter end
        ghostClone:Destroy(); ghostClone = nil
        if originalCharacter and originalCharacter.Parent then
            local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
            local origHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")
            if origRoot then origRoot.CFrame = targetCFrame; origRoot.AssemblyLinearVelocity = Vector3.zero; origRoot.AssemblyAngularVelocity = Vector3.zero end
            preserveGuis()
            LocalPlayer.Character = originalCharacter
            if origHumanoid then Workspace.CurrentCamera.CameraSubject = origHumanoid; origHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
            restoreGuis()
            if animate and animate.Parent == originalCharacter then task.wait(0.1); animate.Disabled = false end
        else print("Originaler Charakter verloren.") end
        originalCharacter = nil; originalAnimateScript = nil
    end
end


-- *** MODIFIED FUNCTION: createGui ***
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LimborbitGui" -- Changed GUI Name
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Wichtig für Slider-Knopf über Track

    -- Haupt-Frame (größer machen für Slider)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 205) -- Höhe für dritten Slider angepasst
    frame.Position = UDim2.new(0.5, -125, 0.1, 0) -- Zentriert
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.Active = true
    frame.Draggable = false -- Nicht mehr draggable, stattdessen Titelleiste verwenden

    -- Titelleiste zum Ziehen des Fensters
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    -- Titeltext
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -35, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Limborbit" -- Changed GUI Title Text
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextSize = 14
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Drag-Funktionalität für die Titelleiste
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then -- Mobile Drag Support
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then -- Mobile Drag Support
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then -- Mobile Drag Support
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

    -- Enable/Disable Button (unter der Titelleiste)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30) -- Höhe angepasst, etwas Platz lassen
    button.Position = UDim2.new(0.5, 0, 0, 40) -- Unter der Titelleiste
    button.AnchorPoint = Vector2.new(0.5, 0)
    button.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    button.Text = "Enable Limborbit" -- Changed Button Text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button

    -- Close Button (Position relativ zur Titelleiste)
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -5, 0.5, 0) -- Rechts in der Titelleiste
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

    -- --- Slider Helper Function (Neu implementiert und für Mobile angepasst) ---
    local function createSlider(parent, yPosition, labelText, minValue, maxValue, defaultValue, valueChangedCallback)
        local sliderY = yPosition
        local sliderHeight = 20
        local knobSize = 16
        local currentValue = defaultValue

        -- Container für den gesamten Slider (für bessere Organisation)
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Size = UDim2.new(1, -20, 0, sliderHeight)
        sliderContainer.Position = UDim2.new(0, 10, 0, sliderY)
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.Parent = parent

        -- Label
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 60, 0, sliderHeight)
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
        valueLabel.Size = UDim2.new(0, 40, 0, sliderHeight)
        valueLabel.Position = UDim2.new(1, 0, 0, 0)
        valueLabel.AnchorPoint = Vector2.new(1, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.TextYAlignment = Enum.TextYAlignment.Center
        valueLabel.Text = string.format("%.2f", defaultValue) -- Display 2 decimal places
        valueLabel.Parent = sliderContainer

        -- Track Container (für bessere Mausinteraktion)
        local trackContainer = Instance.new("Frame")
        trackContainer.Size = UDim2.new(1, -110, 0, sliderHeight)
        trackContainer.Position = UDim2.new(0, 65, 0, 0)
        trackContainer.BackgroundTransparency = 1
        trackContainer.Parent = sliderContainer

        -- Track Frame
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6)
        track.Position = UDim2.new(0, 0, 0.5, 0)
        track.AnchorPoint = Vector2.new(0, 0.5)
        track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        track.BorderSizePixel = 0
        track.Parent = trackContainer

        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track

        -- Knob Button
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, knobSize, 0, knobSize)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        knob.BorderSizePixel = 0
        knob.Text = ""
        knob.AutoButtonColor = false
        knob.ZIndex = 2
        knob.Parent = trackContainer

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob

        -- Funktion zum Aktualisieren der Slider-Anzeige basierend auf dem Wert
        local function updateSliderFromValue(value)
            currentValue = value
            local fraction = (value - minValue) / (maxValue - minValue)
            fraction = math.clamp(fraction, 0, 1)
            knob.Position = UDim2.new(fraction, 0, 0.5, 0)
            valueLabel.Text = string.format("%.2f", value) -- Display 2 decimal places
        end

        -- Funktion zum Aktualisieren des Werts basierend auf der Mausposition
        local function updateValueFromPosition(mouseX)
            local trackAbsPos = trackContainer.AbsolutePosition.X
            local trackAbsSize = trackContainer.AbsoluteSize.X
            local relativeX = mouseX - trackAbsPos
            local fraction = math.clamp(relativeX / trackAbsSize, 0, 1)
            local newValue = minValue + fraction * (maxValue - minValue)
            updateSliderFromValue(newValue)
            valueChangedCallback(newValue)
        end

        -- Mausinteraktionen (Mobile Support hinzugefügt)
        local isDragging = false

        knob.InputBegan:Connect(function(input) -- Mobile Support
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
            end
        end)

        trackContainer.InputBegan:Connect(function(input) -- Mobile Support
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                updateValueFromPosition(input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then -- Mobile Support
                isDragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then -- Mobile Support
                updateValueFromPosition(input.Position.X)
            end
        end)

        -- Initialisierung
        updateSliderFromValue(defaultValue)

        return {
            Container = sliderContainer,
            Track = track,
            Knob = knob,
            Label = label,
            ValueLabel = valueLabel,
            UpdateValue = updateSliderFromValue,
            GetValue = function() return currentValue end
        }
    end
    -- --- End Slider Helper Function ---

    -- Erstelle Radius Slider
    local radiusSliderY = 85 -- Y-Position für den Radius-Slider (unter dem Button)
    local radiusSlider = createSlider(frame, radiusSliderY, "Radius", MIN_RADIUS, MAX_RADIUS, circleRadius, function(newValue)
        circleRadius = newValue -- Aktualisiere die globale Variable
    end)

    -- Erstelle Speed Slider
    local speedSliderY = radiusSliderY + 40 -- Y-Position für den Speed-Slider (unter dem Radius-Slider)
    local speedSlider = createSlider(frame, speedSliderY, "Speed", MIN_SPEED, MAX_SPEED, circleSpeed, function(newValue)
        circleSpeed = newValue -- Aktualisiere die globale Variable
    end)

    -- Erstelle Height Slider
    local heightSliderY = speedSliderY + 40 -- Y-Position für den Height-Slider (unter dem Speed-Slider)
    local heightSlider = createSlider(frame, heightSliderY, "Höhe", MIN_HEIGHT, MAX_HEIGHT, circleVerticalOffset, function(newValue)
        circleVerticalOffset = newValue -- Aktualisiere die globale Variable
    end)

    -- --- Event Connections für Haupt-Buttons ---
    closeButton.MouseButton1Click:Connect(function()
        if ghostEnabled then
            setGhostEnabled(false)
            if button and button.Parent then
                button.Text = "Enable Limborbit" -- Changed Button Text
                button.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            end
            task.wait(0.5)
        end
        screenGui:Destroy()
    end)

    button.MouseButton1Click:Connect(function()
        local newState = not ghostEnabled
        setGhostEnabled(newState)

        if button and button.Parent then
            if newState then
                button.Text = "Disable Limborbit" -- Changed Button Text
                button.BackgroundColor3 = Color3.fromRGB(211, 47, 47)
            else
                button.Text = "Enable Limborbit" -- Changed Button Text
                button.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            end
        end
    end)

    return screenGui
end

-- Initialize GUI and Cleanup (unverändert)
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local existingGui = playerGui:FindFirstChild("LimborbitGui") -- Changed GUI Name Check
if existingGui then
    print("Alte Limborbit GUI gefunden, wird entfernt.")
    existingGui:Destroy()
end

print("Erstelle neue Limborbit GUI mit Slidern.") -- Changed Log Message
local gui = createGui()
gui.Parent = playerGui

script.Destroying:Connect(function()
    print("Limborbit Skript wird zerstört. Räume auf...") -- Changed Log Message
    if ghostEnabled then
        setGhostEnabled(false)
    end
    if gui and gui.Parent then
        gui:Destroy()
    else
        local possiblyExistingGui = playerGui:FindFirstChild("LimborbitGui") -- Changed GUI Name Check
        if possiblyExistingGui then
            possiblyExistingGui:Destroy()
        end
    end
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    print("Aufräumen abgeschlossen.")
end)

print("Limborbit Skript geladen. Radius und Speed über GUI einstellbar.") -- Changed Log Message
