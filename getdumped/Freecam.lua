--[[
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local onMobile = not UIS.KeyboardEnabled
local keysDown = {}
local rotating = false
local touchPos
local toggleActive = true -- Initially enabled
local dragging, dragInput, dragStart, startPos

if not game:IsLoaded() then game.Loaded:Wait() end

-- Freeze the character
if humanoid then
    humanoid.PlatformStand = true -- Prevents the character from falling or moving
    character.HumanoidRootPart.Anchored = true -- Anchor the character's root part
end

cam.CameraType = Enum.CameraType.Scriptable

local speed = 5
local sens = 0.3

speed /= 10
if onMobile then sens *= 2 end

-- Function to control camera
local function renderStepped()
    if not toggleActive then return end -- Stop if toggle is off

    -- Handle camera rotation
    if rotating then
        local delta = UIS:GetMouseDelta()
        local cf = cam.CFrame
        local yAngle = cf:ToEulerAngles(Enum.RotationOrder.YZX)
        local newAmount = math.deg(yAngle) + delta.Y

        if newAmount > 65 or newAmount < -65 then
            if not (yAngle < 0 and delta.Y < 0) and not (yAngle > 0 and delta.Y > 0) then
                delta = Vector2.new(delta.X, 0)
            end
        end

        cf *= CFrame.Angles(-math.rad(delta.Y), 0, 0)
        cf = CFrame.Angles(0, -math.rad(delta.X), 0) * (cf - cf.Position) + cf.Position
        cf = CFrame.lookAt(cf.Position, cf.Position + cf.LookVector)
        if delta ~= Vector2.new(0, 0) then cam.CFrame = cam.CFrame:Lerp(cf, sens) end
        UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end

    -- Handle camera movement
    if keysDown["Enum.KeyCode.W"] then
        cam.CFrame *= CFrame.new(Vector3.new(0, 0, -speed))
    end
    if keysDown["Enum.KeyCode.A"] then
        cam.CFrame *= CFrame.new(Vector3.new(-speed, 0, 0))
    end
    if keysDown["Enum.KeyCode.S"] then
        cam.CFrame *= CFrame.new(Vector3.new(0, 0, speed))
    end
    if keysDown["Enum.KeyCode.D"] then
        cam.CFrame *= CFrame.new(Vector3.new(speed, 0, 0))
    end
end

RS.RenderStepped:Connect(renderStepped)

-- Create GUI for toggle button
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 100, 0, 40) -- Smaller size
toggleButton.Position = UDim2.new(0.5, -50, 0, 20)
toggleButton.Text = "Freecam On"
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Darker background for a sleek look
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for contrast
toggleButton.Font = Enum.Font.Gotham -- Sleeker, modern font
toggleButton.TextSize = 18 -- Smaller font size
toggleButton.BorderSizePixel = 0

-- Add rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12) -- Rounded corners for a modern look
UICorner.Parent = toggleButton

-- Dragging functionality
local function onDragStarted(input)
    dragging = true
    dragStart = input.Position
    startPos = toggleButton.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

local function onDragging(input)
    if not dragging then return end

    local delta = input.Position - dragStart
    local newPosition = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    toggleButton.Position = newPosition
end

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        onDragStarted(input)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and (dragging) then
        onDragging(input)
    end
end)

-- Toggle functionality
local function resetPlayer()
    -- Reset the character to normal (unfreeze)
    humanoid.PlatformStand = false
    character.HumanoidRootPart.Anchored = false
    cam.CameraType = Enum.CameraType.Custom -- Reset to normal camera
end

local function freezePlayer()
    -- Freeze the character again and apply camera controls
    humanoid.PlatformStand = true
    character.HumanoidRootPart.Anchored = true
    cam.CameraType = Enum.CameraType.Scriptable
end

toggleButton.MouseButton1Click:Connect(function()
    toggleActive = not toggleActive

    if toggleActive then
        toggleButton.Text = "Freecam On"
        freezePlayer() -- Freeze player when camera control is on
        RS.RenderStepped:Connect(renderStepped) -- Re-enable camera control
    else
        toggleButton.Text = "Freecam Off"
        resetPlayer() -- Unfreeze player when camera control is off
        RS.RenderStepped:Disconnect(renderStepped) -- Disable camera control
    end
end)

-- Movement key handling
local validKeys = {"Enum.KeyCode.W", "Enum.KeyCode.A", "Enum.KeyCode.S", "Enum.KeyCode.D"}

UIS.InputBegan:Connect(function(Input)
    if not toggleActive then return end

    for _, key in pairs(validKeys) do
        if key == tostring(Input.KeyCode) then
            keysDown[key] = true
        end
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton2 or (Input.UserInputType == Enum.UserInputType.Touch and UIS:GetMouseLocation().X > (cam.ViewportSize.X / 2)) then
        rotating = true
    end

    if Input.UserInputType == Enum.UserInputType.Touch then
        if Input.Position.X < cam.ViewportSize.X / 2 then
            touchPos = Input.Position
        end
    end
end)

UIS.InputEnded:Connect(function(Input)
    if not toggleActive then return end

    for key, v in pairs(keysDown) do
        if key == tostring(Input.KeyCode) then
            keysDown[key] = false
        end
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton2 or (Input.UserInputType == Enum.UserInputType.Touch and UIS:GetMouseLocation().X > (cam.ViewportSize.X / 2)) then
        rotating = false
    end

    if Input.UserInputType == Enum.UserInputType.Touch and touchPos then
        if Input.Position.X < cam.ViewportSize.X / 2 then
            touchPos = nil
            keysDown["Enum.KeyCode.W"] = false
            keysDown["Enum.KeyCode.A"] = false
            keysDown["Enum.KeyCode.S"] = false
            keysDown["Enum.KeyCode.D"] = false
        end
    end
end)

UIS.TouchMoved:Connect(function(input)
    if not toggleActive then return end

    if touchPos then
        if input.Position.X < cam.ViewportSize.X / 2 then
            if input.Position.Y < touchPos.Y then
                keysDown["Enum.KeyCode.W"] = true
                keysDown["Enum.KeyCode.S"] = false
            else
                keysDown["Enum.KeyCode.W"] = false
                keysDown["Enum.KeyCode.S"] = true
            end
            if input.Position.X < (touchPos.X - 15) then
                keysDown["Enum.KeyCode.A"] = true
                keysDown["Enum.KeyCode.D"] = false
            elseif input.Position.X > (touchPos.X + 15) then
                keysDown["Enum.KeyCode.A"] = false
                keysDown["Enum.KeyCode.D"] = true
            else
                keysDown["Enum.KeyCode.A"] = false
                keysDown["Enum.KeyCode.D"] = false
            end
        end
    end
end)
