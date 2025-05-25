------------------------------
-- Fixed Script for Better Chat --
------------------------------

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local filename = "saved_position.txt"

------------------------------
-- Teleport to Saved Position
------------------------------
local function LoadPositionFromFile()
    if isfile(filename) then
        local positionData = readfile(filename)
        local decodedData = HttpService:JSONDecode(positionData)
        if decodedData.x and decodedData.y and decodedData.z then
            return Vector3.new(decodedData.x, decodedData.y, decodedData.z)
        else
            print("[ERROR] Invalid position data in file.")
        end
    else
        print("[INFO] Position file not found.")
    end
    return nil
end

local function TeleportToSavedPosition()
    local savedPosition = LoadPositionFromFile()
    if savedPosition then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = character.HumanoidRootPart
            humanoidRootPart.CFrame = CFrame.new(savedPosition)
            print("[INFO] Teleported to saved position:", savedPosition)
            delfile(filename)
            print("[INFO] Position file deleted after teleport.")
        else
            print("[ERROR] Character not found to teleport.")
        end
    else
        print("[INFO] No saved position found, skipping teleport.")
    end
end

if isfile(filename) then
    TeleportToSavedPosition()
else
    print("[INFO] No saved position file on script execution.")
end

------------------------------
-- Load External Command Scripts
------------------------------
loadstring(game:HttpGet("https://ichfickdeinemutta.pages.dev/allcmdss.lua"))()
loadstring(game:HttpGet("https://ichfickdeinemutta.pages.dev/loadcmds.lua"))()


------------------------------
-- Helper: Get Current Chat Input Box
------------------------------
local function getChatInputBox()
    local chatService = game:GetService("TextChatService")
    local chatInput = nil
    if chatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local coreGui = game:GetService("CoreGui")
        if coreGui:FindFirstChild("ExperienceChat") and coreGui.ExperienceChat:FindFirstChild("appLayout") then
            local chatBar = coreGui.ExperienceChat.appLayout:FindFirstChild("chatInputBar")
            if chatBar 
            and chatBar:FindFirstChild("Background") 
            and chatBar.Background:FindFirstChild("Container") 
            and chatBar.Background.Container:FindFirstChild("TextContainer") 
            and chatBar.Background.Container.TextContainer:FindFirstChild("TextBoxContainer") 
            and chatBar.Background.Container.TextContainer.TextBoxContainer:FindFirstChild("TextBox") then
                chatInput = chatBar.Background.Container.TextContainer.TextBoxContainer.TextBox
            end
        end
    else
        local playerGui = player:WaitForChild("PlayerGui")
        local chatFrame = playerGui:FindFirstChild("Chat")
        if chatFrame 
        and chatFrame:FindFirstChild("Frame") 
        and chatFrame.Frame:FindFirstChild("ChatBarParentFrame") 
        and chatFrame.Frame.ChatBarParentFrame:FindFirstChild("Frame") 
        and chatFrame.Frame.ChatBarParentFrame.Frame:FindFirstChild("BoxFrame") 
        and chatFrame.Frame.ChatBarParentFrame.Frame.BoxFrame:FindFirstChild("Frame") 
        and chatFrame.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame:FindFirstChild("ChatBar") then
            chatInput = chatFrame.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
        end
    end
    return chatInput
end

------------------------------
-- Command Handler Attachment
------------------------------
local function attachCommandHandler()
    local chatInput = getChatInputBox()
    if not chatInput then return end

    -- Avoid reattaching if already bound
    if chatInput:FindFirstChild("CommandHandlerAttached") then
        return
    end

    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local message = chatInput.Text
            local command = message:lower()
            chatInput.Text = "" -- Clear the input box

            -- Check for commands defined in _G.cmds and execute them
            if _G.cmds then
                for cmdname, link in pairs(_G.cmds) do
                    if command == cmdname then
                        loadstring(game:HttpGet(link))()
                        break
                    end
                end
            end

            -- Send the original message to chat
            if game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") then
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
            else
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(message)
            end

            ------------------------------
            -- Command Specific Handling
            ------------------------------
            if command:sub(1, 6) == "!copy " then
                local target = command:sub(7)
                for _, v in pairs(Players:GetChildren()) do
                    if v.Name:lower():find(target:lower()) or v.DisplayName:lower():find(target:lower()) then
                        game:GetService("ReplicatedStorage").ModifyUserEvent:FireServer(v.Name)
                    end
                end

            elseif command == "!copynearest" then
                local closestPlayer
                local closestDistance = math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = p
                        end
                    end
                end
                if closestPlayer then
                    game:GetService("ReplicatedStorage").ModifyUserEvent:FireServer(closestPlayer.Name)
                end

            elseif command == "!rj" then
                print("[INFO] Rejoin command received.")
                if isfile(filename) then
                    TeleportToSavedPosition()
                else
                    print("[INFO] No saved position file on script execution.")
                end
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local pos = character.HumanoidRootPart.Position
                    local posData = HttpService:JSONEncode({x = pos.X, y = pos.Y, z = pos.Z})
                    writefile(filename, posData)
                    print("[INFO] Position saved to file:", posData)
                else
                    print("[ERROR] HumanoidRootPart not found.")
                    return
                end
                local TeleportService = game:GetService("TeleportService")
                local gameId = game.PlaceId
                local jobId = game.JobId
                print("[INFO] Rejoining game...")
                TeleportService:TeleportToPlaceInstance(gameId, jobId, player)

            elseif command == "!copy all" then
                for _, p in pairs(Players:GetPlayers()) do
                    game:GetService("ReplicatedStorage").ModifyUserEvent:FireServer(p.Name)
                end

            elseif command:sub(1,3) == "!to" then
                local targetPlayer = command:sub(5)
                for _, v in pairs(Players:GetChildren()) do
                    if v.Name:lower():find(targetPlayer) or v.DisplayName:lower():find(targetPlayer) then
                        player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
                        break
                    end
                end

            elseif command == "!scan map" then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Reminder",
                    Text = "Make sure you own admin gamepass, use !unscan map to stop scanning map.",
                    Duration = 3
                })
                local args = { [1] = "Wand" }
                game:GetService("ReplicatedStorage"):WaitForChild("ToolEvent"):FireServer(unpack(args))
                wait(2.5)
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    tool.Parent = player.Character
                end
                getgenv().scanningmap = true
                local startPos = -134
                local nd = 265
                while getgenv().scanningmap do
                    wait()
                    startPos = startPos + 2
                    if startPos >= nd then startPos = -134 end
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(startPos, 3, 264)
                    wait(0.07)
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(startPos, 3, -120)
                end

            elseif command == "!unscan map" then
                getgenv().scanningmap = false
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Reminder",
                    Text = "Stopped Scanning map.",
                    Duration = 3
                })

            -- (The rest of your commands continue below in similar fashion)
            -- Due to the length of your script, each elseif branch is preserved as in your original code.
            -- Your commands for !steal, !r15, !r6, !stand, !stand2, !switchtarget, !unstand,
            -- !invistroll, !bodycopy, !unbodycopy, !uninvistroll, and !uncopy follow here.
            --
            -- [Your original command handling logic remains unchanged except that it is now within
            -- the FocusLost event of the dynamically attached chat input.]

            elseif command:sub(1,6) == "!steal" then
                local tplayer = command:sub(8)
                local function findPlayer(partialName)
                    partialName = partialName:lower()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p.Name:lower():find(partialName) or (p.DisplayName and p.DisplayName:lower():find(partialName)) then
                            return p.UserId
                        end
                    end
                    return nil
                end
                local function findPlayer2(partialName)
                    partialName = partialName:lower()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p.Name:lower():find(partialName) or (p.DisplayName and p.DisplayName:lower():find(partialName)) then
                            return p
                        end
                    end
                    return nil
                end
                local realt = findPlayer(tplayer)
                local realb = findPlayer2(tplayer)
                local AES = game:GetService("AvatarEditorService")
                local deadpos
                local function ExecuteRigChange(targetDescription, rigType)
                    local plrLocal = player
                    pcall(function()
                        local char = plrLocal.Character or plrLocal.CharacterAdded:Wait()
                        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                        if not humanoid then
                            warn("No humanoid found for LocalPlayer.")
                            return
                        end
                        local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
                        local posToRestore
                        if hrp then
                            posToRestore = hrp.CFrame
                        end
                        local desc = targetDescription:Clone()
                        if not desc then
                            warn("Invalid target HumanoidDescription provided.")
                            return
                        end
                        AES:PromptSaveAvatar(desc, Enum.HumanoidRigType[rigType])
                        if AES.PromptSaveAvatarCompleted:Wait() == Enum.AvatarPromptResult.Success then
                            humanoid.Health = 0
                            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                            local newChar = plrLocal.CharacterAdded:Wait()
                            local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)
                            if newHRP and posToRestore then
                                newHRP.CFrame = posToRestore
                            end
                        end
                    end)
                end
                if not realb then
                    warn("Player '" .. tplayer .. "' not found.")
                    return
                end
                AES:PromptAllowInventoryReadAccess()
                wait(0.5)
                local result = AES.PromptAllowInventoryReadAccessCompleted:Wait()
                if result == Enum.AvatarPromptResult.Success then
                    local targetHumDesc = Players:GetHumanoidDescriptionFromUserId(realt)
                    local success, errorMessage = pcall(function()
                        local localPlayer = player
                        if localPlayer and realb and realb.Character and realb.Character.Humanoid then
                            local targetHumanoid = realb.Character.Humanoid
                            local targetRigType = targetHumanoid.RigType
                            local targetRigTypeString = targetRigType == Enum.HumanoidRigType.R6 and "R6" or "R15"
                            print("Setting LocalPlayer's avatar and rig type to match " .. realb.Name .. " (" .. targetRigTypeString .. ")")
                            ExecuteRigChange(targetHumDesc, targetRigTypeString)
                        else
                            warn("Could not get character or humanoid for LocalPlayer or Target Player.")
                        end
                    end)
                    if success then
                        local localPlayer = player
                        if localPlayer and localPlayer.Character and localPlayer.Character.Humanoid then
                            local localHumanoid = localPlayer.Character.Humanoid
                            localPlayer.Character.Humanoid.Health = 0
                            local function log(character)
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    deadpos = character.HumanoidRootPart.CFrame
                                end
                            end
                            localHumanoid.Died:Connect(function() log(localPlayer.Character) end)
                            localPlayer.CharacterAdded:Connect(function(char)
                                local newHumanoid = char:WaitForChild("Humanoid", 3)
                                if newHumanoid then
                                    newHumanoid.Died:Connect(function() log(char) end)
                                end
                                local newHRP = char:WaitForChild("HumanoidRootPart", 3)
                                if newHRP and deadpos then
                                    newHRP.CFrame = deadpos
                                end
                            end)
                        else
                            warn("Could not find character/humanoid to kill and respawn for LocalPlayer.")
                        end
                    else
                        warn("Error during PromptSaveAvatar for LocalPlayer, copying avatar of " .. (realb and realb.Name or "unknown player") .. ": " .. (errorMessage or "Unknown error"))
                    end
                end

            elseif command:sub(1,4) == "!r15" then
                local AvatarEditor = game:GetService("AvatarEditorService")
                local plrLocal = player
                local function ExecuteRigChange(rigType)
                    pcall(function()
                        local char = plrLocal.Character or plrLocal.CharacterAdded:Wait()
                        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                        if not humanoid then return end
                        local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
                        local pos = hrp and hrp.CFrame
                        local desc = humanoid.HumanoidDescription and humanoid.HumanoidDescription:Clone()
                        if not desc then return end
                        AvatarEditor:PromptSaveAvatar(desc, Enum.HumanoidRigType[rigType])
                        if AvatarEditor.PromptSaveAvatarCompleted:Wait() == Enum.AvatarPromptResult.Success then
                            humanoid.Health = 0
                            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                            local newChar = plrLocal.CharacterAdded:Wait()
                            local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)
                            if newHRP and pos then
                                newHRP.CFrame = pos
                            end
                        end
                    end)
                end
                local char = plrLocal.Character or plrLocal.CharacterAdded:Wait()
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.RigType then
                    if humanoid.RigType == Enum.HumanoidRigType.R15 then
                        print("Current rig is R15, attempting to switch to R6.")
                        ExecuteRigChange("R6")
                    else
                        print("Current rig is R6 (or other), attempting to switch to R15.")
                        ExecuteRigChange("R15")
                    end
                end

            elseif command:sub(1,3) == "!r6" then
                local AvatarEditor = game:GetService("AvatarEditorService")
                local plrLocal = player
                local function ExecuteRigChange(rigType)
                    pcall(function()
                        local char = plrLocal.Character or plrLocal.CharacterAdded:Wait()
                        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                        if not humanoid then return end
                        local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
                        local pos = hrp and hrp.CFrame
                        local desc = humanoid.HumanoidDescription and humanoid.HumanoidDescription:Clone()
                        if not desc then return end
                        AvatarEditor:PromptSaveAvatar(desc, Enum.HumanoidRigType[rigType])
                        if AvatarEditor.PromptSaveAvatarCompleted:Wait() == Enum.AvatarPromptResult.Success then
                            humanoid.Health = 0
                            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                            local newChar = plrLocal.CharacterAdded:Wait()
                            local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)
                            if newHRP and pos then
                                newHRP.CFrame = pos
                            end
                        end
                    end)
                end
                local char = plrLocal.Character or plrLocal.CharacterAdded:Wait()
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.RigType then
                    if humanoid.RigType == Enum.HumanoidRigType.R6 then
                        ExecuteRigChange("R15")
                    else
                        ExecuteRigChange("R6")
                    end
                end

            elseif command:sub(1,6) == "!stand" then
                local function GetRoot(char)
                    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                end
                local function findPlayer(partialName)
                    partialName = partialName:lower()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p.Name:lower():find(partialName) or (p.DisplayName and p.DisplayName:lower():find(partialName)) then
                            return p
                        end
                    end
                    return nil
                end
                local function PlayAnim(id, time, speed)
                    pcall(function()
                        player.Character.Animate.Disabled = false
                        local hum = player.Character.Humanoid
                        local animtrack = hum:GetPlayingAnimationTracks()
                        for _, track in pairs(animtrack) do
                            track:Stop()
                        end
                        player.Character.Animate.Disabled = true
                        local Anim = Instance.new("Animation")
                        Anim.AnimationId = "rbxassetid://" .. id
                        local loadAnim = hum:LoadAnimation(Anim)
                        loadAnim:Play()
                        loadAnim.TimePosition = time
                        loadAnim:AdjustSpeed(speed)
                        loadAnim.Stopped:Connect(function()
                            player.Character.Animate.Disabled = false
                            for _, track in pairs(animtrack) do
                                track:Stop()
                            end
                        end)
                    end)
                end
                local function startStand(target, animId)
                    if not target or not target.Character then return end
                    isStanding = true
                    STANDRUNNING = true
                    PlayAnim(animId, 4, 0)
                    spawn(function()
                        while isStanding do
                            pcall(function()
                                if not GetRoot(player.Character) then return end
                                if not GetRoot(player.Character):FindFirstChild("BreakVelocity") then
                                    local TempV = Instance.new("BodyVelocity")
                                    TempV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    TempV.Velocity = Vector3.zero
                                    TempV.Parent = GetRoot(player.Character)
                                    if not isStanding then
                                        TempV:Destroy()
                                    end
                                end
                                if not target.Character then
                                    stopStand()
                                    return
                                end
                                local root = GetRoot(target.Character)
                                if not root then return end
                            end)
                            task.wait()
                        end
                    end)
                    spawn(function()
                        local root = GetRoot(target.Character)
                        while STANDRUNNING do
                            wait(0.06)
                            workspace.Gravity = 0
                            player.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(-2, 3, 3)
                            player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
                local targetName = command:sub(8)
                local target = findPlayer(targetName)
                if target then
                    startStand(target, 13823324057)
                end

            elseif command:sub(1,7) == "!stand2" then
                local function GetRoot(char)
                    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                end
                local function findPlayer(partialName)
                    partialName = partialName:lower()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p.Name:lower():find(partialName) or (p.DisplayName and p.DisplayName:lower():find(partialName)) then
                            return p
                        end
                    end
                    return nil
                end
                local function PlayAnim(id, time, speed)
                    pcall(function()
                        player.Character.Animate.Disabled = false
                        local hum = player.Character.Humanoid
                        local animtrack = hum:GetPlayingAnimationTracks()
                        for _, track in pairs(animtrack) do
                            track:Stop()
                        end
                        player.Character.Animate.Disabled = true
                        local Anim = Instance.new("Animation")
                        Anim.AnimationId = "rbxassetid://" .. id
                        local loadAnim = hum:LoadAnimation(Anim)
                        loadAnim:Play()
                        loadAnim.TimePosition = time
                        loadAnim:AdjustSpeed(speed)
                        loadAnim.Stopped:Connect(function()
                            player.Character.Animate.Disabled = false
                            for _, track in pairs(animtrack) do
                                track:Stop()
                            end
                        end)
                    end)
                end
                local function startStand(target, animId)
                    if not target or not target.Character then return end
                    isStanding = true
                    STANDRUNNING = true
                    PlayAnim(animId, 4, 0)
                    spawn(function()
                        while isStanding do
                            pcall(function()
                                if not GetRoot(player.Character) then return end
                                if not GetRoot(player.Character):FindFirstChild("BreakVelocity") then
                                    local TempV = Instance.new("BodyVelocity")
                                    TempV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    TempV.Velocity = Vector3.zero
                                    TempV.Parent = GetRoot(player.Character)
                                    if not isStanding then
                                        TempV:Destroy()
                                    end
                                end
                                if not target.Character then
                                    stopStand()
                                    return
                                end
                                local root = GetRoot(target.Character)
                                if not root then return end
                            end)
                            task.wait()
                        end
                    end)
                    spawn(function()
                        local root = GetRoot(target.Character)
                        while STANDRUNNING do
                            wait(0.06)
                            workspace.Gravity = 0
                            player.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(-2, 3, 3)
                            player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        end
                        workspace.Gravity = 192
                    end)
                end
                local targetName = command:sub(9)
                local target = findPlayer(targetName)
                if target then
                    startStand(target, 12507085924)
                end

            elseif command:sub(1,13) == "!switchtarget" then
                local function GetRoot(char)
                    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                end
                local function findPlayer(partialName)
                    partialName = partialName:lower()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p.Name:lower():find(partialName) or (p.DisplayName and p.DisplayName:lower():find(partialName)) then
                            return p
                        end
                    end
                    return nil
                end
                local function startStand(target, animId)
                    if not target or not target.Character then return end
                    isStanding = true
                    STANDRUNNING = true
                    PlayAnim(animId, 4, 0)
                    spawn(function()
                        while isStanding do
                            pcall(function()
                                if not GetRoot(player.Character) then return end
                                if not GetRoot(player.Character):FindFirstChild("BreakVelocity") then
                                    local TempV = Instance.new("BodyVelocity")
                                    TempV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    TempV.Velocity = Vector3.zero
                                    TempV.Parent = GetRoot(player.Character)
                                    if not isStanding then
                                        TempV:Destroy()
                                    end
                                end
                                if not target.Character then
                                    stopStand()
                                    return
                                end
                                local root = GetRoot(target.Character)
                                if not root then return end
                            end)
                            task.wait()
                        end
                    end)
                    spawn(function()
                        local root = GetRoot(target.Character)
                        while STANDRUNNING do
                            wait(0.06)
                            workspace.Gravity = 0
                            player.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(-2, 3, 3)
                            player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        end
                        workspace.Gravity = 192
                    end)
                end
                local newTargetName = command:sub(15)
                local newTarget = findPlayer(newTargetName)
                if newTarget then
                    stopStand()
                    startStand(newTarget, 13823324057)
                end

            elseif command == "!unstand" then
                local function GetRoot(char)
                    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                end
                local function stopStand()
                    isStanding = false
                    STANDRUNNING = false
                    RunService.Heartbeat:Wait()
                    workspace.Gravity = 192
                    if player.Character and GetRoot(player.Character):FindFirstChild("BreakVelocity") then
                        GetRoot(player.Character).BreakVelocity:Destroy()
                    end
                    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
                    if hum then
                        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                            track:Stop()
                        end
                    end
                    if player.Character and player.Character:FindFirstChild("Animate") then
                        player.Character.Animate.Disabled = false
                    end
                end
                wait(0.25)
                stopStand()

            elseif command:sub(1,11) == "!invistroll" then
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                ActiveTrolls = ActiveTrolls or {}
                local function findPlayer(partialName)
                    partialName = partialName:lower()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Name:lower():match(partialName) or (p.DisplayName and p.DisplayName:lower():match(partialName)) then
                            return p
                        end
                    end
                    return nil
                end
                local function UpdateBody(playerObj, target)
                    local character = playerObj.Character
                    local targetChar = target.Character
                    if not character or not targetChar then return end
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChild("Humanoid")
                    if not humanoidRootPart or not targetHRP or not humanoid then return end
                    humanoid.WalkSpeed = 16
                    humanoidRootPart.CFrame = targetHRP.CFrame
                    local bodyParts = {"UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
                    for _, partName in ipairs(bodyParts) do
                        local part = character:FindFirstChild(partName)
                        if part then
                            part.CFrame = part.CFrame * CFrame.new(0, 10, 0)
                            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                    local head = character:FindFirstChild("Head")
                    if head then
                        head.CFrame = head.CFrame
                    end
                end
                local targetName = command:sub(13)
                local target = findPlayer(targetName)
                if not target then return end
                if ActiveTrolls[player.UserId] then
                    ActiveTrolls[player.UserId]:Disconnect()
                end
                ReplicatedStorage.RagdollEvent:FireServer()
                ActiveTrolls[player.UserId] = RunService.Heartbeat:Connect(function()
                    UpdateBody(player, target)
                end)

            elseif command:sub(1,9) == "!bodycopy" then
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local offsetMagnitude = 5
                local bodyParts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart"}
                local function activateBodyCopy(target)
                    local char = player.Character
                    if not char then return end
                    workspace.Gravity = 0
                    for _, partName in ipairs(bodyParts) do
                        local part = char:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    ReplicatedStorage.RagdollEvent:FireServer()
                    if target.Character and target.Character:FindFirstChild("Humanoid") then
                        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
                    end
                    getgenv().Running = true
                    local updateConnection
                    updateConnection = RunService.RenderStepped:Connect(function()
                        for _, seat in pairs(workspace:GetDescendants()) do
                            if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
                                seat.Disabled = true
                                seat.CanCollide = false
                            end
                        end
                        if not getgenv().Running then updateConnection:Disconnect() end
                        local localChar = player.Character
                        local targetChar = target.Character
                        if localChar and targetChar then
                            local offset = Vector3.new(0, 0, 0)
                            if targetChar:FindFirstChild("HumanoidRootPart") then
                                offset = targetChar.HumanoidRootPart.CFrame.RightVector * (-offsetMagnitude)
                            end
                            for _, partName in ipairs(bodyParts) do
                                local localPart = localChar:FindFirstChild(partName)
                                local targetPart = targetChar:FindFirstChild(partName)
                                if localPart and targetPart and localPart:IsA("BasePart") and targetPart:IsA("BasePart") then
                                    localPart.CFrame = targetPart.CFrame + offset
                                end
                            end
                        end
                    end)
                    print("BodyCopy aktiviert!")
                end
                local function findPlayer(partialName)
                    partialName = partialName:lower()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Name:lower():match(partialName) or (p.DisplayName and p.DisplayName:lower():match(partialName)) then
                            return p
                        end
                    end
                    return nil
                end
                local targetName = command:sub(11)
                local target = findPlayer(targetName)
                if not target then
                    warn("Kein gültiges Ziel gefunden!")
                    return
                end
                activateBodyCopy(target)

            elseif command:sub(1,11) == "!unbodycopy" then
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                getgenv().Running = false
                workspace.Gravity = 196.2
                local char = player.Character
                ReplicatedStorage.UnragdollEvent:FireServer()
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
                        seat.Disabled = false
                        seat.CanCollide = true
                    end
                end
                if char and char:FindFirstChild("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = char.Humanoid
                end
                print("BodyCopy deaktiviert!")

            elseif command:sub(1,13) == "!uninvistroll" then
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                ReplicatedStorage.UnragdollEvent:FireServer()
                if ActiveTrolls[player.UserId] then
                    ActiveTrolls[player.UserId]:Disconnect()
                    ActiveTrolls[player.UserId] = nil
                    local character = player.Character
                    if character then
                        for _, partName in ipairs({"UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
                            local part = character:FindFirstChild(partName)
                            if part then
                                part.CFrame = part.CFrame * CFrame.new(0, -10, 0)
                            end
                        end
                    end
                    ReplicatedStorage.UnragdollEvent:FireServer()
                elseif command == "!uncopy" then
                    isCopying = false
                    isCopyingNearest = false
                    if isCopying or isCopyingNearest then
                        print("Stopped all copying activities.")
                    else
                        warn("Not currently copying usernames or avatars.")
                    end
                end
            end
        end
    end)
    local marker = Instance.new("BoolValue")
    marker.Name = "CommandHandlerAttached"
    marker.Parent = chatInput
end

------------------------------
-- Continuously (Re)Attach the Command Handler
------------------------------
RunService.Heartbeat:Connect(function()
    attachCommandHandler()
end)
