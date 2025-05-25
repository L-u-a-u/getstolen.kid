-- LocalScript inside the TPtoPlr Tool

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create the teleportation tool
local tool = Instance.new("Tool")
tool.Name = "TPtoPlr"  -- Changed the tool name here
tool.RequiresHandle = false
tool.Parent = player:WaitForChild("Backpack") -- Adds the tool to the player's backpack

-- Function to teleport the local player to the clicked target player
local function teleportToPlayer(targetPlayer)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        print("Teleported " .. player.Name .. " to " .. targetPlayer.Name)
    else
        print("Teleport failed: Make sure both players' characters are loaded and have HumanoidRootParts.")
    end
end

-- Function to handle clicking on other players
local function onMouseClick(target)
    local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
    if targetPlayer and targetPlayer ~= player then -- Ensure we're targeting another player
        teleportToPlayer(targetPlayer)
    end
end

-- Set up mouse click detection when the tool is equipped
tool.Equipped:Connect(function()
    local mouse = player:GetMouse()
    
    -- Function to detect mouse clicks
    mouse.Button1Down:Connect(function()
        if mouse.Target and mouse.Target.Parent then
            onMouseClick(mouse.Target)
        end
    end)
end)

-- Cleanup when the tool is unequipped
tool.Unequipped:Connect(function()
    -- Optionally, you could disconnect the mouse click listener here if you stored it.
    print("TPtoPlr tool unequipped")
end)
