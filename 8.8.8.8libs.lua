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

-- [[ EFFETS VISUELS UNIQUES ]] --

-- 1. Onde de choc (Ripple) avec flou
local function CreateRipple(obj)
	local Mouse = game.Players.LocalPlayer:GetMouse()
	local Circle = Instance.new("ImageLabel")
	Circle.Parent = obj
	Circle.BackgroundColor3 = Color3.new(1, 1, 1)
	Circle.BackgroundTransparency = 1
	Circle.Image = "rbxassetid://266543268"
	Circle.ImageColor3 = Theme.Accent
	Circle.ImageTransparency = 0.4
	Circle.ZIndex = 10
	local RelX = Mouse.X - obj.AbsolutePosition.X
	local RelY = Mouse.Y - obj.AbsolutePosition.Y
	Circle.Position = UDim2.new(0, RelX, 0, RelY)
	Circle.AnchorPoint = Vector2.new(0.5, 0.5)
	TS:Create(Circle, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, obj.AbsoluteSize.X * 2.5, 0, obj.AbsoluteSize.X * 2.5),
		ImageTransparency = 1
	}):Play()
	Debris:AddItem(Circle, 0.7)
end

-- 2. Effet de lueur (Glow)
local function AddGlow(object)
	local Glow = Instance.new("UIStroke", object)
	Glow.Color = Theme.Accent
	Glow.Transparency = 0.8
	Glow.Thickness = 0
	Glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return Glow
end

-- [[ FONCTION D'ACCUEIL (PREMIER PLAN ABSOLU) ]] --
function Library:CreateWelcomeScreen()
	local WelcomeGui = Instance.new("ScreenGui", CoreGui)
	WelcomeGui.Name = "8888_Welcome_Final"
	WelcomeGui.DisplayOrder = 999999 -- Toujours devant tout
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

	-- Animation de Zoom & Fade
	TS:Create(TextLabel, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextSize = 85,
		TextTransparency = 0
	}):Play()

	task.delay(5, function()
		TS:Create(TextLabel, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			TextTransparency = 1,
			TextSize = 120
		}):Play()
		Debris:AddItem(WelcomeGui, 1.2)
	end)
end

-- [[ SYSTÈME DE FENÊTRE ]] --
function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_UserLib"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 520, 0, 380)
	Main.Position = UDim2.new(0.5, -260, 0.5, -190)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	local Stroke = Instance.new("UIStroke", Main)
	Stroke.Color = Theme.Outline
	Stroke.Thickness = 1.5

	-- Header Holographique
	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = Theme.Section
	Instance.new("UICorner", Header)

	local Scanline = Instance.new("Frame", Header)
	Scanline.Size = UDim2.new(1, 0, 0, 2)
	Scanline.BackgroundColor3 = Theme.Accent
	Scanline.BackgroundTransparency = 0.6
	TS:Create(Scanline, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0,0,1,0)}):Play()

	local Title = Instance.new("TextLabel", Header)
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.Text = title or "8.8.8.8"
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 17
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = "Left"

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -75)
	Scroll.Position = UDim2.new(0, 10, 0, 60)
	Scroll.BackgroundTransparency = 1
	Scroll.AutomaticCanvasSize = "Y"
	Scroll.ScrollBarThickness = 2
	Scroll.ScrollBarImageColor3 = Theme.Accent
	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 12)
	Layout.HorizontalAlignment = "Center"

	local WindowActions = {}

	-- [[ SECTIONS AVEC EFFET HOVER ]] --
	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.96, 0, 0, 30)
		Section.AutomaticSize = "Y"
		Section.BackgroundColor3 = Theme.Section
		Instance.new("UICorner", Section)
		local sStroke = Instance.new("UIStroke", Section)
		sStroke.Color = Theme.Outline

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		local L = Instance.new("UIListLayout", Container)
		L.Padding = UDim.new(0, 8)
		L.HorizontalAlignment = "Center"
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 15)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		-- [[ BOUTONS AVEC INTERACTION AVANCÉE ]] --
		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.92, 0, 0, 38)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = "  " .. text
			Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			Btn.Font = "GothamMedium"
			Btn.TextSize = 14
			Btn.TextXAlignment = "Left"
			Btn.AutoButtonColor = false
			Btn.ClipsDescendants = true
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			local bStroke = Instance.new("UIStroke", Btn)
			bStroke.Color = Theme.Outline

			Btn.MouseEnter:Connect(function()
				TS:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
				TS:Create(bStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play()
			end)
			Btn.MouseLeave:Connect(function()
				TS:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Main}):Play()
				TS:Create(bStroke, TweenInfo.new(0.3), {Color = Theme.Outline}):Play()
			end)

			Btn.MouseButton1Click:Connect(function()
				CreateRipple(Btn)
				callback()
			end)
		end

		-- [[ SLIDER NÉON ]] --
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
			Label.Font = "Gotham"

			local Bar = Instance.new("Frame", SliderFrame)
			Bar.Size = UDim2.new(1, -10, 0, 4)
			Bar.Position = UDim2.new(0, 5, 0, 35)
			Bar.BackgroundColor3 = Theme.Outline
			Instance.new("UICorner", Bar)

			local Fill = Instance.new("Frame", Bar)
			Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Instance.new("UICorner", Fill)

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

			local sliding = false
			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
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
