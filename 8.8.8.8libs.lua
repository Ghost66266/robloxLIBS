local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(10, 10, 12),
	Section = Color3.fromRGB(18, 18, 22),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(45, 45, 50),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(160, 160, 165)
}

local function CheckForExistingUI(name)
	local existing = CoreGui:FindFirstChild(name)
	if existing then existing:Destroy() end
end

-- [[ DRAG SYSTEM RÉPARÉ ]] --
local function MakeDraggable(topbarobject, object)
	local dragging = false
	local dragInput, dragStart, startPos

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function Library:CreateWelcomeScreen()
	CheckForExistingUI("8888_Welcome")
	local WelcomeGui = Instance.new("ScreenGui", CoreGui)
	WelcomeGui.Name = "8888_Welcome"
	WelcomeGui.IgnoreGuiInset = true

	local TextLabel = Instance.new("TextLabel", WelcomeGui)
	TextLabel.Size = UDim2.new(1, 0, 0, 200)
	TextLabel.Position = UDim2.new(0, 0, 0.5, -100)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = "WELCOME <font color='#AA00FF'>8.8.8.8</font> UI"
	TextLabel.RichText = true
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextSize = 80
	TextLabel.TextTransparency = 1

	TS:Create(TextLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()
	task.delay(5, function()
		TS:Create(TextLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
		Debris:AddItem(WelcomeGui, 1.1)
	end)
end

function Library:CreateWindow(title)
	CheckForExistingUI("8888_Main")
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_Main"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 520, 0, 380)
	Main.Position = UDim2.new(0.5, -260, 0.5, -190)
	Main.BackgroundColor3 = Theme.Main
    Main.Active = true -- Important pour le Drag
	Instance.new("UICorner", Main)
	Instance.new("UIStroke", Main).Color = Theme.Outline

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 45)
	Header.BackgroundColor3 = Theme.Section
    Header.Active = true -- Important pour le Drag
	Instance.new("UICorner", Header)
	
	MakeDraggable(Header, Main)

	local Title = Instance.new("TextLabel", Header)
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.Text = title or "8.8.8.8 UI"
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = "Left"

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -65)
	Scroll.Position = UDim2.new(0, 10, 0, 55)
	Scroll.BackgroundTransparency = 1
	Scroll.AutomaticCanvasSize = "Y"
	Scroll.ScrollBarThickness = 0
	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 12)
	Layout.HorizontalAlignment = "Center"

	local WindowActions = {}

	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.96, 0, 0, 30)
		Section.AutomaticSize = "Y"
		Section.BackgroundColor3 = Theme.Section
		Instance.new("UICorner", Section)

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		local CLayout = Instance.new("UIListLayout", Container)
		CLayout.Padding = UDim.new(0, 6)
		CLayout.HorizontalAlignment = "Center"
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 12)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.92, 0, 0, 35)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = "  " .. text
			Btn.TextColor3 = Theme.TextDark
			Btn.Font = "GothamMedium"
			Btn.TextSize = 13
			Btn.TextXAlignment = "Left"
			Instance.new("UICorner", Btn)
			Btn.MouseButton1Click:Connect(callback)
		end

		function SectionActions:AddToggle(text, callback)
			local Tgl = Instance.new("TextButton", Container)
			Tgl.Size = UDim2.new(0.92, 0, 0, 35)
			Tgl.BackgroundTransparency = 1
			Tgl.Text = "  " .. text
			Tgl.TextColor3 = Theme.TextDark
			Tgl.Font = "Gotham"
			Tgl.TextSize = 13
			Tgl.TextXAlignment = "Left"

			local Box = Instance.new("Frame", Tgl)
			Box.Size = UDim2.new(0, 34, 0, 18)
			Box.Position = UDim2.new(1, -40, 0.5, -9)
			Box.BackgroundColor3 = Theme.Outline
			Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

			local Dot = Instance.new("Frame", Box)
			Dot.Size = UDim2.new(0, 14, 0, 14)
			Dot.Position = UDim2.new(0, 2, 0.5, -7)
			Dot.BackgroundColor3 = Theme.Text
			Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

			local active = false
			Tgl.MouseButton1Click:Connect(function()
				active = not active
				TS:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = active and Theme.Accent or Theme.Outline}):Play()
				TS:Create(Dot, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
				callback(active)
			end)
		end
		
		return SectionActions
	end
	return WindowActions
end

return Library
