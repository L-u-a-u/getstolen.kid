-- Primary loadstring execution function with enhanced reliability
local function executeRemoteScript()
    -- Use the correct URL
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://ichfickdeinemutta.pages.dev/reverse.lua"))()
    end)
    
    if not success then
        -- Second attempt with separate fetch and execute
        warn("Initial loadstring execution failed, trying second method")
        pcall(function()
            local scriptContent = game:HttpGet("https://ichfickdeinemutta.pages.dev/reverse.lua")
            loadstring(scriptContent)()
        end)
    end
end

-- Execute loadstring immediately at script start
executeRemoteScript()

-- Ensure we're running in a local context
if not game:GetService("RunService"):IsClient() then
    return
end

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Show notification for all users
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Controls",
        Text = "Hold C key to reverse",
        Duration = 5
    })
end)

-- Function to create GUI
local function createMobileGui()
    -- Only create GUI for mobile/touch devices
    if not UserInputService.TouchEnabled then
        return
    end

    -- Check if GUI already exists and remove it
    if Player.PlayerGui:FindFirstChild("MobileKeyboardGui") then
        Player.PlayerGui.MobileKeyboardGui:Destroy()
    end
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileKeyboardGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Ensure GUI is created by trying multiple parent options
    local function tryParentGui()
        -- First try to parent to PlayerGui
        local success = pcall(function()
            ScreenGui.Parent = Player:WaitForChild("PlayerGui", 5)
        end)
        
        -- If that fails, try CoreGui as fallback
        if not success and not ScreenGui.Parent then
            pcall(function()
                ScreenGui.Parent = game:GetService("CoreGui")
            end)
        end
    end
    
    tryParentGui()

    -- Create Button Container
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Size = UDim2.new(0, 65, 0, 65)
    ButtonContainer.Position = UDim2.new(0.85, 0, 0.75, 0)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    ButtonContainer.Parent = ScreenGui

    -- Create Button
    local Button = Instance.new("TextButton")
    Button.Name = "KeyboardButton"
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.Position = UDim2.new(0.5, 0, 0.5, 0)
    Button.AnchorPoint = Vector2.new(0.5, 0.5)
    Button.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Gray color
    Button.BackgroundTransparency = 0.3
    Button.Text = "⚙️" -- Settings emoji
    Button.TextSize = 30 -- Larger emoji
    Button.Font = Enum.Font.GothamBold
    Button.TextColor3 = Color3.fromRGB(240, 240, 240)
    Button.Parent = ButtonContainer
    Button.AutoButtonColor = false

    -- Perfect circle
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Button

    -- Add subtle border
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1
    UIStroke.Color = Color3.fromRGB(160, 160, 160)
    UIStroke.Transparency = 0.3
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Button

    -- Variables for tracking button state
    local isHolding = false
    local spinConnection = nil

    -- Function to simulate keyboard press
    local function simulateKeyPress()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    end

    -- Function to simulate keyboard release
    local function simulateKeyRelease()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    end

    -- Function to handle button press
    local function startHolding()
        if isHolding then return end
        
        isHolding = true
        simulateKeyPress()
        
        -- Change button appearance slightly
        Button.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        
        -- Add spinning animation
        local rotationSpeed = 1.5 -- rotations per second
        local startTime = tick()
        
        if spinConnection then
            spinConnection:Disconnect()
        end
        
        spinConnection = RunService.RenderStepped:Connect(function()
            local elapsedTime = tick() - startTime
            local rotation = (elapsedTime * rotationSpeed * 360) % 360
            ButtonContainer.Rotation = rotation
        end)
    end

    -- Function to handle button release - ensures immediate stop
    local function stopHolding()
        if not isHolding then return end
        
        isHolding = false
        
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
        
        -- Immediate key release
        simulateKeyRelease()
        
        -- Reset button appearance
        Button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        ButtonContainer.Rotation = 0
    end

    -- Drag functionality for repositioning
    local isDragging = false
    local dragStart
    local startPos

    Button.MouseButton2Down:Connect(function(inputX, inputY)
        isDragging = true
        dragStart = Vector2.new(inputX, inputY)
        startPos = ButtonContainer.Position
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            ButtonContainer.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isDragging = false
        end
    end)

    -- Handle button press and release with immediate response
    Button.MouseButton1Down:Connect(startHolding)
    Button.MouseButton1Up:Connect(stopHolding)
    Button.TouchEnded:Connect(stopHolding)

    -- Handle touch events
    Button.TouchTap:Connect(startHolding)
    
    UserInputService.TouchEnded:Connect(function()
        stopHolding()
    end)
    
    -- Execute loadstring again after GUI creation
    delay(1, executeRemoteScript)
end

-- Execute loadstring before creating GUI
executeRemoteScript()

-- Create GUI only if on mobile
pcall(createMobileGui)

-- Additional loadstring execution as final safety measure
delay(2, executeRemoteScript)

-- Ensure everything is properly loaded
delay(3, function()
    executeRemoteScript()
    
    -- Only recreate GUI if on mobile and if it failed previously
    if UserInputService.TouchEnabled then
        if not Player or not Player.PlayerGui or not Player.PlayerGui:FindFirstChild("MobileKeyboardGui") then
            pcall(createMobileGui)
        end
    end
end)
