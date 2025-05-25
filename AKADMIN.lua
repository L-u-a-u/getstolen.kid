_G.__AK_ADMIN_EXECUTED = _G.__AK_ADMIN_EXECUTED or false
if _G.__AK_ADMIN_EXECUTED then
    warn("AK Admin has already been executed. Preventing duplicate execution.")
    return
end
_G.__AK_ADMIN_EXECUTED = true

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local setclipboard = setclipboard or function() warn("Clipboard function not available") end

local function tween(inst, props, time)
    return TweenService:Create(inst, TweenInfo.new(time or 0.5, Enum.EasingStyle.Quart), props):Play()
end

local function new(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do
        inst[i] = v
    end
    return inst
end

local function createSound(id, volume)
    local sound = new("Sound", {
        SoundId = "rbxassetid://" .. id,
        Volume = volume or 0.5,
        Parent = CoreGui
    })
    return sound
end

local sounds = {
    slideDown = createSound("12222200", 0.15),
    success = createSound("2027986581", 0.25),
    failure = createSound("7356986865", 0.25),
    slideUp = createSound("12222200", 0.15),
    buttonClick = createSound("7545317681", 0.2)
}

local function verifyKey(inputKey)
    -- Trim whitespace from the key
    local trimmedKey = inputKey:match("^%s*(.-)%s*$")
    
    local success, keyData
    success = pcall(function()
        local rawData = game:HttpGet("https://ichfickdeinemutta.pages.dev/key.json")
        if rawData then
            keyData = HttpService:JSONDecode(rawData)
        end
    end)
    if success and keyData and keyData.key then
        return trimmedKey == keyData.key
    else
        return true
    end
end

local function setupKeyStorage()
    if not isfolder then return end
    pcall(function()
        if not isfolder("AKKey") then
            makefolder("AKKey")
        end
    end)
end

local function saveKeyToFile(key)
    if not writefile then return end
    pcall(function()
        writefile("AKKey/key.txt", key)
    end)
end

local function getKeyFromFile()
    if not readfile or not isfile then return nil end
    local success, content = pcall(function()
        if isfile("AKKey/key.txt") then
            return readfile("AKKey/key.txt")
        end
        return nil
    end)
    if success then
        return content
    end
    return nil
end

local function createGUI()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "PremiumAuthGui" then
            v:Destroy()
        end
    end

    local gui = new("ScreenGui", {
        Name = "PremiumAuthGui",
        IgnoreGuiInset = true,
        DisplayOrder = 999,
        Parent = CoreGui
    })

    local main = new("Frame", {
        Size = UDim2.new(0.4, 0, 0, 50),
        Position = UDim2.new(0.5, 0, -0.2, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        BackgroundTransparency = 0,
        Parent = gui
    })

    new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })
    new("UIStroke", {
        Color = Color3.fromRGB(80, 80, 90),
        Thickness = 2,
        Transparency = 0,
        Parent = main
    })

    local player = Players.LocalPlayer
    local userId = player and player.UserId or 1

    local profilePic = new("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", userId),
        Parent = main
    })
    
    local AKProfilePic = profilePic

    local title = new("TextLabel", {
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0.5, 20, 0, 3),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Text = "Welcome to AK ADMIN",
        TextTransparency = 1,
        Parent = main
    })

    local status = new("TextLabel", {
        Size = UDim2.new(1, -70, 0, 15),
        Position = UDim2.new(0.5, 20, 0, 25),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 16,
        Font = Enum.Font.GothamMedium,
        Text = "Welcome to AK ADMIN",
        TextTransparency = 1,
        Parent = main
    })

    local progressBg = new("Frame", {
        Size = UDim2.new(0.8, 0, 0, 3),
        Position = UDim2.new(0.5, 20, 1, -5),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(45, 45, 50),
        BackgroundTransparency = 0,
        Parent = main
    })

    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressBg })

    local progress = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(180, 160, 255),
        BackgroundTransparency = 0,
        Parent = progressBg
    })

    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progress })

    local keyContainer = new("Frame", {
        Size = UDim2.new(1, -20, 0, 90),
        Position = UDim2.new(0.5, 0, 0, 55),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = main
    })

    local keyInput = new("TextBox", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(50, 50, 55),
        PlaceholderText = "Enter key...",
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamMedium,
        ClearTextOnFocus = false,
        Parent = keyContainer
    })

    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = keyInput })
    new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = keyInput })

    local submitButton = new("TextButton", {
        Size = UDim2.new(0.48, 0, 0, 30),
        Position = UDim2.new(0.25, 0, 0, 40),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(180, 120, 220),
        Text = "Submit",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = keyContainer
    })

    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = submitButton })

    local getKeyButton = new("TextButton", {
        Size = UDim2.new(0.48, 0, 0, 30),
        Position = UDim2.new(0.75, 0, 0, 40),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(80, 80, 90),
        Text = "Join discord",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = keyContainer
    })

    new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = getKeyButton })

    return gui, main, title, status, progress, keyContainer, keyInput, submitButton, getKeyButton, AKProfilePic
end

local AKAdminVars = {}
AKAdminVars.FirstScriptLoaded = false
AKAdminVars.FirstScriptGuiReady = false
AKAdminVars.AKAdminLoaded = false

local loadStringsFinished = false
local gui, main, title, status, progress, keyContainer, keyInput, submitButton, getKeyButton, profilePic
local loadStringInitiated = false

local function executeScripts()
    if loadStringInitiated then return end
    loadStringInitiated = true
    AKAdminVars.FirstScriptGuiReady = true

    task.spawn(function()
        if AKAdminVars.AKAdminLoaded then
            return
        end
        
        AKAdminVars.AKAdminLoaded = true
        
        local success, mainScript = pcall(function()
            return game:HttpGet("https://angelical.me/scripts/ak.lua")
        end)
        
        if success and mainScript then
            pcall(function()
                loadstring(mainScript)()
            end)
        else
            warn("Failed to load main script")
        end
        
        task.wait(2)
        if AKAdminVars.signalLoadstringsComplete then
            AKAdminVars.signalLoadstringsComplete()
        end
    end)
    
    task.delay(5, function()
        if not loadStringsFinished then
            if AKAdminVars.signalLoadstringsComplete then
                AKAdminVars.signalLoadstringsComplete()
            end
        end
    end)
end

AKAdminVars.signalLoadstringsComplete = function()
    if loadStringsFinished then return end
    loadStringsFinished = true

    if status then
        status.Text = "AK ADMIN loaded!"
        sounds.success:Play()
        tween(status, { TextColor3 = Color3.fromRGB(100, 255, 150) }, 0.4)
        tween(progress, { BackgroundColor3 = Color3.fromRGB(100, 255, 150) }, 0.4)
        
        task.wait(4)
        
        sounds.slideUp:Play()
        tween(main, { Position = UDim2.new(0.5, 0, -0.2, 0) }, 1)
        task.wait(1.1)
        
        if gui then
            gui:Destroy()
            gui = nil
        end
    end
end

local function hasNoKeyGamepass()
    local player = Players.LocalPlayer
    if not player then
        if status then status.Text = "LocalPlayer not found" end
        return false
    end
    
    local userId = player.UserId
    if not userId then
        if status then status.Text = "UserId not found" end
        return false
    end
    
    local gamepassIds = {
        1226253039,
    }
    
    for _, gamepassId in ipairs(gamepassIds) do
        local success, ownsPass = pcall(function()
            return MarketplaceService:UserOwnsGamePassAsync(userId, gamepassId)
        end)
        
        if success then
            if ownsPass then
                if status then status.Text = "Premium gamepass detected" end
                return true
            end
        else
            if status then status.Text = "Failed to check gamepass" end
        end
    end
    
    return false
end

local function hasNoKeyAsset()
    local player = Players.LocalPlayer
    if not player then
        return false
    end
    
    local userId = player.UserId
    if not userId then
        return false
    end
    
    local success, response = pcall(function()
        return game:HttpGet("https://inventory.roblox.com/v1/users/" .. userId .. "/items/Asset/75660325080290")
    end)
    
    if success and response then
        local decoded = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decoded then
            local data = HttpService:JSONDecode(response)
            if data and data.data and type(data.data) == "table" and #data.data > 0 then
                for _, item in ipairs(data.data) do
                    if item.id == 75660325080290 then
                        if status then status.Text = "No key asset detected" end
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

local function isWhitelistedUser()
    local player = Players.LocalPlayer
    if not player then
        return false
    end
    
    local whitelistedUsers = {
        "YournothimbuddyXD",
        "328ml",
        "ImOn_ValveIndex",
        "GYATT_DAMN1",
        "BloxiAstra"
    }
    
    local playerName = player.Name
    for _, whitelistedName in ipairs(whitelistedUsers) do
        if playerName == whitelistedName then
            if status then status.Text = "Whitelisted user: " .. playerName end
            return true
        end
    end
    
    return false
end

local function hasAccess()
    local savedKey = getKeyFromFile()
    local keyVerified = false
    
    if savedKey then
        keyVerified = verifyKey(savedKey)
        if keyVerified then
            if status then status.Text = "Valid saved key found" end
            return true
        end
    end
    
    if hasNoKeyGamepass() then
        return true
    end
    
    if hasNoKeyAsset() then
        return true
    end
    
    if isWhitelistedUser() then
        return true
    end
    
    if status then status.Text = "No valid authentication found" end
    return false
end

local function animate(isAlreadyLoaded, onComplete)
    if not gui then
        gui, main, title, status, progress, keyContainer, keyInput, submitButton, getKeyButton, profilePic = createGUI()
    end

    setupKeyStorage()

    if isAlreadyLoaded then
        title.Text = "AK ADMIN"
        status.Text = "Already Loaded"
        status.TextColor3 = Color3.fromRGB(100, 255, 150)
        progress.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
        progress.Size = UDim2.new(1, 0, 1, 0)
        title.TextTransparency = 0
        status.TextTransparency = 0

        sounds.slideDown:Play()
        tween(main, { Position = UDim2.new(0.5, 0, 0, 10) }, 1.2)
        task.wait(2.5)

        sounds.slideUp:Play()
        tween(main, { Position = UDim2.new(0.5, 0, -0.2, 0) }, 1)
        task.wait(1.1)
        gui:Destroy()
        if onComplete then
            onComplete()
        end
    else
        sounds.slideDown:Play()
        tween(main, { Position = UDim2.new(0.5, 0, 0, 10) }, 1.2)
        task.wait(0.3)
        tween(title, { TextTransparency = 0 }, 0.4)
        task.wait(0.2)
        tween(status, { TextTransparency = 0 }, 0.4)

        tween(progress, { Size = UDim2.new(0.5, 0, 1, 0) }, 0.8)

        local isWhitelisted = hasAccess()

        if isWhitelisted then
            task.wait(0.5)
            status.Text = "Loading AK Admin..."
            tween(status, { TextColor3 = Color3.fromRGB(100, 255, 150) }, 0.4)
            tween(progress, { Size = UDim2.new(1, 0, 1, 0) }, 0.8)
            tween(progress, { BackgroundColor3 = Color3.fromRGB(100, 255, 150) }, 0.4)

            task.spawn(function()
                task.wait(1)
                if onComplete then
                    onComplete()
                end
            end)
        else
            task.wait(0.5)
            status.Text = "Verification required"

            tween(main, { Size = UDim2.new(0.4, 0, 0, 155) }, 0.8)
            profilePic.Position = UDim2.new(0, 15, 0.15, 0)
            task.wait(0.8)

            keyContainer.Visible = true

            getKeyButton.MouseButton1Click:Connect(function()
                sounds.buttonClick:Play()
                setclipboard("https://discord.gg/akadmin")
                getKeyButton.Text = "Discord copied. (no ads)"
                task.wait(3)
                getKeyButton.Text = "Get Key"
            end)

            submitButton.MouseButton1Click:Connect(function()
                sounds.buttonClick:Play()
                local key = keyInput.Text

                if key == "" then
                    status.Text = "Please enter a key"
                    status.TextColor3 = Color3.fromRGB(255, 150, 150)
                    task.wait(1.5)
                    status.Text = "Verification required"
                    status.TextColor3 = Color3.fromRGB(200, 200, 200)
                    return
                end

                status.Text = "Verifying key..."
                submitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 110)

                task.wait(0.8)
                local isValid = verifyKey(key)

                if isValid then
                    -- Save the trimmed key
                    local trimmedKey = key:match("^%s*(.-)%s*$")
                    saveKeyToFile(trimmedKey)
                    sounds.success:Play()
                    status.Text = "Key verified"
                    status.TextColor3 = Color3.fromRGB(100, 255, 150)
                    keyContainer.Visible = false

                    tween(main, { Size = UDim2.new(0.4, 0, 0, 50) }, 0.8)
                    profilePic.Position = UDim2.new(0, 15, 0.5, 0)
                    task.wait(0.8)

                    tween(progress, { Size = UDim2.new(1, 0, 1, 0) }, 0.8)
                    task.wait(0.5)
                    status.Text = "Loading Admin..."

                    if onComplete then
                        onComplete()
                    end
                else
                    sounds.failure:Play()
                    status.Text = "Invalid key"
                    status.TextColor3 = Color3.fromRGB(255, 100, 100)
                    submitButton.BackgroundColor3 = Color3.fromRGB(180, 120, 220)
                    submitButton.Enabled = true
                    task.wait(2)
                    status.Text = "Verification required"
                    status.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end)
        end
    end
end

-- Check if already loaded and show GUI accordingly
local alreadyLoaded = AKAdminVars.AKAdminLoaded

pcall(function()
    gui, main, title, status, progress, keyContainer, keyInput, submitButton, getKeyButton, profilePic = createGUI()
    animate(alreadyLoaded, executeScripts)
    AKAdminVars.FirstScriptLoaded = true
end)

local function setupQueueTeleport()
    local qt = nil
    
    if syn and syn.queue_on_teleport then
        qt = syn.queue_on_teleport
    elseif queue_on_teleport then
        qt = queue_on_teleport
    elseif fluxus and fluxus.queue_on_teleport then
        qt = fluxus.queue_on_teleport
    elseif Xeno and Xeno.queue_on_teleport then
        qt = Xeno.queue_on_teleport
    elseif Wave and Wave.queue_on_teleport then
        qt = Wave.queue_on_teleport
    elseif Solara and Solara.queue_on_teleport then
        qt = Solara.queue_on_teleport
    elseif krnl and krnl.queue_on_teleport then
        qt = krnl.queue_on_teleport
    elseif Sentinel and Sentinel.queue_on_teleport then
        qt = Sentinel.queue_on_teleport
    elseif SirHurt and SirHurt.queue_on_teleport then
        qt = SirHurt.queue_on_teleport
    elseif Delta and Delta.queue_on_teleport then
        qt = Delta.queue_on_teleport
    elseif Oxygen and Oxygen.queueOnTeleport then
        qt = Oxygen.queueOnTeleport
    elseif Shadow and Shadow.queue_on_teleport then
        qt = Shadow.queue_on_teleport
    elseif Calamari and Calamari.queue_on_teleport then
        qt = Calamari.queue_on_teleport
    elseif Electron and Electron.queue_on_teleport then
        qt = Electron.queue_on_teleport
    elseif Comet and Comet.queue_on_teleport then
        qt = Comet.queue_on_teleport
    elseif Evon and Evon.queue_on_teleport then
        qt = Evon.queue_on_teleport
    elseif JJSploit and JJSploit.queue_on_teleport then
        qt = JJSploit.queue_on_teleport
    elseif Hydrogen and Hydrogen.queue_on_teleport then
        qt = Hydrogen.queue_on_teleport
    elseif Sirhurt and Sirhurt.Queue_On_Teleport then
        qt = Sirhurt.Queue_On_Teleport
    elseif queueonteleport then
        qt = queueonteleport
    elseif queue_on_tp then
        qt = queue_on_tp
    elseif getgenv and getgenv().queue_on_teleport then
        qt = getgenv().queue_on_teleport
    elseif getgenv and getgenv().queueonteleport then
        qt = getgenv().queueonteleport
    elseif identifyexecutor and identifyexecutor():match("ScriptWare") and queueteleport then
        qt = queueteleport
    elseif ScriptWare and ScriptWare.queue_on_teleport then
        qt = ScriptWare.queue_on_teleport
    end
    
    if not qt then 
        warn("Queue on teleport not supported on this executor")
        return 
    end
    
    local scriptText = [[
        task.spawn(function()
            local success, result = pcall(function()
                return game:HttpGet('https://ichfickdeinemutta.pages.dev/AKADMIN.lua')
            end)
            
            if success and result and #result > 10 then
                pcall(function()
                    loadstring(result)()
                end)
            else
                warn("Failed to load script after teleport")
            end
        end)
    ]]
    
    local success, errorMsg = pcall(function()
        qt(scriptText)
    end)
    
    if success then
        print("Script queued successfully for next teleport")
    else
        warn("Failed to queue script: " .. tostring(errorMsg))
        
        local simpleScript = "loadstring(game:HttpGet('https://ichfickdeinemutta.pages.dev/AKADMIN.lua'))()"
        
        local altSuccess, altError = pcall(function()
            qt(simpleScript)
        end)
        
        if altSuccess then
            print("Alternative script queued successfully")
        else
            warn("Alternative approach also failed: " .. tostring(altError))
        end
    end
end

setupQueueTeleport()

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Lighting = game:GetService("Lighting")

local function cleanupEffects()
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") or 
           effect:IsA("BloomEffect") or 
           effect:IsA("ColorCorrectionEffect") or 
           effect:IsA("SunRaysEffect") or 
           effect:IsA("DepthOfFieldEffect") or
           effect:IsA("LensDistortionEffect") then
            effect:Destroy()
        end
    end
end

cleanupEffects()

local sky = Lighting:FindFirstChildOfClass("Sky")
if sky then sky:Destroy() end

sky = Instance.new("Sky")
sky.Parent = Lighting
sky.CelestialBodiesShown = true
sky.SkyboxBk = "rbxassetid://7018684000"
sky.SkyboxDn = "rbxassetid://7018684676"
sky.SkyboxFt = "rbxassetid://7018686031"
sky.SkyboxLf = "rbxassetid://7018687538"
sky.SkyboxRt = "rbxassetid://7018689553"
sky.SkyboxUp = "rbxassetid://7018690568"
sky.StarCount = 1500

Lighting.Technology = Enum.Technology.Compatibility
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.5
Lighting.ClockTime = 17.65
Lighting.GeographicLatitude = 35
Lighting.ExposureCompensation = 0
Lighting.TimeOfDay = "17:39:00"
Lighting.Ambient = Color3.fromRGB(70, 70, 70)
Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 130)

local bloom = Instance.new("BloomEffect")
bloom.Parent = Lighting
bloom.Enabled = true
bloom.Intensity = 0.04
bloom.Size = 24
bloom.Threshold = 0.95

local replicatedStorage = game:GetService("ReplicatedStorage")
local ToggleDisallowEvent = replicatedStorage:WaitForChild("ToggleDisallowEvent")
ToggleDisallowEvent:FireServer()
