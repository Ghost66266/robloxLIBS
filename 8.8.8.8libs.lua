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
	Glow = Color3.fromRGB(170, 0, 255)
}

-- [[ EFFETS SPECIAUX UNIQUES ]] --

-- 1. Effet de lueur pulsante (Neon Glow)
local function ApplyNeonGlow(object)
	local Glow = Instance.new("UIStroke", object)
	Glow.Color = Theme.Accent
	Glow.Transparency = 0.6
	Glow.Thickness = 2
	
	task.spawn(function()
		while object.Parent do
			TS:Create(Glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.9}):Play()
			task.wait(1.5)
			TS:Create(Glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.4}):Play()
			task.wait(1.5)
		end
	end)
end

-- 2. Effet Onde de Choc (Ripple)
local function CreateRipple(obj)
	local Mouse = game.Players.LocalPlayer:GetMouse()
	local Circle = Instance.new("ImageLabel")
	Circle.Parent = obj
	Circle.BackgroundColor3 = Color3.new(1, 1, 1)
	Circle.BackgroundTransparency = 1
	Circle.Image = "rbxassetid://266543268"
	Circle.ImageColor3 = Theme.Accent
	Circle.ImageTransparency = 0.5
	Circle.ZIndex = 10
	Circle.Position = UDim2.new(0, Mouse.X - obj.AbsolutePosition.X, 0, Mouse.Y - obj.AbsolutePosition.Y)
	Circle.AnchorPoint = Vector2.new(0.5, 0.5)
	TS:Create(Circle, TweenInfo.new(0.6), {Size = UDim2.new(0, obj.AbsoluteSize.X * 3, 0, obj.AbsoluteSize.X * 3), ImageTransparency = 1}):Play()
	Debris:AddItem(Circle, 0.7)
end

function Library:CreateWelcomeScreen()
	local WelcomeGui = Instance.new("ScreenGui", CoreGui)
	WelcomeGui.IgnoreGuiInset = true
	WelcomeGui.DisplayOrder = 1000

	local TextLabel = Instance.new("TextLabel", WelcomeGui)
	TextLabel.Size = UDim2.new(1, 0, 0, 250)
	TextLabel.Position = UDim2.new(0, 0, 0.5, -125)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = "WELCOME <font color='#AA00FF'>8.8.8.8</font> UI"
	TextLabel.RichText = true
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextSize = 0
	TextLabel.TextTransparency = 1

	TS:Create(TextLabel, TweenInfo.new(1.2, Enum.EasingStyle.Back), {TextSize = 90, TextTransparency = 0}):Play()
	task.delay(4, function()
		TS:Create(TextLabel, TweenInfo.new(1), {TextTransparency = 1, TextSize = 110}):Play()
		Debris:AddItem(WelcomeGui, 1.2)
	end)
end

function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_UserLib"

	local Main = Instance.new("Frame", UI)
	Main.Name = "MainFrame"
	Main.Size = UDim2.new(0, 550, 0, 400)
	Main.Position = UDim2.new(0.5, -275, 0.5, -200)
	Main.BackgroundColor3 = Theme.Main
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
	
	-- Effet de Glow sur le menu entier
	ApplyNeonGlow(Main)

	local Header = Instance.new("Frame", Main)
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 55)
	Header.BackgroundColor3 = Theme.Section
	Instance.new("UICorner", Header)
	
	-- Ligne de dégradé animée sous le Header
	local Line = Instance.new("Frame", Header)
	Line.Size = UDim2.new(1, 0, 0, 2)
	Line.Position = UDim2.new(0, 0, 1, 0)
	Line.BackgroundColor3 = Theme.Accent
	local Grad = Instance.new("UIGradient", Line)
	Grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Theme.Accent)})
	task.spawn(function()
		while Line.Parent do
			TS:Create(Grad, TweenInfo.new(2, Enum.EasingStyle.Linear), {Offset = Vector2.new(1, 0)}):Play()
			task.wait(2)
			Grad.Offset = Vector2.new(-1, 0)
		end
	end)

	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Size = UDim2.new(1, 0, 1, 0)
	TitleLabel.Position = UDim2.new(0, 20, 0, 0)
	TitleLabel.Text = title or "8.8.8.8"
	TitleLabel.RichText = true
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 18
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextXAlignment = "Left"

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -85)
	Scroll.Position = UDim2.new(0, 10, 0, 70)
	Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 2
	Scroll.ScrollBarImageColor3 = Theme.Accent
	Scroll.AutomaticCanvasSize = "Y"
	Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 15)

	local WindowActions = {}

	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.96, 0, 0, 40)
		Section.AutomaticSize = "Y"
		Section.BackgroundColor3 = Theme.Section
		Instance.new("UICorner", Section)
		
		local SLabel = Instance.new("TextLabel", Section)
		SLabel.Size = UDim2.new(1, 0, 0, 30)
		SLabel.Text = "  " .. sTitle:upper()
		SLabel.TextColor3 = Theme.Accent
		SLabel.Font = "GothamBold"
		SLabel.TextSize = 12
		SLabel.BackgroundTransparency = 1
		SLabel.TextXAlignment = "Left"

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		local L = Instance.new("UIListLayout", Container)
		L.Padding = UDim.new(0, 8)
		L.HorizontalAlignment = "Center"
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 35)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 12)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.92, 0, 0, 40)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = "  " .. text
			Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
			Btn.Font = "GothamMedium"
			Btn.TextSize = 14
			Btn.TextXAlignment = "Left"
			Btn.ClipsDescendants = true
			Btn.AutoButtonColor = false
			Instance.new("UICorner", Btn)
			local Str = Instance.new("UIStroke", Btn)
			Str.Color = Theme.Outline
			
			Btn.MouseEnter:Connect(function() TS:Create(Str, TweenInfo.new(0.3), {Color = Theme.Accent, Thickness = 1.5}):Play() end)
			Btn.MouseLeave:Connect(function() TS:Create(Str, TweenInfo.new(0.3), {Color = Theme.Outline, Thickness = 1}):Play() end)
			Btn.MouseButton1Click:Connect(function() CreateRipple(Btn) callback() end)
		end

		function SectionActions:AddSlider(text, min, max, default, callback)
			local SliderFrame = Instance.new("Frame", Container)
			SliderFrame.Size = UDim2.new(0.92, 0, 0, 55)
			SliderFrame.BackgroundTransparency = 1
			local Label = Instance.new("TextLabel", SliderFrame)
			Label.Text = "  " .. text .. " : " .. default
			Label.Size = UDim2.new(1, 0, 0, 25)
			Label.TextColor3 = Theme.Text
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = "Left"
			local Bar = Instance.new("Frame", SliderFrame)
			Bar.Name = "Bar"; Bar.Size = UDim2.new(1, -10, 0, 6); Bar.Position = UDim2.new(0, 5, 0, 35); Bar.BackgroundColor3 = Theme.Outline
			Instance.new("UICorner", Bar)
			local Fill = Instance.new("Frame", Bar)
			Fill.Name = "Fill"; Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent
			Instance.new("UICorner", Fill)
			local function Update()
				local p = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				Fill.Size = UDim2.new(p, 0, 1, 0)
				local v = math.floor(min + (max - min) * p)
				Label.Text = "  " .. text .. " : " .. v; callback(v)
			end
			local s = false
			Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then s = true Update() end end)
			UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then s = false end end)
			UIS.InputChanged:Connect(function(i) if s and i.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
		end

		return SectionActions
	end
	return WindowActions
end

return Library
