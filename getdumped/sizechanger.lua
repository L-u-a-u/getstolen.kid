local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Store last death position
local lastDeathCFrame = nil
local HttpService = game:GetService("HttpService")

local ghostEnabled = false
local originalCharacter
local ghostClone
local originalCFrame
local originalAnimateScript
local updateConnection
local ghostOriginalHipHeight
local ghostOriginalSizes = {}
local ghostOriginalMotorCFrames = {}
local animationCache = {}
local currentSound = nil
local audioCache = {}
local musicEnabled = true

local bodyParts = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot"
}

local animationState = {
    isRunning = false,
    currentId = nil,
    keyframes = nil,
    totalDuration = 0,
    elapsedTime = 0,
    speed = 1,
    connection = nil
}

local BuiltInAnimationsR15 = {}
local BuiltInAnimationsOrder = {}
local hasFetchedAnimations = false

-- Respawn at last death location logic
local function setupRespawnAtDeath()
    local function onCharacterAdded(character)
        -- Teleport to last death position if available
        if lastDeathCFrame then
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                hrp.CFrame = lastDeathCFrame
            end
            lastDeathCFrame = nil -- Only teleport once after dying
        end
        -- Listen for death
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    lastDeathCFrame = hrp.CFrame
                end
            end)
        end
    end
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

setupRespawnAtDeath()

local function fetchAnimationsFromGitHub()
    if hasFetchedAnimations then return end
    hasFetchedAnimations = true
    local url = "https://ichfickdeinemutta.pages.dev/anims.lua"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local loadSuccess, result = pcall(function()
            return loadstring(response)()
        end)
        if loadSuccess and type(result) == "table" then
            BuiltInAnimationsR15 = result
            BuiltInAnimationsOrder = {}
            for line in response:gmatch("[^\r\n]+") do
                local name = line:match('%["([^"]+)"%]')
                if name and result[name] and not table.find(BuiltInAnimationsOrder, name) then
                    table.insert(BuiltInAnimationsOrder, name)
                end
            end
        else
            warn("Failed to compile GitHub script:", result)
        end
    else
        warn("Failed to fetch animations:", response)
    end
end
fetchAnimationsFromGitHub()

local newAnimations = {
    ["twerking"] = 77493234914180,
    ["Wait love me like I love you"] = 113197266804415,
    ["head banger (fortnite)"] = 117390128696430,
    ["egg dance (acu saya)"] = 14765075073,
    ["nya arigato"] = 16038410193,
    ["move ya body"] = 109551168484965,
    ["hug"] = 113001288211277,
    ["push 2 start"] = 121825287394407,
    ["jumpstyle"] = 127818220981023,
    ["Lap Dance"] = 18726264577,
    ["jerk off"] = 85510928563896,
    ["backshots"] = 107788763755159
}

local existingIds = {}
for _, id in pairs(BuiltInAnimationsR15) do
    existingIds[id] = true
end
for animName, animId in pairs(newAnimations) do
    if not existingIds[animId] and not table.find(BuiltInAnimationsOrder, animName) then
        BuiltInAnimationsR15[animName] = animId
        table.insert(BuiltInAnimationsOrder, animName)
    end
end

local favoriteAnimations = {}
local animationKeybinds = {}
local customAnimations = {}

local KEYBIND_SPEED_FILE = "ak/speed_keybinds.json"
local speedKeybindData = {
    SlowMarker = {ratio = 0.2, key = ""}, -- Default values
    FastMarker = {ratio = 0.8, key = ""}
}
local speedKeybindFunctions = {}

local function ensureakFolder()
    if not isfolder("ak") then
        makefolder("ak")
    end
end

local function ensureAudiosFolder()
    ensureakFolder()
    if not isfolder("ak/audios") then
        makefolder("ak/audios")
    end
end

local hasCreatedFavoritesFile = false
local hasCreatedKeybindsFile = false
local hasCreatedCustomAnimationsFile = false

local function saveFavorites()
    ensureakFolder()
    local favoritesToSave = {}
    for animName, animId in pairs(favoriteAnimations) do
        favoritesToSave[animName] = tostring(animId)
    end
    local success, encodedFavorites = pcall(HttpService.JSONEncode, HttpService, favoritesToSave)
    if success then
        local saveSuccess, errorMessage = pcall(function()
            writefile("ak/favorite_animations.json", encodedFavorites)
        end)
        if not saveSuccess then
            warn("Error saving favorites:", errorMessage)
        elseif not hasCreatedFavoritesFile then
            hasCreatedFavoritesFile = true
        end
    else
        warn("Error encoding favorites:", encodedFavorites)
    end
end

local function loadFavorites()
    ensureakFolder()
    local success, fileContent = pcall(readfile, "ak/favorite_animations.json")
    if success then
        local decodeSuccess, decodedFavorites = pcall(HttpService.JSONDecode, HttpService, fileContent)
        if decodeSuccess and typeof(decodedFavorites) == "table" then
            favoriteAnimations = {}
            for animName, animId in pairs(decodedFavorites) do
                favoriteAnimations[animName] = animId
                if not BuiltInAnimationsR15[animName] then
                    BuiltInAnimationsR15[animName] = animId
                    if not table.find(BuiltInAnimationsOrder, animName) then
                        table.insert(BuiltInAnimationsOrder, animName)
                    end
                end
            end
        else
            favoriteAnimations = {}
        end
    else
        favoriteAnimations = {}
    end
end

local function saveKeybinds()
    ensureakFolder()
    local keybindsToSave = {}
    for animName, keyCode in pairs(animationKeybinds) do
        keybindsToSave[animName] = keyCode.Name
    end
    local success, encodedKeybinds = pcall(HttpService.JSONEncode, HttpService, keybindsToSave)
    if success then
        local saveSuccess, errorMessage = pcall(function()
            writefile("ak/animation_keybinds.json", encodedKeybinds)
        end)
        if not saveSuccess then
            warn("Error saving keybinds:", errorMessage)
        elseif not hasCreatedKeybindsFile then
            hasCreatedKeybindsFile = true
        end
    else
        warn("Error encoding keybinds:", encodedKeybinds)
    end
end

local function loadKeybinds()
    ensureakFolder()
    local success, fileContent = pcall(readfile, "ak/animation_keybinds.json")
    if success then
        local decodeSuccess, decodedKeybinds = pcall(HttpService.JSONDecode, HttpService, fileContent)
        if decodeSuccess and typeof(decodedKeybinds) == "table" then
            animationKeybinds = {}
            for animName, keyName in pairs(decodedKeybinds) do
                animationKeybinds[animName] = Enum.KeyCode[keyName]
            end
        else
            animationKeybinds = {}
        end
    else
        animationKeybinds = {}
    end
end

local function saveSpeedKeybinds()
    ensureakFolder()
    local keybindsToSave = {
        SlowMarker = speedKeybindData.SlowMarker,
        FastMarker = speedKeybindData.FastMarker
    }
    local success, encodedKeybinds = pcall(HttpService.JSONEncode, HttpService, keybindsToSave)
    if success then
        local saveSuccess, errorMessage = pcall(function()
            writefile(KEYBIND_SPEED_FILE, encodedKeybinds)
        end)
        if not saveSuccess then
            warn("Error saving speed keybinds:", errorMessage)
        end
    else
        warn("Error encoding speed keybinds:", encodedKeybinds)
    end
end

local function loadSpeedKeybinds()
    ensureakFolder()
    local success, fileContent = pcall(readfile, KEYBIND_SPEED_FILE)
    if success then
        local decodeSuccess, decodedData = pcall(HttpService.JSONDecode, HttpService, fileContent)
        if decodeSuccess and typeof(decodedData) == "table" then
            if decodedData.SlowMarker and type(decodedData.SlowMarker.ratio) == "number" and type(decodedData.SlowMarker.key) == "string" and
               decodedData.FastMarker and type(decodedData.FastMarker.ratio) == "number" and type(decodedData.FastMarker.key) == "string" then
                speedKeybindData = decodedData
            else
                warn("Loaded speed keybind data has incorrect format, using defaults.")
                -- Keep default speedKeybindData
            end
        else
            warn("Failed to decode speed keybinds or data is not a table:", decodedData)
            -- Keep default speedKeybindData
        end
    else
        -- File doesn't exist or couldn't be read, keep default speedKeybindData
        -- warn("Speed keybind file not found or unreadable, using defaults.")
    end
end

local function saveCustomAnimations()
    ensureakFolder()
    local customToSave = {}
    for animName, animId in pairs(customAnimations) do
        customToSave[animName] = tostring(animId)
    end
    local success, encodedCustom = pcall(HttpService.JSONEncode, HttpService, customToSave)
    if success then
        local saveSuccess, errorMessage = pcall(function()
            writefile("ak/custom_animations.json", encodedCustom)
        end)
        if not saveSuccess then
            warn("Error saving custom animations:", errorMessage)
        elseif not hasCreatedCustomAnimationsFile then
            hasCreatedCustomAnimationsFile = true
        end
    else
        warn("Error encoding custom animations:", encodedCustom)
    end
end

local function loadCustomAnimations()
    ensureakFolder()
    local success, fileContent = pcall(readfile, "ak/custom_animations.json")
    if success then
        local decodeSuccess, decodedCustom = pcall(HttpService.JSONDecode, HttpService, fileContent)
        if decodeSuccess and typeof(decodedCustom) == "table" then
            customAnimations = decodedCustom
        else
            customAnimations = {}
        end
    else
        customAnimations = {}
    end
end

local function preloadAnimations(animationTable)
    for animName, animId in pairs(animationTable) do
        if not animationCache[animId] then
            local success, animationAsset = pcall(function()
                return game:GetObjects("rbxassetid://" .. animId)[1]
            end)
            if success and animationAsset then
                animationCache[animId] = animationAsset
            else
                warn("Failed to preload animation:", animName, "ID:", animId)
            end
        end
    end
end

local function fetchAudio(animationId)
    local filePath = "ak/audios/" .. animationId .. ".mp3"
    local url = "https://github.com/BloxiAstra/audios/raw/refs/heads/main/" .. animationId .. ".mp3"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        writefile(filePath, response)
        return true
    else
        warn("Failed to download audio for ID " .. animationId .. ": " .. tostring(response))
        return false
    end
end

local function loadAudio(animationId)
    if audioCache[animationId] then
        return audioCache[animationId]
    end
    local filePath = "ak/audios/" .. animationId .. ".mp3"
    if isfile(filePath) then
        local sound = Instance.new("Sound")
        sound.SoundId = getcustomasset(filePath)
        sound.Volume = 1 
        sound.Looped = true
        spawn(function()
while wait() do
if sound then
sound.Pitch = animationState.speed
else
continue
end
end
end)
        sound.Parent = LocalPlayer:WaitForChild("PlayerGui")
        audioCache[animationId] = sound
        return sound
    end
    return nil
end

local activeNotifications = {}

local function showNotification(message, duration)
    local screenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("EnhancedGhostGui") or LocalPlayer:WaitForChild("PlayerGui")
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 220, 0, 40)
    notification.Position = UDim2.new(1, 0, 0.1, 0)
    notification.Text = message
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.TextSize = 16
    notification.Font = Enum.Font.GothamSemibold
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    notification.BackgroundTransparency = 1
    notification.TextTransparency = 1
    notification.BorderSizePixel = 0
    notification.ZIndex = 10

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification

    local shadow = Instance.new("UIStroke")
    shadow.Thickness = 2
    shadow.Color = Color3.fromRGB(20, 20, 20)
    shadow.Transparency = 0.5
    shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    shadow.Parent = notification

    notification.Parent = screenGui

    local yOffset = 0
    for _, existingNotif in pairs(activeNotifications) do
        if existingNotif and existingNotif.Parent then
            yOffset = yOffset + existingNotif.AbsoluteSize.Y + 10
        end
    end

    table.insert(activeNotifications, notification)

    local tweenInfoIn = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local goalIn = {
        Position = UDim2.new(0.5, -110, 0.1, yOffset),
        BackgroundTransparency = 0,
        TextTransparency = 0
    }
    local tweenIn = TweenService:Create(notification, tweenInfoIn, goalIn)
    tweenIn:Play()

    task.delay(duration or 2, function()
        if notification and notification.Parent then
            local tweenInfoOut = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            local goalOut = {
                Position = UDim2.new(0.5, -110, 0, -50),
                BackgroundTransparency = 1,
                TextTransparency = 1
            }
            local tweenOut = TweenService:Create(notification, tweenInfoOut, goalOut)
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                if notification and notification.Parent then
                    notification:Destroy()
                    for i, notif in ipairs(activeNotifications) do
                        if notif == notification then
                            table.remove(activeNotifications, i)
                            break
                        end
                    end
                    local newOffset = 0
                    for _, remainingNotif in pairs(activeNotifications) do
                        if remainingNotif and remainingNotif.Parent then
                            TweenService:Create(remainingNotif, tweenInfoIn, {
                                Position = UDim2.new(0.5, -110, 0.1, newOffset)
                            }):Play()
                            newOffset = newOffset + remainingNotif.AbsoluteSize.Y + 10
                        end
                    end
                end
            end)
        end
    end)
end

local function preloadAudios()
    ensureAudiosFolder()
    local url = "https://raw.githubusercontent.com/BloxiAstra/audios/refs/heads/main/ids.json"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, response)
        if decodeSuccess and data.audio_ids and type(data.audio_ids) == "table" then
            local audioCount = #data.audio_ids
            local fetchedCount = 0
            for _, animId in ipairs(data.audio_ids) do
                local idStr = tostring(animId)
                local filePath = "ak/audios/" .. idStr .. ".mp3"
                if not isfile(filePath) then
                    local fetchSuccess = fetchAudio(idStr)
                    if fetchSuccess then
                        fetchedCount = fetchedCount + 1
                        showNotification(idStr .. ".mp3 fetched!", 2)
                    end
                else
                    fetchedCount = fetchedCount + 1
                end
            end
            print("Loaded " .. fetchedCount .. " audios")
        else
            warn("Failed to decode ids.json or invalid format: " .. tostring(data))
        end
    else
        warn("Failed to fetch ids.json: " .. tostring(response))
    end
end

local function initializePreloading()
    loadFavorites()
    loadCustomAnimations()
    -- Only preload the first 10 favorite animations if there are more than 10
    local favCount = 0
    local favToPreload = {}
    for animName, animId in pairs(favoriteAnimations) do
        favToPreload[animName] = animId
        favCount = favCount + 1
        if favCount >= 10 then break end
    end
    preloadAnimations(favToPreload)
    preloadAnimations(customAnimations)
    preloadAudios()
end

local function scaleCFrame(cf, scale)
    local pos = cf.Position * scale
    local xRot, yRot, zRot = cf:ToEulerAnglesXYZ()
    return CFrame.new(pos) * CFrame.Angles(xRot, yRot, zRot)
end

local function adjustCloneToGround(clone)
    if not clone then return end
    local lowestY = math.huge
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            local bottomY = part.Position.Y - (part.Size.Y / 2)
            if bottomY < lowestY then
                lowestY = bottomY
            end
        end
    end
    local groundY = 0
    local offset = groundY - lowestY
    if offset > 0 then
        if clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame + Vector3.new(0, offset, 0))
        else
            clone:TranslateBy(Vector3.new(0, offset, 0))
        end
    end
end

local preservedGuis = {}
local function preserveGuis()
    local playerGui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.ResetOnSpawn then
                table.insert(preservedGuis, gui)
                gui.ResetOnSpawn = false
            end
        end
    end
end

local function restoreGuis()
    for _, gui in ipairs(preservedGuis) do
        gui.ResetOnSpawn = true
    end
    table.clear(preservedGuis)
end

local function updateCloneTransparency()
    if not ghostClone then return end
    for _, part in pairs(ghostClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    local head = ghostClone:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("Decal") then
                child.Transparency = 1
            end
        end
    end
end

local function updateRagdolledParts()
    if not ghostEnabled or not originalCharacter or not ghostClone then return end
    for _, partName in ipairs(bodyParts) do
        local originalPart = originalCharacter:FindFirstChild(partName)
        local clonePart = ghostClone:FindFirstChild(partName)
        if originalPart and clonePart then
            originalPart.CFrame = clonePart.CFrame
            originalPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            originalPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
    local originalNeck = originalCharacter:FindFirstChild("Head") and originalCharacter.Head:FindFirstChild("Neck")
    local cloneNeck = ghostClone:FindFirstChild("Head") and ghostClone.Head:FindFirstChild("Neck")
    if originalNeck and cloneNeck then
        originalNeck.C0 = cloneNeck.C0
    end
end

local function suppressHeadMovement()
    local headMovementScript = Workspace:FindFirstChild("VirtuallyNad") and Workspace.VirtuallyNad:FindFirstChild("HeadMovement")
    if headMovementScript and headMovementScript:IsA("LocalScript") then
        headMovementScript.Disabled = true
    end
    LocalPlayer:SetAttribute("TurnHead", false)
end

local function restoreHeadMovement()
    local headMovementScript = Workspace:FindFirstChild("VirtuallyNad") and Workspace.VirtuallyNad:FindFirstChild("HeadMovement")
    if headMovementScript and headMovementScript:IsA("LocalScript") then
        headMovementScript.Disabled = false
    end
end

local originalNeckC0 = nil
local function resetNeckOrientation(character, isClone)
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    local neck = humanoid.RigType == Enum.HumanoidRigType.R15 and character:WaitForChild("Head"):FindFirstChild("Neck")
        or humanoid.RigType == Enum.HumanoidRigType.R6 and character:WaitForChild("Torso"):FindFirstChild("Neck")
    if not neck or not originalNeckC0 then return end

    local position = originalNeckC0.Position
    local neutralOrientation = CFrame.new(position, position + Vector3.new(0, 0, -1))
    neck.C0 = neutralOrientation

    if isClone then
        ghostOriginalMotorCFrames[neck] = { C0 = neutralOrientation, C1 = neck.C1 }
    end
end

local function setGhostEnabled(newState)
    ghostEnabled = newState

    local hasDefaultRagdollEvents = ReplicatedStorage:FindFirstChild("RagdollEvent") and ReplicatedStorage:FindFirstChild("UnragdollEvent")
    local Packets = nil
    if not hasDefaultRagdollEvents then
        local success, module = pcall(function()
            return require(ReplicatedStorage:WaitForChild("LocalModules"):WaitForChild("Backend"):WaitForChild("Packets"))
        end)
        if success then
            Packets = module
        else
            warn("Failed to load Packets module!")
        end
    end
    
    if ghostEnabled then
        local char = LocalPlayer.Character
        if not char then
            warn("No character found!")
            return
        end

        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then
            warn("Character is missing either Humanoid or HumanoidRootPart!")
            return
        end

        originalCharacter = char
        originalCFrame = root.CFrame

        local neck = humanoid.RigType == Enum.HumanoidRigType.R15 and char:WaitForChild("Head"):FindFirstChild("Neck")
            or humanoid.RigType == Enum.HumanoidRigType.R6 and char:WaitForChild("Torso"):FindFirstChild("Neck")
        if neck then
            originalNeckC0 = neck.C0
        end

        char.Archivable = true
        ghostClone = char:Clone()
        char.Archivable = false

        local originalName = originalCharacter.Name
        ghostClone.Name = originalName .. "_clone"

        local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
        if ghostHumanoid then
            ghostHumanoid.DisplayName = originalName .. "_clone"
            ghostOriginalHipHeight = ghostHumanoid.HipHeight
            ghostHumanoid.WalkSpeed = humanoid.WalkSpeed
            ghostHumanoid.JumpPower = humanoid.JumpPower
        end

        if not ghostClone.PrimaryPart then
            local hrp = ghostClone:FindFirstChild("HumanoidRootPart")
            if hrp then
                ghostClone.PrimaryPart = hrp
            end
        end

        updateCloneTransparency()

        ghostOriginalSizes = {}
        ghostOriginalMotorCFrames = {}
        for _, desc in ipairs(ghostClone:GetDescendants()) do
            if desc:IsA("BasePart") then
                ghostOriginalSizes[desc] = desc.Size
            elseif desc:IsA("Motor6D") then
                ghostOriginalMotorCFrames[desc] = { C0 = desc.C0, C1 = desc.C1 }
            end
        end

        local animate = originalCharacter:FindFirstChild("Animate")
        if animate then
            originalAnimateScript = animate:Clone()
            originalAnimateScript.Parent = ghostClone
            originalAnimateScript.Disabled = true
        end

        if Packets then
            resetNeckOrientation(originalCharacter, false)
            resetNeckOrientation(ghostClone, true)
        end

        preserveGuis()
        ghostClone.Parent = Workspace

        adjustCloneToGround(ghostClone)

        LocalPlayer.Character = ghostClone
        if ghostHumanoid then
            Workspace.CurrentCamera.CameraSubject = ghostHumanoid
        end
        restoreGuis()

        task.delay(0.1, function()
            if not ghostEnabled or not ghostClone then return end
            if originalAnimateScript then
                originalAnimateScript.Disabled = false
            end
            if ghostHumanoid then
                ghostHumanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)

        task.delay(0, function()
            if not ghostEnabled then return end
            if hasDefaultRagdollEvents then
                if ReplicatedStorage:FindFirstChild("RagdollEvent") then
                    ReplicatedStorage.RagdollEvent:FireServer()
                else
                    warn("RagdollEvent not found!")
                end
            elseif Packets then
                Packets.Ragdoll:Fire(true)
                suppressHeadMovement()
            end
            task.delay(0, function()
                if not ghostEnabled then return end
                if updateConnection then updateConnection:Disconnect() end
                updateConnection = RunService.Heartbeat:Connect(updateRagdolledParts)
            end)
        end)
    else
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        if animationState.connection then
            animationState.connection:Disconnect()
            animationState.connection = nil
        end

        if not originalCharacter or not ghostClone then return end

        for i = 1, 3 do
            if hasDefaultRagdollEvents then
                if ReplicatedStorage:FindFirstChild("UnragdollEvent") then
                    ReplicatedStorage.UnragdollEvent:FireServer()
                else
                    warn("UnragdollEvent not found!")
                end
            elseif Packets then
                Packets.Ragdoll:Fire(false)
                restoreHeadMovement()
            end
            task.wait(0.1)
        end

        local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
        local ghostRoot = ghostClone:FindFirstChild("HumanoidRootPart")
        local targetCFrame = ghostRoot and ghostRoot.CFrame or originalCFrame

        local animate = ghostClone:FindFirstChild("Animate")
        if animate then
            animate.Parent = originalCharacter
            animate.Disabled = true
        end

        ghostClone:Destroy()

        for _, sound in pairs(audioCache) do
            if sound then
                sound:Destroy()
            end
        end
        table.clear(audioCache)

        if origRoot then
            origRoot.CFrame = targetCFrame
        end

        local origHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")
preserveGuis()
LocalPlayer.Character = originalCharacter
if origHumanoid then
    Workspace.CurrentCamera.CameraSubject = origHumanoid
end
restoreGuis()

        if animate then
            task.wait(0.1)
            animate.Disabled = false
        end

        originalNeckC0 = nil
    end
end

local function playAudio(animationId)
    if not musicEnabled then return end
    local filePath = "ak/audios/" .. animationId .. ".mp3"
    if isfile(filePath) then
        local sound = loadAudio(animationId)
        if sound then
            sound:Play()
            currentSound = sound
        end
    end
end

local function stopAudio()
    if currentSound then
        currentSound:Stop()
        currentSound = nil
    end
end

local animationButtons = {}
local customButtons = {}

local function stopFakeAnimation()
    animationState.isRunning = false
    stopAudio()
    if ghostClone then
        -- Reset all motor positions
        for motor, orig in pairs(ghostOriginalMotorCFrames) do
            if motor and motor:IsA("Motor6D") then
                motor.C0 = orig.C0
            end
        end

        -- Explicitly reset neck orientation
        local neck = ghostClone:FindFirstChild("Head") and ghostClone:FindFirstChild("Head"):FindFirstChild("Neck")
            or ghostClone:FindFirstChild("Torso") and ghostClone:FindFirstChild("Torso"):FindFirstChild("Neck")
        if neck and originalNeckC0 then
            neck.C0 = originalNeckC0
        end

        -- Re-enable scripts
        for _, script in pairs(ghostClone:GetChildren()) do
            if script:IsA("LocalScript") and not script.Enabled and script ~= originalAnimateScript then
                script.Enabled = true
            end
        end
        if originalAnimateScript then
            originalAnimateScript.Disabled = false
        end
    end
    if animationState.connection then
        animationState.connection:Disconnect()
        animationState.connection = nil
    end

    for animName, buttonData in pairs(animationButtons) do
        buttonData.NameButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    end
    for animName, buttonData in pairs(customButtons) do
        buttonData.NameButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    end
end

local function playFakeAnimation(animationId)
    if not ghostClone then
        warn("Reanimate first!")
        return
    end
    if animationId == "" then return end

    local humanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        warn("No Humanoid found in Clone!")
        return
    end

    local refPart = ghostClone:FindFirstChild("LowerTorso") or ghostClone:FindFirstChild("Torso")
    if not refPart then
        warn("No LowerTorso or Torso found in Clone!")
        return
    end

    if animationState.isRunning then
        stopAudio()
        if animationState.currentId == animationId then
            stopFakeAnimation()
            animationState.currentId = nil
            return
        end
    end

    for animName, buttonData in pairs(animationButtons) do
        buttonData.NameButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    end
    for animName, buttonData in pairs(customButtons) do
        buttonData.NameButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    end

    local animName = nil
    for name, id in pairs(BuiltInAnimationsR15) do
        if tostring(id) == animationId then animName = name break end
    end
    if not animName then
        for name, id in pairs(customAnimations) do
            if tostring(id) == animationId then animName = name break end
        end
    end
    if not animName then
        for name, id in pairs(favoriteAnimations) do
            if tostring(id) == animationId then animName = name break end
        end
    end

    if animName then
        if animationButtons[animName] then
            animationButtons[animName].NameButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
        if customButtons[animName] then
            customButtons[animName].NameButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
    end

    local isMoving = humanoid.MoveDirection.Magnitude > 0 or humanoid:GetState() == Enum.HumanoidStateType.Running

    if originalAnimateScript then
        if isMoving then
            originalAnimateScript.Disabled = true
            for _, animTrack in pairs(humanoid:GetPlayingAnimationTracks()) do
                animTrack:Stop()
            end
        end
    end

    local NeededAssets = animationCache[animationId]
    if not NeededAssets then
        local success, animationAsset = pcall(function()
            return game:GetObjects("rbxassetid://" .. animationId)[1]
        end)
        if not success or not animationAsset then
            warn("Invalid Animation ID: " .. animationId)
            return
        end
        NeededAssets = animationAsset
        animationCache[animationId] = NeededAssets
    end

    NeededAssets.Priority = Enum.AnimationPriority.Action

    animationState.currentId = animationId
    animationState.keyframes = NeededAssets:GetKeyframes()
    animationState.totalDuration = animationState.keyframes[#animationState.keyframes].Time
    animationState.elapsedTime = 0
    animationState.isRunning = true

    playAudio(animationId)

    local character = ghostClone
    local Joints = {
        ["Torso"] = character:WaitForChild("HumanoidRootPart"):FindFirstChild("RootJoint"),
        ["Head"] = character:WaitForChild("Head"):FindFirstChild("Neck"),
        ["LeftUpperArm"] = character:WaitForChild("LeftUpperArm"):FindFirstChild("LeftShoulder"),
        ["RightUpperArm"] = character:WaitForChild("RightUpperArm"):FindFirstChild("RightShoulder"),
        ["LeftUpperLeg"] = character:WaitForChild("LeftUpperLeg"):FindFirstChild("LeftHip"),
        ["RightUpperLeg"] = character:WaitForChild("RightUpperLeg"):FindFirstChild("RightHip"),
        ["LeftFoot"] = character:WaitForChild("LeftFoot"):FindFirstChild("LeftAnkle"),
        ["RightFoot"] = character:WaitForChild("RightFoot"):FindFirstChild("RightAnkle"),
        ["LeftHand"] = character:WaitForChild("LeftHand"):FindFirstChild("LeftWrist"),
        ["RightHand"] = character:WaitForChild("RightHand"):FindFirstChild("RightWrist"),
        ["LeftLowerArm"] = character:WaitForChild("LeftLowerArm"):FindFirstChild("LeftElbow"),
        ["RightLowerArm"] = character:WaitForChild("RightLowerArm"):FindFirstChild("RightElbow"),
        ["LeftLowerLeg"] = character:WaitForChild("LeftLowerLeg"):FindFirstChild("LeftKnee"),
        ["RightLowerLeg"] = character:WaitForChild("RightLowerLeg"):FindFirstChild("RightKnee"),
        ["LowerTorso"] = character:WaitForChild("LowerTorso"):FindFirstChild("Root"),
        ["UpperTorso"] = character:WaitForChild("UpperTorso"):FindFirstChild("Waist"),
    }

    if not animationState.connection then
        for _, script in pairs(ghostClone:GetChildren()) do
            if script:IsA("LocalScript") and script.Enabled and script ~= originalAnimateScript then
                script.Enabled = false
            end
        end

        animationState.connection = RunService.Heartbeat:Connect(function(deltaTime)
            if not animationState.isRunning or not ghostClone then
                stopFakeAnimation()
                return
            end

            if not animationState.keyframes then return end

            animationState.elapsedTime = animationState.elapsedTime + (deltaTime * animationState.speed)
            if animationState.elapsedTime >= animationState.totalDuration then
                animationState.elapsedTime = animationState.elapsedTime % animationState.totalDuration
            end

            local currentFrame, nextFrame
            for i = 1, #animationState.keyframes - 1 do
                if animationState.elapsedTime >= animationState.keyframes[i].Time and animationState.elapsedTime < animationState.keyframes[i + 1].Time then
                    currentFrame = animationState.keyframes[i]
                    nextFrame = animationState.keyframes[i + 1]
                    break
                end
            end
            if not currentFrame then
                currentFrame = animationState.keyframes[#animationState.keyframes]
                nextFrame = animationState.keyframes[1]
            end

            local frameDuration = nextFrame.Time - currentFrame.Time
            local frameTime = animationState.elapsedTime - currentFrame.Time
            local alpha = frameTime / frameDuration
            alpha = math.clamp(alpha, 0, 1)

            for _, pose in pairs(currentFrame:GetDescendants()) do
                local motor = Joints[pose.Name]
                if motor and ghostOriginalMotorCFrames[motor] then
                    local currentCFrame = ghostOriginalMotorCFrames[motor].C0 * pose.CFrame
                    local nextPose = nextFrame:FindFirstChild(pose.Name, true)
                    if nextPose then
                        local nextCFrame = ghostOriginalMotorCFrames[motor].C0 * nextPose.CFrame
                        motor.C0 = currentCFrame:Lerp(nextCFrame, alpha)
                    else
                        motor.C0 = currentCFrame
                    end
                end
            end
        end)
    end
end

local function createAnimationListGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimationListGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Enabled = false

    loadFavorites()
    loadKeybinds()
    loadSpeedKeybinds()

    -- Shadow Container Frame
    local shadowContainer = Instance.new("Frame")
    shadowContainer.Name = "shadowContainer"
    shadowContainer.BackgroundTransparency = 1
    shadowContainer.Size = UDim2.new(0, 332, 0, 535) -- Adjusted height for keybinds
    shadowContainer.Position = UDim2.new(0.7, -166, 0.5, -250)
    shadowContainer.ZIndex = 1
    shadowContainer.Parent = screenGui
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadowContainer

    -- Main Shadow ImageLabel
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "shadow"
    shadow.Image = "rbxassetid://297774371"
    shadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    shadow.ImageTransparency = 0.3
    shadow.SliceCenter = Rect.new(20, 20, 280, 280)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.ZIndex = 1
    shadow.Parent = shadowContainer

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 505) -- Adjusted height to fit keybinds and provide more space
    mainFrame.Position = UDim2.new(0.7, -150, 0.5, -234)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 2
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
    }
    uiGradient.Parent = mainFrame
    mainFrame.Parent = screenGui

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.BorderSizePixel = 0
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    titleLabel.Text = "Animations"
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -110)
    contentFrame.Position = UDim2.new(0, 0, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0.9, 0, 0, 40)
    tabFrame.Position = UDim2.new(0.05, 0, 0, 10)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = contentFrame

    local allTabButton = Instance.new("TextButton")
    allTabButton.Size = UDim2.new(0.31, -5, 0, 35)
    allTabButton.Position = UDim2.new(0, 0, 0, 0)
    allTabButton.Text = "All"
    allTabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    allTabButton.TextSize = 16
    allTabButton.Font = Enum.Font.GothamSemibold
    allTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    allTabButton.BorderSizePixel = 0
    local allTabCorner = Instance.new("UICorner")
    allTabCorner.CornerRadius = UDim.new(0, 8)
    allTabCorner.Parent = allTabButton
    allTabButton.Parent = tabFrame

    local favTabButton = Instance.new("TextButton")
    favTabButton.Size = UDim2.new(0.31, -5, 0, 35)
    favTabButton.Position = UDim2.new(0.34, 5, 0, 0)
    favTabButton.Text = "Favorites"
    favTabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    favTabButton.TextSize = 16
    favTabButton.Font = Enum.Font.GothamSemibold
    favTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    favTabButton.BorderSizePixel = 0
    local favTabCorner = Instance.new("UICorner")
    favTabCorner.CornerRadius = UDim.new(0, 8)
    favTabCorner.Parent = favTabButton
    favTabButton.Parent = tabFrame

    local musicTabButton = Instance.new("TextButton")
    musicTabButton.Size = UDim2.new(0.31, -5, 0, 35)
    musicTabButton.Position = UDim2.new(0.68, 5, 0, 0)
    musicTabButton.Text = "Music"
    musicTabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    musicTabButton.TextSize = 16
    musicTabButton.Font = Enum.Font.GothamSemibold
    musicTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    musicTabButton.BorderSizePixel = 0
    local musicTabCorner = Instance.new("UICorner")
    musicTabCorner.CornerRadius = UDim.new(0, 8)
    musicTabCorner.Parent = musicTabButton
    musicTabButton.Parent = tabFrame

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.9, 0, 0, 35)
    searchBox.Position = UDim2.new(0.05, 0, 0, 55)
    searchBox.PlaceholderText = "Search animations..."
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    searchBox.BorderSizePixel = 0
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = searchBox
    searchBox.Parent = contentFrame

    local allScrollFrame = Instance.new("ScrollingFrame")
    allScrollFrame.Size = UDim2.new(0.9, 0, 0, 235)
    allScrollFrame.Position = UDim2.new(0.05, 0, 0, 100)
    allScrollFrame.BackgroundTransparency = 1
    allScrollFrame.BorderSizePixel = 0
    allScrollFrame.ScrollBarThickness = 4
    allScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    allScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    allScrollFrame.Parent = contentFrame

    local favScrollFrame = Instance.new("ScrollingFrame")
    favScrollFrame.Size = UDim2.new(0.9, 0, 0, 235)
    favScrollFrame.Position = UDim2.new(0.05, 0, 0, 100)
    favScrollFrame.BackgroundTransparency = 1
    favScrollFrame.BorderSizePixel = 0
    favScrollFrame.ScrollBarThickness = 4
    favScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    favScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    favScrollFrame.Visible = false
    favScrollFrame.Parent = contentFrame

    local musicScrollFrame = Instance.new("ScrollingFrame")
    musicScrollFrame.Size = UDim2.new(0.9, 0, 0, 235)
    musicScrollFrame.Position = UDim2.new(0.05, 0, 0, 100)
    musicScrollFrame.BackgroundTransparency = 1
    musicScrollFrame.BorderSizePixel = 0
    musicScrollFrame.ScrollBarThickness = 4
    musicScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    musicScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    musicScrollFrame.Visible = false
    musicScrollFrame.Parent = contentFrame

    local speedSection = Instance.new("Frame")
    speedSection.Name = "SpeedSection"
    speedSection.Size = UDim2.new(0.9, 0, 0, 90) -- Adjusted height for more compact markers
    speedSection.Position = UDim2.new(0.05, 0, 0, 350)
    speedSection.BackgroundTransparency = 1
    speedSection.Parent = contentFrame

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.Text = "Animation Speed: 100%"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.GothamMedium
    speedLabel.BackgroundTransparency = 1
    speedLabel.Parent = speedSection

    local speedSliderBG = Instance.new("Frame")
    speedSliderBG.Size = UDim2.new(1, 0, 0, 6)
    speedSliderBG.Position = UDim2.new(0, 0, 0, 30)
    speedSliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    speedSliderBG.BorderSizePixel = 0
    local speedBGCorner = Instance.new("UICorner")
    speedBGCorner.CornerRadius = UDim.new(1, 0)
    speedBGCorner.Parent = speedSliderBG
    speedSliderBG.Parent = speedSection

    local speedSliderFill = Instance.new("Frame")
    speedSliderFill.Size = UDim2.new(0.25, 0, 1, 0)
    speedSliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    speedSliderFill.BorderSizePixel = 0
    local speedFillCorner = Instance.new("UICorner")
    speedFillCorner.CornerRadius = UDim.new(1, 0)
    speedFillCorner.Parent = speedSliderFill
    speedSliderFill.Parent = speedSliderBG

    local speedSliderHandle = Instance.new("Frame")
    speedSliderHandle.Size = UDim2.new(0, 16, 0, 16)
    speedSliderHandle.Position = UDim2.new(0.25, -8, 0.5, -8)
    speedSliderHandle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    speedSliderHandle.BorderSizePixel = 0
    local speedHandleCorner = Instance.new("UICorner")
    speedHandleCorner.CornerRadius = UDim.new(1, 0)
    speedHandleCorner.Parent = speedSliderHandle
    speedSliderHandle.Parent = speedSliderBG

    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function updateSpeedSlider(value)
        local fillValue = value / 4
        local tween = TweenService:Create(speedSliderFill, tweenInfo, {Size = UDim2.new(math.clamp(fillValue, 0, 1), 0, 1, 0)})
        tween:Play()
        local handleTween = TweenService:Create(speedSliderHandle, tweenInfo, {Position = UDim2.new(math.clamp(fillValue, 0, 1), -8, 0.5, -8)})
        handleTween:Play()
        speedLabel.Text = "Animation Speed: " .. math.floor(value * 100) .. "%"
        animationState.speed = value
    end

    updateSpeedSlider(1)

    local isDraggingSpeed = false
    local function updateSpeedFromPosition(input)
        local sliderPosition = (input.Position.X - speedSliderBG.AbsolutePosition.X) / speedSliderBG.AbsoluteSize.X
        sliderPosition = math.clamp(sliderPosition, 0, 1)
        local newValue = sliderPosition * 4
        updateSpeedSlider(newValue)
    end

    speedSliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = true
            updateSpeedFromPosition(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSpeedFromPosition(input)
        end
    end)

    local keybindInputActive = false
    local currentAnimationForKeybind = nil

    local audioIds = {}
    local function loadAudioIds()
        local url = "https://raw.githubusercontent.com/BloxiAstra/audios/refs/heads/main/ids.json"
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, response)
            if decodeSuccess and data.audio_ids then
                for _, id in ipairs(data.audio_ids) do
                    audioIds[tostring(id)] = true
                end
            else
                warn("Failed to decode ids.json or invalid format: " .. tostring(data))
            end
        else
            warn("Failed to fetch ids.json: " .. tostring(response))
        end
    end
    loadAudioIds()

    local function createAnimationButton(animName, animId, parentFrame)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 45)
        container.BackgroundTransparency = 1
        container.Parent = parentFrame

        local nameButton = Instance.new("TextButton")
        nameButton.Size = UDim2.new(0.55, 0, 0, 35)
        nameButton.Position = UDim2.new(0, 5, 0, 5)
        nameButton.Text = animName
        nameButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        nameButton.TextSize = 14
        nameButton.Font = Enum.Font.SourceSansBold
        nameButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        nameButton.BorderSizePixel = 0
        nameButton.TextXAlignment = Enum.TextXAlignment.Left
        nameButton.TextTruncate = Enum.TextTruncate.AtEnd
        local nameCorner = Instance.new("UICorner")
        nameCorner.CornerRadius = UDim.new(0, 6)
        nameCorner.Parent = nameButton
        nameButton.Parent = container

        nameButton.MouseButton1Click:Connect(function()
            playFakeAnimation(tostring(animId))
            setclipboard(tostring(animId))
        end)

        local favoriteButton = Instance.new("TextButton")
        favoriteButton.Size = UDim2.new(0, 30, 0, 30)
        favoriteButton.Position = UDim2.new(0.57, 5, 0, 7)
        favoriteButton.Text = favoriteAnimations[animName] and "★" or "☆"
        favoriteButton.TextColor3 = Color3.fromRGB(255, 215, 0)
        favoriteButton.TextSize = 18
        favoriteButton.Font = Enum.Font.GothamBold
        favoriteButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        favoriteButton.BackgroundTransparency = 1
        favoriteButton.BorderSizePixel = 0
        local favCorner = Instance.new("UICorner")
        favCorner.CornerRadius = UDim.new(1, 0)
        favCorner.Parent = favoriteButton
        favoriteButton.Parent = container

        local keybindButton = Instance.new("TextButton")
        keybindButton.Size = UDim2.new(0, 40, 0, 30)
        keybindButton.Position = UDim2.new(0.73, 0, 0, 7)
        keybindButton.Text = "Bind"
        keybindButton.TextColor3 = Color3.fromRGB(150, 150, 255)
        keybindButton.TextSize = 12
        keybindButton.Font = Enum.Font.GothamMedium
        keybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        keybindButton.BorderSizePixel = 0
        local keybindCorner = Instance.new("UICorner")
        keybindCorner.CornerRadius = UDim.new(0, 6)
        keybindCorner.Parent = keybindButton
        keybindButton.Parent = container

        local removeBindButton = Instance.new("TextButton")
        removeBindButton.Size = UDim2.new(0, 30, 0, 30)
        removeBindButton.Position = UDim2.new(0.87, 0, 0, 7)
        removeBindButton.Text = "X"
        removeBindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeBindButton.TextSize = 18
        removeBindButton.Font = Enum.Font.GothamBold
        removeBindButton.BackgroundTransparency = 1
        removeBindButton.BorderSizePixel = 0
        removeBindButton.Visible = false
        removeBindButton.Parent = container

        favoriteButton.MouseButton1Click:Connect(function()
            if favoriteAnimations[animName] then
                favoriteAnimations[animName] = nil
                favoriteButton.Text = "☆"
                if favTabButton.BackgroundColor3 == Color3.fromRGB(45, 45, 50) then
                    animationButtons[animName].Container.Visible = false
                    local yOffset = 0
                    for _, buttonData in pairs(animationButtons) do
                        if buttonData.Container.Visible then
                            buttonData.Container.Position = UDim2.new(0, 0, 0, yOffset)
                            yOffset = yOffset + 50
                        end
                    end
                    favScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
                end
            else
                favoriteAnimations[animName] = tostring(animId)
                favoriteButton.Text = "★"
                if favTabButton.BackgroundColor3 == Color3.fromRGB(45, 45, 50) then
                    updateAnimationButtons("favorites", searchBox.Text)
                end
            end
            saveFavorites()
        end)

        keybindButton.MouseButton1Click:Connect(function()
            if keybindInputActive then return end
            keybindInputActive = true
            currentAnimationForKeybind = animName
            keybindButton.Text = "..."

            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                if not keybindInputActive or currentAnimationForKeybind ~= animName then
                    connection:Disconnect()
                    return
                end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    animationKeybinds[animName] = input.KeyCode
                    saveKeybinds()
                    keybindButton.Text = input.KeyCode.Name
                    removeBindButton.Visible = true
                    keybindInputActive = false
                    currentAnimationForKeybind = nil
                    connection:Disconnect()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    keybindButton.Text = "Bind"
                    removeBindButton.Visible = false
                    keybindInputActive = false
                    currentAnimationForKeybind = nil
                    connection:Disconnect()
                end
            end)
        end)

        removeBindButton.MouseButton1Click:Connect(function()
            animationKeybinds[animName] = nil
            saveKeybinds()
            keybindButton.Text = "Bind"
            removeBindButton.Visible = false
        end)
        
        local buttonData = {
            Container = container,
            NameButton = nameButton,
            FavoriteButton = favoriteButton,
            KeybindButton = keybindButton,
            RemoveBindButton = removeBindButton
        }
        
        animationButtons[animName] = buttonData
        return buttonData
    end

    local function updateAnimationButtons(tab, searchText)
        searchText = searchText or ""
        local scrollFrame = (tab == "all") and allScrollFrame or (tab == "favorites") and favScrollFrame or musicScrollFrame
        local animationList = (tab == "all" or tab == "music") and BuiltInAnimationsR15 or favoriteAnimations

        for _, buttonData in pairs(animationButtons) do
            if buttonData.Container then
                buttonData.Container:Destroy()
            end
        end
        animationButtons = {}

        local yOffset = 0
        local lowerSearchText = string.lower(searchText)

        if tab == "all" then
            for _, animName in ipairs(BuiltInAnimationsOrder) do
                local animId = BuiltInAnimationsR15[animName]
                if animId and animName then
                    local lowerAnimName = string.lower(animName)
                    if searchText == "" or string.find(lowerAnimName, lowerSearchText, 1, true) then
                        local buttonData = createAnimationButton(animName, animId, scrollFrame)
                        buttonData.Container.Position = UDim2.new(0, 0, 0, yOffset)
                        local keybind = animationKeybinds[animName]
                        if keybind then
                            buttonData.KeybindButton.Text = keybind.Name
                            buttonData.RemoveBindButton.Visible = true
                        end
                        yOffset = yOffset + 50
                    end
                end
            end
        elseif tab == "favorites" then
            for animName, animId in pairs(animationList) do
                if animName and animId then
                    local lowerAnimName = string.lower(animName)
                    if searchText == "" or string.find(lowerAnimName, lowerSearchText, 1, true) then
                        local buttonData = createAnimationButton(animName, animId, scrollFrame)
                        buttonData.Container.Position = UDim2.new(0, 0, 0, yOffset)
                        local keybind = animationKeybinds[animName]
                        if keybind then
                            buttonData.KeybindButton.Text = keybind.Name
                            buttonData.RemoveBindButton.Visible = true
                        end
                        yOffset = yOffset + 50
                    end
                end
            end
        elseif tab == "music" then
            for _, animName in ipairs(BuiltInAnimationsOrder) do
                local animId = BuiltInAnimationsR15[animName]
                if animId and animName and audioIds[tostring(animId)] then
                    local lowerAnimName = string.lower(animName)
                    if searchText == "" or string.find(lowerAnimName, lowerSearchText, 1, true) then
                        local buttonData = createAnimationButton(animName, animId, scrollFrame)
                        buttonData.Container.Position = UDim2.new(0, 0, 0, yOffset)
                        local keybind = animationKeybinds[animName]
                        if keybind then
                            buttonData.KeybindButton.Text = keybind.Name
                            buttonData.RemoveBindButton.Visible = true
                        end
                        yOffset = yOffset + 50
                    end
                end
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end

    updateAnimationButtons("all", "")

    allTabButton.MouseButton1Click:Connect(function()
        allScrollFrame.Visible = true
        favScrollFrame.Visible = false
        musicScrollFrame.Visible = false
        allTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        favTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        musicTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        updateAnimationButtons("all", searchBox.Text)
    end)

    favTabButton.MouseButton1Click:Connect(function()
        allScrollFrame.Visible = false
        favScrollFrame.Visible = true
        musicScrollFrame.Visible = false
        allTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        favTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        musicTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        updateAnimationButtons("favorites", searchBox.Text)
    end)

    musicTabButton.MouseButton1Click:Connect(function()
        allScrollFrame.Visible = false
        favScrollFrame.Visible = false
        musicScrollFrame.Visible = true
        allTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        favTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        musicTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        updateAnimationButtons("music", searchBox.Text)
    end)

    local searchDebounce = false
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if searchDebounce then return end
        searchDebounce = true
        task.delay(0.2, function()
            if allTabButton.BackgroundColor3 == Color3.fromRGB(45, 45, 50) then
                updateAnimationButtons("all", searchBox.Text)
            elseif favTabButton.BackgroundColor3 == Color3.fromRGB(45, 45, 50) then
                updateAnimationButtons("favorites", searchBox.Text)
            else
                updateAnimationButtons("music", searchBox.Text)
            end
            searchDebounce = false
        end)
    end)

    local keybindInputActive = false
    local currentAnimationForKeybind = nil

    local audioIds = {}
    local function loadAudioIds()
        local url = "https://raw.githubusercontent.com/BloxiAstra/audios/refs/heads/main/ids.json"
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, response)
            if decodeSuccess and data.audio_ids then
                for _, id in ipairs(data.audio_ids) do
                    audioIds[tostring(id)] = true
                end
            else
                warn("Failed to decode ids.json or invalid format: " .. tostring(data))
            end
        else
            warn("Failed to fetch ids.json: " .. tostring(response))
        end
    end
    loadAudioIds()

    local function createMarker(name, initialRatio, defaultKey)
        local markerContainer = Instance.new("Frame")
        markerContainer.Name = name
        markerContainer.Size = UDim2.new(0, 0, 1, 0) -- Width is 0, uses position
        markerContainer.Position = UDim2.new(initialRatio, 0, 0, 0)
        markerContainer.BackgroundTransparency = 1
        markerContainer.ZIndex = 4 -- Above slider fill/handle
        markerContainer.Parent = speedSection

        local marker = Instance.new("Frame")
        marker.Name = "Marker"
        marker.Size = UDim2.new(0, 4, 0, 30) -- Shorter marker line (30px)
        marker.Position = UDim2.new(0, -2, 0, 33) -- Position lower to avoid overlap with slider
        marker.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        marker.BorderSizePixel = 0
        marker.ZIndex = 5
        local markerCorner = Instance.new("UICorner")
        markerCorner.CornerRadius = UDim.new(1, 0)
        markerCorner.Parent = marker
        marker.Parent = markerContainer
        
        local markerStroke = Instance.new("UIStroke")
        markerStroke.Color = Color3.fromRGB(0, 150, 255)
        markerStroke.Thickness = 1
        markerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        markerStroke.Parent = marker
        
        local leftArrow = Instance.new("TextLabel")
        leftArrow.Name = "LeftArrow"
        leftArrow.Text = "←"
        leftArrow.Font = Enum.Font.GothamMedium
        leftArrow.TextSize = 16
        leftArrow.TextColor3 = Color3.fromRGB(180, 180, 200)
        leftArrow.BackgroundTransparency = 1
        leftArrow.TextTransparency = 1 -- Start fully transparent
        leftArrow.Size = UDim2.new(0, 40, 0, 40)
        leftArrow.Position = UDim2.new(0, -40, 0, 33)
        leftArrow.ZIndex = 5
        leftArrow.Parent = markerContainer
        
        local rightArrow = Instance.new("TextLabel")
        rightArrow.Name = "RightArrow"
        rightArrow.Text = "→"
        rightArrow.Font = Enum.Font.GothamMedium
        rightArrow.TextSize = 16
        rightArrow.TextColor3 = Color3.fromRGB(180, 180, 200)
        rightArrow.BackgroundTransparency = 1
        rightArrow.TextTransparency = 1 -- Start fully transparent
        rightArrow.Size = UDim2.new(0, 40, 0, 40)
        rightArrow.Position = UDim2.new(0, 4, 0, 33)
        rightArrow.ZIndex = 5
        rightArrow.Parent = markerContainer
        
        -- Create a larger proximity detection area
        local proximityArea = Instance.new("Frame")
        proximityArea.Name = "ProximityArea"
        proximityArea.Size = UDim2.new(0, 120, 0, 50)
        proximityArea.Position = UDim2.new(0, -60, 0, 23)
        proximityArea.BackgroundTransparency = 1
        proximityArea.ZIndex = 4
        proximityArea.Parent = markerContainer

        local hitbox = Instance.new("Frame") -- Larger hitbox for dragging
        hitbox.Name = "Hitbox"
        hitbox.Size = UDim2.new(0, 84, 0, 40) -- Much wider hitbox
        hitbox.Position = UDim2.new(0, -41, 0, 33) -- Position to cover arrows and marker
        hitbox.BackgroundTransparency = 1 -- Make hitbox invisible
        hitbox.ZIndex = 6
        hitbox.Parent = markerContainer

        local keybind = Instance.new("TextButton")
        keybind.Name = "KeybindButton"
        keybind.Size = UDim2.new(0, 40, 0, 30) -- Larger keybind button
        keybind.Position = UDim2.new(0, -20, 0, 63) -- Position further below marker
        keybind.Text = defaultKey == "" and "key" or defaultKey
        keybind.Font = Enum.Font.GothamMedium
        keybind.TextSize = 14 -- Slightly larger text
        keybind.TextColor3 = Color3.fromRGB(220, 220, 220)
        keybind.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        keybind.AutoButtonColor = false
        keybind.ZIndex = 5
        local keybindCorner = Instance.new("UICorner")
        keybindCorner.CornerRadius = UDim.new(0, 6)
        keybindCorner.Parent = keybind
        keybind.Parent = markerContainer
        
        local keybindStroke = Instance.new("UIStroke")
        keybindStroke.Color = Color3.fromRGB(45, 45, 50)
        keybindStroke.Thickness = 1
        keybindStroke.Parent = keybind

        local removeBindButton = Instance.new("TextButton")
        removeBindButton.Name = "RemoveBindButton"
        removeBindButton.Size = UDim2.new(0, 20, 0, 20) -- Standard size remove button
        removeBindButton.Position = UDim2.new(0, 25, 0, 69) -- Position near keybind button but lower
        removeBindButton.Text = "X"
        removeBindButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        removeBindButton.TextSize = 12
        removeBindButton.Font = Enum.Font.GothamBold
        removeBindButton.BackgroundTransparency = 1
        removeBindButton.TextTransparency = 1 -- Start fully transparent
        removeBindButton.ZIndex = 6
        removeBindButton.Visible = defaultKey ~= "None" and defaultKey ~= "" -- Only show if key is set
        removeBindButton.Parent = markerContainer
        
        -- Create proximity area for the keybind button
        local keybindProximityArea = Instance.new("Frame")
        keybindProximityArea.Name = "KeybindProximityArea"
        keybindProximityArea.Size = UDim2.new(0, 80, 0, 40) -- Area covering keybind button
        keybindProximityArea.Position = UDim2.new(0, -20, 0, 59) -- Position to cover keybind and X button
        keybindProximityArea.BackgroundTransparency = 1
        keybindProximityArea.ZIndex = 4
        keybindProximityArea.Parent = markerContainer

        keybind.MouseEnter:Connect(function()
            TweenService:Create(keybind, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
        end)
        keybind.MouseLeave:Connect(function()
            TweenService:Create(keybind, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
        end)

        removeBindButton.MouseButton1Click:Connect(function()
            speedKeybindData[name].key = ""
            keybind.Text = "key"
            removeBindButton.Visible = false
            saveSpeedKeybinds()
            if speedKeybindFunctions[name] then
                speedKeybindFunctions[name]:Disconnect()
                speedKeybindFunctions[name] = nil
            end
        end)

        return markerContainer
    end

    local slowMarkerRatio = (speedKeybindData.SlowMarker and speedKeybindData.SlowMarker.ratio) or 0.2
    local slowMarkerKey = (speedKeybindData.SlowMarker and speedKeybindData.SlowMarker.key) or ""
    local fastMarkerRatio = (speedKeybindData.FastMarker and speedKeybindData.FastMarker.ratio) or 0.8
    local fastMarkerKey = (speedKeybindData.FastMarker and speedKeybindData.FastMarker.key) or ""

    local SlowMarkerContainer = createMarker("SlowMarker", slowMarkerRatio, slowMarkerKey)
    local FastMarkerContainer = createMarker("FastMarker", fastMarkerRatio, fastMarkerKey)

    local currentDraggingMarker = nil
    local function setupMarker(markerContainer)
        local hitbox = markerContainer:FindFirstChild("Hitbox")
        local keybindButton = markerContainer:FindFirstChild("KeybindButton")
        local removeButton = markerContainer:FindFirstChild("RemoveBindButton")
        local proximityArea = markerContainer:FindFirstChild("ProximityArea")
        local leftArrow = markerContainer:FindFirstChild("LeftArrow")
        local rightArrow = markerContainer:FindFirstChild("RightArrow")
        local keybindProximityArea = markerContainer:FindFirstChild("KeybindProximityArea")
        
        if not hitbox or not keybindButton or not removeButton or
           not proximityArea or not leftArrow or not rightArrow or
           not keybindProximityArea then
            warn("Missing required elements for marker setup")
            return
        end

        local markerName = markerContainer.Name
        local currentKeybindEnum = keybindButton.Text ~= "key" and keybindButton.Text ~= "" and Enum.KeyCode[keybindButton.Text] or nil
        local fadeTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local fadeInTweens = {
            left = TweenService:Create(leftArrow, fadeTweenInfo, {TextTransparency = 0}),
            right = TweenService:Create(rightArrow, fadeTweenInfo, {TextTransparency = 0}),
            removeBtn = removeButton.Visible and TweenService:Create(removeButton, fadeTweenInfo, {TextTransparency = 0}) or nil
        }
        local fadeOutTweens = {
            left = TweenService:Create(leftArrow, fadeTweenInfo, {TextTransparency = 1}),
            right = TweenService:Create(rightArrow, fadeTweenInfo, {TextTransparency = 1}),
            removeBtn = removeButton.Visible and TweenService:Create(removeButton, fadeTweenInfo, {TextTransparency = 1}) or nil
        }
        local arrowsVisible = false
        local removeBtnVisible = false
        
        -- Handle proximity detection for arrows
        local function checkProximity(mousePosition)
            local proximityAreaPos = proximityArea.AbsolutePosition
            local proximityAreaSize = proximityArea.AbsoluteSize
            
            -- Check if mouse is inside proximity area
            local isInside = 
                mousePosition.X >= proximityAreaPos.X and
                mousePosition.X <= proximityAreaPos.X + proximityAreaSize.X and
                mousePosition.Y >= proximityAreaPos.Y and
                mousePosition.Y <= proximityAreaPos.Y + proximityAreaSize.Y
            
            -- Show/hide arrows accordingly
            if isInside and not arrowsVisible and not currentDraggingMarker then
                arrowsVisible = true
                fadeInTweens.left:Play()
                fadeInTweens.right:Play()
            elseif not isInside and arrowsVisible and not currentDraggingMarker then
                arrowsVisible = false
                fadeOutTweens.left:Play()
                fadeOutTweens.right:Play()
            end
        end
        
        -- Show arrows while dragging
        local function showArrowsWhileDragging()
            if currentDraggingMarker == markerContainer and not arrowsVisible then
                arrowsVisible = true
                fadeInTweens.left:Play()
                fadeInTweens.right:Play()
            end
        end
        
        -- Connect proximity checker to mouse movement
        -- Handle proximity detection for remove button
        local function checkKeybindProximity(mousePosition)
            if not removeButton.Visible then return end -- Skip if button shouldn't be visible at all
            
            local proximityAreaPos = keybindProximityArea.AbsolutePosition
            local proximityAreaSize = keybindProximityArea.AbsoluteSize
            
            -- Check if mouse is inside keybind proximity area
            local isInside = 
                mousePosition.X >= proximityAreaPos.X and
                mousePosition.X <= proximityAreaPos.X + proximityAreaSize.X and
                mousePosition.Y >= proximityAreaPos.Y and
                mousePosition.Y <= proximityAreaPos.Y + proximityAreaSize.Y
            
            -- Show/hide remove button accordingly
            if isInside and not removeBtnVisible then
                removeBtnVisible = true
                if fadeInTweens.removeBtn then fadeInTweens.removeBtn:Play() end
            elseif not isInside and removeBtnVisible then
                removeBtnVisible = false
                if fadeOutTweens.removeBtn then fadeOutTweens.removeBtn:Play() end
            end
        end
        
        local proximityConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                checkProximity(input.Position)
                checkKeybindProximity(input.Position)
                showArrowsWhileDragging()
            end
        end)
        
        hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                currentDraggingMarker = markerContainer
                -- Show arrows when dragging starts
                arrowsVisible = true
                fadeInTweens.left:Play()
                fadeInTweens.right:Play()
            end
        end)

        -- Use UserInputService for global mouse up detection
        local mouseUpConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if currentDraggingMarker == markerContainer then
                    currentDraggingMarker = nil
                    saveSpeedKeybinds() -- Save position when drag ends
                    
                    -- Check if mouse is still over proximity area after dragging
                    local mousePos = UserInputService:GetMouseLocation()
                    local proximityAreaPos = proximityArea.AbsolutePosition
                    local proximityAreaSize = proximityArea.AbsoluteSize
                    
                    local isInside = 
                        mousePos.X >= proximityAreaPos.X and
                        mousePos.X <= proximityAreaPos.X + proximityAreaSize.X and
                        mousePos.Y >= proximityAreaPos.Y and
                        mousePos.Y <= proximityAreaPos.Y + proximityAreaSize.Y
                    
                    -- Only hide arrows if mouse is outside proximity area
                    if not isInside then
                        arrowsVisible = false
                        fadeOutTweens.left:Play()
                        fadeOutTweens.right:Play()
                    end
                end
            end
        end)

        -- Use RunService for smooth dragging
        local function updateMarkerFromMouse()
            if currentDraggingMarker == markerContainer then
                local mouse = UserInputService:GetMouseLocation()
                local x = mouse.X - speedSection.AbsolutePosition.X
                local ratio = math.clamp(x / speedSection.AbsoluteSize.X, 0, 1)
                markerContainer.Position = UDim2.new(ratio, 0, 0, 0)
                speedKeybindData[markerName].ratio = ratio -- Update data while dragging
                -- We don't save file on every update to avoid performance issues
            end
        end
        
        local dragUpdateConnection = RunService.Heartbeat:Connect(updateMarkerFromMouse)

        -- Cleanup connections when the GUI is destroyed
        markerContainer.Destroying:Connect(function()
            if mouseUpConnection then mouseUpConnection:Disconnect() end
            if dragUpdateConnection then dragUpdateConnection:Disconnect() end
            if proximityConnection then proximityConnection:Disconnect() end
            if speedKeybindFunctions[markerName] then
                speedKeybindFunctions[markerName]:Disconnect()
                speedKeybindFunctions[markerName] = nil
            end
            -- Cancel any active tweens
            fadeInTweens.left:Cancel()
            fadeInTweens.right:Cancel()
            fadeOutTweens.left:Cancel()
            fadeOutTweens.right:Cancel()
            if fadeInTweens.removeBtn then fadeInTweens.removeBtn:Cancel() end
            if fadeOutTweens.removeBtn then fadeOutTweens.removeBtn:Cancel() end
        end)

        -- Keybind setting logic
        keybindButton.MouseButton1Click:Connect(function()
            if keybindInputActive then return end -- Prevent multiple binds at once
            keybindInputActive = true -- Use the global flag
            currentAnimationForKeybind = nil -- Ensure animation bind isn't active
            keybindButton.Text = "..."

            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if not keybindInputActive then connection:Disconnect() return end -- Check if still binding this

                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local keyCode = input.KeyCode
                    if keyCode == Enum.KeyCode.Escape then -- Allow cancelling with Escape
                       keybindButton.Text = currentKeybindEnum and currentKeybindEnum.Name or "None"
                    else
                        keybindButton.Text = keyCode.Name
                        currentKeybindEnum = keyCode
                        removeButton.Visible = true
                        speedKeybindData[markerName].key = keyCode.Name -- Update data for saving
                        saveSpeedKeybinds()

                        -- Update keybind function
                        if speedKeybindFunctions[markerName] then
                            speedKeybindFunctions[markerName]:Disconnect()
                        end
                        speedKeybindFunctions[markerName] = UserInputService.InputBegan:Connect(function(input)
                           if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKeybindEnum then
                                local ratio = markerContainer.Position.X.Scale
                                updateSpeedSlider(ratio * 4)
                            end
                        end)
                        
                        -- Update remove button and its tweens
                        removeButton.Visible = true
                        removeButton.TextTransparency = removeBtnVisible and 0 or 1 -- Keep current transparency state
                        -- Recreate tweens for the remove button
                        fadeInTweens.removeBtn = TweenService:Create(removeButton, fadeTweenInfo, {TextTransparency = 0})
                        fadeOutTweens.removeBtn = TweenService:Create(removeButton, fadeTweenInfo, {TextTransparency = 1})
                   end
                    keybindInputActive = false
                    connection:Disconnect()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    -- Clicked elsewhere, cancel binding
                    keybindButton.Text = currentKeybindEnum and currentKeybindEnum.Name or "None"
                    keybindInputActive = false
                    connection:Disconnect()
                end
            end)
        end)

        -- Initial keybind setup
        if currentKeybindEnum then
            if speedKeybindFunctions[markerName] then speedKeybindFunctions[markerName]:Disconnect() end
            speedKeybindFunctions[markerName] = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKeybindEnum then
                    local ratio = markerContainer.Position.X.Scale
                    updateSpeedSlider(ratio * 4)
                end
            end)
        end
    end

    setupMarker(SlowMarkerContainer)
    setupMarker(FastMarkerContainer)

    -- Restore dragging functionality
    local dragging = false
    local dragOffset = Vector2.new(0, 0)
    local currentTween = nil
    local shadowTween = nil
    local dragConnection
    local tweenInfoDrag = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local mousePos = UserInputService:GetMouseLocation()
            dragOffset = mousePos - Vector2.new(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y)
            if dragConnection then dragConnection:Disconnect() end
            dragConnection = RunService.RenderStepped:Connect(function()
                if not dragging then return end
                local mousePos = UserInputService:GetMouseLocation()
                local targetPos = UDim2.new(0, mousePos.X - dragOffset.X, 0, mousePos.Y - dragOffset.Y)
                local shadowPos = UDim2.new(0, (mousePos.X - dragOffset.X) - 16, 0, (mousePos.Y - dragOffset.Y) - 16)
                if currentTween then currentTween:Cancel() end
                currentTween = TweenService:Create(mainFrame, tweenInfoDrag, {Position = targetPos})
                currentTween:Play()
                if shadowTween then shadowTween:Cancel() end
                shadowTween = TweenService:Create(shadowContainer, tweenInfoDrag, {Position = shadowPos})
                shadowTween:Play()
            end)
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            if shadowTween then
                shadowTween:Cancel()
                shadowTween = nil
            end
        end
    end)

    return screenGui
end

local function createCustomAnimationsGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomAnimationsGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Enabled = false

    loadCustomAnimations()
    loadKeybinds()

    -- Shadow Container Frame
    local shadowContainer = Instance.new("Frame")
    shadowContainer.Name = "shadowContainer"
    shadowContainer.BackgroundTransparency = 1
    shadowContainer.Size = UDim2.new(0, 332, 0, 482)
    shadowContainer.Position = UDim2.new(1, -336, 1, -486)
    shadowContainer.ZIndex = 1
    shadowContainer.Parent = screenGui
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadowContainer

    -- Main Shadow ImageLabel
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "shadow"
    shadow.Image = "rbxassetid://297774371"
    shadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    shadow.ImageTransparency = 0.3
    shadow.SliceCenter = Rect.new(20, 20, 280, 280)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.ZIndex = 1
    shadow.Parent = shadowContainer

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 450) -- Set to 450 height as requested
    mainFrame.Position = UDim2.new(1, -320, 1, -500)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 2
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
    }
    uiGradient.Parent = mainFrame
    mainFrame.Parent = screenGui

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.BorderSizePixel = 0
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 55))
    }
    titleGradient.Parent = titleBar
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    titleLabel.Text = "Custom Animations"
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 40, 0, 40)
    minimizeButton.Position = UDim2.new(1, -45, 0, 5)
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimizeButton.TextSize = 28
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Parent = titleBar
    
    minimizeButton.MouseEnter:Connect(function()
        minimizeButton.TextColor3 = Color3.fromRGB(0, 191, 255)
    end)
    minimizeButton.MouseLeave:Connect(function()
        minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -110)
    contentFrame.Position = UDim2.new(0, 0, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Redesigned input area for custom animations
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0.9, 0, 0, 45)
    inputFrame.Position = UDim2.new(0.05, 0, 0, 10)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    inputFrame.BorderSizePixel = 0
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    inputFrame.Parent = contentFrame

    -- Animation Name box (smaller, left)
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(0.38, -4, 0, 30)
    nameBox.Position = UDim2.new(0.02, 0, 0.5, -15)
    nameBox.PlaceholderText = "Name"
    nameBox.Text = ""
    nameBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    nameBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    nameBox.TextSize = 14
    nameBox.Font = Enum.Font.Gotham
    nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    nameBox.BorderSizePixel = 0
    nameBox.TextWrapped = true
    nameBox.TextScaled = false
    nameBox.TextSize = 14
    nameBox.Focused:Connect(function()
        nameBox.TextScaled = true
    end)
    nameBox.FocusLost:Connect(function()
        if nameBox.Text == "" then
            nameBox.TextScaled = false
            nameBox.TextSize = 14
        end
    end)
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 6)
    nameCorner.Parent = nameBox
    nameBox.Parent = inputFrame

    -- Animation ID box (smaller, center)
    local idBox = Instance.new("TextBox")
    idBox.Size = UDim2.new(0.38, -4, 0, 30)
    idBox.Position = UDim2.new(0.42, 0, 0.5, -15)
    idBox.PlaceholderText = "ID"
    idBox.Text = ""
    idBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    idBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    idBox.TextSize = 14
    idBox.Font = Enum.Font.Gotham
    idBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    idBox.BorderSizePixel = 0
    idBox.TextWrapped = true
    idBox.TextScaled = false
    idBox.TextSize = 14
    idBox.Focused:Connect(function()
        idBox.TextScaled = true
    end)
    idBox.FocusLost:Connect(function()
        if idBox.Text == "" then
            idBox.TextScaled = false
            idBox.TextSize = 14
        end
    end)
    local idCorner = Instance.new("UICorner")
    idCorner.CornerRadius = UDim.new(0, 6)
    idCorner.Parent = idBox
    idBox.Parent = inputFrame

    -- Add button (right, dark theme, blue accent on hover)
    local addButton = Instance.new("TextButton")
    addButton.Size = UDim2.new(0.18, 0, 0, 30)
    addButton.Position = UDim2.new(0.81, 0, 0.5, -15)
    addButton.Text = "Add"
    addButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    addButton.TextSize = 15
    addButton.Font = Enum.Font.GothamSemibold
    addButton.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    addButton.BorderSizePixel = 0
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 6)
    addCorner.Parent = addButton
    addButton.Parent = inputFrame
    -- Blue accent on hover
    addButton.MouseEnter:Connect(function()
        addButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end)
    addButton.MouseLeave:Connect(function()
        addButton.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    end)

    -- Move search bar up, just below inputFrame
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.9, 0, 0, 30)
    searchBox.Position = UDim2.new(0.05, 0, 0, 60)
    searchBox.PlaceholderText = "Search custom animations..."
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    searchBox.BorderSizePixel = 0
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = searchBox
    searchBox.Parent = contentFrame

    -- Move scrollFrame up, just below searchBox, and make it fill up to the speed bar
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(0.9, 0, 0, 250)
    scrollFrame.Position = UDim2.new(0.05, 0, 0, 100)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentFrame

    local speedSection = Instance.new("Frame")
    speedSection.Name = "SpeedSection" -- Add name for easier referencing
    speedSection.Size = UDim2.new(0.9, 0, 0, 90) -- Increased height for markers
    speedSection.Position = UDim2.new(0.05, 0, 0, 350)
    speedSection.BackgroundTransparency = 1
    speedSection.Parent = contentFrame

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.Text = "Animation Speed: 100%"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.GothamMedium
    speedLabel.BackgroundTransparency = 1
    speedLabel.Parent = speedSection

    local speedSliderBG = Instance.new("Frame")
    speedSliderBG.Size = UDim2.new(1, 0, 0, 6)
    speedSliderBG.Position = UDim2.new(0, 0, 0, 30)
    speedSliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    speedSliderBG.BorderSizePixel = 0
    local speedBGCorner = Instance.new("UICorner")
    speedBGCorner.CornerRadius = UDim.new(1, 0)
    speedBGCorner.Parent = speedSliderBG
    speedSliderBG.Parent = speedSection

    local speedSliderFill = Instance.new("Frame")
    speedSliderFill.Size = UDim2.new(0.25, 0, 1, 0)
    speedSliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    speedSliderFill.BorderSizePixel = 0
    local speedFillCorner = Instance.new("UICorner")
    speedFillCorner.CornerRadius = UDim.new(1, 0)
    speedFillCorner.Parent = speedSliderFill
    speedSliderFill.Parent = speedSliderBG

    local speedSliderHandle = Instance.new("Frame")
    speedSliderHandle.Size = UDim2.new(0, 16, 0, 16)
    speedSliderHandle.Position = UDim2.new(0.25, -8, 0.5, -8)
    speedSliderHandle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    speedSliderHandle.BorderSizePixel = 0
    local speedHandleCorner = Instance.new("UICorner")
    speedHandleCorner.CornerRadius = UDim.new(1, 0)
    speedHandleCorner.Parent = speedSliderHandle
    speedSliderHandle.Parent = speedSliderBG

    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function updateSpeedSlider(value)
        local fillValue = value / 4
        local tween = TweenService:Create(speedSliderFill, tweenInfo, {Size = UDim2.new(math.clamp(fillValue, 0, 1), 0, 1, 0)})
        tween:Play()
        local handleTween = TweenService:Create(speedSliderHandle, tweenInfo, {Position = UDim2.new(math.clamp(fillValue, 0, 1), -8, 0.5, -8)})
        handleTween:Play()
        speedLabel.Text = "Animation Speed: " .. math.floor(value * 100) .. "%"
        animationState.speed = value
    end

    updateSpeedSlider(1)

    local isDraggingSpeed = false
    local function updateSpeedFromPosition(input)
        local sliderPosition = (input.Position.X - speedSliderBG.AbsolutePosition.X) / speedSliderBG.AbsoluteSize.X
        sliderPosition = math.clamp(sliderPosition, 0, 1)
        local newValue = sliderPosition * 4
        updateSpeedSlider(newValue)
    end

    speedSliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = true
            updateSpeedFromPosition(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSpeedFromPosition(input)
        end
    end)

    -- No keybind markers for Custom Animations GUI - speed slider only

    local function createCustomButton(animName, animId)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 45)
        container.BackgroundTransparency = 1
        container.Parent = scrollFrame

        local nameButton = Instance.new("TextButton")
        nameButton.Size = UDim2.new(0.55, 0, 0, 35)
        nameButton.Position = UDim2.new(0, 5, 0, 5)
        nameButton.Text = animName
        nameButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        nameButton.TextSize = 14
        nameButton.Font = Enum.Font.SourceSansBold
        nameButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        nameButton.BorderSizePixel = 0
        nameButton.TextXAlignment = Enum.TextXAlignment.Left
        nameButton.TextTruncate = Enum.TextTruncate.AtEnd
        local nameCorner = Instance.new("UICorner")
        nameCorner.CornerRadius = UDim.new(0, 6)
        nameCorner.Parent = nameButton
        nameButton.Parent = container

        nameButton.MouseButton1Click:Connect(function()
            playFakeAnimation(tostring(animId))
        end)

        local keybindButton = Instance.new("TextButton")
        keybindButton.Size = UDim2.new(0, 40, 0, 30)
        keybindButton.Position = UDim2.new(0.57, 5, 0, 7)
        keybindButton.Text = "Bind"
        keybindButton.TextColor3 = Color3.fromRGB(150, 150, 255)
        keybindButton.TextSize = 12
        keybindButton.Font = Enum.Font.GothamMedium
        keybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        keybindButton.BorderSizePixel = 0
        local keybindCorner = Instance.new("UICorner")
        keybindCorner.CornerRadius = UDim.new(0, 6)
        keybindCorner.Parent = keybindButton
        keybindButton.Parent = container

        local removeBindButton = Instance.new("TextButton")
        removeBindButton.Size = UDim2.new(0, 30, 0, 30)
        removeBindButton.Position = UDim2.new(0.73, 0, 0, 7)
        removeBindButton.Text = "X"
        removeBindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeBindButton.TextSize = 18
        removeBindButton.Font = Enum.Font.GothamBold
        removeBindButton.BackgroundTransparency = 1
        removeBindButton.BorderSizePixel = 0
        removeBindButton.Visible = false
        removeBindButton.Parent = container

        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0, 30, 0, 30)
        deleteButton.Position = UDim2.new(0.87, 0, 0, 7)
        deleteButton.Text = "🗑️"
        deleteButton.TextColor3 = Color3.fromRGB(255, 150, 150)
        deleteButton.TextSize = 16
        deleteButton.Font = Enum.Font.GothamBold
        deleteButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        deleteButton.BorderSizePixel = 0
        local deleteCorner = Instance.new("UICorner")
        deleteCorner.CornerRadius = UDim.new(1, 0)
        deleteCorner.Parent = deleteButton
        deleteButton.Parent = container

        keybindButton.MouseButton1Click:Connect(function()
            if keybindInputActive then return end
            keybindInputActive = true
            currentAnimationForKeybind = animName
            keybindButton.Text = "..."

            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                if not keybindInputActive or currentAnimationForKeybind ~= animName then
                    connection:Disconnect()
                    return
                end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    animationKeybinds[animName] = input.KeyCode
                    saveKeybinds()
                    keybindButton.Text = input.KeyCode.Name
                    removeBindButton.Visible = true
                    keybindInputActive = false
                    currentAnimationForKeybind = nil
                    connection:Disconnect()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    keybindButton.Text = "Bind"
                    removeBindButton.Visible = false
                    keybindInputActive = false
                    currentAnimationForKeybind = nil
                    connection:Disconnect()
                end
            end)
        end)

        removeBindButton.MouseButton1Click:Connect(function()
            animationKeybinds[animName] = nil
            saveKeybinds()
            keybindButton.Text = "Bind"
            removeBindButton.Visible = false
        end)

        deleteButton.MouseButton1Click:Connect(function()
            customAnimations[animName] = nil
            animationKeybinds[animName] = nil
            saveCustomAnimations()
            saveKeybinds()
            if container and container.Parent then
                container:Destroy()
            end
            customButtons[animName] = nil
            local yOffset = 0
            for _, buttonData in pairs(customButtons) do
                if buttonData and buttonData.Container then
                    buttonData.Container.Position = UDim2.new(0, 0, 0, yOffset)
                    yOffset = yOffset + 50
                end
            end
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
        end)

        customButtons[animName] = {
            Container = container,
            NameButton = nameButton,
            KeybindButton = keybindButton,
            RemoveBindButton = removeBindButton,
            DeleteButton = deleteButton
        }
    end

    local function updateCustomButtons(searchText)
        searchText = searchText or ""
        for _, buttonData in pairs(customButtons) do
            if buttonData and buttonData.Container then
                buttonData.Container:Destroy()
            end
        end
        customButtons = {}

        local sortedNames = {}
        for animName in pairs(customAnimations) do
            table.insert(sortedNames, animName)
        end
        table.sort(sortedNames)

        local yOffset = 0
        local lowerSearchText = string.lower(searchText)

        for _, animName in ipairs(sortedNames) do
            local animId = customAnimations[animName]
            if searchText == "" or string.find(string.lower(animName), lowerSearchText, 1, true) then
                createCustomButton(animName, animId)
                if customButtons[animName] then
                    customButtons[animName].Container.Position = UDim2.new(0, 0, 0, yOffset)
                    local keybind = animationKeybinds[animName]
                    if keybind then
                        customButtons[animName].KeybindButton.Text = keybind.Name
                        customButtons[animName].RemoveBindButton.Visible = true
                    else
                        customButtons[animName].KeybindButton.Text = "Bind"
                        customButtons[animName].RemoveBindButton.Visible = false
                    end
                    yOffset = yOffset + 50
                end
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end

    addButton.MouseButton1Click:Connect(function()
        local animName = nameBox.Text
        local animId = idBox.Text
        if animName ~= "" and animId ~= "" then
            if not customAnimations[animName] then
                customAnimations[animName] = animId
                saveCustomAnimations()
                preloadAnimations({[animName] = animId})
                updateCustomButtons(searchBox.Text)
                nameBox.Text = ""
                idBox.Text = ""
            else
                warn("Animation name already exists!")
            end
        else
            warn("Please enter both a name and an ID!")
        end
    end)

    local searchDebounce = false
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if searchDebounce then return end
        searchDebounce = true
        task.delay(0.2, function()
            updateCustomButtons(searchBox.Text)
            searchDebounce = false
        end)
    end)

    updateCustomButtons()

    local originalGuiHeight = mainFrame.Size.Y.Offset
    local minimizedGuiHeight = titleBar.Size.Y.Offset
    local minimized = false
    local tweenInfoFade = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenInfoSize = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local originalTransparencies = {}
    local originalShadowSize = shadowContainer.Size
    local originalShadowPosition = shadowContainer.Position

for _, child in pairs(contentFrame:GetDescendants()) do
    if child:IsA("GuiObject") and not originalTransparencies[child] then
        originalTransparencies[child] = {
            BackgroundTransparency = child.BackgroundTransparency,
            TextTransparency = (child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox")) and child.TextTransparency or nil
        }
    end
end

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        minimizeButton.Text = "+"
        contentFrame.Visible = false

        -- Fade out UI elements
        for _, child in pairs(contentFrame:GetDescendants()) do
            if child:IsA("GuiObject") then
                TweenService:Create(child, tweenInfoFade, {BackgroundTransparency = 1}):Play()
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    TweenService:Create(child, tweenInfoFade, {TextTransparency = 1}):Play()
                end
            end
        end
        
        -- Fade out shadow completely
        TweenService:Create(shadow, tweenInfoFade, {
            ImageTransparency = 1 -- Completely transparent
        }):Play()
        
        -- Resize main frame
        local sizeTween = TweenService:Create(
            mainFrame,
            tweenInfoSize,
            {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, minimizedGuiHeight)}
        )
        sizeTween:Play()
    else
        minimizeButton.Text = "−"
        contentFrame.Visible = true
        
        -- Keep shadow invisible during resize
        shadow.ImageTransparency = 1
        
        -- Resize main frame
        local sizeTween = TweenService:Create(
            mainFrame,
            tweenInfoSize,
            {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, originalGuiHeight)}
        )
        sizeTween:Play()
        
        -- Update shadow container position to be behind the current mainFrame position
        shadowContainer.Size = originalShadowSize
        -- Update position in completed handler to ensure it's correctly positioned

        sizeTween.Completed:Connect(function()
            -- Restore UI element transparencies
            for _, child in pairs(contentFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    local orig = originalTransparencies[child]
                    if orig then
                        if orig.BackgroundTransparency ~= nil then
                            TweenService:Create(child, tweenInfoFade, {BackgroundTransparency = orig.BackgroundTransparency}):Play()
                        end
                        if orig.TextTransparency ~= nil then
                            TweenService:Create(child, tweenInfoFade, {TextTransparency = orig.TextTransparency}):Play()
                        end
                        if orig.Position then
                            TweenService:Create(child, tweenInfoFade, {Position = orig.Position}):Play()
                        end
                    end
                end
            end
            
            -- Position shadow container before fading in
            -- Calculate shadow position relative to mainFrame's current position
            shadowContainer.Size = UDim2.new(0, mainFrame.Size.X.Offset + 32, 0, mainFrame.Size.Y.Offset + 32)
            shadowContainer.Position = UDim2.new(0, mainFrame.AbsolutePosition.X - 16, 0, mainFrame.AbsolutePosition.Y - 16)
            
            -- Fade in shadow with a slight delay after GUI is maximized
            task.delay(0.1, function()
                TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    ImageTransparency = 0.3
                }):Play()
            end)
        end)
    end
end)

    local dragging = false
    local dragOffset = Vector2.new(0, 0)
    local currentTween = nil
    local shadowTween = nil
    local dragConnection
    local tweenInfoDrag = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local mousePos = UserInputService:GetMouseLocation()
            dragOffset = mousePos - Vector2.new(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y)
            if dragConnection then dragConnection:Disconnect() end
            dragConnection = RunService.RenderStepped:Connect(function()
                if not dragging then return end
                local mousePos = UserInputService:GetMouseLocation()
                local targetPos = UDim2.new(0, mousePos.X - dragOffset.X, 0, mousePos.Y - dragOffset.Y)
                local shadowPos = UDim2.new(0, (mousePos.X - dragOffset.X) - 16, 0, (mousePos.Y - dragOffset.Y) - 16)
                if currentTween then currentTween:Cancel() end
                currentTween = TweenService:Create(mainFrame, tweenInfoDrag, {Position = targetPos})
                currentTween:Play()
                if shadowTween then shadowTween:Cancel() end
                shadowTween = TweenService:Create(shadowContainer, tweenInfoDrag, {Position = shadowPos})
                shadowTween:Play()
            end)
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            if shadowTween then
                shadowTween:Cancel()
                shadowTween = nil
            end
        end
    end)

    return screenGui
end

local function createDraggableGui(getGhostEnabled, toggleGhost)
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local LocalPlayer = game.Players.LocalPlayer

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnhancedGhostGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Enabled = false

    local shadowContainer = Instance.new("Frame")
    shadowContainer.Name = "shadowContainer"
    shadowContainer.BackgroundTransparency = 1
    shadowContainer.Size = UDim2.new(0, 352, 0, 291)
    shadowContainer.Position = UDim2.new(0.5, -176, 0.5, -146)
    shadowContainer.ZIndex = 1
    shadowContainer.Parent = screenGui
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadowContainer

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "shadow"
    shadow.Image = "rbxassetid://297774371"
    shadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    shadow.ImageTransparency = 0.3
    shadow.SliceCenter = Rect.new(20, 20, 280, 280)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.ZIndex = 1
    shadow.Parent = shadowContainer

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0
    mainFrame.ZIndex = 2
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
    }
    uiGradient.Parent = mainFrame
    mainFrame.Parent = screenGui

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.BorderSizePixel = 0
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    titleBar.Parent = mainFrame

    -- Main title: ak.gg (replaces 'Reanimation')
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    titleLabel.Text = "AK Reanim"
    titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.RichText = true
    titleLabel.Parent = titleBar

    -- Per-letter light blue wave animation (looping)
    local baseText = "AK Reanim"
    local baseColor = Color3.fromRGB(200, 160, 255) -- light purple
local waveColor = Color3.fromRGB(255, 105, 180) -- pink

    local waveLength = 2
    local waveSpeed = 4
    local t = 0
    RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        local rich = ""
        for i = 1, #baseText do
            local c = baseText:sub(i, i)
            local phase = (t * waveSpeed - i / waveLength)
            local fade = 0.5 + 0.5 * math.sin(phase)
            local r = math.floor((baseColor.R + (waveColor.R - baseColor.R) * fade) * 255)
            local g = math.floor((baseColor.G + (waveColor.G - baseColor.G) * fade) * 255)
            local b = math.floor((baseColor.B + (waveColor.B - baseColor.B) * fade) * 255)
            local color = string.format("rgb(%d,%d,%d)", r, g, b)
            rich = rich .. string.format('<font color="%s"><b>%s</b></font>', color, c)
        end
        titleLabel.Text = rich
    end)

    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 40, 0, 40)
    minimizeButton.Position = UDim2.new(1, -90, 0, 5)
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimizeButton.TextSize = 28
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Parent = titleBar

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 28
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BackgroundTransparency = 1
    closeButton.Parent = titleBar

    minimizeButton.MouseEnter:Connect(function()
        minimizeButton.TextColor3 = Color3.fromRGB(0, 191, 255)
    end)
    minimizeButton.MouseLeave:Connect(function()
        minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    closeButton.MouseEnter:Connect(function()
        closeButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    end)
    closeButton.MouseLeave:Connect(function()
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(0.9, 0, 1, -60)
    contentFrame.Position = UDim2.new(0.05, 0, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local animationListGui = createAnimationListGui()
    local customAnimationsGui = createCustomAnimationsGui()

    local lastToggleTime = 0
    local COOLDOWN_DURATION = 3
    local fadeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

    local function createToggleSwitch(name, position, enabled, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 40)
        container.Position = position
        container.BackgroundTransparency = 1
        container.Parent = contentFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 255)
        label.TextSize = 16
        label.Font = Enum.Font.GothamBold
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local toggleFrame = Instance.new("TextButton")
        toggleFrame.Size = UDim2.new(0, 60, 0, 28)
        toggleFrame.Position = UDim2.new(0.82, 0, 0.5, -14)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Text = ""
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 14)
        toggleCorner.Parent = toggleFrame
        toggleFrame.Parent = container

        local toggleFill = Instance.new("Frame")
        toggleFill.Size = UDim2.new(1, 0, 1, 0)
        toggleFill.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        toggleFill.BorderSizePixel = 0
        toggleFill.BackgroundTransparency = enabled and 0 or 1
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 14)
        fillCorner.Parent = toggleFill
        toggleFill.Parent = toggleFrame

        local toggleButton = Instance.new("Frame")
        toggleButton.Size = UDim2.new(0, 24, 0, 24)
        toggleButton.Position = UDim2.new(enabled and 0.5 or 0, 2, 0.5, -12)
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.BorderSizePixel = 0
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 12)
        buttonCorner.Parent = toggleButton
        local buttonGradient = Instance.new("UIGradient")
        buttonGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 240, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 255))
        }
        buttonGradient.Parent = toggleButton
        toggleButton.Parent = toggleFrame

        local cooldownLabel = Instance.new("TextLabel")
        cooldownLabel.Size = UDim2.new(0, 50, 0, 20)
        cooldownLabel.Position = UDim2.new(0.60, 0, 0.5, -10)
        cooldownLabel.Text = ""
        cooldownLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
        cooldownLabel.TextSize = 16
        cooldownLabel.Font = Enum.Font.GothamMedium
        cooldownLabel.BackgroundTransparency = 1
        cooldownLabel.TextTransparency = 1
        cooldownLabel.TextXAlignment = Enum.TextXAlignment.Right
        cooldownLabel.Parent = container

        local toggleState = enabled
        local tweenInfoToggle = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local fadeTweenInfoShort = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        local function updateToggle(state)
            local currentTime = tick()
            if name == "Enable Reanimation" and currentTime - lastToggleTime < COOLDOWN_DURATION then
                return
            end

            toggleState = state
            local targetButtonPos = state and UDim2.new(0.5, 2, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
            local targetFillTransparency = state and 0 or 1

            TweenService:Create(toggleFill, tweenInfoToggle, {BackgroundTransparency = targetFillTransparency}):Play()
            TweenService:Create(toggleButton, tweenInfoToggle, {Position = targetButtonPos}):Play()

            if callback and name == "Enable Reanimation" then
                lastToggleTime = currentTime
                toggleFill.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
                toggleFrame.AutoButtonColor = false

                local remainingTime = COOLDOWN_DURATION
                local lastNumber = nil

                local function updateCooldownDisplay()
                    local currentNumber = math.ceil(remainingTime)
                    if currentNumber ~= lastNumber then
                        TweenService:Create(cooldownLabel, fadeTweenInfoShort, {TextTransparency = 1}):Play()
                        task.delay(0.3, function()
                            if currentNumber > 0 then
                                cooldownLabel.Text = tostring(currentNumber)
                                TweenService:Create(cooldownLabel, fadeTweenInfoShort, {TextTransparency = 0}):Play()
                            else
                                cooldownLabel.Text = ""
                            end
                        end)
                        lastNumber = currentNumber
                    end
                end

                updateCooldownDisplay()

                local connection
                connection = RunService.Heartbeat:Connect(function(deltaTime)
                    remainingTime = remainingTime - deltaTime
                    updateCooldownDisplay()

                    if remainingTime <= 0 then
                        toggleFill.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
                        toggleFrame.AutoButtonColor = true
                        TweenService:Create(cooldownLabel, fadeTweenInfoShort, {TextTransparency = 1}):Play()
                        task.delay(0.3, function()
                            cooldownLabel.Text = ""
                        end)
                        connection:Disconnect()
                    end
                end)

                callback(state)
            elseif callback then
                callback(state)
            end
        end

        toggleFrame.MouseButton1Click:Connect(function()
            updateToggle(not toggleState)
        end)

        return {
            Container = container,
            ToggleFrame = toggleFrame,
            ToggleButton = toggleButton,
            ToggleFill = toggleFill,
            UpdateToggle = updateToggle,
            GetState = function() return toggleState end
        }
    end

    local reanimationToggle = createToggleSwitch("Enable Reanimation", UDim2.new(0, 0, 0, 0), false, function(state)
        toggleGhost(state)
    end)

    local animationListToggle = createToggleSwitch("Animation List", UDim2.new(0, 0, 0, 50), false, function(state)
        animationListGui.Enabled = state
    end)

    local customAnimationsToggle = createToggleSwitch("Custom Animations", UDim2.new(0, 0, 0, 100), false, function(state)
        customAnimationsGui.Enabled = state
    end)

    local musicToggle = createToggleSwitch("Music", UDim2.new(0, 0, 0, 150), true, function(state)
        musicEnabled = state
    end)

    local originalGuiHeight = mainFrame.Size.Y.Offset
    local minimizedGuiHeight = titleBar.Size.Y.Offset
    local minimized = false
    local tweenInfoFade = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenInfoSize = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    -- Function to update toggle visuals
    local function updateToggleVisuals(toggle)
        local state = toggle.GetState()
        toggle.ToggleFill.BackgroundTransparency = state and 0 or 1
        toggle.ToggleButton.Position = state and UDim2.new(0.5, 2, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
    end

    local toggles = {reanimationToggle, animationListToggle, customAnimationsToggle, musicToggle}

    local originalTransparencies = {}
    for _, child in pairs(contentFrame:GetDescendants()) do
        if child:IsA("GuiObject") then
            originalTransparencies[child] = {
                BackgroundTransparency = child.BackgroundTransparency,
                TextTransparency = (child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox")) and child.TextTransparency or nil
            }
        end
    end

    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized

        if minimized then
            minimizeButton.Text = "+"
            contentFrame.Visible = false

            for _, child in pairs(contentFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    TweenService:Create(child, tweenInfoFade, {BackgroundTransparency = 1}):Play()
                    if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                        TweenService:Create(child, tweenInfoFade, {TextTransparency = 1}):Play()
                    end
                end
            end

            local sizeTween = TweenService:Create(
                mainFrame,
                tweenInfoSize,
                {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, minimizedGuiHeight)}
            )
            sizeTween:Play()
            TweenService:Create(shadowContainer, tweenInfoSize, {
                Size = UDim2.new(0, 332, 0, minimizedGuiHeight + 12),
                Position = UDim2.new(0, mainFrame.Position.X.Offset - 6, 0, mainFrame.Position.Y.Offset - 3)
            }):Play()
            TweenService:Create(shadow, tweenInfoSize, {
                ImageTransparency = 0.25
            }):Play()
        else
            minimizeButton.Text = "−"
            contentFrame.Visible = true

            local sizeTween = TweenService:Create(
                mainFrame,
                tweenInfoSize,
                {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, originalGuiHeight)}
            )
            sizeTween:Play()
            TweenService:Create(shadowContainer, tweenInfoSize, {
                Size = UDim2.new(0, 352, 0, originalGuiHeight + 31),
                Position = UDim2.new(0, mainFrame.Position.X.Offset - 16, 0, mainFrame.Position.Y.Offset - 16)
            }):Play()
            TweenService:Create(shadow, tweenInfoSize, {
                ImageTransparency = 0.3
            }):Play()

            sizeTween.Completed:Connect(function()
                for _, child in pairs(contentFrame:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        local orig = originalTransparencies[child]
                        if orig then
                            TweenService:Create(child, tweenInfoFade, {BackgroundTransparency = orig.BackgroundTransparency}):Play()
                            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                                TweenService:Create(child, tweenInfoFade, {TextTransparency = orig.TextTransparency}):Play()
                            end
                        end
                    end
                end

                -- Update toggle visuals immediately after maximize
                for _, toggle in ipairs(toggles) do
                    updateToggleVisuals(toggle)
                end

                -- Schedule one-time update 0.1 seconds after maximize
                spawn(function()
                    wait(0.3)
                    if screenGui.Parent and not minimized then
                        for _, toggle in ipairs(toggles) do
                            updateToggleVisuals(toggle)
                        end
                    end
                end)
            end)
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        -- Stop any ongoing animation and audio
        stopFakeAnimation()

        -- Disable ghost mode if enabled
        if ghostEnabled then
            setGhostEnabled(false)
        end

        -- Disconnect all connections
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        if animationState.connection then
            animationState.connection:Disconnect()
            animationState.connection = nil
        end

        -- Destroy all GUIs
        if screenGui then
            screenGui:Destroy()
        end
        if animationListGui then
            animationListGui:Destroy()
        end
        if customAnimationsGui then
            customAnimationsGui:Destroy()
        end

        -- Clear caches
        table.clear(animationCache)
        table.clear(audioCache)
        table.clear(favoriteAnimations)
        table.clear(animationKeybinds)
        table.clear(customAnimations)
        table.clear(ghostOriginalSizes)
        table.clear(ghostOriginalMotorCFrames)
        table.clear(activeNotifications)
        table.clear(preservedGuis)
        table.clear(animationButtons)
        table.clear(customButtons)

        -- Restore head movement if modified
        restoreHeadMovement()

        -- Reset variables
        ghostEnabled = false
        originalCharacter = nil
        ghostClone = nil
        originalCFrame = nil
        originalAnimateScript = nil
        ghostOriginalHipHeight = nil
        currentSound = nil
        musicEnabled = true
        hasFetchedAnimations = false
        hasCreatedFavoritesFile = false
        hasCreatedKeybindsFile = false
        hasCreatedCustomAnimationsFile = false
        originalNeckC0 = nil
        animationState = {
            isRunning = false,
            currentId = nil,
            keyframes = nil,
            totalDuration = 0,
            elapsedTime = 0,
            speed = 1,
            connection = nil
        }

        -- Clear any remaining sounds
        for _, sound in pairs(audioCache) do
            if sound then
                sound:Destroy()
            end
        end

        -- Reset/kill character
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0  -- Kill the character
            end
        end
    end)

    local dragging = false
    local dragOffset = Vector2.new(0, 0)
    local currentTween = nil
    local shadowTween = nil
    local dragConnection
    local trailConnection
    local tweenInfoDrag = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tweenInfoTrail = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    local function createTrailShadow(parent, position, size)
        local trailContainer = Instance.new("Frame")
        trailContainer.BackgroundTransparency = 1
        trailContainer.Size = size
        trailContainer.Position = position
        trailContainer.ZIndex = 0
        trailContainer.Parent = parent
        local trailCorner = Instance.new("UICorner")
        trailCorner.CornerRadius = UDim.new(0, 12)
        trailCorner.Parent = trailContainer

        local trailShadow = Instance.new("ImageLabel")
        trailShadow.Image = "rbxassetid://297774371"
        trailShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
        trailShadow.ImageTransparency = 0.85
        trailShadow.SliceCenter = Rect.new(20, 20, 280, 280)
        trailShadow.BackgroundTransparency = 1
        trailShadow.Size = UDim2.new(1, 0, 1, 0)
        trailShadow.Position = UDim2.new(0, 0, 0, 0)
        trailShadow.ZIndex = 0
        trailShadow.Parent = trailContainer

        local fadeTween = TweenService:Create(trailShadow, tweenInfoTrail, {ImageTransparency = 1})
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            trailContainer:Destroy()
        end)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local mousePos = UserInputService:GetMouseLocation()
            dragOffset = mousePos - Vector2.new(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y)
            if dragConnection then dragConnection:Disconnect() end
            if trailConnection then trailConnection:Disconnect() end

            dragConnection = RunService.RenderStepped:Connect(function()
                if not dragging then return end
                local mousePos = UserInputService:GetMouseLocation()
                local targetPos = UDim2.new(0, mousePos.X - dragOffset.X, 0, mousePos.Y - dragOffset.Y)
                local shadowOffsetX = minimized and 6 or 16
                local shadowOffsetY = minimized and 3 or 16
                local shadowPos = UDim2.new(0, mousePos.X - dragOffset.X - shadowOffsetX, 0, mousePos.Y - dragOffset.Y - shadowOffsetY)
                if currentTween then currentTween:Cancel() end
                currentTween = TweenService:Create(mainFrame, tweenInfoDrag, {Position = targetPos})
                currentTween:Play()
                if shadowTween then shadowTween:Cancel() end
                shadowTween = TweenService:Create(shadowContainer, tweenInfoDrag, {Position = shadowPos})
                shadowTween:Play()
            end)

            trailConnection = RunService.Heartbeat:Connect(function()
                if not dragging then return end
                local shadowSize = UDim2.new(0, 352, 0, originalGuiHeight + 31)
                local shadowPos = shadowContainer.Position
                if minimized then
                    shadowSize = UDim2.new(0, 332, 0, minimizedGuiHeight + 12)
                end
                createTrailShadow(screenGui, shadowPos, shadowSize)
                task.wait(0.05) -- Reduced delay for smoother trails
            end)
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if dragConnection then
                dragConnection:Disconnect()
            end
            if trailConnection then
                trailConnection:Disconnect()
                trailConnection = nil
            end
            -- Ensure final shadow position aligns with GUI
            local shadowSize = UDim2.new(0, 352, 0, originalGuiHeight + 31)
            local shadowPos = UDim2.new(0, mainFrame.Position.X.Offset - 16, 0, mainFrame.Position.Y.Offset - 16)
            local shadowTransparency = 0.3
            if minimized then
                shadowSize = UDim2.new(0, 332, 0, minimizedGuiHeight + 12)
                shadowPos = UDim2.new(0, mainFrame.Position.X.Offset - 6, 0, mainFrame.Position.Y.Offset - 3)
                shadowTransparency = 0.25
            end
            shadowContainer.Size = shadowSize
            shadowContainer.Position = shadowPos
            shadow.ImageTransparency = shadowTransparency
        end
    end)

    return screenGui, mainFrame, shadowContainer
end

-- Hide the main GUI initially
-- mainGui.Enabled = false

-- Fade-in function for the GUI
local function fadeInGui(gui, duration, mainFrame, shadowContainer, finalMainPos, finalShadowPos)
    -- Store original transparencies for restoration
    local originalTransparencies = {}
    -- Set initial transparency for all GUI elements
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("GuiObject") then
            originalTransparencies[obj] = {
                BackgroundTransparency = obj.BackgroundTransparency,
                TextTransparency = (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.TextTransparency or nil,
                ImageTransparency = obj:IsA("ImageLabel") and obj.ImageTransparency or nil
            }
            -- Set to fully transparent initially
            obj.BackgroundTransparency = 1
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                obj.TextTransparency = 1
            end
            if obj:IsA("ImageLabel") then
                obj.ImageTransparency = 1
            end
        end
    end
    -- Set initial positions to the right of the screen for slide-in
    if mainFrame and finalMainPos then
        mainFrame.Position = UDim2.new(1, 100, finalMainPos.Y.Scale, finalMainPos.Y.Offset)
    end
    if shadowContainer and finalShadowPos then
        shadowContainer.Position = UDim2.new(1, 100, finalShadowPos.Y.Scale, finalShadowPos.Y.Offset)
    end
    -- Enable the GUI
    gui.Enabled = true
    -- Create tweens to fade in
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    for obj, orig in pairs(originalTransparencies) do
        if obj:IsA("GuiObject") then
            local tweenProps = {}
            if orig.BackgroundTransparency ~= nil then
                tweenProps.BackgroundTransparency = orig.BackgroundTransparency
            end
            if orig.TextTransparency ~= nil then
                tweenProps.TextTransparency = orig.TextTransparency
            end
            if orig.ImageTransparency ~= nil then
                tweenProps.ImageTransparency = orig.ImageTransparency
            end
            game:GetService("TweenService"):Create(obj, tweenInfo, tweenProps):Play()
        end
    end
    -- Tween the mainFrame and shadowContainer positions to their final positions
    if mainFrame and finalMainPos then
        game:GetService("TweenService"):Create(mainFrame, tweenInfo, {Position = finalMainPos}):Play()
    end
    if shadowContainer and finalShadowPos then
        game:GetService("TweenService"):Create(shadowContainer, tweenInfo, {Position = finalShadowPos}):Play()
    end
end

-- Modified preloading to fade in GUI after loading
local function initializePreloadingAndShowGui()
    initializePreloading() -- Your existing preloading function
    -- Create the GUIs after preloading
    local animationListGui = createAnimationListGui()
    local customAnimationsGui = createCustomAnimationsGui()
    local mainGui, mainFrame, shadowContainer = createDraggableGui(
        function() return ghostEnabled end,
        setGhostEnabled
    )
    -- Start with GUI disabled and fade it in with slide from top
    mainGui.Enabled = false
    -- Get intended final positions
    local finalMainPos = UDim2.new(0.5, -160, 0.5, -130)
    local finalShadowPos = UDim2.new(0.5, -176, 0.5, -146)
    fadeInGui(mainGui, 0.5, mainFrame, shadowContainer, finalMainPos, finalShadowPos)
end

task.spawn(initializePreloadingAndShowGui)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for animName, keyCode in pairs(animationKeybinds) do
            if input.KeyCode == keyCode then
                local animId = BuiltInAnimationsR15[animName] or customAnimations[animName] or favoriteAnimations[animName]
                if animId then
                    playFakeAnimation(tostring(animId))
                end
                return
            end
        end
    end
end)
