-- Services & vars
-- Services & vars
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer
local RealAnimate = LocalPlayer.Character.Animate

-- Body parts to mirror
local bodyParts = {
"Head","UpperTorso","LowerTorso",
"LeftUpperArm","LeftLowerArm","LeftHand",
"RightUpperArm","RightLowerArm","RightHand",
"LeftUpperLeg","LeftLowerLeg","LeftFoot",
"RightUpperLeg","RightLowerLeg","RightFoot"
}

-- State
local ghostEnabled      = false
local originalCharacter = nil
local ghostClone        = nil
local originalCFrame    = nil
local originalAnimate   = nil
local updateConn        = nil
local preservedGuis     = {}
local selectedPlayer    = nil
local offsetDistance    = 2 -- studs
local minimized         = false

-- GUI preservation helpers
local function preserveGuis()
local pg = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
if not pg then return end
for _, gui in ipairs(pg:GetChildren()) do
if gui:IsA("ScreenGui") and gui.Name ~= "ReanimationGui" and gui.ResetOnSpawn then
table.insert(preservedGuis, gui)
gui.ResetOnSpawn = false
end
end
end

local function restoreGuis()
for _, gui in ipairs(preservedGuis) do
if gui and gui.Parent then gui.ResetOnSpawn = true end
end
table.clear(preservedGuis)
end

-- Core sync logic: mirrors all parts with offset
local function updateRagdoll()
if not (ghostEnabled and originalCharacter and ghostClone and selectedPlayer and selectedPlayer.Character) then
if updateConn then updateConn:Disconnect() end; updateConn = nil
return
end

-- Get target and calculate offset
local tgt = selectedPlayer.Character
local hrp = tgt:FindFirstChild("HumanoidRootPart")
local rightOffset = hrp and (hrp.CFrame.RightVector * offsetDistance) or Vector3.new()

-- Make sure HumanoidRootPart is synced first for strong attachment
local originalHRP = originalCharacter:FindFirstChild("HumanoidRootPart")
if originalHRP and hrp then
    originalHRP.CFrame = hrp.CFrame + rightOffset
    originalHRP.AssemblyLinearVelocity = Vector3.zero
    originalHRP.AssemblyAngularVelocity = Vector3.zero
end

-- Update each body part with strong attachment
for _, name in ipairs(bodyParts) do
    local partO = originalCharacter:FindFirstChild(name)
    local partT = tgt:FindFirstChild(name) or hrp
    if partO and partT and partO:IsA("BasePart") and partT:IsA("BasePart") then
        partO.CFrame = partT.CFrame + rightOffset
        partO.AssemblyLinearVelocity = Vector3.zero
        partO.AssemblyAngularVelocity = Vector3.zero
    end
end

-- Instantly snap camera to player with no interpolation (IMPROVED)
if Workspace.CurrentCamera then
    local hum = originalCharacter:FindFirstChildWhichIsA("Humanoid")
    if hum then

    end
end
end

-- Enable/disable reanimation
local function setGhost(state)
ghostEnabled = state
if state then
local ch = LocalPlayer.Character
if not (ch and ch:FindFirstChildWhichIsA("Humanoid") and ch:FindFirstChild("HumanoidRootPart"))
or originalCharacter then return end

-- Store original
    originalCharacter, originalCFrame = ch, ch.HumanoidRootPart.CFrame

    -- Clone to ghost
    ch.Archivable = true
    ghostClone = ch:Clone()
    ch.Archivable = false
    ghostClone.Name = ch.Name .. "_ghost"

    -- Make ghost invisible & physics-only
    local gHum = ghostClone:FindFirstChildWhichIsA("Humanoid")
    if gHum then gHum:ChangeState(Enum.HumanoidStateType.Physics) end
    for _, d in ipairs(ghostClone:GetDescendants()) do
        if d:IsA("BasePart") then d.Transparency, d.Anchored = 1, false
        elseif d:IsA("Decal") then d.Transparency = 1
        elseif d:IsA("Accessory") then
            local h = d:FindFirstChild("Handle")
            if h then h.Transparency = 1 end
        end
    end

    -- Preserve animate script (instead of moving it)
    originalAnimate = ch:FindFirstChild("Animate")
    if originalAnimate then
        originalAnimate.Disabled = true
        originalAnimate:Clone().Parent = ghostClone
    end

    preserveGuis()
    ghostClone.Parent = Workspace
    LocalPlayer.Character = ghostClone
    
    -- Ensure camera instantly snaps to original character

    
    restoreGuis()

    if ReplicatedStorage:FindFirstChild("RagdollEvent") then
        ReplicatedStorage.RagdollEvent:FireServer()
    end

    updateConn = RunService.Heartbeat:Connect(updateRagdoll)
else
    if updateConn then updateConn:Disconnect() end; updateConn = nil
    if ReplicatedStorage:FindFirstChild("UnragdollEvent") then
        for i = 1, 3 do
            ReplicatedStorage.UnragdollEvent:FireServer()
            task.wait(0.1)
        end
    end
    
    -- Don't teleport back to original position, stay at final position
    local endCF = nil
    if ghostClone and ghostClone:FindFirstChild("HumanoidRootPart") then
        endCF = ghostClone.HumanoidRootPart.CFrame
    end
    
    -- Properly restore animations
    if originalAnimate then
        -- First re-enable the original animate script
        originalAnimate.Disabled = false
        
        -- Force animation reset by temporarily disabling and re-enabling
        task.delay(0.1, function()
            if originalAnimate and originalAnimate.Parent then
                -- Briefly disable and re-enable to reset animation state
                originalAnimate.Disabled = true
                task.wait(0.05)
                originalAnimate.Disabled = false
                
                -- Force animation playback
                local hum = originalCharacter and originalCharacter:FindFirstChildWhichIsA("Humanoid")
                if hum then
                    -- Reset animation state and trigger idle animation
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                    task.wait(0.05)
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    task.wait(0.05)
                    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                end
            end
        end)
    end
    
    if ghostClone then
        ghostClone:Destroy()
        ghostClone = nil
    end
    
    if originalCharacter then
        local root = originalCharacter:FindFirstChild("HumanoidRootPart")
        if root and endCF then
            
            root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        end
        
        local hum = originalCharacter:FindFirstChildWhichIsA("Humanoid")
        preserveGuis()
        LocalPlayer.Character = originalCharacter
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        restoreGuis()
    end
    
    originalCharacter, originalAnimate = nil, nil
end
end

-- Toggle minimize function
local function toggleMinimize(frame, content)
    minimized = not minimized
    
    -- Create tween info
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Target size based on state
    local targetSize = minimized 
        and UDim2.new(0, 280, 0, 36)  -- Taskbar only
        or UDim2.new(0, 280, 0, 460)  -- Full size
        
    -- Create and play tween
    local sizeTween = TweenService:Create(frame, tweenInfo, {Size = targetSize})
    sizeTween:Play()
    
    -- Update content visibility after tween completes
    sizeTween.Completed:Connect(function()
        content.Visible = not minimized
    end)
    
    -- If expanding, show content immediately
    if not minimized then
        content.Visible = true
    end
end

-- Build GUI
local function makeGui()
local pg = LocalPlayer:WaitForChild("PlayerGui")
-- Remove existing GUI if present
local existingGui = pg:FindFirstChild("ReanimationGui")
if existingGui then existingGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ReanimationGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 460)
frame.Position = UDim2.new(0, 20, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Name = "MainFrame"
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Taskbar/top bar
local taskbar = Instance.new("Frame")
taskbar.Size = UDim2.new(1, 0, 0, 36)
taskbar.Position = UDim2.new(0, 0, 0, 0)
taskbar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
taskbar.BorderSizePixel = 0
taskbar.Name = "Taskbar"
taskbar.Parent = frame

local taskbarCorner = Instance.new("UICorner")
taskbarCorner.CornerRadius = UDim.new(0, 10)
taskbarCorner.Parent = taskbar

-- Fix corners of taskbar
local taskbarFixBottom = Instance.new("Frame")
taskbarFixBottom.Size = UDim2.new(1, 0, 0, 10)
taskbarFixBottom.Position = UDim2.new(0, 0, 1, -10)
taskbarFixBottom.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
taskbarFixBottom.BorderSizePixel = 0
taskbarFixBottom.Parent = taskbar

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)  -- Reduced width to make room for minimize button
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Anim Copier"
title.TextColor3 = Color3.fromRGB(240,240,240)
title.Font = Enum.Font.GothamSemibold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = taskbar

-- Minimize button (NEW)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.Text = "—"
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
minBtn.BorderSizePixel = 0
minBtn.Name = "MinimizeButton"
minBtn.Parent = taskbar

local minBtnCorner = Instance.new("UICorner")
minBtnCorner.CornerRadius = UDim.new(0, 6)
minBtnCorner.Parent = minBtn

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(211, 47, 47)
closeBtn.Text = "×"
closeBtn.TextSize = 24
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = taskbar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

-- Content container
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -36)
content.Position = UDim2.new(0, 0, 0, 36)
content.BackgroundTransparency = 1
content.Name = "Content"
content.Parent = frame

-- Offset slider label
local lblOffset = Instance.new("TextLabel")
lblOffset.Size = UDim2.new(1, -20, 0, 20)
lblOffset.Position = UDim2.new(0, 10, 0, 10)
lblOffset.BackgroundTransparency = 1
lblOffset.Text = string.format("Offset: %.1f studs", offsetDistance)
lblOffset.TextColor3 = Color3.fromRGB(200,200,200)
lblOffset.Font = Enum.Font.Gotham
lblOffset.TextSize = 14
lblOffset.Parent = content

-- Slider
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0, 12)
sliderBg.Position = UDim2.new(0, 10, 0, 36)
sliderBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = content

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 6)
sliderCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(offsetDistance/10, 0, 1, 0)
sliderFill.BorderSizePixel = 0
sliderFill.BackgroundColor3 = Color3.fromRGB(100,180,240)
sliderFill.Parent = sliderBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 6)
fillCorner.Parent = sliderFill

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(offsetDistance/10, -10, 0.5, -10)
knob.BackgroundColor3 = Color3.fromRGB(180,180,180)
knob.BorderSizePixel = 0
knob.Parent = sliderBg

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(0, 10)
knobCorner.Parent = knob

-- Improved slider dragging logic to prevent GUI dragging while using slider
local draggingKnob = false

knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingKnob = true
        -- Prevent event propagation
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingKnob = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingKnob then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local x = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
        local pct = x / sliderBg.AbsoluteSize.X
        offsetDistance = math.floor((pct * 10)*10+0.5)/10
        lblOffset.Text = string.format("Offset: %.1f studs", offsetDistance)
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -10, 0.5, -10)
    end
end)

-- Player list container
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "PlayerList"
scroll.Size = UDim2.new(1, -20, 0, 250)
scroll.Position = UDim2.new(0, 10, 0, 66)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
scroll.ElasticBehavior = Enum.ElasticBehavior.Always
scroll.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- Make sure CanvasSize updates
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Populate players with thumbnails & names
local function rebuild()
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 70)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.LayoutOrder = pl.UserId
            btn.AutoButtonColor = true
            btn.Parent = scroll

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 50, 0, 50)
            img.Position = UDim2.new(0, 10, 0.5, -25)
            img.BackgroundTransparency = 1
            img.Parent = btn
            
            spawn(function()
                pcall(function()
                    local thumb = Players:GetUserThumbnailAsync(pl.UserId,
                        Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    img.Image = thumb
                end)
            end)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Text = pl.DisplayName or pl.Name
            nameLbl.Size = UDim2.new(0, 180, 0, 28)
            nameLbl.Position = UDim2.new(0, 70, 0, 12)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = Color3.fromRGB(240,240,240)
            nameLbl.Font = Enum.Font.GothamSemibold
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = btn

            local userLbl = Instance.new("TextLabel")
            userLbl.Text = "@"..pl.Name
            userLbl.Size = UDim2.new(0, 180, 0, 20)
            userLbl.Position = UDim2.new(0, 70, 0, 36)
            userLbl.BackgroundTransparency = 1
            userLbl.TextColor3 = Color3.fromRGB(200,200,200)
            userLbl.Font = Enum.Font.Gotham
            userLbl.TextSize = 12
            userLbl.TextXAlignment = Enum.TextXAlignment.Left
            userLbl.Parent = btn

            btn.MouseButton1Click:Connect(function()
                selectedPlayer = pl
                for _, c in ipairs(scroll:GetChildren()) do
                    if c:IsA("TextButton") then
                        c.BackgroundColor3 = Color3.fromRGB(40,40,40)

                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
                
                
                
                -- If already enabled, instantly update camera to the new target
                if ghostEnabled and originalCharacter then
                    local hum = originalCharacter:FindFirstChildWhichIsA("Humanoid")
                    if hum and Workspace.CurrentCamera then
                    end
                end
            end)
        end
    end
    
    -- Update canvas size
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

-- Copy animation button (added new)
local btnCopy = Instance.new("TextButton")
btnCopy.Size = UDim2.new(1, -20, 0, 40)
btnCopy.Position = UDim2.new(0, 10, 1, -100)
btnCopy.Text = "Copy Target Animation"
btnCopy.Font = Enum.Font.GothamSemibold
btnCopy.TextSize = 16
btnCopy.TextColor3 = Color3.new(1,1,1)
btnCopy.BackgroundColor3 = Color3.fromRGB(33,150,243)
btnCopy.BorderSizePixel = 0
btnCopy.Visible = false  -- Initially hidden until player is selected
btnCopy.Parent = content

local btnCopyCorner = Instance.new("UICorner")
btnCopyCorner.CornerRadius = UDim.new(0, 8)
btnCopyCorner.Parent = btnCopy

btnCopy.MouseButton1Click:Connect(function()
    if not selectedPlayer then return end
    -- Logic for copying target animation would go here
    -- This is just a placeholder - implement real copy function based on game's systems
    print("Copying animation from: " .. selectedPlayer.Name)
end)

-- Toggle button
local btnToggle = Instance.new("TextButton")
btnToggle.Size = UDim2.new(1, -20, 0, 40)
btnToggle.Position = UDim2.new(0, 10, 1, -50)
btnToggle.Text = "Start Animation Copy"
btnToggle.Font = Enum.Font.GothamSemibold
btnToggle.TextSize = 16
btnToggle.TextColor3 = Color3.new(1,1,1)
btnToggle.BackgroundColor3 = Color3.fromRGB(100,100,100)
btnToggle.Transparency = 0.4
btnToggle.Active = false
btnToggle.AutoButtonColor = false
btnToggle.Parent = content

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = btnToggle

btnToggle.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        btnToggle.Text = "Select a player first."
        wait(1)
        btnToggle.Text = "Start Animation Copy"
        return
     end

    setGhost(not ghostEnabled)
    btnToggle.Text = ghostEnabled and "Stop Animation Copy" or "Start Animation Copy"
    
    if not ghostEnabled then
        RealAnimate.Disabled = true
        RealAnimate.Enabled = false
        wait(0.1)
        RealAnimate.Disabled = false
        RealAnimate.Enabled = true
        wait(0.1)
        RealAnimate.Disabled = true
        RealAnimate.Enabled = false
        wait(0.1)
        RealAnimate.Disabled = false
        RealAnimate.Enabled = true
    end

    btnToggle.BackgroundColor3 = ghostEnabled
        and Color3.fromRGB(211,47,47)
        or Color3.fromRGB(76,175,80)
        if ghostEnabled then
            wait(2)
            game.Workspace.CurrentCamera.CameraSubject = selectedPlayer.Character.UpperTorso
        else
            game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
        end
end)

-- Frame dragging (avoid dragging when using slider)
local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if draggingKnob then return end  -- Skip dragging when using slider
    
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
        input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if draggingKnob then return end  -- Skip dragging when using slider
    
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingKnob then return end  -- Skip dragging when using slider
    
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Set up minimize button behavior (NEW)
minBtn.MouseButton1Click:Connect(function()
    toggleMinimize(frame, content)
end)

closeBtn.MouseButton1Click:Connect(function()
    setGhost(false)
    gui:Destroy()
end)

-- Initialize player list
Players.PlayerAdded:Connect(rebuild)
Players.PlayerRemoving:Connect(function(pl)
    if pl == selectedPlayer then 
        selectedPlayer = nil
        btnToggle.Text = "Start Animation Copy"
        btnToggle.BackgroundColor3 = Color3.fromRGB(100,100,100)
        btnToggle.Transparency = 0.4
        btnToggle.Active = false
        btnToggle.AutoButtonColor = false
        btnCopy.Visible = false
    end
    rebuild()
end)

-- Run the initial rebuild to populate players
task.spawn(rebuild)

return gui
end

local gui = makeGui()

-- Cleanup on destroy
script.Destroying:Connect(function()
if ghostEnabled then setGhost(false) end
if gui then gui:Destroy() end
if updateConn then updateConn:Disconnect() end
end)
