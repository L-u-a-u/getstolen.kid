local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- GUI Erstellung
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner") -- For rounded corners on MainFrame
local CloseButton = Instance.new("TextButton")
local ToggleButton = Instance.new("TextButton")
local DragBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")

-- GUI zum CoreGui hinzufügen
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Hauptframe (kleiner und mit abgerundeten Ecken)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -75, 0.5, -50) -- adjusted for smaller size
MainFrame.Size = UDim2.new(0, 150, 0, 100) -- smaller than original (150x100 instead of 200x150)
MainFrame.BorderSizePixel = 0

-- Abgerundete Ecken für MainFrame
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- DragBar
DragBar.Name = "DragBar"
DragBar.Parent = MainFrame
DragBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DragBar.Size = UDim2.new(1, 0, 0, 20) -- slightly smaller than original
DragBar.BorderSizePixel = 0

-- Titel
Title.Parent = DragBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "annoy nearest"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12 -- reduced text size for smaller GUI
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button (kleiner und abgerundet)
CloseButton.Parent = DragBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Position = UDim2.new(1, -18, 0, 2)
CloseButton.Size = UDim2.new(0, 15, 0, 15)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 10

-- Toggle Button (kleiner und abgerundet)
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 180, 45)
ToggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0.3, 0)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "ACTIVATE"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14

local function ApplyRoundedCorners(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
end
ApplyRoundedCorners(CloseButton)
ApplyRoundedCorners(ToggleButton)

-- Drag-Funktion für Maus und Touch
local Dragging = false
local DragStart = nil
local StartPos = nil

local function StartDrag(input)
    Dragging = true
    DragStart = input.Position
    StartPos = MainFrame.Position
end

local function UpdateDrag(input)
    if Dragging then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + delta.Y
        )
    end
end

local function StopDrag()
    Dragging = false
end

DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        StartDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        UpdateDrag(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        StopDrag()
    end
end)

--------------------------------------------------------------------------------
-- Körper Lifting Variablen und Funktionen
local BodyLifted = false
local UpdateConnection = nil
local originalPositions = {}      -- Speichert die ursprünglichen CFrames der Körperteile (inkl. Y-Rotation)
local currentKeyframe = 1
local animationTime = 0
local lastKeyframeTime = 0
local nearestTargetPlayers = {}
local farthestTargetPlayers = {}
local randomTargetPlayers = {}
local initialHumanoidRootPartCFrame = nil -- Ursprünglicher CFrame des HumanoidRootPart (mit Y-Achse)

-- Neue Variablen für Sitzplätze
local seatBackup = {}       -- Hier speichern wir die entfernten Sitzplätze (Objekt + ursprünglicher Parent)
local seatAddedConnection = nil  -- Verbindung zum Überwachen neu hinzugefügter Sitzplätze

-- Keyframe System
local keyframes = {
    {
        duration = 0.1,
        config = {
            Humanoid = {
                position = Vector3.new(0, 0, 0),
                rotation = Vector3.new(0, 0, 0),
                targetPlayer = "nearest",
                matchTargetPart = false
            },
            Head = {
                position = Vector3.new(-10, 5, 10),
                rotation = Vector3.new(0, 15, 10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            UpperTorso = {
                position = Vector3.new(-8, 3, 12),
                rotation = Vector3.new(5, -5, 0),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LowerTorso = {
                position = Vector3.new(12, -2, -10),
                rotation = Vector3.new(-5, 10, 5),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperArm = {
                position = Vector3.new(-10, 2, 8),
                rotation = Vector3.new(15, 30, -10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerArm = {
                position = Vector3.new(-2, 7, 5),
                rotation = Vector3.new(0, 45, 20),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftHand = {
                position = Vector3.new(3, 10, -2),
                rotation = Vector3.new(10, 60, -15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperArm = {
                position = Vector3.new(-7, -4, -12),
                rotation = Vector3.new(-20, -15, 10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerArm = {
                position = Vector3.new(4, -8, -5),
                rotation = Vector3.new(15, -40, -25),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightHand = {
                position = Vector3.new(-3, -12, 3),
                rotation = Vector3.new(-10, -55, 30),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperLeg = {
                position = Vector3.new(-12, -3, 10),
                rotation = Vector3.new(25, 10, -5),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerLeg = {
                position = Vector3.new(8, -7, -8),
                rotation = Vector3.new(-10, 20, 15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftFoot = {
                position = Vector3.new(5, -10, 2),
                rotation = Vector3.new(0, -15, -35),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperLeg = {
                position = Vector3.new(10, 4, 12),
                rotation = Vector3.new(-30, -25, 5),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerLeg = {
                position = Vector3.new(-9, 6, -10),
                rotation = Vector3.new(5, -35, -10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightFoot = {
                position = Vector3.new(2, 9, -4),
                rotation = Vector3.new(-5, 25, 40),
                targetPlayer = "nearest",
                matchTargetPart = true
            }
        }
    },
    {
        duration = 0.1,
        config = {
            Humanoid = {
                position = Vector3.new(0, 0, 0),
                rotation = Vector3.new(0, 0, 0),
                targetPlayer = "nearest",
                matchTargetPart = false
            },
            Head = {
                position = Vector3.new(5, -8, -5),
                rotation = Vector3.new(15, -30, -20),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            UpperTorso = {
                position = Vector3.new(3, -5, -7),
                rotation = Vector3.new(-10, 20, 15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LowerTorso = {
                position = Vector3.new(-6, 4, 6),
                rotation = Vector3.new(5, -15, -25),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperArm = {
                position = Vector3.new(4, -3, -4),
                rotation = Vector3.new(-25, 10, 30),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerArm = {
                position = Vector3.new(-2, -7, 2),
                rotation = Vector3.new(15, -40, -10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftHand = {
                position = Vector3.new(0, -9, -1),
                rotation = Vector3.new(-10, 25, 45),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperArm = {
                position = Vector3.new(-5, 6, 3),
                rotation = Vector3.new(30, -20, -15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerArm = {
                position = Vector3.new(2, 8, -2),
                rotation = Vector3.new(-15, 45, 20),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightHand = {
                position = Vector3.new(-1, 10, 1),
                rotation = Vector3.new(10, -30, -35),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperLeg = {
                position = Vector3.new(7, 2, -5),
                rotation = Vector3.new(-20, 15, 40),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerLeg = {
                position = Vector3.new(-4, -1, 4),
                rotation = Vector3.new(10, -25, -10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftFoot = {
                position = Vector3.new(3, 5, -3),
                rotation = Vector3.new(-5, 15, 25),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperLeg = {
                position = Vector3.new(-6, -4, 6),
                rotation = Vector3.new(25, -10, -30),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerLeg = {
                position = Vector3.new(4, 3, -4),
                rotation = Vector3.new(-10, 20, 15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightFoot = {
                position = Vector3.new(-2, -6, 2),
                rotation = Vector3.new(5, -35, -20),
                targetPlayer = "nearest",
                matchTargetPart = true
            }
        }
    },
    {
        duration = 0.1,
        config = {
            Humanoid = {
                position = Vector3.new(0, 0, 0),
                rotation = Vector3.new(0, 0, 0),
                targetPlayer = "nearest",
                matchTargetPart = false
            },
            Head = {
                position = Vector3.new(-5, 8, 5),
                rotation = Vector3.new(-15, 30, 20),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            UpperTorso = {
                position = Vector3.new(-3, 5, 7),
                rotation = Vector3.new(10, -20, -15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LowerTorso = {
                position = Vector3.new(6, -4, -6),
                rotation = Vector3.new(-5, 15, 25),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperArm = {
                position = Vector3.new(-4, 3, 4),
                rotation = Vector3.new(25, -10, -30),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerArm = {
                position = Vector3.new(2, 7, -2),
                rotation = Vector3.new(-15, 40, 10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftHand = {
                position = Vector3.new(0, 9, 1),
                rotation = Vector3.new(10, -25, -45),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperArm = {
                position = Vector3.new(5, -6, -3),
                rotation = Vector3.new(-30, 20, 15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerArm = {
                position = Vector3.new(-2, -8, 2),
                rotation = Vector3.new(15, -45, -20),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightHand = {
                position = Vector3.new(1, -10, -1),
                rotation = Vector3.new(-10, 30, 35),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperLeg = {
                position = Vector3.new(-7, -2, 5),
                rotation = Vector3.new(20, -15, -40),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerLeg = {
                position = Vector3.new(4, 1, -4),
                rotation = Vector3.new(-10, 25, 10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftFoot = {
                position = Vector3.new(-3, -5, 3),
                rotation = Vector3.new(5, -15, -25),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperLeg = {
                position = Vector3.new(6, 4, -6),
                rotation = Vector3.new(-25, 10, 30),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerLeg = {
                position = Vector3.new(-4, -3, 4),
                rotation = Vector3.new(10, -20, -15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightFoot = {
                position = Vector3.new(2, 6, -2),
                rotation = Vector3.new(-5, 35, 20),
                targetPlayer = "nearest",
                matchTargetPart = true
            }
        }
    },
    {
        duration = 0.1,
        config = {
            Humanoid = {
                position = Vector3.new(0, 0, 0),
                rotation = Vector3.new(0, 0, 0),
                targetPlayer = "nearest",
                matchTargetPart = false
            },
            Head = {
                position = Vector3.new(10, -5, -10),
                rotation = Vector3.new(0, -15, -10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            UpperTorso = {
                position = Vector3.new(8, -3, -12),
                rotation = Vector3.new(-5, 5, 0),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LowerTorso = {
                position = Vector3.new(-12, 2, 10),
                rotation = Vector3.new(5, -10, -5),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperArm = {
                position = Vector3.new(10, -2, -8),
                rotation = Vector3.new(-15, -30, 10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerArm = {
                position = Vector3.new(2, -7, -5),
                rotation = Vector3.new(0, -45, -20),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftHand = {
                position = Vector3.new(-3, -10, 2),
                rotation = Vector3.new(-10, -60, 15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperArm = {
                position = Vector3.new(7, 4, 12),
                rotation = Vector3.new(20, 15, -10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerArm = {
                position = Vector3.new(-4, 8, 5),
                rotation = Vector3.new(-15, 40, 25),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightHand = {
                position = Vector3.new(3, 12, -3),
                rotation = Vector3.new(10, 55, -30),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperLeg = {
                position = Vector3.new(12, 3, -10),
                rotation = Vector3.new(-25, -10, 5),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerLeg = {
                position = Vector3.new(-8, 7, 8),
                rotation = Vector3.new(10, -20, -15),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftFoot = {
                position = Vector3.new(-5, 10, -2),
                rotation = Vector3.new(0, 15, 35),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperLeg = {
                position = Vector3.new(-10, -4, -12),
                rotation = Vector3.new(30, 25, -5),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerLeg = {
                position = Vector3.new(9, -6, 10),
                rotation = Vector3.new(-5, 35, 10),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightFoot = {
                position = Vector3.new(-2, -9, 4),
                rotation = Vector3.new(5, -25, -40),
                targetPlayer = "nearest",
                matchTargetPart = true
            }
        }
    },
    {
        duration = 0.1,
        config = {
            Humanoid = {
                position = Vector3.new(0, 0, 0),
                rotation = Vector3.new(0, 0, 0),
                targetPlayer = "nearest",
                matchTargetPart = false
            },
            Head = {
                position = Vector3.new(0, 10, 0),
                rotation = Vector3.new(45, 0, 0),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            UpperTorso = {
                position = Vector3.new(0, 8, 0),
                rotation = Vector3.new(0, 45, 0),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LowerTorso = {
                position = Vector3.new(0, 6, 0),
                rotation = Vector3.new(0, 0, 45),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperArm = {
                position = Vector3.new(5, 7, 5),
                rotation = Vector3.new(30, 60, 0),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerArm = {
                position = Vector3.new(-5, 9, -5),
                rotation = Vector3.new(0, 90, 45),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftHand = {
                position = Vector3.new(10, 5, 0),
                rotation = Vector3.new(45, 180, 0),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperArm = {
                position = Vector3.new(-5, 7, -5),
                rotation = Vector3.new(60, 0, 30),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerArm = {
                position = Vector3.new(5, 9, 5),
                rotation = Vector3.new(90, 45, 0),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightHand = {
                position = Vector3.new(-10, 5, 0),
                rotation = Vector3.new(180, 0, 45),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftUpperLeg = {
                position = Vector3.new(0, 3, 10),
                rotation = Vector3.new(0, 0, -60),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftLowerLeg = {
                position = Vector3.new(0, 7, -10),
                rotation = Vector3.new(45, 45, 90),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            LeftFoot = {
                position = Vector3.new(8, -4, 0),
                rotation = Vector3.new(-45, 90, -45),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightUpperLeg = {
                position = Vector3.new(0, 3, -10),
                rotation = Vector3.new(0, 0, 60),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightLowerLeg = {
                position = Vector3.new(0, 7, 10),
                rotation = Vector3.new(45, -45, -90),
                targetPlayer = "nearest",
                matchTargetPart = true
            },
            RightFoot = {
                position = Vector3.new(-8, -4, 0),
                rotation = Vector3.new(-45, -90, 45),
                targetPlayer = "nearest",
                matchTargetPart = true
            }
        }
    },
}

-- Liste der Körperteile (wird hier nicht weiter verwendet, da wir über die keyframe-Konfiguration iterieren)
local bodyParts = {}
for partName, _ in pairs(keyframes[1].config) do
    table.insert(bodyParts, partName)
end

-- Hilfsfunktion zum Interpolieren zwischen zwei Vektoren
local function LerpVector3(start, target, alpha)
    return start:Lerp(target, alpha)
end

-- Funktion zum Finden eines Spielers anhand eines Teilnamens (unterstützt "nearest", "farthest" und "random")
local function FindPlayerByPartialName(partialName, partName)
    if partialName == "nearest" then
        if nearestTargetPlayers[partName] then
            return nearestTargetPlayers[partName]
        else
            local localPlayer = Players.LocalPlayer
            local localCharacter = localPlayer.Character
            if not localCharacter then return nil end
            local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
            if not localHumanoidRootPart then return nil end

            local nearestPlayer = nil
            local nearestDistance = math.huge
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    local character = player.Character
                    if character then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local distance = (localHumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                            if distance < nearestDistance then
                                nearestDistance = distance
                                nearestPlayer = player
                            end
                        end
                    end
                end
            end
            nearestTargetPlayers[partName] = nearestPlayer
            return nearestPlayer
        end
    elseif partialName == "farthest" then
        if farthestTargetPlayers[partName] then
            return farthestTargetPlayers[partName]
        else
            local localPlayer = Players.LocalPlayer
            local localCharacter = localPlayer.Character
            if not localCharacter then return nil end
            local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
            if not localHumanoidRootPart then return nil end

            local farthestPlayer = nil
            local farthestDistance = -math.huge
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    local character = player.Character
                    if character then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local distance = (localHumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                            if distance > farthestDistance then
                                farthestDistance = distance
                                farthestPlayer = player
                            end
                        end
                    end
                end
            end
            farthestTargetPlayers[partName] = farthestPlayer
            return farthestPlayer
        end
    elseif partialName == "random" then
        if randomTargetPlayers[partName] then
            return randomTargetPlayers[partName]
        else
            local allPlayers = Players:GetPlayers()
            local validPlayers = {}
            for _, player in ipairs(allPlayers) do
                if player ~= Players.LocalPlayer then
                    table.insert(validPlayers, player)
                end
            end
            if #validPlayers > 0 then
                local randomIndex = math.random(1, #validPlayers)
                local randomPlayer = validPlayers[randomIndex]
                randomTargetPlayers[partName] = randomPlayer
                return randomPlayer
            end
            return nil
        end
    end
    
    partialName = partialName:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(partialName) or (player.DisplayName and player.DisplayName:lower():find(partialName)) then
            return player
        end
    end
    return nil
end

-- Drag-Funktionalität der GUI (bereits oben integriert)

--------------------------------------------------------------------------------
-- SPEICHERN DER URSPRÜNGLICHEN POSITIONEN UND ROTATIONEN
local function SaveOriginalPositions()
    local character = Players.LocalPlayer.Character
    if character then
        for partName, _ in pairs(keyframes[1].config) do
            if partName ~= "Humanoid" then
                local part = character:FindFirstChild(partName)
                if part then
                    originalPositions[partName] = part.CFrame
                end
            end
        end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            initialHumanoidRootPartCFrame = humanoidRootPart.CFrame
        end
    end
end

--------------------------------------------------------------------------------
-- AKTUALISIEREN EINER EINZELNEN KÖRPERTEIL-POSITION
local function UpdateBodyPart(character, partName, currentConfig, nextConfig, alpha)
    local part = character:FindFirstChild(partName)
    if part and BodyLifted and partName ~= "Humanoid" then
        local baseCFrame = originalPositions[partName]
        if baseCFrame then
            local currentTargetCFrame = baseCFrame
            local nextTargetCFrame = baseCFrame
            
            if currentConfig.targetPlayer and currentConfig.targetPlayer ~= "" then
                local currentPlayer = FindPlayerByPartialName(currentConfig.targetPlayer, partName)
                if currentPlayer and currentPlayer.Character then
                    if currentConfig.matchTargetPart then
                        local targetPart = currentPlayer.Character:FindFirstChild(partName)
                        if targetPart then
                            currentTargetCFrame = CFrame.new(targetPart.Position)
                        end
                    else
                        local targetHumanoidRootPart = currentPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetHumanoidRootPart then
                            currentTargetCFrame = CFrame.new(targetHumanoidRootPart.Position)
                        end
                    end
                end
            else
                currentTargetCFrame = CFrame.new(baseCFrame.Position)
            end
            
            if nextConfig.targetPlayer and nextConfig.targetPlayer ~= "" then
                local nextPlayer = FindPlayerByPartialName(nextConfig.targetPlayer, partName)
                if nextPlayer and nextPlayer.Character then
                    if nextConfig.matchTargetPart then
                        local targetPart = nextPlayer.Character:FindFirstChild(partName)
                        if targetPart then
                            nextTargetCFrame = CFrame.new(targetPart.Position)
                        end
                    else
                        local targetHumanoidRootPart = nextPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetHumanoidRootPart then
                            nextTargetCFrame = CFrame.new(targetHumanoidRootPart.Position)
                        end
                    end
                end
            else
                nextTargetCFrame = CFrame.new(baseCFrame.Position)
            end
            
            local currentOffset = CFrame.new(currentConfig.position) *
                CFrame.Angles(
                    math.rad(currentConfig.rotation.X),
                    math.rad(currentConfig.rotation.Y),
                    math.rad(currentConfig.rotation.Z)
                )
            local nextOffset = CFrame.new(nextConfig.position) *
                CFrame.Angles(
                    math.rad(nextConfig.rotation.X),
                    math.rad(nextConfig.rotation.Y),
                    math.rad(nextConfig.rotation.Z)
                )
            
            local finalCurrentCFrame = currentTargetCFrame * currentOffset
            local finalNextCFrame = nextTargetCFrame * nextOffset
            local finalCFrame = finalCurrentCFrame:Lerp(finalNextCFrame, alpha)
            
            local _, origYaw, _ = baseCFrame:ToOrientation()
            finalCFrame = CFrame.new(finalCFrame.Position) * CFrame.Angles(0, origYaw, 0)
            
            part.CFrame = finalCFrame
            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end

--------------------------------------------------------------------------------
-- AKTUALISIEREN DES HUMANOID (bzw. des HumanoidRootPart)
local function UpdateHumanoid(character, currentConfig, nextConfig, alpha)
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoidRootPart and initialHumanoidRootPartCFrame then
        local currentTargetCFrame = initialHumanoidRootPartCFrame
        local nextTargetCFrame = initialHumanoidRootPartCFrame
        
        if currentConfig.targetPlayer and currentConfig.targetPlayer ~= "" then
            local currentPlayer = FindPlayerByPartialName(currentConfig.targetPlayer, "Humanoid")
            if currentPlayer and currentPlayer.Character then
                local targetHumanoidRootPart = currentPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHumanoidRootPart then
                    currentTargetCFrame = CFrame.new(targetHumanoidRootPart.Position)
                end
            end
        else
            currentTargetCFrame = CFrame.new(initialHumanoidRootPartCFrame.Position)
        end
        
        if nextConfig.targetPlayer and nextConfig.targetPlayer ~= "" then
            local nextPlayer = FindPlayerByPartialName(nextConfig.targetPlayer, "Humanoid")
            if nextPlayer and nextPlayer.Character then
                local targetHumanoidRootPart = nextPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHumanoidRootPart then
                    nextTargetCFrame = CFrame.new(targetHumanoidRootPart.Position)
                end
            end
        else
            nextTargetCFrame = CFrame.new(initialHumanoidRootPartCFrame.Position)
        end
        
        local currentOffset = CFrame.new(currentConfig.position) *
            CFrame.Angles(
                math.rad(currentConfig.rotation.X),
                math.rad(currentConfig.rotation.Y),
                math.rad(currentConfig.rotation.Z)
            )
        local nextOffset = CFrame.new(nextConfig.position) *
            CFrame.Angles(
                math.rad(nextConfig.rotation.X),
                math.rad(nextConfig.rotation.Y),
                math.rad(nextConfig.rotation.Z)
            )
        
        local finalCurrentCFrame = currentTargetCFrame * currentOffset
        local finalNextCFrame = nextTargetCFrame * nextOffset
        local finalCFrame = finalCurrentCFrame:Lerp(finalNextCFrame, alpha)
        
        local _, origYaw, _ = initialHumanoidRootPartCFrame:ToOrientation()
        finalCFrame = CFrame.new(finalCFrame.Position) * CFrame.Angles(0, origYaw, 0)
        
        humanoidRootPart.CFrame = finalCFrame
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        humanoid.WalkSpeed = 16
    end
end

--------------------------------------------------------------------------------
-- BODY UPDATE FUNKTION (wird jeden Heartbeat aufgerufen)
local function UpdateBody()
    local character = Players.LocalPlayer.Character
    if character and BodyLifted then
        local humanoid = character:FindFirstChild("Humanoid")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoid and humanoidRootPart and initialHumanoidRootPartCFrame then
            local deltaTime = tick() - lastKeyframeTime
            animationTime = animationTime + deltaTime
            lastKeyframeTime = tick()
            
            local currentFrame = keyframes[currentKeyframe]
            local nextFrame = keyframes[currentKeyframe + 1]
            if not nextFrame then
                nextFrame = keyframes[1]
            end
            
            local alpha = math.min(animationTime / currentFrame.duration, 1)
            
            for partName, _ in pairs(currentFrame.config) do
                UpdateBodyPart(character, partName, currentFrame.config[partName], nextFrame.config[partName], alpha)
            end
            if currentFrame.config.Humanoid then
                UpdateHumanoid(character, currentFrame.config.Humanoid, nextFrame.config.Humanoid, alpha)
            end
            if alpha >= 1 then
                currentKeyframe = currentKeyframe + 1
                if currentKeyframe > #keyframes then
                    currentKeyframe = 1
                end
                animationTime = 0
            end
        end
    end
end

--------------------------------------------------------------------------------
-- FUNKTION ZUM SICHEREN DEAKTIVIERENS DES RAGDOLLS
local function SafeDeactivateRagdoll()
    for i = 1, 3 do
        ReplicatedStorage.UnragdollEvent:FireServer()
        task.wait(0.1)
    end
    
    local character = Players.LocalPlayer.Character
    if character then
        for partName, _ in pairs(keyframes[1].config) do
            if partName ~= "Humanoid" then
                local part = character:FindFirstChild(partName)
                if part and originalPositions[partName] then
                    part.CFrame = originalPositions[partName]
                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
    
    nearestTargetPlayers = {}
    farthestTargetPlayers = {}
    randomTargetPlayers = {}
    initialHumanoidRootPartCFrame = nil
end

--------------------------------------------------------------------------------
-- TOGGLE BUTTON FUNKTIONALITÄT
ToggleButton.MouseButton1Click:Connect(function()
    BodyLifted = not BodyLifted
    
    if BodyLifted then
        ToggleButton.Text = "DEACTIVATE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        
        SaveOriginalPositions()
        currentKeyframe = 1
        animationTime = 0
        lastKeyframeTime = tick()
        
        -- Entferne vorhandene Sitzplätze und sichere sie in seatBackup
        for _, obj in ipairs(game.Workspace:GetDescendants()) do
            if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
                table.insert(seatBackup, {seat = obj, parent = obj.Parent})
                obj.Parent = nil
            end
        end
        
        -- Überwache neu hinzugefügte Sitzplätze und entferne diese sofort
        seatAddedConnection = game.Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
                table.insert(seatBackup, {seat = obj, parent = obj.Parent})
                obj.Parent = nil
            end
        end)
        
        if UpdateConnection then
            UpdateConnection:Disconnect()
        end
        UpdateConnection = RunService.Heartbeat:Connect(UpdateBody)
        
        ReplicatedStorage.RagdollEvent:FireServer()
    else
        ToggleButton.Text = "ACTIVATE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 180, 45)
        
        if UpdateConnection then
            UpdateConnection:Disconnect()
        end
        
        -- Beende die Überwachung neuer Sitzplätze
        if seatAddedConnection then
            seatAddedConnection:Disconnect()
            seatAddedConnection = nil
        end
        
        -- Stelle alle entfernten Sitzplätze wieder her
        for _, data in ipairs(seatBackup) do
            if data.seat and data.parent then
                data.seat.Parent = data.parent
            end
        end
        seatBackup = {}
        
        SafeDeactivateRagdoll()
    end
end)

--------------------------------------------------------------------------------
-- CLOSE BUTTON (beendet das Script)
CloseButton.MouseButton1Click:Connect(function()
    if BodyLifted then
        BodyLifted = false
        if UpdateConnection then
            UpdateConnection:Disconnect()
        end
        -- Wiederherstellen der Sitzplätze beim Beenden
        if seatAddedConnection then
            seatAddedConnection:Disconnect()
            seatAddedConnection = nil
        end
        for _, data in ipairs(seatBackup) do
            if data.seat and data.parent then
                data.seat.Parent = data.parent
            end
        end
        seatBackup = {}
        SafeDeactivateRagdoll()
    end
    ScreenGui:Destroy()
end)

--------------------------------------------------------------------------------
-- RESET beim Respawn
Players.LocalPlayer.CharacterAdded:Connect(function()
    if BodyLifted then
        BodyLifted = false
        if UpdateConnection then
            UpdateConnection:Disconnect()
        end
        ToggleButton.Text = "ACTIVATE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 180, 45)
        
        if seatAddedConnection then
            seatAddedConnection:Disconnect()
            seatAddedConnection = nil
        end
        for _, data in ipairs(seatBackup) do
            if data.seat and data.parent then
                data.seat.Parent = data.parent
            end
        end
        seatBackup = {}
        
        SafeDeactivateRagdoll()
    end
end)
