local p = game:GetService("Players").LocalPlayer
local c = p.Character
if c and c:FindFirstChild("Humanoid") then
    for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("Tool") then c:FindFirstChild("Humanoid"):EquipTool(v) end
    end
end

do
end
