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

-- [[ UTILITAIRES ]] --
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
	
	local RelX = Mouse.X - obj.AbsolutePosition.X
	local RelY = Mouse.Y - obj.AbsolutePosition.Y
	Circle.Position = UDim2.new(0, RelX, 0, RelY)
	Circle.AnchorPoint = Vector2.new(0.5, 0.5)

	TS:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, obj.AbsoluteSize.X * 2.5, 0, obj.AbsoluteSize.X * 2.5),
		ImageTransparency = 1
	}):Play()
	Debris:AddItem(Circle, 0.6)
end

-- [[ 1. ÉCRAN DE BIENVENUE (TEXTE SEUL) ]] --
function Library:CreateWelcomeScreen()
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
	TextLabel.TextSize = 0
	TextLabel.TextTransparency = 1

	-- Animation d'entrée
	TS:Create(TextLabel, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextSize = 80,
		TextTransparency = 0
	}):Play()

	-- Temps d'affichage (6 secondes)
	task.delay(6, function()
		TS:Create(TextLabel, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			TextTransparency = 1,
			TextSize = 100
		}):Play()
		Debris:AddItem(WelcomeGui, 1.1)
	end)
end

-- [[ 2. FENÊTRE PRINCIPALE ]] --
function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_Main"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 520, 0, 380)
	Main.Position = UDim2.new(0.5, -260, 0.5, -190)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", Main).Color = Theme.Outline

	-- Drag System
	local d, ds, sp
	Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = Main.Position end end)
	UIS.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - ds
		Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
	end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

	-- Header
	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 45)
	Header.BackgroundColor3 = Theme.Section
	Header.BorderSizePixel = 0
	Instance.new("UICorner", Header)

	local Title = Instance.new("TextLabel", Header)
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.Text = title or "8.8.8.8 UI"
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -65)
	Scroll.Position = UDim2.new(0, 10, 0, 55)
	Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 0
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.CanvasSize = UDim2.new(0,0,0,0)
	Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 12)

	local WindowActions = {}

	-- [[ 3. SECTIONS ]] --
	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.96, 0, 0, 30)
		Section.AutomaticSize = Enum.AutomaticSize.Y
		Section.BackgroundColor3 = Theme.Section
		Instance.new("UICorner", Section)
		Instance.new("UIStroke", Section).Color = Theme.Outline

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		Instance.new("UIListLayout", Container).Padding = UDim.new(0, 6)
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 12)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		-- [[ 4. BOUTON ]] --
		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.92, 0, 0, 35)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = "  " .. text
			Btn.TextColor3 = Theme.TextDark
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 13
			Btn.TextXAlignment = Enum.TextXAlignment.Left
			Btn.ClipsDescendants = true
			Btn.AutoButtonColor = false
			Instance.new("UICorner", Btn)
			
			Btn.MouseButton1Click:Connect(function()
				CreateRipple(Btn)
				callback()
			end)
		end

		-- [[ 5. TOGGLE ]] --
		function SectionActions:AddToggle(text, callback)
			local Tgl = Instance.new("TextButton", Container)
			Tgl.Size = UDim2.new(0.92, 0, 0, 35)
			Tgl.BackgroundTransparency = 1
			Tgl.Text = "  " .. text
			Tgl.TextColor3 = Theme.TextDark
			Tgl.Font = Enum.Font.Gotham
			Tgl.TextXAlignment = Enum.TextXAlignment.Left

			local Box = Instance.new("Frame", Tgl)
			Box.Size = UDim2.new(0, 35, 0, 18)
			Box.Position = UDim2.new(1, -45, 0.5, -9)
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

		-- [[ 6. SLIDER ]] --
		function SectionActions:AddSlider(text, min, max, default, callback)
			local SliderFrame = Instance.new("Frame", Container)
			SliderFrame.Size = UDim2.new(0.92, 0, 0, 45)
			SliderFrame.BackgroundTransparency = 1

			local Label = Instance.new("TextLabel", SliderFrame)
			Label.Text = "  " .. text
			Label.Size = UDim2.new(1, 0, 0, 20)
			Label.TextColor3 = Theme.TextDark
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = Enum.TextXAlignment.Left

			local Bar = Instance.new("Frame", SliderFrame)
			Bar.Size = UDim2.new(1, -10, 0, 6)
			Bar.Position = UDim2.new(0, 5, 0, 30)
			Bar.BackgroundColor3 = Theme.Outline
			Instance.new("UICorner", Bar)

			local Fill = Instance.new("Frame", Bar)
			Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Instance.new("UICorner", Fill)

			local function Update(input)
				local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				Fill.Size = UDim2.new(pos, 0, 1, 0)
				local val = math.floor(min + (max - min) * pos)
				callback(val)
			end

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then Update(input) end
			end)
		end

		return SectionActions
	end
	return WindowActions
end

return Library
