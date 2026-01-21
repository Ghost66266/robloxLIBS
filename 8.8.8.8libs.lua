-- [[ 8.8.8.8 ULTIMATE UI LIBRARY - ANTI-CRASH EDITION ]] --
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(12, 12, 14),
	Section = Color3.fromRGB(20, 20, 24),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(45, 45, 50),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(160, 160, 160)
}

-- [[ SYSTÈME D'ONDE VIOLETTE ]] --
local function CreateRipple(obj)
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Circle = Instance.new("ImageLabel")
		Circle.Name = "Ripple"
		Circle.Parent = obj
		Circle.BackgroundTransparency = 1
		Circle.Image = "rbxassetid://266543268"
		Circle.ImageColor3 = Theme.Accent
		Circle.ImageTransparency = 0.3
		Circle.ZIndex = 15
		
		local RelX = Mouse.X - obj.AbsolutePosition.X
		local RelY = Mouse.Y - obj.AbsolutePosition.Y
		Circle.Position = UDim2.new(0, RelX, 0, RelY)
		Circle.AnchorPoint = Vector2.new(0.5, 0.5)
		Circle.Size = UDim2.new(0, 0, 0, 0)
		
		local Tween = TS:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, obj.AbsoluteSize.X * 2.5, 0, obj.AbsoluteSize.X * 2.5),
			ImageTransparency = 1
		})
		Tween:Play()
		Tween.Completed:Wait()
		Circle:Destroy()
	end)
end

-- [[ ACCUEIL PERSONNALISABLE ]] --
function Library:CreateWelcomeScreen(customText)
	local Screen = Instance.new("ScreenGui", CoreGui)
	Screen.Name = "8888_Welcome"
	Screen.IgnoreGuiInset = true
	
	local Blur = Instance.new("Frame", Screen)
	Blur.Size = UDim2.new(1, 0, 1, 0)
	Blur.BackgroundColor3 = Color3.new(0,0,0)
	Blur.BackgroundTransparency = 1
	
	local Label = Instance.new("TextLabel", Screen)
	Label.Size = UDim2.new(1, 0, 0, 100)
	Label.Position = UDim2.new(0, 0, 0.5, -50)
	Label.BackgroundTransparency = 1
	Label.Text = customText or "8.8.8.8 <font color='#AA00FF'>VIRTUAL</font> ENGINE"
	Label.RichText = true
	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 0
	Label.TextTransparency = 1

	TS:Create(Blur, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
	TS:Create(Label, TweenInfo.new(1, Enum.EasingStyle.Back), {TextSize = 80, TextTransparency = 0}):Play()
	
	task.delay(3, function()
		TS:Create(Label, TweenInfo.new(0.8), {TextTransparency = 1, TextSize = 100}):Play()
		TS:Create(Blur, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
		Debris:AddItem(Screen, 1)
	end)
end

-- [[ FENÊTRE PRINCIPALE ]] --
function Library:CreateWindow(title)
	if CoreGui:FindFirstChild("8888_UserLib") then CoreGui["8888_UserLib"]:Destroy() end

	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_UserLib"

	local Main = Instance.new("Frame", UI)
	Main.Name = "MainFrame"
	Main.Size = UDim2.new(0, 520, 0, 380)
	Main.Position = UDim2.new(0.5, -260, 0.5, -190)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	
	local Stroke = Instance.new("UIStroke", Main)
	Stroke.Color = Theme.Accent
	Stroke.Thickness = 2

	-- Header (Barre de Drag)
	local Header = Instance.new("Frame", Main)
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = Theme.Section
	Header.BorderSizePixel = 0
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Size = UDim2.new(1, -20, 1, 0)
	TitleLabel.Position = UDim2.new(0, 20, 0, 0)
	TitleLabel.Text = title or "8.8.8.8 | UI"
	TitleLabel.RichText = true
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 18
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Container = Instance.new("ScrollingFrame", Main)
	Container.Name = "Container"
	Container.Size = UDim2.new(1, -20, 1, -75)
	Container.Position = UDim2.new(0, 10, 0, 60)
	Container.BackgroundTransparency = 1
	Container.ScrollBarThickness = 0
	Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Instance.new("UIListLayout", Container).Padding = UDim.new(0, 12)

	local WindowActions = {}

	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Container)
		Section.Name = sTitle .. "_Sec"
		Section.Size = UDim2.new(0.96, 0, 0, 40)
		Section.BackgroundColor3 = Theme.Section
		Section.AutomaticSize = Enum.AutomaticSize.Y
		Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 10)
		
		local SecTitle = Instance.new("TextLabel", Section)
		SecTitle.Size = UDim2.new(1, 0, 0, 30)
		SecTitle.Position = UDim2.new(0, 15, 0, 0)
		SecTitle.Text = sTitle:upper()
		SecTitle.TextColor3 = Theme.Accent
		SecTitle.Font = Enum.Font.GothamBold
		SecTitle.TextSize = 13
		SecTitle.BackgroundTransparency = 1
		SecTitle.TextXAlignment = Enum.TextXAlignment.Left

		local Elements = Instance.new("Frame", Section)
		Elements.Size = UDim2.new(1, 0, 1, 0)
		Elements.BackgroundTransparency = 1
		local EList = Instance.new("UIListLayout", Elements)
		EList.Padding = UDim.new(0, 8)
		EList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Instance.new("UIPadding", Elements).PaddingTop = UDim.new(0, 35)
		Instance.new("UIPadding", Elements).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Elements)
			Btn.Size = UDim2.new(0.94, 0, 0, 38)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = "  " .. text
			Btn.TextColor3 = Theme.TextDark
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 14
			Btn.TextXAlignment = Enum.TextXAlignment.Left
			Btn.ClipsDescendants = true
			Btn.AutoButtonColor = false
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			
			local BStroke = Instance.new("UIStroke", Btn)
			BStroke.Color = Theme.Outline

			Btn.MouseEnter:Connect(function() 
				TS:Create(BStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play() 
			end)
			Btn.MouseLeave:Connect(function() 
				TS:Create(BStroke, TweenInfo.new(0.3), {Color = Theme.Outline}):Play() 
			end)

			Btn.MouseButton1Click:Connect(function()
				CreateRipple(Btn)
				callback()
			end)
		end

		function SectionActions:AddSlider(text, min, max, default, callback)
			local Sld = Instance.new("Frame", Elements)
			Sld.Size = UDim2.new(0.94, 0, 0, 50)
			Sld.BackgroundTransparency = 1

			local Lab = Instance.new("TextLabel", Sld)
			Lab.Size = UDim2.new(1, 0, 0, 20)
			Lab.Text = "  " .. text .. " : " .. default
			Lab.TextColor3 = Theme.Text
			Lab.Font = "GothamMedium"; Lab.TextSize = 13; Lab.BackgroundTransparency = 1; Lab.TextXAlignment = "Left"

			local Bar = Instance.new("Frame", Sld)
			Bar.Size = UDim2.new(1, -10, 0, 6); Bar.Position = UDim2.new(0, 5, 0, 30); Bar.BackgroundColor3 = Theme.Outline; Instance.new("UICorner", Bar)

			local Fill = Instance.new("Frame", Bar)
			Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", Fill)

			local function Update()
				local p = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				TS:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(p, 0, 1, 0)}):Play()
				local v = math.floor(min + (max-min)*p)
				Lab.Text = "  " .. text .. " : " .. v; callback(v)
			end

			local active = false
			Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = true Update() end end)
			UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end)
			UIS.InputChanged:Connect(function(i) if active and i.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
		end

		return SectionActions
	end
	return WindowActions
end

return Library
