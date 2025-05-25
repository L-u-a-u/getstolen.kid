-- Instant Respawn Script with Countdown GUI
-- Uses Humanoid.Died event and CharacterAdded for reliable position restoration
local player = game.Players.LocalPlayer
local deadPos -- This will store the CFrame VALUE of the HumanoidRootPart
local deadCam -- This will store the CFrame VALUE of the Camera

-- Create a clean countdown GUI
local function createCountdownGUI()
    -- Remove any existing countdown GUI
    local existingGUI = player.PlayerGui:FindFirstChild("RespawnCountdownGUI")
    if existingGUI then
        existingGUI:Destroy()
    end
    
    -- Create new GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RespawnCountdownGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    -- Create the main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(0.5, -100, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Add corner radius
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame
    
    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Text = "Resetting Character"
    titleLabel.Parent = frame
    
    -- Countdown label
    local countdownLabel = Instance.new("TextLabel")
    countdownLabel.Size = UDim2.new(1, 0, 0, 40)
    countdownLabel.Position = UDim2.new(0, 0, 0, 35)
    countdownLabel.BackgroundTransparency = 1
    countdownLabel.Font = Enum.Font.GothamBold
    countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    countdownLabel.TextSize = 20
    countdownLabel.Name = "CountdownLabel"
    countdownLabel.Parent = frame
    
    return screenGui, countdownLabel
end

-- Function to log position on death (from your example code)
local function logPosition()
    local character = player.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            deadPos = hrp.CFrame
            -- Also store camera position
            if workspace.CurrentCamera then
                deadCam = workspace.CurrentCamera.CFrame
            end
        end
    end
end

-- Set up position restoration connection
-- Connecting to Died event to save position
local diedConnection
local function setupDiedConnection()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Disconnect existing connection if any
            if diedConnection then
                diedConnection:Disconnect()
            end
            
            -- Connect new died event
            diedConnection = humanoid.Died:Connect(logPosition)
        end
    end
end

-- Set up CharacterAdded connection for teleporting back
local characterAddedConnection = player.CharacterAdded:Connect(function(char)
    -- Set up died connection for the new character
    local humanoid = char:WaitForChild("Humanoid", 3)
    if humanoid then
        diedConnection = humanoid.Died:Connect(logPosition)
    end
    
    -- Teleport to previous position if available
    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    if hrp and deadPos then
        hrp.CFrame = deadPos
        
        -- Set camera back to original position if available
        if workspace.CurrentCamera and deadCam then
            workspace.CurrentCamera.CFrame = deadCam
        end
    end
end)

-- Main function for instant respawn
local function performInstantRespawn()
    -- Store initial position first
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Store initial position
    deadPos = hrp.CFrame
    
    -- Store camera position
    if workspace.CurrentCamera then
        deadCam = workspace.CurrentCamera.CFrame
    end
    
    -- Setup died connection for current character
    setupDiedConnection()
    
    -- Create and show the countdown GUI
    local gui, countdownLabel = createCountdownGUI()
    
    -- Calculate exact same respawn timing as original script
    local respawnTime = game.Players.RespawnTime - 0.165
    
    -- Update countdown in a separate thread to avoid adding delays
    spawn(function()
        local startTime = tick()
        local endTime = startTime + respawnTime
        
        while tick() < endTime and gui and gui.Parent do
            local remaining = math.max(0, math.ceil(endTime - tick()))
            countdownLabel.Text = remaining .. "s"
            wait(0.05) -- Update frequently but don't add significant delay
        end
        
        countdownLabel.Text = "Respawning..."
    end)
    
    -- Use replicatesignal if available (exact same as original)
    if typeof(replicatesignal) == "function" then
        replicatesignal(player.ConnectDiedSignalBackend)
    end
    
    -- Wait the exact same time as original script
    wait(respawnTime)
    
    -- Kill the character using your Health = 0 method
    character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0 -- Using your method instead of ChangeState
        end
    end
    
    -- Wait a bit to make sure the character died and CharacterAdded will fire
    wait(0.85) -- Slightly longer wait to ensure CharacterAdded handles the teleport
    
    -- Remove the GUI
    if gui and gui.Parent then
        gui:Destroy()
    end
end

-- Run the respawn function
performInstantRespawn()

-- Cleanup function to use when script stops running
local function cleanup()
    if diedConnection then
        diedConnection:Disconnect()
    end
    
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
    end
    
    local gui = player.PlayerGui:FindFirstChild("RespawnCountdownGUI")
    if gui then
        gui:Destroy()
    end
end

-- Optional: Call cleanup() when you want to stop the script
