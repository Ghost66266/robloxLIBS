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
	Text = Color3.fromRGB(255, 255, 255)
}

-- [[ SYSTÈME DE DRAG INTERNE SÉCURISÉ ]] --
local function EnableInternalDrag(dragFrame, mainFrame)
	local dragging, dragInput, dragStart, startPos
	dragFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function Library:CreateWelcomeScreen()
	local WelcomeGui = Instance.new("ScreenGui", CoreGui)
	WelcomeGui.Name = "8888_Welcome"
	WelcomeGui.DisplayOrder = 999999
	WelcomeGui.IgnoreGuiInset = true

	local TextLabel = Instance.new("TextLabel", WelcomeGui)
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = "WELCOME <font color='#AA00FF'>8.8.8.8</font> UI"
	TextLabel.RichText = true
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextSize = 0
	TextLabel.TextTransparency = 1

	TS:Create(TextLabel, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 85, TextTransparency = 0}):Play()
	task.delay(5, function()
		TS:Create(TextLabel, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextTransparency = 1, TextSize = 120}):Play()
		Debris:AddItem(WelcomeGui, 1.2)
	end)
end

function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_UserLib"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 520, 0, 380)
	Main.Position = UDim2.new(0.5, -260, 0.5, -190)
	Main.BackgroundColor3 = Theme.Main
	Main.Active = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	Instance.new("UIStroke", Main).Color = Theme.Outline

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = Theme.Section
	Header.Active = true
	Instance.new("UICorner", Header)
	
	-- ON ACTIVE LE DRAG UNIQUEMENT SUR LE HEADER
	EnableInternalDrag(Header, Main)

	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Size = UDim2.new(1, 0, 1, 0)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.Text = title or "8.8.8.8"
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 17
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextXAlignment = "Left"

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -75)
	Scroll.Position = UDim2.new(0, 10, 0, 60)
	Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 0
	Scroll.AutomaticCanvasSize = "Y"
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
		Instance.new("UIListLayout", Container).Padding = UDim.new(0, 8)
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 15)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.92, 0, 0, 38)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = "  " .. text
			Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			Btn.Font = "GothamMedium"
			Btn.TextSize = 14
			Btn.TextXAlignment = "Left"
			Btn.AutoButtonColor = true
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			Btn.MouseButton1Click:Connect(callback)
		end

		function SectionActions:AddSlider(text, min, max, default, callback)
			local SliderFrame = Instance.new("Frame", Container)
			SliderFrame.Size = UDim2.new(0.92, 0, 0, 50)
			SliderFrame.BackgroundTransparency = 1

			local Label = Instance.new("TextLabel", SliderFrame)
			Label.Text = "  " .. text .. " : " .. default
			Label.Size = UDim2.new(1, 0, 0, 20)
			Label.TextColor3 = Theme.Text
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = "Left"

			local Bar = Instance.new("Frame", SliderFrame)
			Bar.Size = UDim2.new(1, -10, 0, 6)
			Bar.Position = UDim2.new(0, 5, 0, 30)
			Bar.BackgroundColor3 = Theme.Outline
			Instance.new("UICorner", Bar)

			local Fill = Instance.new("Frame", Bar)
			Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Instance.new("UICorner", Fill)

			local sliding = false
			local function UpdateSlider()
				local mousePos = UIS:GetMouseLocation().X
				local barPos = Bar.AbsolutePosition.X
				local barSize = Bar.AbsoluteSize.X
				local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
				Fill.Size = UDim2.new(percent, 0, 1, 0)
				local val = math.floor(min + (max - min) * percent)
				Label.Text = "  " .. text .. " : " .. val
				callback(val)
			end

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true UpdateSlider() end
			end)
			UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
			end)
			UIS.InputChanged:Connect(function(input)
				if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider() end
			end)
		end

		return SectionActions
	end
	return WindowActions
end

return Library
