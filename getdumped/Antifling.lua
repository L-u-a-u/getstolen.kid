-- Enhanced script: disables collisions and resets velocities for all other players' characters

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Function to disable collisions and reset physics for a given character
local function disableCollisionsAndResetVelocity(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
            
            -- If the part is named "Torso", set it to be massless
            if part.Name == "Torso" then
                part.Massless = true
            end

            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Connect to the RunService Stepped event to update each frame
RunService.Stepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        -- Skip the local player and ensure the character exists
        if player ~= Players.LocalPlayer and player.Character then
            local success, err = pcall(function()
                disableCollisionsAndResetVelocity(player.Character)
            end)
            if not success then
                warn("Failed to modify character for player:", player.Name, err)
            end
        end
    end
end)
