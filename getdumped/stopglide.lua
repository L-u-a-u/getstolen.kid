-- Function to adjust the physical properties of character parts
local function passePhysikAn(character)
    -- Iterate over all MeshParts and Parts in the character
    for _, teil in ipairs(character:GetDescendants()) do
        if teil:IsA("MeshPart") or teil:IsA("Part") then
            -- High values for instant stopping and constant speed
            -- Parameters: Density, Friction, Elasticity, FrictionWeight, ElasticityWeight
            local physikalischeEigenschaften = PhysicalProperties.new(5.0, 3.0, 0.05, 3.0, 0.3)
            teil.CustomPhysicalProperties = physikalischeEigenschaften
            
            -- Set linear velocity to a constant based on movement
            teil.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Get the local player
local spieler = game.Players.LocalPlayer

-- Function to continuously update character's velocity
local function aktualisiereGeschwindigkeit(character)
    -- Monitor movement continuously
    game:GetService("RunService").Heartbeat:Connect(function()
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local zielGeschwindigkeit
            if humanoid.MoveDirection.Magnitude < 0.1 then
                -- Stop immediately if the player tries to halt
                zielGeschwindigkeit = Vector3.new(0, 0, 0)
            else
                -- Set full speed constant when moving
                local geschwindigkeitsMultiplikator = 1
                if humanoid.WalkSpeed > 16 then -- Player is sprinting
                    geschwindigkeitsMultiplikator = 1.5
                end
                zielGeschwindigkeit = humanoid.MoveDirection.Unit * (humanoid.WalkSpeed * geschwindigkeitsMultiplikator)
            end
            
            -- Set the target speed directly for all parts
            for _, teil in ipairs(character:GetDescendants()) do
                if teil:IsA("BasePart") then
                    teil.AssemblyLinearVelocity = Vector3.new(
                        zielGeschwindigkeit.X,
                        teil.AssemblyLinearVelocity.Y,
                        zielGeschwindigkeit.Z
                    )
                end
            end
        end
    end)
end

-- Apply properties if the character already exists
if spieler.Character then
    passePhysikAn(spieler.Character)
    aktualisiereGeschwindigkeit(spieler.Character)
end

-- Apply properties when the character spawns
spieler.CharacterAdded:Connect(function(neuerCharakter)
    passePhysikAn(neuerCharakter)
    aktualisiereGeschwindigkeit(neuerCharakter)
end)
