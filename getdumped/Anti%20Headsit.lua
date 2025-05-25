-- Made by AnthonyIsntHere
-- Modified with simplified head radius detection

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Character, Humanoid, RootPart, Head
local Camera = workspace.CurrentCamera
local IsVoiding = false
local IsEnabled = true

-- Create GUI elements for mobile
local function CreateMobileButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "VoidProtectionGUI"
    gui.ResetOnSpawn = false
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 45, 0, 45)
    button.Position = UDim2.new(0, 20, 1, -70)
    button.AnchorPoint = Vector2.new(0, 1)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BackgroundTransparency = 0.1
    button.Text = "ON"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = button
    
    button.Parent = gui
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    button.MouseButton1Click:Connect(function()
        IsEnabled = not IsEnabled
        button.Text = IsEnabled and "ON" or "OFF"
        button.BackgroundColor3 = IsEnabled and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(180, 40, 40)
    end)
    
    return button
end

-- Simplified head-sitting detection with radius check
local function IsPlayerSittingOnHead()
    if Head then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= Player then
                local otherCharacter = otherPlayer.Character
                if not otherCharacter then continue end
                
                local otherHumanoid = otherCharacter:FindFirstChildWhichIsA("Humanoid")
                if not otherHumanoid then continue end
                
                -- Only check if they're seated
                if otherHumanoid:GetState() ~= Enum.HumanoidStateType.Seated then continue end
                
                local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
                if not otherRoot then continue end
                
                -- Check if they're within radius of head/upper torso area
                local distance = (otherRoot.Position - Head.Position).Magnitude
                if distance <= 3.5 then  -- Radius check
                    return otherPlayer
                end
            end
        end
    end
    return nil
end

-- Bang animation detection
local function IsUsingBangAnimation()
    if RootPart then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= Player then
                local otherCharacter = otherPlayer.Character
                local otherHumanoid = otherCharacter and otherCharacter:FindFirstChildWhichIsA("Humanoid")
                local otherRootPart = otherHumanoid and otherHumanoid.RootPart

                if otherRootPart and (RootPart.Position - otherRootPart.Position).Magnitude < 2 then
                    for _, animTrack in ipairs(otherHumanoid:GetPlayingAnimationTracks()) do
                        if animTrack.Animation and (animTrack.Animation.AnimationId:match("148840371") or animTrack.Animation.AnimationId:match("5918726674")) then
                            return otherPlayer
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Bypass the void limit
workspace.FallenPartsDestroyHeight = 0/0

-- Void teleport function
local function VoidTeleport()
    workspace.Camera.CameraType = Enum.CameraType.Fixed
    
    local HRoot = game:GetService("Players").LocalPlayer.Character.Humanoid.RootPart
    local Pos = HRoot.CFrame
    
    HRoot.CFrame = Pos + Vector3.new(0, -1e3, 0)
    task.wait(0.1)
    HRoot.CFrame = Pos
    
    workspace.Camera.CameraType = Enum.CameraType.Custom
end

-- Create mobile button
local mobileButton = CreateMobileButton()

-- Setup keyboard toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.N then
        IsEnabled = not IsEnabled
        mobileButton.Text = IsEnabled and "ON" or "OFF"
        mobileButton.BackgroundColor3 = IsEnabled and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(180, 40, 40)
    end
end)

-- Main protection loop
while true do
    if IsEnabled then
        Character = Player.Character
        if Character then
            Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            RootPart = Character:FindFirstChild("HumanoidRootPart")
            Head = Character:FindFirstChild("Head")
            
            local sittingPlayer = IsPlayerSittingOnHead()
            local bangPlayer = IsUsingBangAnimation()
            
            if (sittingPlayer or bangPlayer) and not IsVoiding then
                IsVoiding = true
                local offender = sittingPlayer or bangPlayer
                
                -- Kill the offender
                if offender and offender.Character then
                    local offenderHumanoid = offender.Character:FindFirstChildWhichIsA("Humanoid")
                    if offenderHumanoid then
                        offenderHumanoid.Health = 0
                    end
                end
                
                -- Immediate void teleport
                VoidTeleport()
                IsVoiding = false
            end
        end
    end
    
    task.wait(0.1)
end
