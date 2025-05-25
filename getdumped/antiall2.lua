local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Function to remove dangerous objects
local function removeDangerousObjects()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (
            obj.Name:lower():match("kill") or 
            obj.Name:lower():match("death") or 
            (obj:GetAttribute("kills") ~= nil)
        ) then
            obj:Destroy()
        end
        
        if obj:IsA("TouchTransmitter") then
            obj:Destroy()
        end
        
        if (obj:IsA("Script") or obj:IsA("LocalScript")) and (
            obj.Name:lower():match("kill") or
            obj.Name:lower():match("death") or 
            obj.Name:lower():match("damage")
        ) then
            obj:Destroy()
        end
    end
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
local button = Instance.new("TextButton")

button.Size = UDim2.new(0, 60, 0, 60)
button.Position = UDim2.new(0.95, -30, 0.5, -30)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.BackgroundTransparency = 0.2
button.Text = "v"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 18
button.Font = Enum.Font.GothamBlack
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

-- Dragging functionality
local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Freeze and unfreeze functions
local function freezeCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
end

local function unfreezeCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
end

-- Safe teleport function
local function safeTeleport()
    local player = Players.LocalPlayer
    local character = player.Character
    if character then
        removeDangerousObjects()
        
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local originalCFrame = humanoidRootPart.CFrame
        
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 54, 0, 54),
            Position = button.Position + UDim2.new(0, 3, 0, 3)
        }):Play()
        
        -- Freeze character
        freezeCharacter(character)
        
        -- Teleport sideways (90-degree rotation on the Z-axis)
        local targetRotation = CFrame.Angles(0, 0, math.rad(90))
        humanoidRootPart.CFrame = CFrame.new(4213, 0.5, 68) * targetRotation
        
        -- Wait and return with original orientation
        task.wait(0.6)
        
        -- Instantly unfreeze before teleporting back
        unfreezeCharacter(character)
        humanoidRootPart.CFrame = CFrame.new(originalCFrame.Position) * 
            CFrame.Angles(0, originalCFrame.Rotation.Y, 0)
        
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 60, 0, 60),
            Position = button.Position - UDim2.new(0, 3, 0, 3)
        }):Play()
    end
end

-- Button effects
button.MouseEnter:Connect(function()
    TweenService:Create(button, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        TextSize = 20
    }):Play()
end)

button.MouseLeave:Connect(function()
    TweenService:Create(button, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextSize = 18
    }):Play()
end)

button.MouseButton1Click:Connect(safeTeleport)

-- Initialize
removeDangerousObjects()
screenGui.Parent = CoreGui
