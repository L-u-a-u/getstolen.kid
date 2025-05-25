local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function chatMessage(str)
    str = tostring(str)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local generalChannel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
        if generalChannel then
            generalChannel:SendAsync(str)
        else
            warn("RBXGeneral channel not found!")
        end
    else
        local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest")
        if chatEvent then
            chatEvent:FireServer(str, "All")
        else
            warn("DefaultChatSystemChatEvents not found!")
        end
    end
end

local blob = "\u{000D}"
local clearMessage = ""..string.rep(blob, 197)..""


for i = 1, 5 do
    chatMessage(clearMessage) 
end

