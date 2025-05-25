local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- GUI Erstellung
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local UIGradient = Instance.new("UIGradient")
local DragBar = Instance.new("Frame")
local UICornerDrag = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local UICornerClose = Instance.new("UICorner")
local ToggleButton = Instance.new("TextButton")
local UICornerToggle = Instance.new("UICorner")
local ToggleButtonGradient = Instance.new("UIGradient")

-- Keybind Section
local KeybindSection = Instance.new("Frame")
local KeybindTitle = Instance.new("TextLabel")
local KeybindButton = Instance.new("TextButton")
local UICornerKeybind = Instance.new("UICorner")
local KeybindButtonStroke = Instance.new("UIStroke")

-- Sound Effects
local ClickSound = Instance.new("Sound")
local HoverSound = Instance.new("Sound")

-- GUI zum CoreGui hinzufügen
ScreenGui.Name = "InvisibleGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Sound Effects konfigurieren
ClickSound.Name = "ClickSound"
ClickSound.Parent = ScreenGui
ClickSound.SoundId = "rbxassetid://6895079853"
ClickSound.Volume = 0.5

HoverSound.Name = "HoverSound"
HoverSound.Parent = ScreenGui
HoverSound.SoundId = "rbxassetid://6895079733"
HoverSound.Volume = 0.3

-- Hauptframe
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Position = UDim2.new(0.5, -75, 0.5, -65)
MainFrame.Size = UDim2.new(0, 150, 0, 130)
MainFrame.ClipsDescendants = true

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 8)

UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(100, 100, 100)
UIStroke.Thickness = 1.2
UIStroke.Transparency = 0.3

UIGradient.Parent = MainFrame
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
}
UIGradient.Rotation = 45

-- DragBar
DragBar.Name = "DragBar"
DragBar.Parent = MainFrame
DragBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
DragBar.BackgroundTransparency = 0.3
DragBar.Size = UDim2.new(1, 0, 0, 24)
DragBar.BorderSizePixel = 0

UICornerDrag.Parent = DragBar
UICornerDrag.CornerRadius = UDim.new(0, 8)

-- Titel
Title.Parent = DragBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -24, 1, 0)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Invisible"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
CloseButton.Parent = DragBar
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseButton.BackgroundTransparency = 0.2
CloseButton.Position = UDim2.new(1, -20, 0.5, -7)
CloseButton.Size = UDim2.new(0, 14, 0, 14)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12

UICornerClose.Parent = CloseButton
UICornerClose.CornerRadius = UDim.new(0, 4)

-- Keybind Section
KeybindSection.Name = "KeybindSection"
KeybindSection.Parent = MainFrame
KeybindSection.BackgroundTransparency = 1
KeybindSection.Position = UDim2.new(0, 0, 0, 30)
KeybindSection.Size = UDim2.new(1, 0, 0, 45)

KeybindTitle.Parent = KeybindSection
KeybindTitle.BackgroundTransparency = 1
KeybindTitle.Position = UDim2.new(0, 10, 0, 0)
KeybindTitle.Size = UDim2.new(1, -20, 0, 20)
KeybindTitle.Font = Enum.Font.Gotham
KeybindTitle.Text = "Toggle Keybind:"
KeybindTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
KeybindTitle.TextSize = 12
KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left

KeybindButton.Parent = KeybindSection
KeybindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KeybindButton.BackgroundTransparency = 0.1
KeybindButton.Position = UDim2.new(0.5, -40, 0, 22)
KeybindButton.Size = UDim2.new(0, 80, 0, 20)
KeybindButton.Font = Enum.Font.Gotham
KeybindButton.Text = "None"
KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindButton.TextSize = 12

UICornerKeybind.Parent = KeybindButton
UICornerKeybind.CornerRadius = UDim.new(0, 4)

KeybindButtonStroke.Parent = KeybindButton
KeybindButtonStroke.Color = Color3.fromRGB(80, 80, 80)
KeybindButtonStroke.Thickness = 1
KeybindButtonStroke.Transparency = 0.5

-- Toggle Button
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 180, 45)
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.Position = UDim2.new(0.5, -50, 0, 85)
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "ACTIVATE"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14

UICornerToggle.Parent = ToggleButton
UICornerToggle.CornerRadius = UDim.new(0, 5)

ToggleButtonGradient.Parent = ToggleButton
ToggleButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 180, 45)), 
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 150, 35))
}
ToggleButtonGradient.Rotation = 90

-- Variablen
local Dragging = false
local DragStart = nil
local StartPos = nil
local BodyLifted = false
local UpdateConnection = nil
local CurrentKeybind = nil
local ListeningForKeybind = false

-- HRP Fixierung
local initialHrpPosition = nil
local hrpFixationActive = false
local hrpFixationStartTime = 0
local HRP_FIXATION_DURATION = 0.4 -- Dauer der HRP Fixierung

-- Kamera Fixierung
local initialCameraCFrame = nil
local originalCameraType = nil
local cameraFixationActive = false
local cameraFixationStartTime = 0
local CAMERA_FIXATION_DURATION = 0.5 -- Dauer der Kamera Fixierung

-- Liste der Körperteile die angehoben werden
local bodyParts = {
    "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg",
    "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "Head"
}

-- Sound Effects Play Function
local function PlayClickSound()
    ClickSound:Play()
end

local function PlayHoverSound()
    if not HoverSound.IsPlaying then
        HoverSound:Play()
    end
end

-- Hover Effects
local function ApplyHoverEffect(button)
    button.MouseEnter:Connect(function()
        PlayHoverSound()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundTransparency = 0})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local transparency = button == ToggleButton and 0.1 or 0.2
        local tween = TweenService:Create(button, tweenInfo, {BackgroundTransparency = transparency})
        tween:Play()
    end)
end

-- Apply hover effects to buttons
ApplyHoverEffect(ToggleButton)
ApplyHoverEffect(CloseButton)
ApplyHoverEffect(KeybindButton)

-- Drag Funktionalität (für PC und Mobile)
local function BeginDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end

local function DoDrag(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                    input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + delta.X,
            StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
        )
    end
end

DragBar.InputBegan:Connect(BeginDrag)
UserInputService.InputChanged:Connect(DoDrag)

local function resetCamera()
    local camera = Workspace.CurrentCamera
    if camera and originalCameraType then
        camera.CameraType = originalCameraType
    elseif camera then
        camera.CameraType = Enum.CameraType.Custom -- Fallback
    end
    cameraFixationActive = false
    initialCameraCFrame = nil
    originalCameraType = nil
end

-- Close Button Funktion
CloseButton.MouseButton1Click:Connect(function()
    PlayClickSound()
    if BodyLifted then
        BodyLifted = false
        hrpFixationActive = false
        resetCamera() -- Kamera zurücksetzen
        if UpdateConnection then
            UpdateConnection:Disconnect()
            UpdateConnection = nil
        end
        local player = Players.LocalPlayer
        local character = player and player.Character
        if character then
             if ReplicatedStorage:FindFirstChild("UnragdollEvent") then
                ReplicatedStorage.UnragdollEvent:FireServer()
            end
        end
    end
    ScreenGui:Destroy()
end)

-- Body Update Funktion
local function UpdateBody()
    local player = Players.LocalPlayer
    local character = player and player.Character
    local camera = Workspace.CurrentCamera

    if not character or not camera then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then return end
    
    if humanoid:GetState() ~= Enum.HumanoidStateType.Physics and humanoid:GetState() ~= Enum.HumanoidStateType.Ragdoll then
        humanoid.WalkSpeed = 16
    end
    
    -- Kamera Fixierung
    if cameraFixationActive then
        if (tick() - cameraFixationStartTime) < CAMERA_FIXATION_DURATION then
            if initialCameraCFrame then
                camera.CFrame = initialCameraCFrame
            end
        else
            resetCamera()
        end
    end

    -- HumanoidRootPart Fixierung
    if hrpFixationActive then
        if (tick() - hrpFixationStartTime) < HRP_FIXATION_DURATION then
            if initialHrpPosition then
                humanoidRootPart.CFrame = CFrame.new(initialHrpPosition)
                humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
            end
        else
            hrpFixationActive = false
        end
    end
            
    -- Körperteile anheben
    if BodyLifted then
        for _, partName in ipairs(bodyParts) do
            local part = character:FindFirstChild(partName)
            if part and part ~= humanoidRootPart then
                part.CFrame = part.CFrame * CFrame.new(0, 10000, 0)
                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

-- Toggle Button Funktion
ToggleButton.MouseButton1Click:Connect(function()
    PlayClickSound()
    local player = Players.LocalPlayer
    local character = player and player.Character
    local camera = Workspace.CurrentCamera

    if not character or not camera then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    BodyLifted = not BodyLifted
    
    if BodyLifted then
        ToggleButton.Text = "DEACTIVATE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        ToggleButtonGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 75, 75)), 
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 60, 60))
        }
        
        -- HRP Position speichern und SOFORT fixieren
        initialHrpPosition = humanoidRootPart.Position 
        humanoidRootPart.CFrame = CFrame.new(initialHrpPosition)
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
        hrpFixationActive = true
        hrpFixationStartTime = tick()

        -- Kamera CFrame speichern und SOFORT fixieren
        initialCameraCFrame = camera.CFrame
        originalCameraType = camera.CameraType -- Ursprünglichen Kameratyp speichern
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = initialCameraCFrame -- Sofort anwenden
        cameraFixationActive = true
        cameraFixationStartTime = tick()
        
        -- Start Update Loop
        if UpdateConnection then
            UpdateConnection:Disconnect()
        end
        UpdateConnection = RunService.Heartbeat:Connect(UpdateBody)
        
        if ReplicatedStorage:FindFirstChild("RagdollEvent") then
            ReplicatedStorage.RagdollEvent:FireServer()
        end
    else
        ToggleButton.Text = "ACTIVATE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 180, 45)
        ToggleButtonGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 180, 45)), 
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 150, 35))
        }
        
        hrpFixationActive = false
        resetCamera() -- Kamera beim Deaktivieren sofort zurücksetzen
        
        if UpdateConnection then
            UpdateConnection:Disconnect()
            UpdateConnection = nil
        end
        
        if character then
            for _, partName in ipairs(bodyParts) do
                local part = character:FindFirstChild(partName)
                if part and part ~= humanoidRootPart then
                    part.CFrame = part.CFrame * CFrame.new(0, -10000, 0)
                end
            end
        end
        
        if ReplicatedStorage:FindFirstChild("UnragdollEvent") then
            ReplicatedStorage.UnragdollEvent:FireServer()
        end
    end
end)

-- Keybind functionality
KeybindButton.MouseButton1Click:Connect(function()
    PlayClickSound()
    if ListeningForKeybind then return end
    
    ListeningForKeybind = true
    KeybindButton.Text = "Press a key..."
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            CurrentKeybind = input.KeyCode
            KeybindButton.Text = input.KeyCode.Name
            ListeningForKeybind = false
            connection:Disconnect()
        end
    end)
end)

-- Listen for keybind press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and CurrentKeybind and input.KeyCode == CurrentKeybind then
        ToggleButton.MouseButton1Click:Fire()
    end
end)
