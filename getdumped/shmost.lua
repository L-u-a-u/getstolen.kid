-- Enhanced Auto Teleport to Highest Population Server Script
-- This script keeps searching until it finds a server with a good amount of players
-- It prioritizes servers with optimal player counts and implements persistence

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local visitedServersFileName = "VisitedServers_" .. game.PlaceId .. ".json"
local minimumAcceptablePlayerCount = 10 -- Won't stop until finding a server with at least this many players
local preferredPlayerCount = math.floor(Players.MaxPlayers * 0.8) -- Target around 80% full
local preferredSpaceAvailable = 2 -- How many slots should be open in the server
local maxRetries = 10 -- Increased maximum attempts 
local maxServerPages = 5 -- How many pages of servers to fetch (100 servers per page)
local serverBlacklist = {} -- Servers to avoid (add JobIds here if needed)

-- Create a persistent GUI status display
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportStatusGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Status Frame
local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(0, 300, 0, 120)
StatusFrame.Position = UDim2.new(0.5, -150, 0.15, 0)
StatusFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = ScreenGui

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusFrame

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -20, 0, 20)
TitleText.Position = UDim2.new(0, 10, 0, 5)
TitleText.BackgroundTransparency = 1
TitleText.Text = "High Population Server Finder"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = StatusFrame

-- Status Text
local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(1, -20, 0, 60)
StatusText.Position = UDim2.new(0, 10, 0, 30)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Initializing server search..."
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.SourceSans
StatusText.TextWrapped = true
StatusText.TextYAlignment = Enum.TextYAlignment.Top
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusFrame

-- Stats Text
local StatsText = Instance.new("TextLabel")
StatsText.Name = "StatsText"
StatsText.Size = UDim2.new(1, -20, 0, 20)
StatsText.Position = UDim2.new(0, 10, 0, 80)
StatsText.BackgroundTransparency = 1
StatsText.Text = "Servers checked: 0 | Best server: 0 players"
StatsText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsText.TextSize = 12
StatsText.Font = Enum.Font.SourceSans
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.Parent = StatusFrame

-- Progress Bar
local ProgressBarFrame = Instance.new("Frame")
ProgressBarFrame.Name = "ProgressBarFrame"
ProgressBarFrame.Size = UDim2.new(1, -20, 0, 8)
ProgressBarFrame.Position = UDim2.new(0, 10, 1, -15)
ProgressBarFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ProgressBarFrame.BorderSizePixel = 0
ProgressBarFrame.Parent = StatusFrame

local ProgressBarCorner = Instance.new("UICorner")
ProgressBarCorner.CornerRadius = UDim.new(1, 0)
ProgressBarCorner.Parent = ProgressBarFrame

local ProgressBar = Instance.new("Frame")
ProgressBar.Name = "ProgressBar"
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBarFrame

local ProgressBarInnerCorner = Instance.new("UICorner")
ProgressBarInnerCorner.CornerRadius = UDim.new(1, 0)
ProgressBarInnerCorner.Parent = ProgressBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = StatusFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Function to update the status
local function UpdateStatus(message, progress)
    StatusText.Text = message
    ProgressBar.Size = UDim2.new(progress, 0, 1, 0)
end

-- Function to update the stats
local function UpdateStats(serversChecked, bestPlayerCount)
    StatsText.Text = "Servers checked: " .. serversChecked .. " | Best server: " .. bestPlayerCount .. " players"
end

-- Function to load visited servers
local function LoadVisitedServers()
    local success, result = pcall(function()
        if not isfolder("ServerHistory") then
            makefolder("ServerHistory")
        end
        
        local filePath = "ServerHistory/" .. visitedServersFileName
        if isfile(filePath) then
            return HttpService:JSONDecode(readfile(filePath))
        else
            return {}
        end
    end)
    
    if success then
        return result
    else
        warn("Failed to load visited servers: " .. tostring(result))
        return {}
    end
end

-- Function to save visited servers
local function SaveVisitedServers(visitedServers)
    local success, result = pcall(function()
        if not isfolder("ServerHistory") then
            makefolder("ServerHistory")
        end
        
        local filePath = "ServerHistory/" .. visitedServersFileName
        writefile(filePath, HttpService:JSONEncode(visitedServers))
    end)
    
    if not success then
        warn("Failed to save visited servers: " .. tostring(result))
    end
end

-- Function to add current server to visited servers
local function AddCurrentServerToVisited(visitedServers)
    local currentServerGuid = game.JobId
    if currentServerGuid ~= "" then
        visitedServers[currentServerGuid] = os.time() -- Store timestamp
        SaveVisitedServers(visitedServers)
    end
end

-- Function to mark a server as visited (used when teleport fails)
local function MarkServerAsVisited(serverId)
    local visitedServers = LoadVisitedServers()
    visitedServers[serverId] = os.time()
    SaveVisitedServers(visitedServers)
end

-- Function to get server list with pagination
local function GetAllServers()
    local allServers = {}
    local cursor = ""
    local pageCount = 0
    
    repeat
        local success, result = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                table.insert(allServers, server)
            end
            
            cursor = result.nextPageCursor or ""
            pageCount = pageCount + 1
            
            UpdateStatus("Fetching server list, page " .. pageCount .. "...", math.min(0.3, 0.1 + (pageCount / maxServerPages) * 0.2))
            wait(0.1) -- Brief pause to prevent throttling
        else
            warn("Failed to get server page: " .. tostring(result))
            cursor = ""
        end
    until cursor == "" or pageCount >= maxServerPages
    
    return allServers
end

-- Function to find target server
local function FindTargetServer(serverList, visitedServers, excludeServerIds)
    excludeServerIds = excludeServerIds or {}
    local bestServer = nil
    local bestScore = -1
    local maxPlayers = Players.MaxPlayers
    local serversChecked = 0
    local bestPlayerCount = 0
    
    -- Calculate scores for each server
    for _, server in pairs(serverList) do
        serversChecked = serversChecked + 1
        
        -- Skip if this server is in our exclude list or blacklist
        if excludeServerIds[server.id] or serverBlacklist[server.id] then
            continue
        end
        
        -- Skip current server
        if server.id == game.JobId then
            continue
        end
        
        local playerCount = server.playing
        local spaceAvailable = maxPlayers - playerCount
        
        -- Skip servers with insufficient space
        if spaceAvailable < preferredSpaceAvailable then
            continue
        end
        
        -- Higher score is better
        local score = 0
        
        -- Prioritize player count with heavy weight
        score = score + playerCount * 10
        
        -- Bonus for being close to preferred count
        local preferredCountBonus = 1000 - math.abs(playerCount - preferredPlayerCount) * 10
        score = score + preferredCountBonus
        
        -- Penalty for being visited recently
        if visitedServers[server.id] then
            local timeAgo = os.time() - visitedServers[server.id]
            if timeAgo < 3600 then -- Less than an hour ago
                score = score - 2000
            elseif timeAgo < 86400 then -- Less than a day ago
                score = score - 1000
            else
                score = score - 500
            end
        else
            -- Bonus for being a new server
            score = score + 500
        end
        
        -- Update stats every 10 servers
        if serversChecked % 10 == 0 then
            UpdateStats(serversChecked, bestPlayerCount)
        end
        
        -- Update best server if this one has a higher score
        if score > bestScore then
            bestScore = score
            bestServer = server
            bestPlayerCount = playerCount
        end
    end
    
    -- Final stats update
    UpdateStats(serversChecked, bestPlayerCount)
    
    return bestServer, bestScore, bestPlayerCount
end

-- TeleportService failure handling
local failedTeleports = {}
local teleportTarget = nil
local retryCount = 0

-- Listen for teleport failures
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if player == LocalPlayer then
        local failReason = teleportResult.Name
        
        -- Handle specific teleport failures
        if failReason == "GameEnded" or failReason == "GameFull" or failReason == "Unauthorized" then
            if retryCount < maxRetries then
                retryCount = retryCount + 1
                UpdateStatus("Server was full or unavailable. Finding next best server... (Attempt " .. retryCount .. "/" .. maxRetries .. ")", 0.4)
                
                -- If we have an active target server, mark it as visited
                if teleportTarget and teleportTarget.id then
                    failedTeleports[teleportTarget.id] = true
                    MarkServerAsVisited(teleportTarget.id)
                end
                
                -- Re-run teleport process
                spawn(function()
                    TeleportToHighestPopulationServer()
                end)
            else
                UpdateStatus("Failed to find an available server after " .. maxRetries .. " attempts. Please try again later.", 1)
            end
        else
            UpdateStatus("Teleport failed: " .. failReason .. ". " .. (errorMessage or ""), 1)
        end
    end
end)

-- Function to teleport to the server with the highest player count
function TeleportToHighestPopulationServer()
    UpdateStatus("Initializing teleport process...", 0.05)
    
    -- Load visited servers
    local visitedServers = LoadVisitedServers()
    
    -- Add current server to visited servers
    AddCurrentServerToVisited(visitedServers)
    
    UpdateStatus("Retrieving server list...", 0.1)
    
    -- Get extended server list
    local allServers = GetAllServers()
    if #allServers == 0 then
        UpdateStatus("Error: No servers found. Try again later.", 1)
        return
    end
    
    UpdateStatus("Analyzing " .. #allServers .. " servers...", 0.4)
    
    -- Find the best server based on scoring system
    local targetServer, serverScore, playerCount = FindTargetServer(allServers, visitedServers, failedTeleports)
    
    -- If no good server found, or player count is too low, try again with visited servers
    local attempts = 0
    while (not targetServer or playerCount < minimumAcceptablePlayerCount) and attempts < 3 do
        attempts = attempts + 1
        UpdateStatus("No ideal server found, trying again with relaxed criteria (attempt " .. attempts .. "/3)...", 0.6)
        
        -- Temporarily clear visited history for broader search
        if attempts >= 2 then
            visitedServers = {}
        end
        
        targetServer, serverScore, playerCount = FindTargetServer(allServers, visitedServers, failedTeleports)
    end
    
    -- Teleport to the target server if found
    if targetServer and playerCount >= minimumAcceptablePlayerCount then
        local spaceAvailable = Players.MaxPlayers - targetServer.playing
        UpdateStatus("Found optimal server with " .. targetServer.playing .. " players (" .. spaceAvailable .. " slots available). Teleporting...", 0.9)
        
        teleportTarget = targetServer -- Store current target
        
        wait(0.5) -- Brief pause
        
        local teleportSuccess, teleportError = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, LocalPlayer)
        end)
        
        if not teleportSuccess then
            -- If immediate error, try next server
            UpdateStatus("Teleport error: " .. tostring(teleportError) .. ". Trying next server...", 0.5)
            failedTeleports[targetServer.id] = true
            
            if retryCount < maxRetries then
                retryCount = retryCount + 1
                
                -- Try again with the current server excluded
                TeleportToHighestPopulationServer()
            else
                UpdateStatus("Failed after " .. maxRetries .. " attempts. Try again later.", 1)
            end
        else
            UpdateStatus("Teleport initiated! Joining server with " .. targetServer.playing .. " players...", 1)
        end
    elseif targetServer then
        -- Found a server but it doesn't meet minimum player count
        UpdateStatus("Best server found has only " .. playerCount .. " players (minimum " .. minimumAcceptablePlayerCount .. " required). Teleporting anyway...", 0.9)
        
        teleportTarget = targetServer
        
        wait(0.5)
        
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, LocalPlayer)
        end)
    else
        UpdateStatus("No suitable servers found. Try again later.", 1)
    end
end

-- Execute teleport immediately
spawn(TeleportToHighestPopulationServer)

-- Create a retry button
local RetryButton = Instance.new("TextButton")
RetryButton.Name = "RetryButton"
RetryButton.Size = UDim2.new(0, 100, 0, 30)
RetryButton.Position = UDim2.new(0.5, -50, 1, 10)
RetryButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
RetryButton.BorderSizePixel = 0
RetryButton.Text = "Retry Search"
RetryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RetryButton.TextSize = 14
RetryButton.Font = Enum.Font.SourceSansBold
RetryButton.Parent = StatusFrame

local RetryCorner = Instance.new("UICorner")
RetryCorner.CornerRadius = UDim.new(0, 5)
RetryCorner.Parent = RetryButton

RetryButton.MouseButton1Click:Connect(function()
    retryCount = 0
    failedTeleports = {}
    UpdateStatus("Restarting server search...", 0.05)
    spawn(TeleportToHighestPopulationServer)
end)
