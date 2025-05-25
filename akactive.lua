local aes = game:GetService("AvatarEditorService")
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local teleport = game:GetService("TeleportService")
local run = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local http = game:GetService("HttpService")
local localPlayer = game.Players.LocalPlayer

-- Color constants from Script 1
local colors = {
	main = Color3.fromRGB(35, 39, 42),
	secondary = Color3.fromRGB(50, 55, 60),
	accent = Color3.fromRGB(114, 137, 218),
	hover = Color3.fromRGB(130, 150, 230),
	selection = Color3.fromRGB(90, 110, 180),
	text = Color3.fromRGB(240, 240, 240),
	textDim = Color3.fromRGB(180, 180, 190),
	danger = Color3.fromRGB(240, 90, 90),
	success = Color3.fromRGB(95, 210, 120),
	toggleOff = Color3.fromRGB(60, 65, 70),
	toggleOn = Color3.fromRGB(95, 210, 120)
}

-- Tween constants from Script 1
local tweens = {
	fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	medium = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	slow = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	spin = TweenInfo.new(0.6, Enum.EasingStyle.Linear),
	slide = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

-- Load commands from URL
local success, err = pcall(function()
	loadstring(game:HttpGet("https://ichfickdeinemutta.pages.dev/allcmdss.lua"))()
end)
if not success then
	warn("Failed to load commands: " .. err)
end

-- Define targeted commands
local targetedCommands = {
	{"!copy <target>", "Copies the avatar of the specified target (MIC UP! only if he has modified turned om!)."},
	{"!to <target>", "Teleports to the specified player's display name."}

}

-- GUI setup
local adminGui = Instance.new("ScreenGui")
adminGui.Name = "AdminActiveGUI"
adminGui.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")
adminGui.DisplayOrder = 10
adminGui.ResetOnSpawn = false

local adminPanel = Instance.new("ImageButton")
adminPanel.Name = "MainContainer"
adminPanel.Size = UDim2.new(0, 140, 0, 45)
adminPanel.Position = UDim2.new(1, -145, 0, -55)
-- adminPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Original color
adminPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Changed to white for gradient to show true colors
adminPanel.BackgroundTransparency = 0.5 -- Kept as is
adminPanel.BorderSizePixel = 0
adminPanel.Parent = adminGui
adminPanel.Active = true
adminPanel.Image = ""
adminPanel.AutoButtonColor = false
adminPanel.Selectable = true

-- Added UIGradient for the light purple to light pink effect
local adminPanelGradient = Instance.new("UIGradient")
adminPanelGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 150, 255)), -- Light Neon Purple
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 105, 180))  -- More Vibrant Pink
}
adminPanelGradient.Parent = adminPanel

local adminLabel = Instance.new("TextLabel")
adminLabel.Name = "AdminStatus"
adminLabel.Size = UDim2.new(0, 100, 0, 20)
adminLabel.Position = UDim2.new(0, 30, 0, 5)
adminLabel.Font = Enum.Font.GothamBold
adminLabel.Text = "AK ACTIVE"
adminLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
adminLabel.TextSize = 13
adminLabel.TextXAlignment = Enum.TextXAlignment.Left
adminLabel.BackgroundTransparency = 1
adminLabel.Parent = adminPanel

local liveDot = Instance.new("Frame")
liveDot.Name = "HeartbeatDot"
liveDot.Size = UDim2.new(0, 8, 0, 8)
liveDot.Position = UDim2.new(0, 15, 0, 18)
liveDot.BackgroundColor3 = Color3.fromRGB(80, 240, 120)
liveDot.BorderSizePixel = 0
liveDot.AnchorPoint = Vector2.new(0.5, 0.5)
liveDot.Parent = adminPanel

local liveDotGlow = Instance.new("UIGradient")
liveDotGlow.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 240, 120)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 180, 80))
}
liveDotGlow.Parent = liveDot

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSCounter"
fpsLabel.Size = UDim2.new(0, 100, 0, 20)
fpsLabel.Position = UDim2.new(0, 30, 0, 22)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(120, 220, 120) -- Changed to light green
fpsLabel.TextSize = 12
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.BackgroundTransparency = 1
fpsLabel.Parent = adminPanel

local liveDotCorner = Instance.new("UICorner")
liveDotCorner.CornerRadius = UDim.new(1, 0)
liveDotCorner.Parent = liveDot

local adminCorner = Instance.new("UICorner")
adminCorner.CornerRadius = UDim.new(0, 6)
adminCorner.Parent = adminPanel

local execLabel
if identifyexecutor then
	local success, execName = pcall(identifyexecutor)
	if success and execName then
		execLabel = Instance.new("TextLabel")
		execLabel.Name = "ExecutorLabel"
		execLabel.Size = UDim2.new(0, 100, 0, 20)
		execLabel.Position = UDim2.new(0, 95, 0, 22)
		execLabel.Font = Enum.Font.Gotham
		execLabel.Text = execName
		execLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		execLabel.TextSize = 12
		execLabel.TextXAlignment = Enum.TextXAlignment.Left
		execLabel.BackgroundTransparency = 1
		execLabel.Font = Enum.Font.ArialBold
		execLabel.Parent = adminPanel
		if execName == "Wave" then
			execLabel.TextColor3 = Color3.new(0, 0.764706, 1)
		elseif execName == "Delta" then
			execLabel.TextColor3 = Color3.new(0.549020, 0, 1)
		elseif execName == "Xeno" then
			execLabel.TextColor3 = Color3.new(1, 0, 0.784314)
		elseif execName == "JJSploit x Xeno" then
			execLabel.TextColor3 = Color3.new(1, 1, 1)
		end
	end
end

local CommandsList = Instance.new("ScreenGui")
CommandsList.Name = "CommandsList"
CommandsList.Parent = adminGui
CommandsList.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CommandsList.IgnoreGuiInset = true
CommandsList.ResetOnSpawn = false

local InnerFrame = Instance.new("CanvasGroup")
InnerFrame.Name = "InnerFrame"
InnerFrame.Parent = CommandsList
InnerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InnerFrame.BackgroundTransparency = 0.300
InnerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
InnerFrame.BorderSizePixel = 0
InnerFrame.Position = UDim2.new(0.393544734, 0, 0.268957347, 0)
InnerFrame.Size = UDim2.new(0, 300, 0, 390)
InnerFrame.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = InnerFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = InnerFrame
TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopBar.BackgroundTransparency = 0.800
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(0, 300, 0, 45)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0.0480000824, 0, 0, 0)
Title.Size = UDim2.new(0, 126, 0, 45)
Title.Font = Enum.Font.GothamMedium
Title.Text = "AK Commands"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16.000
Title.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("ImageButton")
Close.Name = "Close"
Close.Parent = TopBar
Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Close.BackgroundTransparency = 1.000
Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.893333316, 0, 0.266666681, 0)
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Image = "rbxassetid://11293981586"

local Minimise = Instance.new("ImageButton")
Minimise.Name = "Minimise"
Minimise.Parent = TopBar
Minimise.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Minimise.BackgroundTransparency = 1.000
Minimise.BorderColor3 = Color3.fromRGB(0, 0, 0)
Minimise.BorderSizePixel = 0
Minimise.Position = UDim2.new(0.803333342, 0, 0.266666681, 0)
Minimise.Size = UDim2.new(0, 20, 0, 20)
Minimise.Image = "rbxassetid://11293980042"

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = InnerFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Inner = Instance.new("Frame")
Inner.Name = "Inner"
Inner.Parent = InnerFrame
Inner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Inner.BackgroundTransparency = 1.000
Inner.BorderColor3 = Color3.fromRGB(0, 0, 0)
Inner.BorderSizePixel = 0
Inner.LayoutOrder = 1
Inner.Position = UDim2.new(0, 0, 0.120512821, 0)
Inner.Size = UDim2.new(0, 300, 0, 345)

local UIListLayout_2 = Instance.new("UIListLayout")
UIListLayout_2.Parent = Inner
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

local Search = Instance.new("Frame")
Search.Name = "Search"
Search.Parent = Inner
Search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Search.BackgroundTransparency = 1.000
Search.BorderColor3 = Color3.fromRGB(0, 0, 0)
Search.BorderSizePixel = 0
Search.Size = UDim2.new(0, 300, 0, 72)

local SearchInner = Instance.new("Frame")
SearchInner.Name = "SearchInner"
SearchInner.Parent = Search
SearchInner.AnchorPoint = Vector2.new(0.5, 0.5)
SearchInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SearchInner.BackgroundTransparency = 0.900
SearchInner.BorderColor3 = Color3.fromRGB(0, 0, 0)
SearchInner.BorderSizePixel = 0
SearchInner.Position = UDim2.new(0.5, 0, 0.5, 0)
SearchInner.Size = UDim2.new(1, 0, 0, 35)

local UICorner_2 = Instance.new("UICorner")
UICorner_2.CornerRadius = UDim.new(0, 10)
UICorner_2.Parent = SearchInner

local UIListLayout_3 = Instance.new("UIListLayout")
UIListLayout_3.Parent = SearchInner
UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout_3.Padding = UDim.new(0, 10)

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Name = "SearchIcon"
SearchIcon.Parent = SearchInner
SearchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SearchIcon.BackgroundTransparency = 1.000
SearchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
SearchIcon.BorderSizePixel = 0
SearchIcon.Size = UDim2.new(0, 20, 0, 20)
SearchIcon.Image = "rbxassetid://11293977875"
SearchIcon.ImageTransparency = 0.500

local TextBox = Instance.new("TextBox")
TextBox.Parent = SearchInner
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundTransparency = 1.000
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0.173076928, 0, 0.300000012, 0)
TextBox.Size = UDim2.new(0, 215, 0, 14)
TextBox.Font = Enum.Font.GothamMedium
TextBox.PlaceholderText = "Search Commands (0)"
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 14.000
TextBox.TextXAlignment = Enum.TextXAlignment.Left

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = Search
UIPadding.PaddingLeft = UDim.new(0, 20)
UIPadding.PaddingRight = UDim.new(0, 20)

local Results = Instance.new("Frame")
Results.Name = "Results"
Results.Parent = Inner
Results.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Results.BackgroundTransparency = 1.000
Results.BorderColor3 = Color3.fromRGB(0, 0, 0)
Results.BorderSizePixel = 0
Results.Position = UDim2.new(0, 0, 0.20869565, 0)
Results.Size = UDim2.new(0, 300, 0, 273)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = Results
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScrollingFrame.BackgroundTransparency = 1.000
ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Size = UDim2.new(0.981333435, 0, 1, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout_4 = Instance.new("UIListLayout")
UIListLayout_4.Parent = ScrollingFrame
UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_4.Padding = UDim.new(0, 10)

local UIPadding_2 = Instance.new("UIPadding")
UIPadding_2.Parent = ScrollingFrame
UIPadding_2.PaddingBottom = UDim.new(0, 20)
UIPadding_2.PaddingLeft = UDim.new(0, 20)
UIPadding_2.PaddingRight = UDim.new(0, 14)
UIPadding_2.PaddingTop = UDim.new(0, 2)

local Template = Instance.new("CanvasGroup")
Template.Name = "Template"
Template.Parent = ScrollingFrame
Template.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Template.BackgroundTransparency = 0.900
Template.BorderColor3 = Color3.fromRGB(0, 0, 0)
Template.BorderSizePixel = 0
Template.Size = UDim2.new(1, 0, 0, 0)
Template.AutomaticSize = Enum.AutomaticSize.Y

local UICorner_3 = Instance.new("UICorner")
UICorner_3.CornerRadius = UDim.new(0, 10)
UICorner_3.Parent = Template

local UIListLayout_5 = Instance.new("UIListLayout")
UIListLayout_5.Parent = Template
UIListLayout_5.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_5.VerticalAlignment = Enum.VerticalAlignment.Center

local Inner_2 = Instance.new("ImageButton")
Inner_2.Name = "Inner"
Inner_2.Parent = Template
Inner_2.Active = true
Inner_2.AnchorPoint = Vector2.new(0.5, 0.5)
Inner_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Inner_2.BackgroundTransparency = 1.000
Inner_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Inner_2.BorderSizePixel = 0
Inner_2.Position = UDim2.new(0.5, 0, 0.5, 0)
Inner_2.Selectable = true
Inner_2.Size = UDim2.new(1, 0, 0, 35)
Inner_2.AutomaticSize = Enum.AutomaticSize.Y

local UIListLayout_6 = Instance.new("UIListLayout")
UIListLayout_6.Parent = Inner_2
UIListLayout_6.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_6.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout_6.Padding = UDim.new(0, 5)

local Title_2 = Instance.new("TextLabel")
Title_2.Name = "Title"
Title_2.Parent = Inner_2
Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_2.BackgroundTransparency = 1.000
Title_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title_2.BorderSizePixel = 0
Title_2.Position = UDim2.new(0.0629801154, 0, 0, 0)
Title_2.Size = UDim2.new(0, 228, 0, 14)
Title_2.Font = Enum.Font.GothamMedium
Title_2.Text = "Template"
Title_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_2.TextSize = 14.000
Title_2.TextXAlignment = Enum.TextXAlignment.Left

local Desc = Instance.new("TextLabel")
Desc.Name = "Desc"
Desc.Parent = Inner_2
Desc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Desc.BackgroundTransparency = 1.000
Desc.BorderColor3 = Color3.fromRGB(0, 0, 0)
Desc.BorderSizePixel = 0
Desc.Position = UDim2.new(0.0629801154, 0, 0.582822084, 0)
Desc.Size = UDim2.new(0, 228, 0, 13)
Desc.Font = Enum.Font.GothamMedium
Desc.Text = "Description"
Desc.TextColor3 = Color3.fromRGB(255, 255, 255)
Desc.TextSize = 14.000
Desc.TextTransparency = 0.500
Desc.TextWrapped = true
Desc.TextXAlignment = Enum.TextXAlignment.Left
Desc.AutomaticSize = Enum.AutomaticSize.Y
Desc.TextTransparency = 1
Desc.Visible = false

local UIPadding_3 = Instance.new("UIPadding")
UIPadding_3.Parent = Inner_2
UIPadding_3.PaddingBottom = UDim.new(0, 15)
UIPadding_3.PaddingTop = UDim.new(0, 15)

local TopBarStroke = Instance.new("UIStroke")
local TemplateStroke = Instance.new("UIStroke")
local SearchStroke = Instance.new("UIStroke")
local MainStroke = Instance.new("UIStroke")

SearchStroke.Parent = SearchInner
SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
SearchStroke.Color = Color3.new(1, 1, 1)
SearchStroke.LineJoinMode = Enum.LineJoinMode.Round
SearchStroke.Thickness = 1.5
SearchStroke.Transparency = 0.83

TopBarStroke.Parent = TopBar
TopBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
TopBarStroke.Color = Color3.new(1, 1, 1)
TopBarStroke.LineJoinMode = Enum.LineJoinMode.Round
TopBarStroke.Thickness = 1.5
TopBarStroke.Transparency = 0.83

TemplateStroke.Parent = Template
TemplateStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
TemplateStroke.Color = Color3.new(1, 1, 1)
TemplateStroke.LineJoinMode = Enum.LineJoinMode.Round
TemplateStroke.Thickness = 1.5
TemplateStroke.Transparency = 0.83

MainStroke.Parent = InnerFrame
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
MainStroke.Color = Color3.new(0, 0, 0)
MainStroke.LineJoinMode = Enum.LineJoinMode.Round
MainStroke.Thickness = 3
MainStroke.Transparency = 0.94

Template.Visible = false

-- Function to handle command clicks
local function handleCommandClick(cmdName)
	if cmdName == "!r6" then
		local rigType = Enum.HumanoidRigType.R6
		aes:PromptAllowInventoryReadAccess()
		local result = aes:PromptAllowInventoryReadAccessCompleted()
		if result == Enum.AvatarPromptResult.Success then
			local HumDesc = localPlayer:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
			local success, errorMessage = pcall(function()
				aes:PromptSaveAvatar(HumDesc, rigType)
			end)
			if success then
				local char = localPlayer.Character
				if char and char:FindFirstChild("Humanoid") then
					char.Humanoid.Health = 0
				end
			else
				warn("Error saving avatar:", errorMessage)
			end
		end
	elseif cmdName == "!r15" then
		local rigType = Enum.HumanoidRigType.R15
		aes:PromptAllowInventoryReadAccess()
		local result = aes:PromptAllowInventoryReadAccessCompleted()
		if result == Enum.AvatarPromptResult.Success then
			local HumDesc = localPlayer:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
			local success, errorMessage = pcall(function()
				aes:PromptSaveAvatar(HumDesc, rigType)
			end)
			if success then
				local char = localPlayer.Character
				if char and char:FindFirstChild("Humanoid") then
					char.Humanoid.Health = 0
				end
			else
				warn("Error saving avatar:", errorMessage)
			end
		end
	elseif string.find(cmdName, "<target>") then
		local targetInput = Instance.new("TextBox")
		targetInput.Size = UDim2.new(0, 200, 0, 30)
		targetInput.Position = UDim2.new(0.5, -100, 0.5, -15)
		targetInput.PlaceholderText = "Enter target player name..."
		targetInput.Text = ""
		targetInput.Font = Enum.Font.Gotham
		targetInput.TextSize = 14
		targetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		targetInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		targetInput.BorderSizePixel = 0
		targetInput.Parent = InnerFrame
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = targetInput
		targetInput.FocusLost:Connect(function(enterPressed)
			if enterPressed and targetInput.Text ~= "" then
				local command = cmdName:gsub("<target>", targetInput.Text)
				print("Executing targeted command: " .. command)
			end
			targetInput:Destroy()
		end)
		targetInput:CaptureFocus()
	else
		if _G.cmds and _G.cmds[cmdName] then
			loadstring(game:HttpGet(_G.cmds[cmdName]))()
		else
			print("No URL provided for command: " .. cmdName)
		end
	end
end

local cmdDescs = {
	{name = "!afk", desc = "AFK mode script"},
	{name = "!aimbot", desc = "Aim assistance script"},
	{name = "!akhub", desc = "AK Hub script loader"},
	{name = "!bigbaseplate", desc = "Create large baseplate"},
	{name = "!fov", desc = "Field of view modifier"},
	{name = "!lagserver", desc = "Server lag script"},
	{name = "!bodysnake", desc = "Body snake animation"},
	{name = "!animcopy", desc = "Copy player animations"},
	{name = "!animrecord", desc = "Animation recorder"},
	{name = "!bodyletter", desc = "Body letter formation"},
	{name = "!vccontroller", desc = "Voice chat controller"},
	{name = "!permdeath", desc = "Permanent death effect"},
	{name = "!ad", desc = "Advertisement script"},
	{name = "!ftp", desc = "FTP utility script"},
	{name = "!reanim", desc = "Character size changer"},
	{name = "!annoynearest", desc = "Annoy nearest player"},
	{name = "!limborbit", desc = "Limb orbit animation"},
	{name = "!annoyserver", desc = "Annoy all server players"},
	{name = "!trip", desc = "Trip animation"},
	{name = "!firework", desc = "Firework effect script"},
	{name = "!rizzlines", desc = "Pickup lines script"},
	{name = "!akbypasser", desc = "AK bypasser utility"},
	{name = "!animlogger", desc = "Animation logger"},
	{name = "!antiall", desc = "Anti all protections"},
	{name = "!antiall2", desc = "Anti all protections v2"},
	{name = "!antiall3", desc = "Anti all protections v3"},
	{name = "!autorevc", desc = "Auto reactivate voice chat"},
	{name = "!reverse", desc = "Reverse animation"},
	{name = "!antibang", desc = "Anti bang protection"},
	{name = "!antilag", desc = "Anti lag script"},
	{name = "!antilog", desc = "Anti logger protection"},
	{name = "!antiheadsit", desc = "Anti head sit protection"},
	{name = "!antikick", desc = "Anti kick protection"},
	{name = "!antifling", desc = "Anti fling protection"},
	{name = "!antivoid", desc = "Anti void protection"},
	{name = "!autogrammar", desc = "Auto grammar correction"},
	{name = "!chatspy", desc = "Chat spy utility"},
	{name = "!micupinvis", desc = "Invisible body with mic"},
	{name = "!chatbot", desc = "Chat bot utility"},
	{name = "!chatdraw", desc = "Draw in chat"},
	{name = "!chatlogs", desc = "Chat logs viewer"},
	{name = "!chatquiz", desc = "Chat quiz game"},
	{name = "!chattroll", desc = "Chat trolling script"},
	{name = "!clrchat", desc = "Clear chat command"},
	{name = "!droptools", desc = "Drop all tools"},
	{name = "!emotes", desc = "Emotes menu"},
	{name = "!emoji", desc = "Emoji script"},
	{name = "!errornotify", desc = "Error notifications"},
	{name = "!facebang", desc = "Face bang animation"},
	{name = "!fling all", desc = "Fling all players"},
	{name = "!fps", desc = "FPS booster"},
	{name = "!freecam", desc = "Free camera mode"},
	{name = "!hug", desc = "Hug animation"},
	{name = "!invis", desc = "Invisibility script"},
	{name = "!iy", desc = "Infinite Yield"},
	{name = "!jerk", desc = "Jerk animation"},
	{name = "!jumpingrope", desc = "Jumping rope animation"},
	{name = "!loopclearchat", desc = "Loop clear chat"},
	{name = "!mupcombo", desc = "Mic up combo"},
	{name = "!mutenonfriends", desc = "Mute non-friends"},
	{name = "!nofriends", desc = "No friends utility"},
	{name = "!ndsgodmode", desc = "NDS godmode"},
	{name = "!oof", desc = "Oof sound"},
	{name = "!pickuptools", desc = "Pick up all tools"},
	{name = "!revc", desc = "Voice chat bypass"},
	{name = "!remotechecker", desc = "Remote events checker"},
	{name = "!sfly", desc = "Silent fly mode"},
	{name = "!sh", desc = "Server hop utility"},
	{name = "!shiftlock", desc = "Shift lock enabler"},
	{name = "!shlow", desc = "Server hop low player"},
	{name = "!shmost", desc = "Server hop most players"},
	{name = "!sneak", desc = "Sneak animation"},
	{name = "!stopglide", desc = "Stop glide animation"},
	{name = "!touchfling", desc = "Touch fling script"},
	{name = "!touchmanager", desc = "Touch manager utility"},
	{name = "!tptoplr", desc = "Teleport to player"},
	{name = "!uafling", desc = "Unanchor fling"},
	{name = "!unctest", desc = "UNC check environment"},
	{name = "!vcbypass", desc = "Voice chat bypass"},
	{name = "!voidoof", desc = "Void oof sound"},
	{name = "!walkonair", desc = "Walk on air ability"},
	{name = "!walkonvoid", desc = "Walk on void ability"},
	{name = "!walkonwalls", desc = "Walk on walls ability"},
	{name = "!priorityspeaker", desc = "Priority speaker in VC"}
}

-- Modified addButton function using Activated event
local function addButton(data)
	local title = data.title
	local desc = data.desc
	local hovereffects = data.hovereffects

	local newButton = Template:Clone()
	newButton.Parent = ScrollingFrame
	newButton.Inner.Title.Text = title
	newButton.Inner.Desc.Text = desc
	newButton.Name = title
	
	for _,v in pairs(cmdDescs) do
		if v.name == title then
			newButton.Inner.Desc.Text = v.desc
		end
	end

	if hovereffects then
		newButton.Inner.MouseEnter:Connect(function()
			ts:Create(newButton, tweens.fast, {Transparency = 0.6}):Play()
			newButton.Inner.Desc.Visible = true
			ts:Create(newButton.Inner.Desc, tweens.medium, {TextTransparency = 0.5}):Play()
			local clicksound = Instance.new("Sound")
			clicksound.Volume = 0.2
			clicksound.SoundId = "rbxassetid://92876108656319"
			clicksound.Parent = newButton
			clicksound:Play()
		end)
		newButton.Inner.MouseLeave:Connect(function()
			ts:Create(newButton.Inner.Desc, tweens.medium, {TextTransparency = 1}):Play()
			ts:Create(newButton, tweens.fast, {Transparency = 0.9}):Play()
			task.wait(0.25)
			newButton.Inner.Desc.Visible = false
		end)
	end

	newButton.Inner.Activated:Connect(function()
		handleCommandClick(title)
	end)

	newButton.Visible = true
end

-- Add all commands
local allCommands = {}
if _G.cmds then
	for cmdName, url in pairs(_G.cmds) do
		table.insert(allCommands, {title = cmdName, desc = "", url = url})
	end
end
for _, cmdData in ipairs(targetedCommands) do
	table.insert(allCommands, {title = cmdData[1], desc = cmdData[2]})
end
table.sort(allCommands, function(a, b)
	return a.title < b.title
end)
for _, cmd in ipairs(allCommands) do
	addButton({
		title = cmd.title,
		desc = cmd.desc or "",
		hovereffects = true
	})
end

-- Auto-execute functionality
local autoexecConfig = {}
local cfgFile = "ak_config.json"
local settingsPopulated = false
local settingsOpen = false

local function saveConfig()
	if not writefile or not http then return end
	local success, encoded = pcall(http.JSONEncode, http, autoexecConfig)
	if success then
		writefile(cfgFile, encoded)
	end
end

local function loadConfig()
	if not isfile or not readfile or not http then return end
	if isfile(cfgFile) then
		local success, data = pcall(readfile, cfgFile)
		if success then
			local decodeSuccess, decoded = pcall(http.JSONDecode, http, data)
			if decodeSuccess then
				autoexecConfig = decoded
			else
				autoexecConfig = {}
			end
		else
			autoexecConfig = {}
		end
	else
		autoexecConfig = {}
	end
end

local function executeAutoCommands()
	if not _G.cmds then return end
	for cmdName, enabled in pairs(autoexecConfig) do
		if enabled and _G.cmds[cmdName] then
			local success, err = pcall(function()
				loadstring(game:HttpGet(_G.cmds[cmdName]))()
			end)
			task.wait(0.1)
		end
	end
end

-- Auto-execute panel setup
local autoExecPanel = Instance.new("Frame")
autoExecPanel.Name = "AutoExecutePanel"
autoExecPanel.Size = UDim2.new(0, 280, 0, 300)
autoExecPanel.Position = UDim2.new(0, -200, 1, 0)
autoExecPanel.BackgroundColor3 = Color3.fromRGB(25, 28, 32)
autoExecPanel.BorderSizePixel = 0
autoExecPanel.ClipsDescendants = true
autoExecPanel.Parent = adminPanel
autoExecPanel.Visible = false
autoExecPanel.ZIndex = adminPanel.ZIndex - 1

local autoExecCorner = Instance.new("UICorner")
autoExecCorner.CornerRadius = UDim.new(0, 8)
autoExecCorner.Parent = autoExecPanel

local autoExecHeader = Instance.new("Frame")
autoExecHeader.Name = "AutoExecuteHeader"
autoExecHeader.Size = UDim2.new(1, 0, 0, 40)
autoExecHeader.BackgroundColor3 = Color3.fromRGB(32, 35, 40)
autoExecHeader.BorderSizePixel = 0
autoExecHeader.Parent = autoExecPanel

local autoExecHeaderCorner = Instance.new("UICorner")
autoExecHeaderCorner.CornerRadius = UDim.new(0, 8)
autoExecHeaderCorner.Parent = autoExecHeader

local autoExecHeaderMask = Instance.new("Frame")
autoExecHeaderMask.Size = UDim2.new(1, 0, 0, 10)
autoExecHeaderMask.Position = UDim2.new(0, 0, 1, -10)
autoExecHeaderMask.BackgroundColor3 = Color3.fromRGB(32, 35, 40)
autoExecHeaderMask.BorderSizePixel = 0
autoExecHeaderMask.ZIndex = 0
autoExecHeaderMask.Parent = autoExecHeader

local autoExecTitle = Instance.new("TextLabel")
autoExecTitle.Size = UDim2.new(1, -20, 1, 0)
autoExecTitle.Position = UDim2.new(0, 15, 0, 0)
autoExecTitle.Text = "Auto Execute"
autoExecTitle.Font = Enum.Font.GothamBold
autoExecTitle.TextSize = 15
autoExecTitle.TextColor3 = colors.text
autoExecTitle.TextXAlignment = Enum.TextXAlignment.Left
autoExecTitle.BackgroundTransparency = 1
autoExecTitle.Parent = autoExecHeader

local autoexecSearchContainer = Instance.new("Frame")
autoexecSearchContainer.Name = "SearchContainer"
autoexecSearchContainer.Size = UDim2.new(1, -24, 0, 34)
autoexecSearchContainer.Position = UDim2.new(0, 12, 0, 50)
autoexecSearchContainer.BackgroundColor3 = Color3.fromRGB(35, 38, 45)
autoexecSearchContainer.BorderSizePixel = 0
autoexecSearchContainer.Parent = autoExecPanel

local autoexecSearchCorner = Instance.new("UICorner")
autoexecSearchCorner.CornerRadius = UDim.new(0, 8)
autoexecSearchCorner.Parent = autoexecSearchContainer

local autoexecSearchIcon = Instance.new("ImageLabel")
autoexecSearchIcon.Size = UDim2.new(0, 16, 0, 16)
autoexecSearchIcon.Position = UDim2.new(0, 8, 0.5, -8)
autoexecSearchIcon.BackgroundTransparency = 1
autoexecSearchIcon.Image = "rbxassetid://6031154871"
autoexecSearchIcon.ImageColor3 = colors.textDim
autoexecSearchIcon.Parent = autoexecSearchContainer

local autoexecSearchBox = Instance.new("TextBox")
autoexecSearchBox.Name = "SearchBox"
autoexecSearchBox.Size = UDim2.new(1, -35, 1, -10)
autoexecSearchBox.Position = UDim2.new(0, 30, 0, 5)
autoexecSearchBox.PlaceholderText = "Search commands..."
autoexecSearchBox.Font = Enum.Font.GothamMedium
autoexecSearchBox.TextSize = 13
autoexecSearchBox.TextColor3 = colors.text
autoexecSearchBox.PlaceholderColor3 = colors.textDim
autoexecSearchBox.BackgroundTransparency = 1
autoexecSearchBox.BorderSizePixel = 0
autoexecSearchBox.ClearTextOnFocus = false
autoexecSearchBox.Text = ""
autoexecSearchBox.Parent = autoexecSearchContainer

local autoExecScroll = Instance.new("ScrollingFrame")
autoExecScroll.Name = "AutoExecScrollFrame"
autoExecScroll.Size = UDim2.new(1, -16, 1, -95)
autoExecScroll.Position = UDim2.new(0, 8, 0, 95)
autoExecScroll.BackgroundColor3 = Color3.fromRGB(32, 35, 40)
autoExecScroll.BorderSizePixel = 0
autoExecScroll.ScrollBarThickness = 4
autoExecScroll.ScrollBarImageColor3 = colors.accent
autoExecScroll.ScrollBarImageTransparency = 0.3
autoExecScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
autoExecScroll.Parent = autoExecPanel

local autoExecScrollCorner = Instance.new("UICorner")
autoExecScrollCorner.CornerRadius = UDim.new(0, 6)
autoExecScrollCorner.Parent = autoExecScroll

local autoExecList = Instance.new("UIListLayout")
autoExecList.Name = "AutoExecListLayout"
autoExecList.Padding = UDim.new(0, 5)
autoExecList.SortOrder = Enum.SortOrder.LayoutOrder
autoExecList.Parent = autoExecScroll

local autoExecPadding = Instance.new("UIPadding")
autoExecPadding.Name = "AutoExecPadding"
autoExecPadding.PaddingTop = UDim.new(0, 5)
autoExecPadding.PaddingBottom = UDim.new(0, 5)
autoExecPadding.PaddingLeft = UDim.new(0, 5)
autoExecPadding.PaddingRight = UDim.new(0, 5)
autoExecPadding.Parent = autoExecScroll

-- Toggle creation function from Script 1
local function createToggle(parent, cmdName)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = "ToggleFrame"
	toggleFrame.Size = UDim2.new(0, 44, 0, 24)
	toggleFrame.Position = UDim2.new(1, -15, 0.5, 2)
	toggleFrame.BackgroundColor3 = autoexecConfig[cmdName] and colors.toggleOn or colors.toggleOff
	toggleFrame.BorderSizePixel = 0
	toggleFrame.Parent = parent
	toggleFrame.AnchorPoint = Vector2.new(1, 0.5)

	local rippleEffect = Instance.new("Frame")
	rippleEffect.Name = "RippleEffect"
	rippleEffect.AnchorPoint = Vector2.new(0.5, 0.5)
	rippleEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	rippleEffect.BackgroundTransparency = 0.8
	rippleEffect.BorderSizePixel = 0
	rippleEffect.Size = UDim2.new(0, 0, 0, 0)
	rippleEffect.Parent = toggleFrame

	local rippleCorner = Instance.new("UICorner")
	rippleCorner.CornerRadius = UDim.new(1, 0)
	rippleCorner.Parent = rippleEffect

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleFrame

	local toggleGradient = Instance.new("UIGradient")
	toggleGradient.Rotation = 45
	toggleGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
	})
	toggleGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.85),
		NumberSequenceKeypoint.new(1, 0.75)
	})
	toggleGradient.Parent = toggleFrame

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 20, 0, 20)
	indicator.Position = autoexecConfig[cmdName] and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	indicator.BorderSizePixel = 0
	indicator.Parent = toggleFrame
	indicator.AnchorPoint = Vector2.new(0, 0.5)
	indicator.ZIndex = 2

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator

	local indicatorGradient = Instance.new("UIGradient")
	indicatorGradient.Rotation = autoexecConfig[cmdName] and 180 or 0
	indicatorGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))
	})
	indicatorGradient.Parent = indicator

	local indicatorShadow = Instance.new("Frame")
	indicatorShadow.Name = "Shadow"
	indicatorShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	indicatorShadow.BackgroundTransparency = autoexecConfig[cmdName] and 0.4 or 0.6
	indicatorShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	indicatorShadow.BorderSizePixel = 0
	indicatorShadow.Size = UDim2.new(1, 4, 1, 4)
	indicatorShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	indicatorShadow.ZIndex = 1
	indicatorShadow.Parent = indicator

	local indicatorShadowCorner = Instance.new("UICorner")
	indicatorShadowCorner.CornerRadius = UDim.new(1, 0)
	indicatorShadowCorner.Parent = indicatorShadow

	local function playRippleEffect(inputPosition)
		rippleEffect.Position = UDim2.new(0, inputPosition.X - toggleFrame.AbsolutePosition.X, 0.5, 0)
		rippleEffect.BackgroundTransparency = 0.7

		local rippleSize = UDim2.new(0, toggleFrame.AbsoluteSize.X * 1.5, 0, toggleFrame.AbsoluteSize.X * 1.5)
		local fadeOut = ts:Create(rippleEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = rippleSize,
			BackgroundTransparency = 1
		})

		rippleEffect.Size = UDim2.new(0, 0, 0, 0)
		fadeOut:Play()

		fadeOut.Completed:Connect(function()
			rippleEffect.Size = UDim2.new(0, 0, 0, 0)
		end)
	end

	local function updateVisuals(isInstant)
		local enabled = autoexecConfig[cmdName] == true
		local targetColor = enabled and colors.toggleOn or colors.toggleOff
		local targetPos = enabled and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		local targetRotation = enabled and 180 or 0

		if isInstant then
			toggleFrame.BackgroundColor3 = targetColor
			indicator.Position = targetPos
			indicatorGradient.Rotation = targetRotation
			indicatorShadow.BackgroundTransparency = enabled and 0.4 or 0.6
		else
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			ts:Create(toggleFrame, tweenInfo, {BackgroundColor3 = targetColor}):Play()
			ts:Create(indicator, tweenInfo, {Position = targetPos}):Play()
			ts:Create(indicatorGradient, tweenInfo, {Rotation = targetRotation}):Play()
			ts:Create(indicatorShadow, tweenInfo, {BackgroundTransparency = enabled and 0.4 or 0.6}):Play()
		end
	end

	toggleFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
			input.UserInputType == Enum.UserInputType.Touch then
			autoexecConfig[cmdName] = not autoexecConfig[cmdName]
			updateVisuals(false)
			playRippleEffect(input.Position)
			saveConfig()
		end
	end)

	local hoverTween
	toggleFrame.MouseEnter:Connect(function()
		if hoverTween then hoverTween:Cancel() end
		hoverTween = ts:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.1})
		hoverTween:Play()
	end)

	toggleFrame.MouseLeave:Connect(function()
		if hoverTween then hoverTween:Cancel() end
		hoverTween = ts:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0})
		hoverTween:Play()
	end)

	updateVisuals(true)
	return toggleFrame
end

-- Update canvas size for auto-execute scroll frame
local function updateAutoExecCanvasSize()
	local contentHeight = autoExecList.AbsoluteContentSize.Y + autoExecPadding.PaddingTop.Offset + autoExecPadding.PaddingBottom.Offset
	autoExecScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end

autoExecScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateAutoExecCanvasSize)
autoExecList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateAutoExecCanvasSize)

-- Populate auto-execute panel
local function populateAutoExec()
	if settingsPopulated then return end

	for _, child in ipairs(autoExecScroll:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "UICorner" then
			child:Destroy()
		end
	end

	local sortedCmds = {}
	if _G.cmds then
		for cmdName, _ in pairs(_G.cmds) do
			table.insert(sortedCmds, cmdName)
		end
	end
	table.sort(sortedCmds)

	for _, cmdName in ipairs(sortedCmds) do
		local rowFrame = Instance.new("Frame")
		rowFrame.Name = cmdName
		rowFrame.Size = UDim2.new(1, 0, 0, 30)
		rowFrame.BackgroundColor3 = Color3.fromRGB(28, 31, 35)
		rowFrame.BorderSizePixel = 0
		rowFrame.Parent = autoExecScroll

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 4)
		rowCorner.Parent = rowFrame

		local cmdLabel = Instance.new("TextLabel")
		cmdLabel.Size = UDim2.new(1, -55, 1, 0)
		cmdLabel.Position = UDim2.new(0, 10, 0, 0)
		cmdLabel.Text = cmdName
		cmdLabel.Font = Enum.Font.Gotham
		cmdLabel.TextSize = 13
		cmdLabel.TextColor3 = colors.text
		cmdLabel.TextXAlignment = Enum.TextXAlignment.Left
		cmdLabel.BackgroundTransparency = 1
		cmdLabel.Parent = rowFrame

		createToggle(rowFrame, cmdName)
	end

	updateAutoExecCanvasSize()
	settingsPopulated = true
end

-- Search functionality for auto-execute panel
autoexecSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local searchText = string.lower(autoexecSearchBox.Text)
	for _, row in ipairs(autoExecScroll:GetChildren()) do
		if row:IsA("Frame") and row.Name ~= "UICorner" then
			local cmdName = string.lower(row.Name)
			local shouldShow = searchText == "" or cmdName:find(searchText, 1, true) ~= nil
			row.Visible = shouldShow
		end
	end
	updateAutoExecCanvasSize()
end)

-- Settings icon setup
local settingsGearBox = Instance.new("Frame")
settingsGearBox.Name = "SettingsGearBox"
settingsGearBox.Size = UDim2.new(0, 32, 0, 32)
settingsGearBox.Position = UDim2.new(1, -16, 0, 14)
settingsGearBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
settingsGearBox.BackgroundTransparency = 1
settingsGearBox.BorderSizePixel = 0
settingsGearBox.AnchorPoint = Vector2.new(1, 0.5)
settingsGearBox.Parent = adminPanel

local settingsIcon = Instance.new("TextButton")
settingsIcon.Name = "SettingsIcon"
settingsIcon.Size = UDim2.new(0, 12, 0, 12)
settingsIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
settingsIcon.Text = "⚙️"
settingsIcon.TextColor3 = colors.textDim
settingsIcon.TextSize = 10
settingsIcon.BackgroundTransparency = 1
settingsIcon.BorderSizePixel = 0
settingsIcon.AnchorPoint = Vector2.new(0.5, 0.5)
settingsIcon.Rotation = 0
settingsIcon.Parent = settingsGearBox
settingsIcon.AutoButtonColor = false

settingsGearBox.MouseEnter:Connect(function()
	ts:Create(settingsIcon, tweens.fast, {TextColor3 = colors.text}):Play()
end)

settingsGearBox.MouseLeave:Connect(function()
	ts:Create(settingsIcon, tweens.fast, {TextColor3 = colors.textDim}):Play()
end)

settingsIcon.MouseButton1Click:Connect(function()
	settingsOpen = not settingsOpen

	local spinTween = ts:Create(settingsIcon, tweens.spin, {Rotation = settingsIcon.Rotation + 360})
	spinTween:Play()

	if settingsOpen then
		populateAutoExec()
		autoExecPanel.Visible = true
		local targetPos = UDim2.new(0, -200, 1, adminPanel.AbsoluteSize.Y)
		ts:Create(autoExecPanel, tweens.slide, {Position = targetPos}):Play()
	else
		local targetPos = UDim2.new(0, -200, 1, 0)
		local slideOut = ts:Create(autoExecPanel, tweens.slide, {Position = targetPos})
		slideOut.Completed:Connect(function()
			if not settingsOpen then
				autoExecPanel.Visible = false
			end
		end)
		slideOut:Play()
	end
end)

-- GUI interaction
local dragging = false
local dragStart
local startPos

local function updateInput(input)
	local delta = input.Position - dragStart
	InnerFrame.Position = UDim2.new(
		startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y
	)
end

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = InnerFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

uis.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateInput(input)
	end
end)

Minimise.Activated:Connect(function()
	if InnerFrame.Size == UDim2.new(0, 300, 0, 390) then
		ts:Create(InnerFrame, tweens.medium, {Size = UDim2.new(0, 300, 0, 45)}):Play()
	else
		ts:Create(InnerFrame, tweens.medium, {Size = UDim2.new(0, 300, 0, 390)}):Play()
	end
end)

Close.Activated:Connect(function()
	InnerFrame.Visible = false
end)

adminPanel.Activated:Connect(function()
	local inputPos = uis:GetMouseLocation()
	local settingsIconAbsPos = settingsGearBox.AbsolutePosition
	local settingsIconAbsSize = settingsGearBox.AbsoluteSize

	local isClickOnSettingsGearBox = (
		inputPos.X >= settingsIconAbsPos.X and
			inputPos.X <= settingsIconAbsPos.X + settingsIconAbsSize.X and
			inputPos.Y >= settingsIconAbsPos.Y and
			inputPos.Y <= settingsIconAbsPos.Y + settingsIconAbsSize.Y
	)

	if not isClickOnSettingsGearBox and not settingsOpen then
		InnerFrame.Visible = not InnerFrame.Visible
	end
end)

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	local newText = TextBox.Text:lower()
	for _, v in pairs(ScrollingFrame:GetChildren()) do
		if v:IsA("CanvasGroup") and v.Name ~= "Template" then
			if newText == "" or v.Name:lower():find(newText, 1, true) then
				v.Visible = true
			else
				v.Visible = false
			end
		end
	end
end)

-- FPS counter and heartbeat animation
local frameCount = 0
local timeElapsed = 0
run.RenderStepped:Connect(function(delta)
	frameCount = frameCount + 1
	timeElapsed = timeElapsed + delta
	if timeElapsed >= 1 then
		local fps = math.floor(frameCount / timeElapsed)
		fpsLabel.Text = "FPS: " .. tostring(fps)
		frameCount = 0
		timeElapsed = 0
	end
end)

local heartbeatInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
local heartbeatTween = ts:Create(liveDot, heartbeatInfo, {Size = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(100, 255, 140)})
heartbeatTween:Play()

local rotationInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
local gradientRotation = ts:Create(liveDotGlow, rotationInfo, {Rotation = 360})
gradientRotation:Play()

-- Load and execute auto commands
loadConfig()
executeAutoCommands()

local function updateCount()
	local countOfCommands = 0

	for _,v in pairs(ScrollingFrame:GetChildren()) do
		if v:IsA("CanvasGroup") then
			if v.Name ~= "Template" then
				countOfCommands += 1
			end
		end
	end

	TextBox.PlaceholderText = `Search Commands ({countOfCommands})`
end

updateCount()

print("Admin GUI script loaded successfully.")
