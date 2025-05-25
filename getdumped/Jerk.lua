local player = game.Players.LocalPlayer
local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")

if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
    loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))() 
elseif humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
    loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
end
