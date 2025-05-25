local runsvc = game:GetService("RunService")
local heartbeat = runsvc.Heartbeat
local rstepped = runsvc.RenderStepped
local players = game:GetService("Players")

local lp = players.LocalPlayer
local novel = Vector3.zero

local function noDamage(chr)
    local root = chr:WaitForChild("HumanoidRootPart")
    local humanoid = chr:WaitForChild("Humanoid")

    if root and humanoid then
        -- Prevent fall damage
        local rootCon
        rootCon = heartbeat:Connect(function()
            if not root.Parent then
                rootCon:Disconnect()
                return
            end

            local oldVel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = novel

            rstepped:Wait()
            root.AssemblyLinearVelocity = oldVel
        end)

        -- Prevent all other types of damage
        local healthCon
        healthCon = humanoid.HealthChanged:Connect(function(health)
            if health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)

        -- Cleanup connections on character removal
        chr.AncestryChanged:Connect(function(_, parent)
            if not parent then
                if rootCon then rootCon:Disconnect() end
                if healthCon then healthCon:Disconnect() end
            end
        end)
    end
end

-- Apply no damage to the current character
if lp.Character then
    noDamage(lp.Character)
end

-- Apply no damage to future characters
lp.CharacterAdded:Connect(noDamage)
