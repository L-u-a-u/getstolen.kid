for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
    game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
    v.Parent = workspace
end
