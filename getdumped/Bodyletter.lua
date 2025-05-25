-- BodyLetter; everything from German to Englisch. Also make the gui smaller and rounded cornered

-- SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Configuration: All body parts are used automatically
local bodyParts = { "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart" }

-- Global Variables and State
local ghostEnabled = false
local originalCharacter
local ghostClone
local originalCFrame
local originalAnimateScript
local updateConnection
local renderStepConnection
local previousPositions = {}
local lastUpdateTime = 0

-- Scaling factor for the letter shape (adjustable via GUI slider)
local letterSize = 5 -- Default value
-- The currently selected letter (as a string, e.g., "A", "B", etc.)
local selectedLetter = "A"

-- Variables for text animation
local animationText = ""
local isAnimationPlaying = false
local animationSpeed = 2.0 -- Seconds per letter
local animationIndex = 1
local animationConnection

-- LETTER SHAPES (Revised for better representation)
local letterShapes = {
    ["A"] = {
        Vector2.new(-0.5, -0.5), Vector2.new(0, 0.5), Vector2.new(0.5, -0.5), -- Base shape
        Vector2.new(0.25, -0.1), Vector2.new(-0.25, -0.1) -- Middle bar
    },
    ["B"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(-0.5, -0.5), -- Left stroke
        Vector2.new(-0.5, -0.5), Vector2.new(0.1, -0.5), -- Bottom horizontal line
        Vector2.new(0.1, -0.5), Vector2.new(0.4, -0.4), Vector2.new(0.5, -0.25), Vector2.new(0.4, -0.1), Vector2.new(0.1, 0), -- Lower bow
        Vector2.new(-0.5, 0), Vector2.new(0.1, 0), -- Middle line
        Vector2.new(0.1, 0), Vector2.new(0.4, 0.1), Vector2.new(0.5, 0.25), Vector2.new(0.4, 0.4), Vector2.new(0.1, 0.5), -- Upper bow
        Vector2.new(0.1, 0.5), Vector2.new(-0.5, 0.5) -- Top horizontal line
    },
    ["C"] = {
        Vector2.new(0.5, 0.3), Vector2.new(0.3, 0.5), Vector2.new(-0.3, 0.5), -- Top curve
        Vector2.new(-0.5, 0.3), Vector2.new(-0.5, -0.3), -- Left side
        Vector2.new(-0.3, -0.5), Vector2.new(0.3, -0.5), Vector2.new(0.5, -0.3) -- Bottom curve
    },
    ["D"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(-0.5, -0.5), -- Left stroke
        Vector2.new(0.2, -0.5), Vector2.new(0.5, -0.2), -- Bottom curve
        Vector2.new(0.5, 0.2), Vector2.new(0.2, 0.5), -- Top curve
        Vector2.new(-0.5, 0.5) -- Back to start
    },
    ["E"] = {
        Vector2.new(0.5, 0.5), Vector2.new(-0.5, 0.5), -- Top line
        Vector2.new(-0.5, 0), Vector2.new(0.3, 0), -- Middle line
        Vector2.new(-0.5, 0), Vector2.new(-0.5, -0.5), -- Left line bottom
        Vector2.new(0.5, -0.5) -- Bottom line
    },
    ["F"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(0.5, 0.5), -- Top line
        Vector2.new(-0.5, 0.5), Vector2.new(-0.5, -0.5), -- Left line continuous
        Vector2.new(-0.5, 0.1), Vector2.new(0.3, 0.1) -- Middle line (slightly shifted up)
    },
    ["G"] = {
        Vector2.new(0.5, 0.3), Vector2.new(0.3, 0.5), Vector2.new(-0.2, 0.5), Vector2.new(-0.4, 0.4), -- Top curve
        Vector2.new(-0.5, 0.2), Vector2.new(-0.5, -0.2), Vector2.new(-0.4, -0.4), Vector2.new(-0.2, -0.5), -- Left/bottom curve
        Vector2.new(0.2, -0.5), Vector2.new(0.4, -0.4), Vector2.new(0.5, -0.2), -- Bottom right curve
        Vector2.new(0.5, 0), Vector2.new(0.5, -0.1), -- Right line
        Vector2.new(0.5, 0), Vector2.new(0.1, 0) -- Horizontal stroke left
    },
    ["H"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(-0.5, -0.5), -- Left line
        Vector2.new(-0.5, 0), Vector2.new(-0.3, 0), -- Left part of middle line
        Vector2.new(-0.3, 0), Vector2.new(0.3, 0), -- Middle part of middle line
        Vector2.new(0.3, 0), Vector2.new(0.5, 0), -- Right part of middle line
        Vector2.new(0.5, 0.5), Vector2.new(0.5, -0.5) -- Right line
    },
    ["I"] = {
        Vector2.new(-0.2, 0.5), Vector2.new(0.2, 0.5), -- Top line
        Vector2.new(0, 0.5), Vector2.new(0, -0.5), -- Middle line
        Vector2.new(-0.2, -0.5), Vector2.new(0.2, -0.5) -- Bottom line
    },
    ["J"] = {
        Vector2.new(-0.2, 0.5), Vector2.new(0.2, 0.5), -- Top line
        Vector2.new(0.2, 0.5), Vector2.new(0.2, -0.3), -- Right line
        Vector2.new(0.2, -0.3), Vector2.new(0, -0.5), Vector2.new(-0.2, -0.3), -- Bottom curve
        Vector2.new(-0.2, -0.3), Vector2.new(-0.2, -0.1) -- Left hook
    },
    ["K"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(-0.5, -0.5), -- Left stroke
        Vector2.new(-0.5, 0.1), Vector2.new(-0.3, 0.1), -- Middle line start
        Vector2.new(-0.3, 0.1), Vector2.new(0, 0.3), -- Middle part up
        Vector2.new(0, 0.3), Vector2.new(0.5, 0.5), -- Top stroke end
        Vector2.new(-0.3, 0.1), Vector2.new(0, -0.1), -- Middle part down
        Vector2.new(0, -0.1), Vector2.new(0.5, -0.5) -- Bottom stroke end
    },
    ["L"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(-0.5, -0.5), -- Left stroke
        Vector2.new(-0.5, -0.5), Vector2.new(0.5, -0.5) -- Bottom stroke
    },
    ["M"] = {
        Vector2.new(-0.5, -0.5), Vector2.new(-0.5, 0.5), -- Left stroke
        Vector2.new(-0.5, 0.5), Vector2.new(0, 0), -- Left diagonal
        Vector2.new(0, 0), Vector2.new(0.5, 0.5), -- Right diagonal
        Vector2.new(0.5, 0.5), Vector2.new(0.5, -0.5) -- Right stroke
    },
    ["N"] = {
        Vector2.new(-0.5, -0.5), Vector2.new(-0.5, 0.5), -- Left stroke
        Vector2.new(-0.5, 0.5), Vector2.new(0.5, -0.5), -- Diagonal
        Vector2.new(0.5, -0.5), Vector2.new(0.5, 0.5) -- Right stroke
    },
    ["O"] = {
        Vector2.new(0, 0.5), Vector2.new(-0.3, 0.4), Vector2.new(-0.5, 0.2), -- Top left curve
        Vector2.new(-0.5, -0.2), Vector2.new(-0.3, -0.4), Vector2.new(0, -0.5), -- Bottom left curve
        Vector2.new(0.3, -0.4), Vector2.new(0.5, -0.2), -- Bottom right curve
        Vector2.new(0.5, 0.2), Vector2.new(0.3, 0.4), Vector2.new(0, 0.5) -- Top right curve
    },
    ["P"] = {
        Vector2.new(-0.5, -0.5), Vector2.new(-0.5, 0.5), -- Left stroke
        Vector2.new(-0.5, 0.5), Vector2.new(0.2, 0.5), -- Top line
        Vector2.new(0.2, 0.5), Vector2.new(0.4, 0.3), Vector2.new(0.4, 0.1), Vector2.new(0.2, 0), -- Bow
        Vector2.new(0.2, 0), Vector2.new(-0.5, 0) -- Back to stroke
    },
    ["Q"] = {
        Vector2.new(0, 0.5), Vector2.new(-0.3, 0.4), Vector2.new(-0.5, 0.2), -- Top left curve
        Vector2.new(-0.5, -0.2), Vector2.new(-0.3, -0.4), Vector2.new(0, -0.5), -- Bottom left curve
        Vector2.new(0.3, -0.4), Vector2.new(0.5, -0.2), -- Bottom right curve
        Vector2.new(0.5, 0.2), Vector2.new(0.3, 0.4), Vector2.new(0, 0.5), -- Top right curve
        Vector2.new(0.1, -0.3), Vector2.new(0.5, -0.6) -- Tail
    },
    ["R"] = {
        Vector2.new(-0.5, -0.5), Vector2.new(-0.5, 0.5), -- Left stroke
        Vector2.new(-0.5, 0.5), Vector2.new(0.2, 0.5), -- Top line
        Vector2.new(0.2, 0.5), Vector2.new(0.4, 0.3), Vector2.new(0.4, 0.1), Vector2.new(0.2, 0), -- Bow
        Vector2.new(0.2, 0), Vector2.new(-0.5, 0), -- Back to stroke
        Vector2.new(0.2, 0), Vector2.new(0.5, -0.5) -- Right leg
    },
    ["S"] = {
        Vector2.new(0.4, 0.5), Vector2.new(0, 0.5), Vector2.new(-0.4, 0.3), -- Top curve
        Vector2.new(-0.4, 0.3), Vector2.new(-0.2, 0), -- Top middle
        Vector2.new(-0.2, 0), Vector2.new(0.2, 0), -- Middle part
        Vector2.new(0.2, 0), Vector2.new(0.4, -0.3), -- Bottom middle
        Vector2.new(0.4, -0.3), Vector2.new(0, -0.5), Vector2.new(-0.4, -0.5) -- Bottom curve
    },
    ["T"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(0.5, 0.5), -- Top line
        Vector2.new(0, 0.5), Vector2.new(0, -0.5) -- Middle line
    },
    ["U"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(-0.5, -0.3), -- Left line
        Vector2.new(-0.5, -0.3), Vector2.new(-0.3, -0.5), Vector2.new(0.3, -0.5), -- Bottom curve
        Vector2.new(0.3, -0.5), Vector2.new(0.5, -0.3), Vector2.new(0.5, 0.5) -- Right line
    },
    ["V"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(0, -0.5), Vector2.new(0.5, 0.5)
    },
    ["W"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(-0.3, -0.5), -- Left outer line
        Vector2.new(-0.3, -0.5), Vector2.new(0, 0), -- Left inner line
        Vector2.new(0, 0), Vector2.new(0.3, -0.5), -- Right inner line
        Vector2.new(0.3, -0.5), Vector2.new(0.5, 0.5) -- Right outer line
    },
    ["X"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(0.5, -0.5), -- Diagonal top-left to bottom-right
        Vector2.new(-0.5, -0.5), Vector2.new(0.5, 0.5) -- Diagonal bottom-left to top-right
    },
    ["Y"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(0, 0), -- Left top stroke
        Vector2.new(0.5, 0.5), Vector2.new(0, 0), -- Right top stroke
        Vector2.new(0, 0), Vector2.new(0, -0.5) -- Bottom stroke
    },
    ["Z"] = {
        Vector2.new(-0.5, 0.5), Vector2.new(0.5, 0.5), -- Top line
        Vector2.new(0.5, 0.5), Vector2.new(-0.5, -0.5), -- Diagonal
        Vector2.new(-0.5, -0.5), Vector2.new(0.5, -0.5) -- Bottom line
    },
    ["Ä"] = {},
    ["Ö"] = {},
    ["Ü"] = {}
}

-- Helper function: Returns the letter shape for the requested letter.
local function getLetterShape(letter)
    local upper = string.upper(letter)
    return letterShapes[upper] or {}
end

-- Helper function: Linear interpolation (Lerp) for Vector2
local function lerpVector2(a, b, t)
    return a + (b - a) * t
end

-- Helper function: Generates numSamples points, evenly distributed along the path.
local function sampleLetterPoints(points, numSamples)
    local samples = {}
    if #points < 1 then
        for i = 1, numSamples do table.insert(samples, Vector2.new(0,0)) end
        return samples
    elseif #points == 1 then
        for i = 1, numSamples do table.insert(samples, points[1]) end
        return samples
    end

    local segments = {}
    local totalLength = 0
    for i = 1, #points - 1 do
        local segLength = (points[i+1] - points[i]).Magnitude
        totalLength = totalLength + segLength
        table.insert(segments, {start = points[i], finish = points[i+1], length = segLength})
    end

    if totalLength == 0 then
        for i = 1, numSamples do table.insert(samples, points[1]) end
        return samples
    end

    local sampleDistance = totalLength / (numSamples - 1)
    if numSamples == 1 then sampleDistance = 0 end

    local currentDist = 0
    local currentSeg = 1
    local segStartDist = 0

    for i = 1, numSamples do
        while currentSeg <= #segments and (segStartDist + segments[currentSeg].length) < currentDist - 0.0001 do
            segStartDist = segStartDist + segments[currentSeg].length
            currentSeg = currentSeg + 1
        end
        currentSeg = math.min(currentSeg, #segments)

        local seg = segments[currentSeg]
        local t = 0
        if seg.length > 0 then
            t = math.clamp((currentDist - segStartDist) / seg.length, 0, 1)
        elseif currentDist > segStartDist then t = 1 else t = 0 end

        local samplePoint = lerpVector2(seg.start, seg.finish, t)
        table.insert(samples, samplePoint)

        if numSamples > 1 then currentDist = currentDist + sampleDistance end
    end

    while #samples < numSamples do table.insert(samples, points[#points]) end
    while #samples > numSamples do table.remove(samples) end

    return samples
end

-- GUI Preservation Functions
local preservedGuis = {}
local function preserveGuis()
    preservedGuis = {}
    local playerGui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "BodyLetterGui" and gui.ResetOnSpawn then
                table.insert(preservedGuis, gui)
                gui.ResetOnSpawn = false
            end
        end
    end
end

local function restoreGuis()
    task.wait() -- Give engine time to process GUI changes
    for _, gui in ipairs(preservedGuis) do
        if gui and gui.Parent == LocalPlayer:FindFirstChildWhichIsA("PlayerGui") then
            gui.ResetOnSpawn = true
        end
    end
    preservedGuis = {}
end

-- Update Function: Arranges body parts along the letter shape
local function updateRagdolledParts(dt)
    if not ghostEnabled or not originalCharacter or not originalCharacter.Parent or not ghostClone or not ghostClone.Parent then
        if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
        if renderStepConnection then renderStepConnection:Disconnect(); renderStepConnection = nil end
        return
    end

    local currentTime = tick()
    local actualDt = currentTime - lastUpdateTime
    lastUpdateTime = currentTime
    local interpDt = math.min(actualDt, 1/30)

    local rootPart = originalCharacter:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local centerPosition = ghostClone.PrimaryPart and ghostClone.PrimaryPart.Position or rootPart.Position
    local centerCFrame = ghostClone.PrimaryPart and ghostClone.PrimaryPart.CFrame or rootPart.CFrame

    local shapePoints = getLetterShape(selectedLetter)
    if #shapePoints == 0 then return end
    local samplePoints = sampleLetterPoints(shapePoints, #bodyParts)
    if #samplePoints ~= #bodyParts then return end

    for i, partName in ipairs(bodyParts) do
        local originalPart = originalCharacter:FindFirstChild(partName)
        if originalPart then
            if not previousPositions[partName] then previousPositions[partName] = originalPart.CFrame end

            local sample = samplePoints[i]
            local offsetX = centerCFrame.RightVector * sample.X * letterSize
            local offsetY = centerCFrame.UpVector * sample.Y * letterSize
            local targetPos = centerPosition + offsetX + offsetY

            local rotation = previousPositions[partName] - previousPositions[partName].Position
            local targetCFrame = CFrame.new(targetPos) * rotation

            local distance = (targetCFrame.Position - previousPositions[partName].Position).Magnitude
            local baseRate = math.min(0.15, interpDt * 18)
            local adaptiveRate = math.min(0.85, baseRate * (1 + distance * 1.2))
            local smoothCFrame = previousPositions[partName]:Lerp(targetCFrame, adaptiveRate)

            if smoothCFrame == smoothCFrame then -- NaN Check
                 originalPart.CFrame = smoothCFrame
                 previousPositions[partName] = smoothCFrame
            else
                 originalPart.CFrame = targetCFrame
                 previousPositions[partName] = targetCFrame
            end

            originalPart.AssemblyLinearVelocity = Vector3.zero
            originalPart.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

-- Toggle Ghost Mode / Reanimation
local function setGhostEnabled(newState)
    ghostEnabled = newState

    if ghostEnabled then
        -- Enabling logic remains the same as in your original script
        local char = LocalPlayer.Character
        if not char then print("Character not found to activate."); return end
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then print("Humanoid or RootPart missing."); return end
        if originalCharacter or ghostClone then print("Already in Ghost Mode or clone still exists."); return end

        print("Activating Ghost Mode...")
        originalCharacter = char
        originalCFrame = root.CFrame
        char.Archivable = true
        ghostClone = char:Clone()
        char.Archivable = false
        ghostClone.Name = originalCharacter.Name .. "_clone"

        local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
        if ghostHumanoid then
            ghostHumanoid.DisplayName = originalCharacter.Name .. "_clone"
            ghostHumanoid:ChangeState(Enum.HumanoidStateType.Physics) -- Keep ragdolling the clone
        end

        if not ghostClone.PrimaryPart then
            local hrp = ghostClone:FindFirstChild("HumanoidRootPart")
            if hrp then ghostClone.PrimaryPart = hrp else warn("Clone HRP not found!") end
        end

        for _, descendant in ipairs(ghostClone:GetDescendants()) do
            if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
                 descendant.Transparency = 1
                 descendant.CanCollide = false
                 descendant.Anchored = false
                 descendant.CanQuery = false
            elseif descendant:IsA("Decal") then descendant.Transparency = 1
            elseif descendant:IsA("Accessory") then
                 local handle = descendant:FindFirstChild("Handle")
                 if handle then
                    handle.Transparency = 1; handle.CanCollide = false; handle.CanQuery = false
                 end
            end
        end

        local animate = originalCharacter:FindFirstChild("Animate")
        if animate and animate:IsA("Script") then
            originalAnimateScript = animate
            originalAnimateScript.Disabled = true
            originalAnimateScript.Parent = ghostClone -- Move script to clone
        else originalAnimateScript = nil end

        preserveGuis()
        ghostClone.Parent = Workspace -- Keep clone in Workspace
        LocalPlayer.Character = ghostClone -- Player controls clone
        if ghostHumanoid then Workspace.CurrentCamera.CameraSubject = ghostHumanoid end
        restoreGuis()

        -- Enable Animate script on the clone
        if originalAnimateScript and originalAnimateScript.Parent == ghostClone then
            task.wait()
            originalAnimateScript.Disabled = false
        end

        -- Fire Ragdoll Event (Server-side constraints for original character)
        local ragdollEvent = ReplicatedStorage:FindFirstChild("RagdollEvent")
        if ragdollEvent then ragdollEvent:FireServer() else warn("RagdollEvent not found!") end

        previousPositions = {}
        lastUpdateTime = tick()
        if updateConnection then updateConnection:Disconnect() end
        if renderStepConnection then renderStepConnection:Disconnect() end
        updateConnection = RunService.Heartbeat:Connect(updateRagdolledParts) -- Start updating original parts

        print("Ghost Mode activated.")

    else
        -- MODIFIED DISABLING LOGIC (Based on the second script)
        print("Deactivating Ghost Mode...")
        if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
        if renderStepConnection then renderStepConnection:Disconnect(); renderStepConnection = nil end

        if not originalCharacter or not ghostClone then
            print("Not in Ghost Mode or clone/original character missing.")
            return
        end

        -- Fire Unragdoll Event
        local unragdollEvent = ReplicatedStorage:FindFirstChild("UnragdollEvent")
        if unragdollEvent then
            for i = 1, 3 do
                unragdollEvent:FireServer()
                task.wait(0.1) -- Small delay between fires as in the example
            end
        else
            warn("UnragdollEvent not found in ReplicatedStorage!")
        end

        -- Get target CFrame from the clone's RootPart or use original saved CFrame
        local targetCFrame = originalCFrame
        local ghostRoot = ghostClone:FindFirstChild("HumanoidRootPart")
        if ghostRoot then
            targetCFrame = ghostRoot.CFrame
        else
             warn("Clone HumanoidRootPart not found when deactivating! Using original CFrame.")
        end

        -- Find Animate script in the clone
        local animate = ghostClone:FindFirstChild("Animate")
        if animate and animate == originalAnimateScript then
             -- Disable and move Animate script back to the original character *before* destroying clone
             animate.Disabled = true
             animate.Parent = originalCharacter
        end

        -- Destroy the clone
        ghostClone:Destroy()
        ghostClone = nil

        -- Restore original character
        if originalCharacter and originalCharacter.Parent then
            local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
            local origHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")

            -- Set original character's position
            if origRoot then
                origRoot.CFrame = targetCFrame
                -- Reset velocities (important after ragdoll)
                origRoot.AssemblyLinearVelocity = Vector3.zero
                origRoot.AssemblyAngularVelocity = Vector3.zero
            end

            preserveGuis()
            LocalPlayer.Character = originalCharacter -- Give control back
            if origHumanoid then
                Workspace.CurrentCamera.CameraSubject = origHumanoid -- Set camera back
                -- NOTE: No forced state changes like GettingUp from the first script
            end
            restoreGuis()

            -- Re-enable Animate script on the original character after a short delay
            if animate and animate.Parent == originalCharacter then
                task.wait(0.1) -- Use the shorter delay from the second script example
                animate.Disabled = false
                print("Original Animate script re-enabled.")
            end

            print("Original character restored.")
        else
             warn("Original character lost during ghost mode! Forcing respawn.")
             LocalPlayer:LoadCharacter() -- Fallback if original character is gone
        end

        -- Clean up variables
        originalCharacter = nil
        originalAnimateScript = nil -- Already moved or irrelevant
        previousPositions = {}
        print("Ghost mode disabled.")
    end
end

-- GUI Creation Function (Modified for size and rounded corners)
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BodyLetterGui" -- **Changed GUI Name to BodyLetterGui**
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 1000

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400) -- **Smaller GUI Size**
    frame.Position = UDim2.new(0.5, -150, 0.1, 0) -- Adjusted Position for smaller size
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.Active = true
    frame.Draggable = true

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 25) -- Smaller title bar
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.Parent = frame
    titleBar.Active = false
    local titleBarCorner = Instance.new("UICorner") -- Rounded Corners for title bar
    titleBarCorner.CornerRadius = UDim.new(0, 8)
    titleBarCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -30, 1, 0) -- Adjusted size for smaller title bar
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "BodyLetter" -- **Changed GUI Title to BodyLetter**
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextSize = 14
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20) -- Smaller close button
    closeButton.Position = UDim2.new(1, -3, 0.5, 0) -- Adjusted position
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12 -- Smaller text size
    closeButton.Parent = titleBar
    closeButton.ZIndex = 2

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, -15, 0, 25) -- Smaller button
    toggleButton.Position = UDim2.new(0.5, 0, 0, 35) -- Adjusted position
    toggleButton.AnchorPoint = Vector2.new(0.5, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    toggleButton.Text = "Enable BodyLetter" -- **Changed Button Text to Enable BodyLetter**
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamSemibold
    toggleButton.TextSize = 14
    toggleButton.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = toggleButton

    -- Size Slider Function (Unchanged with minor style adjustments for size)
    local function createSlider(parent, yPosition, labelText, minValue, maxValue, defaultValue, valueChangedCallback)
        local sliderHeight = 25; local knobSize = 18 -- Smaller slider height and knob
        local currentValue = defaultValue; local lastCallbackTime = 0
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Size = UDim2.new(1, -15, 0, sliderHeight + 10) -- Adjusted size
        sliderContainer.Position = UDim2.new(0, 7.5, 0, yPosition) -- Adjusted position
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.Parent = parent
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 50, 0, sliderHeight); label.BackgroundTransparency = 1 -- Smaller label width
        label.Text = labelText .. ":"; label.TextColor3 = Color3.fromRGB(220, 220, 220) -- **English Text**
        label.Font = Enum.Font.Gotham; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left -- Smaller text size
        label.Parent = sliderContainer
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 40, 0, sliderHeight); valueLabel.Position = UDim2.new(1, 0, 0, 0) -- Smaller value label
        valueLabel.AnchorPoint = Vector2.new(1, 0); valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255); valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 12; valueLabel.TextXAlignment = Enum.TextXAlignment.Right -- Smaller text size
        valueLabel.Text = string.format("%.1f", defaultValue); valueLabel.Parent = sliderContainer
        local sliderBackground = Instance.new("Frame")
        sliderBackground.Size = UDim2.new(1, -100, 0, sliderHeight); sliderBackground.Position = UDim2.new(0, 55, 0, 0) -- Adjusted size and position
        sliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40); sliderBackground.BorderSizePixel = 0
        sliderBackground.Parent = sliderContainer
        local backgroundCorner = Instance.new("UICorner"); backgroundCorner.CornerRadius = UDim.new(0, 6); backgroundCorner.Parent = sliderBackground
        local trackContainer = Instance.new("Frame")
        trackContainer.Size = UDim2.new(1, -10, 0, sliderHeight); trackContainer.Position = UDim2.new(0.5, 0, 0, 0)
        trackContainer.AnchorPoint = Vector2.new(0.5, 0); trackContainer.BackgroundTransparency = 1
        trackContainer.Parent = sliderBackground; trackContainer.Active = true
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6); track.Position = UDim2.new(0, 0, 0.5, 0); track.AnchorPoint = Vector2.new(0, 0.5) -- Smaller track height
        track.BackgroundColor3 = Color3.fromRGB(80, 80, 80); track.BorderSizePixel = 0; track.Parent = trackContainer
        local trackCorner = Instance.new("UICorner"); trackCorner.CornerRadius = UDim.new(1, 0); trackCorner.Parent = track
        local progressTrack = Instance.new("Frame")
        progressTrack.Size = UDim2.new(0, 0, 1, 0); progressTrack.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        progressTrack.BorderSizePixel = 0; progressTrack.Parent = track
        local progressCorner = Instance.new("UICorner"); progressCorner.CornerRadius = UDim.new(1, 0); progressCorner.Parent = progressTrack
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, knobSize, 0, knobSize); knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200); knob.BorderSizePixel = 0
        knob.Text = ""; knob.AutoButtonColor = false; knob.ZIndex = 3; knob.Parent = trackContainer
        local knobCorner = Instance.new("UICorner"); knobCorner.CornerRadius = UDim.new(1, 0); knobCorner.Parent = knob
        local knobShadow = Instance.new("Frame")
        knobShadow.Size = UDim2.new(1, 4, 1, 4); knobShadow.Position = UDim2.new(0.5, 0, 0.5, 0); knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0); knobShadow.BackgroundTransparency = 0.7
        knobShadow.BorderSizePixel = 0; knobShadow.ZIndex = 2; knobShadow.Parent = knob
        local shadowCorner = Instance.new("UICorner"); shadowCorner.CornerRadius = UDim.new(1, 0); shadowCorner.Parent = knobShadow
        local function updateSliderFromValue(value, callCallback)
            value = math.clamp(value, minValue, maxValue); value = math.floor(value * 10 + 0.5) / 10
            if value ~= currentValue or not callCallback then
                currentValue = value; local fraction = (value - minValue) / (maxValue - minValue)
                knob.Position = UDim2.new(fraction, 0, 0.5, 0); progressTrack.Size = UDim2.new(fraction, 0, 1, 0)
                valueLabel.Text = string.format("%.1f", value)
                local currentTime = tick()
                if callCallback and valueChangedCallback and (currentTime - lastCallbackTime > 0.1) then
                    lastCallbackTime = currentTime; valueChangedCallback(currentValue) end
            end
        end
        local function updateValueFromPosition(mouseX)
            local trackAbsPos = trackContainer.AbsolutePosition.X; local trackAbsSize = trackContainer.AbsoluteSize.X
            if trackAbsSize == 0 then return end; local relativeX = mouseX - trackAbsPos
            local fraction = math.clamp(relativeX / trackAbsSize, 0, 1); local newValue = minValue + fraction * (maxValue - minValue)
            updateSliderFromValue(newValue, true)
        end
        local isDragging = false
        knob.MouseButton1Down:Connect(function() isDragging = true end)
        sliderBackground.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then updateValueFromPosition(input.Position.X); isDragging = true end end)
        track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then updateValueFromPosition(input.Position.X); isDragging = true end end)
        local inputEndedConnection; local inputChangedConnection
        inputEndedConnection = UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then if isDragging then if valueChangedCallback then valueChangedCallback(currentValue) end; isDragging = false end end end)
        inputChangedConnection = UserInputService.InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateValueFromPosition(input.Position.X) end end)
        sliderContainer.AncestryChanged:Connect(function(_, newParent) if not newParent then if inputEndedConnection then inputEndedConnection:Disconnect() end; if inputChangedConnection then inputChangedConnection:Disconnect() end end end)
        updateSliderFromValue(defaultValue, false); return sliderContainer
    end

    local sliderY = 70 -- Adjusted slider Y position
    local sizeSlider = createSlider(frame, sliderY, "Size", 1, 20, letterSize, function(newValue)
        letterSize = newValue
    end)

    -- Letter Selection Frame (Unchanged with smaller size)
    local letterFrame = Instance.new("ScrollingFrame")
    letterFrame.Size = UDim2.new(1, -15, 0, 150); letterFrame.Position = UDim2.new(0, 7.5, 0, sliderY + 35) -- Smaller height and adjusted position
    letterFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50); letterFrame.BorderSizePixel = 1
    letterFrame.BorderColor3 = Color3.fromRGB(60, 60, 60); letterFrame.ScrollBarThickness = 5 -- Smaller scroll bar
    letterFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; letterFrame.Parent = frame
    local letterCorner = Instance.new("UICorner"); letterCorner.CornerRadius = UDim.new(0, 4); letterCorner.Parent = letterFrame
    local UIGridLayout = Instance.new("UIGridLayout")
    UIGridLayout.CellSize = UDim2.new(0, 30, 0, 30); UIGridLayout.CellPadding = UDim2.new(0, 3, 0, 3) -- Smaller cells and padding
    UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIGridLayout.Parent = letterFrame
    local supportedLetters = {}
    for i = 65, 90 do table.insert(supportedLetters, string.char(i)) end; table.sort(supportedLetters)
    local letterButtons = {}
    for i, letter in ipairs(supportedLetters) do
        local letterButton = Instance.new("TextButton")
        letterButton.Name = "LetterButton_" .. letter; letterButton.Size = UDim2.new(0, 30, 0, 30) -- Smaller button size
        letterButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80); letterButton.Text = letter
        letterButton.Font = Enum.Font.GothamBold; letterButton.TextSize = 14 -- Smaller text size
        letterButton.TextColor3 = Color3.fromRGB(255, 255, 255); letterButton.LayoutOrder = i; letterButton.Parent = letterFrame
        local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 4); btnCorner.Parent = letterButton
        table.insert(letterButtons, letterButton)
        letterButton.MouseButton1Click:Connect(function()
            selectedLetter = letter
            for _, btn in ipairs(letterButtons) do
                if btn.Text == selectedLetter then btn.BackgroundColor3 = Color3.fromRGB(76, 175, 80); btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                else btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); btn.TextColor3 = Color3.fromRGB(220, 220, 220) end
            end
        end)
        if letter == selectedLetter then letterButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80); letterButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        else letterButton.TextColor3 = Color3.fromRGB(220, 220, 220) end
    end

    -- Text Animation Area (Unchanged with smaller size)
    local textAnimationY = letterFrame.Position.Y.Offset + letterFrame.Size.Y.Offset + 15 -- Adjusted position
    local animationLabel = Instance.new("TextLabel")
    animationLabel.Size = UDim2.new(1, -15, 0, 18); animationLabel.Position = UDim2.new(0, 7.5, 0, textAnimationY) -- Smaller height and adjusted position
    animationLabel.BackgroundTransparency = 1; animationLabel.Text = "Text Animation:" -- **English Text**
    animationLabel.TextColor3 = Color3.fromRGB(220, 220, 220); animationLabel.Font = Enum.Font.GothamSemibold
    animationLabel.TextSize = 12; animationLabel.TextXAlignment = Enum.TextXAlignment.Left; animationLabel.Parent = frame
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -100, 0, 25); textBox.Position = UDim2.new(0, 7.5, 0, textAnimationY + 20) -- Smaller height and adjusted position
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60); textBox.BorderSizePixel = 0; textBox.Text = animationText
    textBox.PlaceholderText = "Enter text..."; textBox.TextColor3 = Color3.fromRGB(255, 255, 255) -- **English Text**
    textBox.Font = Enum.Font.Gotham; textBox.TextSize = 12; textBox.ClearTextOnFocus = false; textBox.Parent = frame
    local textBoxCorner = Instance.new("UICorner"); textBoxCorner.CornerRadius = UDim.new(0, 4); textBoxCorner.Parent = textBox
    local playButton = Instance.new("TextButton")
    playButton.Size = UDim2.new(0, 40, 0, 25); playButton.Position = UDim2.new(1, -85, 0, textAnimationY + 20) -- Smaller button and adjusted position
    playButton.AnchorPoint = Vector2.new(0, 0); playButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    playButton.Text = "Play"; playButton.TextColor3 = Color3.fromRGB(255, 255, 255); playButton.Font = Enum.Font.GothamSemibold -- **English Text**
    playButton.TextSize = 12; playButton.Parent = frame
    local playButtonCorner = Instance.new("UICorner"); playButtonCorner.CornerRadius = UDim.new(0, 4); playButtonCorner.Parent = playButton
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(0, 40, 0, 25); stopButton.Position = UDim2.new(1, -45, 0, textAnimationY + 20) -- Smaller button and adjusted position
    stopButton.AnchorPoint = Vector2.new(0, 0); stopButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47)
    stopButton.Text = "Stop"; stopButton.TextColor3 = Color3.fromRGB(255, 255, 255); stopButton.Font = Enum.Font.GothamSemibold -- **English Text**
    stopButton.TextSize = 12; stopButton.Parent = frame
    local stopButtonCorner = Instance.new("UICorner"); stopButtonCorner.CornerRadius = UDim.new(0, 4); stopButtonCorner.Parent = stopButton
    animationSpeed = 2.0
    local speedSlider = createSlider(frame, textAnimationY + 55, "Speed", 0.5, 5.0, animationSpeed, function(newValue) -- Adjusted position
        animationSpeed = 5.5 - newValue
    end)
    local speedExplanation = Instance.new("TextLabel")
    speedExplanation.Size = UDim2.new(1, -15, 0, 18); speedExplanation.Position = UDim2.new(0, 7.5, 0, textAnimationY + 90) -- Smaller height and adjusted position
    speedExplanation.BackgroundTransparency = 1; speedExplanation.Text = "(Higher = faster)" -- **English Text**
    speedExplanation.TextColor3 = Color3.fromRGB(180, 180, 180); speedExplanation.Font = Enum.Font.Gotham
    speedExplanation.TextSize = 11; speedExplanation.TextXAlignment = Enum.TextXAlignment.Left; speedExplanation.Parent = frame

    local function startTextAnimation()
        if isAnimationPlaying then return end; animationText = textBox.Text; if animationText == "" then return end
        isAnimationPlaying = true; animationIndex = 1; playButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100); stopButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47)
        if animationConnection then animationConnection:Disconnect() end
        local lastUpdateTime = tick(); local currentChar = ""
        animationConnection = RunService.Heartbeat:Connect(function()
            if not isAnimationPlaying then return end; local currentTime = tick(); local elapsedTime = currentTime - lastUpdateTime
            if elapsedTime < animationSpeed then return end
            if animationIndex <= #animationText then
                currentChar = string.sub(animationText, animationIndex, animationIndex)
                if currentChar == " " or not letterShapes[string.upper(currentChar)] then
                    animationIndex = animationIndex + 1; lastUpdateTime = currentTime; return
                end
                selectedLetter = currentChar
                for _, btn in ipairs(letterButtons) do
                    if btn.Text == string.upper(selectedLetter) then btn.BackgroundColor3 = Color3.fromRGB(76, 175, 80); btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); btn.TextColor3 = Color3.fromRGB(220, 220, 220) end
                end
                lastUpdateTime = currentTime; animationIndex = animationIndex + 1
            else
                animationIndex = 1; if #animationText > 0 then currentChar = string.sub(animationText, 1, 1); if letterShapes[string.upper(currentChar)] then selectedLetter = currentChar
                for _, btn in ipairs(letterButtons) do if btn.Text == string.upper(selectedLetter) then btn.BackgroundColor3 = Color3.fromRGB(76, 175, 80); btn.TextColor3 = Color3.fromRGB(255, 255, 255) else btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); btn.TextColor3 = Color3.fromRGB(220, 220, 220) end end end end
                lastUpdateTime = currentTime
            end
        end)
    end
    local function stopTextAnimation()
        if not isAnimationPlaying then return end; isAnimationPlaying = false
        if animationConnection then animationConnection:Disconnect(); animationConnection = nil end
        playButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80); stopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
    playButton.MouseButton1Click:Connect(startTextAnimation); stopButton.MouseButton1Click:Connect(stopTextAnimation)
    textBox.FocusLost:Connect(function(enterPressed) animationText = textBox.Text; if enterPressed and animationText ~= "" then startTextAnimation() end end)

    -- Event Connections for Toggle and Close (Unchanged)
    closeButton.MouseButton1Click:Connect(function()
        if isAnimationPlaying then stopTextAnimation() end
        if ghostEnabled then setGhostEnabled(false); task.wait(0.5) end
        screenGui:Destroy()
    end)
    toggleButton.MouseButton1Click:Connect(function()
        local newState = not ghostEnabled
        setGhostEnabled(newState)
        if ghostEnabled then toggleButton.Text = "Disable BodyLetter"; toggleButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47) -- **Changed Button Text to Disable BodyLetter**
        else toggleButton.Text = "Enable BodyLetter"; toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80) end -- **Changed Button Text to Enable BodyLetter**
    end)

    return screenGui
end

-- Initialization & Cleanup (Unchanged)
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local function cleanupExistingGui()
    local existingGui = playerGui:FindFirstChild("BodyLetterGui") -- **Changed GUI Name Check to BodyLetterGui**
    if existingGui then print("Old BodyLetter GUI found, removing."); existingGui:Destroy() end -- **Changed Log Message to BodyLetter**
end
cleanupExistingGui()
print("Creating new BodyLetter GUI (Letter Shape).") -- **Changed Log Message to BodyLetter**
local gui = createGui()
gui.Parent = playerGui
local scriptDestroyConnection
scriptDestroyConnection = script.Destroying:Connect(function()
    print("BodyLetter script destroying. Cleaning up...") -- **Changed Log Message to BodyLetter**
    if isAnimationPlaying and animationConnection then animationConnection:Disconnect(); animationConnection = nil; isAnimationPlaying = false end
    if ghostEnabled then setGhostEnabled(false) end
    if gui and gui.Parent then gui:Destroy() else cleanupExistingGui() end
    if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
    if renderStepConnection then renderStepConnection:Disconnect(); renderStepConnection = nil end
    if scriptDestroyConnection then scriptDestroyConnection:Disconnect(); scriptDestroyConnection = nil end
    print("Cleanup complete.")
end)
print("BodyLetter script loaded. GUI created.") -- **Changed Log Message to BodyLetter**
