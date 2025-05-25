local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
local clearMessage = "" .. string.rep(blob, 197) .. ""

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClearChatGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ClearChatToggle"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(1, -60, 0.5, -25) -- Middle-Right
toggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
toggleButton.BackgroundTransparency = 0.5
toggleButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
toggleButton.BorderSizePixel = 2
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 28
toggleButton.Parent = screenGui
toggleButton.Draggable = true
toggleButton.AutoButtonColor = false
toggleButton.Text = "🗑️"

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.5, 0)
corner.Parent = toggleButton

local dragging = false
local offset

local function dragStart(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Mouse or inputObject.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		offset = Vector2.new(toggleButton.AbsolutePosition.X - inputObject.Position.X, toggleButton.AbsolutePosition.Y - inputObject.Position.Y)
		inputObject.Changed:Connect(function()
			if not dragging then return end
			toggleButton.Position = UDim2.new(0, inputObject.Position.X + offset.X, 0, inputObject.Position.Y + offset.Y)
		end)
	end
end

local function dragEnd(inputObject)
	dragging = false
end

toggleButton.InputBegan:Connect(dragStart)
toggleButton.InputEnded:Connect(dragEnd)

-- Variables for the message loop
local isClearing = false
local messageLoopThread = nil

-- Function that continuously sends the clear message every 4 seconds.
local function messageLoop()
	while isClearing do
		chatMessage(clearMessage)
		-- Wait exactly 4 seconds before sending the next message.
		wait(4)
	end
end

-- Function to toggle the loop on and off.
local function toggleMessageLoop()
	isClearing = not isClearing

	if isClearing then
		-- Change the button appearance to indicate "active"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
		toggleButton.BackgroundTransparency = 0.3
		-- Start the message loop as a coroutine
		messageLoopThread = coroutine.wrap(messageLoop)
		messageLoopThread()
	else
		-- Change the button appearance back to "inactive"
		toggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		toggleButton.BackgroundTransparency = 0.5
	end

	-- Button rotation animation for visual feedback.
	local tweenInfo = TweenInfo.new(
		0.3,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		0,
		false
	)
	local tween = TweenService:Create(toggleButton, tweenInfo, {Rotation = toggleButton.Rotation + 360})
	tween:Play()
end

toggleButton.MouseButton1Click:Connect(toggleMessageLoop)
