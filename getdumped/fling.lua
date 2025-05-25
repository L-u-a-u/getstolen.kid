local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Blacklist and Settings
local Blacklist, kroneUserids = {}, {4710732523, 354902977}
local Settings = {Distance = 18, Globals = {"Executions", "List"}}
local WhitelistedPlayers = {}

-- Script State Variables
local scriptEnabled = false
local targetPlayers = {} -- Table to store multiple targets
local viewingPlayers = {} -- Track players being viewed
local SavedPosition = nil
local SavedCamera = nil
local CF = nil

-- Enhanced UI Colors
local Colors = {
    Background = Color3.fromRGB(25, 25, 35),
    Primary = Color3.fromRGB(40, 40, 60),
    Accent = Color3.fromRGB(0, 120, 215),
    Text = Color3.fromRGB(230, 230, 240),
    Highlight = Color3.fromRGB(0, 180, 240)
}

-- GUI Creation
local function createEnhancedUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if game:GetService("RunService"):IsStudio() then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end

    -- Main Frame (Draggable)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 150, 0, 50) -- Smaller size
    MainFrame.Position = UDim2.new(0.5, -75, 0.05, 0) -- Adjusted position
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainFrameCorner = Instance.new("UICorner")
    MainFrameCorner.CornerRadius = UDim.new(0, 10)
    MainFrameCorner.Parent = MainFrame

    local MainFrameStroke = Instance.new("UIStroke")
    MainFrameStroke.Color = Colors.Accent
    MainFrameStroke.Thickness = 2
    MainFrameStroke.Parent = MainFrame

    -- Toggle and Target Buttons Frame
    local ToggleTargetFrame = Instance.new("Frame")
    ToggleTargetFrame.Size = UDim2.new(1, 0, 1, 0)
    ToggleTargetFrame.BackgroundColor3 = Colors.Primary
    ToggleTargetFrame.Parent = MainFrame

    local ToggleTargetFrameCorner = Instance.new("UICorner")
    ToggleTargetFrameCorner.CornerRadius = UDim.new(0, 8)
    ToggleTargetFrameCorner.Parent = ToggleTargetFrame

    -- Toggle Button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleButton.BackgroundColor3 = Colors.Primary
    ToggleButton.Text = "Fling: OFF"
    ToggleButton.TextColor3 = Colors.Text
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 12
    ToggleButton.Parent = ToggleTargetFrame
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(0, 8)
    ToggleButtonCorner.Parent = ToggleButton
    
    
     -- Target Button
    local TargetButton = Instance.new("TextButton")
    TargetButton.Size = UDim2.new(0.3, 0, 1, 0)
    TargetButton.Position = UDim2.new(0.7, 0, 0, 0)
    TargetButton.BackgroundColor3 = Colors.Primary
    TargetButton.Text = "🎯"
    TargetButton.TextColor3 = Colors.Text
    TargetButton.Font = Enum.Font.GothamBold
    TargetButton.TextSize = 12
    TargetButton.Parent = ToggleTargetFrame
    
    local TargetButtonCorner = Instance.new("UICorner")
    TargetButtonCorner.CornerRadius = UDim.new(0, 8)
    TargetButtonCorner.Parent = TargetButton
    
    -- Player List Frame
    local PlayerListFrame = Instance.new("Frame")
    PlayerListFrame.Size = UDim2.new(0, 200, 0, 300) -- Smaller size
    PlayerListFrame.Position = UDim2.new(0.5, -100, 0.5, -150) -- Adjusted position
    PlayerListFrame.BackgroundColor3 = Colors.Background
    PlayerListFrame.Visible = false
    PlayerListFrame.Active = true
    PlayerListFrame.Draggable = true
    PlayerListFrame.Parent = ScreenGui

    local PlayerListCorner = Instance.new("UICorner")
    PlayerListCorner.CornerRadius = UDim.new(0, 10)
    PlayerListCorner.Parent = PlayerListFrame

    local PlayerListStroke = Instance.new("UIStroke")
    PlayerListStroke.Color = Colors.Accent
    PlayerListStroke.Thickness = 2
    PlayerListStroke.Parent = PlayerListFrame

    -- Player List Title
    local PlayerListTitle = Instance.new("TextLabel")
    PlayerListTitle.Size = UDim2.new(1, 0, 0, 30) -- Smaller size
    PlayerListTitle.BackgroundColor3 = Colors.Primary
    PlayerListTitle.Text = "Select Target Player"
    PlayerListTitle.TextColor3 = Colors.Text
    PlayerListTitle.Font = Enum.Font.GothamBold
    PlayerListTitle.TextSize = 14
    PlayerListTitle.Parent = PlayerListFrame

    local PlayerListTitleCorner = Instance.new("UICorner")
    PlayerListTitleCorner.CornerRadius = UDim.new(0, 10)
    PlayerListTitleCorner.Parent = PlayerListTitle

    -- Scrolling Frame
    local PlayerScrollFrame = Instance.new("ScrollingFrame")
    PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -40) -- Adjusted size
    PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 35) -- Adjusted position
    PlayerScrollFrame.BackgroundTransparency = 1
    PlayerScrollFrame.ScrollBarThickness = 5
    PlayerScrollFrame.Parent = PlayerListFrame
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- initialize canvas size to 0,0

    local PlayerListLayout = Instance.new("UIListLayout")
    PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PlayerListLayout.Padding = UDim.new(0, 5)
    PlayerListLayout.Parent = PlayerScrollFrame

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ToggleButton = ToggleButton,
		TargetButton = TargetButton,
        PlayerListFrame = PlayerListFrame,
        PlayerScrollFrame = PlayerScrollFrame,
		PlayerListLayout = PlayerListLayout,
        ToggleTargetFrame = ToggleTargetFrame
    }
end

local UI = createEnhancedUI()

-- Player Entry Creation Function
local function createPlayerEntry(player)
    local PlayerFrame = Instance.new("Frame")
    PlayerFrame.Size = UDim2.new(1, 0, 0, 30)
    PlayerFrame.BackgroundColor3 = Colors.Primary
    PlayerFrame.Parent = UI.PlayerScrollFrame

    local PlayerFrameCorner = Instance.new("UICorner")
    PlayerFrameCorner.CornerRadius = UDim.new(0, 6)
    PlayerFrameCorner.Parent = PlayerFrame

    local PlayerButton = Instance.new("TextButton")
    PlayerButton.Size = UDim2.new(0.7, 0, 1, 0)
    PlayerButton.Position = UDim2.new(0.05,0,0,0)
    PlayerButton.BackgroundColor3 = Colors.Primary
    PlayerButton.Text = ""
    PlayerButton.TextColor3 = Colors.Text
    PlayerButton.Font = Enum.Font.GothamMedium
    PlayerButton.TextSize = 10
    PlayerButton.TextXAlignment = Enum.TextXAlignment.Left
    PlayerButton.Parent = PlayerFrame

    local PlayerButtonCorner = Instance.new("UICorner")
    PlayerButtonCorner.CornerRadius = UDim.new(0, 6)
    PlayerButtonCorner.Parent = PlayerButton

    local PlayerThumbnail = Instance.new("ImageLabel")
    PlayerThumbnail.Size = UDim2.new(0, 20, 0, 20)
    PlayerThumbnail.Position = UDim2.new(0, 5, 0.5, -10)
    PlayerThumbnail.BackgroundTransparency = 1
    PlayerThumbnail.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    PlayerThumbnail.Parent = PlayerButton

    local PlayerNameLabel = Instance.new("TextLabel")
    PlayerNameLabel.Size = UDim2.new(1, -40, 1, 0)
    PlayerNameLabel.Position = UDim2.new(0, 30, 0, 0)
    PlayerNameLabel.BackgroundTransparency = 1
    PlayerNameLabel.TextColor3 = Colors.Text
    PlayerNameLabel.Font = Enum.Font.GothamMedium
    PlayerNameLabel.TextSize = 10
    PlayerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlayerNameLabel.Text = player.Name
    PlayerNameLabel.Parent = PlayerButton

    local ViewButton = Instance.new("TextButton")
    ViewButton.Size = UDim2.new(0.3, 0, 1, 0)
    ViewButton.Position = UDim2.new(0.7, 0, 0, 0)
    ViewButton.BackgroundColor3 = Colors.Primary
    ViewButton.Text = "👁️"
    ViewButton.TextColor3 = Colors.Text
    ViewButton.Font = Enum.Font.GothamBold
    ViewButton.TextSize = 10
    ViewButton.Parent = PlayerFrame

    local ViewButtonCorner = Instance.new("UICorner")
    ViewButtonCorner.CornerRadius = UDim.new(0, 6)
    ViewButtonCorner.Parent = ViewButton

     PlayerButton.MouseButton1Click:Connect(function()
        if table.find(targetPlayers, player) then
            table.remove(targetPlayers, table.find(targetPlayers, player))
            PlayerButton.BackgroundColor3 = Colors.Primary
        else
            table.insert(targetPlayers, player)
            PlayerButton.BackgroundColor3 = Colors.Highlight
        end
    end)

    ViewButton.MouseButton1Click:Connect(function()
        if table.find(viewingPlayers, player) then
           table.remove(viewingPlayers, table.find(viewingPlayers, player))
           ViewButton.BackgroundColor3 = Colors.Primary
           if workspace.CurrentCamera.CameraSubject == player.Character:FindFirstChild("Head") then
              workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
           end
       else
           table.insert(viewingPlayers, player)
           ViewButton.BackgroundColor3 = Colors.Highlight
       end
   end)

    return PlayerFrame
end

-- Player List Management
local playerEntries = {}
local function updatePlayerList()
    local players = Players:GetPlayers()
    local totalHeight = 0

    -- Add new players
    for _, player in ipairs(players) do
        if player ~= LocalPlayer and not playerEntries[player] then
            local playerEntry = createPlayerEntry(player)
            playerEntries[player] = playerEntry
        end
    end

     -- Remove old players
    for player, entry in pairs(playerEntries) do
        local found = false
        for _, p in ipairs(players) do
            if p == player then
                found = true
                break
            end
        end
        if not found then
           entry:Destroy()
           playerEntries[player] = nil
        end
    end
    
     for _, entry in pairs(UI.PlayerScrollFrame:GetChildren()) do
        if entry:IsA("Frame") then
             totalHeight = totalHeight + entry.AbsoluteSize.Y + UI.PlayerListLayout.Padding.Offset
         end
     end

  local frameHeight = UI.PlayerScrollFrame.AbsoluteSize.Y
  if totalHeight > frameHeight then
        UI.PlayerScrollFrame.CanvasSize = UDim2.new(0,0,0, totalHeight) -- makes it scrollable
    else
        UI.PlayerScrollFrame.CanvasSize = UDim2.new(0,0,0,0) -- if not many players make not scrollable
    end
end

-- Fling Function
local function shhhlol(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid.RootPart

    local im = TargetPlayer.Character
    local so = im:FindFirstChildOfClass("Humanoid")
    local sorry = so and so.RootPart
    local please = im:FindFirstChild("Head")

    if Character and Humanoid and RootPart then
       
        if not im:FindFirstChildWhichIsA("BasePart") then return end

        local function mmmm(comkid, Pos, Ang)
            RootPart.CFrame = CFrame.new(comkid.Position) * Pos * Ang
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local function wtf(comkid)
            local TimeToWait = 0.134
            local Time = tick()
            
            local Att1 = Instance.new("Attachment", RootPart)
            local Att2 = Instance.new("Attachment", sorry)

            repeat
                if RootPart and so then
                    if comkid.Velocity.Magnitude < 30 then
                        mmmm(
                            comkid,
                            CFrame.new(0, 1.5, 0) + so.MoveDirection * comkid.Velocity.Magnitude / 5,
                            CFrame.Angles(
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180),
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180),
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180)
                            )
                        )
                        RunService.Heartbeat:wait()

                        mmmm(
                            comkid,
                            CFrame.new(0, 1.5, 0) + so.MoveDirection * comkid.Velocity.Magnitude / 1.25,
                            CFrame.Angles(
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180),
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180),
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180)
                            )
                        )
                        RunService.Heartbeat:wait()

                        mmmm(
                            comkid,
                            CFrame.new(0, -1.5, 0) + so.MoveDirection * comkid.Velocity.Magnitude / 1.25,
                            CFrame.Angles(
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180),
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180),
                                math.random(1, 2) == 1 and math.rad(0) or math.rad(180)
                            )
                        )
                        RunService.Heartbeat:wait()
                    else
                        mmmm(comkid, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(0), 0, 0))
                        RunService.Heartbeat:wait()
                    end
                else
                    break
                end
            until comkid.Velocity.Magnitude > 1000 or 
                  comkid.Parent ~= TargetPlayer.Character or
                  TargetPlayer.Parent ~= Players or
                  not TargetPlayer.Character == im or
                  Humanoid.Health <= 0 or
                  tick() > Time + TimeToWait or
                  not scriptEnabled

            Att1:Destroy()
            Att2:Destroy()
            
            if game.PlaceId == 417267366 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(5524, 36, -17126.50)
            else
                LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition or CF
            end
        end

        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(-9e99, 9e99, -9e99)
        BV.MaxForce = Vector3.new(-9e9, 9e9, -9e9)

        local BodyGyro = Instance.new("BodyGyro")
        BodyGyro.CFrame = CFrame.new(LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position)
        BodyGyro.D = 9e8
        BodyGyro.MaxTorque = Vector3.new(-9e9, 9e9, -9e9)
        BodyGyro.P = -9e9

        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.Position = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position
        BodyPosition.D = 9e8
        BodyPosition.MaxForce = Vector3.new(-9e9, 9e9, -9e9)
        BodyPosition.P = -9e9

        if sorry and please then
            if (sorry.CFrame.p - please.CFrame.p).Magnitude > 5 then
                wtf(please)
            else
                wtf(sorry)
            end
        elseif sorry and not please then
            wtf(sorry)
        elseif not sorry and please then
            wtf(please)
        end

        BV:Destroy()
        BodyGyro:Destroy()
        BodyPosition:Destroy()
        
        for _, x in next, Character:GetDescendants() do
            if x:IsA("BasePart") then
                x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
            end
        end
        
        Humanoid:ChangeState("GettingUp")
     end
end

-- Enable Script Function
local function enableScript()
    coroutine.wrap(function()
        while scriptEnabled do
            pcall(function()
                if #targetPlayers > 0 then
                    for _, player in ipairs(targetPlayers) do
                        if LocalPlayer.Character and 
                           LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and 
                           player and player.Character and
                            player.Character:FindFirstChildOfClass("Humanoid") then
                            local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            local RootPart = Humanoid.RootPart
                             if RootPart and Humanoid.Sit == false and RootPart.Velocity.Magnitude < 30 then
                                shhhlol(player)
                            end
                         end
                    end
                else
                    for _, z in pairs(Players:GetPlayers()) do
                        if z ~= LocalPlayer and not table.find(WhitelistedPlayers, tostring(z.UserId)) then
                             if LocalPlayer.Character and 
                               LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and 
                               z and z.Character and
                               z.Character:FindFirstChildOfClass("Humanoid") then
                                local Humanoid = z.Character:FindFirstChildOfClass("Humanoid")
                                local RootPart = Humanoid.RootPart
                                 if RootPart and Humanoid.Sit == false and RootPart.Velocity.Magnitude < 30 then
                                    shhhlol(z)
                                end
                             end
                        end
                    end
                end
                if scriptEnabled then
                    for _, player in ipairs(viewingPlayers) do
                        if player and player.Character and player.Character:FindFirstChild("Head") then
                           workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Head")
                        end
                    end
                else
                  workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                 end
            end)
            wait()
        end
    end)()
end

-- Event Connections
UI.ToggleButton.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled

    if scriptEnabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            SavedCamera = workspace.CurrentCamera.CFrame
        end
        
        UI.ToggleButton.Text = "Fling: ON"
        UI.ToggleButton.BackgroundColor3 = Colors.Highlight
        enableScript()
    else
        wait(0.1)
        if SavedPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
        end
        
        -- Restore camera position
        if SavedCamera then
            workspace.CurrentCamera.CFrame = SavedCamera
        end
         for _, player in ipairs(viewingPlayers) do
             if player and player.Character and player.Character:FindFirstChild("Head") then
                 workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                 table.remove(viewingPlayers, table.find(viewingPlayers, player))
            end
         end
        UI.ToggleButton.Text = "Fling: OFF"
        UI.ToggleButton.BackgroundColor3 = Colors.Primary
    end
end)

UI.TargetButton.MouseButton1Click:Connect(function()
    UI.PlayerListFrame.Visible = not UI.PlayerListFrame.Visible
    updatePlayerList()
end)

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
      local playerEntry = createPlayerEntry(player)
      playerEntries[player] = playerEntry
        updatePlayerList()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if playerEntries[player] then
        playerEntries[player]:Destroy()
        playerEntries[player] = nil
    end
     updatePlayerList()
end)

-- Initialize
updatePlayerList()
