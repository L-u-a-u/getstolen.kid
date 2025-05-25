-- Animation Recorder by AI Assistant
-- Local script for recording and playing animation clips
-- Modified to remove whitelist system, make GUI fully draggable for mobile, remove webhook functionality,
-- add minimize functionality, mirror player animations 1:1 including exact speed and freeze states,
-- and reduce GUI size

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- Retrieve player data
local LocalPlayer = Players.LocalPlayer

-- Variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local GUI
local DraggableFrame
local RecordingClip = false
local CurrentClip = {}
local SavedClips = {}
local LoopingClips = {}
local KeyBinds = {}
local ClipsFolder = "AnimationClipsSaved"
local SaveFileName = "AnimationClips_" .. LocalPlayer.UserId .. ".json"
local SelectedPlayer = nil
local CurrentlyPlayingClip = nil
local CurrentStopFunc = nil
local IsMinimized = false

-- Track animation states
local TrackingAnimations = false
local AnimationTracks = {}
local LastAnimationTime = 0

-- Create GUI
local function CreateGUI()
    -- Main Frame (reduced size: 400x500 -> 300x375)
    GUI = Instance.new("ScreenGui")
    GUI.Name = "AnimationRecorderGUI"
    GUI.ResetOnSpawn = false

    DraggableFrame = Instance.new("Frame")
    DraggableFrame.Name = "MainFrame"
    DraggableFrame.Size = UDim2.new(0, 300, 0, 375)
    DraggableFrame.Position = UDim2.new(0.5, -150, 0.5, -187.5)
    DraggableFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DraggableFrame.BorderSizePixel = 0
    DraggableFrame.Parent = GUI

    -- Round corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = DraggableFrame

    -- Title Bar (height: 30 -> 22)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 22)
    TitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = DraggableFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

    -- Fix corners for title bar
    local CornerFix = Instance.new("Frame")
    CornerFix.Name = "CornerFix"
    CornerFix.Size = UDim2.new(1, 0, 0.5, 0)
    CornerFix.Position = UDim2.new(0, 0, 0.5, 0)
    CornerFix.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    CornerFix.BorderSizePixel = 0
    CornerFix.Parent = TitleBar

    -- Title (font size: 14 -> 12)
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -75, 1, 0)
    Title.Position = UDim2.new(0, 8, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 12
    Title.Text = "Animation Recorder"
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Minimize Button (size: 20x20 -> 15x15)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 15, 0, 15)
    MinimizeButton.Position = UDim2.new(1, -37, 0, 4)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 12
    MinimizeButton.Parent = TitleBar

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(1, 0)
    MinimizeCorner.Parent = MinimizeButton

    -- Close Button (size: 20x20 -> 15x15)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 15, 0, 15)
    CloseButton.Position = UDim2.new(1, -19, 0, 4)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.Text = ""
    CloseButton.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton

    -- Main Content Container (adjusted for smaller frame)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -15, 1, -30)
    ContentFrame.Position = UDim2.new(0, 8, 0, 26)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = DraggableFrame

    -- Player Search Section (height: 60 -> 45)
    local SearchSection = Instance.new("Frame")
    SearchSection.Name = "SearchSection"
    SearchSection.Size = UDim2.new(1, 0, 0, 45)
    SearchSection.BackgroundTransparency = 1
    SearchSection.Parent = ContentFrame

    local SearchLabel = Instance.new("TextLabel")
    SearchLabel.Name = "SearchLabel"
    SearchLabel.Size = UDim2.new(1, 0, 0, 15)
    SearchLabel.BackgroundTransparency = 1
    SearchLabel.Font = Enum.Font.Gotham
    SearchLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchLabel.TextSize = 12
    SearchLabel.Text = "Search Player:"
    SearchLabel.TextXAlignment = Enum.TextXAlignment.Left
    SearchLabel.Parent = SearchSection

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, 0, 0, 22)
    SearchBox.Position = UDim2.new(0, 0, 0, 18)
    SearchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SearchBox.BorderSizePixel = 0
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 12
    SearchBox.PlaceholderText = "Enter username or display name..."
    SearchBox.Text = ""
    SearchBox.Parent = SearchSection

    local SearchBoxCorner = Instance.new("UICorner")
    SearchBoxCorner.CornerRadius = UDim.new(0, 4)
    SearchBoxCorner.Parent = SearchBox

    -- Dropdown for search results (item height: 30 -> 22)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "DropdownFrame"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
    DropdownFrame.Position = UDim2.new(0, 0, 0, 45)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Visible = false
    DropdownFrame.ZIndex = 5
    DropdownFrame.Parent = SearchSection

    local DropdownLayout = Instance.new("UIListLayout")
    DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropdownLayout.Parent = DropdownFrame

    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 4)
    DropdownCorner.Parent = DropdownFrame

    -- Recording Control Section (height: 40 -> 30)
    local ControlSection = Instance.new("Frame")
    ControlSection.Name = "ControlSection"
    ControlSection.Size = UDim2.new(1, 0, 0, 30)
    ControlSection.Position = UDim2.new(0, 0, 0, 52)
    ControlSection.BackgroundTransparency = 1
    ControlSection.Parent = ContentFrame

    -- Toggle Record Button
    local RecordButton = Instance.new("TextButton")
    RecordButton.Name = "RecordButton"
    RecordButton.Size = UDim2.new(1, 0, 1, 0)
    RecordButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    RecordButton.Font = Enum.Font.GothamBold
    RecordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RecordButton.TextSize = 12
    RecordButton.Text = "START RECORDING"
    RecordButton.Parent = ControlSection

    local RecordCorner = Instance.new("UICorner")
    RecordCorner.CornerRadius = UDim.new(0, 4)
    RecordCorner.Parent = RecordButton

    -- Status Label (height: 20 -> 15)
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, 0, 0, 15)
    StatusLabel.Position = UDim2.new(0, 0, 0, 90)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 10
    StatusLabel.Text = "Ready to record"
    StatusLabel.Parent = ContentFrame

    -- Clips List Section
    local ClipsSection = Instance.new("Frame")
    ClipsSection.Name = "ClipsSection"
    ClipsSection.Size = UDim2.new(1, 0, 1, -112)
    ClipsSection.Position = UDim2.new(0, 0, 0, 112)
    ClipsSection.BackgroundTransparency = 1
    ClipsSection.Parent = ContentFrame

    local ClipsLabel = Instance.new("TextLabel")
    ClipsLabel.Name = "ClipsLabel"
    ClipsLabel.Size = UDim2.new(1, 0, 0, 15)
    ClipsLabel.BackgroundTransparency = 1
    ClipsLabel.Font = Enum.Font.GothamBold
    ClipsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClipsLabel.TextSize = 12
    ClipsLabel.Text = "Saved Clips"
    ClipsLabel.TextXAlignment = Enum.TextXAlignment.Left
    ClipsLabel.Parent = ClipsSection

    local ClipsScrollFrame = Instance.new("ScrollingFrame")
    ClipsScrollFrame.Name = "ClipsScrollFrame"
    ClipsScrollFrame.Size = UDim2.new(1, 0, 1, -18)
    ClipsScrollFrame.Position = UDim2.new(0, 0, 0, 18)
    ClipsScrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ClipsScrollFrame.BorderSizePixel = 0
    ClipsScrollFrame.ScrollBarThickness = 3
    ClipsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ClipsScrollFrame.Parent = ClipsSection

    local ClipsCorner = Instance.new("UICorner")
    ClipsCorner.CornerRadius = UDim.new(0, 4)
    ClipsCorner.Parent = ClipsScrollFrame

    local ClipsList = Instance.new("UIListLayout")
    ClipsList.Padding = UDim.new(0, 4)
    ClipsList.SortOrder = Enum.SortOrder.LayoutOrder
    ClipsList.Parent = ClipsScrollFrame

    local ClipsPadding = Instance.new("UIPadding")
    ClipsPadding.PaddingLeft = UDim.new(0, 4)
    ClipsPadding.PaddingRight = UDim.new(0, 4)
    ClipsPadding.PaddingTop = UDim.new(0, 4)
    ClipsPadding.PaddingBottom = UDim.new(0, 4)
    ClipsPadding.Parent = ClipsScrollFrame

    -- Set parent
    GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

    return {
        MainFrame = DraggableFrame,
        TitleBar = TitleBar,
        CloseButton = CloseButton,
        MinimizeButton = MinimizeButton,
        SearchBox = SearchBox,
        DropdownFrame = DropdownFrame,
        RecordButton = RecordButton,
        StatusLabel = StatusLabel,
        ClipsScrollFrame = ClipsScrollFrame,
        ContentFrame = ContentFrame
    }
end

-- Make Frame Draggable (Enhanced for Mobile)
local function MakeDraggable(frame)
    local dragging = false
    local dragStart
    local frameStart

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            frameStart = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Find player function
local function FindPlayer(searchText)
    if searchText == "" then return {} end

    local results = {}
    for _, player in pairs(Players:GetPlayers()) do
        if string.lower(player.Name):find(string.lower(searchText)) then
            table.insert(results, player)
        elseif string.lower(player.DisplayName):find(string.lower(searchText)) then
            table.insert(results, player)
        end
        
        if #results >= 5 then
            break
        end
    end

    return results
end

-- Update dropdown with search results
local function UpdateDropdown(guiElements, results)
    local dropdown = guiElements.DropdownFrame

    for _, child in pairs(dropdown:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    if #results == 0 then
        dropdown.Visible = false
        dropdown.Size = UDim2.new(1, 0, 0, 0)
        return
    end

    for i, player in ipairs(results) do
        local button = Instance.new("TextButton")
        button.Name = "Result" .. i
        button.Size = UDim2.new(1, 0, 0, 22)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.BorderSizePixel = 0
        button.Font = Enum.Font.Gotham
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 12
        button.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        button.ZIndex = 5
        button.Parent = dropdown
        
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        
        button.MouseButton1Click:Connect(function()
            SelectedPlayer = player
            guiElements.SearchBox.Text = player.DisplayName .. " (@" .. player.Name .. ")"
            dropdown.Visible = false
            guiElements.StatusLabel.Text = "Ready to record " .. player.DisplayName .. "'s animations"
        end)
    end

    dropdown.Size = UDim2.new(1, 0, 0, 22 * #results)
    dropdown.Visible = true
end

-- Generate clip name with auto-incrementing number for duplicates
local function GenerateClipName(playerName)
    local baseName = playerName .. "'s clip"
    local highestNumber = 0

    for _, clip in ipairs(SavedClips) do
        if clip.PlayerName == playerName then
            local clipNumber = clip.Name:match(baseName .. " (%d+)")
            if clipNumber then
                clipNumber = tonumber(clipNumber)
                if clipNumber and clipNumber > highestNumber then
                    highestNumber = clipNumber
                end
            end
        end
    end

    if highestNumber == 0 then
        return baseName .. " 1"
    else
        return baseName .. " " .. (highestNumber + 1)
    end
end

-- Start tracking animations of a player
local function StartTrackingAnimations(player)
    if not player then return end

    local character = player.Character
    if not character then
        player.CharacterAdded:Wait()
        character = player.Character
    end

    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    TrackingAnimations = true
    AnimationTracks = {}

    local clipName = GenerateClipName(player.Name)

    CurrentClip = {
        Name = clipName,
        PlayerName = player.Name,
        Events = {},
        StartTime = tick(),
        InitialCFrame = character:GetPivot(),
        InitialCameraCFrame = workspace.CurrentCamera.CFrame
    }

    local function TrackCharacterTransform()
        local currentTime = tick() - CurrentClip.StartTime
        local currentCFrame = character:GetPivot()
        
        table.insert(CurrentClip.Events, {
            Type = "Transform",
            Time = currentTime,
            CFrame = currentCFrame,
            LookVector = currentCFrame.LookVector
        })
    end

    local equippedTool = nil

    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and item.Parent == character then
            equippedTool = item
            break
        end
    end

    local toolConnection = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            equippedTool = child
        end
    end)

    local toolRemovedConnection = character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == equippedTool then
            equippedTool = nil
        end
    end)

    local function UpdateAnimationTracks()
        local tracks = animator:GetPlayingAnimationTracks()
        local currentTime = tick() - CurrentClip.StartTime
        
        for _, track in pairs(tracks) do
            local trackId = track.Animation.AnimationId
            
            local skipTrack = false
            if equippedTool then
                if trackId:match("tool") or trackId:match("equip") or trackId:match("weapon") then
                    skipTrack = true
                end
            end
            
            if not skipTrack then
                if not AnimationTracks[trackId] or AnimationTracks[trackId].Stopped then
                    AnimationTracks[trackId] = {
                        Track = track,
                        Stopped = false,
                        StartTime = currentTime,
                        LastTimePosition = track.TimePosition,
                        LastUpdateTime = currentTime,
                        LastSpeed = track.Speed,
                        IsFrozen = false
                    }
                    
                    table.insert(CurrentClip.Events, {
                        Type = "Start",
                        AnimationId = trackId,
                        Time = currentTime,
                        Speed = track.Speed,
                        Weight = track.WeightCurrent,
                        TimePosition = track.TimePosition
                    })
                else
                    local trackData = AnimationTracks[trackId]
                    local expectedPosition = trackData.LastTimePosition + 
                        (currentTime - trackData.LastUpdateTime) * trackData.LastSpeed
                    
                    -- Check for freeze state (animation paused)
                    local isFrozen = math.abs(track.TimePosition - trackData.LastTimePosition) < 0.01 and track.Speed ~= 0
                    if isFrozen ~= trackData.IsFrozen then
                        table.insert(CurrentClip.Events, {
                            Type = "Freeze",
                            AnimationId = trackId,
                            Time = currentTime,
                            IsFrozen = isFrozen
                        })
                        trackData.IsFrozen = isFrozen
                    end
                    
                    -- Check for significant time position jump
                    if math.abs(track.TimePosition - expectedPosition) > 0.1 then
                        table.insert(CurrentClip.Events, {
                            Type = "TimeJump",
                            AnimationId = trackId,
                            Time = currentTime,
                            PreviousPosition = trackData.LastTimePosition,
                            NewPosition = track.TimePosition
                        })
                    end
                    
                    -- Record speed changes
                    if math.abs(track.Speed - trackData.LastSpeed) > 0.01 then
                        table.insert(CurrentClip.Events, {
                            Type = "Speed",
                            AnimationId = trackId,
                            Time = currentTime,
                            Speed = track.Speed
                        })
                        trackData.LastSpeed = track.Speed
                    end
                    
                    -- Record weight changes
                    if math.abs(track.WeightCurrent - trackData.Track.WeightCurrent) > 0.01 then
                        table.insert(CurrentClip.Events, {
                            Type = "Weight",
                            AnimationId = trackId,
                            Time = currentTime,
                            Weight = track.WeightCurrent
                        })
                    end
                    
                    trackData.Track = track
                    trackData.LastTimePosition = track.TimePosition
                    trackData.LastUpdateTime = currentTime
                end
            end
        end
        
        for id, data in pairs(AnimationTracks) do
            if not data.Stopped then
                local stillPlaying = false
                
                for _, track in pairs(tracks) do
                    if track.Animation.AnimationId == id then
                        stillPlaying = true
                        break
                    end
                end
                
                if not stillPlaying then
                    data.Stopped = true
                    
                    table.insert(CurrentClip.Events, {
                        Type = "Stop",
                        AnimationId = id,
                        Time = currentTime,
                        FinalPosition = data.LastTimePosition
                    })
                end
            end
        end
    end

    LastAnimationTime = tick()

    local trackingLoop = task.spawn(function()
        while TrackingAnimations do
            UpdateAnimationTracks()
            TrackCharacterTransform()
            task.wait(0.03)
        end
        
        toolConnection:Disconnect()
        toolRemovedConnection:Disconnect()
    end)
end

-- Stop tracking animations
local function StopTrackingAnimations()
    TrackingAnimations = false

    if CurrentClip and #CurrentClip.Events > 0 then
        CurrentClip.Duration = tick() - CurrentClip.StartTime
        
        CurrentClip.Id = HttpService:GenerateGUID(false)
        
        table.insert(SavedClips, CurrentClip)
        
        SaveClipsToFile()
        
        return true
    end

    return false
end

-- Play an animation clip on local character
local function PlayClip(clip, loop)
    if CurrentStopFunc then
        CurrentStopFunc()
        CurrentStopFunc = nil
    end

    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    local originalCFrame = character:GetPivot()
    local originalLookVector = originalCFrame.LookVector

    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    local clipTracks = {}
    CurrentlyPlayingClip = clip.Id

    local function PlayClipOnce()
        local startTime = tick()
        local eventsProcessed = {}
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            
            if elapsed > clip.Duration and not loop then
                connection:Disconnect()
                
                for _, trackData in pairs(clipTracks) do
                    if trackData.Track and trackData.Track.IsPlaying then
                        trackData.Track:Stop()
                    end
                end
                
                if CurrentlyPlayingClip == clip.Id then
                    CurrentlyPlayingClip = nil
                    for _, child in pairs(GUI.MainFrame.ContentFrame.ClipsSection.ClipsScrollFrame:GetChildren()) do
                        if child:IsA("Frame") and child.Name == "Clip_" .. clip.Id then
                            local playButton = child.Actions.PlayButton
                            playButton.Text = "PLAY"
                            playButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
                            break
                        end
                    end
                end
                
                return
            end
            
            if loop and elapsed > clip.Duration then
                startTime = tick()
                table.clear(eventsProcessed)
                elapsed = 0
                
                for _, trackData in pairs(clipTracks) do
                    if trackData.Track and trackData.Track.IsPlaying then
                        trackData.Track:Stop()
                    end
                end
            end
            
            for i, event in ipairs(clip.Events) do
                if not eventsProcessed[i] and elapsed >= event.Time then
                    eventsProcessed[i] = true
                    
                    if event.Type == "Start" then
                        local animation = Instance.new("Animation")
                        animation.AnimationId = event.AnimationId
                        
                        local track = animator:LoadAnimation(animation)
                        track:AdjustSpeed(event.Speed)
                        
                        if event.TimePosition then
                            track.TimePosition = event.TimePosition
                        end
                        
                        track:Play()
                        
                        clipTracks[event.AnimationId] = {
                            Track = track,
                            Animation = animation
                        }
                        
                    elseif event.Type == "Stop" then
                        if clipTracks[event.AnimationId] and clipTracks[event.AnimationId].Track then
                            clipTracks[event.AnimationId].Track:Stop()
                        end
                        
                    elseif event.Type == "Speed" then
                        if clipTracks[event.AnimationId] and clipTracks[event.AnimationId].Track then
                            clipTracks[event.AnimationId].Track:AdjustSpeed(event.Speed)
                        end
                        
                    elseif event.Type == "Weight" then
                        if clipTracks[event.AnimationId] and clipTracks[event.AnimationId].Track then
                            clipTracks[event.AnimationId].Track:AdjustWeight(event.Weight)
                        end
                        
                    elseif event.Type == "TimeJump" then
                        if clipTracks[event.AnimationId] and clipTracks[event.AnimationId].Track then
                            clipTracks[event.AnimationId].Track.TimePosition = event.NewPosition
                        end
                        
                    elseif event.Type == "Freeze" then
                        if clipTracks[event.AnimationId] and clipTracks[event.AnimationId].Track then
                            local track = clipTracks[event.AnimationId].Track
                            if event.IsFrozen then
                                track:AdjustSpeed(0)
                            else
                                track:AdjustSpeed(1)
                            end
                        end
                        
                    elseif event.Type == "Transform" then
                        if event.LookVector then
                            local recordedLookVec = event.LookVector
                            local initialLookVec = clip.InitialCFrame.LookVector
                            
                            local angle = math.atan2(
                                recordedLookVec.X - initialLookVec.X,
                                recordedLookVec.Z - initialLookVec.Z
                            )
                            
                            local currentPos = originalCFrame.Position
                            local rotatedLookVec = CFrame.Angles(0, angle, 0) * originalLookVector
                            
                            local newOrientation = CFrame.new(
                                currentPos,
                                currentPos + rotatedLookVec
                            )
                            
                            local rootPart = character:FindFirstChild("HumanoidRootPart")
                            if rootPart then
                                rootPart.CFrame = CFrame.new(rootPart.Position) * (newOrientation - newOrientation.Position)
                            end
                        end
                    end
                end
            end
        end)
        
        return connection
    end

    local playConnection = PlayClipOnce()

    return function()
        if playConnection then
            playConnection:Disconnect()
        end
        
        CurrentlyPlayingClip = nil
        
        for _, trackData in pairs(clipTracks) do
            if trackData.Track and trackData.Track.IsPlaying then
                trackData.Track:Stop()
            end
        end
    end
end

-- Create a clip entry for the UI (clip height: 80 -> 60)
local function CreateClipEntry(guiElements, clip, index)
    local clipFrame = Instance.new("Frame")
    clipFrame.Name = "Clip_" .. clip.Id
    clipFrame.Size = UDim2.new(1, 0, 0, 60)
    clipFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    clipFrame.BorderSizePixel = 0
    clipFrame.LayoutOrder = index

    local clipCorner = Instance.new("UICorner")
    clipCorner.CornerRadius = UDim.new(0, 4)
    clipCorner.Parent = clipFrame

    local clipHeader = Instance.new("Frame")
    clipHeader.Name = "Header"
    clipHeader.Size = UDim2.new(1, 0, 0, 22)
    clipHeader.BackgroundTransparency = 1
    clipHeader.Parent = clipFrame

    local nameBox = Instance.new("TextBox")
    nameBox.Name = "NameBox"
    nameBox.Size = UDim2.new(1, -82, 1, 0)
    nameBox.Position = UDim2.new(0, 4, 0, 0)
    nameBox.BackgroundTransparency = 1
    nameBox.Font = Enum.Font.GothamBold
    nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBox.TextSize = 12
    nameBox.Text = clip.Name
    nameBox.TextXAlignment = Enum.TextXAlignment.Left
    nameBox.ClearTextOnFocus = false
    nameBox.Parent = clipHeader

    local durationLabel = Instance.new("TextLabel")
    durationLabel.Name = "Duration"
    durationLabel.Size = UDim2.new(0, 75, 1, 0)
    durationLabel.Position = UDim2.new(1, -79, 0, 0)
    durationLabel.BackgroundTransparency = 1
    durationLabel.Font = Enum.Font.Gotham
    durationLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    durationLabel.TextSize = 10
    durationLabel.Text = string.format("%.1fs", clip.Duration or 0)
    durationLabel.Parent = clipHeader

    local actionsFrame = Instance.new("Frame")
    actionsFrame.Name = "Actions"
    actionsFrame.Size = UDim2.new(1, 0, 0, 30)
    actionsFrame.Position = UDim2.new(0, 0, 0, 26)
    actionsFrame.BackgroundTransparency = 1
    actionsFrame.Parent = clipFrame

    local playButton = Instance.new("TextButton")
    playButton.Name = "PlayButton"
    playButton.Size = UDim2.new(0.23, 0, 0, 22)
    playButton.Position = UDim2.new(0, 4, 0, 0)
    playButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
    playButton.Font = Enum.Font.GothamBold
    playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playButton.TextSize = 10
    playButton.Text = "PLAY"
    playButton.Parent = actionsFrame

    local playCorner = Instance.new("UICorner")
    playCorner.CornerRadius = UDim.new(0, 4)
    playCorner.Parent = playButton

    local loopButton = Instance.new("TextButton")
    loopButton.Name = "LoopButton"
    loopButton.Size = UDim2.new(0.23, 0, 0, 22)
    loopButton.Position = UDim2.new(0.25, 4, 0, 0)
    loopButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    loopButton.Font = Enum.Font.GothamBold
    loopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    loopButton.TextSize = 10
    loopButton.Text = "LOOP"
    loopButton.Parent = actionsFrame

    local loopCorner = Instance.new("UICorner")
    loopCorner.CornerRadius = UDim.new(0, 4)
    loopCorner.Parent = loopButton

    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = "KeybindButton"
    keybindButton.Size = UDim2.new(0.23, 0, 0, 22)
    keybindButton.Position = UDim2.new(0.5, 4, 0, 0)
    keybindButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    keybindButton.Font = Enum.Font.GothamBold
    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindButton.TextSize = 10
    keybindButton.Text = "KEYBIND"
    keybindButton.Parent = actionsFrame

    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 4)
    keybindCorner.Parent = keybindButton

    local deleteButton = Instance.new("TextButton")
    deleteButton.Name = "DeleteButton"
    deleteButton.Size = UDim2.new(0.23, 0, 0, 22)
    deleteButton.Position = UDim2.new(0.75, 4, 0, 0)
    deleteButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    deleteButton.Font = Enum.Font.GothamBold
    deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteButton.TextSize = 10
    deleteButton.Text = "DELETE"
    deleteButton.Parent = actionsFrame

    local deleteCorner = Instance.new("UICorner")
    deleteCorner.CornerRadius = UDim.new(0, 4)
    deleteCorner.Parent = deleteButton

    local stopFunc = nil

    playButton.MouseButton1Click:Connect(function()
        if stopFunc then
            stopFunc()
            stopFunc = nil
            playButton.Text = "PLAY"
            playButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
            return
        end
        
        local isLooping = LoopingClips[clip.Id] or false
        
        stopFunc = PlayClip(clip, isLooping)
        CurrentStopFunc = stopFunc
        playButton.Text = "STOP"
        playButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    end)

    loopButton.MouseButton1Click:Connect(function()
        LoopingClips[clip.Id] = not LoopingClips[clip.Id]
        
        if LoopingClips[clip.Id] then
            loopButton.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
        else
            loopButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)

    keybindButton.MouseButton1Click:Connect(function()
        if KeyBinds[clip.Id] then
            KeyBinds[clip.Id] = nil
            keybindButton.Text = "KEYBIND"
            keybindButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            return
        end
        
        keybindButton.Text = "PRESS KEY"
        keybindButton.BackgroundColor3 = Color3.fromRGB(180, 180, 60)
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                KeyBinds[clip.Id] = input.KeyCode
                keybindButton.Text = input.KeyCode.Name
                keybindButton.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
                
                SaveKeybinds()
                
                connection:Disconnect()
            end
        end)
    end)

    deleteButton.MouseButton1Click:Connect(function()
        if CurrentlyPlayingClip == clip.Id and CurrentStopFunc then
            CurrentStopFunc()
            CurrentStopFunc = nil
            CurrentlyPlayingClip = nil
        end
        
        for i, savedClip in ipairs(SavedClips) do
            if savedClip.Id == clip.Id then
                table.remove(SavedClips, i)
                break
            end
        end
        
        KeyBinds[clip.Id] = nil
        LoopingClips[clip.Id] = nil
        
        clipFrame:Destroy()
        
        UpdateClipsCanvasSize(guiElements)
        
        SaveClipsToFile()
        SaveKeybinds()
    end)

    nameBox.FocusLost:Connect(function(enterPressed)
        for i, savedClip in ipairs(SavedClips) do
            if savedClip.Id == clip.Id then
                SavedClips[i].Name = nameBox.Text
                break
            end
        end
        
        SaveClipsToFile()
    end)

    if LoopingClips[clip.Id] then
        loopButton.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
    end

    if KeyBinds[clip.Id] then
        keybindButton.Text = KeyBinds[clip.Id].Name
        keybindButton.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
    end

    clipFrame.Parent = guiElements.ClipsScrollFrame
    return clipFrame
end

-- Update the canvas size of the clips scrolling frame
function UpdateClipsCanvasSize(guiElements)
    local scrollFrame = guiElements.ClipsScrollFrame
    local contentSize = scrollFrame.UIListLayout.AbsoluteContentSize.Y
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize + 8)
end

-- Save clips to file
function SaveClipsToFile()
    local success, errorMsg = pcall(function()
        local saveData = {
            Clips = SavedClips,
            Version = 1
        }

        local jsonData = HttpService:JSONEncode(saveData)
        
        if not isfolder(ClipsFolder) then
            makefolder(ClipsFolder)
        end
        
        writefile(ClipsFolder .. "/" .. SaveFileName, jsonData)
    end)

    if not success then
        warn("Failed to save clips: " .. errorMsg)
    end
end

-- Save keybinds to file
function SaveKeybinds()
    local success, errorMsg = pcall(function()
        local keybindData = {}
        for id, keyCode in pairs(KeyBinds) do
            keybindData[id] = keyCode.Name
        end

        local saveData = {
            KeyBinds = keybindData,
            LoopingClips = LoopingClips,
            Version = 1
        }
        
        local jsonData = HttpService:JSONEncode(saveData)
        
        if not isfolder(ClipsFolder) then
            makefolder(ClipsFolder)
        end
        
        writefile(ClipsFolder .. "/Keybinds_" .. LocalPlayer.UserId .. ".json", jsonData)
    end)

    if not success then
        warn("Failed to save keybinds: " .. errorMsg)
    end
end

-- Load clips from file
local function LoadClipsFromFile()
    local success, result = pcall(function()
        if not isfolder(ClipsFolder) then
            makefolder(ClipsFolder)
            return false
        end

        if not isfile(ClipsFolder .. "/" .. SaveFileName) then
            return false
        end
        
        local jsonData = readfile(ClipsFolder .. "/" .. SaveFileName)
        local saveData = HttpService:JSONDecode(jsonData)
        
        if saveData and saveData.Clips then
            SavedClips = saveData.Clips
            return true
        end
        
        return false
    end)

    if not success or result == false then
        SavedClips = {}
    end
end

-- Load keybinds from file
local function LoadKeybinds()
    local success, result = pcall(function()
        if not isfolder(ClipsFolder) then
            makefolder(ClipsFolder)
            return false
        end

        local keybindFileName = ClipsFolder .. "/Keybinds_" .. LocalPlayer.UserId .. ".json"
        if not isfile(keybindFileName) then
            return false
        end
        
        local jsonData = readfile(keybindFileName)
        local saveData = HttpService:JSONDecode(jsonData)
        
        if saveData then
            for id, keyName in pairs(saveData.KeyBinds) do
                KeyBinds[id] = Enum.KeyCode[keyName]
            end
            
            LoopingClips = saveData.LoopingClips
            
            return true
        end
        
        return false
    end)

    if not success or result == false then
        KeyBinds = {}
        LoopingClips = {}
    end
end

-- Initialize the UI and functionality
local function Initialize()
    local guiElements = CreateGUI()

    MakeDraggable(guiElements.MainFrame)

    -- Minimize button functionality (minimized height: 30 -> 22)
    guiElements.MinimizeButton.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        if IsMinimized then
            guiElements.ContentFrame.Visible = false
            guiElements.MainFrame.Size = UDim2.new(0, 300, 0, 22)
            guiElements.MinimizeButton.Text = "+"
        else
            guiElements.ContentFrame.Visible = true
            guiElements.MainFrame.Size = UDim2.new(0, 300, 0, 375)
            guiElements.MinimizeButton.Text = "-"
        end
    end)

    guiElements.CloseButton.MouseButton1Click:Connect(function()
        GUI:Destroy()
    end)

    guiElements.SearchBox.Changed:Connect(function(property)
        if property == "Text" then
            local results = FindPlayer(guiElements.SearchBox.Text)
            UpdateDropdown(guiElements, results)
        end
    end)

    guiElements.SearchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local results = FindPlayer(guiElements.SearchBox.Text)
            if #results == 1 then
                SelectedPlayer = results[1]
                guiElements.SearchBox.Text = results[1].DisplayName .. " (@" .. results[1].Name .. ")"
                guiElements.DropdownFrame.Visible = false
                guiElements.StatusLabel.Text = "Ready to record " .. results[1].DisplayName .. "'s animations"
            end
        end
    end)

    guiElements.RecordButton.MouseButton1Click:Connect(function()
        if RecordingClip then
            RecordingClip = false
            guiElements.RecordButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            guiElements.RecordButton.Text = "START RECORDING"
            
            local clipSaved = StopTrackingAnimations()
            
            if clipSaved then
                guiElements.StatusLabel.Text = "Clip saved"
                
                local newClip = SavedClips[#SavedClips]
                CreateClipEntry(guiElements, newClip, #SavedClips)
                
                UpdateClipsCanvasSize(guiElements)
            else
                guiElements.StatusLabel.Text = "Recording canceled (no animations recorded)"
            end
        else
            if not SelectedPlayer then
                guiElements.StatusLabel.Text = "Please select a player first"
                return
            end
            
            RecordingClip = true
            guiElements.RecordButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            guiElements.RecordButton.Text = "STOP RECORDING"
            guiElements.StatusLabel.Text = "Recording " .. SelectedPlayer.DisplayName .. "'s animations..."
            
            StartTrackingAnimations(SelectedPlayer)
        end
    end)

    LoadClipsFromFile()
    LoadKeybinds()

    for i, clip in ipairs(SavedClips) do
        CreateClipEntry(guiElements, clip, i)
    end

    UpdateClipsCanvasSize(guiElements)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            for clipId, keyCode in pairs(KeyBinds) do
                if keyCode == input.KeyCode then
                    local clipToPlay = nil
                    for _, clip in ipairs(SavedClips) do
                        if clip.Id == clipId then
                            clipToPlay = clip
                            break
                        end
                    end
                    
                    if clipToPlay then
                        local isLooping = LoopingClips[clipId] or false
                        
                        if CurrentlyPlayingClip == clipId and CurrentStopFunc then
                            CurrentStopFunc()
                            CurrentStopFunc = nil
                            CurrentlyPlayingClip = nil
                            
                            for _, child in pairs(GUI.MainFrame.ContentFrame.ClipsSection.ClipsScrollFrame:GetChildren()) do
                                if child:IsA("Frame") and child.Name == "Clip_" .. clipId then
                                    local playButton = child.Actions.PlayButton
                                    playButton.Text = "PLAY"
                                    playButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
                                    break
                                end
                            end
                        else
                            if CurrentStopFunc then
                                CurrentStopFunc()
                                CurrentStopFunc = nil
                                
                                if CurrentlyPlayingClip then
                                    for _, child in pairs(GUI.MainFrame.ContentFrame.ClipsSection.ClipsScrollFrame:GetChildren()) do
                                        if child:IsA("Frame") and child.Name == "Clip_" .. CurrentlyPlayingClip then
                                            local playButton = child.Actions.PlayButton
                                            playButton.Text = "PLAY"
                                            playButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
                                            break
                                        end
                                    end
                                end
                            end
                            
                            CurrentStopFunc = PlayClip(clipToPlay, isLooping)
                            
                            for _, child in pairs(GUI.MainFrame.ContentFrame.ClipsSection.ClipsScrollFrame:GetChildren()) do
                                if child:IsA("Frame") and child.Name == "Clip_" .. clipId then
                                    local playButton = child.Actions.PlayButton
                                    playButton.Text = "STOP"
                                    playButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    guiElements.StatusLabel.Text = "Ready to record"
end

-- Run the script
Initialize()

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    Animator = Humanoid:WaitForChild("Animator")
end)
