local exceptions = {
    ["Alikhammas"] = true,
    ["Alikhammas1234"] = true,
    ["AK_ADMEN1"] = true
}

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local function isException(playerName)
    return exceptions[playerName] ~= nil
end

local function findServer()
    local gameId = game.PlaceId
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", gameId)
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if not success then return nil end
    
    for _, server in ipairs(result.data or {}) do
        -- Server is not full and not empty (20% to 80% capacity)
        local minPlayers = math.floor(server.maxPlayers * 0.2)
        local maxPlayers = math.floor(server.maxPlayers * 0.8)
        
        if server.playing >= minPlayers and server.playing < maxPlayers then
            return server.id
        end
    end
    
    return nil
end

local function serverHop()
    local serverId = findServer()
    if serverId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, Players.LocalPlayer)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player:IsFriendsWith(Players.LocalPlayer.UserId) and not isException(player.Name) then
        serverHop()
    end
end)


