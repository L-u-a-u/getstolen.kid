-- Professional-Grade Character Physics Manipulation Utility
-- Streamlined control system for character velocity and collision manipulation

-- Core Service Initialization
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Global Configuration
local Config = {
    GUI_COLORS = {
        BACKGROUND = Color3.fromRGB(25, 25, 35),
        BUTTON_OFF = Color3.fromRGB(45, 45, 65),
        BUTTON_ON = Color3.fromRGB(0, 120, 50),
        ACCENT = Color3.fromRGB(65, 105, 225),
        TEXT = Color3.fromRGB(240, 240, 240)
    },
    FLING = {
        STRENGTH = 500000,
        MOVEMENT_DELTA = 0.1
    }
}

-- State Management
local State = {
    isAlive = true,
    isResetting = false,
    flingEnabled = false,
    collisionEnabled = false,
    character = nil,
    root = nil,
    humanoid = nil,
    velocity = nil
}

-- Enhanced UI Components Creation
local function createEnhancedUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PhysicsControlPanel"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main Control Panel
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 140)
    mainFrame.Position = UDim2.new(0.01, 0, 0.7, 0)
    mainFrame.BackgroundColor3 = Config.GUI_COLORS.BACKGROUND
    mainFrame.BorderSizePixel = 0
    mainFrame.Name = "ControlPanel"
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Config.GUI_COLORS.ACCENT
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Physics Controller"
    titleText.TextColor3 = Config.GUI_COLORS.TEXT
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.Parent = titleBar

    -- Rounded Corners
    local function addCorners(instance)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = instance
    end

    addCorners(mainFrame)
    addCorners(titleBar)

    -- Create Toggle Button Function
    local function createToggleButton(title, position)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0, 35)
        button.Position = position
        button.BackgroundColor3 = Config.GUI_COLORS.BUTTON_OFF
        button.Text = title
        button.TextColor3 = Config.GUI_COLORS.TEXT
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 14
        button.Parent = mainFrame
        
        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        buttonStroke.Color = Config.GUI_COLORS.ACCENT
        buttonStroke.Thickness = 1
        buttonStroke.Parent = button
        
        addCorners(button)
        return button
    end

    -- Create Buttons
    local flingButton = createToggleButton("Fling: OFF", UDim2.new(0.05, 0, 0.3, 0))
    local collisionButton = createToggleButton("No-Clip: OFF", UDim2.new(0.05, 0, 0.65, 0))

    return {
        flingButton = flingButton,
        collisionButton = collisionButton
    }
end

-- Button State Management
local function updateButtonState(button, enabled, onText, offText)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {
        BackgroundColor3 = enabled and Config.GUI_COLORS.BUTTON_ON or Config.GUI_COLORS.BUTTON_OFF
    }
    
    TweenService:Create(button, tweenInfo, goal):Play()
    button.Text = enabled and onText or offText
end

-- Character Management Functions
local function setupCharacter()
    State.character = Players.LocalPlayer.Character
    if State.character then
        State.root = State.character:FindFirstChild("HumanoidRootPart")
        State.humanoid = State.character:FindFirstChild("Humanoid")
        
        if State.humanoid then
            State.humanoid.Died:Connect(function()
                State.isAlive = false
            end)
        end
    end
end

-- Collision Handler
local function handleCollisions()
    if not State.collisionEnabled then return end
    
    for _, player in next, Players:GetPlayers() do
        if player ~= Players.LocalPlayer and player.Character then
            pcall(function()
                for _, part in next, player.Character:GetChildren() do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                        if part.Name == "Torso" then
                            part.Massless = true
                        end
                        part.Velocity = Vector3.new()
                        part.RotVelocity = Vector3.new()
                    end
                end
            end)
        end
    end
end

-- Fling Handler
local function handleFling()
    if not State.flingEnabled or State.isResetting or not State.isAlive then return end
    
    if not (State.character and State.character.Parent and State.root and State.root.Parent) then return end
    
    if not State.humanoid or State.humanoid.Health <= 0 then
        State.isAlive = false
        return
    end
    
    State.velocity = State.root.Velocity
    State.root.Velocity = State.velocity * Config.FLING.STRENGTH + Vector3.new(0, Config.FLING.STRENGTH, 0)
    RunService.RenderStepped:Wait()
    
    if State.character and State.character.Parent and State.root and State.root.Parent then
        State.root.Velocity = State.velocity
    end
    
    RunService.Stepped:Wait()
    
    if State.character and State.character.Parent and State.root and State.root.Parent then
        State.root.Velocity = State.velocity + Vector3.new(0, Config.FLING.MOVEMENT_DELTA, 0)
        Config.FLING.MOVEMENT_DELTA = Config.FLING.MOVEMENT_DELTA * -1
    end
end

-- Main Initialization
local function initialize()
    local ui = createEnhancedUI()
    
    -- Setup Character
    setupCharacter()
    Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        State.isResetting = true
        wait(0.1)
        if newCharacter == Players.LocalPlayer.Character then
            setupCharacter()
            State.isAlive = true
        end
        State.isResetting = false
    end)
    
    -- Button Event Handlers
    ui.flingButton.MouseButton1Click:Connect(function()
        State.flingEnabled = not State.flingEnabled
        updateButtonState(ui.flingButton, State.flingEnabled, "Fling: ON", "Fling: OFF")
    end)
    
    ui.collisionButton.MouseButton1Click:Connect(function()
        State.collisionEnabled = not State.collisionEnabled
        updateButtonState(ui.collisionButton, State.collisionEnabled, "No-Clip: ON", "No-Clip: OFF")
    end)
    
    -- Main Loop Connections
    RunService.Heartbeat:Connect(handleFling)
    RunService.Stepped:Connect(handleCollisions)
end

-- Execute Initialization
initialize()
