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


for i = 1, 1 do
    chatMessage(clearMessage) 
end



loadstring(game:HttpGet("https://raw.githubusercontent.com/vqmpjayZ/More-Scripts/refs/heads/main/Anthony's%20ACL"))()

wait(1)

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create notification
StarterGui:SetCore("SendNotification", {
    Title = "AK ADMIN",
    Text = "You need to change your Roblox Language to Қазақ тілі so it won't get tagged",
    Duration = 5
})

local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Function to send a chat message
local function chatMessage(str)
    str = tostring(str)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local generalChannel = TextChatService:FindFirstChild("TextChannels")
        if generalChannel then
            generalChannel = generalChannel:FindFirstChild("RBXGeneral")
            if generalChannel then
                generalChannel:SendAsync(str)
            else
                warn("RBXGeneral channel not found!") 
            end
        else
            warn("TextChannels not found!")
        end
    else
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local chatEvent = chatEvents:FindFirstChild("SayMessageRequest")
            if chatEvent then
                chatEvent:FireServer(str, "All")
            else
                warn("SayMessageRequest event not found!")
            end
        else
            warn("DefaultChatSystemChatEvents not found!")
        end
    end
end

-- Invisible character for new lines
local blob = ""

-- Formatted message (common for both systems)
wait(0.1)
local newMessage = 
        blob .. "\r" ..
        " ----------------🔥 AK ADMIN 🔥-------------  " .. blob .. "\r" ..
        blob .. "\r" ..
        blob .. "\r" ..
        " JOIN NOW AT " .. blob .. "\r" ..
        blob .. "\r" ..
        "----------DISִCORD.GG/AKADMIN------------" 

-- New message for the old chat system (without ASCII art)
local oldMessage = "🔥AK ADMIN🔥 👉 .ĝĝ/akadmin 👈"


-- Send the appropriate message based on the chat system
local function sendMessage()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        -- New chat system
        chatMessage(newMessage)
    else
        -- Old chat system
        chatMessage(oldMessage)
    end
end

-- Retry mechanism in case the message fails to send
local retries = 3
while retries > 0 do
    local success, err = pcall(sendMessage)
    if success then
        break
    else
        warn("Failed to send message: " .. err)
        retries = retries - 1
        wait(1) -- Wait before retrying
    end
end

if retries == 0 then
    warn("Failed to send message after multiple attempts.")
end

