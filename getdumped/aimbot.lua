PLAYER  = game.Players.LocalPlayer
MOUSE   = PLAYER:GetMouse()
CC      = game.Workspace.CurrentCamera

ENABLED      = false       -- PC right-click aimbot activation
ESP_ENABLED  = false

_G.FREE_FOR_ALL = true

_G.ESP_BIND    = 52        -- Key code for ESP toggle (PC)
_G.CHANGE_AIM  = 'q'       -- Key for aim target toggle (PC)

_G.AIM_AT = 'Head'

wait(1)

function GetNearestPlayerToMouse()
	local PLAYERS      = {}
	local PLAYER_HOLD  = {}
	local DISTANCES    = {}
	for i, v in pairs(game.Players:GetPlayers()) do
		if v ~= PLAYER then
			table.insert(PLAYERS, v)
		end
	end
	for i, v in pairs(PLAYERS) do
		if _G.FREE_FOR_ALL == false then
			if v and v.Character and v.TeamColor ~= PLAYER.TeamColor then
				local AIM = v.Character:FindFirstChild(_G.AIM_AT)
				if AIM ~= nil then
					local DISTANCE                 = (AIM.Position - game.Workspace.CurrentCamera.CoordinateFrame.p).magnitude
					local RAY                      = Ray.new(game.Workspace.CurrentCamera.CoordinateFrame.p, (MOUSE.Hit.p - CC.CoordinateFrame.p).unit * DISTANCE)
					local HIT,POS                  = game.Workspace:FindPartOnRay(RAY, game.Workspace)
					local DIFF                     = math.floor((POS - AIM.Position).magnitude)
					PLAYER_HOLD[v.Name .. i]       = {}
					PLAYER_HOLD[v.Name .. i].dist  = DISTANCE
					PLAYER_HOLD[v.Name .. i].plr   = v
					PLAYER_HOLD[v.Name .. i].diff  = DIFF
					table.insert(DISTANCES, DIFF)
				end
			end
		elseif _G.FREE_FOR_ALL == true then
			if v and v.Character then
				local AIM = v.Character:FindFirstChild(_G.AIM_AT)
				if AIM ~= nil then
					local DISTANCE                 = (AIM.Position - game.Workspace.CurrentCamera.CoordinateFrame.p).magnitude
					local RAY                      = Ray.new(game.Workspace.CurrentCamera.CoordinateFrame.p, (MOUSE.Hit.p - CC.CoordinateFrame.p).unit * DISTANCE)
					local HIT,POS                  = game.Workspace:FindPartOnRay(RAY, game.Workspace)
					local DIFF                     = math.floor((POS - AIM.Position).magnitude)
					PLAYER_HOLD[v.Name .. i]       = {}
					PLAYER_HOLD[v.Name .. i].dist  = DISTANCE
					PLAYER_HOLD[v.Name .. i].plr   = v
					PLAYER_HOLD[v.Name .. i].diff  = DIFF
					table.insert(DISTANCES, DIFF)
				end
			end
		end
	end
	
	if unpack(DISTANCES) == nil then
		return false
	end
	
	local L_DISTANCE = math.floor(math.min(unpack(DISTANCES)))
	if L_DISTANCE > 20 then
		return false
	end
	
	for i, v in pairs(PLAYER_HOLD) do
		if v.diff == L_DISTANCE then
			return v.plr
		end
	end
	return false
end

-- Main GUI for aimbot/ESP info
GUI_MAIN                           = Instance.new('ScreenGui', game.CoreGui)
GUI_MAIN.Name                      = 'AIMBOT'

GUI_TARGET                         = Instance.new('TextLabel', GUI_MAIN)
GUI_TARGET.Size                    = UDim2.new(0,200,0,30)
GUI_TARGET.BackgroundTransparency  = 0.5
GUI_TARGET.BackgroundColor         = BrickColor.new('Fossil')
GUI_TARGET.BorderSizePixel         = 0
GUI_TARGET.Position                = UDim2.new(0.5,-100,0,0)
GUI_TARGET.Text                    = 'AIMBOT : OFF'
GUI_TARGET.TextColor3              = Color3.new(1,1,1)
GUI_TARGET.TextStrokeTransparency  = 1
GUI_TARGET.TextWrapped             = true
GUI_TARGET.FontSize                = 'Size24'
GUI_TARGET.Font                    = 'SourceSansBold'

GUI_AIM_AT                         = Instance.new('TextLabel', GUI_MAIN)
GUI_AIM_AT.Size                    = UDim2.new(0,200,0,20)
GUI_AIM_AT.BackgroundTransparency  = 0.5
GUI_AIM_AT.BackgroundColor         = BrickColor.new('Fossil')
GUI_AIM_AT.BorderSizePixel         = 0
GUI_AIM_AT.Position                = UDim2.new(0.5,-100,0,30)
GUI_AIM_AT.Text                    = 'AIMING : HEAD'
GUI_AIM_AT.TextColor3              = Color3.new(1,1,1)
GUI_AIM_AT.TextStrokeTransparency  = 1
GUI_AIM_AT.TextWrapped             = true
GUI_AIM_AT.FontSize                = 'Size18'
GUI_AIM_AT.Font                    = 'SourceSansBold'

--[[ 
    CONTROLS GUI PANEL 
    A button that toggles the visibility of a panel showing the controls.
]]--
local guiControlsToggle = Instance.new("TextButton", GUI_MAIN)
guiControlsToggle.Name = "ControlsToggle"
guiControlsToggle.Size = UDim2.new(0, 150, 0, 30)
guiControlsToggle.Position = UDim2.new(0, 10, 0, 100)
guiControlsToggle.BackgroundTransparency = 0.5
guiControlsToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
guiControlsToggle.BorderSizePixel = 0
guiControlsToggle.Text = "Show Controls"
guiControlsToggle.TextColor3 = Color3.new(1, 1, 1)
guiControlsToggle.Font = Enum.Font.SourceSansBold
guiControlsToggle.TextSize = 18

local guiControlsDetails = Instance.new("Frame", GUI_MAIN)
guiControlsDetails.Name = "ControlsDetails"
guiControlsDetails.Size = UDim2.new(0, 200, 0, 100)
guiControlsDetails.Position = UDim2.new(0, 10, 0, 140)
guiControlsDetails.BackgroundTransparency = 0.5
guiControlsDetails.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
guiControlsDetails.Visible = false

local controlsText = Instance.new("TextLabel", guiControlsDetails)
controlsText.Size = UDim2.new(1, 0, 1, 0)
controlsText.BackgroundTransparency = 1
controlsText.TextColor3 = Color3.new(1, 1, 1)
controlsText.Font = Enum.Font.SourceSans
controlsText.TextSize = 16
controlsText.TextWrapped = true
controlsText.Text = "Controls:\n- PC:\n   Right Mouse Button: Hold to aim\n   Q: Toggle aim target (Head/Torso)\n   4: Toggle ESP\n\n- Mobile:\n   Use on-screen buttons to toggle Aimbot and ESP"

guiControlsToggle.MouseButton1Click:Connect(function()
	guiControlsDetails.Visible = not guiControlsDetails.Visible
	if guiControlsDetails.Visible then
		guiControlsToggle.Text = "Hide Controls"
	else
		guiControlsToggle.Text = "Show Controls"
	end
end)

-- Optional: Hide the controls panel if clicked
guiControlsDetails.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		guiControlsDetails.Visible = false
		guiControlsToggle.Text = "Show Controls"
	end
end)

--[[ 
    MOBILE TOGGLES 
    These on-screen buttons let mobile users toggle the aimbot and ESP.
]]--
local MOBILE_AIMBOT = false

local aimbotToggleButton = Instance.new("TextButton", GUI_MAIN)
aimbotToggleButton.Name = "AimbotToggleButton"
aimbotToggleButton.Size = UDim2.new(0, 150, 0, 30)
aimbotToggleButton.Position = UDim2.new(0, 10, 0, 250)
aimbotToggleButton.BackgroundTransparency = 0.5
aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
aimbotToggleButton.BorderSizePixel = 0
aimbotToggleButton.Text = "Aimbot: OFF"
aimbotToggleButton.TextColor3 = Color3.new(1,1,1)
aimbotToggleButton.Font = Enum.Font.SourceSansBold
aimbotToggleButton.TextSize = 18

aimbotToggleButton.MouseButton1Click:Connect(function()
	MOBILE_AIMBOT = not MOBILE_AIMBOT
	if MOBILE_AIMBOT then
		aimbotToggleButton.Text = "Aimbot: ON"
	else
		aimbotToggleButton.Text = "Aimbot: OFF"
	end
end)

local espToggleButton = Instance.new("TextButton", GUI_MAIN)
espToggleButton.Name = "ESPToggleButton"
espToggleButton.Size = UDim2.new(0, 150, 0, 30)
espToggleButton.Position = UDim2.new(0, 10, 0, 290)
espToggleButton.BackgroundTransparency = 0.5
espToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
espToggleButton.BorderSizePixel = 0
espToggleButton.Text = "ESP: OFF"
espToggleButton.TextColor3 = Color3.new(1,1,1)
espToggleButton.Font = Enum.Font.SourceSansBold
espToggleButton.TextSize = 18

espToggleButton.MouseButton1Click:Connect(function()
	if ESP_ENABLED == false then
		FIND()
		ESP_ENABLED = true
		espToggleButton.Text = "ESP: ON"
		print('ESP : ON')
	else
		CLEAR()
		TRACK = false
		ESP_ENABLED = false
		espToggleButton.Text = "ESP: OFF"
		print('ESP : OFF')
	end
end)

local TRACK = false

function CREATE(BASE, TEAM)
	local ESP_MAIN                   = Instance.new('BillboardGui', PLAYER.PlayerGui)
	local ESP_DOT                    = Instance.new('Frame', ESP_MAIN)
	local ESP_NAME                   = Instance.new('TextLabel', ESP_MAIN)
	
	ESP_MAIN.Name                    = 'ESP'
	ESP_MAIN.Adornee                 = BASE
	ESP_MAIN.AlwaysOnTop             = true
	ESP_MAIN.ExtentsOffset           = Vector3.new(0, 1, 0)
	ESP_MAIN.Size                    = UDim2.new(0, 5, 0, 5)
	
	ESP_DOT.Name                     = 'DOT'
	ESP_DOT.BackgroundColor          = BrickColor.new('Bright red')
	ESP_DOT.BackgroundTransparency   = 0.3
	ESP_DOT.BorderSizePixel          = 0
	ESP_DOT.Position                 = UDim2.new(-0.5, 0, -0.5, 0)
	ESP_DOT.Size                     = UDim2.new(2, 0, 2, 0)
	ESP_DOT.Visible                  = true
	ESP_DOT.ZIndex                   = 10
	
	ESP_NAME.Name                    = 'NAME'
	ESP_NAME.BackgroundColor3        = Color3.new(255, 255, 255)
	ESP_NAME.BackgroundTransparency  = 1
	ESP_NAME.BorderSizePixel         = 0
	ESP_NAME.Position                = UDim2.new(0, 0, 0, -40)
	ESP_NAME.Size                    = UDim2.new(1, 0, 10, 0)
	ESP_NAME.Visible                 = true
	ESP_NAME.ZIndex                  = 10
	ESP_NAME.Font                    = 'ArialBold'
	ESP_NAME.FontSize                = 'Size14'
	ESP_NAME.Text                    = BASE.Parent.Name:upper()
	ESP_NAME.TextColor               = BrickColor.new('Bright red')
end

function CLEAR()
	for _,v in pairs(PLAYER.PlayerGui:GetChildren()) do
		if v.Name == 'ESP' and v:IsA('BillboardGui') then
			v:Destroy()
		end
	end
end

function FIND()
	CLEAR()
	TRACK = true
	spawn(function()
		while wait() do
			if TRACK then
				CLEAR()
				for i,v in pairs(game.Players:GetChildren()) do
					if v.Character and v.Character:FindFirstChild('Head') then
						if _G.FREE_FOR_ALL == false then
							if v.TeamColor ~= PLAYER.TeamColor then
								if v.Character:FindFirstChild('Head') then
									CREATE(v.Character.Head, true)
								end
							end
						else
							if v.Character:FindFirstChild('Head') then
								CREATE(v.Character.Head, true)
							end
						end
					end
				end
			end
		end
		wait(1)
	end)
end

-- PC aimbot activation via right mouse button (remains for PC users)
MOUSE.Button2Down:connect(function()
	ENABLED = true
end)

MOUSE.Button2Up:connect(function()
	ENABLED = false
end)

-- PC key events for toggling ESP and aim target
MOUSE.KeyDown:connect(function(KEY)
	KEY = KEY:lower():byte()
	if KEY == _G.ESP_BIND then
		if ESP_ENABLED == false then
			FIND()
			ESP_ENABLED = true
			print('ESP : ON')
		elseif ESP_ENABLED == true then
			wait()
			CLEAR()
			TRACK = false
			ESP_ENABLED = false
			print('ESP : OFF')
		end
	end
end)

MOUSE.KeyDown:connect(function(KEY)
	if KEY == _G.CHANGE_AIM then
		if _G.AIM_AT == 'Head' then
			_G.AIM_AT = 'Torso'
			GUI_AIM_AT.Text = 'AIMING : TORSO'
		elseif _G.AIM_AT == 'Torso' then
			_G.AIM_AT = 'Head'
			GUI_AIM_AT.Text = 'AIMING : HEAD'
		end
	end
end)

-- The aimbot now works if either the right mouse button is held (PC) or the mobile button is toggled ON.
game:GetService('RunService').RenderStepped:connect(function()
	if ENABLED or MOBILE_AIMBOT then
		local TARGET = GetNearestPlayerToMouse()
		if (TARGET ~= false) then
			local AIM = TARGET.Character:FindFirstChild(_G.AIM_AT)
			if AIM then
				CC.CoordinateFrame = CFrame.new(CC.CoordinateFrame.p, AIM.CFrame.p)
			end
			GUI_TARGET.Text = 'AIMBOT : '.. TARGET.Name:sub(1, 5)
		else
			GUI_TARGET.Text = 'AIMBOT : OFF'
		end
	else
		GUI_TARGET.Text = 'AIMBOT : OFF'
	end
end)

repeat
	wait()
	if ESP_ENABLED == true then
		FIND()
	end
until ESP_ENABLED == false
