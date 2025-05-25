replicatesignal(game.Players.LocalPlayer.ConnectDiedSignalBackend)
wait(game.Players.RespawnTime + .1)
game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15)
