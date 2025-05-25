-- Auto Teleport to Lowest Population Server Script (With Minimum Players)
-- This script automatically teleports the player to the server with the lowest player count
-- while ensuring there's a minimum number of players and avoiding servers they've previously visited
-- If teleport fails, it automatically tries the next best server

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- File to store visited server IDs (saved to player's machine)
local visitedServersFileName = "VisitedServers_" .. game.PlaceId .. ".json"
local minimumPlayers = 2 -- Minimum players needed in the server (set to 0 for completely empty)
local maxRetries = 5 -- Maximum number of servers to try if teleports fail
local keepSearching = true -- Will continue searching until a suitable server is found

-- Create a small status GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportStatusGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Status Frame
local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(0, 250, 0, 80)
StatusFrame.Position = UDim2.new(0.5, -125, 0.15, 0)
StatusFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = ScreenGui

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusFrame

-- Status Text
local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(1, -20, 1, -10)
StatusText.Position = UDim2.new(0, 10, 0, 5)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Finding emptiest server..."
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.SourceSans
StatusText.TextWrapped = true
StatusText.TextYAlignment = Enum.TextYAlignment.Top
StatusText.Parent = StatusFrame

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
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 132) -- Green color for low population
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBarFrame

local ProgressBarInnerCorner = Instance.new("UICorner")
ProgressBarInnerCorner.CornerRadius = UDim.new(1, 0)
ProgressBarInnerCorner.Parent = ProgressBar

-- Function to update the status
local function UpdateStatus(message, progress)
    StatusText.Text = message
    ProgressBar.Size = UDim2.new(progress, 0, 1, 0)
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

-- Function to get server list (using cursor to potentially load more servers)
local function GetServerList(cursor)
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if success then
        return result
    else
        warn("Failed to get server list: " .. tostring(result))
        return {data = {}}
    end
end

-- Function to find target server
local function FindTargetServer(visitedServers, excludeServerIds)
    excludeServerIds = excludeServerIds or {}
    local targetServer = nil
    local lowestPlayers = math.huge
    local candidates = {}
    local nextCursor = nil
    local searchAttempts = 0
    local maxSearchAttempts = 5 -- Limit how many pagination requests we make
    
    while (not targetServer or keepSearching) and searchAttempts < maxSearchAttempts do
        -- Get a batch of servers
        local serverList = GetServerList(nextCursor)
        searchAttempts = searchAttempts + 1
        
        if #serverList.data == 0 then
            break -- No more servers available
        end
        
        -- Sort servers by player count (lowest first - this is the key difference)
        table.sort(serverList.data, function(a, b)
            return a.playing < b.playing
        end)
        
        -- Try to find unvisited server with minimum players
        for _, server in pairs(serverList.data) do
            -- Skip if this server is in our exclude list (failed teleport)
            if excludeServerIds[server.id] then
                continue
            end
            
            -- Check if server hasn't been visited and meets minimum player count
            if not visitedServers[server.id] and 
               server.playing >= minimumPlayers and
               server.playing < lowestPlayers then
                lowestPlayers = server.playing
                targetServer = server
                table.insert(candidates, server)
                
                -- If not keeping searching, break after finding the first valid server
                if not keepSearching then
                    break
                end
            end
        end
        
        -- If we found a target and aren't continuing to search, break out
        if targetServer and not keepSearching then
            break
        end
        
        -- If there's a next page of results and we should keep looking
        nextCursor = serverList.nextPageCursor
        if not nextCursor then
            break -- No more pages
        end
    end
    
    -- If no server found with our criteria, take any server with minimum players
    if not targetServer then
        local serverList = GetServerList() -- Get fresh list
        
        for _, server in pairs(serverList.data) do
            -- Skip if this server is in our exclude list
            if excludeServerIds[server.id] then
                continue
            end
            
            if server.playing >= minimumPlayers and server.playing < lowestPlayers then
                lowestPlayers = server.playing
                targetServer = server
                table.insert(candidates, server)
            end
        end
    end
    
    return targetServer, candidates
end

-- TeleportService.TeleportInitFailed event handler
local failedTeleports = {}
local retryCount = 0

-- Listen for teleport failures
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if player == LocalPlayer then
        local failReason = teleportResult.Name
        
        -- Handle specific teleport failures
        if failReason == "GameEnded" or failReason == "GameFull" or failReason == "Unauthorized" then
            if retryCount < maxRetries then
                retryCount = retryCount + 1
                UpdateStatus("Server was unavailable. Finding next emptiest server... (Attempt " .. retryCount .. "/" .. maxRetries .. ")", 0.4)
                
                -- If we have an active target server, mark it as visited
                if teleportTarget and teleportTarget.id then
                    failedTeleports[teleportTarget.id] = true
                    MarkServerAsVisited(teleportTarget.id)
                end
                
                -- Re-run teleport process
                spawn(function()
                    TeleportToLowestPopulationServer()
                end)
            else
                UpdateStatus("Failed to find an available server after " .. maxRetries .. " attempts. Please try again later.", 1)
                wait(5)
                ScreenGui:Destroy()
            end
        else
            UpdateStatus("Teleport failed: " .. failReason .. ". " .. (errorMessage or ""), 1)
            wait(5)
            ScreenGui:Destroy()
        end
    end
end)

-- Global var to track current teleport target
local teleportTarget = nil

-- Function to teleport to the server with the lowest player count
function TeleportToLowestPopulationServer()
    UpdateStatus("Initializing teleport process...", 0.05)
    
    -- Load visited servers
    local visitedServers = LoadVisitedServers()
    
    -- Add current server to visited servers
    AddCurrentServerToVisited(visitedServers)
    
    UpdateStatus("Searching for emptiest servers...", 0.2)
    
    -- Find the server with the lowest player count
    local targetServer, candidates = FindTargetServer(visitedServers, failedTeleports)
    
    UpdateStatus("Finalizing server selection...", 0.9)
    
    -- Teleport to the target server
    if targetServer then
        UpdateStatus("Teleporting to server with only " .. targetServer.playing .. " players", 1)
        
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
                
                -- Try to find another server
                targetServer, _ = FindTargetServer(visitedServers, failedTeleports)
                
                if targetServer then
                    teleportTarget = targetServer
                    
                    UpdateStatus("Teleporting to alternate server with " .. targetServer.playing .. " players", 1)
                    
                    wait(0.5)
                    
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, LocalPlayer)
                    end)
                else
                    UpdateStatus("No other suitable servers found. Try again later.", 1)
                    wait(5)
                    ScreenGui:Destroy()
                end
            else
                UpdateStatus("Failed after " .. maxRetries .. " attempts. Try again later.", 1)
                wait(5)
                ScreenGui:Destroy()
            end
        end
    else
        UpdateStatus("No suitable servers found. Try again later.", 1)
        wait(5)
        ScreenGui:Destroy()
    end
end

-- Execute teleport immediately
spawn(TeleportToLowestPopulationServer)
