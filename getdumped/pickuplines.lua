local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Create the ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PickupLinesGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Create the main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300)  -- Reduced Size
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150) -- Adjusted position for smaller size
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BackgroundTransparency = 0.6
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Add rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Add glass effect
local UIGradient = Instance.new("UIGradient")
UIGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.3),
	NumberSequenceKeypoint.new(1, 0.4)
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Create title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)  -- Reduced title bar size
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.BackgroundTransparency = 0.25
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- Add rounded corners to title bar
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Create title text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -70, 1, 0) -- Adjusted size for smaller title bar
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Smooth Pickup Lines"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16 -- Reduced text size
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

-- Create minimize button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 25, 0, 25) -- Reduced button size
MinimizeButton.Position = UDim2.new(1, -60, 0, 3)  -- Adjusted button position
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeButton.BackgroundTransparency = 0.4
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18 -- Reduced text size
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

-- Add rounded corners to minimize button
local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 5)
MinimizeCorner.Parent = MinimizeButton

-- Create close button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25) -- Reduced button size
CloseButton.Position = UDim2.new(1, -30, 0, 3) -- Adjusted button position
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseButton.BackgroundTransparency = 0.4
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18 -- Reduced text size
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

-- Add rounded corners to close button
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

-- Create ScrollingFrame for pickup lines
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -10, 1, -40) -- Adjusted size to fit smaller main frame
ScrollFrame.Position = UDim2.new(0, 5, 0, 35) -- Adjusted position for smaller titlebar
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ClipsDescendants = true
ScrollFrame.Parent = MainFrame

-- Add more pickup lines
local pickupLines = {
    "Are you a magician? Because whenever I look at you, everyone else disappears.",
    "Do you have a map? I keep getting lost in your eyes.",
    "Is your name Google? Because you've got everything I've been searching for.",
    "Are you a WiFi signal? Because I'm feeling a strong connection.",
	"Do you like science? Because I've got my ion you.",
    "Are you French? Because Eiffel for you.",
    "Is your name Autumn? Because you're making me fall for you.",
    "Are you a camera? Because every time I look at you, I smile.",
    "Do you believe in love at first sight, or should I walk by again?",
    "Are you a parking ticket? Because you've got FINE written all over you.",
    "Is your name Spotify? Because you're the hottest single around.",
    "Are you a bank loan? Because you've got my interest.",
    "Do you play Minecraft? Because you're mine-crafted perfectly.",
    "Are you a campfire? Because you are hot and I want s'more.",
    "Is this the Hogwarts Express? Because Platform 9 and 3/4 isn't the only thing making me crash into walls.",
    "Are you made of copper and tellurium? Because you're Cu-Te.",
    "Do you have a pencil? Because I want to erase your past and write our future.",
    "Is your name Wifi? Because I'm really feeling a connection.",
    "Are you a dictionary? Because you're adding meaning to my life.",
    "Do you have a map? Because I just keep getting lost in your eyes.",
	 "Is your name Microsoft? Because you're exactly what I need.",
    "Are you a photographer? Because I can picture us together.",
    "Do you have a bandaid? Because I scraped my knee falling for you.",
    "Is your father a boxer? Because you're a knockout!",
    "Are you a time traveler? Because I see you in my future.",
	"Do you like math? Because I can add you to my life.",
	"Is your name Waldo? Because someone like you is hard to find.",
    "Are you a cat? Because you're purr-fect.",
    "Do you have a sunburn, or are you always this hot?",
    "Is this a library? Because I keep checking you out.",
	"Are you an interior decorator? Because when I saw you, the room became beautiful.",
    "Do you play soccer? Because you're a keeper.",
    "Is your name Winter? Because you'll be snow problem for me.",
    "Are you a drum? Because I can't beat spending time with you.",
    "Do you have a name, or can I call you mine?",
    "Is this seat taken? Because my heart just skipped a beat.",
	"Are you a magician? Because you just made my heart skip a beat.",
	 "Do you have a quarter? I need to call my mom and tell her I met the one.",
    "Is your name Summer? Because you're hot as can be.",
    "Are you a gardener? Because you've planted yourself in my heart.",
    "Do you like raisins? How about a date instead?",
	"Is your name NASA? Because you're out of this world.",
    "Are you a campfire? Because you're hot and I want s'more.",
    "Do you have a map? I keep getting lost in your smile.",
    "Is your dad an art thief? Because you're a masterpiece.",
	"Are you a keyboard? Because you're just my type.",
    "Do you like science? Because we've got chemistry.",
    "Is your name Gravity? Because I keep falling for you.",
    "Are you a star? Because you light up my world.",
	 "Do you have a Band-Aid? I just scraped my knee falling for you.",
    "Is this a dream? Because you're too good to be true.",
    "Are you an alien? Because you're out of this world.",
    "Do you believe in fate? Because I think we were meant to meet.",
	"Is your name Art? Because you're a masterpiece.",
    "Are you a baker? Because you're making my heart rise.",
	"Do you have a compass? Because I keep getting lost in your eyes.",
    "Is your name Google? Because you've got everything I'm searching for.",
    "Are you a charger? Because I'm dying without you.",
    "Do you have a name tag? I keep forgetting my name around you.",
	 "Is your name WiFi? Because I'm feeling a strong connection."
}


local function chat(txt)
	if game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") then
		game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(txt,"All")
	else
		game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(txt)
	end
end

-- Create pickup line buttons
local function createPickupLineButtons()
	local buttonHeight = 40  -- Reduced button height
	local padding = 5

	for i, line in ipairs(pickupLines) do
		local Button = Instance.new("TextButton")
		Button.Name = "PickupLine" .. i
		Button.Size = UDim2.new(1, -10, 0, buttonHeight)
		Button.Position = UDim2.new(0, 5, 0, (i-1) * (buttonHeight + padding))
		Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		Button.BackgroundTransparency = 0.4
		Button.Text = line
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.TextSize = 14  -- Reduced text size
		Button.Font = Enum.Font.Gotham
		Button.TextWrapped = true
		Button.Parent = ScrollFrame

		-- Add rounded corners to button
		local ButtonCorner = Instance.new("UICorner")
		ButtonCorner.CornerRadius = UDim.new(0, 5)
		ButtonCorner.Parent = Button

		-- Button hover effect
		Button.MouseEnter:Connect(function()
			TweenService:Create(Button, TweenInfo.new(0.3), {
				BackgroundTransparency = 0.2
			}):Play()
		end)

		Button.MouseLeave:Connect(function()
			TweenService:Create(Button, TweenInfo.new(0.3), {
				BackgroundTransparency = 0.4
			}):Play()
		end)

		-- Button click handler
		Button.MouseButton1Click:Connect(function()
			local clickAnimation = TweenService:Create(Button, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			})
			clickAnimation:Play()

			-- Chat the pickup line
			chat(line)
			wait(0.1)
			TweenService:Create(Button, TweenInfo.new(0.1), {
				BackgroundTransparency = 0.4
			}):Play()
		end)
	end
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #pickupLines * (buttonHeight + padding))
end

-- Make the frame draggable
local isDragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				isDragging = false
			end
		end)
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and isDragging then
		updateDrag(input)
	end
end)

-- Create minimize/maximize animation
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local targetSize = isMinimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 300) -- Adjusted minimized size

	TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		Size = targetSize
	}):Play()

	if isMinimized then
		ScrollFrame.Visible = false
	else
		wait(0.2)
		ScrollFrame.Visible = true
	end
end)

-- Create close animation
CloseButton.MouseButton1Click:Connect(function()
	local closeAnimation = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1
	})

	closeAnimation:Play()
	closeAnimation.Completed:Connect(function()
        ScreenGui:Destroy()
	end)
end)

-- Initialize the GUI
createPickupLineButtons()
