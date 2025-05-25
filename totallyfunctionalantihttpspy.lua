if hookfunction and newcclosure then
local originalHttpGet = game.HttpGet
hookfunction(game.HttpGet, newcclosure(function(self, ...)
    if self == game and select(1, ...) == originalHttpGet then
        return nil
    end
    return originalHttpGet(self, ...)
end))
