local Void = Instance.new("Part")
Void.Parent = workspace.Terrain
Void.Name = "Void"
Void.Transparency = 1
Void.Anchored = true
Void.Size = Vector3.new(2048, 1, 2048)
Void.Position = Vector3.new(0, workspace.FallenPartsDestroyHeight, 0)
Void.Locked = true
while true do
    pcall(function()
        Void.Position = Vector3.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position.X, workspace.FallenPartsDestroyHeight, game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position.Z)
    end)
    task.wait(0)
end
