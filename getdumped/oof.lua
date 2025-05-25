game.Players.LocalPlayer.Character.Humanoid.Health = 0
function log()
    deadpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
end

game.Players.LocalPlayer.Character.Humanoid.Died:Connect(log)
game.Players.LocalPlayer.CharacterAdded:Connect(
    function(char)
        char:WaitForChild("Humanoid", 3).Died:Connect(log)
        char:WaitForChild("HumanoidRootPart", 3).CFrame = deadpos
    end
)()
