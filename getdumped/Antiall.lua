

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character, Humanoid, RootPart
local Camera = workspace.CurrentCamera
local IsVoiding = false

-- Prevent objects from being destroyed by the void
workspace.FallenPartsDestroyHeight = math.huge * -1 -- Removes the void destruction limit

-- Create GUI Elements
local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.Name = "VoidGui"

-- Button Setup
Button.Parent = ScreenGui
Button.Name = "VoidButton"
Button.Size = UDim2.new(0, 50, 0, 50) -- Small circle button
Button.Position = UDim2.new(1, -60, 0.5, -25) -- Middle right of the screen
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray
Button.BackgroundTransparency = 0.5 -- Semi-transparent button
Button.BorderSizePixel = 0
Button.Text = "V" -- Simple "V" for Void
Button.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
Button.Font = Enum.Font.GothamBold
Button.TextSize = 20
Button.Active = true
Button.Draggable = true -- Allows dragging on PC

-- Add Rounded Corners and Outline
UICorner.Parent = Button
UICorner.CornerRadius = UDim.new(1, 0) -- Makes the button a perfect circle

UIStroke.Parent = Button
UIStroke.Color = Color3.fromRGB(255, 255, 255) -- White border
UIStroke.Thickness = 1

-- Make it Draggable for All Devices
local dragging = false
local dragInput, dragStart, startPos

Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Voiding Function

-- Camera stuff
local function VoidTeleport()
    workspace.Camera.CameraType = Enum.CameraType.Fixed;

    local HRoot = game:GetService("Players").LocalPlayer.Character.Humanoid.RootPart;
    local Pos = HRoot.CFrame;
    HRoot.CFrame = Pos + Vector3.new(0, -1e3, 0);
    task.wait(.1) -- try messing with this value
    HRoot.CFrame = Pos;

    workspace.Camera.CameraType = Enum.CameraType.Custom;
end

local function VoidAndReturn()
    Character = Player.Character
    Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
    RootPart = Humanoid and Humanoid.RootPart

    if RootPart and Humanoid and not IsVoiding then
        IsVoiding = true

        -- Teleport yourself to the void
        VoidTeleport()

        IsVoiding = false
    end
end


-- Connect Button Click to Void Function
Button.MouseButton1Click:Connect(VoidAndReturn)
