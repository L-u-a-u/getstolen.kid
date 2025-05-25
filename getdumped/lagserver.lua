local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToolManagerGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 120)
mainFrame.Position = UDim2.new(0.8, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.BackgroundTransparency = 0.5

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0, 100, 0, 30)
titleText.Position = UDim2.new(0, 10, 0, 5)
titleText.BackgroundTransparency = 1
titleText.Text = "Lag Server"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = mainFrame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 24, 0, 24)
minimizeButton.Position = UDim2.new(1, -52, 0, 8)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 14
minimizeButton.Parent = mainFrame

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -26, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -40)
contentFrame.Position = UDim2.new(0, 10, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 180, 0, 30)
toggleButton.Position = UDim2.new(0.5, -90, 0, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.TextSize = 14
toggleButton.Parent = contentFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = toggleButton

local auraFrame = Instance.new("Frame")
auraFrame.Name = "AuraFrame"
auraFrame.Size = UDim2.new(1, 0, 0, 30)
auraFrame.Position = UDim2.new(0, 0, 0, 45)
auraFrame.BackgroundTransparency = 1
auraFrame.Parent = contentFrame

local auraCheckbox = Instance.new("Frame")
auraCheckbox.Name = "AuraCheckbox"
auraCheckbox.Size = UDim2.new(0, 24, 0, 24)
auraCheckbox.Position = UDim2.new(0, 0, 0.5, -12)
auraCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
auraCheckbox.BorderSizePixel = 0
auraCheckbox.Parent = auraFrame

local checkboxCorner = Instance.new("UICorner")
checkboxCorner.CornerRadius = UDim.new(0, 4)
checkboxCorner.Parent = auraCheckbox

local checkboxIndicator = Instance.new("Frame")
checkboxIndicator.Name = "CheckboxIndicator"
checkboxIndicator.Size = UDim2.new(0.7, 0, 0.7, 0)
checkboxIndicator.Position = UDim2.new(0.5, 0, 0.5, 0)
checkboxIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
checkboxIndicator.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
checkboxIndicator.BorderSizePixel = 0
checkboxIndicator.Visible = false
checkboxIndicator.Parent = auraCheckbox

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 2)
indicatorCorner.Parent = checkboxIndicator

local auraLabel = Instance.new("TextLabel")
auraLabel.Name = "AuraLabel"
auraLabel.Size = UDim2.new(1, -34, 1, 0)
auraLabel.Position = UDim2.new(0, 34, 0, 0)
auraLabel.BackgroundTransparency = 1
auraLabel.Text = "Anti Lag"
auraLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
auraLabel.Font = Enum.Font.Gotham
auraLabel.TextSize = 14
auraLabel.TextXAlignment = Enum.TextXAlignment.Left
auraLabel.Parent = auraFrame

local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(0.7, 0, 0, 15)
statusText.Position = UDim2.new(0.3, 0, 1, -18)
statusText.BackgroundTransparency = 1
statusText.Text = "Ready"
statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 10
statusText.Parent = contentFrame

local minimizedFrame = Instance.new("Frame")
minimizedFrame.Name = "MinimizedFrame"
minimizedFrame.Size = UDim2.new(0, 120, 0, 30)
minimizedFrame.Position = UDim2.new(0.8, 0, 0.5, 0)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizedFrame.BorderSizePixel = 0
minimizedFrame.Visible = false
minimizedFrame.Parent = screenGui

local minimizedCorner = Instance.new("UICorner")
minimizedCorner.CornerRadius = UDim.new(0, 8)
minimizedCorner.Parent = minimizedFrame

local minimizedText = Instance.new("TextLabel")
minimizedText.Name = "MinimizedText"
minimizedText.Size = UDim2.new(0.7, 0, 1, 0)
minimizedText.BackgroundTransparency = 1
minimizedText.Text = "Lag Server"
minimizedText.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedText.Font = Enum.Font.GothamBold
minimizedText.TextSize = 12
minimizedText.Parent = minimizedFrame

local restoreButton = Instance.new("TextButton")
restoreButton.Name = "RestoreButton"
restoreButton.Size = UDim2.new(0, 24, 0, 24)
restoreButton.Position = UDim2.new(1, -26, 0.5, -12)
restoreButton.AnchorPoint = Vector2.new(0, 0)
restoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
restoreButton.BorderSizePixel = 0
restoreButton.Text = "▢"
restoreButton.TextColor3 = Color3.fromRGB(200, 200, 200)
restoreButton.Font = Enum.Font.GothamBold
restoreButton.TextSize = 14
restoreButton.Parent = minimizedFrame

local restoreCorner = Instance.new("UICorner")
restoreCorner.CornerRadius = UDim.new(0, 6)
restoreCorner.Parent = restoreButton

local toolsEquipped = false
local removeAuras = false
local tools = {}
local auraRemovalConnection
local isMinimized = false
local originalCameraType
local teleportConnection
local originalPosition
local teleportFrameCounter = 0
local teleportTickInterval = 15

local fixedPosition
local yaw
local pitch
local inputConnection
local heartbeatConnection

local MIN_X = -500000 
local MAX_X = 500000  
local MIN_Z = -500000 
local MAX_Z = 500000  
local MIN_Y = 50000  
local MAX_Y = 100000 

local ModifyUsername
local toolEvent
local ToggleDisallowEvent
local ModifyUserEvent
local targetModifiedUsername = "YournothimbuddyXD"

pcall(function()
    ModifyUsername = ReplicatedStorage:WaitForChild("ModifyUsername", 10)
end)

pcall(function()
    toolEvent = ReplicatedStorage:WaitForChild("ToolEvent", 10)
end)

pcall(function()
    ToggleDisallowEvent = ReplicatedStorage:WaitForChild("ToggleDisallowEvent", 10)
end)

pcall(function()
    ModifyUserEvent = ReplicatedStorage:WaitForChild("ModifyUserEvent", 10)
end)

local titleDragArea = Instance.new("Frame")
titleDragArea.Name = "TitleDragArea"
titleDragArea.Size = UDim2.new(1, -80, 0, 35)
titleDragArea.Position = UDim2.new(0, 0, 0, 0)
titleDragArea.BackgroundTransparency = 1
titleDragArea.Parent = mainFrame

local dragging = false
local dragInput
local dragStart
local startPos
local minimizedDragging = false
local minimizedDragStart
local minimizedStartPos

local function updateDrag(input, object, dragStartPos, startPosition)
    local delta = input.Position - dragStartPos
    local newPosition = UDim2.new(
        startPosition.X.Scale, 
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale, 
        startPosition.Y.Offset + delta.Y
    )
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = tweenService:Create(object, tweenInfo, {Position = newPosition})
    tween:Play()
end

titleDragArea.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            titleDragArea.Parent.BackgroundTransparency = 0.6
        end
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                titleDragArea.Parent.BackgroundTransparency = 0.5
            end
        end)
    end
end)

minimizedFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local inputPosition = input.Position
        local guiObjects = screenGui:GetGuiObjectsAtPosition(inputPosition.X, inputPosition.Y)
        
        local canDrag = true
        for _, obj in pairs(guiObjects) do
            if obj == restoreButton then
                canDrag = false
                break
            end
        end
        
        if canDrag then
            minimizedDragging = true
            minimizedDragStart = input.Position
            minimizedStartPos = minimizedFrame.Position
            
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                minimizedFrame.BackgroundTransparency = 0.1
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    minimizedDragging = false
                    minimizedFrame.BackgroundTransparency = 0
                end
            end)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            updateDrag(input, mainFrame, dragStart, startPos)
        end
        
        if minimizedDragging then
            updateDrag(input, minimizedFrame, minimizedDragStart, minimizedStartPos)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        minimizedDragging = false
        mainFrame.BackgroundTransparency = 0.5
        minimizedFrame.BackgroundTransparency = 0
    end
end)

local function removeAuraItems()
    if not removeAuras or not localPlayer.Character then return end
    
    local auraItemsFound = false
    for _, item in pairs(localPlayer.Character:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Tool") or item:IsA("BasePart") or item:IsA("Shirt") or item:IsA("Pants") then
            if string.find(string.lower(item.Name), "aura") then
                item:Destroy()
                auraItemsFound = true
            end
        end
    end
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= localPlayer and otherPlayer.Character then
            for _, item in pairs(otherPlayer.Character:GetChildren()) do
                if item:IsA("Accessory") or item:IsA("Tool") or item:IsA("BasePart") or item:IsA("Shirt") or item:IsA("Pants") then
                    if string.find(string.lower(item.Name), "aura") then
                        item:Destroy()
                        auraItemsFound = true
                    end
                end
            end
        end
    end
    
    if auraItemsFound then
        statusText.Text = "Aura items removed"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(0.01)
        statusText.Text = toolsEquipped and "Running" or "Ready"
        statusText.TextColor3 = toolsEquipped and Color3.fromRGB(40, 180, 120) or Color3.fromRGB(150, 150, 150)
    end
end

local function startAuraRemoval()
    if auraRemovalConnection then
        auraRemovalConnection:Disconnect()
    end
    
    auraRemovalConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if removeAuras then
            removeAuraItems()
        end
    end)
end

startAuraRemoval()

auraCheckbox.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        removeAuras = not removeAuras
        checkboxIndicator.Visible = removeAuras
        
        if removeAuras then
            statusText.Text = "Anti Lag active"
            statusText.TextColor3 = Color3.fromRGB(40, 180, 120)
        else
            statusText.Text = "Anti Lag off"
            statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        task.wait(0.01)
        if toolsEquipped then
            statusText.Text = "Running"
            statusText.TextColor3 = Color3.fromRGB(40, 180, 120)
        else
            statusText.Text = "Ready"
            statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end)

auraLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        removeAuras = not removeAuras
        checkboxIndicator.Visible = removeAuras
        
        if removeAuras then
            statusText.Text = "Anti Lag active"
            statusText.TextColor3 = Color3.fromRGB(40, 180, 120)
        else
            statusText.Text = "Anti Lag off"
            statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        task.wait(0.01)
        if toolsEquipped then
            statusText.Text = "Running"
            statusText.TextColor3 = Color3.fromRGB(40, 180, 120)
        else
            statusText.Text = "Ready"
            statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizedFrame.Visible = true
    isMinimized = true
    minimizedFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
end)

restoreButton.MouseButton1Click:Connect(function()
    minimizedFrame.Visible = false
    mainFrame.Visible = true
    isMinimized = false
    mainFrame.Position = UDim2.new(minimizedFrame.Position.X.Scale, minimizedFrame.Position.X.Offset, minimizedFrame.Position.Y.Scale, minimizedFrame.Position.Y.Offset)
end)

closeButton.MouseButton1Click:Connect(function()
    if teleportConnection then
        teleportConnection:Disconnect()
    end
    
    if auraRemovalConnection then
        auraRemovalConnection:Disconnect()
    end
    
    if toolsEquipped then
        workspace.FallenPartsDestroyHeight = -500
        if originalCameraType then
            workspace.Camera.CameraType = originalCameraType
        end
        
        if localPlayer.Character and originalPosition then
            localPlayer.Character:SetPrimaryPartCFrame(CFrame.new(originalPosition))
        end
    end
    
    screenGui:Destroy()
    toolsEquipped = false
end)

local function fireModifyUsername()
    if not ModifyUsername or typeof(ModifyUsername) ~= "Instance" or not ModifyUsername:IsA("RemoteEvent") then
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("ModifyUsername", 2)
        end)
        if success and result then
            ModifyUsername = result
        else
            return false
        end
    end
    
    local success = pcall(function()
        local args = {
            [1] = "24k_mxtty1"
        }
        ModifyUsername:FireServer(unpack(args))
    end)
    
    return success
end

local function fireToolEvent(toolName)
    if not toolEvent or typeof(toolEvent) ~= "Instance" or not toolEvent:IsA("RemoteEvent") then
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("ToolEvent", 2)
        end)
        if success and result then
            toolEvent = result
        else
            return false
        end
    end
    
    local success = pcall(function()
        local args = {
            [1] = toolName
        }
        toolEvent:FireServer(unpack(args))
    end)
    
    return success
end

local function fireToggleDisallowEvent()
    if not ToggleDisallowEvent or typeof(ToggleDisallowEvent) ~= "Instance" or not ToggleDisallowEvent:IsA("RemoteEvent") then
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("ToggleDisallowEvent", 2)
        end)
        if success and result then
            ToggleDisallowEvent = result
        else
            return false
        end
    end
    
    local success = pcall(function()
        ToggleDisallowEvent:FireServer()
    end)
    
    return success
end

local function fireModifyUserEvent(username)
    if not ModifyUserEvent or typeof(ModifyUserEvent) ~= "Instance" or not ModifyUserEvent:IsA("RemoteEvent") then
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("ModifyUserEvent", 2)
        end)
        if success and result then
            ModifyUserEvent = result
        else
            return false
        end
    end
    
    local success = pcall(function()
        ModifyUserEvent:FireServer(username)
    end)
    
    return success
end

local function startVoidTeleporting()
    if teleportConnection then
        teleportConnection:Disconnect() 
    end
    
    teleportFrameCounter = 0
    local hasTeleportedOnce = false

    teleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not toolsEquipped or not localPlayer.Character or not localPlayer.Character.PrimaryPart then return end
        
        teleportFrameCounter = teleportFrameCounter + 1
        
        if teleportFrameCounter >= teleportTickInterval then
            teleportFrameCounter = 0 
            
            local randomX = math.random(MIN_X, MAX_X)
            local randomY = math.random(MIN_Y, MAX_Y) 
            local randomZ = math.random(MIN_Z, MAX_Z)
            local randomPosition = Vector3.new(randomX, randomY, randomZ)
            
            if localPlayer.Character and localPlayer.Character.PrimaryPart then
                localPlayer.Character:SetPrimaryPartCFrame(CFrame.new(randomPosition))

                local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:IsA("BasePart") then
                    local wasAnchored = hrp.Anchored
                    hrp.Anchored = true
                    task.wait(0.001) 
                    hrp.Anchored = wasAnchored
                end

                if not hasTeleportedOnce and toolsEquipped then
                    hasTeleportedOnce = true 
                    task.spawn(function()
                        while toolsEquipped do
                            fireModifyUsername()
                            
                            tools = {}
                            for _, tool in pairs(localPlayer.Backpack:GetChildren()) do
                                if tool:IsA("Tool") then
                                    table.insert(tools, tool)
                                end
                            end
                            
                            if #tools > 0 and localPlayer.Character then
                                for _, tool in pairs(tools) do
                                    if not toolsEquipped then break end
                                    tool.Parent = localPlayer.Character
                                end
                            end
                            
                            if localPlayer.Character then
                                for _, tool in pairs(localPlayer.Character:GetChildren()) do
                                    if not toolsEquipped then break end
                                    if tool:IsA("Tool") then
                                        tool.Parent = localPlayer.Backpack
                                    end
                                end
                            end
                            
                            task.wait(0.05)
                        end
                    end)
                end
            end
        end
    end)
end

local function safelyReturnToPosition()
    if not localPlayer.Character then return end
    
    local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not humanoid then return end
    
    local stabilizationLoop = RunService.Heartbeat:Connect(function()
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            hrp.Anchored = true
        end
        
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
    
    hrp.CFrame = CFrame.new(originalPosition)
    
    task.wait(0.5)
    
    for i = 1, 6 do
        if hrp then
            hrp.CFrame = CFrame.new(originalPosition)
        end
        task.wait(0.1)
    end
    
    if stabilizationLoop then stabilizationLoop:Disconnect() end
    
    if hrp then
        hrp.Anchored = false
    end
    
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

toggleButton.MouseButton1Click:Connect(function()
    toolsEquipped = not toolsEquipped
    
    if toolsEquipped then
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
        statusText.Text = "Running"
        statusText.TextColor3 = Color3.fromRGB(40, 180, 120)
        
        if localPlayer.Character and localPlayer.Character.PrimaryPart then
            originalPosition = localPlayer.Character.PrimaryPart.Position
        end
        
        originalCameraType = workspace.Camera.CameraType
        fixedPosition = workspace.Camera.CFrame.Position
        local x, y, z = workspace.Camera.CFrame:ToEulerAnglesYXZ()
        pitch = math.deg(x)
        yaw = math.deg(y)
        
        workspace.Camera.CameraType = Enum.CameraType.Scriptable
        
        inputConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Delta
                yaw = yaw - delta.X * 0.1
                pitch = math.clamp(pitch - delta.Y * 0.1, -89, 89)
            end
        end)
        
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if toolsEquipped then
                local rotationCFrame = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
                workspace.Camera.CFrame = CFrame.new(fixedPosition) * rotationCFrame
            end
        end)
        
        workspace.FallenPartsDestroyHeight = math.huge * -1
        
        startVoidTeleporting()
        fireModifyUsername()
        fireToolEvent("Motor")
        
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        statusText.Text = "Returning..."
        statusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        
        if inputConnection then inputConnection:Disconnect() end
        if heartbeatConnection then heartbeatConnection:Disconnect() end
        if teleportConnection then teleportConnection:Disconnect() end
        
        workspace.FallenPartsDestroyHeight = -500
        
        if originalCameraType then
            workspace.Camera.CameraType = originalCameraType
        end
        
        safelyReturnToPosition()
        
        fireToggleDisallowEvent()
        fireModifyUserEvent(localPlayer.Name)
        task.wait(0.5)
        fireToggleDisallowEvent()
        
        statusText.Text = "Ready"
        statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

local replicatedStorage = game:GetService("ReplicatedStorage")
local ToggleDisallowEvent = replicatedStorage:WaitForChild("ToggleDisallowEvent")

ToggleDisallowEvent:FireServer()
